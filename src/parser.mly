%{
open Parsersupport
%}

%token <string> INT
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
    | list(definition) EOF {}
;

////////////////////////////////////////////////////////////
// Identifiers
////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////
// Declarations
////////////////////////////////////////////////////////////

definition:
    | type_definition                                   {}
    | variable_or_constant_definition                   {}
    | function_definition                               {}
    | procedure_definition                              {}
    | getter_definition                                 {}
    | setter_definition                                 {}
    ;

type_definition:
    | BUILTIN TYPE tidentdecl SEMI                                    {}
    | TYPE tidentdecl SEMI                                            {}
    | TYPE tidentdecl IS LPAREN separated_list(COMMA,field) RPAREN    {} // why no SEMI?
    | TYPE tidentdecl EQ type1 SEMI                                   {}
    | ENUM tidentdecl LBRACE separated_list(COMMA,IDENT) RBRACE SEMI  {}
    ;

field:
    | type1 ident {}
    ;

variable_or_constant_definition:
    | type1 qualident SEMI                              {}
    | CONSTANT type1 IDENT EQ expr SEMI                 {}
    | ARRAY type1 IDENT LBRACK ixtype RBRACK SEMI       {}

ixtype:
    | tident                          {}
    | expr DOTDOT expr                {}
    ;

function_definition:
    | returntype qualident LPAREN arguments RPAREN SEMI                 {}
    | returntype qualident LPAREN arguments RPAREN indented_block       {}
    ;

%inline returntype:
    | type1                                      {}
    | LPAREN separated_list(COMMA, type1) RPAREN {}
    ;

arguments:
    | separated_list(COMMA, formal) {}
    ;

formal:
    | type1 ident {}
    ;

procedure_definition:
    | qualident LPAREN arguments RPAREN SEMI                            {}
    | qualident LPAREN arguments RPAREN indented_block                  {}
    ;

getter_definition:
    | returntype qualident indented_block                         {}
    | returntype qualident LBRACK arguments RBRACK indented_block {}
    | returntype qualident LBRACK arguments RBRACK SEMI {}

setter_definition:
    | qualident LBRACK sarguments RBRACK EQ type1 ident SEMI   {}
    | qualident LBRACK sarguments RBRACK EQ type1 ident indented_block   {}
    | qualident EQ type1 ident SEMI   {}
    | qualident EQ type1 ident indented_block   {}
    ;

sarguments:
    | separated_list(COMMA, sformal) {}
    ;

sformal:
    | type1 option(AMP) ident {}
    ;

////////////////////////////////////////////////////////////
// Types
////////////////////////////////////////////////////////////

type1:
    | tident                               {}
    | tident LPAREN expr RPAREN            {}
    | TYPEOF LPAREN expr RPAREN            {}
    | REGISTER INT LBRACE separated_list(COMMA, regfield) RBRACE {}
    | ARRAY LBRACK ixtype RBRACK OF type1  {}
    ;

regfield:
    | separated_nonempty_list(COMMA, slice) IDENT {}
    ;

////////////////////////////////////////////////////////////
// Statements
////////////////////////////////////////////////////////////

stmt:
    | assignment_stmt                                      {}
    | simple_stmt                                          {}
    | conditional_stmt                                     {}
    | repetitive_stmt                                      {}
    | exceptional_stmt                                     {}
    ;

indented_block:
    | INDENT nonempty_list(stmt) DEDENT {}
    ;

// list of 0 or more statements
// only used in case alternatives
// todo: potential confusion in code like
//     when 0 // ignore this case
//     when 1 x = x + 1;
possibly_empty_block:
    | indented_block       {}
    | list(stmt)           {}
    ;

// list of 1 or more statements
nonempty_block:
    | indented_block       {}
    | nonempty_list(stmt)  {}
    ;

assignment_stmt:
    | type1 separated_nonempty_list(COMMA, ident) SEMI {}
    | type1 ident EQ expr SEMI                         {}
    | CONSTANT type1 ident EQ expr SEMI                {}
    | lexpr EQ expr SEMI                               {}
    ;

lexpr:
    | MINUS                                                         {}
    | qualident                                                     {}
    | lexpr DOT ident                                               {}
    | lexpr DOT LBRACK separated_nonempty_list(COMMA, ident) RBRACK {}
    | lexpr LBRACK separated_list(COMMA, slice) RBRACK              {}
    | LBRACK separated_nonempty_list(COMMA, lexpr) RBRACK           {}
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
    | IF expr THEN nonempty_block list(s_elsif) option(preceded(ELSE, nonempty_block))  {}
    | CASE expr OF INDENT nonempty_list(alt) DEDENT                     {}
    ;

s_elsif: ELSIF expr THEN nonempty_block {}

alt:
    | WHEN separated_list(COMMA,pattern) option(altcond) possibly_empty_block {}
    | OTHERWISE possibly_empty_block {}
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
    | LPAREN separated_nonempty_list(COMMA, pattern) RPAREN {}
    ;

repetitive_stmt:
    | FOR ident EQ expr direction expr indented_block {}
    | WHILE expr DO indented_block                    {}
    | REPEAT indented_block UNTIL expr SEMI           {}
    ;

direction:
    | TO      {}
    | DOWNTO  {}
    ;

exceptional_stmt:
    | THROW ident SEMI                                     {}
    | UNDEFINED SEMI                                       {}
    | SEE LPAREN expr RPAREN SEMI                          {}
    | SEE STRING SEMI                                      {}
    | TRY indented_block
      CATCH ident
      INDENT nonempty_list(catcher) DEDENT {}
    ;

catcher:
    | WHEN expr indented_block {}
    | OTHERWISE indented_block {}
    ;

////////////////////////////////////////////////////////////
// Expressions
////////////////////////////////////////////////////////////

aexpr:
    | INT                                                 {}
    | HEX                                                 {}
    | REAL                                                {}
    | BIN                                                 {}
    | MASK                                                {}
    | STRING                                              {}
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

(* Same as cexpr but without "x : y".  Used in slices *)
cexpr1:
    | bexpr binop1 cexpr1                 {}
    | bexpr                              {}
    ;

cexpr:
    | bexpr binop2 cexpr                 {}
    | bexpr                             {}
    ;

dexpr:
    | IF expr THEN expr list(e_elsif) ELSE expr   {}
    | cexpr {}
    ;

expr:
    dexpr {}
    ;

e_elsif: ELSIF expr THEN expr {}

slice:
    | cexpr1                   {}
    | cexpr1 COLON     cexpr   {}
    | cexpr1 PLUSCOLON cexpr   {}
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

binop2:
    | binop1 {}
    | COLON  {}
    ;

binop1:
    | EQEQ       {}
    | NEQ        {}
    | GT         {}
    | GTEQ       {}
    | LT         {}
    | LTEQ       {}
    | LTLT       {}
    | GTGT       {}
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

////////////////////////////////////////////////////////////
// End
////////////////////////////////////////////////////////////

