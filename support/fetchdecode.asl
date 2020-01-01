////////////////////////////////////////////////////////////////
// Functions to support instruction fetch/decode
//
// The following functions are not defined in the current
// XML release but are necessary to build a working simulator
////////////////////////////////////////////////////////////////

EndOfInstruction()
    __ExceptionTaken();


boolean __Sleeping;

EnterLowPowerState()
    __Sleeping = TRUE;

ExitLowPowerState()
    __Sleeping = FALSE;

__ResetExecuteState()
    __Sleeping    = FALSE;

ExecuteA64(bits(32) instr)
    __decode A64 instr;

ExecuteA32(bits(32) instr)
    __decode A32 instr;

ExecuteT32(bits(16) hw1, bits(16) hw2)
    __decode T32 (hw1 : hw2);

ExecuteT16(bits(16) instr)
    __decode T16 instr;

// Implementation of BranchTo and BranchToAddr modified so that we can
// tell that a branch was taken - this is essential for implementing
// PC advance correctly.

boolean __BranchTaken;

BranchTo(bits(N) target, BranchType branch_type)
    __BranchTaken = TRUE; // extra line added
    Hint_Branch(branch_type);
    if N == 32 then
        assert UsingAArch32();
        _PC = ZeroExtend(target);
    else
        assert N == 64 && !UsingAArch32();
        _PC = AArch64.BranchAddr(target[63:0]);
    return;

BranchToAddr(bits(N) target, BranchType branch_type)
    __BranchTaken = TRUE; // extra line added
    Hint_Branch(branch_type);
    if N == 32 then
        assert UsingAArch32();
        _PC = ZeroExtend(target);
    else
        assert N == 64 && !UsingAArch32();
        _PC = target[63:0];
    return;

enumeration __InstrEnc { __A64, __A32, __T16, __T32 };

bits(32)   __ThisInstr;
__InstrEnc __ThisInstrEnc;
bits(4)    __currentCond;


__SetThisInstrDetails(__InstrEnc enc, bits(32) opcode, bits(4) cond)
    __ThisInstrEnc = enc;
    __ThisInstr    = opcode;
    __currentCond  = cond;
    return;

bits(32) ThisInstr()
    return __ThisInstr;

// Length in bits of instruction
integer ThisInstrLength()
    return if __ThisInstrEnc == __T16 then 16 else 32;

bits(4) AArch32.CurrentCond()
    return __currentCond;

bits(N) ThisInstrAddr()
    return _PC[0 +: N];

bits(N) NextInstrAddr()
    return (_PC + (ThisInstrLength() DIV 8))[N-1:0];

(__InstrEnc, bits(32)) __FetchInstr(bits(64) pc)
    __InstrEnc enc;
    bits(32)   instr;

    CheckSoftwareStep();

    if PSTATE.nRW == '0' then
        AArch64.CheckPCAlignment();
        enc = __A64;
        instr = AArch64.MemSingle[pc, 4, AccType_IFETCH, TRUE];
        AArch64.CheckIllegalState();
    else
        AArch32.CheckPCAlignment();
        if PSTATE.T == '1' then
            hw1 = AArch32.MemSingle[pc[31:0], 2, AccType_IFETCH, TRUE];
            isT16 = UInt(hw1[15:11]) < UInt('11101');
            if isT16 then
                enc = __T16;
                instr = Zeros(16) : hw1;
            else
                hw2 = AArch32.MemSingle[pc[31:0]+2, 2, AccType_IFETCH, TRUE];
                enc   = __T32;
                instr = hw1 : hw2;
        else
            enc   = __A32;
            instr = AArch32.MemSingle[pc[31:0], 4, AccType_IFETCH, TRUE];
        AArch32.CheckIllegalState();

    return (enc, instr);

__DecodeExecute(__InstrEnc enc, bits(32) instr)
    case enc of
        when __A64
            ExecuteA64(instr);
        when __A32
            ExecuteA32(instr);
        when __T16
            ExecuteT16(instr[15:0]);
        when __T32
            ExecuteT32(instr[31:16], instr[15:0]);
    return;

// Default condition for an instruction with encoding 'enc'.
// This may be overridden for instructions with explicit condition field.
bits(4) __DefaultCond(__InstrEnc enc)
    if enc IN {__A64, __A32} || PSTATE.IT[3:0] == Zeros(4) then
        cond = 0xE[3:0];
    else
        cond = PSTATE.IT[7:4];
    return cond;

__InstructionExecute()
    try
        __BranchTaken = FALSE;
        bits(64) pc   = ThisInstrAddr();
        (enc, instr)  = __FetchInstr(pc);
        __SetThisInstrDetails(enc, instr, __DefaultCond(enc));
        __DecodeExecute(enc, instr);

    catch exn
        // Do not catch UNPREDICTABLE or internal errors
        when IsSEE(exn) || IsUNDEFINED(exn)
            if UsingAArch32() then
                if ConditionHolds(AArch32.CurrentCond()) then
                    AArch32.UndefinedFault();
            else
                AArch64.UndefinedFault();

        when IsExceptionTaken(exn)
            // Do nothing
            assert TRUE; // todo: this is a bodge around lack of support for empty statements

    if !__BranchTaken then
        _PC = (_PC + (ThisInstrLength() DIV 8))[63:0];

    boolean itExecuted = __ThisInstrEnc == __T16 && __ThisInstr[15:0] IN '1011 1111 xxxx xxxx' && __ThisInstr[3:0] != '0000';
    if PSTATE.nRW == '1' && PSTATE.T == '1' && !itExecuted then
        AArch32.ITAdvance();

    return;

////////////////////////////////////////////////////////////////
// The following functions define the IMPLEMENTATION_DEFINED behaviour
// of this execution
////////////////////////////////////////////////////////////////

boolean __IMPDEF_boolean(string x)
    if x == "Condition valid for trapped T32" then return TRUE;
    elsif x == "Has Dot Product extension" then return TRUE;
    elsif x == "Has RAS extension" then return TRUE;
    elsif x == "Has SHA512 and SHA3 Crypto instructions" then return TRUE;
    elsif x == "Has SM3 and SM4 Crypto instructions" then return TRUE;
    elsif x == "Has basic Crypto instructions" then return TRUE;
    elsif x == "Have CRC extension" then return TRUE;
    elsif x == "Report I-cache maintenance fault in IFSR" then return TRUE;
    elsif x == "Reserved Control Space EL0 Trapped" then return TRUE;
    elsif x == "Translation fault on misprogrammed contiguous bit" then return TRUE;
    elsif x == "UNDEF unallocated CP15 access at NS EL0" then return TRUE;
    elsif x == "UNDEF unallocated CP15 access at NS EL0" then return TRUE;

    return FALSE;

integer __IMPDEF_integer(string x)
    if x == "Maximum Physical Address Size" then return 52;
    elsif x == "Maximum Virtual Address Size" then return 56;

    return 0;

bits(N) __IMPDEF_bits(integer N, string x)
    if x == "0 or 1" then return Zeros(N);
    elsif x == "FPEXC.EN value when TGE==1 and RW==0" then return Zeros(N);
    elsif x == "reset vector address" then return Zeros(N);

    return Zeros(N);

MemoryAttributes __IMPDEF_MemoryAttributes(string x)
    return MemoryAttributes UNKNOWN;

// todo: implement defaults for these behaviours
// IMPLEMENTATION_DEFINED "floating-point trap handling";
// IMPLEMENTATION_DEFINED "signal slave-generated error";

////////////////////////////////////////////////////////////////
// The following functions are required by my simulator:
// - __TopLevel(): take one atomic step
// - __setPC(): set PC to particular value (used after loading an ELF file)
// - __getPC(): read current value of PC (used to support breakpointing)
// - __conditionPassed: set if executing a conditional instruction
// - __CycleEnd(): deprecated hook called after every instruction execution
// - __ModeString(): generate summary of current mode (used to support tracing)
////////////////////////////////////////////////////////////////

__TakeColdReset()
    PSTATE.nRW = '0'; // boot into A64 mode
    PSTATE.SS = '0';
    __ResetInterruptState();
    __ResetMemoryState();
    __ResetExecuteState();
    AArch64.TakeReset(TRUE);

__TopLevel()
    __InstructionExecute();

__setPC(integer x)
    _PC = x[63:0];
    return;

integer __getPC()
    return UInt(_PC);

boolean __conditionPassed;

__CycleEnd()
    return;

// Function used to generate summary of current state of processor
// (used when generating debug traces)
string __ModeString()
    return "";

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
