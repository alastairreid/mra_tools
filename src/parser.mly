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
%token NEWLINE
%token EOF

/* reserved words */
%token AND
%token ARRAY
%token ASSERT
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
%token EOL
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
    | definition EOL                { }
;

definition:
    | ENUM IDENT EQ LBRACE separated_list(COMMA,IDENT) RBRACE {}
    | CONSTANT type1 IDENT EQ expr SEMI {}
    | TYPE IDENT IS LPAREN separated_list(COMMA,field) SEMI {}
    | ARRAY type1 IDENT LBRACK ixtype RBRACK SEMI {}
    | REGISTER INT LBRACE regfields RBRACE SEMI {}
    | type1 IDENT SEMI {}
    | type1 IDENT formals SEMI {}
    | type1 IDENT formals NEWLINE block {}
    | IDENT formals SEMI {}
    | IDENT formals NEWLINE block {}
    ;

field:
    | type1 IDENT {}
    ;

regfields:
    | regfield                 {}
    | regfield regfields       {}
    | NEWLINE regfields        {}
    ;

regfield:
    | separated_list(COMMA, slice) IDENT {}
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
    | type1 option(AMP) IDENT {}
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
    | IF expr THEN block list(elsif_s)               {}
    | IF expr THEN block list(elsif_s) ELSE block    {}
    | FOR IDENT EQ expr direction expr NEWLINE block {}
    | CASE expr OF INDENT separated_list(NEWLINE, alt) DEDENT {}
    | WHILE expr DO INDENT list(stmt) DEDENT          {}
    | REPEAT INDENT list(stmt) DEDENT UNTIL expr SEMI {}
;

block:
    | NEWLINE INDENT separated_list(NEWLINE,stmt) DEDENT {}
    | list(stmt) NEWLINE {}
    // | list(stmt) {}
    ;

elsif_s: ELSIF expr THEN block {}

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
    | lexpr DOT IDENT                 {}
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
    | IDENT                           { }
    | IDENT LPAREN separated_list(COMMA, expr) RPAREN {}
    | LPAREN separated_nonempty_list(COMMA, expr) RPAREN   { }
    | LBRACE separated_list(COMMA, element) RBRACE  {}
    | unop aexpr                      { }
    | type1 UNKNOWN                   {}
    | type1 IMPDEF                    {}

bexpr:
    | aexpr {}
    | aexpr LBRACK expr RBRACK     { }
    | aexpr DOT IDENT                  {}
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
    | MINUS                  { }
    | BANG                   { }
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
