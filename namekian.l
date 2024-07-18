%{
#include <stdio.h>
#include <stdlib.h>

bool force_print_tree = false;
char * build_file_name;
class Node;
#include "namekian.tab.h"
int yyerror(const char *s);
%}

%option yylineno

%%
[ \t\r\n] {}
"//".*\n {}

"avishta" {return TOK_PRINT;}
"pumerettohero" {return TOK_IF;}
"tsutenonipiro" {return TOK_ELSE;}
"tetoraputo" {return TOK_LOOP;}

"&&" {return TOK_AND;}
"\|\|" {return TOK_OR;}
"!" {return '!';}

"=" {return '=';}
"<" {return '<';}
">" {return '>';}
"<=" {return TOK_LESSEQUAL;}
">=" {return TOK_GREATEREQUAL;}
"==" {return TOK_EQUAL;}
"!=" {return TOK_DIFF;}

"+" {return '+';}
"-" {return '-';}
"*" {return '*';}
"/" {return '/';}
"%" {return '%';}

"(" {return '(';}
")" {return ')';}
"{" {return '{';}
"}" {return '}';}
"[" {return '[';}
"]" {return ']';}
";" {return ';';}

"hotto" {return TOK_TRUE;}
"uotoku" {return TOK_FALSE;}

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

\"([^\\\"]|\\.)*\" {return TOK_STRING;}


.   {printf("Simbolo não reconhecido! %c\n",yytext[0]);}

%%
int yywrap(){
    return 1;
}

extern int error_count;
int yyerror(const char *s){
    printf("%s:%d:0: %s\n",build_file_name, yylineno, s);
    error_count++;
    return 1;
}

int main(int argc, char *argv[]){
    if(argc <= 1){
        printf("Sintaxe: %s nome_do_programa\n",argv[0]);
        return 1;
    }
        
    //Parametros adicionais
    for(int i=1;i<argc;i++){
        if(strcmp(argv[i],"-d")==0){
            yydebug=1;
        }
        
        if (strcmp(argv[i],"-f")==0){
            force_print_tree = true;
        }
    }

    build_file_name = argv[1];
    yyin = fopen(argv[1],"r");
    if(yyin == NULL){
        printf("Não foi possivel abrir o arquivo %s.\n",build_file_name);
        return 1;
    }
    
    yyparse();

    if(yyin)
        fclose(yyin);

    return 0;
}