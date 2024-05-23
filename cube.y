%{
int yyerror(const char *s);
int yylex(void);
%}

%define parse.error verbose

%token TOK_IDENT
%token TOK_PRINT
%token TOK_SCAN
%token TOK_IF
%token TOK_ELSE
%token TOK_WHILE
%token TOK_FOR
%token TOK_BREAK
%token TYPE_BOOL
%token TOK_TRUE
%token TOK_FALSE
%token TYPE_INT
%token TYPE_FLOAT
%token TYPE_CHAR
%token TYPE_STRING
%token TOK_AND
%token TOK_OR
%token TOK_NOT
%token TOK_LE
%token TOK_GE
%token TOK_EQ
%token TOK_NE


%start program

%%

program : globals;

globals : globals global {
}

globals : global {
}

global : TOK_IDENT '=' expr ';' {
}

global : TOK_PRINT TOK_IDENT ';' {
}

expr : expr '+' term {
}

expr : expr '-' term {
}

expr : term {
}

term : term '*' factor {
}

term : term '/' factor {
}

term : factor {
}

factor : '(' expr ')' {
}

factor : TOK_IDENT {
}

factor : TYPE_INT {
}

factor : TYPE_FLOAT {
}

factor : unary {
}

unary : '-' factor {
}

%%

