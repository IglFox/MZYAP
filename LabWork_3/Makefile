all: lab3

lab3: main.o input.o output.o asm16signbit.o asm16unsignbit.o diagram.o
	ld -m elf_i386 -e main -o lab3 main.o input.o output.o asm16signbit.o asm16unsignbit.o diagram.o

main.o: main.asm
	nasm -f elf32 -g main.asm

input.o: input.asm
	nasm -f elf32 -g input.asm

output.o: output.asm
	nasm -f elf32 -g output.asm

asm16signbit.o: asm16signbit.asm
	nasm -f elf32 -g asm16signbit.asm

asm16unsignbit.o: asm16unsignbit.asm
	nasm -f elf32 -g asm16unsignbit.asm

diagram.o: diagram.asm
	nasm -f elf32 -g diagram.asm

clean:
	rm -f *.o lab3

run: lab3
	./lab3