val roundtrip : string -> unit effect pure

function roundtrip s = {
         print_string(s, " =>");
         print_string("                ", assembly(assembly(s)));
}

val main : unit -> unit effect pure

function main () = {
         roundtrip("DSB SY");
         roundtrip("ADD SP, SP, X21");
         roundtrip("ADD SP, X21, X2");
         roundtrip("ADD X1, SP, X2");
         roundtrip("ADD X0, X1, X2, UXTX #0");
         roundtrip("ADDS X1, SP, X2");
         roundtrip("ADD X1, SP, X0, SXTX");
         roundtrip("ADDS X1, SP, X0, SXTX #0");
         roundtrip("ADD SP, SP, X2, LSL #0");
         roundtrip("ADD SP, SP, X2, UXTX #0");
         roundtrip("ADD WSP, WSP, W2, UXTW");
         roundtrip("ADC X0, X1, X2");
         roundtrip("ADD X0, X1, X2");
         roundtrip("AND SP, X0, #0");
         roundtrip("B.EQ #4");
         roundtrip("MRS X0, S2_1_C2_C3_4");
         print("done.")
}
