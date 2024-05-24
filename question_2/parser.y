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

int search_push=0;

typedef struct identifier
{
    char* name;
    int block_level;
    double value;
} Identifier;

typedef struct node
{
    Identifier *data;
    struct node *next;
} Node;

Node *method_head=NULL;
Node *identifier_head=NULL;

int current_block;
//========================================================
// Function to create a new node
Node* createNode(char* name, int block_level);
// Function to insert a node at the end of the list
void insertNode(Node **head, char* name, int block_level);
// Function to print the linked list
void printList(Node *head);
// Function to free memory allocated for the linked list
void freeList(Node *head);

void search(Node *head, char* name, int block);
//========================================================


#define MAX_STACK_SIZE 100

double operand_stack[MAX_STACK_SIZE];
char operator_stack[MAX_STACK_SIZE];
int operand_top = -1;
int operator_top = -1;

void push_operand(double value);
void push_operator(char op);
double pop_operand();
char pop_operator();
double perform_operation(char op, double val1, double val2);
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
    data_type IDENTIFIER SEMICOLON { insertNode(&identifier_head, $2, current_block); }
    | modifier data_type IDENTIFIER SEMICOLON{ insertNode(&identifier_head, $3, current_block);  }
    | data_type IDENTIFIER ASSIGN assigned_value SEMICOLON{ insertNode(&identifier_head, $2, current_block); }
    | modifier data_type IDENTIFIER ASSIGN assigned_value SEMICOLON{ insertNode(&identifier_head, $3, current_block);  }
    | data_type identifier_list SEMICOLON
    | data_type assignment_list SEMICOLON{}
    ;

assignment_list:
    IDENTIFIER ASSIGN assigned_value{insertNode(&identifier_head, $1, current_block);}
    | assignment_list COMMA IDENTIFIER ASSIGN assigned_value{insertNode(&identifier_head, $3, current_block);}
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
    modifier data_type IDENTIFIER LPAREN parameter_list RPAREN LBRACE {insertNode(&method_head, $3, current_block); current_block++;} block return_stmt RBRACE {current_block--;}
    ;

method_call:
    IDENTIFIER  method_call_list SEMICOLON
    ;

method_call_list:
    LPAREN RPAREN
    | method_identifiers RPAREN
    ;

method_identifiers:
    LPAREN IDENTIFIER {insertNode(&identifier_head, $2, current_block);}
    | LPAREN member_access
    | method_identifiers COMMA IDENTIFIER {insertNode(&identifier_head, $3, current_block);}
    | method_identifiers COMMA member_access
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
    data_type IDENTIFIER {insertNode(&identifier_head, $2, current_block);}
    ;


identifier_list:
    /* empty */
    |identifiers
    ;

identifiers:
    IDENTIFIER {insertNode(&identifier_head, $1, current_block);}
    | member_access
    | identifiers COMMA IDENTIFIER {insertNode(&identifier_head, $3, current_block);}    
    | identifiers COMMA member_access
    ;

member_access:
    IDENTIFIER DOT IDENTIFIER
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
    IDENTIFIER ASSIGN assigned_value SEMICOLON{search(identifier_head, $1, current_block);}
    | IDENTIFIER ASSIGN NEW CLASS_IDENTIFIER LPAREN identifier_list RPAREN SEMICOLON {search(identifier_head, $1, current_block);}
    | member_access ASSIGN assigned_value SEMICOLON 
    | IDENTIFIER ASSIGN method_call {search(identifier_head, $1, current_block);}
    ;

assigned_value:
    expression {printf("result is: %lf\n", pop_operand());}
    | CHAR
    | STRING
    | BOOLEAN_TRUE
    | BOOLEAN_FALSE
    ;

expression:
    term
    | expression MINUS term{push_operator('-');}
    | expression PLUS term{push_operator('+');}
    ;

term:
    factor
    | term MULT factor{push_operator('*');}
    | term DIV factor{push_operator('/');}
    ;

factor:
    IDENTIFIER
    | INT{push_operand($1);}
    | MINUS INT{push_operand(-$2);}
    | DOUBLE {push_operand($1);}
    | MINUS DOUBLE{push_operand(-$2);}
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

    current_block = 0;
    yyparse();


    printList(identifier_head);

    freeList(identifier_head);
    freeList(method_head);
    }
    else
        printf("Usage: %s <filename>\n", argv[0]);
        
    return 0;
}

// Function to create a new node
Node* createNode(char* name, int block_level) {
    Node *newNode = (Node*)malloc(sizeof(Node));
    if (newNode == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }
    newNode->data = (Identifier*)malloc(sizeof(Identifier));
    if (newNode->data == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        free(newNode);
        exit(EXIT_FAILURE);
    }
    newNode->data->name = strdup(name);
    newNode->data->block_level = block_level;
    newNode->next = NULL;
    return newNode;
}

// Function to insert a node at the end of the list
void insertNode(Node **head, char* name, int block_level) {
    Node *newNode = createNode(name, block_level);
    if (*head == NULL) {
        *head = newNode;
    } else {
        Node *temp = *head;
        while (temp->next != NULL) {
            temp = temp->next;
        }
        temp->next = newNode;
    }
}

// Function to print the linked list
void printList(Node *head) {
    Node *current = head;
    while (current != NULL) {
        printf("Name: %s, Block Level: %d \n ", current->data->name, current->data->block_level);
        current = current->next;
    }
    printf("NULL\n");
}

// Function to free memory allocated for the linked list
void freeList(Node *head) {
    Node *current = head;
    while (current != NULL) {
        Node *temp = current;
        current = current->next;
        free(temp->data->name);
        free(temp->data);
        free(temp);
    }
}


void search(Node *head, char* name, int block) {
    Node *current = head;
    //printf("SEARCHING: %s\n", name);
    
    int flag = 0;
    while (current != NULL) {
        if (strcmp(current->data->name, name) == 0) {
             // Node with matching name found
             //printf("---FOUND---\n");

             //check block
             if(current->data->block_level>block){
                printf("Out of Scope: %d - %d\n", current->data->block_level, block);
                break;
             }
             return;
        }
        current = current->next;
    }
    printList(head);
    printf("___XXX___\n");
    exit(1);
}

void push_operand(double value) {
    printf("PUSHING: %f\n", value);
    if (operand_top >= MAX_STACK_SIZE - 1) {
        fprintf(stderr, "Operand stack overflow\n");
        exit(EXIT_FAILURE);
    }
    operand_stack[++operand_top] = value;
}

void push_operator(char op) {
    printf("PUSHING: %c\n", op);
    operator_stack[++operator_top] = op;
    if (operator_top >= MAX_STACK_SIZE - 1) {
        fprintf(stderr, "Operator stack overflow\n");
        exit(EXIT_FAILURE);
    }
    while (operator_top >= 0 && (operator_stack[operator_top] == '*' || operator_stack[operator_top] == '/' ||(op == '+' || op == '-'))) 
    {
        char opr = pop_operator();
        double val2 = pop_operand();
        double val1 = pop_operand();
        push_operand(perform_operation(opr, val1, val2));
    }
    
}

double pop_operand() {
    printf("pop operand\n");
    if (operand_top < 0) {
        fprintf(stderr, "Operand stack underflow\n");
        exit(EXIT_FAILURE);
    }
    return operand_stack[operand_top--];
}

char pop_operator() {
    printf("pop operator\n");
    if (operator_top < 0) {
        fprintf(stderr, "Operator stack underflow\n");
        exit(EXIT_FAILURE);
    }
    return operator_stack[operator_top--];
}

double perform_operation(char op, double val1, double val2) {
    printf("OPERATION\n");
    switch (op) {
        case '+': return val1 + val2;
        case '-': return val1 - val2;
        case '*': return val1 * val2;
        case '/': 
            if (val2 == 0) {
                fprintf(stderr, "Division by zero\n");
                exit(EXIT_FAILURE);
            }
            return val1 / val2;
        default:
            fprintf(stderr, "Unknown operator: %c\n", op);
            exit(EXIT_FAILURE);
    }
    return 0; // should never reach here
}
