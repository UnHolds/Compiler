#include "register.h"


//r12 - r15 are callee saved TODO
Register registers = {
	.name = {"\%rdi", "\%rsi", "\%rdx", "\%rcx", "\%r8", "\%r9", "\%r10", "\%r11", "\%r12", "\%r13", "\%r14", "\%r15"},
	.variable = {"\0", "\0", "\0" ,"\0", "\0", "\0", "\0", "\0" ,"\0", "\0", "\0", "\0"},
	.free = {true, true, true, true, true, true, true, true, true, true, true, true},
	.oldRegisters = NULL
};


void createNewRegisters(){

	Register* oldRegisters = malloc(sizeof(struct Register));
	for(int i = 0; i < NUM_REGISTER; i++){
		oldRegisters->name[i] = registers.name[i];
		oldRegisters->variable[i] = registers.variable[i];
		oldRegisters->free[i] = registers.free[i];

		registers.variable[i] = "\0";
		registers.free[i] = true;
	}

	oldRegisters->oldRegisters = registers.oldRegisters;

	registers.oldRegisters = oldRegisters;
}

void restoreOldRegisters(){

	registers = *(registers.oldRegisters);
}

char* getRegister(){
	for(int i = 0; i < NUM_REGISTER; i++){
		if(registers.free[i]== true){
			registers.free[i] = false;
			return registers.name[i];
		}
	}

	printf("ERROR no free registers! (getRegister)\n");
	return NULL;
}

void freeRegister(char* name){

	if(name == NULL){
		printf("ERROR null register given (freeRegister)\n");
		return;
	}

	for(int i = 0; i < NUM_REGISTER; i++){
		if(strcmp(name, registers.name[i]) == 0){
			registers.variable[i] = "\0";
			registers.free[i] = true;
			return;
		}
	}
}

void freeRegisterIfNotVariable(char* name){

	if(name == NULL){
		printf("ERROR null register given (freeRegisterIfNotVariable)\n");
		return;
	}

	for(int i = 0; i < NUM_REGISTER; i++){
		if(strcmp(name, registers.name[i]) == 0){
			if(strcmp("\0", registers.variable[i]) == 0){
				freeRegister(name);
			return;
		}
		}
	}
}

char* newVariableAndGetRegister(char* variableName){
	for(int i = 0; i < NUM_REGISTER; i++){
		if(registers.free[i] == true){
			registers.free[i] = false;
			registers.variable[i] = variableName;
			return registers.name[i];
		}
	}

	printf("ERROR no free registers! (newVariableAndGetRegister)\n");
	return NULL;
}

char* getRegisterByVariable(char* variableName){
	for(int i = 0; i < NUM_REGISTER; i++){
		if(strcmp(variableName, registers.variable[i]) == 0){
			return registers.name[i];
		}
	}

	return NULL;
}

void printRegisterDebug(){
	for(int i = 0; i < NUM_REGISTER; i++){
		printf("Register: %s, Free: %d, Variable: %s\n", registers.name[i], registers.free[i], registers.variable[i]);
	}
}

void freeAllRegister(){
	for(int i = 0; i < NUM_REGISTER; i++){
		registers.variable[i] = "\0";
		registers.free[i] = true;
	}
}



