This directory consists of functions that are deliberately omitted from ARM's
official specification need to be implemented to execute the spec.

The current implementations are sufficient to create a simulator that can
execute very simple programs by:

- loading a program into memory using __ELFWriteMemory()
- resetting the processor state using __TakeColdReset()
- setting the program counter to the start address using __setPC()
- repeatedly calling __TopLevel() to execute one instruction at a time

The implementations of these functions are not part of ARM's official
specification, they are largely untested and almost certainly contain bugs.
They will get better in time.
