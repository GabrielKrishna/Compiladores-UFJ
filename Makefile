all:
	flex calc.l
	bison -d calc.y
	${CC} *.c -o calc