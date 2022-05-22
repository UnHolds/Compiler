%{

#include <stdio.h>
#include <stdlib.h>
#include "oxout.h"
#include <string.h>
#include "list.h"
#include "tree.h"
#include "treeOperators.h"
#include "register.h"

#define YYERROR_VERBOSE 1
extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
extern int yylineno;

extern void invoke_burm(NODEPTR_TYPE root);

%}

%union {
    long num;
    char* str;
}


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


@attributes {char * str;} T_ID
@attributes {long num;} T_NUM
@attributes {struct list * s_labels;} labeldef
@attributes {struct list * s_labels; struct list * i_labels; struct list * i_variables; struct list * s_variables;} stats
@attributes {struct list * i_labels; struct list * i_variables; struct list * s_variables;} stat
@attributes {struct list * s_variables; struct s_node *node;} pars
@attributes {struct list * i_variables; struct s_node *node;} multi_expr
@attributes {struct list * i_variables; struct s_node *node;} term expr expr_plus expr_times expr_and lexpr


@traversal @preorder codegen
@traversal LRpost



%%

program: /* nothing */
    @{
        @codegen invoke_burm(newOperatorNode(INIT, NULL, NULL));
    @}
    | program def T_SEMICOLON
;

def:    T_ID T_ROUND_BRACKET_OPENED pars T_ROUND_BRACKET_CLOSED stats end
    @{
        @i @stats.i_labels@ = @stats.s_labels@;

        @i @stats.i_variables@ = @pars.s_variables@;

        @LRpost variable_label_conflict_exits(join_lists(@stats.s_variables@, @pars.s_variables@), @stats.s_labels@);

        @codegen {
            treenode* t = newOperatorNode(FUNCTION, NULL, NULL);
            t->str = @T_ID.str@;
            invoke_burm(t);

            invoke_burm(@pars.node@);
        }

    @}
    |   T_ID T_CURLY_BRACKET_OPENED pars T_CURLY_BRACKET_CLOSED T_ROUND_BRACKET_OPENED pars T_ROUND_BRACKET_CLOSED stats end
    @{
        @i @stats.i_labels@ = new_string_list();

        @i @stats.i_variables@ = join_lists(@pars.0.s_variables@, @pars.1.s_variables@);

        @LRpost find_variable_duplicates(@stats.i_variables@);
        @LRpost variable_label_conflict_exits(join_lists(@stats.s_variables@, @pars.s_variables@), @stats.s_labels@);

        @codegen {
            treenode* t = newOperatorNode(FUNCTION, NULL, NULL);
            t->str = @T_ID.str@;
            invoke_burm(t);

            invoke_burm(@pars.1.node@);
            invoke_burm(newOperatorNode(PARS_2OD, newOperatorNode(PARS_2OD_ADDRESS, NULL, NULL), @pars.0.node@));
        }
    @}
;

end: T_END
    @{
        @codegen {
            treenode* t = newOperatorNode(FUNCTION_END, NULL, NULL);
            invoke_burm(t);
        }
    @}
;




pars: T_ID
    @{
        @i @pars.s_variables@ = add_string(@T_ID.str@, new_string_list());

        @i @pars.node@ = newOperatorNode(PARS_LAST, newVariableNode(@T_ID.str@), NULL);
    @}
    | pars T_COMMA T_ID
    @{
        @i @pars.0.s_variables@ = add_string(@T_ID.str@, @pars.1.s_variables@);
        @LRpost find_variable_duplicates(@pars.0.s_variables@);

        @i @pars.0.node@ = newOperatorNode(PARS, @pars.1.node@, newVariableNode(@T_ID.str@));
    @}
;

stats: /* nothing */
    @{
        @i @stats.s_labels@ = new_string_list();

        @i @stats.s_variables@ = new_string_list();
    @}
    |  stats labeldef stat T_SEMICOLON
    @{
        @i @stats.0.s_labels@ = join_lists(@stats.1.s_labels@, @labeldef.s_labels@);
        @i @stats.1.i_labels@ = @stats.0.i_labels@;
        @i @stat.i_labels@ = @stats.1.i_labels@;
        @LRpost find_label_duplicates(@stats.0.s_labels@);

        //vars
        @i @stats.0.s_variables@ = join_lists(@stat.s_variables@, @stats.1.s_variables@); //propagate vars
        @i @stats.1.i_variables@ =  @stats.0.i_variables@;
        //check this
        @i @stat.i_variables@ = join_lists(@stats.1.s_variables@, @stats.0.i_variables@); // combine with stats.1 s_vars
    @}
;

labeldef: /* nothing */
    @{
        @i @labeldef.s_labels@ = new_string_list();
    @}
    | labeldef T_ID T_COLON
    @{
        @i @labeldef.0.s_labels@ = add_string(@T_ID.str@, @labeldef.1.s_labels@);

        @codegen {
            treenode* t = newOperatorNode(LABEL, NULL, NULL);
            t->str = @T_ID.str@;
            invoke_burm(t);
        }
    @}
;

stat: T_RETURN expr
    @{
        @i @stat.s_variables@ = new_string_list();
        @i @expr.i_variables@ = @stat.i_variables@;

        @codegen {
            treenode* t = newOperatorNode(RETURN, @expr.node@, NULL);
            invoke_burm(t);
        }
    @}
    | T_GOTO T_ID
    @{
        @LRpost label_exists(@T_ID.str@, @stat.i_labels@);

        @i @stat.s_variables@ = new_string_list();

        @codegen {
            treenode* t = newOperatorNode(GOTO, NULL, NULL);
            t->str = @T_ID.str@;
            invoke_burm(t);
        }
    @}
    | T_IF expr T_GOTO T_ID
    @{
        @LRpost label_exists(@T_ID.str@, @stat.i_labels@);

        @i @stat.s_variables@ = new_string_list();
        @i @expr.i_variables@ = @stat.i_variables@;

        @codegen {
            treenode* t_label = newOperatorNode(GOTO, NULL, NULL);
            t_label->str = @T_ID.str@;
            treenode* t = newOperatorNode(IF, @expr.node@, t_label);
            invoke_burm(t);
        }
    @}
    | T_VAR T_ID T_EQUAL expr
    @{

        @i @stat.s_variables@ = add_string(@T_ID.str@, new_string_list());
        @i @expr.i_variables@ = @stat.i_variables@;

        //check if var exists
        @LRpost find_variable_duplicates2(@T_ID.str@, @stat.i_variables@);

        @codegen {
            treenode* t = newOperatorNode(VARIABLE_DEFINITION, @expr.node@, NULL);
            t->str = @T_ID.str@;
            invoke_burm(t);
        }
    @}
    | lexpr T_EQUAL expr
    @{
        @i @stat.s_variables@ = new_string_list();
        @i  @lexpr.i_variables@ = @stat.i_variables@;
        @i @expr.i_variables@ = @stat.i_variables@;

        @codegen {
            treenode* t = newOperatorNode(VARIABLE_ASSIGNMENT, @lexpr.node@, @expr.node@);
            invoke_burm(t);
        }
    @}
    | term
    @{
        @i @stat.s_variables@ = new_string_list();
        @i @term.i_variables@ = @stat.i_variables@;

        @codegen {
            treenode* t = newOperatorNode(TERM_EXECUTION, @term.node@, NULL);
            invoke_burm(t);
        }
    @}
;

lexpr: T_ID
    @{
        @LRpost variable_exists(@T_ID.str@, @lexpr.i_variables@);

        @i @lexpr.node@ = newVariableNode(@T_ID.str@);
    @}
    | term T_SQUARE_BRACKET_OPENED expr T_SQUARE_BRACKET_CLOSED
    @{
        @i @term.i_variables@ = @lexpr.i_variables@;
        @i @expr.i_variables@ = @lexpr.i_variables@;

        @i @lexpr.node@ = newOperatorNode(ARRAY_ASSIGN, @term.node@, @expr.node@);
    @}
;

expr_plus: term
    @{
        @i @term.i_variables@ = @expr_plus.i_variables@;
        @i @expr_plus.node@ = @term.node@;
    @}
    | expr_plus T_PLUS term
    @{
        @i @expr_plus.1.i_variables@ = @expr_plus.0.i_variables@;
        @i @term.i_variables@ = @expr_plus.0.i_variables@;
        @i @expr_plus.0.node@ = newOperatorNode(PLUS, @expr_plus.1.node@, @term.node@);
    @}
;

expr_times: term
    @{
        @i @term.i_variables@ = @expr_times.i_variables@;
        @i @expr_times.node@ = @term.node@;
    @}
    | expr_times T_TIMES term
    @{
        @i  @expr_times.1.i_variables@ = @expr_times.0.i_variables@;
        @i @term.i_variables@ = @expr_times.0.i_variables@;
        @i @expr_times.0.node@ = newOperatorNode(TIMES, @expr_times.1.node@, @term.node@);
    @}
;

expr_and: term
    @{
        @i @term.i_variables@ = @expr_and.i_variables@;
        @i @expr_and.node@ = @term.node@;
    @}
    | expr_and T_AND term
    @{
        @i @expr_and.1.i_variables@ = @expr_and.0.i_variables@;
        @i @term.i_variables@ = @expr_and.0.i_variables@;
        @i @expr_and.0.node@ = newOperatorNode(AND, @expr_and.1.node@, @term.node@);
    @}
;

expr: term
    @{
        @i @term.i_variables@ = @expr.i_variables@;
        @i @expr.node@ = @term.node@;
    @}
    | T_NOT expr
    @{
        @i @expr.1.i_variables@ = @expr.0.i_variables@;
        @i @expr.0.node@ = newOperatorNode(NOT, @expr.1.node@, NULL);
    @}
    | T_MINUS expr
    @{
        @i @expr.1.i_variables@ = @expr.0.i_variables@;
        @i @expr.0.node@ = newOperatorNode(MINUS, @expr.1.node@, NULL);
    @}
    | expr_plus T_PLUS term
    @{
        @i @expr_plus.i_variables@ = @expr.i_variables@;
        @i @term.i_variables@ = @expr.i_variables@;
        @i @expr.node@ = newOperatorNode(PLUS, @expr_plus.node@, @term.node@);
    @}
    | expr_times T_TIMES term
    @{
        @i @expr_times.i_variables@ = @expr.i_variables@;
        @i @term.i_variables@ = @expr.i_variables@;
        @i @expr.node@ = newOperatorNode(TIMES, @expr_times.node@, @term.node@);
    @}
    | expr_and T_AND term
    @{
        @i @expr_and.i_variables@ = @expr.i_variables@;
        @i @term.i_variables@ = @expr.i_variables@;
        @i @expr.node@ = newOperatorNode(AND,  @expr_and.node@, @term.node@);
    @}
    | term T_GREATER term
    @{
        @i @term.0.i_variables@ = @expr.i_variables@;
        @i @term.1.i_variables@ = @expr.i_variables@;
        @i @expr.node@ = newOperatorNode(GREATER, @term.0.node@, @term.1.node@);
    @}
    | term T_EQUAL term
    @{
        @i @term.0.i_variables@ = @expr.i_variables@;
        @i @term.1.i_variables@ = @expr.i_variables@;
        @i @expr.node@ = newOperatorNode(EQUAL, @term.0.node@, @term.1.node@);
    @}
;

multi_expr: expr
    @{
        @i @expr.i_variables@ = @multi_expr.i_variables@;
        @i @multi_expr.node@ = newOperatorNode(MULTI_EXPR_LAST, @expr.node@, NULL);
    @}
    | multi_expr T_COMMA expr
    @{
        @i @multi_expr.0.node@ = newOperatorNode(MULTI_EXPR, @expr.node@, @multi_expr.1.node@);
        @i @multi_expr.1.i_variables@ = @multi_expr.0.i_variables@;
        @i @expr.i_variables@ = @multi_expr.0.i_variables@;
    @}
;

term: T_ROUND_BRACKET_OPENED expr T_ROUND_BRACKET_CLOSED
    @{
        @i @expr.i_variables@ = @term.i_variables@;
        @i @term.node@ = @expr.node@; //FIXME ???
    @}
    | T_NUM
    @{
        @i @term.node@ = newNumberNode(@T_NUM.num@); //create new number node
    @}
    | term T_SQUARE_BRACKET_OPENED expr T_SQUARE_BRACKET_CLOSED
    @{
        @i @term.1.i_variables@ = @term.0.i_variables@;
        @i @expr.i_variables@ = @term.0.i_variables@;

        @i @term.0.node@ = newOperatorNode(ARRAY_ACCESS, @term.1.node@, @expr.node@);
    @}
    | T_ID
    @{
        @i @term.node@ = newVariableNode(@T_ID.str@); //create a new variable node

        @LRpost variable_exists(@T_ID.str@, @term.i_variables@);
    @}
    | T_ID T_ROUND_BRACKET_OPENED multi_expr T_ROUND_BRACKET_CLOSED //function call
    @{
        @i @term.node@ = newOperatorNode(0, NULL, NULL); //PLACEHOLDER change in gesamt
        @i @multi_expr.i_variables@ = @term.i_variables@;
    @}
    | T_ID T_CURLY_BRACKET_OPENED multi_expr T_CURLY_BRACKET_CLOSED //stufe 1
    @{
        @i {treenode* t2 = newOperatorNode(FIRST_ORDER_ADDR, NULL, NULL); treenode* t = newOperatorNode(FIRST_ORDER, t2, NULL); @term.node@ = t; t->str = @T_ID.str@; t2->str = @T_ID.str@; t->kids[1] = @multi_expr.node@;}
        @i @multi_expr.i_variables@ = @term.i_variables@;
    @}
    | term T_AT T_ROUND_BRACKET_OPENED multi_expr T_ROUND_BRACKET_CLOSED //stufe 2
    @{
        @i @term.node@ = newOperatorNode(0, NULL, NULL); //PLACEHOLDER change in gesamt
        @i @term.1.i_variables@ = @term.0.i_variables@;
        @i @multi_expr.i_variables@ = @term.0.i_variables@;
    @}
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