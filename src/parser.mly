%{
open Parsersupport
%}

%token <int> INT
%token <string> HEX
%token <string> REAL
%token <string> BIN
%token <string> MASK
%token <string> STRING
%token <string> IDENT
%token <string> TIDENT
%token <string> QUALIFIER

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
%token CATCH
%token CONSTANT
%token DIV
%token DO
%token DOWNTO
%token ELSE
%token ELSIF
%token ENUM
%token EOR
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
%token THEN
%token THROW
%token TO
%token TRY
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
    ;

// match an identifier in a context where the identifier will be
// declared as a type identifier
tidentdecl:
    | IDENT                { addTypeIdent($1) }
    | QUALIFIER DOT IDENT  { addTypeIdent($3) } (* todo: should really add $1.$3 *)
    | tident               {}
    ;

qualident:
    | ident               {}
    | QUALIFIER DOT ident {}
    ;

tident:
    | TIDENT               {}
    | QUALIFIER DOT TIDENT {}
    ;

// workaround: allow "type" as an identifier in some contexts
ident:
    | IDENT {}
    | TYPE  {}
    ;

definition:
    | type_definition                                   {}
    | variable_or_constant_definition                   {}
    | function_or_procedure_definition                  {}
    ;

type_definition:
    | BUILTIN TYPE tidentdecl SEMI                                              {}
    | TYPE tidentdecl SEMI                                                      {}
    | TYPE tidentdecl IS LPAREN separated_list(COMMA,field) RPAREN option(SEMI) {}
    | TYPE tidentdecl EQ type1 SEMI                                             {}
    | ENUM tidentdecl LBRACE separated_list(COMMA,IDENT) RBRACE SEMI            {}
    ;

field:
    | type1 ident {}
    ;

type1:
    | tident                               {}
    | tident LPAREN expr RPAREN            {}
    | TYPEOF LPAREN expr RPAREN            {}
    | REGISTER INT LBRACE regfields RBRACE {}
    | ARRAY LBRACK ixtype RBRACK OF type1  {}
;

ixtype:
    | tident                          {}
    | expr DOTDOT expr                {}
;

variable_or_constant_definition:
    | CONSTANT type1 IDENT EQ expr SEMI                 {}
    | ARRAY type1 IDENT LBRACK ixtype RBRACK SEMI       {}
    | REGISTER INT LBRACE regfields RBRACE IDENT SEMI   {}
    | type1 qualident SEMI                              {}

regfields:
    | separated_list(COMMA, regfield) {}
    ;

regfield:
    | separated_nonempty_list(COMMA, slice) IDENT {}
    ;

function_or_procedure_definition:
    | returntype qualident formals SEMI                 {}
    | returntype qualident formals block                {}
    | qualident formals SEMI                            {}
    | qualident formals block                           {}
    ;

formals:
    | arguments EQ type1 IDENT {}
    | arguments                {}
    | EQ type1 IDENT           {}
    |                          {}
    ;

arguments:
    | LPAREN separated_list(COMMA, argdecl) RPAREN {}
    | LBRACK separated_list(COMMA, argdecl) RBRACK {}
    ;

argdecl:
    | type1 option(AMP) ident {}
    ;

%inline returntype:
    | type1                                      {}
    | LPAREN separated_list(COMMA, type1) RPAREN {}
    ;

stmt:
    | assignment_stmt                                      {}
    | simple_stmt                                          {}
    | conditional_stmt                                     {}
    | repetitive_stmt                                      {}
    | exceptional_stmt                                     {}
    ;

assignment_stmt:
    | option(CONSTANT) type1 separated_list(COMMA, ident) SEMI {}
    | option(CONSTANT) type1 ident option(preceded(EQ, expr)) SEMI {}
    | lexpr EQ expr SEMI                                   {}
    ;

lexpr:
    | MINUS                                                         {}
    | qualident                                                     {}
    | lexpr DOT ident                                               {}
    | lexpr DOT LBRACK separated_nonempty_list(COMMA, ident) RBRACK {}
    | lexpr LBRACK separated_list(COMMA, slice) RBRACK              {}
    | LBRACK separated_list(COMMA, lexpr) RBRACK                    {}
    | LPAREN separated_nonempty_list(COMMA, lexpr) RPAREN           {}
;

simple_stmt:
    | qualident LPAREN separated_list(COMMA, expr) RPAREN SEMI {}
    | RETURN option(expr) SEMI                             {}
    | ASSERT expr SEMI                                     {}
    | UNPREDICTABLE SEMI                                   {}
    | IMPDEF STRING SEMI                                   {}
    ;

conditional_stmt:
    | IF expr THEN block1 list(elsif_s) option(preceded(ELSE, block1))  {}
    | CASE expr OF INDENT list(alt) DEDENT                      {}
    ;

elsif_s: ELSIF expr THEN block1 {}

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
    | LPAREN separated_list(COMMA, pattern) RPAREN {}
    ;

block:
    | INDENT nonempty_list(stmt) DEDENT {}
    | list(stmt)                        {}
    ;

block1:
    | INDENT nonempty_list(stmt) DEDENT {}
    | nonempty_list(stmt)               {}
    ;

repetitive_stmt:
    | FOR IDENT EQ expr direction expr INDENT list(stmt) DEDENT {}
    | WHILE expr DO INDENT list(stmt) DEDENT                    {}
    | REPEAT INDENT list(stmt) DEDENT UNTIL expr SEMI           {}
    ;

direction:
    | TO      {}
    | DOWNTO  {}
    ;

exceptional_stmt:
    | THROW ident SEMI                                     {}
    | UNDEFINED SEMI                                       {}
    | SEE STRING SEMI                                      {}
    | TRY INDENT list(stmt) DEDENT
      CATCH ident
      INDENT list(catcher) DEDENT {}
    ;

catcher:
    | WHEN expr block {}
    | OTHERWISE block {}
    ;

aexpr:
    | INT                                                 {}
    | REAL                                                {}
    | HEX                                                 {}
    | BIN                                                 {}
    | STRING                                              {}
    | MASK                                                {}
    | qualident                                           {}
    | qualident LPAREN separated_list(COMMA, expr) RPAREN {}
    | LPAREN separated_nonempty_list(COMMA, expr) RPAREN  {}
    | unop aexpr                                          {}
    | type1 UNKNOWN                                       {}
    | type1 IMPDEF option(STRING)                         {}
;

bexpr:
    | aexpr                                                         {}
    | bexpr DOT ident                                               {}
    | bexpr DOT LBRACK separated_nonempty_list(COMMA, ident) RBRACK {}
    | bexpr LBRACK separated_list(COMMA, slice) RBRACK     {}
    | bexpr IN set                   {}
    | bexpr IN MASK                  {}
;

cexpr:
    | bexpr cmpop cexpr                 {}
    | bexpr binop cexpr                 {}
    | bexpr COLON cexpr                 {}
    | bexpr                             {}
;

(* Same as cexpr but without "x : y".  Used in slices *)
cexpr2:
    | bexpr cmpop cexpr2                 {}
    | bexpr binop cexpr2                 {}
    | bexpr                              {}
;

dexpr:
    | IF expr THEN expr list(elsif_e) ELSE expr   {}
    | cexpr {}
    ;

expr:
    dexpr {}
    ;

elsif_e: ELSIF expr THEN expr {}

slice:
      | cexpr2                    {}
      | cexpr2 COLON     cexpr2   {}
      | cexpr2 PLUSCOLON cexpr2   {}
;

element:
      | expr option(DOTDOT; expr {})     {}
;

set:
    | LBRACE separated_list(COMMA, element) RBRACE        {}
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
;
