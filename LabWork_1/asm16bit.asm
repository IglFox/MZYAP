section .text
extern b_2, a_2, c_2, num3, num4, res2
global func16bit

func16bit:
    ; (1)
    MOVZX EAX, word [b_2]
    MOV EBX, 7
    MUL EBX ; eax*ebx->edx:eax
    MOV RCX, RAX

    ; (2)
    MOV AX, 64
    MOV BX, word [a_2] 
    CWD
    DIV BX
    MOVZX RAX, AX

    ; (3)
    ADD RAX, RCX
    MOV [num3], RAX

    ; (4)
    MOVZX EAX, word [b_2]
    MOVZX EBX, word [c_2]
    MUL EBX            

    ; (5)
    MOV EBX, 2
    DIV EBX
   
    ; (6)
    MOV RBX, 31
    SUB RBX, RAX
    MOV [num4], RBX

    ; (7)
    MOV RAX, [num3]
    MOV RBX, [num4]
    CQO
    IDIV RBX

    MOV [res2], RAX
    ret
