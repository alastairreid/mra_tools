#!/usr/bin/env python3

'''
Unpack ARM shared XML files extracting the ASL code within it.
'''

import argparse, os, re, sys
import xml.etree.cElementTree as ET

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verbose', '-v', help='Use verbose output',
                        action = 'store_true')
    parser.add_argument('--output',  '-o', help='File to store tag output',
                        metavar='FILE', default='output')
    parser.add_argument('xml', metavar='<xml>',  nargs='+',
                        help='input files')
    args = parser.parse_args()

    asl = {}
    defns = {}
    for f in args.xml:
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
    # producing list in reverse order
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

    # Read proprietary notice
    notice = ["Proprietary Notice"]
    xml = ET.parse(os.path.join(os.path.dirname(args.xml[0]), 'notice.xml'))
    for p in xml.iter('para'):
        para = ET.tostring(p, method='text').decode().rstrip()
        para = para.replace("&#8217;", '"')
        para = para.replace("&#8220;", '"')
        para = para.replace("&#8221;", '"')
        para = para.replace("&#8482;", '(TM)')
        para = para.replace("&#169;", '(C)')
        para = para.replace("&#174;", '(R)')
        lines = para.split('\n')
        notice.extend(lines)

    with open(args.output, "w") as f:
        print('/'*72, file=f)
        for p in notice:
            print('// '+p, file=f)
        print('/'*72, file=f)
        print(file=f)
        for x in sorted:
            print("%s" % asl[x][0], file=f)
    return


if __name__ == "__main__":
    sys.exit(main())
