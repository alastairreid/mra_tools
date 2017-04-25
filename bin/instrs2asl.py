#!/usr/bin/env python3

'''
Unpack ARM instruction XML files extracting the encoding information
and ASL code within it.
'''

import argparse, glob, os, re, sys
import xml.etree.cElementTree as ET

tags = set()
'''
Write content to a 'tag file' suppressing duplicate information
'''
def emit(f, tag, content):
    if tag not in tags: # suppress duplicate entries
        tags.add(tag)
        print('TAG:'+tag, file=f)
        print(content, file=f)

'''
Read shared pseudocode files to extract ASL.
Result is sorted so that uses come before definitions.
'''
def readShared(files):
    asl = {}
    defns = {}
    for f in files:
        xml = ET.parse(f)
        for ps in xml.findall('.//ps_section/ps'):
            name = ps.attrib["name"]
            chunk = ps.find("pstext")
            for x in chunk.findall('anchor'):
                defns[x.attrib['link']] = name
            links = [ x.attrib['link'] for x in chunk.findall('a') ]
            asl[name] = (ET.tostring(chunk, method="text").decode().rstrip()+"\n", links)

    # add missing dependencies
    # these are mostly due to function prototypes not having links
    # on any types they mention
    asl['aarch32/functions/ras/AArch32.PhysicalSErrorSyndrome'][1].append('AArch32.SErrorSyndrome')

    # perform topological sort on definitions
    sorted = []
    seen = set()

    def visit(xs):
        nonlocal seen
        for x in xs:
            if x not in seen:
                seen = seen | {x}
                if x in asl:
                    deps = [ defns[y] for y in asl[x][1] ]
                    # print(x,deps)
                    visit(deps)
                    sorted.append(x)
        return
    visit(asl.keys())
    # print("\n".join(sorted))
    return [ asl[x][0] for x in sorted ]

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
        para = para.replace("&#8217;", '"')
        para = para.replace("&#8220;", '"')
        para = para.replace("&#8221;", '"')
        para = para.replace("&#8482;", '(TM)')
        para = para.replace("&#169;", '(C)')
        para = para.replace("&#174;", '(R)')
        lines = [ '// '+l for l in para.split('\n') ]
        notice.extend(lines)
    notice.append('/'*72)
    return '\n'.join(notice)

def readInstruction(inf, outf, name):
    exec_tag = name+':execute'
    post_tag = name+':postdecode'
    idx_tag  = name+':index'
    xml = ET.parse(inf)
    execs = xml.findall(".//pstext[@section='Execute']")
    posts = xml.findall(".//pstext[@section='Postdecode']")
    assert(len(posts) <= 1)
    assert(len(execs) <= 1)
    if not execs: return

    index = [] # index of sections of this instruction

    # emit ASL for execute and (optional) postdecode sections
    emit(outf, exec_tag, ET.tostring(execs[0], method="text").decode().rstrip())
    index.append('Execute: '+exec_tag)
    if posts:
        emit(outf, post_tag, ET.tostring(posts[0], method="text").decode().rstrip())
        index.append('Postdecode: '+post_tag)

    # for each encoding, emit instructions encoding, matching decode ASL and index
    for iclass in xml.findall('.//classes/iclass'):
        inm = name+"_"+iclass.attrib['name']
        # emit decode ASL
        dec_tag  = inm + ':decode'
        dec_asl = ET.tostring(iclass.find('ps_section/ps/pstext'), method="text").decode().rstrip()
        # Normalise SEE statements (AArch32 version omits quotes)
        dec_asl = re.sub(r'SEE\s+([^"][^;]*);', r'SEE "\1";', dec_asl)
        emit(outf, dec_tag, dec_asl)

        # emit instructions encoding
        encoding = iclass.find('regdiagram')
        enc_tag  = inm + ':diagram'
        isT16 = encoding.attrib['form'] == "16"
        fs = []
        for b in encoding.findall('box'):
            wd = int(b.attrib.get('width','1'))
            hi = int(b.attrib['hibit'])
            # normalise T16 encoding bit numbers
            if isT16: hi = hi-16
            lo = hi - wd + 1
            nm  = b.attrib.get('name', '_')
            consts = ''.join([ c.text for c in b.findall('c') if c.text is not None ])

            # normalise constants: note that it discards != information
            # because it is better obtained elsewhere in spec
            if consts == "" or consts.startswith('!='):
                consts = 'x'*wd
            elif nm in ["SP", "mask"]:
                # avoid use of overloaded field name
                nm = '_'

            # if adjacent entries are two parts of same field, join them
            # e.g., imm8<7:1> and imm8<0>
            m = re.match('^(\w+)<', nm)
            if m:
                nm = m.group(1)
                split = True
                if fs[-1][3] and fs[-1][2] == nm:
                    (hi1,lo1,_,_,c1) = fs.pop()
                    assert(lo1 == hi+1) # must be adjacent
                    hi = hi1
                    consts = c1+consts
            else:
                split = False

            fs.append((hi,lo,nm,split,consts))
        enc = ["T16" if isT16 else iclass.attrib['isa']]
        enc.extend([str(hi)+":"+str(lo)+" "+nm+" "+consts
                    for (hi,lo,nm,_,consts) in fs ])
        emit(outf, enc_tag, "\n".join(enc))

        index.append('Decode: '+dec_tag+'@'+enc_tag)

    # emit index for this encoding
    emit(outf, idx_tag, "\n".join(index))

    return


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verbose', '-v', help='Use verbose output',
                        action = 'store_true')
    parser.add_argument('--tag',  help='Output tag file for instructions',
                        metavar='FILE', default='arch.tag')
    parser.add_argument('--asl',  help='Output asl file for support code',
                        metavar='FILE', default='arch.asl')
    parser.add_argument('dir', metavar='<dir>',  nargs='+',
                        help='input directories')
    parser.add_argument('--slice',  help='Optional input json file to filter definitions',
                        metavar='FILE', default='isa.json')
    args = parser.parse_args()

    notice = readNotice(ET.parse(os.path.join(args.dir[0], 'notice.xml')))
    shared = readShared([ f for d in args.dir for f in glob.glob(os.path.join(d, 'shared_pseudocode.xml'))])

    with open(args.tag, "w") as outf:
        emit(outf, 'notice:asl', notice)
        for d in args.dir:
            for inf in glob.glob(os.path.join(d, '*.xml')):
                name = re.search('.*/(\S+).xml',inf).group(1)
                if name == "onebigfile": continue
                readInstruction(inf, outf, name)

    with open(args.asl, "w") as outf:
        print(notice, file=outf)
        print(file=outf)
        print('\n'.join(shared), file=outf)
        print('/'*72, file=outf)
        print('// End', file=outf)
        print('/'*72, file=outf)

    return


if __name__ == "__main__":
    sys.exit(main())
