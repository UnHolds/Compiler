#include <stdio.h>
#include <string.h>
#include <mcheck.h>
#include <stdlib.h>

extern void asma_callchecking(char x[]);

void asma_orig(char x[])
{
  long i,j;
  for (i=0,j=15; i<j; i++, j--) {
    char t=x[i];
    x[i]=x[j];
    x[j]=t;
  }
}

int test(char x[])
{
  int i;
  char x_input[32],x_ref[32],x_test[32];
  memset(x_input,'>',16);
  memset(x_input+16,'<',16);
  memcpy(x_input+8,x,16);
  memcpy(x_ref,x_input,32);
  memcpy(x_test,x_input,32);
  printf(" input: %.32s",x_ref);
  asma_callchecking(x_test+8);
  asma_orig(x_ref+8);
  if (memcmp(x_test,x_ref,32)) {
    printf("\n  Error: wrong output\n\
  expected: %.32s\n\
  actual:   %.32s\n",x_ref,x_test);
    return 0;
  }
  printf("; output ok\n");
  return 1;
}

int main()
{
  char *s = "0123456789abcdefghijklmnopqrstuvwxyz";
  int f;

  fprintf(stdout,"The actual inputs are between >>>>>>>> and <<<<<<<<\n");
  f =  test(s);
  f &= test(s+10);
  if (!f)
    fprintf(stdout,"\nTest failed.\n");
  else
    fprintf(stdout,"\nTest succeeded.\n");
  return !f;
}
