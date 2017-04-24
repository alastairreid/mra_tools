#!/usr/bin/env python3

'''
Unpack ARM instruction XML files extracting the encoding information
and ASL code within it.
'''

import argparse, glob, os, re, sys
import xml.etree.cElementTree as ET

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verbose', '-v', help='Use verbose output',
                        action = 'store_true')
    parser.add_argument('--output',  '-o', help='File to store tag output',
                        metavar='FILE', default='output')
    parser.add_argument('dir', metavar='<dir>',  nargs='+',
                        help='input directory')
    args = parser.parse_args()

    with open(args.output, "w") as outf:

        # Read proprietary notice
        notice = ['/'*72, "// Proprietary Notice"]
        xml = ET.parse(os.path.join(args.dir[0], 'notice.xml'))
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
        emit(outf, 'notice:asl', "\n".join(notice))

        for d in args.dir:
            for inf in glob.glob(os.path.join(d, '*.xml')):
                name = re.search('.*/(\S+).xml',inf).group(1)
                if name == "onebigfile": continue
                exec_tag = name+':execute'
                post_tag = name+':postdecode'
                idx_tag  = name+':index'
                xml = ET.parse(inf)
                execs = xml.findall(".//pstext[@section='Execute']")
                posts = xml.findall(".//pstext[@section='Postdecode']")
                assert(len(posts) <= 1)
                assert(len(execs) <= 1)
                if not execs: continue

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
                                print("Merged", nm)
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

tags = set()
def emit(f, tag, content):
    if tag not in tags: # suppress duplicate entries
        tags.add(tag)
        print('TAG:'+tag, file=f)
        print(content, file=f)

if __name__ == "__main__":
    sys.exit(main())
