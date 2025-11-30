section .data
    msg_error_file db 'Error! Failed to open file', 0x0A, 0
    msg_error_read db 'Error! Failed to read data from file', 0x0A, 0
    msg_parse_error db 'Error: invalid data format in file', 0x0A, 0

section .bss
    file_buffer resb 2000       ; буфер для данных файла (2000 байт)
    file_buffer_len resd 1      ; реальный размер прочитанных данных

section .text
    global read_file, parse_signed_number, file_buffer, file_buffer_len
    extern print_string

;-----------------------------------------------------------
; Функция чтения файла
; Вход: EBX = имя файла (из аргументов командной строки)
; Выход: CF=1 если ошибка
read_file:
    push eax
    push ebx
    push ecx
    push edx

    ; Открытие файла
    mov eax, 5          ; системный вызов open
    mov ecx, 0          ; O_RDONLY (только чтение)
    mov edx, 0          ; права доступа
    int 0x80
    cmp eax, 0
    jl .error           ; если ошибка открытия

    ; Чтение файла
    mov ebx, eax        ; сохраняем файловый дескриптор
    mov eax, 3          ; системный вызов read
    mov ecx, file_buffer; буфер для данных
    mov edx, 2000       ; максимальный размер
    int 0x80
    mov [file_buffer_len], eax  ; сохраняем реальный размер

    ; Закрытие файла
    mov eax, 6          ; системный вызов close
    int 0x80

    clc                 ; сбрасываем флаг переноса (успех)
    jmp .exit

.error:
    mov esi, msg_error_file
    call print_string
    stc                 ; устанавливаем флаг переноса (ошибка)

.exit:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

;-----------------------------------------------------------
; Функция парсинга знакового числа из буфера
; Вход: ESI = указатель на текущую позицию в буфере
; Выход: AX = число, ESI = указатель на следующий символ, CF=1 если ошибка или конец
parse_signed_number:
    push ebx
    push ecx
    push edx
    push edi

    xor eax, eax        ; обнуляем число
    xor ecx, ecx        ; обнуляем счетчик цифр
    xor edi, edi        ; обнуляем флаг знака (0 = +, 1 = -)

.skip_spaces:
    mov bl, [esi]       ; читаем текущий символ
    cmp bl, ' '         ; смотрим пробел ли
    je .next_char
    cmp bl, 0x0A        ; смотрим это перевод строки LF
    je .next_char
    cmp bl, 0x0D        ; смотрим это возврат каретки CR
    je .next_char
    cmp bl, 0           ; смотрим это конец файла
    je .end
    jmp .check_sign     ; нашли начало числа

.next_char:
    inc esi             ; переходим к следующему символу
    jmp .skip_spaces

.check_sign:
    mov bl, [esi]
    cmp bl, '-'   
    jne .check_plus     ; если плюс
    mov edi, 1          ; в ином случае устанавливаем флаг отрицательности
    inc esi             ; пропускаем символ минуса
    jmp .convert

.check_plus:
    cmp bl, '+'         ; если плюс
    jne .convert
    inc esi             ; пропускаем символ плюса

.convert:
    mov bl, [esi]       ; читаем текущий символ
    cmp bl, ' '         ; пробел - конец числа
    je .done
    cmp bl, 0x0A        ; перевод строки - конец числа
    je .done
    cmp bl, 0x0D        ; возврат каретки - конец числа
    je .done
    cmp bl, 0           ; конец файла - конец числа
    je .done

    ; Проверка что символ - цифра
    cmp bl, '0'
    jb .error           ; если меньше '0' - ошибка
    cmp bl, '9'
    ja .error           ; если больше '9' - ошибка

    ; Преобразование символа в цифру
    sub bl, '0'         ; преобразуем символ в число ( вычитаем код '0'(48) )

    ; Умножение текущего результата на 10 и добавление новой цифры
    imul eax, 10        ; EAX = EAX * 10
    add al, bl          ; добавляем новую цифру
    adc ah, 0           ; учитываем перенос в старший байт

    inc esi             ; переходим к следующему символу
    jmp .convert

.done:
    test edi, edi       ; проверка флага отрицательности
    jz .positive        ; если положительное - пропускаем
    neg ax              ; преобразуем в отрицательное число

.positive:
    clc                 ; сбрасываем флаг переноса (успех)
    jmp .exit

.error:
.end:
    stc                 ; устанавливаем флаг переноса (ошибка или конец)

.exit:
    pop edi
    pop edx
    pop ecx
    pop ebx
    ret