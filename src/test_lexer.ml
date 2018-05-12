open Core
open Lexer
open Lexing

open Parser
open Lexersupport

let _ =
    let lexbuf = Lexing.from_channel In_channel.stdin in
    try
        let lexer = offside_token Lexer.token in
        (* let lexer = Lexer.token in *)
        while true do
            let t = lexer lexbuf in
            let curr = lexbuf.Lexing.lex_curr_p in
            let line = curr.Lexing.pos_lnum in
            let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
            printf "Token %d.%d %s\n" line cnum (string_of_token t);
            if t = EOF then exit 0
        done
    with Parser.Error -> begin
        let curr = lexbuf.Lexing.lex_curr_p in
        let line = curr.Lexing.pos_lnum in
        let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
        let tok = Lexing.lexeme lexbuf in
        printf "Parser error at %d.%d '%s'\n" line cnum tok
    end
