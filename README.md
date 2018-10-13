# Tools to extract ARM's Machine Readable Architecture Specification.

These tools unpack the ASL spec from inside the XML so that the spec is
easy to process.

See [blog post](https://alastairreid.github.io/dissecting-ARM-MRA/) for an
explanation of the structure of ARM's releases and a description of the
innards of these tools and see [blog
post](https://alastairreid.github.io/ARM-v8a-xml-release/) for some ideas
on what can be done with the specification once it has been unpacked.


## Usage

The following commands will download ARM's specification and unpack it.

    mkdir -p v8.5
    cd v8.5

    wget https://developer.arm.com/-/media/developer/products/architecture/armv8-a-architecture/ARMv85A-SysReg-00bet8.tar.gz
    wget https://developer.arm.com/-/media/developer/products/architecture/armv8-a-architecture/A64_v85A_ISA_xml_00bet8.tar.gz
    wget https://developer.arm.com/-/media/developer/products/architecture/armv8-a-architecture/AArch32_v85A_ISA_xml_00bet8.tar.gz

    tar zxf A64_v85A_ISA_xml_00bet8.tar.gz
    tar zxf AArch32_v85A_ISA_xml_00bet8.tar.gz
    tar zxf ARMv85A-SysReg-00bet8.tar.gz

    tar zxf ISA_v85A_A64_xml_00bet8.tar.gz
    tar zxf ISA_v85A_AArch32_xml_00bet8.tar.gz

    cd ..

    make all

Generates:

- arch.asl: all the ASL support code
  (This file uses an alternative syntax for bitslices that is easier to parse.
  Remove the --altslicesyntax flag from the Makefile to get the original ASL.)
- arch.tag: all the instruction encodings and decode/execute ASL
- arch_instrs.tag: all the instruction encodings and decode/execute ASL
  (alternate format)
- arch_decode.tag: instruction decode trees in ASL
- regs.asl: type of each system register

You can also extract various subsets of the full architecture specification.
For example, if you want a subset of the usermode AArch64 instructions, you can
use the following command.

    make FILTER=--filter=usermode.json all

The subset selected may not contain all the instructions you would want --- see
[Subsetting](#subsetting) for more details.


## Help

    $ bin/instrs2asl.py  -h
    usage: instrs2asl.py [-h] [--verbose] [--altslicesyntax] [--demangle]
                         [--output FILE] [--filter [FILE [FILE ...]]]
                         [--arch {AArch32,AArch64}]
                         <dir> [<dir> ...]

    Unpack ARM instruction XML files extracting the encoding information and ASL
    code within it.

    positional arguments:
      <dir>                 input directories

    optional arguments:
      -h, --help            show this help message and exit
      --verbose, -v         Use verbose output
      --altslicesyntax      Convert to alternative slice syntax
      --demangle            Demangle instruction ASL
      --output FILE, -o FILE
                            Basename for output files
      --filter [FILE [FILE ...]]
                            Optional input json file to filter definitions
      --arch {AArch32,AArch64}
                            Optional list of architecture states to extract


## Subsetting

Various subsets of the architecture can be generated using these additional flags

    --arch=AArch32
    --arch=AArch64
    --arch=AArch32 --arch=AArch64

For finer control, you can specify a specific filter that selects exactly which
instructions and subset of the call graph to include

    make FILTER=--filter=usermode.json all

The filter is controlled by a json file that has this format:

    {
        "instructions": [
            // regexp list goes here
        ],
        "roots": [
            // root definitions go here
        ],
        "cuts": [
            // cut functions go here
        ],
        "canaries": [
            // canary definitions go here
        ]
    }

The four parts of this are:

- 'instructions' and 'roots' define what you want to include

    - 'instructions' is a list of regexps that match instruction names
      For example "aarch64/branch/conditional/.*".
      You can find the list of instruction names by looking in the file
      arch.tag.

          grep TAG arch.tag | grep decode

    - 'roots' is a list of functions that you wish to keep even though they are
      not referred to by instructions.  For example, after executing an
      instruction in Thumb mode, you should call "AArch32.ITAdvance()" (which
      has 0 arguments) so add "AArch32.ITAdvance.0" to the list of roots.  The
      ".0" suffix indicates that the function has 0 arguments.

- 'cuts' defines what you want to exclude.

    This should be a list of functions
    that you wish to provide your own implementations for.   For example, if all
    you are interested in is usermode execution, you might want to omit all the
    code to implement page table lookups and replace the functions to read or
    write memory by adding the following to the cut list

        "AArch64.MemSingle.read.4",
        "AArch64.MemSingle.write.4",

    This will cause the definitions of these functions to be replaced by
    function prototypes.

    Choosing the right set of cuts will depend on what functionality from the
    part you extract and on what you want to implement in your
    analysis/simulation framework.

- 'canaries' are optional but are useful when trying to understand why your
    'cuts' are not behaving as intended.

    Any uncut path from the instructions or roots to a canary is reported.

    For example, if you are trying to eliminate as much of the AArch32 support
    as possible, you might want to omit the function "ELUsingAArch32.1".
    But there are many possible code paths to that function and it is hard
    to find which functions to cut.  So add "ELUsingAArch32.1" to the list of
    canaries and you will get a report that looks a bit like this:

        Canary ELUsingAArch32.1 ELIsInHost.1 IsInHost.0 AArch64.TakeException.4 AArch64.UndefinedFault.0
        Canary ELUsingAArch32.1 ELIsInHost.1 S1TranslationRegime.0 ESR[ AArch64.ReportException.2 AArch64.TakeException.4 AArch64.UndefinedFault.0
        Canary ELUsingAArch32.1 ELIsInHost.1 S1TranslationRegime.0 AArch64.ReportException.2 AArch64.TakeException.4 AArch64.UndefinedFault.0
        ...
        Canary ELUsingAArch32.1 ELIsInHost.1 S1TranslationRegime.0 AArch64.TakeException.4 AArch64.UndefinedFault.0
        Canary ELUsingAArch32.1 ELIsInHost.1 AArch64.TakeException.4 AArch64.UndefinedFault.0
        Canary ELUsingAArch32.1 S1TranslationRegime.0 ESR[ AArch64.ReportException.2 AArch64.TakeException.4 AArch64.UndefinedFault.0
        Canary ELUsingAArch32.1 S1TranslationRegime.0 AArch64.ReportException.2 AArch64.TakeException.4 AArch64.UndefinedFault.0
        ...
        Canary ELUsingAArch32.1 S1TranslationRegime.0 VBAR.read.0 AArch64.TakeException.4 AArch64.UndefinedFault.0
        Canary ELUsingAArch32.1 S1TranslationRegime.0 AArch64.TakeException.4 AArch64.UndefinedFault.0
        Canary ELUsingAArch32.1 AArch64.TakeException.4 AArch64.UndefinedFault.0

    This shows that the final calls to ELUsingAArch32.1 are from ELIsInHost.1,
    S1TranslationRegime.0 and AArch64.TakeException.  So we could choose to cut
    all those functions.

    It also shows that the root call to ELUsingAArch32.1 is
    AArch64.UndefinedFault.0 so the easiest fix is to cut just that function.


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


## Experimental parser, etc.

There is an experimental parser for the language written in ocaml.
This requires some tools to be installed.  The following instructions are for
a Mac.

    brew install ocaml opam
    opam install menhir core

Test it using the following

    make test

At the moment, all it does is parse the ASL code extracted from the XML files.
It does not have a parser or typechecker.
