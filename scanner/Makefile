
default: lex.yy.o
	gcc lex.yy.o -o scanner

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c


lex.yy.c:
	flex scanner.c


clean:
	rm -f lex.yy.c lex.yy.o scanner