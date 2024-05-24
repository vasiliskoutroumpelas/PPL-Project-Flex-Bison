output: flex bison
	gcc lex.yy.c parser.tab.c 

run: output
	clear; ./a.out test2.txt

flex: flex.l
	flex flex.l

bison: parser.y
	bison -d -t parser.y

clean:
	rm a.out lex.yy.c parser.tab.c parser.tab.h