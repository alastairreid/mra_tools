////////////////////////////////////////////////////////////////
// Functions to support usermode execution
//
// The following functions provide simplified implementations
// of some key system architecture functions that are sufficient
// to model usermode behaviour.
////////////////////////////////////////////////////////////////

// Simplified version of AArch64 bit normalization of virtual addresses
bits(64) AArch64.BranchAddr(bits(64) vaddress)
    assert !UsingAArch32();
    integer msbit = 51;
    return ZeroExtend(vaddress[msbit:0]);

bits(size*8) AArch64.MemSingle[bits(64) address, integer size, AccType acctype, boolean wasaligned]
    AddressDescriptor desc;
    AccessDescriptor accdesc;
    desc.paddress.physicaladdress = address[0 +: 52];
    return _Mem[desc, size, accdesc];

AArch64.MemSingle[bits(64) address, integer size, AccType acctype, boolean wasaligned] = bits(size*8) value
    AddressDescriptor desc;
    AccessDescriptor accdesc;
    desc.paddress.physicaladdress = address[0 +: 52];
    _Mem[desc, size, accdesc] = value;
    return;


bits(size*8) Mem[bits(64) address, integer size, AccType acctype]
    return AArch64.MemSingle[address, size, acctype, TRUE];

Mem[bits(64) address, integer size, AccType acctype] = bits(size*8) value
    AArch64.MemSingle[address, size, acctype, TRUE] = value;
    return;

AArch64.TakeException(bits(2) target_el, ExceptionRecord exception,
                      bits(64) preferred_exception_return, integer vect_offset)
    assert FALSE;

AArch64.UndefinedFault()
    assert FALSE;

AArch32.UndefinedFault()
    assert FALSE;

ReservedValue()
    assert FALSE;

UnallocatedEncoding()
    assert FALSE;

EndOfInstruction()
    assert FALSE;

CheckSoftwareStep()
    return;

bits(64) AuthDA(bits(64) X, bits(64) Y)
    assert FALSE;
    return bits(64) UNKNOWN;

bits(64) AuthDB(bits(64) X, bits(64) Y)
    assert FALSE;
    return bits(64) UNKNOWN;

CheckSPAlignment()
    return;

AArch32.CheckPCAlignment()
    return;

ResetExternalDebugRegisters(boolean cold_reset)
    return;

AArch32.CheckIllegalState()
    return;

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
