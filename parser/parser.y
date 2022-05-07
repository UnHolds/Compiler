%{

#include <stdio.h>
#include <stdlib.h>
#define YYERROR_VERBOSE 1
extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
extern int yylineno;

%}


%token T_NUM
%token T_ID

%token T_END
%token T_RETURN
%token T_GOTO
%token T_IF
%token T_VAR
%token T_NOT
%token T_AND

%token T_SEMICOLON
%token T_ROUND_BRACKET_OPENED
%token T_ROUND_BRACKET_CLOSED
%token T_CURLY_BRACKET_OPENED
%token T_CURLY_BRACKET_CLOSED
%token T_SQUARE_BRACKET_OPENED
%token T_SQUARE_BRACKET_CLOSED
%token T_COMMA
%token T_COLON
%token T_EQUAL
%token T_PLUS
%token T_TIMES
%token T_GREATER
%token T_MINUS
%token T_AT

%%

program: /* nothing */
        | program def T_SEMICOLON
;

def:    T_ID T_ROUND_BRACKET_OPENED pars T_ROUND_BRACKET_CLOSED stats T_END
    |   T_ID T_CURLY_BRACKET_OPENED pars T_CURLY_BRACKET_CLOSED T_ROUND_BRACKET_OPENED pars T_ROUND_BRACKET_CLOSED stats T_END
;


pars: T_ID
    | pars T_COMMA T_ID
;

stats: /* nothing */
    |  stats labeldef stat T_SEMICOLON
;

labeldef: /* nothing */
    | labeldef T_ID T_COLON
;

stat: T_RETURN expr
    | T_GOTO T_ID;
    | T_IF expr T_GOTO T_ID
    | T_VAR T_ID T_EQUAL expr
    | lexpr T_EQUAL expr
    | term
;

lexpr: T_ID
    | term T_SQUARE_BRACKET_OPENED expr T_SQUARE_BRACKET_CLOSED
;

expr_plus: term
    | expr_plus T_PLUS term
;

expr_times: term
    | expr_times T_TIMES term
;

expr_and: term
    | expr_and T_AND term
;



expr: term
    | T_NOT expr
    | T_MINUS expr
    | expr_plus T_PLUS term
    | expr_times T_TIMES term
    | expr_and T_AND term
    | term T_GREATER term
    | term T_EQUAL term
;

multi_expr: expr
    | multi_expr T_COMMA expr
;

term: T_ROUND_BRACKET_OPENED expr T_ROUND_BRACKET_CLOSED
    | T_NUM
    | term T_SQUARE_BRACKET_OPENED expr T_SQUARE_BRACKET_CLOSED
    | T_ID
    | T_ID T_ROUND_BRACKET_OPENED multi_expr T_ROUND_BRACKET_CLOSED
    | T_ID T_CURLY_BRACKET_OPENED multi_expr T_CURLY_BRACKET_CLOSED
    | term T_AT T_ROUND_BRACKET_OPENED multi_expr T_ROUND_BRACKET_CLOSED
;
%%

int main( int argc, char **argv )
{
    ++argv, --argc;  /* skip over program name */
    if ( argc > 0 ) {
        yyin = fopen( argv[0], "r" );
    } else {
        yyin = stdin;
    }

    do {
		yyparse();
	} while(!feof(yyin));

	return 0;
}

void yyerror(const char* s) {
	fprintf(stderr, "Parse error: %s in line %d\n", s, yylineno);
    exit(2);
}