section .data
    msg_enter_c db 'Enter C for expression D <= a[i] <= C: ', 0
    msg_enter_d db 'Enter D for expression D <= a[i] <= C: ', 0
    msg_result db 'Result: ', 0
    msg_newline db 0x0A, 0
    
    c_value dw 0        ; верхняя граница C
    d_value dw 0        ; нижняя граница D
    array_size dd 0     ; размер массива
    result_count dd 0   ; счетчик результата

section .bss
    array resw 1000     ; массив для 1000 элементов (по 2 байта каждый)

section .text
    global _start
    extern print_string, input_signed, print_signed, check_arguments, read_file, parse_signed_number
    extern file_buffer

_start:
    call check_arguments    
    jc .exit               ; если ошибка - выход

    call read_file         
    jc .exit               ; если ошибка - выход

    ; Парсинг чисел из файла
    mov esi, file_buffer   ; ESI = указатель на данные файла
    mov edi, 0             ; EDI = индекс в массиве (счетчик элементов)

.parse_loop:
    call parse_signed_number  ; парсим одно число из файла
    jc .parse_done           ; если конец файла или ошибка - выходим
    mov [array + edi*2], ax  ; сохраняем число в массив (2 байта на элемент)
    inc edi                  ; увеличиваем счетчик элементов
    jmp .parse_loop          ; продолжаем парсинг

.parse_done:
    mov [array_size], edi    

    ; Ввод C
    mov esi, msg_enter_c
    call print_string        
    call input_signed        
    jc .exit                
    mov [c_value], ax       

    ; Ввод D
    mov esi, msg_enter_d
    call print_string     
    call input_signed       
    jc .exit               
    mov [d_value], ax       

    ; Обработка массива
    mov ecx, [array_size]    ; ECX = количество элементов в массиве
    mov dword [result_count], 0 ; обнуляем счетчик результата
    mov esi, 0               ; ESI = индекс текущего элемента

.process_loop:
    mov ax, [array + esi*2]  ; загружаем текущий элемент массива
    cmp ax, 0                ; если <= 0 - пропускаем
    jle .next                
    cmp ax, [d_value]        ; если < D - пропускаем
    jl .next                 
    cmp ax, [c_value]        ; если > C - пропускаем
    jg .next                 
    inc dword [result_count] ; увеличиваем счетчик
    
.next:
    inc esi                  
    loop .process_loop       

    ; Вывод результата
    mov esi, msg_result
    call print_string        
    mov eax, [result_count]  
    call print_signed        
    mov esi, msg_newline
    call print_string        

.exit:
    mov eax, 1              ; системный вызов exit
    mov ebx, 0              ; код возврата 0
    int 0x80