

%{
/* need this for the call to atof() below */
#include <math.h>
#include "oxout.tab.h"
#include "oxout.h"
%}

%option noyywrap
%option yylineno

DIGIT           [0-9]
HEX             $[0-9A-Fa-f]+
ID              [a-zA-Z_][a-zA-Z_0-9]*
%%

end return T_END;
return return T_RETURN;
goto return T_GOTO;
if return T_IF;
var return T_VAR;
not return T_NOT;
and return T_AND;

";" return T_SEMICOLON;
"(" return T_ROUND_BRACKET_OPENED;
")" return T_ROUND_BRACKET_CLOSED;
"{" return T_CURLY_BRACKET_OPENED;
"}" return T_CURLY_BRACKET_CLOSED;
"[" return T_SQUARE_BRACKET_OPENED;
"]" return T_SQUARE_BRACKET_CLOSED;
"," return T_COMMA;
":" return T_COLON;
"=" return T_EQUAL;
"+" return T_PLUS;
"*" return T_TIMES;
">" return T_GREATER;
"-" return T_MINUS;
"@" return T_AT;

{DIGIT}+        {
                        yylval.num = atoi( yytext );
                        return T_NUM;
                }

{HEX}   {
                yylval.num = (int)strtol(yytext + 1, NULL, 16);
                return T_NUM;
        }

{ID}    {
                yylval.str = strdup(yytext);
                return T_ID;
                @{@T_ID.str@ = strdup(yytext);@}
        }




"//"[^\n]*     /* eat up one-line comments */

[ \t\n]+          /* eat up whitespace */

.       {
                printf( "Unrecognized character: %s\n", yytext );
                exit(1);
        }
%%

