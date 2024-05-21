all:
	flex calc.l
	bison -d calc.y
	${CXX} *.c -o calc