%{
#include <stdio.h>
extern FILE *yyin;

int yylex (void);
void yyerror(char *);
%}

%token EOL
%token DIGIT


%%



int: 
    DIGIT EOL{printf("test %d", $1);}
    | EOL {printf("END OF LINE");}



%%

void yyerror(char *s){
    fprintf(stderr, "%s\n",s);
}

int main(int argc, char** argv){
    if(argc > 0)
         yyin = fopen( argv[1], "r" );
    
    yyparse();
      
    return 0;
}


