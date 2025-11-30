program: main.o cli_func.o args_func.o file_func.o
	ld -m elf_i386 -o program main.o cli_func.o args_func.o file_func.o

main.o: main.asm
	nasm -f elf32 main.asm

cli_func.o: cli_func.asm
	nasm -f elf32 cli_func.asm

args_func.o: args_func.asm
	nasm -f elf32 args_func.asm

file_func.o: file_func.asm
	nasm -f elf32 file_func.asm

clean:
	rm -f *.o program

run: program
	./program input.txt

rebuild: clean program