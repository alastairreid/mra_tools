.default: all

regs.asl: v8.2/sysreg/SysReg_v82A_xml-00bet3.1
	bin/reg2asl.py $< -o $@

shared.asl: v8.2/isa64/ISA_v82A_A64_xml_00bet3.1/shared_pseudocode.xml
	bin/shared2asl.py $< -o $@

instrs64.tag: v8.2/isa64/ISA_v82A_A64_xml_00bet3.1
	bin/instrs2asl.py $< -o $@

instrs32.tag: v8.2/isa32/ISA_v82A_AArch32_xml_00bet3.1
	bin/instrs2asl.py $< -o $@

all :: regs.asl shared.asl

clean ::
	$(RM) regs.asl shared.asl
