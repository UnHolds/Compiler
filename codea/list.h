#ifndef LIST_H
#define LIST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct list {
    char ** values;
    size_t length;
    size_t mem_size;
} list;



list * new_string_list();
list * add_string(char* string, list* list);
list * join_lists(list * list_a, list * list_b);
int count_string_occurrences(char * string, list* list);
void find_label_duplicates(list* list);
void find_variable_duplicates(list* list);
void find_variable_duplicates2(char* string, list* list);
void label_exists(char* string, list * list);
void variable_exists(char* string, list * list);
void variable_label_conflict_exits(list * variables, list * labels);
void print_list(list * list);

#endif