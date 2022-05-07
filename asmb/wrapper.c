#include "stdio.h"

#define SIZE 96

extern int asmb(char x[], long n);

int main(){
    char x[SIZE] = "Nu+ivm??LE9(j*CjonX(YN0!maobk4@)$(dU.StnZLFdb7EK1l[=5wZ4CgnIPw(u8[q](CGf#e)PAr&D+lntsqWLltB?7(9l";

    //fill the array
    /*
    for(int i =0; i < SIZE; i++){
        x[i] = i;
    }
    */

    printf("Array before asmb(x) call: ");
    for(int i = 0; i < SIZE; i++){
        printf("%c", x[i]);
    }

    //call the function
    asmb(x, SIZE);

    printf("\n\nArray after asmb(x) call: ");
    for(int i = 0; i < SIZE; i++){
        printf("%c", x[i]);
    }
    printf("\n");
}