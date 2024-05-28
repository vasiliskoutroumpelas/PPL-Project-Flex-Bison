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
    char charval;
}

%token <intval> INT
%token <dblval> DOUBLE
%token <charval> CHAR
%token <str> IDENTIFIER CLASS_IDENTIFIER STRING

%token INT_DATA_TYPE CHAR_DATA_TYPE DOUBLE_DATA_TYPE BOOLEAN_DATA_TYPE VOID_DATA_TYPE STRING_DATA_TYPE
%token BOOLEAN_TRUE BOOLEAN_FALSE
%token PUBLIC PRIVATE
%token NEW CLASS RETURN BREAK DO WHILE FOR IF ELSE ELSEIF SWITCH CASE DEFAULT PRINT
%token SEMICOLON COMMA LPAREN RPAREN LBRACE RBRACE DOT ASSIGN PLUS MINUS MULT DIV COLON
%token EQ_OP NEQ_OP GT_OP LT_OP AND_OP OR_OP

%%

program:
    class_declarations { printf("-- Successful Parse :D --\n"); }
    ;

class_declarations:
    class_declaration
    | class_declarations class_declaration
    ;

class_declaration:
    modifier CLASS CLASS_IDENTIFIER LBRACE class_body RBRACE
    ;

modifier:
    PUBLIC
    | PRIVATE
    ;

class_body:
    /* empty */
    | class_body_elements
    ;

class_body_elements:
    class_body_element
    | class_body_elements class_body_element
    ;

class_body_element:
    declaration
    | method_declaration
    | class_declaration
    | assignment
    ;


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
    | CLASS_IDENTIFIER
    ;


method_declaration:
    modifier data_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE block return_stmt RBRACE
    ;

method_call:
    IDENTIFIER LPAREN identifier_list RPAREN SEMICOLON

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

identifier_list:
    /* empty */
    | identifiers
    ;

identifiers:
    IDENTIFIER
    | identifiers COMMA IDENTIFIER    
    | member_access
    ;

member_access:
    IDENTIFIER DOT IDENTIFIER;
    | IDENTIFIER DOT method_call
    ;
    
block:
    statement
    | block statement
    ;

statement:
    declaration
    | method_call
    | assignment
    | dowhile
    | for
    | if
    | switch
    | BREAK SEMICOLON
    | print SEMICOLON
    ;

assignment:
    IDENTIFIER ASSIGN assigned_value SEMICOLON
    | IDENTIFIER ASSIGN NEW CLASS_IDENTIFIER LPAREN identifier_list RPAREN SEMICOLON
    | member_access ASSIGN assigned_value SEMICOLON
    | member_access ASSIGN method_call SEMICOLON
    | IDENTIFIER ASSIGN method_call
    ;

assigned_value:
    expression
    | CHAR
    | STRING
    | BOOLEAN_TRUE
    | BOOLEAN_FALSE
    ;

expression:
    term
    | expression MINUS term
    | expression PLUS term
    ;

term:
    factor
    | term MULT factor
    | term DIV factor
    ;

factor:
    IDENTIFIER
    | INT
    | MINUS INT
    | DOUBLE
    | MINUS DOUBLE
    | LPAREN expression RPAREN
    | member_access
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
    | FOR LPAREN assignment condition SEMICOLON assignment RPAREN statement
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
    SWITCH LPAREN expression RPAREN LBRACE case_blocks  default_block_opt RBRACE
    ;

case_blocks:
    case_block
    | case_blocks case_block
    ;

case_block:
    CASE expression COLON LBRACE block RBRACE
    ;

default_block_opt:
    /* empty */
    | DEFAULT COLON LBRACE block RBRACE
    ;

print:
    PRINT LPAREN STRING RPAREN
    | PRINT LPAREN STRING COMMA identifier_list RPAREN
    ;

return_stmt:
    RETURN assigned_value SEMICOLON
    | RETURN SEMICOLON
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s in line %d\n", s, yylineno);
}

int main(int argc, char** argv) {
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
            if (!yyin) {
            perror(argv[1]);
            return 1;
        }

        /* //PRINT SOURCE CODE
        FILE* file_copy = fopen(argv[1], "r");
        char c = fgetc(file_copy); 
        while (c != EOF) 
        { 
            printf ("%c", c); 
            c = fgetc(file_copy); 
        } 
        fclose(file_copy);
        // */
        
        yyparse();        
    }
    else
        printf("Usage: %s <filename>\n", argv[0]);
    return 0;
}
