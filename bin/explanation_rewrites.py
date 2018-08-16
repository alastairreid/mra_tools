import re

rewrites = [
    (r'\s+', r' '), # normalise multiple whitespace
    (r'^\s', r''), # leading whitespace
    (r'\s$', r''), # trailing whitespace

    # normalisation
    (r',', r' '),
    (r'\ban\b', r'a'),
    (r'-bit', r' bit'),
    (r'\bencoded as\b', r'encoded in'),
    (r'\band encoded in\b', r'encoded in'),
    (r'the [\'"](.+)[\'"] fields?', r'"\1"'),
    (r'^Is a ', r'Is the '),
    (r'^Specifies (a|the) ', r'Is the '),
    (r'Is the', r'is the'),
    (r' unsigned \(positive\) ', ' unsigned '),

    (r'\s+', r' '), # normalise multiple whitespace
    (r'^\s', r''), # leading whitespace
    (r'\s$', r''), # trailing whitespace

    # maths
    (r'\bzero\b',  r'0'),
    (r'\bone\b',   r'1'),
    (r'\btwo\b',   r'2'),
    (r'\bthree\b', r'3'),
    (r'\bfour\b',  r'4'),
    (r'\bfive\b',  r'5'),
    (r'\bsix\b',   r'6'),
    (r'\bseven\b', r'7'),
    (r'\beight\b', r'8'),
    (r'\bnine\b',  r'9'),
    (r'\bdivided by\b', r'/'),
    (r'\btimes\b', r'*'),
    (r'\bminus\b', r'-'),
    (r'\bplus\b', r'+'),

    # should be specified in XML as enclist etc
    (r'^For the (.+?) variant: ', r''),
    (r'^When (.+?) is the ', r'is the '),

    # useless natural-language junk
    (r' in the range -?\d+ to -?\d+\b', r''),
    (r' in the range \+/-\d+[kmgKMG][bB]\b', r''),
    (r' holding the data value to be operated on with the contents of the memory location\b', r''),
    (r' holding the address to be branched to\b', r''),
    (r' holding the (multiplier|multiplicand|addend|minuend|modifier)\b', r''),
    (r' into which the status result of the store exclusive is written\b', r''),
    (r' giving the alternative state for the 4 bit NZCV condition flags\b', r''),
    (r' which selects the bits that are inserted into the NZCV condition flags\b', r''),
    (r' to be (loaded|stored|transferred|moved from the source|tested|compared and loaded|conditionally stored)\b', r''),
    (r' to apply to the immediate\b', r''),
    (r' from which to extract\b', r''),
    (r' (most|least) significant\b', r''),
    (r' (first|second|third|fourth|fifth|sixth|seventh|eighth|ninth)\b', r''),
    (r' (left|right|rotate)\b', r''),
    (r' to be applied to the (source operand|final source)\b', r''),
    (r'\.$', r''),
    (r'\. It is$', r''),
    (r' and$', r''),
    (r' excluding the allocated encodings described below ', r' '),
    (r' only when <extend> is not LSL', r''),
    (r'. The System register names are defined in \'AArch64 System Registers\' in the System Register XML', r''),
    (r'. This syntax is only for encodings that are not accessible using <prfop>', r''),
    (r' and which must be omitted for the LSL option when <amount> is omitted', r''),

    (r'. The value returned is:.+$', r''), # TODO FIXME too much?
    (r'. The following encodings of "CRm:op2" are allocated:.+$', r''), # TODO FIXME too much?
    (r'. The encodings that are allocated to architectural hint functionality are described.+$', r''), # TODO FIXME too much?
    (r'. It must be absent when .+$', r''), # TODO FIXME too much?

    # superfluous natural-language junk
    (r'\b((leftmost|rightmost) )?bit number\b', r'immediate'),
    (r'\bname \'C[mn]\' with \'[mn]\' ', r'immediate '),
    (r'\bimmediate byte offset\b', r'immediate'),
    (r'\bbitmask immediate\b', r'immediate'),
    (r'\bflag bit (specifier|mask) a immediate\b', r'immediate'),
    (r'\bbit position\b', r'immediate'),
    (r'\bPSTATE field name\b', r'immediate'),
    (r'\bindex extend specifier\b', r'immediate'),
    (r'\bamount by which to shift the immediate either 0 \(the default\) (\d+ )*or \d+', r'immediate defaulting to 0'),
    (r'\b((rotate|rotate|(index )?shift) )?amount\b', r'immediate'),
    (r'\b(destination|source) general-purpose register\b', r'GPR'),
    (r'\bgeneral[- ]purpose ((destination|source|base|data source|accumulator (input|output)|index) )?register\b', r'GPR'),
    (r'\bstack pointer\b', r'SP'),
    (r'\bthe name ZR( \(31\))?\b', r'ZR'),
    (r'\bprefetch operation defined as .+$', r'PREFETCH_OP ENCODED "Rt"'), # TODO FIXME special case
    (r'\blimitation on the barrier operation. Values are: .+$', r'BARRIER_SCOPE ENCODED "CRm"'), # TODO FIXME special case
    (r'\b. Where it is permitted to be optional it defaults to #0', ' DEFAULT 0'), # TODO FIXME special case
    (r'\bimmediate it must be ([^ ]+)', r'CONSTANT CONSTANT_VALUE \1'),
    (r'\b0 if omitted or as 1 if present\b', r'PRESENCE'),
    (r'\bis the (optional )?shift( type)?\b', r'is the immediate'),
    (r'\bis the (optional )?(width specifier|extension)\b', r'is the immediate'),
    (r'\bis the index extend/shift specifier\b', 'is the immediate'),
    (r'\bis the number of bits after the binary point in the fixed-point destination\b', 'is the immediate'),

    # TODO FIXME labels?
    (r'\bprogram label whose address is to be calculated\. Its offset from the address of this instruction is\b', r'immediate'),
    (r'\bprogram label to be (un)?conditionally branched to\. Its offset from the address of this instruction is\b', r'immediate'),
    (r'\bprogram label whose 4KB page address is to be calculated. Its offset from the page address of this instruction is\b', r'immediate'),
    (r'\bprogram label from which the data is. Its offset from the address of this instruction is\b', r'immediate'),

    # quote some things that really should be quoted
    (r'\b(LSL #\d+)\b', r'"\1"'),

    # more cleanup
    (r'\bnumber \[0-30\] of the GPR or ZR \(31\) ', r'immediate '),
    (r'\b64 bit name of the optional GPR\b', r'optional 64 bit name of the GPR'),
    (r'\b32 bit name of the optional GPR\b', r'optional 32 bit name of the GPR'),
    (r'\b64 bit name of the GPR or SP\b', r'XREG_SP'),
    (r'\b64 bit name of the GPR or ZR\b', r'XREG_ZR'),
    (r'\b32 bit name of the GPR or SP\b', r'WREG_SP'),
    (r'\b32 bit name of the GPR or ZR\b', r'WREG_ZR'),
    (r'\b64 bit name of the GPR\b', r'XREG_ZR'),
    (r'\b32 bit name of the GPR\b', r'WREG_ZR'),
    (r'\b128 bit name of the SIMD&FP ((source|destination|source and destination) )?register\b', r'FPREG_128'),
    (r'\b64 bit name of the SIMD&FP ((source|destination|source and destination) )?register\b', r'FPREG_64'),
    (r'\b32 bit name of the SIMD&FP ((source|destination|source and destination) )?register\b', r'FPREG_32'),
    (r'\b16 bit name of the SIMD&FP ((source|destination|source and destination) )?register\b', r'FPREG_16'),
    (r'\b8 bit name of the SIMD&FP ((source|destination|source and destination) )?register\b', r'FPREG_8'),
    (r'\bname of the SIMD&FP ((source|destination|source and destination) )?register\b', r'FPREG'),
    (r'\bnumber of the SIMD&FP ((source|destination|source and destination) )?register\b', r'immediate'),
    (r'\bname of the SIMD&FP ((source|destination|source and destination) )?register\b', r'FPREG'),
    (r' encoded in "cond" in the standard way', r' encoded in "cond"'),
    (r'^Is 1 of the standard conditions ', r'is the condition '),
    (r'\b\d+ bit (unsigned )?immediate\b', r'immediate'),
    (r'\b\d+ bit signed immediate\b', r'signed immediate'),
    (r'\b([XW]REG_(ZR|SP)) holding a immediate from \d+ to \d+ in its bottom \d+ bits\b', r'\1'),
    (r'. Defaults to X30 if absent\b', ' defaulting to \'11110\''),

    # finally make more token-y
    (r'\bsigned immediate\b', r'SIGNED_IMMEDIATE'),
    (r'\bprefetch operation encoding as a immediate\b', r'IMMEDIATE'),
    (r'\b(unsigned|positive|index) immediate\b', r'IMMEDIATE'),
    (r'\bimmediate to be applied after extension\b', r'IMMEDIATE'), # was _EXTENDEDREG
    (r'\bimmediate\b', r'IMMEDIATE'),
    (r'\bSystem register name\b', r'SYSREG'),
    (r'\bcondition\b', r'CONDITION'),
    (r' optional\b', r''), # optional-ness should be encoded in the asmtemplate
    (r'^is the ', r'TYPE '),
    (r' (encoded )?in (the )?', r' ENCODED '),
    (r'" as ', r'" EXPR '),
    (r' a multiple of ', r' MULTIPLE_OF '),
    (r' defaulting to ', r' DEFAULT '),

    (r'\s+', r' '), # normalise multiple whitespace
    (r'^\s', r''), # leading whitespace
    (r'\s$', r''), # trailing whitespace
]

rewrites = [(re.compile(regex), rep) for regex, rep in rewrites]
