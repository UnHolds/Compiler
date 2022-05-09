#ifndef REGISTER_H
#define REGISTER_H


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>


typedef struct Register {
    char* name[12];
	char* variable[12];
    bool free[12];
} Register;


extern Register registers;

char* getRegister();
void freeRegister(char* name);
char* newVariableAndGetRegister(char* variableName);
char* getRegisterByVariable(char* variableName);
void freeRegisterIfNotVariable(char* name);
void printRegisterDebug();

#endif