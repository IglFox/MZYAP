#include <stdio.h>
#include <stdint.h>

int16_t a_sign, b_sign;
uint16_t a_unsign, b_unsign;

int16_t result_sign;
uint16_t result_unsign;

extern void asm_sign();
extern void asm_unsign();

void print_diagram() {
    printf("╭─────────────────╮\n");
    printf("│   Вход: a, b    │\n");
    printf("╰─────────────────╯\n");
    printf("        │\n");
    printf("        ├─ a < b ────> 100 + a/b\n");
    printf("        │\n");
    printf("        ├─ a > b ────> 32\n");
    printf("        │\n");
    printf("        └─ a = b ────> a*a/b\n\n");
}

int calc_sign(int16_t a, int16_t b) {
    if (a == b) {
        return a*a/2;
    } else if (a > b) {
        return 32;
    } else {
        return (100+a/b);
    }
}

int calc_unsign(uint16_t a, uint16_t b) {
    if (a == b) {
        return a*a/2;
    } else if (a > b) {
        return 32;
    } else {
        return (100+a/b);
    }
}

int main() {
    print_diagram();
    printf("Input signed (-32768 >x< 32767) a and b: \n");
    printf("a-> ");
    scanf("%hd", &a_sign);
    printf("b-> ");
    scanf("%hd", &b_sign);
    
    result_sign = calc_sign(a_sign, b_sign);
    printf("Result in C: %d  |  ", result_sign);
    
    asm_sign();
    printf("Result in ASM: %d\n\n", result_sign);
    
    printf("Input unsigned (0 >x< 65535) a and b: \n");
    printf("a-> ");
    scanf("%hd", &a_unsign);
    printf("b-> ");
    scanf("%hd", &b_unsign);

    result_unsign = calc_unsign(a_unsign, b_unsign);
    printf("Reslt in C: %u   |  ", result_unsign);

    asm_unsign();
    printf("Result in ASM: %u\n\n", result_unsign);
    
    return 0;
}