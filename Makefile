.PHONY: default
default: all

VERSION = v85A-2019-06
XMLDIR  = v8.5

A64    = ${XMLDIR}/ISA_A64_xml_${VERSION}
A32    = ${XMLDIR}/ISA_AArch32_xml_${VERSION}
SYSREG = ${XMLDIR}/SysReg_xml_${VERSION}


FILTER =
# FILTER = --filter=usermode.json

regs.asl: ${SYSREG}
	bin/reg2asl.py $< -o $@

arch.asl arch.tag arch_instrs.asl arch_decode.asl: ${A32} ${A64}
	bin/instrs2asl.py --altslicesyntax --demangle --verbose $^ ${FILTER}

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
	$(RM) regs.asl arch.asl arch.tag arch_instrs.asl arch_decode.asl


clean ::
	$(MAKE) -C src clean


# End
