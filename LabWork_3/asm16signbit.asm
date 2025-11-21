section .text
    extern a_sign, b_sign
    extern result_sign

global asm_sign

asm_sign:
    MOV AX, [a_sign]
    MOV BX, [b_sign]
    
    CMP AX, BX

    jg bigger
    je equal
    jl smaller


smaller:
    ; 100 + a/b
    MOV AX, [a_sign]
    MOV CX, 100
    CWD
    IDIV BX
    ADD AX, CX
    jmp end


bigger:
    ; 32
    MOV AX, 32
    jmp end


equal:
    ; a*a/b
    MOV AX, [a_sign]
    IMUL AX
    CWD
    IDIV BX
    MOV BX, AX
    jmp end


end:
    MOV [result_sign], AX
    ret







