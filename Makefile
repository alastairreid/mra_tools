.PHONY: default
default: all

VERSION = 00bet6
XMLDIR = v8.3

A64 = ${XMLDIR}/ISA_v83A_A64_xml_$(VERSION).1
A32 = ${XMLDIR}/ISA_v83A_AArch32_xml_$(VERSION).1
SYSREG = ${XMLDIR}/SysReg_v83A_xml-$(VERSION)

FILTER =
# FILTER = --filter=usermode.json

regs.asl: ${SYSREG}
	bin/reg2asl.py $< -o $@

arch.asl arch.tag: ${A32} ${A64}
	bin/instrs2asl.py --altslicesyntax $^ ${FILTER}

src/test_parser.byte:
	make -C src test_parser.byte

test: arch.asl regs.asl src/test_parser.byte
	cat prelude.asl regs.asl arch.asl | src/test_parser.byte

all :: regs.asl
all :: arch.asl

clean ::
	$(RM) regs.asl arch.asl arch.tag


clean ::
	$(MAKE) -C src clean


# End
