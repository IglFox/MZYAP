section .bss
	global a_sign, b_sign, result_sign
	global a_unsign, b_unsign, result_unsign

	a_sign       resw 1
    b_sign       resw 1
	result_sign  resw 1

	a_unsign     resw 1
	b_unsign     resw 1
	result_unsign resw 1

section .data
	; Сообщения для пользователя
	msg_signed_title      db "__Signed numbers__", 10, 0
	msg_unsigned_title    db "__Unsigned numbers__", 10, 0
   	msg_signed_result     db "Result for signed numbers: ", 0
   	msg_unsigned_result   db "Result for unsigned numbers: ", 0
   	msg_error             db "__Error__!", 10, 0

	; Приглашения для ввода
    input_msg_signed_a       db "Input a (-32768..32767): ", 0
   	input_msg_signed_b       db "Input b (-32768..32767): ", 0
	input_msg_unsigned_a     db "Input a (0..65535): ", 0
	input_msg_unsigned_b     db "Input b (0..65535): ", 0

section .text
	global main

	extern input_signed, input_unsigned
	extern print_signed, print_unsigned
	extern print_string, print_diagram

	extern asm_sign, asm_unsign

main:
	call print_diagram

	; Знаковые числа
	; msg заголовок
	mov esi, msg_signed_title
	call print_string

	; msg для ввода
	mov esi, input_msg_signed_a
	call print_string

	; Ввод a
	call input_signed
	jc .input_error      ; Если CF=1 - ошибка ввода
	mov [a_sign], ax     ; Сохраняем введенное значение

	; msg для ввода
	mov esi, input_msg_signed_b
	call print_string

	; Ввод b
	call input_signed
	jc .input_error      ; Если CF=1 - ошибка ввода
	mov [b_sign], ax     ; Сохраняем введенное значение

	call asm_sign

	; msg для результата
	mov esi, msg_signed_result
	call print_string
	mov ax, [result_sign]
	call print_signed



	; Беззнаковые числа
	; msg заголовок
	mov esi, msg_unsigned_title
	call print_string

	; msg для ввода a
	mov esi, input_msg_unsigned_a
	call print_string

	; ввод a
	call input_unsigned
	jc .input_error      ; Если CF=1 - ошибка ввода
	mov [a_unsign], ax   ; Сохраняем введенное значение

	; msg для ввода b
	mov esi, input_msg_unsigned_b
	call print_string

	; ввод b
	call input_unsigned
	jc .input_error      ; Если CF=1 - ошибка ввода
	mov [b_unsign], ax   ; Сохраняем введенное значение

	call asm_unsign

	; msg для результата
	mov esi, msg_unsigned_result
	call print_string
	mov ax, [result_unsign]
	call print_unsigned

	; завершение
	jmp .exit

.input_error:
   	; Обработка ошибки ввода
	mov esi, msg_error
	call print_string
	jmp .exit

.exit:
	; Завершение программы
	mov eax, 1      ; номер системного вызова exit
	xor ebx, ebx    ; код возврата 0
	int 0x80