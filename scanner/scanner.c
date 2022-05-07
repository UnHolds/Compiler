

%{
/* need this for the call to atof() below */
#include <math.h>
%}

%option noyywrap

LEXEM           [;(){},:=\[\]\+\*>\-@]
DIGIT           [0-9]
HEX             $[0-9A-Fa-f]+
ID              [a-zA-Z_][a-zA-Z_0-9]*
%%

{DIGIT}+        {
                        printf( "num %d\n", atoi( yytext ) );
                }

{HEX}   {
                printf( "num %d\n", (int)strtol(yytext + 1, NULL, 16));
        }

{LEXEM}|end|return|goto|if|var|not|and  {
                                                printf( "%s\n", yytext );
                                        }

{ID}        printf( "id %s\n", yytext);


"//"[^\n]*     /* eat up one-line comments */

[ \t\n]+          /* eat up whitespace */

.       {
                printf( "Unrecognized character: %s\n", yytext );
                exit(1);
        }
%%

int main( int argc, char **argv )
{
++argv, --argc;  /* skip over program name */
if ( argc > 0 )
        yyin = fopen( argv[0], "r" );
else
        yyin = stdin;

yylex();
}
