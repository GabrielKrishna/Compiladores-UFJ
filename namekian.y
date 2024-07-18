%{
#include "nodes.h"

extern bool force_print_tree;
int yyerror(const char *s);
int yylex(void);
%}

%define parse.error verbose
%define parse.trace

%union { 
    char *str;
    int itg;
    double flt;
    Node *node;
}

%token TOK_IDENT TOK_INT TOK_FLOAT TOK_STRING TOK_TRUE TOK_FALSE

%token TOK_PRINT TOK_LOOP TOK_IF TOK_ELSE

%token TOK_AND TOK_OR TOK_EQUAL TOK_DIFF TOK_GREATEREQUAL TOK_LESSEQUAL

%type<str> TOK_IDENT
%type<itg> TOK_INT
%type<flt> TOK_FLOAT
%type<str> TOK_STRING

%type<node> globals global logic_expresion logic_term logic_factor num_expr num_term num_factor unary

%start program 

%%

program : globals {
        Node *program = new Program();
        program->append($globals);

        // aqui vai a analise semantica
        CheckVarDecl cvd;
        cvd.check(program);

        if (error_count > 0 )
                cout << error_count <<" error(s) found." << endl;
        if (force_print_tree || error_count == 0 )
                printf_tree(program);
                        
        }

globals : globals[gg] global {
                $gg->append($global);
                $$ = $gg;
        }
        | global {
                Node *n = new Node();
                n->append($global);
                $$ = n;
        }

global : TOK_IDENT '=' num_expr ';' {
                $$ = new Variable($TOK_IDENT,$num_expr);
        }
        | TOK_PRINT num_factor ';' {
                $$ = new Print($num_factor);
        }
        | TOK_IF  '(' logic_expresion ')'  '{' globals '}' {
                $$ = new Ifso($logic_expresion,$globals);
        }
        | TOK_IF  '(' logic_expresion ')'  '{' globals[g1] '}' TOK_ELSE '{' globals[g2] '}' {
                $$ = new Ifnot($logic_expresion,$g1,$g2);
        }
        | TOK_LOOP '(' logic_expresion ')' '{' globals '}' {
                $$ = new Loop($logic_expresion,$globals);
        }
        | error ';' {
                $$ = new Node();
        }
        | error {
                $$ = new Node();
        }

logic_expresion : logic_expresion[le] TOK_OR  logic_term[lt] {
                $$ = new BinaryOp($le,'|',$lt);
        }
        | logic_expresion[le] TOK_EQUAL logic_term[lt] {
                $$ = new BinaryOp($le,'=',$lt);
        }
        | logic_expresion[le] '<' logic_term[lt] {
                $$ = new BinaryOp($le,'<',$lt);
        }
        | logic_expresion[le] '>' logic_term[lt] {
                $$ = new BinaryOp($le,'>',$lt);
        }
        | logic_expresion[le] TOK_LESSEQUAL logic_term[lt] {
                $$ = new BinaryOp($le,'.',$lt);
        }
        | logic_expresion[le] TOK_GREATEREQUAL logic_term[lt] {
                $$ = new BinaryOp($le,'^',$lt);
        }
        | logic_term  {
                $$ = $logic_term;
        }

logic_term : logic_term[lt] TOK_AND logic_factor[lf] {
                $$ = new BinaryOp($lt,'&',$lf);
        }
        | logic_term[lt] TOK_DIFF logic_factor[lf] {
                $$ = new BinaryOp($lt,'!',$lf);
        }
        | logic_factor {
                $$ = $logic_factor;
        }

logic_factor : '[' logic_expresion ']' {
                $$ = $logic_expresion;
        }
        | num_factor {
                $$ = $num_factor;
        }
        | '!' '[' logic_expresion[le] ']' {
                $$ = new Unary("!",$le);
        }

num_expr : num_expr[ee] '+' num_term {
                $$ = new BinaryOp($ee,'+',$num_term);
        }
        | num_expr[ee] '-' num_term  {
                $$ = new BinaryOp($ee,'-',$num_term);
        }
        | num_term {
                $$ = $num_term;
        }

num_term : num_term[tt] '*' num_factor {
                $$ = new BinaryOp($tt,'*',$num_factor);
        }
        | num_term[tt] '/' num_factor {
                $$ = new BinaryOp($tt,'/',$num_factor);
        }
        | num_term[tt] '%' num_factor{
                $$ = new BinaryOp($tt,'%',$num_factor);
        }       
        | num_factor {
                $$ = $num_factor;
        }

num_factor : '(' num_expr ')'{
                $$ = $num_expr;
        }
        | TOK_IDENT{
                $$ = new Ident($TOK_IDENT);
        }
        | TOK_INT {
                $$ = new Integer($TOK_INT);
        }
        | TOK_FLOAT {
                $$ = new Float($TOK_FLOAT);
        }
        | TOK_STRING {
                $$ = new String($TOK_STRING);
        }
        | unary {
                $$ = $unary;
        }
        | TOK_FALSE {
                $$ = new Bool(false);
        }
        | TOK_TRUE {
                $$= new Bool(true);
        }

unary : '-' num_factor {
                $$ = new Unary("-",$num_factor);
        }
        | '+' num_factor {
                $$ = new Unary("+",$num_factor);
        }

%%