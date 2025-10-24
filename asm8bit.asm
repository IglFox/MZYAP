section .text
extern b, a, c, num1, num2, res1

global func8bit

func8bit:
    ; (1)
    MOV AL, byte [b]
    MOV BL, 7
    IMUL BL ; al*bl->ax
    MOV CX, AX

    ; (2)
    MOV AX, 64
    MOV BL, byte [a] 
    IDIV BL

    ; (3)
    MOVSX BX, AL
    ADD BX, CX
    MOV [num1], BX

    ; (4)
    MOV AL, byte [b]
    MOV BL, byte [c]
    IMUL BL
    CWD

    ; (5)
    MOV BX, 2
    IDIV BX

    ; (6)
    MOV BX, 31
    SUB BX, AX
    MOV [num2], BX

    ; (7)
    MOV AX, [num1]
    CWD
    IDIV word [num2]
    MOV [res1], AX

    ret