#include "list.h"


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