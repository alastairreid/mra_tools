.PHONY: default
default: all

VERSION = v86A-2019-12
XMLDIR  = v8.6

A64    = ${XMLDIR}/ISA_A64_xml_${VERSION}
A32    = ${XMLDIR}/ISA_AArch32_xml_${VERSION}
SYSREG = ${XMLDIR}/SysReg_xml_${VERSION}


FILTER =
# FILTER = --filter=usermode.json

regs.asl: ${SYSREG}
	bin/reg2asl.py $< -o $@

arch.asl arch.tag arch_instrs.asl arch_decode.asl: ${A32} ${A64}
	bin/instrs2asl.py --altslicesyntax --demangle --verbose -ounpatched $^ ${FILTER}

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

all :: regs.asl
all :: arch.asl

clean ::
	$(RM) regs.asl arch.asl arch.tag arch_instrs.asl arch_decode.asl

# End
