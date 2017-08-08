////////////////////////////////////////////////////////////////
// Functions to implement hint instructions
//
// The following functions are not defined in the current
// XML release but are necessary to build a working simulator
////////////////////////////////////////////////////////////////

Hint_Branch(BranchType hint)
    return;

Hint_Prefetch(bits(64) address, PrefetchHint hint, integer target, boolean stream)
    return;

Hint_PreloadDataForWrite(bits(32) address)
    return;

Hint_PreloadData(bits(32) address)
    return;

Hint_PreloadDataForWrite(bits(32) address)
    return;

Hint_PreloadInstr(bits(32) address)
    return;

Hint_Yield()
    return;

////////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////////
