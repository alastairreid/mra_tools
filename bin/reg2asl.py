#!/usr/bin/env python3

'''
Unpack ARM System Register XML files creating ASL type definitions.
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

    # read all the registers
    regs = {}
    for d in args.dir:
        for f in glob.glob(os.path.join(d, '*.xml')):
            xml = ET.parse(f)
            for r in xml.iter('register'):
                if r.attrib['is_register'] == 'True':
                    long = r.find('reg_long_name').text
                    name = r.find('reg_short_name').text
                    bounds = None
                    if r.find('reg_array'):
                        lo = r.find('reg_array/reg_array_start').text
                        hi = r.find('reg_array/reg_array_end').text
                        bounds = (lo,hi)
                        name = name.replace("<n>","")
                    # there can be multiple views of a register each either 32 or 64 bits
                    # so take the longest.  (Required for TTBR0/1)
                    length = max([int(l.attrib['length']) for l in r.findall('reg_fieldsets/fields') ])
                    fields = {}
                    slices = {}
                    for f in r.findall('reg_fieldsets/fields/field'):
                        if f.find('field_name') is not None:
                            nm = f.find('field_name').text
                            slice = None
                            m1 = re.match('^(\w+)\[(\d+)\]$', nm)
                            m2 = re.match('^(\w+)\[(\d+):(\d+)\]$', nm)
                            if m1:
                                nm = m1.group(1)
                                hi = m1.group(2)
                                slice = (hi,hi)
                            elif m2:
                                nm = m2.group(1)
                                hi = m2.group(2)
                                lo = m2.group(3)
                                slice = (hi,lo)
                            msb = f.find('field_msb').text
                            lsb = f.find('field_lsb').text
                            isident = (re.match('^[a-zA-Z_]\w*$', nm)
                                       and nm != "UNKNOWN")
                            if slice:
                                if nm not in slices: slices[nm] = []
                                slices[nm].append((msb,lsb,slice))
                            elif isident:
                                fields[nm] = [(msb,lsb)]
                            else:
                                # print(name,nm)
                                pass
                    for f in slices.keys():
                        ss = slices[f]
                        ss.sort(key=lambda s: int(s[2][0]))
                        ss = [ slice for (msb,lsb,slice) in reversed(ss) ]
                        fields[f] = ss

                    if re.match('^[a-zA-Z_]\w*$', name):
                        # merge any new fields in (mostly to handle external views of regs)
                        if name in regs:
                            for f,ss in regs[name][2].items():
                                if f not in fields:
                                    fields[f] = ss
                        regs[name] = (long, length, fields, bounds)

    # Read proprietary notice
    notice = ["Proprietary Notice"]
    xml = ET.parse(os.path.join(args.dir[0], 'notice.xml'))
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

    # Generate file of definitions
    with open(args.output, "w") as f:
        print('/'*72, file=f)
        for p in notice:
            print('// '+p, file=f)
        print('/'*72, file=f)
        print(file=f)
        for name in regs.keys():
            (long, length, fields, bounds) = regs[name]
            fs = ", ".join([ ", ".join([msb+":"+lsb for (msb,lsb) in ss]) +" "+nm
                             for nm, ss in fields.items() ])
            type = "__register "+str(length)+" { "+fs+" }"
            if bounds:
                type = 'array ['+bounds[0]+".."+bounds[1]+'] of '+type
            prefix = "// " if long == 'IMPLEMENTATION DEFINED registers' else ""
            print("//", long, file=f)
            print(prefix+type+' '+name+";", file=f)
            print(file=f)
    return


if __name__ == "__main__":
    sys.exit(main())
