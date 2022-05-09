#include "Register.h"


Register registers = {
	.name = {"\%rdi", "\%rsi", "\%rdx", "\%rcx", "\%r8", "\%r9", "\%r10", "\%r11", "\%r12", "\%r13", "\%r14", "\%r15"},
	.variable = {0},
	.free = {true, true, true, true, true, true, true, true, true, true, true, true}
};


char* getRegister(){
	for(int i = 0; i < 12; i++){
		if(registers.free[i]==true){
			registers.free[i] = false;
			return registers.name[i];
		}
	}
}

void freeRegister(char* name){
	for(int i = 0; i < 12; i++){
		if(strcmp(name, registers.name[i])){
			registers.free[i] = true;
			return;
		}
	}
}
