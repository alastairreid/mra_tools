#!/usr/bin/env python3

'''
Unpack ARM instruction XML files extracting the encoding information
and ASL code within it.
'''

import argparse
import glob
import json
import os
import re
import string
import sys
import xml.etree.cElementTree as ET
from collections import defaultdict
from itertools import takewhile

include_regex = None
exclude_regex = None

########################################################################
# Tag file support
########################################################################

tags = set()
'''
Write content to a 'tag file' suppressing duplicate information
'''
def emit(f, tag, content):
    if tag not in tags: # suppress duplicate entries
        tags.add(tag)
        print('TAG:'+tag, file=f)
        print(content, file=f)


########################################################################
# Workarounds
########################################################################

# workaround: v8-A code still uses the keyword 'type' as a variable name
# change that to 'type1'
def patchTypeAsVar(x):
    return re.sub(r'([^a-zA-Z0-9_\n])type([^a-zA-Z0-9_])', r'\1type1\2', x)

########################################################################
# Classes
########################################################################

class ASL:
    '''Representation of ASL code consisting of the code, list of names it defines and list of dependencies'''

    def __init__(self, name, code, defs, deps):
        self.name = name
        self.code = code
        self.defs = defs
        self.deps = deps

    def emit(self, file, tag):
        emit(file, tag, self.code)

    def put(self, ofile, indent):
        for l in self.code.splitlines():
            print(" "*indent + l, file=ofile)

    def __str__(self):
        return "ASL{"+", ".join([self.name, str(self.defs), str(self.deps)])+"}"

    # workaround: patch all ASL code with extra dependencies
    def patchDependencies(self, chunks):
        for line in self.code.splitlines():
            l = re.split('//', line)[0]  # drop comments
            for m in re.finditer('''([a-zA-Z_]\w+(\.\w+)?\[?)''', l):
                n = m.group(1)
                if n in chunks:
                    self.deps |= {chunks[n].name}
                    self.deps |= {n}
                    # print("Adding dep", n, chunks[n].name)
        self.deps -= self.defs
        # Workaround: ProcState SP field incorrectly handled
        if self.name == "shared/functions/system/ProcState": self.deps -= {"SP", "SP.write.none"}
        if "Unpredictable_WBOVERLAPST" in self.defs: self.deps -= {"PSTATE"}

    # workaround: v8-A code still uses the keyword 'type' as a variable name
    # change that to 'type1'
    def patchTypeVar(self):
        self.code = patchTypeAsVar(self.code)

    def toPrototype(self):
        '''Strip function bodies out of ASL
           This is used when a function is cut but we still need to keep
           the function body.'''
        # build groups of lines based on whether they have matching numbers of parentheses
        groups = []
        group  = []
        parens = 0
        for l in self.code.splitlines():
            group.append(l)
            # update count of matching parentheses
            openers = len(re.findall('[([]', l))
            closers = len(re.findall('[)\]]', l))
            parens = parens + openers - closers
            if parens == 0:
                groups.append(group)
                group = []
        # crude heuristic for function bodies: starts with blank chars
        # beware: only works if the ASL block only contains functions
        lines = [ l for g in groups if not g[0].startswith("    ") for l in g ]
        # print("Generating prototype for "+self.name)
        # print("  "+"\n  ".join(lines))
        return ASL(self.name, '\n'.join(lines), self.defs, set())

# Test whether instruction encoding has a field with given name
def hasField(fields, nm):
    return any(f == nm for (_, _, f, _, _) in fields)

# Turn instruction and encoding names into identifiers
# e.g., "aarch32/UHSAX/A1_A" becomes "aarch32_UHSAX_A1_A"
# and remove dots from "LDNT1D_Z.P.BR_Contiguous"
def deslash(nm):
    return nm.replace("/instrs","").replace("/", "_").replace("-","_").replace(".","_")

class Instruction:
    '''Representation of Instructions'''

    def __init__(self, name, encs, post, conditional, exec):
        self.name = name
        self.encs = encs
        self.post = post
        self.conditional = conditional
        self.exec = exec

    def emit_asl_syntax(self, ofile):
        print("__instruction "+ deslash(self.name), file=ofile)

        for (inm,insn_set,fields,dec) in self.encs:
            unpreds = []
            pattern = "" # todo: assumes that fields are sorted in order

            print("    __encoding "+ deslash(inm), file=ofile)
            print("        __instruction_set "+ insn_set, file=ofile)
            for (hi, lo, nm, split, consts) in fields:
                # assert(not split) todo
                wd = (hi - lo) + 1

                if re.fullmatch("(\([01]\))+", nm):
                    # workaround
                    consts = nm
                    nm = '_'

                # convert all the 'should be' bits to 'unpredictable_unless'
                cs = ""
                i  = hi
                while consts != "":
                    if consts.startswith("(1)") or consts.startswith("(0)"):
                        unpreds.append((i, consts[1]))
                        cs = cs + "x"
                        consts = consts[3:]
                    elif consts[0] in "01x":
                        cs = cs + consts[0]
                        consts = consts[1:]
                    else:
                        print("Malformed field "+consts)
                        assert False
                    i = i - 1
                consts = cs
                assert len(consts) == wd
                pattern = pattern + consts
                nm = patchTypeAsVar(nm) # workaround
                if nm != "_":
                    print("        __field "+nm+" "+str(lo)+" +: "+str(wd), file=ofile)
            pattern = [ pattern[i:i+8] for i in range(0, len(pattern), 8) ]
            print("        __opcode '" + " ".join(pattern) + "'", file=ofile)
            guard = "cond != '1111'" if  insn_set == "A32" and hasField(fields, "cond") else "TRUE";
            print("        __guard "+guard, file=ofile)
            for (i, v) in unpreds:
                print("        __unpredictable_unless "+str(i)+" == '"+v+"'", file=ofile)

            print("        __decode", file=ofile)
            dec.patchTypeVar()
            dec.put(ofile, 12)
            print(file=ofile)
        if self.post:
            print("    __postdecode", file=ofile)
            self.post.patchTypeVar()
            self.post.put(ofile, 8)
        if self.conditional:
            print("    __execute __conditional", file=ofile)
        else:
            print("    __execute", file=ofile)
        self.exec.patchTypeVar()
        self.exec.put(ofile, 8)

    def emit_tag_syntax(self, file):
        index = [] # index of sections of this instruction
        exec_tag = self.name+':execute'
        post_tag = self.name+':postdecode'
        idx_tag  = self.name+':index'
        self.exec.emit(file, exec_tag)
        index.append('Execute: '+exec_tag)
        if self.post:
            self.post.emit(file, post_tag)
            index.append('Postdecode: '+post_tag)
        for (inm,insn_set,fields,dec) in self.encs:
            dec_tag  = inm + ':decode'
            enc_tag  = inm + ':diagram'
            enc = [insn_set]
            enc.extend([str(hi)+":"+str(lo)+" "+nm+" "+consts
                        for (hi,lo,nm,_,consts) in fields ])
            emit(file, enc_tag, "\n".join(enc))
            dec.emit(file, dec_tag)
            index.append('Decode: '+dec_tag+'@'+enc_tag)
        emit(file, idx_tag, "\n".join(index))

    def emit_sail_ast(self, previous_clauses, file):
        for enc in self.encs:
            enc_name, enc_iset, enc_fields, enc_asl = enc
            fields = [(nm, hi - lo + 1) for (hi, lo, nm, split, consts) in enc_fields if nm != '_']
            typed_fields = ['/* {} : */ bits({})'.format(name, length)  for (name, length) in fields]
            if len(typed_fields) < 1:
                clause = 'union clause ast = ' + sanitize(enc_name) + ' : unit'
            else:
                clause = 'union clause ast = ' + sanitize(enc_name) + ' : (' + ', '.join(typed_fields) + ')'
            if clause not in previous_clauses:
                print(clause, file=file)
                previous_clauses.add(clause)

    def __str__(self):
        encs = "["+ ", ".join([inm for (inm,_,_,_) in self.encs]) +"]"
        return "Instruction{" + ", ".join([encs, (self.post.name if self.post else "-"), self.exec.name])+", "+conditional+"}"


########################################################################
# Extracting information from XML files
########################################################################

alt_slice_syntax = False
demangle_instr = False

'''
Read pseudocode to extract ASL.
'''
def readASL(ps):
    name = ps.attrib["name"]
    name = name.replace(".txt","")
    name = name.replace("/instrs","")
    name = name.replace("/Op_","/")
    chunk = ps.find("pstext")

    # list of things defined in this chunk
    defs = { x.attrib['link'] for x in chunk.findall('anchor') }

    # extract dependencies from hyperlinks in the XML
    deps = { x.attrib['link'] for x in chunk.findall('a') if not x.text.startswith("SEE") }

    # drop impl- prefixes in links
    deps = { re.sub('(impl-\w+\.)','',x) for x in deps }
    defs = { re.sub('(impl-\w+\.)','',x) for x in defs }

    # drop file references in links
    deps = { re.sub('([^#]+#)','',x) for x in deps }

    code = ET.tostring(chunk, method="text").decode().rstrip()+"\n"

    if alt_slice_syntax:
        code = "\n".join(map(patchSlices, code.split('\n')))

    return ASL(name, code, defs, deps)


'''
Classic ASL syntax has a syntax ambiguity involving the use of
angles (< and >) both to delimit bitslices and as comparision
operators.
We make parsing easier by converting bitslices to use square brackets
using a set of heuristics to distinguish bitslices from comparisions.
'''
def patchSlices(x):
    reIndex = r'[0-9a-zA-Z_+*:\-()[\]., ]+'
    rePart = reIndex
    reParts = rePart+"(,"+rePart+")*"
    x = re.sub("<("+reParts+")>", r'[\1]',x)
    x = re.sub("<("+reParts+")>", r'[\1]',x)
    x = re.sub("<("+reParts+")>", r'[\1]',x)
    x = re.sub("<("+reParts+")>", r'[\1]',x)
    return x

'''
Read encoding diagrams header found in encoding index XML
'''
def readDiagram(reg):
    size = reg.attrib['form']

    fields = []
    for b in reg.findall('box'):
        wd = int(b.attrib.get('width','1'))
        hi = int(b.attrib['hibit'])
        # normalise T16 reg bit numbers
        lo = hi - wd + 1
        fields.append((lo, wd))
    return (size, fields)

def squote(s):
    return "'"+s+"'"

'''
Convert a field in a decode table such as "111" or "!= 111" or None
to a legal ASL pattern
'''
def fieldToPattern(f):
    if f:
        return "!"+squote(f[3:]) if f.startswith('!= ') else squote(f)
    else:
        return "_"

'''
Read encoding diagrams entries found in encoding index XML
'''
def readDecode(d, columns):
    values = {}
    for b in d.findall('box'):
        wd = int(b.attrib.get('width','1'))
        hi = int(b.attrib['hibit'])
        lo = hi - wd + 1
        values[lo] = fieldToPattern(b.find('c').text)
    return [ values.get(lo, "_") for (lo, _) in columns ]

def readIClass(c):
    label = c.attrib['iclass']
    allocated = c.attrib.get("unallocated", "0") == "0"
    predictable = c.attrib.get("unpredictable", "0") == "0"
    assert allocated or predictable
    # print("Reading iclass "+label+" "+str(allocated)+" "+str(unpredictable))
    return (label, allocated, predictable)

'''
'''
def readGroup(label, g):
    # print("Reading group "+label)
    diagram = readDiagram(g.find("regdiagram"))
    # print("Diagram "+str(diagram))

    children = []

    for n in g.findall('node'):
        dec = readDecode(n.find('decode'), diagram[1])
        # print("Decode "+str(dec), diagram[1])
        if 'iclass' in n.attrib:
            i = readIClass(n)
            children.append((dec, False, i))
        elif 'groupname' in n.attrib:
            nm = n.attrib['groupname']
            g = readGroup(nm, n)
            children.append((dec, True, g))
        else:
            assert False
    return (label, diagram, children)

'''
'''
def readInstrName(dir, filename, encname):
    filename = dir+"/"+filename
    xml = ET.parse(filename)
    for ic in xml.findall(".//iclass"):
        decode = ic.find("regdiagram").attrib['psname']
        for enc in ic.findall("encoding"):
            if not encname or enc.attrib['name'] == encname:
                decode = decode.replace(".txt","")
                decode = decode.replace("/instrs","")
                decode = decode.replace("-","_")
                decode = decode.replace("/","_")
                return decode
    assert False

'''
'''
def readITables(dir, root):
    classes = {}
    funcgroup = None # hack: structure of XML is not quite hierarchial
    for child in root.iter():
        if child.tag == 'funcgroupheader':
            funcgroup = child.attrib['id']
            # print("Functional Group "+funcgroup)
        elif child.tag == 'iclass_sect':
            iclass_id = child.attrib['id']
            fields = [ (b.attrib['name'], int(b.attrib['hibit']), int(b.attrib.get('width', 1))) for b in child.findall('regdiagram/box') if 'name' in b.attrib ]
            # print("Group "+funcgroup +" "+ iclass_id +' '+str(fields))
            tables = []
            for i in child.findall('instructiontable'):
                iclass = i.attrib['iclass']
                headers = [ r.text for r in i.findall('thead/tr/th') if r.attrib['class'] == 'bitfields' ]
                headers = [ patchTypeAsVar(nm) for nm in headers ] # workaround
                # print("ITable "+funcgroup +" "+ iclass +" "+str(headers))
                rows = []
                for r in i.findall('tbody/tr'):
                    patterns = [ fieldToPattern(d.text) for d in r.findall('td') if d.attrib['class'] == 'bitfield' ]
                    undef    = r.get('undef', '0') == '1'
                    unpred   = r.get('unpred', '0') == '1'
                    nop      = r.get('reserved_nop_hint', '0') == '1'
                    encname  = r.get('encname')
                    nm       = "_" if undef or unpred or nop else readInstrName(dir, r.attrib['iformfile'], encname)
                    rows.append((patterns, nm, encname, undef, unpred, nop))
                tables.append((iclass, headers, rows))
                # print(iclass, fields, headers, rows)
            assert len(tables) == 1
            # discard fields that are not used to select instruction
            # fields = [ (nm, hi, wd) for (nm, hi, wd) in fields if nm in headers ]
            fields = [ (patchTypeAsVar(nm), hi, wd) for (nm, hi, wd) in fields ] # workaround
            classes[iclass_id] = (fields, tables[0])
    return classes

'''
'''
def readDecodeFile(dir, file):
    print("Reading decoder "+file)
    root = ET.parse(file)

    iset = root.getroot().attrib['instructionset']
    groups = readGroup(iset, root.find('hierarchy'))

    classes = readITables(dir, root)

    return (groups, classes)

def ppslice(f):
    (lo, wd) = f
    return (str(lo) +" +: "+ str(wd))

def printITable(ofile, level, c):
    (fields, (ic, hdr, rows)) = c
    for (fnm, hi, wd) in fields:
        print("    "*level + "__field "+ fnm +" "+str(hi-wd+1) +" +: "+str(wd), file=ofile)
    print("    "*level +"case ("+ ", ".join(hdr) +") of", file=ofile)
    for (pats, nm, encname, undef, unpred, nop) in rows:
        nm = "__encoding "+deslash(nm)
        if encname: nm = nm + " // " +encname
        if undef: nm = "__UNALLOCATED"
        if unpred: nm = "__UNPREDICTABLE"
        if nop: nm = "__NOP"
        print("    "*(level+1) +"when ("+ ", ".join(pats) +") => "+ nm, file=ofile)
    return

def printDiagram(ofile, level, reg):
    (size, fields) = reg
    print("    "*level +"case ("+ ", ".join(map(ppslice, fields)) +") of", file=ofile)
    return

def printGroup(ofile, classes, level, root):
    (label, diagram, children) = root
    print("    "*level + "// "+label, file=ofile)
    printDiagram(ofile, level, diagram)
    for (dec, isGroup, c) in children:
        if isGroup:
            print("    "*(level+1) +"when ("+ ", ".join(dec) +") =>", file=ofile)
            printGroup(ofile, classes, level+2, c)
        else:
            (label, allocated, predictable) = c
            tag = "// "+label
            if allocated and predictable:
                (fields, (ic, hdr, rows)) = classes[label]
                print("    "*(level+1) +"when ("+ ", ".join(dec) +") => " +tag, file=ofile)
                printITable(ofile, level+2, classes[label])
            else:
                if not allocated: tag = "__UNPREDICTABLE"
                if not predictable: tag = "__UNALLOCATED"
                print("    "*(level+1) +"when ("+ ", ".join(dec) +") => " +tag, file=ofile)

    return

def printDecodeTree(ofile, groups, classes):
    print("__decode", groups[0], file=ofile)
    printGroup(ofile, classes, 1, groups)

'''
Read shared pseudocode files to extract ASL.
Result is sorted so that uses come before definitions.
'''
def readShared(files):
    asl = {}
    names = set()
    for f in files:
        xml = ET.parse(f)
        for ps in xml.findall('.//ps_section/ps'):
            r = readASL(ps)
            # workaround: patch use of type as a variable name
            r.patchTypeVar()
            # workaround: patch SCTLR[] definition
            if r.name == "aarch64/functions/sysregisters/SCTLR":
                r.code = r.code.replace("bits(32) r;", "bits(64) r;")
            # workaround: patch AArch64.CheckUnallocatedSystemAccess
            if r.name == "aarch64/functions/system/AArch64.CheckUnallocatedSystemAccess":
                r.code = r.code.replace("bits(2) op0,", "bits(2) el, bits(2) op0,")
            # workaround: patch AArch64.CheckSystemAccess
            if r.name == "aarch64/functions/system/AArch64.CheckSystemAccess":
                r.code = r.code.replace("AArch64.CheckSVESystemRegisterTraps(op0, op1, crn, crm, op2);",
                                        "AArch64.CheckSVESystemRegisterTraps(op0, op1, crn, crm, op2, read);")

            # workaround: collect type definitions
            for m in re.finditer('''(?m)^(enumeration|type)\s+(\S+)''',r.code):
                r.defs.add(m.group(2))
                names |= {m.group(2)}
            # workaround: collect variable definitions
            for m in re.finditer('''(?m)^(\S+)\s+([a-zA-Z_]\w+);''',r.code):
                if m.group(1) != "type":
                    # print("variable declaration", m[1], m[2])
                    r.defs.add(m.group(2))
                    names |= {m.group(2)}
            # workaround: collect array definitions
            for m in re.finditer('''(?m)^array\s+(\S+)\s+([a-zA-Z_]\w+)''',r.code):
                # print("array declaration", m[1], m[2])
                v = m.group(2)+"["
                r.defs.add(v)
                names |= {v}
            # workaround: collect variable accessors
            for m in re.finditer('''(?m)^(\w\S+)\s+([a-zA-Z_]\w+)\s*$''',r.code):
                # print("variable accessor", m[1], m[2])
                r.defs.add(m.group(2))
                names |= {m.group(2)}
            # workaround: collect array accessors
            for m in re.finditer('''(?m)^(\w\S+)\s+([a-zA-Z_]\w+)\[''',r.code):
                # print("array accessor", m[1], m[2])
                v = m.group(2)+"["
                r.defs.add(v)
                names |= {v}
            # workaround: add PSTATE definition/dependency
            if r.name == 'shared/functions/system/PSTATE': r.defs.add("PSTATE")
            if "PSTATE" in r.code: r.deps.add("PSTATE")

            # workaround: skip standard library functions
            if r.name in [
                'shared/functions/common/SInt',
                'shared/functions/common/UInt',
                'shared/functions/common/Ones',
                'shared/functions/common/Zeros',
                'shared/functions/common/IsOnes',
                'shared/functions/common/IsZero',
                'shared/functions/common/SignExtend',
                'shared/functions/common/ZeroExtend',
                'shared/functions/common/Replicate',
                'shared/functions/common/RoundDown',
                'shared/functions/common/RoundUp',
                'shared/functions/common/RoundTowardsZero',
                ]:
                continue

            asl[r.name] = r

    return (asl, names)


'''
Read ARM's license notice from an XML file.
Convert unicode characters to ASCII equivalents (e.g,, (C)).
Return a giant comment block containing the notice.
'''
def readNotice(xml):
    # Read proprietary notice
    notice = ['/'*72, "// Proprietary Notice"]
    for p in xml.iter('para'):
        para = ET.tostring(p, method='text').decode().rstrip()
        para = para.replace("&#8217;", "'")
        para = para.replace("&#8220;", '"')
        para = para.replace("&#8221;", '"')
        para = para.replace("&#8482;", '(TM)')
        para = para.replace("&#169;", '(C)')
        para = para.replace("&#174;", '(R)')
        lines = [ ('// '+l).rstrip() for l in para.split('\n') ]
        notice.extend(lines)
    notice.append('/'*72)
    return '\n'.join(notice)

def sanitize(name):
    new_name = ""
    for c in name:
        if c not in string.ascii_letters and c not in string.digits:
            new_name += "_"
        else:
            new_name += c
    return new_name

# remove one level of indentation from code
def indent(code):
    return [ "    " + l for l in code ]

# remove one level of indentation from code
def unindent(code):
    cs = []
    for l in code:
        if l != "" and l[0:4] != "    ":
            print("Malformed conditional code '" + l[0:4] +"'")
            assert False
        cs.append(l[4:])
    return cs

# Execute ASL code often has a header like this:
#
#     if ConditionPassed() then
#         EncodingSpecificOperations();
#
# that we need to transform into a more usable form.
# Other patterns found are:
# - declaring an enumeration before the instruction
# - inserting another line of code between the first and second lines.
#   eg "if PSTATE.EL == EL2 then UNPREDICTABLE;"
# - wrapping the entire instruction in
#    "if code[0].startswith("if CurrentInstrSet() == InstrSet_A32 then"):
#
# Return value consists of (top, cond, dec, exec):
# - additional top level declarations (of enumerations)
# - boolean: is the instruction conditional?
# - additional decode logic (to be added to start of decode ASL)
# - demangled execute logic
def demangleExecuteASL(code):
    tops = None
    conditional = False
    decode = None
    if code[0].startswith("enumeration ") and code[1] == "":
        tops = code[0]
        code = code[2:]
    if code[0].startswith("if CurrentInstrSet() == InstrSet_A32 then"):
        first = code[0]
        code = code[1:]
        mid = code.index("else")
        code1 = unindent(code[:mid])
        code2= unindent(code[mid+1:])
        (tops1, conditional1, decode1, code1) = demangleExecuteASL(code1)
        (tops2, conditional2, decode2, code2) = demangleExecuteASL(code2)
        assert tops1 == None and tops2 == None
        assert conditional1 == conditional2
        code = [first] + indent(code1) + ["else"] + indent(code2)
        ([], conditional1, "\n".join([decode1 or "", decode2 or ""]), code)

    if code[0] == "if ConditionPassed() then":
        conditional = True
        code = code[1:] # delete first line
        code = unindent(code)
    if code[0] == "bits(128) result;":
        tmp = code[0]
        code[0] = code[1]
        code[1] = tmp
    elif len(code) >= 2 and code[1] == "EncodingSpecificOperations();":
        decode = code[0]
        code = code[1:]
    if code[0].startswith("EncodingSpecificOperations();"):
        rest = code[0][29:].strip()
        if rest == "":
            code = code[1:]
        else:
            code[0] = rest
    return (tops, conditional, decode, code)

def readInstruction(xml,names,sailhack):
    execs = xml.findall(".//pstext[@section='Execute']/..")
    posts = xml.findall(".//pstext[@section='Postdecode']/..")
    assert(len(posts) <= 1)
    assert(len(execs) <= 1)
    if not execs: return (None, None) # discard aliases

    exec = readASL(execs[0])
    post = readASL(posts[0]) if posts else None

    if demangle_instr:
        # demangle execute code
        code = exec.code.splitlines()
        (top, conditional, decode, execute) = demangleExecuteASL(code)
        exec.code = '\n'.join(execute)
    else:
        top = None
        conditional = False
        decode = None

    exec.patchDependencies(names)
    if post: post.patchDependencies(names)

    include_matches = include_regex is None or include_regex.search(exec.name)
    exclude_matches = exclude_regex is not None and exclude_regex.search(exec.name)
    if not include_matches or exclude_matches:
        return None


    # for each encoding, read instructions encoding, matching decode ASL and index
    encs = []
    for iclass in xml.findall('.//classes/iclass'):
        encoding = iclass.find('regdiagram')
        isT16 = encoding.attrib['form'] == "16"
        insn_set = "T16" if isT16 else iclass.attrib['isa']

        fields = []
        for b in encoding.findall('box'):
            wd = int(b.attrib.get('width','1'))
            hi = int(b.attrib['hibit'])
            lo = hi - wd + 1
            nm  = b.attrib.get('name', '_') if b.attrib.get('usename', '0') == '1' else '_'
            # workaround for Sail
            if sailhack and nm == 'type': nm = 'typ'
            ignore = 'psbits' in b.attrib and b.attrib['psbits'] == 'x'*wd
            consts = ''.join([ 'x'*int(c.attrib.get('colspan','1')) if c.text is None or ignore else c.text for c in b.findall('c') ])

            # workaround: add explicit slicing to LDM/STM register_list fields
            if nm == "register_list" and wd == 13: nm = nm + "<12:0>"

            # if adjacent entries are two parts of same field, join them
            # e.g., imm8<7:1> and imm8<0> or opcode[5:2] and opcode[1:0]
            m = re.match('^(\w+)[<[]', nm)
            if m:
                nm = m.group(1)
                split = True
                if fields[-1][3] and fields[-1][2] == nm:
                    (hi1,lo1,_,_,c1) = fields.pop()
                    assert(lo1 == hi+1) # must be adjacent
                    hi = hi1
                    consts = c1+consts
            else:
                split = False

            # discard != information because it is better obtained elsewhere in spec
            if consts.startswith('!='): consts = 'x'*wd

            fields.append((hi,lo,nm,split,consts))

        # pad opcode with zeros for T16 so that all opcodes are 32 bits
        if isT16:
            fields.append((15,0,'_',False,'0'*16))

        # workaround: avoid use of overloaded field names
        fields2 = []
        for (hi, lo, nm, split, consts) in fields:
            if (nm in ["SP", "mask", "opcode"]
               and 'x' not in consts
               and exec.name not in ["aarch64/float/convert/fix", "aarch64/float/convert/int"]):
                # workaround: avoid use of overloaded field name
                nm = '_'
            fields2.append((hi,lo,nm,split,consts))

        dec_asl = readASL(iclass.find('ps_section/ps'))
        if decode: dec_asl.code = decode +"\n"+ dec_asl.code
        dec_asl.patchDependencies(names)

        name = dec_asl.name if insn_set in ["T16","T32","A32"] else encoding.attrib['psname']
        encs.append((name, insn_set, fields2, dec_asl))

    return (Instruction(exec.name, encs, post, conditional, exec), top)

########################################################################
# Reachability analysis
########################################################################

# Visit all nodes reachable from roots
# Returns topologically sorted list of reachable nodes
# and set of reachable nodes.
def reachable(graph, roots):
    visited = set()
    sorted = []

    def worker(seen, f):
        if f in seen:
            # print("Cyclic dependency",f)
            pass
        elif f not in visited:
            visited.add(f)
            for g in graph[f]: worker(seen + [f], g)
            sorted.append(f)

    for f in roots: worker([], f)
    return (sorted, visited)

########################################################################
# Canary detection
########################################################################

# Check all paths from a function 'f' to any function in the list 'canaries'
# and report every such path.
# 'callers' is a reversed callgraph (from callees back to callers)
# Prints paths in reverse order (starting function first, root last) because that
# helps identify the common paths to the the starting function f
#
# Usage is to iterate over all canaries 'f' searching for paths that should not exist
def checkCanaries(callers, isChunk, roots, f, path):
    if f in path: # ignore recursion
        pass
    elif f in roots:
        path = [ g for g in path+[f] if not isChunk(g) ]
        print("  Canary "+" ".join(path))
    elif callers[f]:
        path = path + [f]
        for g in callers[f]:
            checkCanaries(callers, isChunk, roots, g, path)

########################################################################
# Main
########################################################################

def main():
    global alt_slice_syntax
    global include_regex
    global exclude_regex
    global demangle_instr

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verbose', '-v', help='Use verbose output',
                        action = 'count', default=0)
    parser.add_argument('--altslicesyntax', help='Convert to alternative slice syntax',
                        action='store_true', default=False)
    parser.add_argument('--sail_asts', help='Output Sail file for AST clauses',
                        metavar='FILE', default=None)
    parser.add_argument('--demangle', help='Demangle instruction ASL',
                        action='store_true', default=False)
    parser.add_argument('--output', '-o', help='Basename for output files',
                        metavar='FILE', default='arch')
    parser.add_argument('dir', metavar='<dir>',  nargs='+',
                        help='input directories')
    parser.add_argument('--filter',  help='Optional input json file to filter definitions',
                        metavar='FILE', default=[], nargs='*')
    parser.add_argument('--arch', help='Optional list of architecture states to extract',
                        choices=["AArch32", "AArch64"], default=[], action='append')
    parser.add_argument('--include', help='Regex to select instructions by name',
                        metavar='REGEX', default=None)
    parser.add_argument('--exclude', help='Regex to exclude instructions by name',
                        metavar='REGEX', default=None)
    args = parser.parse_args()

    alt_slice_syntax = args.altslicesyntax
    if args.include is not None:
        include_regex = re.compile(args.include)
    if args.exclude is not None:
        exclude_regex = re.compile(args.exclude)
    demangle_instr   = args.demangle

    encodings = []
    if "AArch32" in args.arch: encodings.extend(["T16", "T32", "A32"])
    if "AArch64" in args.arch: encodings.extend(["A64"])
    if args.verbose > 0:
        if encodings != []:
            print("Selecting encodings", ", ".join(encodings))
        else:
            print("Selecting entire architecture")

    notice = readNotice(ET.parse(os.path.join(args.dir[0], 'notice.xml')))
    (shared,names) = readShared([ f for d in args.dir for f in glob.glob(os.path.join(d, 'shared_pseudocode.xml'))])

    # reverse mapping of names back to the chunks containing them
    chunks = {}
    for a in shared.values():
        for d in a.defs:
            chunks[d] = a

    for a in shared.values():
        a.patchDependencies(chunks)

    decoder_files = [ 'encodingindex.xml', 't32_encindex.xml', 'a32_encindex.xml' ]
    decoders = [ readDecodeFile(d, f) for df in decoder_files for d in args.dir for f in glob.glob(os.path.join(d, df)) ]

    sailhack = args.sail_asts is not None
    instrs = []
    tops   = set()
    for d in args.dir:
        for inf in glob.glob(os.path.join(d, '*.xml')):
            name = re.search('.*/(\S+).xml',inf).group(1)
            if name == "onebigfile": continue
            xml = ET.parse(inf)
            (instr, top) = readInstruction(xml,chunks,sailhack)
            if top: tops.add(top)
            if instr is None: continue

            if encodings != []: # discard encodings from unwanted InsnSets
                encs = [ e for e in instr.encs if e[1] in encodings ]
                if encs == []:
                    if args.verbose > 1: print("Discarding", instr.name, encodings)
                    continue
                instr.encs = encs

            instrs.append(instr)

    # Having read everything in, decide which parts to write
    # back out again and in what order

    if args.verbose > 3:
        for f in shared.values():
            print("Dependencies", f.name, "=", str(f.deps))
            print("Definitions", f.name, "=", str(f.defs))

    roots    = set()
    cuts     = set()
    canaries = set()
    for fn in args.filter:
        with open(fn, "r") as f:
            try:
                filter = json.load(f)
            except ValueError as err:
                print(err)
                sys.exit(1)
            for fun in filter['roots']:
                if fun not in chunks: print("Warning: unknown root", fun)
                roots.add(fun)
            for fun in filter['cuts']:
                if fun not in chunks: print("Warning: unknown cut", fun)
                cuts.add(fun)
            for fun in filter['canaries']:
                if fun not in chunks: print("Warning: unknown canary", fun)
                canaries.add(fun)

            # treat instrs as a list of rexexps
            patterns = [ re.compile(p) for p in filter['instructions'] ]
            instrs = [ i for i in instrs
                         if any(regex.match(i.name) for regex in patterns)
                     ]
            # print("\n".join(sorted([ i.name for i in instrs ])))
    # print("\n".join(sorted(chunks.keys())))

    # Replace all cutpoints with a stub so that we keep dependencies
    # on the argument/result types but drop the definition and any
    # dependencies on the definition.
    for x,s in shared.items():
        if any([d in cuts for d in s.defs]):
            if args.verbose > 0: print("Cutting", x)
            t = s.toPrototype()
            t.patchDependencies(chunks)
            # print("Cut", t)
            shared[x] = t

    # build bipartite graph consisting of chunk names and functions
    deps = defaultdict(set) # dependencies between functions
    for a in shared.values():
        deps[a.name] = a.deps
        for d in a.defs:
            deps[d] = {a.name}

    if args.verbose > 2:
        for f in deps: print("Dependency", f, "on", str(deps[f]))


    if encodings == [] and args.filter == []:
        # default: you get everything
        if args.verbose > 0: print("Keeping entire specification")
        roots |= { x for x in shared }
    else:
        if args.verbose > 0: print("Discarding definitions unreachable from",
                               ", ".join(encodings), " instructions")
        for i in instrs:
            for (_,_,_,dec) in i.encs: roots |= dec.deps
            if i.post: roots |= i.post.deps
            roots |= i.exec.deps
    (live, _) = reachable(deps, roots)

    # Check whether canaries can be reached from roots
    if canaries != set():
        if args.verbose > 0: print("Checking unreachability of", ", ".join(canaries))
        rcg = defaultdict(set) # reverse callgraph
        for f, ds in deps.items():
            for d in ds:
                rcg[d].add(f)
        for canary in canaries:
            if canary in live:
                checkCanaries(rcg, lambda x: x in shared, roots, canary, [])

    # print("Live:", " ".join(live))
    # print()
    # print("Shared", " ".join(shared.keys()))

    live_chunks = [ shared[x] for x in live if x in shared ]

    tagfile    = args.output + ".tag"
    instrfile  = args.output + "_instrs.asl"
    decodefile = args.output + "_decode.asl"
    aslfile    = args.output + ".asl"

    if args.verbose > 0: print("Writing instruction encodings to", tagfile)
    with open(tagfile, "w") as outf:
        emit(outf, 'notice:asl', notice)
        for i in instrs:
            i.emit_tag_syntax(outf)

    if args.verbose > 0: print("Writing instructions to", instrfile)
    with open(instrfile, "w") as outf:
        print(notice, file=outf)
        print(file=outf)
        for i in instrs:
            i.emit_asl_syntax(outf)
            print(file=outf)
        print('/'*72, file=outf)
        print('// End', file=outf)
        print('/'*72, file=outf)

    if args.verbose > 0: print("Writing instruction decoder to", decodefile)
    with open(decodefile, "w") as ofile:
        for (groups, classes) in decoders: printDecodeTree(ofile, groups, classes)

    if args.verbose > 0: print("Writing ASL definitions to", aslfile)
    with open(aslfile, "w") as outf:
        print(notice, file=outf)
        print(file=outf)
        print('\n'.join([ t for t in tops ]), file=outf)
        print('\n'.join([ x.code for x in live_chunks ]), file=outf)
        print('/'*72, file=outf)
        print('// End', file=outf)
        print('/'*72, file=outf)

    if args.sail_asts is not None:
        if args.verbose > 0: print("Writing Sail ast clauses to", args.sail_asts)
        with open(args.sail_asts, "w") as outf:
            print(notice, file=outf, end='\n\n')
            print('scattered union ast', file=outf, end='\n\n')
            previous_clauses = set()
            for i in instrs:
                i.emit_sail_ast(previous_clauses, outf)
            print('\nend ast', file=outf)

    return

if __name__ == "__main__":
    sys.exit(main())

########################################################################
# End
########################################################################
