////////////////////////////////////////////////////////////////
// Feature support
////////////////////////////////////////////////////////////////

boolean HaveAnyAArch32()
    // return boolean IMPLEMENTATION_DEFINED;
    return TRUE;

boolean HighestELUsingAArch32()
    if !HaveAnyAArch32() then return FALSE;
    // return boolean IMPLEMENTATION_DEFINED;       // e.g. CFG32SIGNAL == HIGH
    return FALSE;

boolean HaveEL(bits(2) el)
    if el IN {EL1,EL0} then
        return TRUE;                             // EL1 and EL0 must exist
    // return boolean IMPLEMENTATION_DEFINED;
    return TRUE;

boolean IsSecureBelowEL3()
    if HaveEL(EL3) then
        return SCR_GEN[].NS == '0';
    elsif HaveEL(EL2) then
        return FALSE;
    else
        // TRUE if processor is Secure or FALSE if Non-secure;
        // return boolean IMPLEMENTATION_DEFINED;
        return FALSE;

boolean HasArchVersion(ArchVersion version)
    // return version == ARMv8p0 || boolean IMPLEMENTATION_DEFINED;
    return version IN {ARMv8p0, ARMv8p1, ARMv8p2, ARMv8p3,
                       ARMv8p4, ARMv8p5, ARMv8p6};

boolean HaveAArch32EL(bits(2) el)
    // Return TRUE if Exception level 'el' supports AArch32 in this implementation
    if !HaveEL(el) then
        return FALSE;                    // The Exception level is not implemented
    elsif !HaveAnyAArch32() then
        return FALSE;                    // No Exception level can use AArch32
    elsif HighestELUsingAArch32() then
        return TRUE;                     // All Exception levels are using AArch32
    elsif el == HighestEL() then
        return FALSE;                    // The highest Exception level is using AArch64
    elsif el == EL0 then
        return TRUE;                     // EL0 must support using AArch32 if any AArch32
    // return boolean IMPLEMENTATION_DEFINED;
    return TRUE;

boolean Have16bitVMID()
    // return HaveEL(EL2) && boolean IMPLEMENTATION_DEFINED;
    return HaveEL(EL2);

boolean HaveFP16Ext()
    // return boolean IMPLEMENTATION_DEFINED;
    return TRUE;

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
