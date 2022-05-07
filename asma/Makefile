

.PHONY: all, clean, default

default: asma.o

all: asma.o wrapper.o
	gcc -g -o wrapper wrapper.o asma.o


asma.o:
	gcc -c asma.s

wrapper.o:
	gcc -c wrapper.c


clean:
	rm -f asma.o wrapper.o wrapper