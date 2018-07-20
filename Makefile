.PHONY: default
default: all

VERSION = 00bet7
XMLDIR = v8.4

A64 = ${XMLDIR}/ISA_v84A_A64_xml_$(VERSION)
A32 = ${XMLDIR}/ISA_v84A_AArch32_xml_$(VERSION)
SYSREG = ${XMLDIR}/SysReg_v84A_xml-$(VERSION)

FILTER =
# FILTER = --filter=usermode.json

regs.asl: ${SYSREG}
	bin/reg2asl.py $< -o $@

arch.asl arch.tag: ${A32} ${A64}
	bin/instrs2asl.py --altslicesyntax $^ ${FILTER}

src/test_parser.byte:
	make -C src test_parser.byte

ASL += prelude.asl
ASL += regs.asl
ASL += arch.asl
ASL += support/aes.asl
ASL += support/barriers.asl
ASL += support/debug.asl
ASL += support/feature.asl
ASL += support/interrupts.asl
ASL += support/memory.asl
ASL += support/fetchdecode.asl
ASL += support/stubs.asl
ASL += support/usermode.asl

test: src/test_parser.byte $(ASL)
	cat $(ASL) | src/test_parser.byte

all :: regs.asl
all :: arch.asl

clean ::
	$(RM) regs.asl arch.asl arch.tag


clean ::
	$(MAKE) -C src clean


# End
