type CPACRType   = typeof(CPACR_EL1);
type CNTKCTLType = typeof(CNTKCTL_EL1);
type ESRType     = typeof(ESR_EL1);
type FPCRType    = typeof(FPCR);
type MAIRType    = typeof(MAIR_EL1);
type SCRType     = typeof(SCR);
type SCTLRType   = typeof(SCTLR_EL1);

// The following appear to be missing from the XML
// The following is not necessarily correct - but it lets us keep going
typeof(TTBCR) TTBCR_S;
__register 32 { 0+:24 PC, 29+:2 EL, 31 NS } EDPCSRhi;

bits(64) AArch64.SysRegRead(integer op0, integer op1, integer crn, integer crm, integer op2);
AArch64.SysRegWrite(integer op0, integer op1, integer crn, integer crm, integer op2, bits(64) val);
TraceSynchronizationBarrier();

constant integer LOG2_TAG_GRANULE=4;
constant integer TAG_GRANULE=2 ^ LOG2_TAG_GRANULE;
// These declarations have to be manually inserted into arch.asl after extraction.
// Insert them before the declaration of MemTag.
// bits(4) _MemTag[AddressDescriptor desc]
// _MemTag[AddressDescriptor desc] = bits(4) value;
boolean IsNonTagCheckedInstruction();
SetNotTagCheckedInstruction(boolean unchecked);
bits(4) _ChooseRandomNonExcludedTag(bits(16) exclude);
(bits(64), integer) ImpDefTagArrayStartAndCount(bits(64) address);

signal HIDEN;
signal HNIDEN;
