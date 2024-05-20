%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;

extern int yylineno;
void yyerror(const char *s);
int yylex(void);

%}

%define parse.error verbose

%union {
    int intval;
    double dblval;
    char *str;
}

%token <intval> INT
%token <dblval> DOUBLE
%token <str> IDENTIFIER STRING

%token INT_DATA_TYPE CHAR_DATA_TYPE DOUBLE_DATA_TYPE BOOLEAN_DATA_TYPE VOID_DATA_TYPE STRING_DATA_TYPE
%token BOOLEAN_TRUE BOOLEAN_FALSE
%token PUBLIC PRIVATE
%token NEW CLASS RETURN BREAK DO WHILE FOR IF ELSE ELSEIF SWITCH CASE DEFAULT PRINT
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE DOT ASSIGN PLUS MINUS MULT DIV
%token EQ_OP NEQ_OP GT_OP LT_OP AND_OP OR_OP

%%

program:
    class_declarations { printf("Successful Parse\n"); }
    ;

class_declarations:
    class_declaration
    | class_declarations class_declaration
    ;

class_declaration:
    modifier CLASS IDENTIFIER LBRACE class_body RBRACE
    ;

modifier:
    PUBLIC
    | PRIVATE
    ;

class_body:
    declarations
    | method_declarations
    | declarations method_declarations
    | method_declarations declarations
    ;

declarations:
    declaration
    | declarations declaration
    ;
skeleton completed
declaration:
    data_type IDENTIFIER SEMICOLON
    | modifier data_type IDENTIFIER SEMICOLON
    ;

data_type:
    INT_DATA_TYPE
    | CHAR_DATA_TYPE
    | DOUBLE_DATA_TYPE
    | BOOLEAN_DATA_TYPE
    | VOID_DATA_TYPE
    | STRING_DATA_TYPE
    ;

method_declarations:
    method_declaration
    | method_declarations method_declaration
    ;

method_declaration:
    modifier data_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE block return_stmt RBRACE
    ;

parameter_list:
    /* empty */
    | parameters
    ;

parameters:
    parameter
    | parameters COMMA parameter
    ;

parameter:
    data_type IDENTIFIER
    ;

block:
    statement
    | block statement
    ;

statement:
    declaration
    | assignment
    | expression SEMICOLON
    | dowhile
    | for
    | if
    | switch
    | print SEMICOLON
    ;

assignment:
    IDENTIFIER ASSIGN assigned_value SEMICOLON
    | NEW IDENTIFIER LPAREN RPAREN SEMICOLON
    ;

assigned_value:
    expression
    | STRING
    | BOOLEAN_TRUE
    | BOOLEAN_FALSE
    ;

expression:
    term
    | expression PLUS term
    | expression MINUS term
    ;

term:
    factor
    | term MULT factor
    | term DIV factor
    ;

factor:
    IDENTIFIER
    | INT
    | DOUBLE
    | LPAREN expression RPAREN
    ;

condition:
    assigned_value
    | assigned_value logic_operator assigned_value
    ;

logic_operator:
    EQ_OP
    | NEQ_OP
    | GT_OP
    | LT_OP
    | AND_OP
    | OR_OP
    ;

dowhile:
    DO LBRACE block RBRACE WHILE LPAREN condition RPAREN SEMICOLON
    ;

for:
    FOR LPAREN assignment condition SEMICOLON assignment RPAREN LBRACE block RBRACE
    ;

if:
    IF LPAREN condition RPAREN LBRACE block RBRACE elseif_opt else_opt
    ;

elseif_opt:
    /* empty */
    | elseif
    ;

elseif:
    ELSEIF LPAREN condition RPAREN LBRACE block RBRACE elseif_opt
    ;

else_opt:
    /* empty */
    | ELSE LBRACE block RBRACE
    ;

switch:
    SWITCH LPAREN expression RPAREN LBRACE case_blocks default_block RBRACE
    ;

case_blocks:
    case_block
    | case_blocks case_block
    ;

case_block:
    CASE expression SEMICOLON LBRACE block RBRACE
    ;

default_block:
    DEFAULT SEMICOLON LBRACE block RBRACE
    ;

print:
    PRINT LPAREN STRING RPAREN
    | PRINT LPAREN STRING COMMA expression RPAREN
    ;

return_stmt:
    RETURN expression SEMICOLON
    | RETURN SEMICOLON
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s in line %d\n", s, yylineno);
}

int main(int argc, char** argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror(argv[1]);
            return 1;
        }
    }

    yyparse();
    return 0;
}
