////////////////////////////////////////////////////////////////
// Functions to support exclusive memory accesses
//
// The following functions are not defined in the current
// XML release but are necessary to build a working simulator
////////////////////////////////////////////////////////////////

__RAM(52) __Memory;

boolean __ExclusiveLocal;

__ResetMemoryState()
    __InitRAM(52, 1, __Memory, Zeros(8)); // zero memory on reset
    __ExclusiveLocal = FALSE;

__ELFWriteMemory(bits(64) address, bits(8) val)
    __WriteRAM(52, 1, __Memory, address[0 +: 52], val);
    return;

bits(8*size) _Mem[AddressDescriptor desc, integer size, AccessDescriptor accdesc]
    assert size IN {1, 2, 4, 8, 16};
    bits(52) address = desc.paddress.address;
    assert address == Align(address, size);
    return __ReadRAM(52, size, __Memory, address);

_Mem[AddressDescriptor desc, integer size, AccessDescriptor accdesc] = bits(8*size) value
    assert size IN {1, 2, 4, 8, 16};
    bits(52) address = desc.paddress.address;
    assert address == Align(address, size);

    if address == 0x13000000[51:0] then // TUBE
        if UInt(value) == 0x4 then
            print("Program exited by writing ^D to TUBE\n");
            __abort();
        else
            putchar(UInt(value[7:0]));
    else
        __WriteRAM(52, size, __Memory, address, value);
    return;

ClearExclusiveLocal(integer processorid)
    __ExclusiveLocal = FALSE;
    return;

MarkExclusiveLocal(FullAddress paddress, integer processorid, integer size)
    __ExclusiveLocal = FALSE;

boolean IsExclusiveLocal(FullAddress paddress, integer processorid, integer size)
    return __ExclusiveLocal;


boolean AArch32.IsExclusiveVA(bits(32) address, integer processorid, integer size)
    assert FALSE;
    return FALSE;

AArch32.MarkExclusiveVA(bits(32) address, integer processorid, integer size)
    assert FALSE;

boolean AArch64.IsExclusiveVA(bits(64) address, integer processorid, integer size)
    assert FALSE;
    return FALSE;

AArch64.MarkExclusiveVA(bits(64) address, integer processorid, integer size)
    assert FALSE;

ClearExclusiveByAddress(FullAddress paddress, integer processorid, integer size)
    assert TRUE; // todo

bit ExclusiveMonitorsStatus()
    assert FALSE;
    return '0'; // '0' indicates success

boolean IsExclusiveGlobal(FullAddress paddress, integer processorid, integer size)
    assert FALSE;
    return FALSE;

MarkExclusiveGlobal(FullAddress paddress, integer processorid, integer size)
    assert FALSE;

integer ProcessorID()
    return 0;

bits(4) _MemTag[AddressDescriptor desc]
    assert FALSE;
    return Zeros(4);

_MemTag[AddressDescriptor desc] = bits(4) value
    assert FALSE;
    return;

boolean IsNonTagCheckedInstruction()
    assert FALSE;
    return FALSE;

SetNotTagCheckedInstruction(boolean unchecked)
    assert FALSE;
    return;

bits(4) _ChooseRandomNonExcludedTag(bits(16) exclude)
    assert FALSE;
    return Zeros(4);

(bits(64), integer) ImpDefTagArrayStartAndCount(bits(64) address)
    assert FALSE;
    return (Zeros(64), 0);

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
