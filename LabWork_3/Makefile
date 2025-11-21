all: lab3

lab3: main.o input.o output.o variables.o asm16signbit.o asm16unsignbit.o
	gcc -m32 -o lab3 main.o input.o output.o variables.o asm16signbit.o asm16unsignbit.o -no-pie -z noexecstack -Wno-format

main.o: main.asm
	nasm -f elf32 -g main.asm

input.o: input.asm
	nasm -f elf32 -F dwarf -g input.asm

output.o: output.asm
	nasm -f elf32 -F dwarf -g output.asm

variables.o: variables.asm
	nasm -f elf32 -F dwarf -g variables.asm

asm16signbit.o: asm16signbit.asm
	nasm -f elf32 -F dwarf -g asm16signbit.asm

asm16unsignbit.o: asm16unsignbit.asm
	nasm -f elf32 -F dwarf -g asm16unsignbit.asm

clean:
	find . -name "*.exe" -delete
	find . -name "*.o" -delete

run: lab3
	./lab3