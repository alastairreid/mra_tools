# mra_tools

Tools to process ARM's Machine Readable Architecture Specification.

These tools unpack the ASL spec from inside the XML.

## Usage

The following commands will download ARM's specification and unpack it.

    wget https://developer.arm.com/-/media/developer/products/architecture/armv8-a-architecture/ARMv82A-SysReg-00bet3.1.tar.gz
    wget https://developer.arm.com/-/media/developer/products/architecture/armv8-a-architecture/A64_v82A_ISA_xml_00bet3.1.tar.gz
    wget https://developer.arm.com/-/media/developer/products/architecture/armv8-a-architecture/AArch32_v82A_ISA_xml_00bet3.1.tar.gz

    tar zxf ARMv82A-SysReg-00bet3.1.tar.gz SysReg_v82A_xml-00bet3.1.tar.gz
    tar zxf SysReg_v82A_xml-00bet3.1.tar.gz SysReg_v82A_xml-00bet3.1
    tar zxf A64_v82A_ISA_xml_00bet3.1.tar.gz ISA_v82A_A64_xml_00bet3.1
    tar zxf AArch32_v82A_ISA_xml_00bet3.1.tar.gz ISA_v82A_AArch32_xml_00bet3.1

    python3 bin/reg2asl.py SysReg_v82A_xml-00bet3.1 -o regs.asl
    python3 bin/instrs2asl.py ISA_v82A_AArch32_xml_00bet3.1 ISA_v82A_A64_xml_00bet3.1

Generates:

- arch.asl: all the ASL support code
- arch.tag: all the instruction encodings and decode/execute ASL
- regs.asl: type of each system register

Various subsets of the architecture can be generated using these additional flags

    --arch=AArch32
    --arch=AArch64
    --arch=AArch32 --arch=AArch64

## Help

    $ bin/instrs2asl.py  -h
    usage: instrs2asl.py [-h] [--verbose] [--tag FILE] [--asl FILE]
			 [--arch {AArch32,AArch64}]
			 <dir> [<dir> ...]

    Unpack ARM instruction XML files extracting the encoding information and ASL
    code within it.

    positional arguments:
      <dir>                 input directories

    optional arguments:
      -h, --help            show this help message and exit
      --verbose, -v         Use verbose output
      --tag FILE            Output tag file for instructions
      --asl FILE            Output asl file for support code
      --arch {AArch32,AArch64}
			    Optional list of architecture states to extract


## Currently implemented

- Unpack all the ASL code in the 'shared_pseudocode' file to giant ASL file
- Unpack instructions to 'tagfile' format
- Quick and dirty unpack of system register spec to ASL file

All generated files include ARM's license notice.


## Shared pseudocode

The shared pseudocode is sorted so that definitions come before uses.


## Tagfile format for functions

A tagfile consists of sections that start with a line of the form "TAG:$label:$kind".
There are five different kinds:

- diagram:
    Instruction encoding consisting of:
    - An initial line that specifies the encoding: A64, A32, T32 or T16
    - Field specifiers of the form "hi:lo name constants" where the name
      "_" is used for anonymous fields and the each constant is of the form:
        - 0 or 1
        - x meaning don't care
        - (0) or (1) meaning 'should be 0/1' (UNPREDICTABLE if not)

    For example:

        T32
        31:25 _ 1110101
        24:21 op1 1000
        20:20 S x
        19:16 Rn 1101
        15:15 _ (0)
        14:12 imm3 xxx
        11:8 Rd xxxx
        7:6 imm2 xx
        5:4 type xx
        3:0 Rm xxxx

- decode:
    ASL code to decode an instruction encoding

- postdecode:
    Additional code to continue decoding an instruction encoding

- execute:
    ASL code to execute after postdecode

- index:
    Identifies the different parts of an instruction encoding and consists
    of:
    - Decode: [tag of decode section]@[tag of diagram section]
    - Postdecode: optional [tag of postdecode section]
    - Execute: [tag of execute section]

    There can be multiple Decode lines all sharing the same postdecode and
    execute parts.

- asl:
    ASL definitions (e.g., function definitions)


## Register spec

At the moment, we unpack all the information about fields and declare a
variable with the right name and with named fields.  This uses an
unofficial ASL extension to declare a number the location of each field.

    __register 32 {
        31:31 N, 30:30 Z, 29:29 C, 28:28 V, 27:27 Q, 24:24 J, 22:22 PAN, 19:16 GE,
        9:9 E, 8:8 A, 7:7 I, 6:6 F, 5:5 T, 7:2, 1:0 IT, 3:0 M
    } CPSR;

The system register specification also contains a lot of information about
how to refer to a system register, permission checking, constant value fields,
etc. but none of that is being extracted at the moment.
