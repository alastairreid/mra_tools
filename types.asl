type CPACRType   = TypeOf(CPACR_EL1);
type CNTKCTLType = TypeOf(CNTKCTL_EL1);
type ESRType     = TypeOf(ESR_ELx);
type FPCRType    = TypeOf(FPCR);
type MAIRType    = TypeOf(MAIR_EL1);
type SCRType     = TypeOf(SCR);
type SCTLRType   = TypeOf(SCTLR_EL1);

// The following appear to be missing from the XML
// The following is not necessarily correct - but it lets us keep going
TypeOf(TTBCR) TTBCR_S;
__register 32 { 0+:24 PC, 29+:2 EL, 31 NS } EDPCSRhi;
__register 64 { 0 E, 1+:2 FM, 12+:48 LIMIT } PMBLIMITR_EL1;
__register 64 { 0+:6 FSC, 0+:6 BSC, 16 COLL, 17 S, 18 EA, 19 DL, 26+:6 EC } PMBSR_EL1;
__register 64 { 0 E0SPE, 1 E1SPE, 3 CX, 4 PA, 5 TS, 6 PCT } PMSCR_EL1;
__register 64 { 0 E0HSPE, 1 E2SPE, 3 CX, 4 PA, 5 TS, 6 PCT } PMSCR_EL2;
__register 64 { } PMSEVFR_EL1;
__register 64 { 0 FE, 1 FT, 2 FL, 16 B, 17 LD, 18 ST } PMSFCR_EL1;
__register 64 { 0+:12 MINLAT } PMSLATFR_EL1;
__register 32 {} VDFSR;
__register 32 {} VSESR_EL2;

bits(64) AArch64.SysRegRead(integer op0, integer op1, integer crn, integer crm, integer op2);
AArch64.SysRegWrite(integer op0, integer op1, integer crn, integer crm, integer op2, bits(64) val);
