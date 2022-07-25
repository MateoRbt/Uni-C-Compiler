all:
	bison -d team6.y
	flex team6.l
	gcc team6.tab.c lex.yy.c -o team6

clean:
	rm steam6.tab.c team6.tab.h lex.yy.c team6
