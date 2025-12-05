section .data
    msg_usage db 'Error, use: ./program <filename>', 0x0A, 0

section .text
    global check_arguments
    extern print_string

check_arguments:
	mov ecx, [esp + 4] ; кол-во аргументов
	mov eax, [esp + 8] ; команда запуска

	cmp ecx, 2
	jl .error		; если argc < 2

	mov ebx, [esp + 12] ; имя файла 1 арг
	clc
	ret

.error:
	mov esi, msg_usage
	call print_string
	stc
	ret