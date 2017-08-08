////////////////////////////////////////////////////////////////
// Functions to support debug features
//
// The following functions are not defined in the current
// XML release but are necessary to build a working simulator
////////////////////////////////////////////////////////////////

CTI_SetEventLevel(CrossTriggerIn id, signal level)
    assert FALSE;

CTI_SignalEvent(CrossTriggerIn id)
    assert FALSE;

DisableITRAndResumeInstructionPrefetch()
    assert FALSE;

boolean HaltingStep_DidNotStep()
    assert FALSE;
    return FALSE;

boolean HaltingStep_SteppedEX()
    assert FALSE;
    return FALSE;

ResetExternalDebugRegisters(boolean cold_reset)
    assert FALSE;

boolean SoftwareStep_DidNotStep()
    assert FALSE;
    return FALSE;

boolean SoftwareStep_SteppedEX()
    assert FALSE;
    return FALSE;

StopInstructionPrefetchAndEnableITR()
    assert FALSE;

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
