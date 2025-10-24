all: lr2.exe

lr2.exe: main.c asm16signbit.o asm16unsignbit.o
	gcc -m64 -o lr2.exe main.c asm16signbit.o asm16unsignbit.o -no-pie -z noexecstack -Wno-format

asm16signbit.o: asm16signbit.asm
	nasm -f elf64 -F dwarf -g asm16signbit.asm

asm16unsignbit.o: asm16unsignbit.asm
	nasm -f elf64 -F dwarf -g asm16unsignbit.asm

clean:
	rm *.exe
	rm *.o
