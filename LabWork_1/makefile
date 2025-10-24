all: lr1.exe

lr1.exe: main.c asm8bit.o asm16bit.o
	gcc -m64 -o lr1.exe main.c asm8bit.o asm16bit.o -no-pie -z noexecstack -Wno-format

asm8bit.o: asm8bit.asm
	nasm -f elf64 -F dwarf -g asm8bit.asm

asm16bit.o: asm16bit.asm
	nasm -f elf64 -F dwarf -g asm16bit.asm

clean:
	find . -name "*.exe" -delete
	find . -name "*.o" -delete



