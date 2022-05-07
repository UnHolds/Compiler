%{

#include <stdio.h>
#include <stdlib.h>
#include "oxout.h"
#include <string.h>

#define YYERROR_VERBOSE 1
extern int yylex();
extern int yyparse();
extern FILE* yyin;

void yyerror(const char* s);
extern int yylineno;

typedef struct list {
    char ** values;
    size_t length;
    size_t mem_size;
} list;

list * new_string_list(){
    list * newList = malloc(sizeof(list));
    newList->values = NULL;
    newList->length = 0;
    newList->mem_size = sizeof(char**);

    return newList;
}

list * add_string(char* string, list* list){
    list->values = realloc(list->values, list->mem_size * (list->length + 1));
    list->values[list->length] = (void*) string;
    list->length += 1;
}

list * join_lists(list * list_a, list * list_b){
    list * newList = malloc(sizeof(list));
    newList->length = list_a->length + list_b->length;
    if(list_a->mem_size != list_b->mem_size){
        printf("missmatching list mem_sizes while joining lists\n");
    }
    newList->mem_size = list_a->mem_size;
    newList->values = malloc(newList->mem_size * (list_a->length + list_b->length));

    //copy all the values to the new list
    for(int i = 0; i < newList->length; i++){
        if(i < list_a->length){
            newList->values[i] = list_a->values[i];
        }else{
            newList->values[i] = list_b->values[i - list_a->length];
        }
    }

    return newList;
}

int count_string_occurrences(char * string, list* list){

    int occurrences = 0;

    for(int i = 0; i < list->length; i++){
        if(strcmp(string, list->values[i]) == 0){
            occurrences++;
        }
    }
    return occurrences;
}

void find_label_duplicates(list* list){
    for(int i = 0; i < list->length; i++){
        if(count_string_occurrences(list->values[i], list) > 1){
            printf("duplicate label found! (%s)\n", list->values[i]);
            exit(3);
        }
    }
}

void find_variable_duplicates(list* list){
    for(int i = 0; i < list->length; i++){
        if(count_string_occurrences(list->values[i], list) > 1){
            printf("duplicate variable declaration found! (%s)\n", list->values[i]);
            exit(3);
        }
    }
}

void find_variable_duplicates2(char* string, list* list){
    if(count_string_occurrences(string, list) > 0 ){
        printf("duplicate variable declaration found! (%s)\n", string);
        exit(3);
    }
}

void label_exists(char* string, list * list){
    if(count_string_occurrences(string, list) < 1){
        printf("label does not exist (%s)\n", string);
        exit(3);
    }
}

void variable_exists(char* string, list * list){
    if(count_string_occurrences(string, list) < 1){
        printf("variable does not exist (%s)\n", string);
        exit(3);
    }
}

void variable_label_conflict_exits(list * variables, list * labels){
    for(int i = 0; i < variables->length; i++){
        if(count_string_occurrences(variables->values[i], labels) > 0){
            printf("label and variable with same name exit (%s)", variables->values[i]);
            exit(3);
        }
    }
}


void print_list(list * list){
    printf("\n\n");
    for(int i = 0; i < list->length; i++){
        printf("%s\n", list->values[i]);
    }
    printf("\n");
}

%}

%union {
    int num;
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
@attributes {struct list * s_labels;} labeldef
@attributes {struct list * s_labels; struct list * i_labels; struct list * i_variables; struct list * s_variables;} stats
@attributes {struct list * i_labels; struct list * i_variables; struct list * s_variables;} stat
@attributes {struct list * s_variables;} pars
@attributes {struct list * i_variables;} expr lexpr expr_plus expr_times expr_and multi_expr
@attributes {struct list * i_variables;} term

@traversal @preorder LRpre
@traversal LRpost

%%

program: /* nothing */
        | program def T_SEMICOLON
;

def:    T_ID T_ROUND_BRACKET_OPENED pars T_ROUND_BRACKET_CLOSED stats T_END
    @{
        @i @stats.i_labels@ = @stats.s_labels@;

        @i @stats.i_variables@ = @pars.s_variables@;

        @LRpost variable_label_conflict_exits(join_lists(@stats.s_variables@, @pars.s_variables@), @stats.s_labels@);
    @}
    |   T_ID T_CURLY_BRACKET_OPENED pars T_CURLY_BRACKET_CLOSED T_ROUND_BRACKET_OPENED pars T_ROUND_BRACKET_CLOSED stats T_END
    @{
        @i @stats.i_labels@ = new_string_list();

        @i @stats.i_variables@ = join_lists(@pars.0.s_variables@, @pars.1.s_variables@);

        @LRpost find_variable_duplicates(@stats.i_variables@);
        @LRpost variable_label_conflict_exits(join_lists(@stats.s_variables@, @pars.s_variables@), @stats.s_labels@);
    @}
;


pars: T_ID
    @{
        @i @pars.s_variables@ = add_string(@T_ID.str@, new_string_list());
    @}
    | pars T_COMMA T_ID
    @{
        @i @pars.0.s_variables@ = add_string(@T_ID.str@, @pars.1.s_variables@);
        @LRpost find_variable_duplicates(@pars.0.s_variables@);
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
    @}
;

stat: T_RETURN expr
    @{
        @i @stat.s_variables@ = new_string_list();
        @i @expr.i_variables@ = @stat.i_variables@;
    @}
    | T_GOTO T_ID
    @{
        @LRpost label_exists(@T_ID.str@, @stat.i_labels@);

        @i @stat.s_variables@ = new_string_list();
    @}
    | T_IF expr T_GOTO T_ID
    @{
        @LRpost label_exists(@T_ID.str@, @stat.i_labels@);

        @i @stat.s_variables@ = new_string_list();
        @i @expr.i_variables@ = @stat.i_variables@;
    @}
    | T_VAR T_ID T_EQUAL expr
    @{

        @i @stat.s_variables@ = add_string(@T_ID.str@, new_string_list());
        @i @expr.i_variables@ = @stat.i_variables@;

        //check if var exists
        @LRpost find_variable_duplicates2(@T_ID.str@, @stat.i_variables@);
    @}
    | lexpr T_EQUAL expr
    @{
        @i @stat.s_variables@ = new_string_list();
        @i  @lexpr.i_variables@ = @stat.i_variables@;
        @i @expr.i_variables@ = @stat.i_variables@;
    @}
    | term
    @{
        @i @stat.s_variables@ = new_string_list();
        @i @term.i_variables@ = @stat.i_variables@;
    @}
;

lexpr: T_ID
    @{
        @LRpost variable_exists(@T_ID.str@, @lexpr.i_variables@);
    @}
    | term T_SQUARE_BRACKET_OPENED expr T_SQUARE_BRACKET_CLOSED
    @{
        @i @term.i_variables@ = @lexpr.i_variables@;
        @i @expr.i_variables@ = @lexpr.i_variables@;
    @}
;

expr_plus: term
    @{
        @i @term.i_variables@ = @expr_plus.i_variables@;
    @}
    | expr_plus T_PLUS term
    @{
        @i @expr_plus.1.i_variables@ = @expr_plus.0.i_variables@;
        @i @term.i_variables@ = @expr_plus.0.i_variables@;
    @}
;

expr_times: term
    @{
        @i @term.i_variables@ = @expr_times.i_variables@;
    @}
    | expr_times T_TIMES term
    @{
        @i  @expr_times.1.i_variables@ = @expr_times.0.i_variables@;
        @i @term.i_variables@ = @expr_times.0.i_variables@;
    @}
;

expr_and: term
    @{
        @i @term.i_variables@ = @expr_and.i_variables@;
    @}
    | expr_and T_AND term
    @{
        @i @expr_and.1.i_variables@ = @expr_and.0.i_variables@;
        @i @term.i_variables@ = @expr_and.0.i_variables@;
    @}
;

expr: term
    @{
        @i @term.i_variables@ = @expr.i_variables@;
    @}
    | T_NOT expr
    @{
        @i @expr.1.i_variables@ = @expr.0.i_variables@;
    @}
    | T_MINUS expr
    @{
        @i @expr.1.i_variables@ = @expr.0.i_variables@;
    @}
    | expr_plus T_PLUS term
    @{
        @i @expr_plus.i_variables@ = @expr.i_variables@;
        @i @term.i_variables@ = @expr.i_variables@;
    @}
    | expr_times T_TIMES term
    @{
        @i @expr_times.i_variables@ = @expr.i_variables@;
        @i @term.i_variables@ = @expr.i_variables@;
    @}
    | expr_and T_AND term
    @{
        @i @expr_and.i_variables@ = @expr.i_variables@;
        @i @term.i_variables@ = @expr.i_variables@;
    @}
    | term T_GREATER term
    @{
        @i @term.0.i_variables@ = @expr.i_variables@;
        @i @term.1.i_variables@ = @expr.i_variables@;
    @}
    | term T_EQUAL term
    @{
        @i @term.0.i_variables@ = @expr.i_variables@;
        @i @term.1.i_variables@ = @expr.i_variables@;
    @}
;

multi_expr: expr
    @{
        @i @expr.i_variables@ = @multi_expr.i_variables@;
    @}
    | multi_expr T_COMMA expr
    @{
        @i @multi_expr.1.i_variables@ = @multi_expr.0.i_variables@;
        @i @expr.i_variables@ = @multi_expr.0.i_variables@;
    @}
;

term: T_ROUND_BRACKET_OPENED expr T_ROUND_BRACKET_CLOSED
    @{
        @i @expr.i_variables@ = @term.i_variables@;
    @}
    | T_NUM
    | term T_SQUARE_BRACKET_OPENED expr T_SQUARE_BRACKET_CLOSED
    @{
        @i @term.1.i_variables@ = @term.0.i_variables@;
        @i @expr.i_variables@ = @term.0.i_variables@;
    @}
    | T_ID
    @{
        @LRpost variable_exists(@T_ID.str@, @term.i_variables@);
    @}
    | T_ID T_ROUND_BRACKET_OPENED multi_expr T_ROUND_BRACKET_CLOSED
    @{
        @i @multi_expr.i_variables@ = @term.i_variables@;
    @}
    | T_ID T_CURLY_BRACKET_OPENED multi_expr T_CURLY_BRACKET_CLOSED
    @{
        @i @multi_expr.i_variables@ = @term.i_variables@;
    @}
    | term T_AT T_ROUND_BRACKET_OPENED multi_expr T_ROUND_BRACKET_CLOSED
    @{
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