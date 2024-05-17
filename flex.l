%{
#include <stdio.h>
//#include "bison.tab.h"
%}
digit [0-9]

%%
{digit}+ {
    printf("Integer\n");
}

[ \t\n]+ {}

. {printf("Other\n");}
%%
int yywrap() {
    return 1;
}

int main() {
    yylex();
    return 0;
}
