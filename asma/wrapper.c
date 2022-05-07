#include "stdio.h"


extern int asma(char x[]);

int main(){
    char x[16] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16};
    printf("Array before asma(x) call: ");
    for(int i = 0; i < 16; i++){
        printf("%d ", x[i]);
    }

    //call the function
    asma(x);

    printf("\n\nArray after asma(x) call: ");
    for(int i = 0; i < 16; i++){
        printf("%d ", x[i]);
    }
    printf("\n");
}