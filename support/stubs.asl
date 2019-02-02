////////////////////////////////////////////////////////////////
// Miscellaneous stub functions
//
// The following functions are not defined in the current
// XML release.
////////////////////////////////////////////////////////////////

AArch32.ResetControlRegisters(boolean cold_reset)
    assert FALSE;

AArch32.ResetSystemRegisters(boolean cold_reset)
    assert FALSE;

AArch64.ResetControlRegisters(boolean cold_reset)
    return;

AArch64.ResetSystemRegisters(boolean cold_reset)
    return;

ResetExternalDebugRegisters(boolean cold_reset)
    return;


bits(64) AArch32.SysRegRead64(integer cp_num, bits(32) instr)
    assert FALSE;
    return Zeros(64);

boolean AArch32.SysRegReadCanWriteAPSR(integer cp_num, bits(32) instr)
    assert FALSE;
    return FALSE;

bits(32) AArch32.SysRegRead(integer cp_num, bits(32) instr)
    assert FALSE;
    return Zeros(32);

bits(64) AArch32.SysRegRead64(integer cp_num, bits(32) instr)
    assert FALSE;
    return Zeros(64);

AArch32.SysRegWrite(integer cp_num, bits(32) instr, bits(32) val)
    assert FALSE;

AArch32.SysRegWrite64(integer cp_num, bits(32) instr, bits(64) val)
    assert FALSE;

AArch32.SysRegWrite64(integer cp_num, bits(32) instr, bits(64) val)
    assert FALSE;

(boolean, bits(2)) AArch64.CheckAdvSIMDFPSystemRegisterTraps(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert FALSE;
    return (FALSE, '00');

(boolean, bits(2)) AArch64.CheckAdvSIMDFPSystemRegisterTraps(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert FALSE;
    return (FALSE, '00');

(boolean, bits(2)) AArch64.CheckSystemRegisterTraps(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert FALSE;
    return (FALSE, '00');

boolean AArch64.CheckUnallocatedSystemAccess(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert FALSE;
    return FALSE;

bits(64) AArch64.SysInstrWithResult(integer op0, integer op1, integer crn, integer crm, integer op2)
    assert FALSE;
    return Zeros(64);

AArch64.SysInstr(integer op0, integer op1, integer crn, integer crm, integer op2, bits(64) val)
    assert FALSE;

bits(64) AArch64.SysInstrWithResult(integer op0, integer op1, integer crn, integer crm, integer op2)
    assert FALSE;
    return Zeros(64);

AArch64.SysRegWrite(integer op0, integer op1, integer crn, integer crm, integer op2, bits(64) val)
    assert FALSE;

bits(64) System_Get(integer op0, integer op1, integer crn, integer crm, integer op2)
    assert FALSE;
    return Zeros(64);

boolean CP14DebugInstrDecode(bits(32) instr)
    assert FALSE;
    return FALSE;

boolean CP14JazelleInstrDecode(bits(32) instr)
    assert FALSE;
    return FALSE;

boolean CP14TraceInstrDecode(bits(32) instr)
    assert FALSE;
    return FALSE;

boolean CP15InstrDecode(bits(32) instr)
    assert FALSE;
    return FALSE;

bits(11) LSInstructionSyndrome()
    assert FALSE;
    return Zeros(11);

boolean RemapRegsHaveResetValues()
    assert FALSE;
    return FALSE;

UndefinedFault()
    assert FALSE;
    return;

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
