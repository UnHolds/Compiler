
all: ag

oxout.l oxout.y oxout.h: parser.y scanner.l
	ox -h parser.y scanner.l

oxout.tab.c oxout.tab.h: oxout.y
	bison -d oxout.y

lex.yy.c: oxout.l
	flex oxout.l

oxout.tab.o: oxout.tab.c
	gcc -c oxout.tab.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

ag: oxout.tab.o lex.yy.o
	gcc -o ag oxout.tab.o lex.yy.o -ly -ll

clean:
	rm -rf oxout.* lex.yy.* ag