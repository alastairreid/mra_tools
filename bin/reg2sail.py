#!/usr/bin/env python3

'''
Parse ARM System Register XML files and create Sail mapping clauses for disassembling MRS/MSR
'''

import argparse
import os
import math
import re
import sys
import xml.etree.cElementTree as ET

def isbinary(s):
    return all(c in '01' for c in s)

def get_value(binary_n, enc):
    v = enc.get('v')
    if v is not None:
        return v
    else:
        width = int(enc.get('width'))
        varname = enc.get('varname')
        if varname is not None:
            assert varname == 'n'
            return binary_n[-width:]
        else:
            # have to explode value to a list, strings can't do slice assignment
            value = ['x'] * width
            for encbits in enc.findall('encbits'):
                # lsb on the right
                msb = - int(encbits.get('msb')) - 1
                lsb = - int(encbits.get('lsb'))
                if lsb == 0:
                    lsb = width
                assert lsb > msb
                v = encbits.get('v')
                if v is not None:
                    value[msb:lsb] = [c for c in v]
                else:
                    encvars = encbits.findall('encvar')
                    assert len(encvars) == 1
                    encvar = encvars[0]
                    assert encvar.get('name') == 'n'
                    var_msb = - int(encvar.get('msb')) - 1
                    var_lsb = - int(encvar.get('lsb'))
                    if var_lsb == 0:
                        var_lsb = len(binary_n)
                    assert var_lsb > var_msb
                    value[msb:lsb] = binary_n[var_msb:var_lsb]
            # make an actual string again
            value = ''.join(value)
            assert 'x' not in value
            return value

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verbose', '-v', help='Use verbose output',
                        action = 'store_true')
    parser.add_argument('--output',  '-o', help='File to store tag output',
                        metavar='FILE', default='asm_sysregs.sail')
    parser.add_argument('files', metavar='<file>',  nargs='+',
                        help='input XML files')
    args = parser.parse_args()

    # read all the registers
    regs = {}
    for f in args.files:
        xml = ET.parse(f)
        for r in xml.findall('.//register'):
            if r.get('is_register') != 'True':
                continue
            # these values should never actually get used if we're not an array
            # but in that case, we still want an ns of length 1
            # and an arbitrary n_bits value which will never get used
            ns = [999]
            n_bits = 1
            if r.find('./reg_array'):
                lo = int(r.find('./reg_array/reg_array_start').text)
                hi = int(r.find('./reg_array/reg_array_end').text)
                ns = list(range(lo, hi + 1))
                # we assume that the bitwidth of <n> is the smallest that contains its largest possible value
                n_bits = int(math.ceil(math.log2(hi)))
            for n in ns:
                binary_n = '{:0{}b}'.format(n, n_bits)
                for d in r.findall('.//access_instructions/defvar/def[@asmname="systemreg"]'):
                    # we assume that register arrays always use <n> as their metavar.
                    name = d.get('asmvalue').replace('<n>', str(n))
                    op0 = get_value(binary_n, d.find('enc[@n="op0"]'))
                    op1 = get_value(binary_n, d.find('enc[@n="op1"]'))
                    CRn = get_value(binary_n, d.find('enc[@n="CRn"]'))
                    CRm = get_value(binary_n, d.find('enc[@n="CRm"]'))
                    op2 = get_value(binary_n, d.find('enc[@n="op2"]'))
                    # have to handle op0 specially: only last bit is actually encoded
                    # and there is an implied 1 bit so 2 and 3 are the possible values
                    # but there are varying numbers of leading zeroes in the register spec...
                    assert isbinary(op0) and int(op0, base=2) in (2, 3)
                    assert len(op1) == 3 and isbinary(op1)
                    assert len(CRn) == 4 and isbinary(CRn)
                    assert len(CRm) == 4 and isbinary(CRm)
                    assert len(op2) == 3 and isbinary(op2)
                    o0 = op0[-1]
                    encoding = o0 + op1 + CRn + CRm + op2
                    # there are some duplicates in the spec because of ELs etc... but check they're at least the same
                    assert name not in regs or regs[name] == encoding
                    regs[name] = encoding

    # Generate file of definitions
    with open(args.output, "w") as f:
        for name, encoding in sorted(list(regs.items()), key=lambda x: len(x[0]), reverse=True): # sort in reverse order of length to avoid prefix clashing
            print('mapping clause asm_sysreg = 0b{} <-> "{}"'.format(encoding, name), file=f)
    return


if __name__ == "__main__":
    sys.exit(main())
