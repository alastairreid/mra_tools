open Core.Std
open Lexer
open Lexing

open Parser
(* open Asl_parser_pp *)
open Lexersupport
open Asl_ast

let _ =
    let lexbuf = Lexing.from_channel stdin in
    try
        let lexer = offside_token Lexer.token in
        ignore (Parser.main lexer lexbuf);
        (* printf "%s" (pp_raw_declarations decls) *)
        printf "Done\n"
    with Parser.Error -> begin
        let curr = lexbuf.Lexing.lex_curr_p in
        let line = curr.Lexing.pos_lnum in
        let cnum = curr.Lexing.pos_cnum - curr.Lexing.pos_bol in
        let tok = Lexing.lexeme lexbuf in
        printf "Parser error at %d.%d '%s'\n" line cnum tok
    end
