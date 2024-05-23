%{
#include <stdio.h>
#include "cube.tab.h"

int yyerror(const char *s);

%}

%option yylineno

%%

[ \t\r\n] {}

"//".*\n {}

"print" {return TOK_PRINT;}
"scan" {return TOK_SCAN;}
"if" {return TOK_IF;}
"else" {return TOK_ELSE;}
"while" {return TOK_WHILE;}
"for" {return TOK_FOR;}
"break" {return TOK_BREAK;}
"bool" {return TYPE_BOOL;}
"int" {return TYPE_INT;}
"float" {return TYPE_FLOAT;}
"char" {return TYPE_CHAR;}
"string" {return TYPE_STRING;}

"&&" {return TOK_AND;}
"\|\|" {return TOK_OR;}
"!" {return TOK_NOT;}

"<=" {return TOK_LE;}
">=" {return TOK_GE;}
"<" {return '<';}
">" {return '>';}
"==" {return TOK_EQ;}
"!=" {return TOK_NE;}

"+" {return '+';}
"-" {return '-';}
"*" {return '*';}
"/" {return '/';}
"(" {return '(';}
")" {return ')';}
"{" {return '{';}
"}" {return '}';}
";" {return ';';}
"=" {return '=';}

"true" {return TOK_TRUE;}
"false" {return TOK_FALSE;}
[a-zA-Z_][a-zA-Z0-9_]* {return TOK_IDENT;}
[0-9]+ {return TYPE_INT;}
[0-9]+\.[0-9]* {return TYPE_FLOAT;}
\'[a-zA-Z]\' {return TYPE_CHAR;}
\"[a-zA-Z_' '0-9]+\" {return TYPE_STRING;}

. {
    printf("Símbolo não reconhecido %c\n", yytext[0]);
  }


%%

int yywrap(){
  return 1;
}

int yyerror(const char *s) {
  printf("Erro de sintaxe a linha %d: %s\n", yylineno, s);
  return 1;
}

int main(int argc, char *argv[]) {

  if(argc <= 1){
    printf("Sintaxe: %s nome_do_programa\n", argv[0]);
    return 1;
  }

  yyin = fopen(argv[1], "r");
  if (yyin == NULL){
    printf("Não foi possível abrir o arquivo %s.\n, argv[1]");
    return 1;
  }

  yyparse();

  if (yyin)
    fclose(yyin);

  return 0;
}
