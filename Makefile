all:
	flex namekian.l
	bison -d namekian.y
	${CC} *.c -o namekian
