.PHONY: default
default: all

VERSION = 00bet3.2
XMLDIR = v8.2

regs.asl: ${XMLDIR}/SysReg_v82A_xml-${VERSION}
	bin/reg2asl.py $< -o $@

arch.asl arch.tag: ${XMLDIR}/ISA_v82A_AArch32_xml_${VERSION} ${XMLDIR}/ISA_v82A_A64_xml_${VERSION}
	bin/instrs2asl.py $^

all :: regs.asl
all :: arch.asl

clean ::
	$(RM) regs.asl arch.asl arch.tag
