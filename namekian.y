%{
int yyerror(const char *s);
int yylex(void);
%}

%define parse.error verbose

%token TOK_IDENT TOK_PRINT TOK_SCAN TOK_IF TOK_ELSE TOK_WHILE TOK_FOR TOK_BREAK
%token TYPE_BOOL TYPE_INT TYPE_FLOAT TYPE_CHAR TYPE_STRING
%token TOK_AND TOK_OR TOK_LESSEQUAL TOK_GREATEREQUAL TOK_EQUAL TOK_DIFF
%token TOK_TRUE TOK_FALSE TOK_INT TOK_FLOAT TOK_CHAR TOK_STRING

%start program

%%

program : globals;

globals : globals global{
}

globals : global{
}

global : declaration
       | atribuition
       | while
       | for
       | print
       | selection
       | break{
}

declaration : type TOK_IDENT '=' tok ';'{
} 

declaration : type TOK_IDENT ';'{
}

atribuition: TOK_IDENT '=' tok ';'{
}

atribuition : TOK_IDENT '=' scan{
}

scan : TOK_SCAN '(' type ')'';'{
}

type : TYPE_BOOL{
}

type : TYPE_INT{
}

type : TYPE_FLOAT{
}

type : TYPE_CHAR{
}

type : TYPE_STRING{
}

tok : TOK_STRING{
}

tok : condition{
}

tok : TOK_CHAR{
}

num_expression : num_expression '+' num_term{
} 

num_expression : num_expression '-' num_term{
}

num_expression : num_term{
}

num_term : num_term '*' num_factor{
}

num_term : num_term '/' num_factor{
}

num_term : num_factor{
}

num_factor : '(' num_expression ')'{
}

num_factor : TOK_IDENT{
}

num_factor : TOK_INT{
}

num_factor : TOK_FLOAT{
}

num_factor : unary{
} 

unary : '-' num_factor{
}

print : TOK_PRINT '(' tok ')'';'{
}

selection : TOK_IF '(' condition ')' '{' globals '}'{
}

selection : TOK_IF '(' condition ')' '{' globals '}' TOK_ELSE '{' globals '}'{
}

selection : TOK_IF '(' condition ')' '{' globals '}' TOK_ELSE selection{    
}

condition : num_factor logic_operator num_factor{
}

condition : '(' condition TOK_AND condition ')'{
}

condition: '(' condition TOK_OR condition ')'{
}

condition : num_expression{
}

condition : bool{
}

bool : TOK_TRUE{
}

bool : TOK_FALSE{
}

bool : not{
}

not : '!''(' condition ')'{
}

logic_operator : TOK_DIFF{
}

logic_operator : TOK_EQUAL{
}

logic_operator : '>'{
}

logic_operator : TOK_GREATEREQUAL{
}

logic_operator : '<'{
}

logic_operator : TOK_LESSEQUAL{
}

while : TOK_WHILE '(' TOK_INT ';' TOK_INT ';' TOK_INT ')''{' globals '}'{
}

while : TOK_WHILE '(' condition ')''{' globals '}'{
}

for : TOK_FOR '(' for_init ';' condition ';' for_iter ')' '{' globals '}'{
}

for_init : declaration 
         | atribuition{
}

for_iter : atribuition{
}

break : TOK_BREAK ';'{
}

%%