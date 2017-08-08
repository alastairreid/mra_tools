////////////////////////////////////////////////////////////////
// Functions to support interrupts and System Errors
//
// The following functions are not defined in the current
// XML release but are necessary to build a working simulator
////////////////////////////////////////////////////////////////

boolean __PendingPhysicalSError;
boolean __PendingInterrupt;

__ResetInterruptState()
    __PendingPhysicalSError = FALSE;
    __PendingInterrupt = FALSE;

boolean InterruptPending()
    return __PendingInterrupt;

SendEvent()
    assert FALSE;

SetInterruptRequestLevel(InterruptID id, signal level)
    assert FALSE;

AArch32.SErrorSyndrome AArch32.PhysicalSErrorSyndrome()
    assert FALSE;
    AArch32.SErrorSyndrome r;
    r.AET = Zeros(2);
    r.ExT = Zeros(1);
    return r;

bits(25) AArch64.PhysicalSErrorSyndrome(boolean implicit_esb)
    assert FALSE;
    return Zeros(25);

__SetPendingPhysicalSError()
    __PendingPhysicalSError = TRUE;
    return;

ClearPendingPhysicalSError()
    __PendingPhysicalSError = FALSE;
    return;

boolean SErrorPending()
    // todo: can there be a pending virtual SError?
    return __PendingPhysicalSError;

TakeUnmaskedPhysicalSErrorInterrupts(boolean iesb_req)
    assert FALSE;

TakeUnmaskedSErrorInterrupts()
    assert FALSE;

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
