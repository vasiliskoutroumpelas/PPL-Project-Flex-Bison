%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define ARRAY_SIZE 100
#define STRING_SIZE 100
#define METHOD 1
#define IDENT 0
extern FILE *yyin;

extern int yylineno;
void yyerror(const char *s);
int yylex(void);

typedef struct identifier
{
    char* name;
    int block_level;
} Identifier;

Identifier **methods_array;
int methods_array_position=0;

Identifier **identifiers_array;
int identifiers_array_position=0;

int current_block;

void push(Identifier **array, char* var, int type);
void search(Identifier **array, char* var, int block);
void printArray(Identifier **array);

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
%token COMMA SEMICOLON
%token LPAREN RPAREN LBRACE RBRACE DOT ASSIGN PLUS MINUS MULT DIV COLON
%token EQ_OP NEQ_OP GT_OP LT_OP AND_OP OR_OP

%left IDENTIFIER
%%

program:
    class_declarations { printf("-- Successful Parse :D --\n"); }
    ;

class_declarations:
    class_declaration
    | class_declarations class_declaration
    ;

class_declaration:
    modifier CLASS CLASS_IDENTIFIER LBRACE {current_block++;} class_body RBRACE {current_block--;}
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
    data_type IDENTIFIER SEMICOLON { push(identifiers_array, $2, IDENT); }
    | modifier data_type IDENTIFIER SEMICOLON{ push(identifiers_array, $3, IDENT); }
    | data_type IDENTIFIER ASSIGN assigned_value SEMICOLON{ push(identifiers_array, $2, IDENT);}
    | modifier data_type IDENTIFIER ASSIGN assigned_value SEMICOLON{ push(identifiers_array, $3, IDENT); }
    | data_type identifier_list SEMICOLON
    | data_type assignment_list SEMICOLON
    ;

assignment_list:
    IDENTIFIER ASSIGN assigned_value 
    | assignment_list COMMA IDENTIFIER ASSIGN assigned_value
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
    modifier data_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE {push(methods_array, $3, METHOD); current_block++;} block return_stmt RBRACE {current_block--;}
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
    |identifiers
    ;

identifiers:
    IDENTIFIER
    | identifiers COMMA IDENTIFIER    
    | member_access
    ;

member_access:
    IDENTIFIER DOT IDENTIFIER;
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
    IDENTIFIER ASSIGN assigned_value SEMICOLON{search(identifiers_array, $1, current_block);}
    | IDENTIFIER ASSIGN NEW CLASS_IDENTIFIER LPAREN identifier_list RPAREN SEMICOLON {search(identifiers_array, $1, current_block);}
    | member_access ASSIGN assigned_value SEMICOLON 
    | IDENTIFIER ASSIGN method_call {search(identifiers_array, $1, current_block);}
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
    DO LBRACE {current_block++;} block RBRACE {current_block--;} WHILE LPAREN condition RPAREN SEMICOLON
    ;

for:
    FOR LPAREN assignment condition SEMICOLON assignment RPAREN LBRACE {current_block++;} block RBRACE {current_block--;}
    ;

if:
    IF LPAREN condition RPAREN LBRACE {current_block++;} block RBRACE {current_block--;} elseif_opt else_opt
    ;

elseif_opt:
    /* empty */
    | elseif
    ;

elseif:
    ELSEIF LPAREN condition RPAREN LBRACE {current_block++;} block RBRACE {current_block--;} elseif_opt
    ;

else_opt:
    /* empty */
    | ELSE LBRACE {current_block++;} block RBRACE {current_block--;}
    ;

switch:
    SWITCH LPAREN expression RPAREN LBRACE {current_block++;} case_blocks  default_block_opt RBRACE {current_block--;}
    ;

case_blocks:
    case_block
    | case_blocks case_block
    ;

case_block:
    CASE expression COLON LBRACE {current_block++;} block RBRACE {current_block--;}
    ;

default_block_opt:
    /* empty */
    | DEFAULT COLON LBRACE {current_block++;} block RBRACE {current_block--;}
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

        
    

        methods_array = malloc(ARRAY_SIZE * sizeof(char));
        for (int i = 0; i < ARRAY_SIZE; i++)
            methods_array[i] = malloc((STRING_SIZE+1) * sizeof(char));

        identifiers_array = malloc(ARRAY_SIZE * sizeof(char));
        for (int i = 0; i < ARRAY_SIZE; i++)
            identifiers_array[i] = malloc((STRING_SIZE+1) * sizeof(char));

       // identifiers_array_position = 0;
       // methods_array_position = 0;
        current_block = 0;



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

        printf("----------METHODS-----------\n");
        int line = 0;
        for(int i = 0; i < methods_array_position; i++)
        {
            line++;
            printf("line %d --> %s --> block: %d\n", line, methods_array[i]->name, methods_array[i]->block_level);
        }  

        printf("----------IDENTIFIERS-----------\n");
        line = 0;
        for(int i = 0; i < identifiers_array_position; i++){
            line++;
            printf("line %d --> %s --> block: %d\n", line, identifiers_array[i]->name, identifiers_array[i]->block_level);
        }



        

    }
    else
        printf("Usage: %s <filename>\n", argv[0]);
    return 0;
}


void push(Identifier **array, char* var, int type)
{
    int index=0;

    if(type == METHOD)
    {
        index=methods_array_position;
        methods_array_position++;
    }
    else{
       
        index=identifiers_array_position;
        identifiers_array_position++;
    }
    
    array[index]->name = var;
    array[index]->block_level = current_block;
}



void search(Identifier **array, char* var, int block){
    printf("%d %d\n", methods_array_position, identifiers_array_position);
    int flag=0;
    printf("SEARCHING: %s\n", var);
    for(int i=0; i<identifiers_array_position; i++){
        if(array[i]->name!=NULL && var!=NULL){ 
            printf("%s\t%s\n",array[i]->name, var);


            if(strcmp(array[i]->name, var)==0){
                if(array[i]->block_level>current_block)
                {
                    printf("Out of scope: %s\n", var);
                    exit(1);
                }else{
                printf("--->FOUND\n"); flag=1; break;
                }
            }
        }


        
           
    }

    if(flag==0){
        printf("\"%s\" has not been initialized\n", *var);
        exit(1);
    } 
    /* for(int i=0; i<identifiers_array_position; i++){
       printf("CURRENT: %s\n", array[i]->name);
        
        printf("%d",array[i]->block_level);*/
       
        
            
        


    
}

