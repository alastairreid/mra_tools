open Core.Std
open Lexer
open Lexing
open Parser

let string_of_token (t: Parser.token): string =
    ( match t with
    | AMP       -> "amp"
    | AMPAMP    -> "ampamp"
    | AND       -> "and"
    | ARRAY     -> "array"
    | ASSERT    -> "assert"
    | BANG      -> "bang"
    | BARBAR    -> "barbar"
    | BIN(x)    -> "bin:"^x
    | BUILTIN   -> "builtin"
    | CARET     -> "caret"
    | CASE      -> "case"
    | COLON     -> "colon"
    | COMMA     -> "comma"
    | CONSTANT  -> "constant"
    | DEDENT    -> "dedent"
    | DIV       -> "div"
    | DO        -> "do"
    | DOT       -> "dot"
    | DOTDOT    -> "dotdot"
    | DOWNTO    -> "downto"
    | ELSE      -> "else"
    | ELSIF     -> "elsif"
    | ENUM      -> "enum"
    | EOF       -> "eof"
    | EOL       -> "eol"
    | EOR       -> "eor"
    | EQ        -> "eq"
    | EQEQ      -> "eqeq"
    | FAIL      -> "fail"
    | FLOAT(x)  -> "float:"^x
    | FOR       -> "for"
    | GT        -> "gt"
    | GTEQ      -> "gteq"
    | GTGT      -> "gtgt"
    | HEX(x)    -> "hex:"^x
    | IDENT(x)  -> "ident:"^x
    | IF        -> "if"
    | IMPDEF    -> "impdef"
    | IN        -> "in"
    | INDENT    -> "indent"
    | INT(x)    -> "int:" ^ string_of_int x
    | IS        -> "is"
    | LBRACE    -> "lbrace"
    | LBRACK    -> "lbrack"
    | LPAREN    -> "lparen"
    | LT        -> "lt"
    | LTEQ      -> "lteq"
    | LTLT      -> "ltlt"
    | MASK(x)   -> "mask:"^x
    | MINUS     -> "minus"
    | MOD       -> "mod"
    | NEQ       -> "neq"
    | NOT       -> "not"
    | OF        -> "of"
    | OR        -> "or"
    | OTHERWISE -> "otherwise"
    | PLUS      -> "plus"
    | PLUSCOLON -> "pluscolon"
    | PLUSPLUS  -> "plusplus"
    | QUOT      -> "quot"
    | RBRACE    -> "rbrace"
    | RBRACK    -> "rbrack"
    | REGISTER  -> "register"
    | REM       -> "rem"
    | REPEAT    -> "repeat"
    | RETURN    -> "return"
    | RPAREN    -> "rparen"
    | SEE       -> "see"
    | SEMI      -> "semi"
    | SKIP      -> "skip"
    | SLASH     -> "slash"
    | STAR      -> "star"
    | STRING(x) -> "\"" ^ x
    | THEN      -> "then"
    | TIDENT(x) -> "tident:"^x
    | TO        -> "to"
    | TYPE      -> "type"
    | TYPEOF    -> "typeof"
    | UNDEFINED -> "undefined"
    | UNKNOWN   -> "unknown"
    | UNPREDICTABLE -> "unpredictable"
    | UNTIL     -> "until"
    | WHEN      -> "when"
    | WHILE     -> "while"
    )

let print_position outx lexbuf =
    let pos = lexbuf.lex_curr_p in
    fprintf outx "%s:%d:%d" pos.pos_fname
        pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let starters : Parser.token list = [LPAREN; LBRACK; LBRACE; IF; ELSIF; WHILE]
let enders   : Parser.token list = [RPAREN; RBRACK; RBRACE; THEN; DO]

type offside_state = {
    mutable stack  : int list;      (* indentation history *)
    mutable parens : int;           (* number of outstanding openers *)
    mutable newline: bool;          (* processing newline *)
    mutable next   : Parser.token;  (* next token *)
}

let offside_token (read: Lexing.lexbuf -> Parser.token): (Lexing.lexbuf -> Parser.token) =
    let state = {
        stack   = [0];
        parens  = 0;
        newline = false;
        next    = EOL
    } in

    let pushStack (col: int): Parser.token = begin
        state.stack <- col :: state.stack;
        INDENT
    end in

    let getToken (buf: Lexing.lexbuf): Parser.token = begin
        let useToken _ : Parser.token = begin
            let tok :Parser.token = state.next in
            if List.mem starters tok then begin
                state.parens <- state.parens + 1
            end else if (state.parens > 0) && (List.mem enders tok) then begin
                state.parens <- state.parens - 1
            end;
            (try
                state.next <- read buf
             with Lexer.Eof -> state.next <- EOF);
            tok
        end in

        if state.parens > 0 then begin
            while state.next = EOL do
                ignore (useToken())
            done;
            useToken()
        end else if state.next = EOF then begin
            begin match state.stack with
            | [_] ->
                    EOF
            | (d::ds) ->
                    state.stack <- ds;
                    DEDENT
            end
        end else begin
            while state.next = EOL do
                ignore (useToken ());
                state.newline <- true
            done;
            if state.newline then begin
                let prev_col = List.hd_exn state.stack in
                let pos = lexeme_start_p buf in
                let new_column = pos.pos_cnum - pos.pos_bol in
                if new_column > prev_col then begin
                    state.newline <- false;
                    pushStack new_column
                end else if new_column = prev_col then begin
                    state.newline <- false;
                    EOL
                end else begin
                    state.stack <- List.tl_exn state.stack;
                    let target_column = List.hd_exn state.stack in
                    state.newline <- new_column <> target_column;
                    if new_column < target_column then begin
                        printf "Warning: incorrect indentation %d %d\n"
                           new_column target_column
                    end;
                    DEDENT
                end
            end else begin
                useToken()
            end
        end
    end
    in
    getToken

