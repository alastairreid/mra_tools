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

mapping asm_sysreg : bits(15) <-> string = {
// TODO FIXME
  0b000000000000000 <-> "something",
  0b0 : bits(1) @ op1 : bits(3) @ CRn : bits(4) @ CRm : bits(4) @ op2 : bits(3) <-> "S2_" ^ bits3_str(op1) ^ "_C" ^ bits4_str(CRn) ^ "_C" ^ bits4_str(CRm) ^ "_" ^ bits3_str(op2),
  0b1 : bits(1) @ op1 : bits(3) @ CRn : bits(4) @ CRm : bits(4) @ op2 : bits(3) <-> "S3_" ^ bits3_str(op1) ^ "_C" ^ bits4_str(CRn) ^ "_C" ^ bits4_str(CRm) ^ "_" ^ bits3_str(op2)
}


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

/*
val casp_hack_wplusone_forwards : bits(5) -> string
function casp_hack_wplusone_forwards arg = match arg {
  Rn => asm_wreg_zr(Rn) ^ "," ^ def_spc() ^ asm_wreg_zr(Rn + 1)
}
val casp_hack_wplusone_forwards_matches : bits(5) -> bool
function casp_hack_wplusone_forwards_matches arg = match arg {
  Rn => true
}
val casp_hack_wplusone_backwards : string -> bits(5)
function casp_hack_wplusone_backwards arg = match arg {
  asm_wreg_zr(Rn) ^ "," ^ def_spc() ^ asm_wreg_zr(Rm) if Rm == Rn + 1 => Rn
}
val casp_hack_wplusone_backwards_matches : string -> bool
function casp_hack_wplusone_backwards_matches arg = match arg {
  asm_wreg_zr(Rn) ^ "," ^ def_spc() ^ asm_wreg_zr(Rm) if Rm == Rn + 1 => true,
  _ => false
}
*/
