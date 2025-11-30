section .text
    extern a_unsign, b_unsign 
    extern result_unsign
    
global asm_unsign

asm_unsign:
    MOV AX, [a_unsign]
    MOV BX, [b_unsign]
    
    ; Проверка деления на ноль
    CMP BX, 0
    JE .error_zero
    
    CMP AX, BX
    JA .above
    JE .equal
    JB .below

.below:
    ; 100 + a/b
    MOV AX, [a_unsign]
    XOR DX, DX          ; обнуляем DX для деления
    DIV BX              ; AX = a/b
    ADD AX, 100         ; AX = 100 + a/b
    JMP .end

.above:
    ; 32
    MOV AX, 32
    JMP .end

.equal:
    ; a*a/b
    MOV AX, [a_unsign]
    MUL AX              ; DX:AX = a * a
    DIV BX              ; AX = (a*a)/b
    JMP .end

.error_zero:
    MOV AX, 0xFFFF

.end:
    MOV [result_unsign], AX
    RET