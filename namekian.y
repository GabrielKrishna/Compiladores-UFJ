%{
int yyerror(const char *s);
int yylex(void);
%}

%define parse.error verbose

%token TOK_IDENT TOK_PRINT TOK_SCAN TOK_IF TOK_ELSE TOK_WHILE TOK_BREAK
%token TYPE_BOOL TYPE_INT TYPE_FLOAT TYPE_CHAR TYPE_STRING
%token TOK_AND TOK_OR TOK_LESSEQUAL TOK_GREATEREQUAL TOK_EQUAL TOK_DIFF
%token TOK_TRUE TOK_FALSE TOK_INT TOK_FLOAT TOK_CHAR TOK_STRING

%start program

%%

program
	: globals;

globals
	: globals global
	| global
	;

global
	: declaration
	| atribuition
	| print
	| selection
	| while
	| break
	;

declaration
	: TYPE_BOOL TOK_IDENT '=' bool ';'
	| TYPE_INT TOK_IDENT '=' TOK_INT ';'
	| TYPE_FLOAT TOK_IDENT '=' TOK_FLOAT ';'
	| TYPE_CHAR TOK_IDENT '=' TOK_CHAR ';'
	| TYPE_STRING TOK_IDENT '=' TOK_STRING ';'
	| simple_declaration
	;

simple_declaration
	: TYPE_BOOL TOK_IDENT ';'
	| TYPE_INT TOK_IDENT ';'
	| TYPE_FLOAT TOK_IDENT ';'
	| TYPE_CHAR TOK_IDENT ';'
	| TYPE_STRING TOK_IDENT ';'
	;

atribuition
	: TOK_IDENT '=' value ';'
	| TOK_IDENT '=' scan ';'
	;

value
	: TOK_STRING
	| TOK_CHAR
	| num_expression
	;

scan
	: TOK_SCAN '(' type ')'
	;

type
	: TYPE_BOOL
	| TYPE_INT
	| TYPE_FLOAT
	| TYPE_CHAR
	| TYPE_STRING
	;

num_expression
	: num_expression '+' num_term
	| num_expression '-' num_term
	| num_term
	;

num_term
	: num_term '*' num_factor
	| num_term '/' num_factor
	| num_factor
	;

num_factor
	: '(' num_expression ')'
	| TOK_IDENT
	| TOK_INT
	| TOK_FLOAT
	| unary
	;

unary
	: '-' num_factor
	;

print
	: TOK_PRINT '(' value ')' ';'
	;

selection
	: TOK_IF '(' condition ')' '{' globals '}'
	| TOK_IF '(' condition ')' '{' globals '}' TOK_ELSE '{' globals '}'
	| TOK_IF '(' condition ')' '{' globals '}' TOK_ELSE selection
	;

condition
	: num_factor relational_operator num_factor
	| '(' condition logic_operator condition ')'
	| num_expression
	| bool
	| not
	;

bool
	: TOK_TRUE
	| TOK_FALSE
	;

not
	: '!''(' condition ')'
	;

relational_operator
	: TOK_EQUAL
	| TOK_DIFF
	| '>'
	| TOK_GREATEREQUAL
	| '<'
	| TOK_LESSEQUAL
	;

logic_operator
	: TOK_AND
	| TOK_OR
	;

while
	: TOK_WHILE '(' condition ')''{' globals '}'
	;

break
	: TOK_BREAK ';'
	;

%%