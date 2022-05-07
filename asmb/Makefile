

.PHONY: all, clean, default

default: asmb.o

all: asmb.o wrapper.o
	gcc -g -o wrapper wrapper.o asmb.o


asmb.o:
	gcc -c asmb.s

wrapper.o:
	gcc -c wrapper.c


clean:
	rm -f asmb.o wrapper.o wrapper