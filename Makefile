.default: all

regs.asl: SysReg_v82A_xml-00bet3.1
	bin/reg2asl.py $< -o $@

arch.asl arch.tag: ISA_v82A_AArch32_xml_00bet3.1 ISA_v82A_A64_xml_00bet3.1
	bin/instrs2asl.py $^

all :: regs.asl arch.asl arch.tag

clean ::
	$(RM) regs.asl arch.asl arch.tag
