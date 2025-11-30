section .data
    msg_usage db 'Error, use: ./program <filename>', 0x0A, 0

section .text
    global check_arguments
    extern print_string

check_arguments:
    pop eax        ; адрес возврата в основную программу
    pop ebx        ; количество аргументов командной строки
    pop ebx        ; имя программы, например "./program"
    pop ebx        ; первый аргумент, например "input.txt"
    
    test ebx, ebx ; проверяем пусто ли 
    jnz .success  ; (not zero)если нет - успех
    
    ; Ошибка
    push eax       ; возвращаем return address
    mov esi, msg_usage
    call print_string
    stc
    ret

.success:
    push eax       ; возвращаем return address
    clc
    ret