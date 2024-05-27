%{
#include <stdio.h>
#include "namekian.tab.h"

int yyerror(const char *s);

%}

%option yylineno

%%

[ \t\r\n] {}
"//".*\n {}

"avishta" {return TOK_PRINT;}
"puyakkiriguo" {return TOK_SCAN;}
"pumerettohero" {return TOK_IF;}
"tsutenonipiro" {return TOK_ELSE;}
"tetoraputo" {return TOK_WHILE;}
"fanparitsu" {return TOK_FOR;}
"terumopara" {return TOK_BREAK;}
"paatoratemorinpe" {return TYPE_BOOL;}
"tamakuroru" {return TYPE_INT;}
"rutemiraru" {return TYPE_FLOAT;}
"peropuppo" {return TYPE_CHAR;}
"pimoposo" {return TYPE_STRING;}

"&&" {return TOK_AND;}
"\|\|" {return TOK_OR;}

"=" {return '=';}
"<=" {return TOK_LESSEQUAL;}
">=" {return TOK_GREATEREQUAL;}
"<" {return '<';}
">" {return '>';}
"==" {return TOK_EQUAL;}
"!=" {return TOK_DIFF;}

"+" {return '+';}
"-" {return '-';}
"*" {return '*';}
"/" {return '/';}

"(" {return '(';}
")" {return ')';}
"{" {return '{';}
"}" {return '}';}
";" {return ';';}

"hotto" {return TOK_TRUE;}
"uotoku" {return TOK_FALSE;}
[a-zA-Z_][a-zA-Z0-9_]* {return TOK_IDENT;}
[0-9]+ {return TOK_INT;}
[0-9]+\.[0-9]* {return TOK_FLOAT;}
\'[a-zA-Z]\' {return TOK_CHAR;}
\"[a-zA-Z_' '0-9]+\" {return TOK_STRING;}

. {
    printf("Símbolo não reconhecido %c\n", yytext[0]);
  }

%%

int yywrap(){
  return 1;
}

int yyerror(const char *s){
  printf("Erro de sintaxe a linha %d: %s\n", yylineno, s);
  return 1;
}

int main(int argc, char *argv[]){

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