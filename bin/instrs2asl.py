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
import sys
import xml.etree.cElementTree as ET
from collections import defaultdict

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


class Instruction:
    '''Representation of Instructions'''

    def __init__(self, name, encs, post, exec):
        self.name = name
        self.encs = encs
        self.post = post
        self.exec = exec

    def emit(self, file):
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

    def __str__(self):
        encs = "["+ ", ".join([inm for (inm,_,_,_) in self.encs]) +"]"
        return "Instruction{" + ", ".join([encs, (self.post.name if self.post else "-"), self.exec.name])+"}"


########################################################################
# Extracting information from XML files
########################################################################

alt_slice_syntax = False

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
    reIndex = r'[0-9a-zA-Z_+*\-()[\]., ]+'
    rePart = reIndex+"(:"+reIndex+")?"
    reParts = rePart+"(,"+rePart+")*"
    x = re.sub("<("+reParts+")>", r'[\1]',x)
    x = re.sub("<("+reParts+")>", r'[\1]',x)
    return x


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

def readInstruction(xml,names):
    execs = xml.findall(".//pstext[@section='Execute']/..")
    posts = xml.findall(".//pstext[@section='Postdecode']/..")
    assert(len(posts) <= 1)
    assert(len(execs) <= 1)
    if not execs: return None # discard aliases

    exec = readASL(execs[0])
    post = readASL(posts[0]) if posts else None

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
            # normalise T16 encoding bit numbers
            if isT16: hi = hi-16
            lo = hi - wd + 1
            nm  = b.attrib.get('name', '_')
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
        dec_asl.patchDependencies(names)

        name = dec_asl.name if insn_set in ["T16","T32","A32"] else encoding.attrib['psname']
        encs.append((name, insn_set, fields2, dec_asl))

    return Instruction(exec.name, encs, post, exec)

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

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verbose', '-v', help='Use verbose output',
                        action = 'count', default=0)
    parser.add_argument('--altslicesyntax', help='Convert to alternative slice syntax',
                        action='store_true', default=False)
    parser.add_argument('--tag',  help='Output tag file for instructions',
                        metavar='FILE', default='arch.tag')
    parser.add_argument('--asl',  help='Output asl file for support code',
                        metavar='FILE', default='arch.asl')
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

    instrs = []
    for d in args.dir:
        for inf in glob.glob(os.path.join(d, '*.xml')):
            name = re.search('.*/(\S+).xml',inf).group(1)
            if name == "onebigfile": continue
            xml = ET.parse(inf)
            instr = readInstruction(xml,chunks)
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
    if canaries != []:
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

    if args.verbose > 0: print("Writing instruction encodings to", args.tag)
    with open(args.tag, "w") as outf:
        emit(outf, 'notice:asl', notice)
        for i in instrs:
            i.emit(outf)

    if args.verbose > 0: print("Writing ASL definitions to", args.asl)
    with open(args.asl, "w") as outf:
        print(notice, file=outf)
        print(file=outf)
        print('\n'.join([ x.code for x in live_chunks ]), file=outf)
        print('/'*72, file=outf)
        print('// End', file=outf)
        print('/'*72, file=outf)

    return

if __name__ == "__main__":
    sys.exit(main())

########################################################################
# End
########################################################################
