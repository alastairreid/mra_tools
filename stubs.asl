////////////////////////////////////////////////////////////////
// Stub functions
//
// The following functions are not defined in the current
// XML release.  There are a number of different categories
// of stub function:
//
// - Part of the instruction decode/execute machinery that a
//   simulator must supply
// - Part of the system register access machinery defined
//   by the system register XML
// - Part of the memory system machinery that a simulator must
//   supply
// - Part of the interrupt/sleep machinery that a simulator
//   must supply
// - Part of the AES instruction support omitted for export
//   control reasons
////////////////////////////////////////////////////////////////

bits(4) AArch32.CurrentCond()
    assert(FALSE);

boolean AArch32.IsExclusiveVA(bits(32) address, integer processorid, integer size)
    assert(FALSE);

AArch32.MarkExclusiveVA(bits(32) address, integer processorid, integer size)
    assert(FALSE);

AArch32.SErrorSyndrome AArch32.PhysicalSErrorSyndrome()
    assert(FALSE);

AArch32.ResetControlRegisters(boolean cold_reset)
    assert(FALSE);

AArch32.ResetSystemRegisters(boolean cold_reset)
    assert(FALSE);

bits(64) AArch32.SysRegRead64(integer cp_num, bits(32) instr)
    assert(FALSE);

boolean AArch32.SysRegReadCanWriteAPSR(integer cp_num, bits(32) instr)
    assert(FALSE);

bits(32) AArch32.SysRegRead(integer cp_num, bits(32) instr)
    assert(FALSE);

bits(64) AArch32.SysRegRead64(integer cp_num, bits(32) instr)
    assert(FALSE);

AArch32.SysRegWrite(integer cp_num, bits(32) instr, bits(32) val)
    assert(FALSE);

AArch32.SysRegWrite64(integer cp_num, bits(32) instr, bits(64) val)
    assert(FALSE);

AArch32.SysRegWrite64(integer cp_num, bits(32) instr, bits(64) val)
    assert(FALSE);

(boolean, bits(2)) AArch64.CheckAdvSIMDFPSystemRegisterTraps(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert(FALSE);

(boolean, bits(2)) AArch64.CheckAdvSIMDFPSystemRegisterTraps(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert(FALSE);

(boolean, bits(2)) AArch64.CheckSystemRegisterTraps(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert(FALSE);

boolean AArch64.CheckUnallocatedSystemAccess(bits(2) op0, bits(3) op1, bits(4) crn, bits(4) crm, bits(3) op2, bit read)
    assert(FALSE);

boolean AArch64.IsExclusiveVA(bits(64) address, integer processorid, integer size)
    assert(FALSE);

AArch64.MarkExclusiveVA(bits(64) address, integer processorid, integer size)
    assert(FALSE);

bits(25) AArch64.PhysicalSErrorSyndrome(boolean implicit_esb)
    assert(FALSE);

AArch64.ResetControlRegisters(boolean cold_reset)
    assert(FALSE);

AArch64.ResetSystemRegisters(boolean cold_reset)
    assert(FALSE);

bits(64) AArch64.SysInstrWithResult(integer op0, integer op1, integer crn, integer crm, integer op2)
    assert(FALSE);

AArch64.SysInstr(integer op0, integer op1, integer crn, integer crm, integer op2, bits(64) val)
    assert(FALSE);

bits(64) AArch64.SysInstrWithResult(integer op0, integer op1, integer crn, integer crm, integer op2)
    assert(FALSE);

AArch64.SysRegWrite(integer op0, integer op1, integer crn, integer crm, integer op2, bits(64) val)
    assert(FALSE);

bits(128) AESInvMixColumns(bits (128) op)
    assert(FALSE);

bits(128) AESInvShiftRows(bits(128) op)
    assert(FALSE);

bits(128) AESInvSubBytes(bits(128) op)
    assert(FALSE);

bits(128) AESMixColumns(bits (128) op)
    assert(FALSE);

bits(128) AESShiftRows(bits(128) op)
    assert(FALSE);

bits(128) AESSubBytes(bits(128) op)
    assert(FALSE);

boolean CP14DebugInstrDecode(bits(32) instr)
    assert(FALSE);

boolean CP14JazelleInstrDecode(bits(32) instr)
    assert(FALSE);

boolean CP14TraceInstrDecode(bits(32) instr)
    assert(FALSE);

boolean CP15InstrDecode(bits(32) instr)
    assert(FALSE);

CTI_SetEventLevel(CrossTriggerIn id, signal level)
    assert(FALSE);

CTI_SignalEvent(CrossTriggerIn id)
    assert(FALSE);

ClearExclusiveByAddress(FullAddress paddress, integer processorid, integer size)
    assert(FALSE);

ClearExclusiveLocal(integer processorid)
    assert(FALSE);

ClearPendingPhysicalSError()
    assert(FALSE);

DataMemoryBarrier(MBReqDomain domain, MBReqTypes types)
    assert(FALSE);

DataSynchronizationBarrier(MBReqDomain domain, MBReqTypes types)
    assert(FALSE);

DisableITRAndResumeInstructionPrefetch()
    assert(FALSE);

EndOfInstruction()
    assert(FALSE);

EnterLowPowerState()
    assert(FALSE);

ErrorSynchronizationBarrier(MBReqDomain domain, MBReqTypes types)
    assert(FALSE);

bit ExclusiveMonitorsStatus()
    assert(FALSE);

ExecuteA64(bits(32) instr)
    assert(FALSE);

ExecuteT32(bits(16) hw1, bits(16) hw2)
    assert(FALSE);

boolean HaltingStep_DidNotStep()
    assert(FALSE);

boolean HaltingStep_SteppedEX()
    assert(FALSE);

Hint_Branch(BranchType hint)
    assert(FALSE);

Hint_Prefetch(bits(64) address, PrefetchHint hint, integer target, boolean stream)
    assert(FALSE);

Hint_PreloadDataForWrite(bits(32) address)
    assert(FALSE);

Hint_PreloadData(bits(32) address)
    assert(FALSE);

Hint_PreloadDataForWrite(bits(32) address)
    assert(FALSE);

Hint_PreloadInstr(bits(32) address)
    assert(FALSE);

Hint_Yield()
    assert(FALSE);

InstructionSynchronizationBarrier()
    assert(FALSE);

boolean InterruptPending()
    assert(FALSE);

boolean IsExclusiveGlobal(FullAddress paddress, integer processorid, integer size)
    assert(FALSE);

boolean IsExclusiveLocal(FullAddress paddress, integer processorid, integer size)
    assert(FALSE);

bits(11) LSInstructionSyndrome()
    assert(FALSE);

MarkExclusiveGlobal(FullAddress paddress, integer processorid, integer size)
    assert(FALSE);

MarkExclusiveLocal(FullAddress paddress, integer processorid, integer size)
    assert(FALSE);

bits(N) NextInstrAddr()
    assert(FALSE);

integer ProcessorID()
    assert(FALSE);

ProfilingSynchronizationBarrier()
    assert(FALSE);

boolean RemapRegsHaveResetValues()
    assert(FALSE);

ResetExternalDebugRegisters(boolean cold_reset)
    assert(FALSE);

boolean SErrorPending()
    assert(FALSE);

SendEvent()
    assert(FALSE);

SetInterruptRequestLevel(InterruptID id, signal level)
    assert(FALSE);

boolean SoftwareStep_DidNotStep()
    assert(FALSE);

boolean SoftwareStep_SteppedEX()
    assert(FALSE);

StopInstructionPrefetchAndEnableITR()
    assert(FALSE);

SynchronizeContext()
    assert(FALSE);

bits(64) System_Get(integer op0, integer op1, integer crn, integer crm, integer op2)
    assert(FALSE);

TakeUnmaskedPhysicalSErrorInterrupts(boolean iesb_req)
    assert(FALSE);

TakeUnmaskedSErrorInterrupts()
    assert(FALSE);

bits(32) ThisInstr()
    assert(FALSE);

integer ThisInstrLength()
    assert(FALSE);

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
