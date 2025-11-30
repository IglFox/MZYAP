section .bss
    print_buf_unsign resb 7    ; буфер для беззнакового числа (6 цифр + 0)
    print_buf_sign resb 7      ; буфер для знакового числа (знак + 5 цифр + 0)

section .data
    global print_string, print_signed, print_unsigned
    newline db 10, 0

section .text
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
    mov byte [edi], '+'     ; Записываем плюс
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

;=================================
; Вывод беззнакового числа
; Вход: AX - число для вывода
print_unsigned:
    push esi
    push ecx
    push edx
    push ebx
    push eax

    ; Инициализация буфера
    mov esi, print_buf_unsign + 6  
    mov byte [esi], 0          ; нуль-терминатор в конец

    mov cx, ax                 ; копируем число для обработки
    mov ebx, 10                ; основание системы счисления

.digit_loop:
    dec esi                    ; двигаемся назад по буферу
    mov ax, cx
    xor dx, dx
    div bx                     ; DX = остаток (цифра), AX = частное

    add dl, '0'                ; преобразуем цифру в символ
    mov [esi], dl              ; сохраняем символ в буфер

    mov cx, ax                 ; обновляем частное
    cmp cx, 0             	   ; проверяем конец числа
    jnz .digit_loop            ; продолжаем если есть еще цифры

    ; Вывод числа
    mov eax, 4                      ; системный вызов write
    mov ebx, 1                      ; stdout
    mov ecx, esi                    ; начало цифр в буфере
    mov edx, print_buf_unsign + 6	; длина
    sub edx, esi                    ; вычисляем длину числа
    int 0x80                  

    ; Вывод перевода строки
    mov eax, 4                 ; системный вызов write
    mov ebx, 1                 ; стандартный вывод
    mov ecx, newline           ; символ новой строки
    mov edx, 1                 ; длина 1 символ
    int 0x80

    pop eax
    pop ebx
    pop edx
    pop ecx
    pop esi
    ret