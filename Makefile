all:
	flex namekian.l
	bison -d namekian.y
	${CXX} *.c -o namekian
