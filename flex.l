%{
#include <stdio.h>
#include "parser.tab.h"
%}
%option yylineno

digit [0-9]
letter [a-zA-Z]

%%
"int" { return INT_DATA_TYPE; }
"char" { return CHAR_DATA_TYPE; }
"double" { return DOUBLE_DATA_TYPE; }
"boolean" { return BOOLEAN_DATA_TYPE; }
"void" { return VOID_DATA_TYPE; }
"String" { return STRING_DATA_TYPE; }

"true" { return BOOLEAN_TRUE; }
"false" { return BOOLEAN_FALSE; }

"public" { return PUBLIC; }
"private" { return PRIVATE; }

"new" { return NEW; }
"class" { return CLASS; }
"return" { return RETURN; }
"break" { return BREAK; }
"do" { return DO; }
"while" { return WHILE; }
"for" { return FOR; }
"if" { return IF; }
"else" { return ELSE; }
"elseif" { return ELSEIF; }
"switch" { return SWITCH; }
"case" { return CASE; }
"default" { return DEFAULT; }
"out.print" { return PRINT; }

"==" { return EQ_OP; }
"!=" { return NEQ_OP; }
">" { return GT_OP; }
"<" { return LT_OP; }
"&&" { return AND_OP; }
"||" { return OR_OP; }

";" { return SEMICOLON; }
"," { return COMMA; }
"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LBRACE; }
"}" { return RBRACE; }
"." { return DOT; }
"=" { return ASSIGN; }
"+" { return PLUS; }
"-" { return MINUS; }
"*" { return MULT; }
"/" { return DIV; }

{letter}({letter}|{digit}|_)* { yylval.str = strdup(yytext); return IDENTIFIER; }

{digit}+ { yylval.intval = atoi(yytext); return INT; }
{digit}+"."{digit}+ { yylval.dblval = atof(yytext); return DOUBLE; }

\"[a-zA-Z0-9 -~]*\" { yylval.str = strdup(yytext); return STRING; }

"//".* { /* ignore comments */ }
"/*"([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*"*/" { /* ignore comments */ }

[ \t\n]+ { /* ignore whitespace */ }

%%

int yywrap() {
    return 1;
}
