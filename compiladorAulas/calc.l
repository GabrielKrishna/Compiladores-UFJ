%{
#include <stdio.h>
#include <stdlib.h>

class Node;
#include "calc.tab.h"

int yyerror(const char *s);

%}

%option yylineno

%%

[ \t\r\n] { /* ignora */ }

"//".*\n { /*  ignora */ }

"print" {return TOK_PRINT; }

"+" {return '+';}
"-" {return '-';}
"*" {return '*';}
"/" {return '/';}
"(" {return '(';}
")" {return ')';}
";" {return ';';}
"=" {return '=';}

[a-zA-Z_][a-zA-Z0-9_]* {
  yylval.str = strndup(yytext, yyleng);
  return TOK_IDENT;
}

[0-9]+\.[0-9]* {
  yylval.flt = atof(yytext);
  return TOK_FLOAT;
}

[0-9]+ {
  yylval.itg = atoi(yytext);
  return TOK_INT;
}

. {
    printf("Símbolo não reconhecido %c\n", yytext[0]);
  }


%%

int yywrap(){
  return 1;
}

extern int errorcount;

int yyerror(const char *s) {
  printf("Syntax error teste1.txt:%d: 0 %s\n", yylineno, s);
  errorcount++;
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
