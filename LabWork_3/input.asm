section .bss
	input_buffer resb 16		; Буфер для ввода строки

section .data
	global input_signed, input_unsigned

section .text
;========================================
; Функция для ввода беззнакового числа
; Выход: ax = число (0-65535)
; CF = 0 если успех, CF = 1 если ошибка
input_unsigned:
	push esi              
	push edi
	push ebx
	push ecx
	push edx

	; Читаем строку
	mov eax, 3              ; системный вызов read
	mov ebx, 0              ; stdin
	mov ecx, input_buffer   ; буфер для ввода
	mov edx, 15             ; максимальная длина (15 символов + нуль-терминатор)
	int 0x80

	cmp eax, 1		; проверяем, что что-то ввели
	jb .error       ; если eax < 1

	mov esi, input_buffer   ; ESI = указатель на начало строки
	xor edx, edx            ; EDX = 0 (число)
	xor ecx, ecx            ; ECX = 0 (счетчик позиции в строке)
	xor ebx, ebx            ; EBX = 0 (текущий символ)

.convert_loop:
	mov bl, byte [esi + ecx]; текущий символ

	cmp bl, 10              ; если есть флаг LF (перевод строки)
	je .done
	cmp bl, 13              ; если есть флаг CR (возврат каретки)
	je .done
	cmp bl, 0               ; если есть нуль-терминатор
	je .done

	cmp bl, '0'
	jb .error               ; если первое меньше '0' - ошибка
	cmp bl, '9'
	ja .error               ; если первое больше '9' - ошибка

	sub bl, '0'             ; для того, чтобы получить число, нужно вычесть символ 0
	; К примеру '2' по ASCII это 50. Тогда если вычесть '0' (48) получиться число 2 

	mov eax, edx    	; копируем текущий результат
	mov edi, 10         
	mul edi         	; EAX = EAX * 10
	jc .error 	      	; Проверяем не было ли переполнения

	mov edx, eax        ; возвращаем результат в EDX

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

	mov ax, dx
	clc                     ; очищаем флаг переноса
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
; "513" (edx = 0)
; 5 -> eax
; edx * 10 + eax -> edx = 5

; 1 -> eax
; edx * 10 + eax -> edx = 51

; 3 -> eax
; edx * 10 + eax -> edx = 513

; \n -> eax
; jmp done

; ax = 513

;-----------------------------------------------------------
; Функция для ввода знакового числа
; Выход: AX = число (-32768..32767)
input_signed:
	push esi
	push edi
	push ebx
	push ecx
	push edx

	; Читаем строку с stdin
	mov eax, 3		        ; системный вызов read
	mov ebx, 0		        ; stdin
	mov ecx, input_buffer   ; куда писать
	mov edx, 15				; длина максимум
	int 0x80

	; Преобразуем строку в число
	mov esi, input_buffer
	xor edx, edx		; EDX будет накапливать число
	xor ecx, ecx		; ECX = счетчик позиции
	xor ebx, ebx		; EBX = для текущего символа
	xor edi, edi		; EDI = флаг знака (0 = +, 1 = -)

	mov bl, byte [esi]
	cmp bl, '-'		; если первый символ минус
	jne .check_plus ; если BL не '-' то переходит
	mov edi, 1		; устанавливаем флаг отрицательности
	inc ecx			; пропускаем символ минуса
	jmp .convert_loop

.check_plus:
	cmp bl, '+'		; если первый символ плюс
	jne .convert_loop
	inc ecx			; пропускаем символ плюса

.convert_loop:
	mov bl, byte [esi + ecx]	; текущий символ

        cmp bl, 10              ; если есть флаг LF (перевод строки)
        je .done
        cmp bl, 13              ; если есть флаг CR (возврат каретки)
        je .done
        cmp bl, 0               ; если есть нуль-терминатор
        je .done

        cmp bl, '0'
        jb .error               ; если первое меньше '0' - ошибка
        cmp bl, '9'
        ja .error               ; если первое больше '9' - ошибка

        sub bl, '0'

	mov eax, edx        ; копируем текущее число в EAX
	mov edx, 10         
	imul edx            ; умножаем EAX на 10
	jo .error           ; если было переполнение

	mov edx, eax        ; сохраняем результат умножения обратно в EDX

	movsx eax, bl       ; расширяем до 32 бит
	add edx, eax        ; добавляем новую цифру: EDX = EDX + цифра
	jo .error           ; если было переполнение

	inc ecx             ; увеличиваем счетчик позиции в строке
	cmp ecx, 7          ; проверяем, не превысили ли максимальную длину
	jae .error          ; если ECX более 7
	jmp .convert_loop   ; продолжаем цикл обработки символов

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
	jl .error
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


; "-513" (edx = 0)

; смотрим первый байт

; стоит минус -> в edi ставим 1 и пропускаем его

; далее считаем также 

; 5 -> eax
; edx * 10 + eax -> edx = 5

; 1 -> eax
; edx * 10 + eax -> edx = 51

; 3 -> eax
; edx * 10 + eax -> edx = 513

; \n -> eax
; jmp done

; т.к. флаг отрицательности 1, то делаем из положительного отрицатеьное

; ax = -513
