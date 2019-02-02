/* Note that these have to be in reverse order because some are prefixes of others. */
mapping asm_wreg_zr : bits(5) <-> string = {
  0b11111 <-> "WZR",
  0b11110 <-> "W30",
  0b11101 <-> "W29",
  0b11100 <-> "W28",
  0b11011 <-> "W27",
  0b11010 <-> "W26",
  0b11001 <-> "W25",
  0b11000 <-> "W24",
  0b10111 <-> "W23",
  0b10110 <-> "W22",
  0b10101 <-> "W21",
  0b10100 <-> "W20",
  0b10011 <-> "W19",
  0b10010 <-> "W18",
  0b10001 <-> "W17",
  0b10000 <-> "W16",
  0b01111 <-> "W15",
  0b01110 <-> "W14",
  0b01101 <-> "W13",
  0b01100 <-> "W12",
  0b01011 <-> "W11",
  0b01010 <-> "W10",
  0b01001 <-> "W9",
  0b01000 <-> "W8",
  0b00111 <-> "W7",
  0b00110 <-> "W6",
  0b00101 <-> "W5",
  0b00100 <-> "W4",
  0b00011 <-> "W3",
  0b00010 <-> "W2",
  0b00001 <-> "W1",
  0b00000 <-> "W0"
}

mapping asm_xreg_zr : bits(5) <-> string = {
  0b11111 <-> "ZR",
  0b11111 <-> "XZR",
  0b11110 <-> "X30",
  0b11101 <-> "X29",
  0b11100 <-> "X28",
  0b11011 <-> "X27",
  0b11010 <-> "X26",
  0b11001 <-> "X25",
  0b11000 <-> "X24",
  0b10111 <-> "X23",
  0b10110 <-> "X22",
  0b10101 <-> "X21",
  0b10100 <-> "X20",
  0b10011 <-> "X19",
  0b10010 <-> "X18",
  0b10001 <-> "X17",
  0b10000 <-> "X16",
  0b01111 <-> "X15",
  0b01110 <-> "X14",
  0b01101 <-> "X13",
  0b01100 <-> "X12",
  0b01011 <-> "X11",
  0b01010 <-> "X10",
  0b01001 <-> "X9",
  0b01000 <-> "X8",
  0b00111 <-> "X7",
  0b00110 <-> "X6",
  0b00101 <-> "X5",
  0b00100 <-> "X4",
  0b00011 <-> "X3",
  0b00010 <-> "X2",
  0b00001 <-> "X1",
  0b00000 <-> "X0"
}

mapping asm_wreg_sp : bits(5) <-> string = {
  0b11111 <-> "WSP",
  0b11110 <-> "W30",
  0b11101 <-> "W29",
  0b11100 <-> "W28",
  0b11011 <-> "W27",
  0b11010 <-> "W26",
  0b11001 <-> "W25",
  0b11000 <-> "W24",
  0b10111 <-> "W23",
  0b10110 <-> "W22",
  0b10101 <-> "W21",
  0b10100 <-> "W20",
  0b10011 <-> "W19",
  0b10010 <-> "W18",
  0b10001 <-> "W17",
  0b10000 <-> "W16",
  0b01111 <-> "W15",
  0b01110 <-> "W14",
  0b01101 <-> "W13",
  0b01100 <-> "W12",
  0b01011 <-> "W11",
  0b01010 <-> "W10",
  0b01001 <-> "W9",
  0b01000 <-> "W8",
  0b00111 <-> "W7",
  0b00110 <-> "W6",
  0b00101 <-> "W5",
  0b00100 <-> "W4",
  0b00011 <-> "W3",
  0b00010 <-> "W2",
  0b00001 <-> "W1",
  0b00000 <-> "W0"
}

mapping asm_xreg_sp : bits(5) <-> string = {
  0b11111 <-> "SP",
  0b11111 <-> "XSP",
  0b11110 <-> "X30",
  0b11101 <-> "X29",
  0b11100 <-> "X28",
  0b11011 <-> "X27",
  0b11010 <-> "X26",
  0b11001 <-> "X25",
  0b11000 <-> "X24",
  0b10111 <-> "X23",
  0b10110 <-> "X22",
  0b10101 <-> "X21",
  0b10100 <-> "X20",
  0b10011 <-> "X19",
  0b10010 <-> "X18",
  0b10001 <-> "X17",
  0b10000 <-> "X16",
  0b01111 <-> "X15",
  0b01110 <-> "X14",
  0b01101 <-> "X13",
  0b01100 <-> "X12",
  0b01011 <-> "X11",
  0b01010 <-> "X10",
  0b01001 <-> "X9",
  0b01000 <-> "X8",
  0b00111 <-> "X7",
  0b00110 <-> "X6",
  0b00101 <-> "X5",
  0b00100 <-> "X4",
  0b00011 <-> "X3",
  0b00010 <-> "X2",
  0b00001 <-> "X1",
  0b00000 <-> "X0"
}

mapping reg_n_or_zr : bits(5) <-> string = {
  0b11111 <-> "ZR",
  0b11110 <-> "30",
  0b11101 <-> "29",
  0b11100 <-> "28",
  0b11011 <-> "27",
  0b11010 <-> "26",
  0b11001 <-> "25",
  0b11000 <-> "24",
  0b10111 <-> "23",
  0b10110 <-> "22",
  0b10101 <-> "21",
  0b10100 <-> "20",
  0b10011 <-> "19",
  0b10010 <-> "18",
  0b10001 <-> "17",
  0b10000 <-> "16",
  0b01111 <-> "15",
  0b01110 <-> "14",
  0b01101 <-> "13",
  0b01100 <-> "12",
  0b01011 <-> "11",
  0b01010 <-> "10",
  0b01001 <-> "9",
  0b01000 <-> "8",
  0b00111 <-> "7",
  0b00110 <-> "6",
  0b00101 <-> "5",
  0b00100 <-> "4",
  0b00011 <-> "3",
  0b00010 <-> "2",
  0b00001 <-> "1",
  0b00000 <-> "0"
}

mapping sep : unit <-> string = {
  () <-> opt_spc() ^ "," ^ def_spc()
}

mapping asm_extendedreg_hack_optional_imm3 : bits(3) <-> string = {
  (0b000) <-> "" if false /* hack */,
  (imm3) <-> spc() ^ "#" ^ hex_bits_3(imm3),
  (0b000)  <-> ""
}

mapping asm_extendedreg_hack_optional_lsl_imm3 : bits(3) <-> string = {
  (0b000) <-> "" if false /* hack */,
  (imm3) <-> sep() ^ "LSL #" ^ hex_bits_3(imm3),
  (0b000)  <-> ""
}

                                        /* Rn,  option,      Rm,    imm3 */
mapping asm_extendedreg_hack_oneSP_64 : (bits(5), bits(3), bits(5), bits(3)) <-> string = {
  (0b11111, 0b011, Rm, 0b000) <->            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) if false, // special case: Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (0b11111, 0b011, Rm, imm3) <->            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (     Rn, 0b000, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b001, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b010, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b011, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b100, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b101, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b110, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b111, Rm, imm3) <-> asm_xreg_sp(Rn) ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (0b11111, 0b011, Rm, 0b000) <->            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) // special case: Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
}

                                        /*    Rd,      Rn,  option,      Rm,    imm3 */
mapping asm_extendedreg_hack_twoSP_64 : (bits(5), bits(5), bits(3), bits(5), bits(3)) <-> string = {
  (0b11111, 0b11111, 0b011, Rm, 0b000) <->            "SP" ^ sep() ^            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) if false, // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (0b11111,      Rn, 0b011, Rm, 0b000) <->            "SP" ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "X" ^ reg_n_or_zr(Rm) if false, // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (     Rd, 0b11111, 0b011, Rm, 0b000) <-> asm_xreg_sp(Rd) ^ sep() ^            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) if false,// special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  
  (0b11111, 0b11111, 0b011, Rm, imm3) <->            "SP" ^ sep() ^            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (0b11111,      Rn, 0b011, Rm, imm3) <->            "SP" ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (     Rd, 0b11111, 0b011, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  
  (     Rd,      Rn, 0b000, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b001, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b010, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b011, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b100, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b101, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b110, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b111, Rm, imm3) <-> asm_xreg_sp(Rd) ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "X" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),

  (0b11111, 0b11111, 0b011, Rm, 0b000) <->            "SP" ^ sep() ^            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm), // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (0b11111,      Rn, 0b011, Rm, 0b000) <->            "SP" ^ sep() ^ asm_xreg_sp(Rn) ^ sep() ^ "X" ^ reg_n_or_zr(Rm), // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
  (     Rd, 0b11111, 0b011, Rm, 0b000) <-> asm_xreg_sp(Rd) ^ sep() ^            "SP" ^ sep() ^ "X" ^ reg_n_or_zr(Rm) // special case: Rd == SP || Rn == SP -> LSL as alias for UXTX, omittable if LSL #0
}

                                        /* Rn,  option,      Rm,    imm3 */
mapping asm_extendedreg_hack_oneSP_32 : (bits(5), bits(3), bits(5), bits(3)) <-> string = {
  (0b11111, 0b010, Rm, 0b000) <->            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) if false, // special case: Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (0b11111, 0b010, Rm, imm3) <->            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (     Rn, 0b000, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b001, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b010, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b011, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b100, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b101, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b110, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rn, 0b111, Rm, imm3) <-> asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (0b11111, 0b010, Rm, 0b000) <->            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) // special case: Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
}

                                        /*    Rd,      Rn,  option,      Rm,    imm3 */
mapping asm_extendedreg_hack_twoSP_32 : (bits(5), bits(5), bits(3), bits(5), bits(3)) <-> string = {
  (0b11111, 0b11111, 0b010, Rm, 0b000) <->            "WSP" ^ sep() ^            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) if false, // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (0b11111,      Rn, 0b010, Rm, 0b000) <->            "WSP" ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) if false, // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (     Rd, 0b11111, 0b010, Rm, 0b000) <-> asm_wreg_sp(Rd) ^ sep() ^            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) if false, // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  
  (0b11111, 0b11111, 0b010, Rm, imm3) <->            "WSP" ^ sep() ^            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (0b11111,      Rn, 0b010, Rm, imm3) <->            "WSP" ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (     Rd, 0b11111, 0b010, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "LSL" ^ spc() ^ "#" ^ hex_bits_3(imm3), // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  
  (     Rd,      Rn, 0b000, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b001, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b010, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b011, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "UXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b100, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTB" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b101, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTH" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b110, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTW" ^ asm_extendedreg_hack_optional_imm3(imm3),
  (     Rd,      Rn, 0b111, Rm, imm3) <-> asm_wreg_sp(Rd) ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm) ^ sep() ^ "SXTX" ^ asm_extendedreg_hack_optional_imm3(imm3),

  (0b11111, 0b11111, 0b010, Rm, 0b000) <->            "WSP" ^ sep() ^            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm), // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (0b11111,      Rn, 0b010, Rm, 0b000) <->            "WSP" ^ sep() ^ asm_wreg_sp(Rn) ^ sep() ^ "W" ^ reg_n_or_zr(Rm), // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
  (     Rd, 0b11111, 0b010, Rm, 0b000) <-> asm_wreg_sp(Rd) ^ sep() ^            "WSP" ^ sep() ^ "W" ^ reg_n_or_zr(Rm) // special case: Rd == WSP || Rn == WSP -> LSL as alias for UXTW, omittable if LSL #0
}

mapping asm_barrier_scope : bits(4) <-> string = {
  0b1111 <-> "SY",
  0b1110 <-> "ST",
  0b1101 <-> "LD",
  0b1010 <-> "ISHST",
  0b1001 <-> "ISHLD",
  0b1011 <-> "ISH",
  0b0110 <-> "NSHST",
  0b0101 <-> "NSHLD",
  0b0111 <-> "NSH",
  0b0010 <-> "OSHST",
  0b0001 <-> "OSHLD",
  0b0011 <-> "OSH"
}

mapping asm_prefetch_type : bits(2) <-> string = {
  0b00 <-> "PLD",
  0b01 <-> "PLI",
  0b10 <-> "PST"
}

mapping asm_prefetch_target : bits(2) <-> string = {
  0b00 <-> "L1",
  0b01 <-> "L2",
  0b10 <-> "L3"
}

mapping asm_prefetch_policy : bits(1) <-> string = {
  0b0 <-> "KEEP",
  0b1 <-> "STRM"
}

mapping asm_prefetch_op : bits(5) <-> string = {
  (ty:bits(2))@(ta:bits(2))@(po:bits(1)) <-> asm_prefetch_type(ty) ^ asm_prefetch_target(ta) ^ asm_prefetch_policy(po)
}

/* These are needed because ocaml int_of_string, normally used in hex_bits_N, also consumes underscores */
mapping bits3_str : bits(3) <-> string = {
  0b111 <-> "7",
  0b110 <-> "6",
  0b101 <-> "5",
  0b100 <-> "4",
  0b011 <-> "3",
  0b010 <-> "2",
  0b001 <-> "1",
  0b000 <-> "0"
}
mapping bits4_str : bits(4) <-> string = {
  0b1111 <-> "15",
  0b1110 <-> "14",
  0b1101 <-> "13",
  0b1100 <-> "12",
  0b1011 <-> "11",
  0b1010 <-> "10",
  0b1001 <-> "9",
  0b1000 <-> "8",
  0b0111 <-> "7",
  0b0110 <-> "6",
  0b0101 <-> "5",
  0b0100 <-> "4",
  0b0011 <-> "3",
  0b0010 <-> "2",
  0b0001 <-> "1",
  0b0000 <-> "0"
}

val asm_sysreg : bits(15) <-> string

scattered mapping asm_sysreg

$include "asm_sysregs.sail"

mapping clause asm_sysreg = 0b0 : bits(1) @ op1 : bits(3) @ CRn : bits(4) @ CRm : bits(4) @ op2 : bits(3) <-> "S2_" ^ bits3_str(op1) ^ "_C" ^ bits4_str(CRn) ^ "_C" ^ bits4_str(CRm) ^ "_" ^ bits3_str(op2)
mapping clause asm_sysreg = 0b1 : bits(1) @ op1 : bits(3) @ CRn : bits(4) @ CRm : bits(4) @ op2 : bits(3) <-> "S3_" ^ bits3_str(op1) ^ "_C" ^ bits4_str(CRn) ^ "_C" ^ bits4_str(CRm) ^ "_" ^ bits3_str(op2)

end asm_sysreg


mapping asm_condition : bits(4) <-> string = {
  0b0000 <-> "EQ",
  0b0001 <-> "NE",
  0b0010 <-> "CS",
  0b0010 <-> "HS",
  0b0011 <-> "CC",
  0b0011 <-> "LO",
  0b0100 <-> "MI",
  0b0101 <-> "PL",
  0b0110 <-> "VS",
  0b0111 <-> "VC",
  0b1000 <-> "HI",
  0b1001 <-> "LS",
  0b1010 <-> "GE",
  0b1011 <-> "LT",
  0b1100 <-> "GT",
  0b1101 <-> "LE",
  0b1110 <-> "AL",
  0b1111 <-> "NV"
}

mapping asm_inverted_condition : bits(4) <-> string = {
  0b0000 <-> "NE",
  0b0001 <-> "EQ",
  0b0010 <-> "HS",
  0b0010 <-> "CS",
  0b0011 <-> "LO",
  0b0011 <-> "CC",
  0b0100 <-> "PL",
  0b0101 <-> "MI",
  0b0110 <-> "VC",
  0b0111 <-> "VS",
  0b1000 <-> "LS",
  0b1001 <-> "HI",
  0b1010 <-> "LT",
  0b1011 <-> "GE",
  0b1100 <-> "LE",
  0b1101 <-> "GT",
  0b1110 <-> "NV",
  0b1111 <-> "AL"
}


mapping label_hack_16 : bits(16) <-> string = {
  bv <-> "#" ^ hex_bits_16(bv)
}

mapping label_hack_21 : bits(21) <-> string = {
  bv <-> "#" ^ hex_bits_21(bv)
}

mapping label_hack_28 : bits(28) <-> string = {
  bv <-> "#" ^ hex_bits_28(bv)
}

mapping label_hack_33 : bits(33) <-> string = {
  bv <-> "#" ^ hex_bits_33(bv)
}

val casp_hack_wplusone : bits(5) <-> string
val casp_hack_xplusone : bits(5) <-> string

mapping casp_hack_wplusone = {
   Rn => asm_wreg_zr(Rn) ^ "," ^ def_spc() ^ asm_wreg_zr(Rn + 1),
   asm_wreg_zr(Rn) ^ "," ^ def_spc() ^ asm_wreg_zr(Rm) if Rm == Rn + 1 <- Rn
}

mapping casp_hack_xplusone = {
   Rn => asm_xreg_zr(Rn) ^ "," ^ def_spc() ^ asm_xreg_zr(Rn + 1),
   asm_xreg_zr(Rn) ^ "," ^ def_spc() ^ asm_xreg_zr(Rm) if Rm == Rn + 1 <- Rn
}

mapping movewide_imm_hack_32 : (bits(16), bits(2)) <-> string = {
  (imm16, 0b00) <-> hex_bits_16(imm16),
  (imm16, 0b01) <-> hex_bits_32(imm16 @ 0x0000)
}

mapping movewide_imm_hack_64 : (bits(16), bits(2)) <-> string = {
  (imm16, 0b00) <-> hex_bits_16(imm16),
  (imm16, 0b01) <-> hex_bits_32(imm16 @ 0x0000),
  (imm16, 0b10) <-> hex_bits_48(imm16 @ 0x00000000),
  (imm16, 0b11) <-> hex_bits_64(imm16 @ 0x000000000000)
}

mapping movewide_inverted_imm_hack_32 : (bits(16), bits(2)) <-> string = {
  (imm16, 0b00) => hex_bits_16(not_vec(imm16)),
  hex_bits_16(imm16) <- (not_vec(imm16), 0b00),
  (imm16, 0b01) => hex_bits_32(not_vec(imm16) @ 0xFFFF),
  hex_bits_32(imm16 : bits(16) @ 0xFFFF) <- (not_vec(imm16), 0b01)
}

mapping movewide_inverted_imm_hack_64 : (bits(16), bits(2)) <-> string = {
  (imm16, 0b00) => hex_bits_16(not_vec(imm16)),
  hex_bits_16(imm16) <- (not_vec(imm16), 0b00),
  (imm16, 0b01) => hex_bits_32(not_vec(imm16) @ 0xFFFF),
  hex_bits_32(imm16 : bits(16) @ 0xFFFF) <- (not_vec(imm16), 0b01),
  (imm16, 0b10) => hex_bits_48(not_vec(imm16) @ 0xFFFFFFFF),
  hex_bits_48(imm16 : bits(16) @ 0xFFFFFFFF) <- (not_vec(imm16), 0b10),
  (imm16, 0b11) => hex_bits_64(not_vec(imm16) @ 0xFFFFFFFFFFFF),
  hex_bits_64(imm16 : bits(16) @ 0xFFFFFFFFFFFF) <- (not_vec(imm16), 0b11)
}

mapping lsl_shift_hack_32 : (bits(6), bits(6)) <-> string = {
  (0b0 @ shift : bits(5), imms) if imms == to_bits(6, 31 - unsigned(shift)) => hex_bits_5(shift),
  hex_bits_5(shift) <- (0b0 @ shift, to_bits(6, 31 - unsigned(shift)))
}

mapping lsl_shift_hack_64 : (bits(6), bits(6)) <-> string = {
  (shift, imms) if imms == to_bits(6, 63 - unsigned(shift)) => hex_bits_6(shift),
  hex_bits_6(shift) <- (shift, to_bits(6, 63 - unsigned(shift)))
}

mapping lsb_width_hack : (bits(6), bits(6)) <-> string = {
  (immr, imms) => "#" ^ hex_bits_6(immr) ^ sep() ^ "#" ^ string_of_int(unsigned(imms) - unsigned(immr) + 1),
  "#" ^ hex_bits_6(lsb) ^ sep() ^ "#" ^ hex_bits_6(width) <- (lsb, to_bits(6, unsigned(lsb) + unsigned(width) - 1))
}

mapping matching_Wn : (bits(5), bits(5)) <-> string = {
  (Rn, Rm) if Rn == Rm => asm_wreg_zr(Rn),
  asm_wreg_zr(Rn) <- (Rn, Rn)
}

mapping matching_Xn : (bits(5), bits(5)) <-> string = {
  (Rn, Rm) if Rn == Rm => asm_xreg_zr(Rn),
  asm_xreg_zr(Rn) <- (Rn, Rn)
}

mapping lsb_mod_hack_32 : (bits(6), bits(6)) <-> string = {
  (0b1 @ immr : bits(5), imms) => "#" ^ string_of_int(negate(unsigned(immr))) ^ sep() ^ "#" ^ string_of_int(unsigned(imms) + 1),
  "#" ^ hex_bits_5(lsb) ^ sep() ^ "#" ^ hex_bits_6(width) <- (to_bits(6, negate(unsigned(lsb))), to_bits(6, unsigned(width) - 1))
}

mapping lsb_mod_hack_64 : (bits(6), bits(6)) <-> string = {
  (immr, imms) => "#" ^ string_of_int(negate(unsigned(immr))) ^ sep() ^ "#" ^ string_of_int(unsigned(imms) + 1),
  "#" ^ hex_bits_6(lsb) ^ sep() ^ "#" ^ hex_bits_6(width) <- (to_bits(6, negate(unsigned(lsb))), to_bits(6, unsigned(width) - 1))
}

/* Temporary prelude stuff for testing until we have full ASL parsing */
val HighestSetBit : forall ('N : Int), 'N >= 2. bits('N) -> int

function HighestSetBit x = {
  foreach (i from ('N - 1) to 0 by 1 in dec)
    if [x[i]] == 0b1 then return(i) else ();
  return(negate(1))
}

val Zeros__0 : forall ('N : Int), 'N >= 0. atom('N) -> bits('N)

val Zeros__1 : forall ('N : Int), 'N >= 0. unit -> bits('N)

overload Zeros = {Zeros__0, Zeros__1}

function Zeros__0 N = return(replicate_bits(0b0, 'N))

function Zeros__1 () = return(Zeros('N))

val Ones__0 : forall ('N : Int), 'N >= 0. atom('N) -> bits('N)

val Ones__1 : forall ('N : Int), 'N >= 0. unit -> bits('N)

overload Ones = {Ones__0, Ones__1}

function Ones__0 N = return(replicate_bits(0b1, 'N))

function Ones__1 () = return(Ones('N))

val DecodeBitMasks : forall ('M : Int), 1 >= 0 & 6 >= 0 & 6 >= 0 & 'M >= 0 & 'M >= 0.
  (bits(1), bits(6), bits(6), bool) -> (bits('M), bits('M)) effect {escape/*, rreg, undef, wreg*/}

val ZeroExtend__0 : forall ('M : Int) ('N : Int), 'M >= 0 & 'N >= 0 & 'N >= 'M.
  (bits('M), atom('N)) -> bits('N) effect pure

val ZeroExtend__1 : forall ('M : Int) ('N : Int), 'M >= 0 & 'N >= 0 & 'N >= 'M.
  bits('M) -> bits('N) effect pure

overload ZeroExtend = {ZeroExtend__0, ZeroExtend__1}

function ZeroExtend__0 (x, N) = {
//  assert('N >= 'M);
  return(Zeros('N - 'M) @ x)
}

function ZeroExtend__1 x = return(ZeroExtend(x, 'N))


function DecodeBitMasks (immN, imms, immr, immediate) = {
/*  tmask : bits(64) = undefined;
  wmask : bits(64) = undefined;
  tmask_and : bits(6) = undefined;
  wmask_and : bits(6) = undefined;
  tmask_or : bits(6) = undefined;
  wmask_or : bits(6) = undefined;
  levels : bits(6) = undefined;*/
  let 'len = HighestSetBit(immN @ ~(imms));
  assert('len >= 0);
  assert('len > 1);
  //if len < 1 then ReservedValue() else ();
  assert('M >= shl_int(1, len), "(M >= (1 << len))");
  assert(len <= 6);
  levels = ZeroExtend(Ones(len), 6);
  //if immediate & (imms & levels) == levels then ReservedValue() else ();
  S : int = unsigned(imms & levels);
  R : int = unsigned(immr & levels);
  diff : int = S - R;
  tmask_and = __GetSlice_int(6, diff, 0) | ~(levels);
  tmask_or = __GetSlice_int(6, diff, 0) & levels;
  tmask = Ones(64);
  tmask = tmask & replicate_bits(replicate_bits([tmask_and[0]], 1) @ Ones(1), 32) | replicate_bits(Zeros(1) @ replicate_bits([tmask_or[0]], 1), 32);
  tmask = tmask & replicate_bits(replicate_bits([tmask_and[1]], 2) @ Ones(2), 16) | replicate_bits(Zeros(2) @ replicate_bits([tmask_or[1]], 2), 16);
  tmask = tmask & replicate_bits(replicate_bits([tmask_and[2]], 4) @ Ones(4), 8) | replicate_bits(Zeros(4) @ replicate_bits([tmask_or[2]], 4), 8);
  tmask = tmask & replicate_bits(replicate_bits([tmask_and[3]], 8) @ Ones(8), 4) | replicate_bits(Zeros(8) @ replicate_bits([tmask_or[3]], 8), 4);
  tmask = tmask & replicate_bits(replicate_bits([tmask_and[4]], 16) @ Ones(16), 2) | replicate_bits(Zeros(16) @ replicate_bits([tmask_or[4]], 16), 2);
  tmask = tmask & replicate_bits(replicate_bits([tmask_and[5]], 32) @ Ones(32), 1) | replicate_bits(Zeros(32) @ replicate_bits([tmask_or[5]], 32), 1);
  wmask_and = immr | ~(levels);
  wmask_or = immr & levels;
  wmask = Zeros(64);
  wmask = wmask & replicate_bits(Ones(1) @ replicate_bits([wmask_and[0]], 1), 32) | replicate_bits(replicate_bits([wmask_or[0]], 1) @ Zeros(1), 32);
  wmask = wmask & replicate_bits(Ones(2) @ replicate_bits([wmask_and[1]], 2), 16) | replicate_bits(replicate_bits([wmask_or[1]], 2) @ Zeros(2), 16);
  wmask = wmask & replicate_bits(Ones(4) @ replicate_bits([wmask_and[2]], 4), 8) | replicate_bits(replicate_bits([wmask_or[2]], 4) @ Zeros(4), 8);
  wmask = wmask & replicate_bits(Ones(8) @ replicate_bits([wmask_and[3]], 8), 4) | replicate_bits(replicate_bits([wmask_or[3]], 8) @ Zeros(8), 4);
  wmask = wmask & replicate_bits(Ones(16) @ replicate_bits([wmask_and[4]], 16), 2) | replicate_bits(replicate_bits([wmask_or[4]], 16) @ Zeros(16), 2);
  wmask = wmask & replicate_bits(Ones(32) @ replicate_bits([wmask_and[5]], 32), 1) | replicate_bits(replicate_bits([wmask_or[5]], 32) @ Zeros(32), 1);
  if __GetSlice_int(1, diff, 6) != 0b0 then wmask = wmask & tmask
  else wmask = wmask | tmask;
  return((slice(wmask, 0, 'M), slice(tmask, 0, 'M)))
}

/* End temporary stuff */

val _ror : forall 'regSize 'n 'k, 'k >= 0. (atom('regSize), atom('n), atom('k)) -> int effect {escape}
function _ror (regSize, n, k) = {
  let k = k % regSize;
  assert(k >= 0);
  if k == 0 then n else {
    let d = unsigned(__GetSlice_int(k, n, 0));
    lor_int(shl_int(d, (regSize - k)), shr_int(n, k))
  }
}

val _next : (bits(1), int) -> int effect pure
function _next (b, n) = {
  if __GetSlice_int(1, n, 0) == b then 0
  else 1 + _next(b, shr_int(n, 1))
}

val EncodeBitMasks : forall 'regSize, 'regSize >= 0. (atom('regSize), int) -> option((bits(1), bits(6), bits(6))) effect {escape}
function EncodeBitMasks (regSize, imm) = {
  //print_int("EncodeBitMasks called with ", imm);
  //print_bits("(in bits) ", to_bits('regSize, imm));
  if imm == 0 then None() // 0 is disallowed
  else if imm == (shl_int(1, regSize) - 1) then None() // all 1s is disallowed
  else {
    let pref0 = _next(0b1, imm); // the length of 0s prefix of imm
    let (e, ones, rotate) : (int, int, int) = {
      if pref0 == 0 then {
        let pref1 = _next(0b0, imm); // the length of 1s prefix of imm
        assert(pref1 >= 0);
        let run0 = _next(0b1, _ror(regSize, imm, pref1)); // the length of the first 0s run
        assert(run0 >= 0);
        let run1 = _next(0b0, _ror(regSize, imm, (pref1 + run0))); // the length of the first non-prefix 1s run
        (run0 + run1, run1, run1 - pref1)
      } else {
        assert(pref0 >= 0);
        let run1 = _next(0b0, _ror(regSize, imm, pref0)); // the length of the first 1s run
        assert(run1 >= 0);
        let run0 = _next(0b1, _ror(regSize, imm, (pref0 + run1))); // the length of the first non-prefix 0s run
        (run0 + run1, run1, run0 + run1 - pref0)
      }
    };
    let (N, imms, immr) : (bits(1), bits(6), bits(6)) = {
      if e == 64 then (0b1, to_bits(6, ones - 1), to_bits(6, rotate))
      else (0b0, or_vec(not_vec(to_bits(6, 2 * e - 1)), to_bits(6, ones - 1)), to_bits(6, rotate))
    };
    //print_bits("=== got N = ", N);
    //print_bits("     imms = ", imms);
    //print_bits("     immr = ", immr);
    match DecodeBitMasks(N, imms, immr, true) : (bits('regSize), bits('regSize)) {
      (wmask, _) if unsigned(wmask) == imm => {
        //print("and decode concurred.");
        Some((N, imms, immr))
      },
      (wmask, _) => {
        //print_bits("but decode said ", wmask);
        //print_bits("while we had    ", to_bits('regSize, imm));
        //print_int("which was ", imm);
        //print_int("and regSize = ", 'regSize);
        None()
      }
    }
  }
}

function valid_bitmask (M : nat, N : bits(1), imms : bits(6), immr : bits(6)) -> bool = {
  let 'len = HighestSetBit(N@not_vec(imms));
  if 'len < 1 | M < (shl_int(1, 'len))
  then false
  else {
    let ones : bits('len) = Ones('len);
    if len > 6 then
      false
    else {
      let levels = ZeroExtend(ones, 6);
      if and_vec(imms, levels) == levels then
        false
      else
        true
    }
  }
}

mapping asm_bitmask_immediate_32 : bits(13) <-> string = {
  N : bits(1) @ imms : bits(6) @ immr : bits(6) if valid_bitmask(32, N, imms, immr) =>
    match DecodeBitMasks(N, imms, immr, true) : (bits(32), bits(32)) { (imm, _) => BitStr(imm) },

  hex_bits_32(imm) if match EncodeBitMasks(32, unsigned(imm)) { Some(_, _, _) => true, None() => false }
    <- match EncodeBitMasks(32, unsigned(imm)) { Some(N, imms, immr) => N @ imms @ immr }
}

mapping asm_bitmask_immediate_64 : bits(13) <-> string = {
  N : bits(1) @ imms : bits(6) @ immr : bits(6) if valid_bitmask(64, N, imms, immr) =>
    match DecodeBitMasks(N, imms, immr, true) : (bits(64), bits(64)) { (imm, _) => BitStr(imm) },

  hex_bits_64(imm) if match EncodeBitMasks(64, unsigned(imm)) { Some(_, _, _) => true, None() => false }
    <- match EncodeBitMasks(64, unsigned(imm)) { Some(N, imms, immr) => N @ imms @ immr }
}
