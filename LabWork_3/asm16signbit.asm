section .text
    extern a_sign, b_sign
    extern result_sign

global asm_sign

asm_sign:
    MOV AX, [a_sign]
    MOV BX, [b_sign]
    
    ; Проверка деления на ноль
    CMP BX, 0
    JE .error_zero
    
    CMP AX, BX
    JG .bigger
    JE .equal
    JL .smaller

.smaller:
    ; 100 + a/b
    MOV AX, [a_sign]
    CWD                 ; Расширяем AX в DX:AX для знакового деления
    IDIV BX             ; AX = a/b
    ADD AX, 100         ; AX = 100 + a/b
    ; Проверка переполнения
    JO .error_overflow
    JMP .end

.bigger:
    ; 32
    MOV AX, 32
    JMP .end

.equal:
    ; a*a/b
    MOV AX, [a_sign]
    IMUL AX             ; DX:AX = a * a
    IDIV BX             ; AX = (a*a)/b
    JMP .end

.error_zero:
    MOV AX, 0x7FFF      ; Специальное значение для ошибки деления на ноль
    JMP .end

.error_overflow:
    MOV AX, 0x7FFE      ; Специальное значение для переполнения

.end:
    MOV [result_sign], AX
    RET