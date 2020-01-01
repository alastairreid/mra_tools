.PHONY: default
default: all

VERSION = v86A-2019-12
XMLDIR  = v8.6

A64    = ${XMLDIR}/ISA_A64_xml_${VERSION}
A32    = ${XMLDIR}/ISA_AArch32_xml_${VERSION}
SYSREG = ${XMLDIR}/SysReg_xml_${VERSION}


FILTER =
# FILTER = --filter=usermode.json

arch/regs.asl: ${SYSREG}
	mkdir -p arch
	bin/reg2asl.py $< -o $@

arch/arch.asl arch/arch.tag arch/arch_instrs.asl arch/arch_decode.asl: ${A32} ${A64}
	mkdir -p arch
	bin/instrs2asl.py --altslicesyntax --demangle --verbose -oarch/arch $^ ${FILTER}
	patch -Np0 < arch.patch

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

all :: arch/regs.asl
all :: arch/arch.asl

clean ::
	$(RM) -r arch

# Assumes that patched/* contains a manually fixed version of arch/*
arch.patch ::
	diff -Naur arch patched

# End
