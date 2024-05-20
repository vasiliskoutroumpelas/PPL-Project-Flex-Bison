%{
#include <stdio.h>
extern FILE *yyin;

int yylex(void);
void yyerror(const char *s);
%}

%define parse.error verbose
%token EOL
%token NUMBER
%token IDENTIFIER
%token SEMICOLON

%token INT_DATA_TYPE
%token CHAR_DATA_TYPE 
%token DOUBLE_DATA_TYPE
%token BOOLEAN_DATA_TYPE
%token STRING_DATA_TYPE

%%
program:
    declarations
    ;

declarations:
    declarations declaration
    | /* empty */
    ;

declaration: 
    INT_DATA_TYPE IDENTIFIER SEMICOLON EOL { printf("integer declaration\n"); }
    | CHAR_DATA_TYPE IDENTIFIER SEMICOLON EOL { printf("char declaration\n"); }
    | DOUBLE_DATA_TYPE IDENTIFIER SEMICOLON EOL { printf("double declaration\n"); }
    | BOOLEAN_DATA_TYPE IDENTIFIER SEMICOLON EOL { printf("boolean declaration\n"); }
    | STRING_DATA_TYPE IDENTIFIER SEMICOLON EOL { printf("string declaration\n"); }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
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
