section .data
    diagram_line1 db "╭─────────────────╮", 10, 0
    diagram_line2 db "│   Вход: a, b    │", 10, 0
    diagram_line3 db "╰─────────────────╯", 10, 0
    diagram_line4 db "        │", 10, 0
    diagram_line5 db "        ├─ a < b ────> 100 + a/b", 10, 0
    diagram_line6 db "        │", 10, 0
    diagram_line7 db "        ├─ a > b ────> 32", 10, 0
    diagram_line8 db "        │", 10, 0
    diagram_line9 db "        └─ a = b ────> a*a/b", 10, 10, 0
section .text
    extern print_string
    global print_diagram
;========================================
; Функция вывода диаграммы алгоритма
print_diagram:
    push esi
    push eax
    push ebx
    push ecx
    push edx

    mov esi, diagram_line1
    call print_string

    mov esi, diagram_line2
    call print_string

    mov esi, diagram_line3
    call print_string

    mov esi, diagram_line4
    call print_string

    mov esi, diagram_line5
    call print_string

    mov esi, diagram_line6
    call print_string

    mov esi, diagram_line7
    call print_string

    mov esi, diagram_line8
    call print_string

    mov esi, diagram_line9
    call print_string

    pop edx
    pop ecx
    pop ebx
    pop eax
    pop esi
    ret