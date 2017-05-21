{
open Parser        (* The type token is defined in parser.mli *)
open Parsersupport
open Core.Std
exception Eof

let keywords : (string, Parser.token) List.Assoc.t = [
    ("AND",           AND);
    ("DIV",           DIV);
    ("EOR",           EOR);
    ("IMPLEMENTATION_DEFINED", IMPDEF);
    ("IN",            IN);
    ("MOD",           MOD);
    ("NOT",           NOT);
    ("OR",            OR);
    ("QUOT",          QUOT);
    ("REM",           REM);
    ("SEE",           SEE);
    ("TypeOf",        TYPEOF);
    ("UNDEFINED",     UNDEFINED);
    ("UNKNOWN",       UNKNOWN);
    ("UNPREDICTABLE", UNPREDICTABLE);
    ("__builtin",     BUILTIN);
    ("__register",    REGISTER);
    ("array",         ARRAY);
    ("assert",        ASSERT);
    ("case",          CASE);
    ("constant",      CONSTANT);
    ("do",            DO);
    ("downto",        DOWNTO);
    ("else",          ELSE);
    ("elsif",         ELSIF);
    ("enumeration",   ENUM);
    ("fail",          FAIL);
    ("for",           FOR);
    ("if",            IF);
    ("is",            IS);
    ("of",            OF);
    ("otherwise",     OTHERWISE);
    ("repeat",        REPEAT);
    ("return",        RETURN);
    ("then",          THEN);
    ("to",            TO);
    ("type",          TYPE);
    ("until",         UNTIL);
    ("when",          WHEN);
    ("while",         WHILE);
]

}

rule token = parse
    (* whitespace and comments *)
    | ['\n']                      { Lexing.new_line lexbuf; EOL }
    | [' ' '\t']                  { token lexbuf }
    | '/' '/' [^'\n']*            { token lexbuf }
    | '/' '*'                     { comment 1 lexbuf }

    (* numbers, strings and identifiers *)
    | '"' [^'"']* '"'                        as lxm { STRING(lxm) }
    | '\'' ['0' '1' 'x' ' ']* '\''           as lxm { MASK(lxm) }
    | '\'' ['0' '1' ' ']* '\''               as lxm { BIN(lxm) }
    | '0''x'['0'-'9' 'A' - 'F' 'a'-'f' '_']+ as lxm { HEX(lxm) }
    | ['0'-'9']+ '.' ['0'-'9']+              as lxm { FLOAT(lxm) }
    | ['0'-'9']+                             as lxm { INT(int_of_string lxm) }
    | ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']* as lxm {
           ( match List.Assoc.find keywords lxm with
           | Some x -> x
           | None   -> if isTypeIdent(lxm) then TIDENT(lxm) else IDENT(lxm)
           )
    }
    | '`' [^'`']+ '`'                        as lxm { IDENT(lxm) }

    (* delimiters *)
    | '!'            { BANG     }
    | '!' '='        { NEQ      }
    | '&' '&'        { AMPAMP   }
    | '&'            { AMP      }
    | '('            { LPAREN   }
    | ')'            { RPAREN   }
    | '*'            { STAR     }
    | '+'            { PLUS     }
    | '+' '+'        { PLUSPLUS }
    | '+' ':'        { PLUSCOLON}
    | ','            { COMMA    }
    | '-'            { MINUS    }
    | '.'            { DOT      }
    | '.' '.'        { DOTDOT   }
    | '/'            { SLASH    }
    | ':'            { COLON    }
    | ';'            { SEMI     }
    | '<'            { LT       }
    | '<' '<'        { LTLT     }
    | '<' '='        { LTEQ     }
    | '='            { EQ       }
    | '=' '='        { EQEQ     }
    | '>'            { GT       }
    | '>' '='        { GTEQ     }
    | '>' '>'        { GTGT     }
    | '['            { LBRACK   }
    | ']'            { RBRACK   }
    | '^'            { CARET    }
    | '{'            { LBRACE   }
    | '|' '|'        { BARBAR   }
    | '}'            { RBRACE   }

    | eof            { raise Eof }

and comment depth = parse
      '/' '*' { comment (depth+1) lexbuf }
    | '*' '/' { if depth = 1 then token lexbuf else comment (depth-1) lexbuf }
    | _       { comment depth lexbuf }
