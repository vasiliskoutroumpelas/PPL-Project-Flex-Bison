%{
#include <stdio.h>
#include "parser.tab.h"
%}

number [1-9][0-9]*|0
identifier [a-zA-Z][a-zA-Z_0-9]*

%%
";" { return SEMICOLON; }
"int" { return INT_DATA_TYPE; }
"char" { return CHAR_DATA_TYPE; }
"double" { return DOUBLE_DATA_TYPE; }
"boolean" { return BOOLEAN_DATA_TYPE; }
"String" { return STRING_DATA_TYPE; }

{number} { return NUMBER; }
{identifier} { return IDENTIFIER; }

"\n" { return EOL; }

[ \t]+ { /* Ignore whitespace */ }

%%

int yywrap() {
    return 1;
}
