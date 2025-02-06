#makefile for EBNF
EBNF: EBNF.o
	gcc -z noexecstack -o EBNF EBNF.o  ../EBNFKernel/EBNFKernel.o ../DebugTools/DebugTools.o -no-pie
EBNF.o: EBNF.asm
	nasm -f elf64 -g -F dwarf EBNF.asm -l EBNF.lst
