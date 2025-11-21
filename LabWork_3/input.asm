section .data
	global input_signed_number, input_unsigned_number
	global print_signed_number, print_unsigned_number
	global print_string, print_newline

	; Символ новой строки
	newline_str db 10, 0

section .bss
	input_buffer resb 16		; Буфер для ввода строки
	output_buffer resb 7		; Буфер для вывода числа (знак + 5 цифр + нуль-терминатор)
	output_buffer_sign resb 7	; Буфер для вывода знаково числа (5 цифр + нуль-терминатор + знак)

section .text

;-----------------------------------------------------------
; print_string - выводит строку
; Вход: esi = указатель на строку
print_string:
	push eax
	push ebx
	push ecx
	push edx
	push esi

	mov ecx, esi    ; Указатель на строку для sys_write
	mov eax, 4      ; sys_write
	mov ebx, 1      ; stdout

	; Вычисляем длину строки
	mov edx, 0      ; Счетчик длины

.length_loop:
	cmp byte [esi + edx], 0
	je .final_print
	inc edx
	jmp .length_loop

.final_print:
	int 0x80        ; Вызов системы syscall

	pop esi
	pop edx
	pop ecx
	pop ebx
	pop eax
	ret

;-----------------------------------------------------------
;print_newline - выводит перевод строки
print_newline:
	push esi
	mov esi, newline_str
	call print_string
	pop esi
	ret

;-----------------------------------------------------------
; Функция для ввода беззнакового числа
; Выход: ax = число (0-65535)
; CF = 0 если успех, CF = 1 если ошибка
input_unsigned_number:
	push esi                ; Сохраняем регистры
	push edi
	push ebx
	push ecx
	push edx

	; Читаем строку с stdin
	mov eax, 3              ; sys_read
	mov ebx, 0              ; stdin
	mov ecx, input_buffer   ; буфер для ввода
	mov edx, 15             ; максимальная длина (15 символов + нуль-терминатор)
	int 0x80

	cmp eax, 1		; проверяем, что что-то ввели
	jb .error

	mov esi, input_buffer   ; ESI = указатель на начало строки
	xor edx, edx            ; EDX = 0 (здесь будет накапливаться число)
	xor ecx, ecx            ; ECX = 0 (счетчик позиции в строке)
	xor ebx, ebx            ; EBX = 0 (для текущего символа)

.convert_loop:
	mov bl, byte [esi + ecx]; текущий символ

	cmp bl, 10              ; LF (Line feed - перевод строки)
	je .done
	cmp bl, 13              ; CR (Carriage Return - в начало строки)
	je .done
	cmp bl, 0               ; нуль-терминатор
	je .done

	cmp bl, '0'
	jb .error               ; если первое меньше '0' - ошибка
	cmp bl, '9'
	ja .error               ; если первое больше '9' - ошибка

	sub bl, '0'

	; Пользователь ввел 5
	;BL = 53 (ASCII код '5')
	;sub bl, '0' -> 53 - 48 = 5
	;BL = 5 (теперь это ЧИСЛО 5, а не символ)

	mov eax, edx    	; копируем текущий результат
	mov edi, 10
	mul edi         	; EAX = EAX * 10
	jc .error 	      	; Проверяем не было ли переполнения

	mov edx, eax            ; возвращаем результат в EDX

	movzx eax, bl		; расширяем до 32 бит
	add edx, eax		; добавляем новую цифру с итерации
	jc .error

	cmp edx, 65535		; Проверяем не больше ли 65535
	ja .error

	inc ecx                 ; следующий символ
	cmp ecx, 6              ; максимум 6 цифр (65535)
	jae .error              ; если слишком длинное число - ошибка
	jmp .convert_loop

.done:
	; Проверяем что ввели хотя бы одну цифру
	cmp ecx, 0
	je .error               ; если нет цифр - ошибка

	; Успех - очищаем флаг переноса
	mov ax, dx
	clc
	pop edx                 ; Восстанавливаем регистры в обратном порядке
	pop ecx
	pop ebx
	pop edi
	pop esi
	ret

.error:
	; Ошибка - устанавливаем флаг переноса
	stc
        pop edx                 ; Восстанавливаем регистры в обратном порядке
        pop ecx
        pop ebx
        pop edi
        pop esi
	ret

;-----------------------------------------------------------
; Функция для ввода знакового числа
; Выход: AX = число (-32768..32767)
input_signed_number:

	push esi
	push edi
	push ebx
	push ecx
	push edx

	; Читаем строку с stdin
	mov eax, 3		; sys_read
	mov ebx, 0		; stdin
	mov ecx, input_buffer
	mov edx, 15
	int 0x80

	; Преобразуем строку в число
	mov esi, input_buffer
	xor edx, edx		; EDX будет накапливать число
	xor ecx, ecx		; ECX = счетчик позиции
	xor ebx, ebx		; EBX = для текущего символа
	xor edi, edi		; EDI = флаг знака (0 = +, 1 = -)

	mov bl, byte [esi]
	cmp bl, '-'		; если первый символ минус
	jne .check_plus		; если BL не '-' то переходит
	mov edi, 1		; устанавливаем флаг отрицательности
	inc ecx			; пропускаем символ минуса
	jmp .convert_loop

.check_plus:
	cmp bl, '+'		; если первый символ плюс
	jne .convert_loop
	inc ecx			; пропускаем символ плюса

.convert_loop:
	mov bl, byte [esi + ecx]	; текущий символ

        cmp bl, 10              ; LF (Line feed - перевод строки)
        je .done
        cmp bl, 13              ; CR (Carriage Return - в начало строки)
        je .done
        cmp bl, 0               ; нуль-терминатор
        je .done

        cmp bl, '0'
        jb .error               ; если первое меньше '0' - ошибка
        cmp bl, '9'
        ja .error               ; если первое больше '9' - ошибка

        sub bl, '0'

	mov eax, edx
	mov edx, 10
	imul edx
	jo .error		; если переполнен

	mov edx, eax

	movsx eax, bl
	add edx, eax
	jo .error

	inc ecx
	cmp ecx, 7
	jae .error		; если exc больше чем 6, то переход
	jmp .convert_loop

.done:
	; Проверяем что ввели хотя бы одну цифру
	cmp ecx, edi		; если только знак без цифр (ECX == EDI)
	je .error

	test edi, edi		; проверка флага отрицательности
	jz .check_positive	; если флаг 0 установлен, то переход

	; Проверяем диапазон для 16-битного знакового числа
	cmp edx, 32768
	ja .error
	neg edx
	cmp edx, -32768
	j l .error
	jmp .get_result

.check_positive:

	cmp edx, 32767
	jg .error

.get_result:

	mov ax, dx
	clc

	pop edx
	pop ecx
	pop ebx
	pop edi
	pop esi
	ret

.error:
	stc
        pop edx
        pop ecx
        pop ebx
        pop edi
        pop esi
        ret

;-----------------------------------------------------------
; Функция для вывода знакового числа
; Вход: AX = число для вывода
print_signed_number:
	push esi
	push ecx
	push edx
	push ebx
	push eax

	; 0 в конец
	mov esi, output_buffer_sign + 6
	mov byte [esi], 0

	test ax, ax
	jns .positive		; Если флаг знака не установлен, то переход

	; Отрицательное число - обрабатываем знак
	neg ax			; Преобразуем в положительное число
	mov byte [output_buffer_sign], '-'
	jmp .convert

.positive:
	mov byte [output_buffer_sign], ' '

.convert:
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