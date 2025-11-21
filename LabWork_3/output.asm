section .bss
	print_buf_unsign resb 7		; знак + 5 цифр + нуль
	print_buf_sign resb 7	    ; знак + 5 цифр + нуль

section .data
    global print_str, print_signed, print_unsigned


section .text


; Выводит строку, которая в esi
print_str:
	push eax
	push ebx
	push ecx
	push edx
	push esi

    .loop_start:
        cmp byte [esi + edx], 0   ; выход при '\0'
        je .loop_end
        inc edx
        jmp .loop_start


    .loop_end:
        mov eax, 4      ; sys_write
        mov ebx, 1      ; stdout
        mov ecx, esi    ; стррока для вывода
        ; в edx сохранена длина
        int 0x80        ; Вызов системы syscall

	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret


print_signed:
	push esi
	push ecx
	push edx
	push ebx
	push eax

	; 0 в конец
	mov esi, print_buf_sign + 6	
	mov byte [esi], 0

	test ax, ax
	jns .if_positive		; Если флаг знака не установлен, то переход

	; Отрицательное число - обрабатываем знак
	neg ax			; Преобразуем в положительное число
	mov byte [print_buf_sign], '-'
	jmp .if_negative

	.if_positive:
		mov byte [print_buf_sign], ' '

	.if_negative:
		mov cx, ax
		mov ebx, 10

.digit_loop:
	dec esi			; двигаемся назад по буферу
	mov ax, cx
	xor dx, dx
	div bx			; AX = частное, DX = остаток (0-9)

	; Преобразуем остаток в символ
	add dl, '0'		; DL = цифра -> символ
	mov [esi], dl		; Сохраняем символ в буфер

	mov cx, ax		; CX - частное
	test cx, cx		; Проверяем, осталось ли число
	jnz .digit_loop		; Если не 0, то переход



	mov eax, 4		; sys_write
	mov ebx, 1		; stdout
	; Вычисляем длину всей строки (знак + цифры)
	mov ecx, output_buffer		; ECX = начало буфера (знак)
	mov edx, output_buffer + 6	; EDX = конец буфера
	sub edx, esi			; EDX = длина цифровой части
	inc edx				; EDX = общая длина (знак + цифры)

	int 0x80

	pop eax                     ; Восстанавливаем исходное число
	pop ebx
	pop edx
	pop ecx
	pop esi
	ret
