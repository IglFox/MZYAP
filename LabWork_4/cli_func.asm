section .bss
	input_buffer resb 16		; Буфер для ввода строки
	print_buf_sign resb 7       ; буфер для вывода знакового числа (знак + 5 цифр + 0)

section .data
	global input_signed
	global print_string, print_signed
    newline db 10, 0

section .text
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






;========================================
; Вывод строки
; Вход: ESI - указатель на строку
print_string:
    push eax
    push ebx
    push ecx
    push edx
    push esi

    xor edx, edx               ; обнуляем счетчик длины

.loop_start:
    cmp byte [esi + edx], 0    ; проверяем конец строки
    je .loop_end               ; если одинаково, то в end
    inc edx					   ; увеличисть edx на 1
    jmp .loop_start            ; переход в start

.loop_end:
    mov eax, 4                 ; системный вызов write
    mov ebx, 1                 ; стандартный вывод
    mov ecx, esi               ; строка для вывода
    int 0x80                  

    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

;===============================
; Вывод знакового числа
; Вход: AX - число для вывода
print_signed:
	push esi
	push edi
	push ebx
	push ecx
	push edx                
    
    mov cx, ax              ; Сохраняем число
    mov edi, print_buf_sign ; Буфер для вывода
    mov byte [edi], 0       ; Начальный нуль-терминатор
    
    ; Проверяем знак
    cmp cx, 0
    jge .positive
    mov byte [edi], '-'     ; Записываем минус
    inc edi
    neg cx                  ; Делаем положительным
    jmp .convert

.positive:    
    inc edi

.convert:
    ; Находим конец буфера для цифр
    mov esi, edi
    add esi, 6              ; Максимум 6 цифр
    
.digit_loop:
    dec esi                 ; Двигаемся назад
    
    mov ax, cx
    xor dx, dx
    mov bx, 10
    div bx                  ; AX = частное, DX = цифра
    
    add dl, '0'             ; Преобразуем в символ
    mov [esi], dl           ; Сохраняем
    
    mov cx, ax              ; Обновляем число
    cmp cx, 0
    jnz .digit_loop         ; Продолжаем если есть цифры
    
    ; Копируем цифры в основной буфер
.copy_digits:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0               ; До нуль-терминатора
    jne .copy_digits
    
    ; Вывод результата
    mov eax, 4              ; write
    mov ebx, 1				; stdout
    mov ecx, print_buf_sign ; то, куда
    mov edx, edi			; длина
    sub edx, print_buf_sign 
    dec edx                 ; Минус лишний нуль-терминатор
    int 0x80
    
    ; Перевод строки
    mov eax, 4           
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
	pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret