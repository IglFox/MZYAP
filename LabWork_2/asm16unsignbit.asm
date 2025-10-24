section .text
    extern a_unsign, b_unsign 
    extern result_unsign
    
global asm_unsign

asm_unsign:
    MOV AX, [a_unsign]
    MOV BX, [b_unsign]
    
    CMP AX, BX

    ja above
    je equal
    jb below


below:
    ; 100 + a/b
    MOV AX, [a_unsign]
    MOV CX, 100
    DIV BX
    ADD AX, CX
    jmp end


above:
    ; 32
    MOV AX, 32
    jmp end


equal:
    ; a*a/b
    MOV AX, [a_unsign]
    MUL AX
    DIV BX
    jmp end


end:
    MOV [result_unsign], AX
    ret

