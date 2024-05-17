%{
#include <stdio.h>
#include "parser.tab.h"


%}
digit [0-9]
bool true|false
letter [a-zA-Z]
special_character [ -~]

int int
char char
double double
boolean boolean
void void
String String

%%
{digit} {
 yylval=atoi(yytext); return DIGIT;
}
{letter} {
    printf("Letter\n");
}

{special_character} {
    printf("Special Character\n");   
}

{bool} {
    printf("Boolean\n");
}

\n {return EOL;}

[ \t]+ {}


%%
int yywrap() {
    return 1;
}

