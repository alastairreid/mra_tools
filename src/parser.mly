%{
open Parsersupport
%}

%token <int> INT
%token <string> HEX
%token <string> FLOAT
%token <string> BIN
%token <string> MASK
%token <string> STRING
%token <string> IDENT
%token <string> TIDENT

%token INDENT
%token DEDENT
%token EOL
%token EOF

/* reserved words */
%token AND
%token ARRAY
%token ASSERT
%token BUILTIN
%token CASE
%token CONSTANT
%token DIV
%token DO
%token DOWNTO
%token ELSE
%token ELSIF
%token ENUM
%token EOR
%token FAIL
%token FOR
%token IF
%token IMPDEF
%token IN
%token IS
%token MOD
%token NOT
%token OF
%token OR
%token OTHERWISE
%token QUOT
%token REM
%token REPEAT
%token RETURN
%token REGISTER
%token SEE
%token SKIP
%token THEN
%token TO
%token TYPE
%token TYPEOF
%token UNDEFINED
%token UNKNOWN
%token UNPREDICTABLE
%token UNTIL
%token WHEN
%token WHILE

/* delimiters */
%token AMP
%token AMPAMP
%token BANG
%token CARET
%token COLON
%token COMMA
%token DOT
%token DOTDOT
%token EQ
%token EQEQ
%token GT
%token GTEQ
%token GTGT
%token LBRACE RBRACE
%token LBRACK RBRACK
%token LPAREN RPAREN
%token LT
%token LTEQ
%token LTLT
%token MINUS
%token NEQ
%token BARBAR
%token PLUS
%token PLUSCOLON
%token PLUSPLUS
%token SEMI
%token SLASH
%token STAR

%start <unit> main
%%
main:
    | list(def) EOF {}
;

def:
    | definition {}
    | EOL        {}
    ;

definition:
    | BUILTIN TYPE tidentdecl SEMI {}
    | ENUM tidentdecl LBRACE separated_list(COMMA,IDENT) RBRACE SEMI {}
    | TYPE tidentdecl IS LPAREN separated_list(COMMA,field) RPAREN option(SEMI) {}
    | TYPE tidentdecl EQ type1 SEMI {}
    | CONSTANT type1 IDENT EQ expr SEMI {}
    | ARRAY type1 IDENT LBRACK ixtype RBRACK SEMI {}
    | REGISTER INT LBRACE regfields RBRACE IDENT SEMI {}
    | type1 qualident SEMI {}
    | returntype qualident formals SEMI {}
    | returntype qualident formals block {}
    | qualident formals SEMI {}
    | qualident formals block {}
    ;

// match an identifier in a context where the identifier will be
// declared as a type identifier
tidentdecl:
    | IDENT { addTypeIdent($1) }
    ;

qualident:
    | IDENT {}
    | IDENT DOT IDENT {}
    ;

field:
    | type1 ident {}
    ;

// workaround: allow "type" as an identifier in some contexts
ident:
    | IDENT {}
    | TYPE {}
    ;

regfields:
    | separated_list(COMMA, regfield) {}
    ;

regfield:
    | separated_nonempty_list(COMMA, slice) IDENT {}
    ;

formals:
    | arguments EQ type1 IDENT {}
    | arguments                {}
    | EQ type1 IDENT           {}
    ;

arguments:
    | LPAREN separated_list(COMMA, argdecl) RPAREN {}
    | LBRACK separated_list(COMMA, argdecl) RBRACK {}
    ;

argdecl:
    | type1 option(AMP) ident {}
    ;

type1:
    | TIDENT                          {}
    | TIDENT LPAREN expr RPAREN       {}
    | TYPEOF LPAREN expr RPAREN       {}
    | ARRAY LBRACK ixtype RBRACK      {}
;

ixtype:
    | TIDENT                          {}
    | expr DOTDOT expr                {}
;

%inline returntype:
    | type1                                      {}
    | LPAREN separated_list(COMMA, type1) RPAREN {}
    ;

stmt:
    | option(CONSTANT) type1 IDENT option(preceded(EQ, expr)) SEMI {}
    | lexpr EQ expr SEMI                     {}
    | UNDEFINED SEMI                         {}
    | UNPREDICTABLE SEMI                     {}
    | SEE STRING SEMI                        {}
    | ASSERT expr SEMI                       {}
    | RETURN expr SEMI                       {}
    | FAIL                                   {}
    | SKIP                                   {}
    | IF expr THEN block1 list(elsif_s)               {}
    | IF expr THEN block1 list(elsif_s) ELSE block1    {}
    | FOR IDENT EQ expr direction expr block {}
    | CASE expr OF INDENT separated_list(EOL, alt) DEDENT {}
    | WHILE expr DO INDENT list(stmt) DEDENT          {}
    | REPEAT INDENT list(stmt) DEDENT UNTIL expr SEMI {}
;

block1:
    | INDENT separated_list(EOL,stmt) DEDENT {}
    | nonempty_list(stmt) {}
    ;

block:
    | INDENT separated_list(EOL,stmt) DEDENT {}
    | list(stmt) EOL {}
    // | list(stmt) {}
    ;

elsif_s: ELSIF expr THEN block1 {}

direction:
    | TO      {}
    | DOWNTO  {}
    ;

alt:
    | WHEN separated_list(COMMA,pattern) option(altcond) block {}
    | OTHERWISE block {}
    ;

altcond:
    | AMPAMP expr  {}
    ;

pattern:
    | INT                                          {}
    | HEX                                          {}
    | BIN                                          {}
    | MASK                                         {}
    | IDENT                                        {}
    | MINUS                                        {}
    | BANG pattern                                 {}
    | LPAREN separated_list(COMMA, pattern) RPAREN {}
    ;

lexpr:
    | MINUS                           {}
    | IDENT                           {}
    | lexpr LBRACK expr RBRACK        {}
    | lexpr DOT ident                 {}
    | lexpr DOT LT separated_nonempty_list(COMMA, IDENT) GT     {}
    | LPAREN separated_nonempty_list(COMMA, lexpr) RPAREN   { }
;

aexpr:
    | INT                             { }
    | FLOAT                           { }
    | HEX                             { }
    | BIN                             { }
    | MASK                            { }
    | STRING                          { }
    | ident                           { }
    | ident LPAREN separated_list(COMMA, expr) RPAREN {}
    | LPAREN separated_nonempty_list(COMMA, expr) RPAREN   { }
    | LBRACE separated_list(COMMA, element) RBRACE  {}
    | unop aexpr                      { }
    | type1 UNKNOWN                   {}
    | type1 IMPDEF                    {}

bexpr:
    | aexpr {}
    | aexpr LBRACK expr RBRACK     { }
    | aexpr DOT ident                  {}
    | aexpr DOT LT separated_nonempty_list(COMMA, IDENT) GT     {}
    // note that the following creates an ambiguity:
    // x < y  vs.  x < y >
    // one option is to support 0 < x < 10
    | aexpr LT separated_nonempty_list(COMMA, slice) GT     {}
    | aexpr cmpop expr                 { }
    | aexpr binop expr                 { }
;

cexpr:
    | IF expr THEN expr list(elsif_e) ELSE bexpr   { }
    | bexpr {}
    ;

expr:
    cexpr {}
    ;

elsif_e: ELSIF expr THEN expr {}

slice:
      | INT                  {}
      | INT COLON     INT    {}
      | INT PLUSCOLON INT    {}
;

element:
      | expr option(DOTDOT; expr {})     {}
;

unop:
    | MINUS                  {}
    | BANG                   {}
    | NOT                    {}
;

cmpop:
    | EQEQ       {}
    | NEQ        {}
    | GT         {}
    | GTEQ       {}
    | LT         {}
    | LTEQ       {}
    | LTLT       {}
    | GTGT       {}
;

binop:
    | PLUS       {}
    | MINUS      {}
    | STAR       {}
    | SLASH      {}
    | COLON      {}
    | CARET      {}
    | AMPAMP     {}
    | BARBAR     {}
    | OR         {}
    | EOR        {}
    | AND        {}
    | PLUSPLUS   {}
    | QUOT       {}
    | REM        {}
    | DIV        {}
    | MOD        {}
    | IN         {}
;
