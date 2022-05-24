#ifndef REGISTER_H
#define REGISTER_H


#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <stdbool.h>
#include <string.h>


#define NUM_REGISTER 12


typedef struct Register {
    char* name[NUM_REGISTER];
	char* variable[NUM_REGISTER];
    bool free[NUM_REGISTER];
    struct Register* oldRegisters;
} Register;


extern Register registers;

char* getRegister();
void freeRegister(char* name);
char* newVariableAndGetRegister(char* variableName);
char* getRegisterByVariable(char* variableName);
void freeRegisterIfNotVariable(char* name);
void freeAllRegister();
void printRegisterDebug();
void createNewRegisters();
void restoreOldRegisters();

#endif