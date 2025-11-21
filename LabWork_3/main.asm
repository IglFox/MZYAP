section .data
	; Сообщения для пользователя
	msg_signed_title      db "=== ВВОД ЗНАКОВЫХ ЧИСЕЛ ===", 10, 0
	msg_unsigned_title    db "=== ВВОД БЕЗЗНАКОВЫХ ЧИСЕЛ ===", 10, 0
   	msg_signed_result     db "Результат для знаковых чисел: ", 0
   	msg_unsigned_result   db "Результат для беззнаковых чисел: ", 0
   	msg_error             db "Ошибка ввода! Программа завершена.", 10, 0

	; Приглашения для ввода
    	prompt_signed_a       db "Введите знаковое a (-32768..32767): ", 0
   	prompt_signed_b       db "Введите знаковое b (-32768..32767): ", 0
    	prompt_unsigned_a     db "Введите беззнаковое a (0..65535): ", 0
    	prompt_unsigned_b     db "Введите беззнаковое b (0..65535): ", 0

section .bss
    	; Глобальные переменные для знаковых чисел
	global a_sign, b_sign, result_sign
	global a_unsign, b_unsign, result_unsign

	a_sign       resw 1
    	b_sign       resw 1
    	result_sign  resw 1

    	; Глобальные переменные для беззнаковых чисел
    	a_unsign     resw 1
    	b_unsign     resw 1
    	result_unsign resw 1

section .text
    	global _start

    	; Внешние функции из io.asm
    	extern input_signed_number, input_unsigned_number
    	extern print_signed_number, print_unsigned_number
    	extern print_string, print_newline

    	; Внешние расчетные функции
    	extern asm_sign, asm_unsign

_start:
    	; ==================== ЗНАКОВЫЕ ЧИСЛА ====================

    	; Вывод заголовка для знаковых чисел
    	mov esi, msg_signed_title
    	call print_string
    	call print_newline

    	; Ввод знакового a
    	mov esi, prompt_signed_a
    	call print_string
    	call input_signed_number
    	jc .input_error      ; Если CF=1 - ошибка ввода
    	mov [a_sign], ax     ; Сохраняем введенное значение

    	; Ввод знакового b
    	mov esi, prompt_signed_b
    	call print_string
    	call input_signed_number
    	jc .input_error      ; Если CF=1 - ошибка ввода
    	mov [b_sign], ax     ; Сохраняем введенное значение

    	call print_newline

    	; Вызов функции расчета для знаковых чисел
    	call asm_sign

    	; Вывод результата для знаковых чисел
    	mov esi, msg_signed_result
    	call print_string
   	mov ax, [result_sign]
    	call print_signed_number
    	call print_newline
    	call print_newline

    	; ==================== БЕЗЗНАКОВЫЕ ЧИСЛА ====================

    	; Вывод заголовка для беззнаковых чисел
    	mov esi, msg_unsigned_title
    	call print_string
    	call print_newline

    	; Ввод беззнакового a
    	mov esi, prompt_unsigned_a
    	call print_string
    	call input_unsigned_number
    	jc .input_error      ; Если CF=1 - ошибка ввода
    	mov [a_unsign], ax   ; Сохраняем введенное значение

    	; Ввод беззнакового b
    	mov esi, prompt_unsigned_b
    	call print_string
    	call input_unsigned_number
    	jc .input_error      ; Если CF=1 - ошибка ввода
    	mov [b_unsign], ax   ; Сохраняем введенное значение

    	call print_newline

    	; Вызов функции расчета для беззнаковых чисел
    	call asm_unsign

    	; Вывод результата для беззнаковых чисел
    	mov esi, msg_unsigned_result
    	call print_string
    	mov ax, [result_unsign]
    	call print_signed_number
    	call print_newline

    	; Успешное завершение программы
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