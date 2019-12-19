type CPACRType   = typeof(CPACR_EL1);
type CNTKCTLType = typeof(CNTKCTL_EL1);
type ESRType     = typeof(ESR_EL1);
type FPCRType    = typeof(FPCR);
type MAIRType    = typeof(MAIR_EL1);
type SCRType     = typeof(SCR_EL3);
type SCTLRType   = typeof(SCTLR_EL1);

// The following appear to be missing from the XML
// The following is not necessarily correct - but it lets us keep going
__register 32 { 31:31 EAE, 5:5 PD1, 4:4 PD0, 2:0 N, 29:28 SH1, 27:26 ORGN1, 25:24 IRGN1, 23:23 EPD1, 22:22 A1, 18:16 T1SZ, 13:12 SH0, 11:10 ORGN0, 9:8 IRGN0, 7:7 EPD0, 6:6 T2E, 2:0 T0SZ } TTBCR_S;
__register 32 { 0+:24 PC, 29+:2 EL, 31 NS } EDPCSRhi;

bits(64) AArch64.SysRegRead(integer op0, integer op1, integer crn, integer crm, integer op2);
AArch64.SysRegWrite(integer op0, integer op1, integer crn, integer crm, integer op2, bits(64) val);
TraceSynchronizationBarrier();
UndefinedFault();
ReservedEncoding();

boolean IRQPending();
boolean FIQPending();

constant integer LOG2_TAG_GRANULE=4;
constant integer TAG_GRANULE=2 ^ LOG2_TAG_GRANULE;
// These declarations have to be manually inserted into arch.asl after extraction.
// Insert them before the declaration of MemTag.
// bits(4) _MemTag[AddressDescriptor desc];
// _MemTag[AddressDescriptor desc] = bits(4) value;
boolean IsNonTagCheckedInstruction();
SetNotTagCheckedInstruction(boolean unchecked);
bits(4) _ChooseRandomNonExcludedTag(bits(16) exclude);
(bits(64), integer) ImpDefTagArrayStartAndCount(bits(64) address);

signal HIDEN;
signal HNIDEN;
