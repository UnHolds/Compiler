
all: codea

matcher.brg: matcher.bfe
	bfe matcher.bfe > matcher.brg

matcher.c: matcher.brg
	iburg matcher.brg > matcher.c

matcher.o: matcher.c tree.h
	gcc -c -DUSE_IBURG -DBURM matcher.c

oxout.l oxout.y oxout.h: parser.y scanner.l
	ox -h parser.y scanner.l

oxout.tab.c oxout.tab.h: oxout.y
	bison -vd oxout.y

lex.yy.c: oxout.l
	flex oxout.l

list.o: list.c list.h
	gcc -c list.c

treeOperators.o: treeOperators.c treeOperators.h
	gcc -c treeOperators.c

oxout.tab.o: oxout.tab.c
	gcc -c oxout.tab.c

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

codea: oxout.tab.o lex.yy.o matcher.o list.o treeOperators.o
	gcc -o codea oxout.tab.o lex.yy.o list.o matcher.o treeOperators.o -ly -ll -lfl

clean:
	rm -rf oxout.* lex.yy.* codea matcher.c matcher.brg *.o