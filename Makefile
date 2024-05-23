all:
	flex cube.l
	bison -d cube.y
	${CC} *.c -o cube
