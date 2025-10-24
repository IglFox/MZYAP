#include <stdio.h>
#include <stdint.h>

int8_t a, b, c;
int16_t num1, num2, res1;

uint16_t a_2, b_2, c_2;
int64_t num3, num4, res2;

extern void func8bit();
extern void func16bit();
//Функция для вычисления на си 8 бит
void c_calculate_8bit(int8_t a, int8_t b, int8_t c) {
    int16_t num, den, res; 
    printf("debug: %d %d %d\n", a, b, c);
    num = (b*7+64/a);
    den = (31-c*b/2);
    if (den != 0) {
        res = num / den;
    } else {
        printf("Divide by 0");
    }

    printf("Numerator is %d\n", num);
    printf("Denominator is %d\n", den);
    printf("Result is %d\n\n", res);
}

//Функция для вычисления на си 16 бит
void c_calculate_16bit(uint16_t a, uint16_t b, uint16_t c) {
    int64_t num, den, res; 
    printf("debug: %d %d %d\n", a, b, c);
    num = ((int64_t)b*7+64/(int64_t)a);
    den = (31-(int64_t)c*(int64_t)b/2);
    if (den != 0) {
        res = num / den;
    } else {
        printf("Divide by 0");
    }

    printf("Numerator is %lld\n", num);
    printf("Denominator is %lld\n", den);
    printf("Result is %lld\n\n", res);
}


int main() {
    printf("\n\n(b*7+64/a)/(31-c*b/2)\n\n");

    printf("Enter the values for 8-bit (signed char from -128 to 127):\n");
    printf("a = ");
    scanf("%hhd", &a); //hh - signed char, d - чтобы вывело как число
    printf("b = ");
    scanf("%hhd", &b);
    printf("c = ");
    scanf("%hhd", &c);

    // Вычисления на Си (8-бит)
    printf("\nCalculation on C 8-bit (signed char)\n");
    c_calculate_8bit(a, b, c);

    func8bit();
    printf("\nCalculation on ASM 8-bit (signed char)\n");
    printf("num=%d\nden=%d\nres=%d\n\n", num1, num2, res1);

    printf("\nEnter the values for 16-bit (unsigned short from 0 to 65535):\n");
    printf("a = ");
    scanf("%hu", &a_2); //hu - так википедия написала (h - char, u - unsigned)
    printf("b = ");
    scanf("%hu", &b_2);
    printf("c = ");
    scanf("%hu", &c_2);

    // Вычисления на Си (16-бит)
    printf("\nCalculation on C 16-bit (unsigned short)\n");
    c_calculate_16bit(a_2, b_2, c_2);

    // Вычисления на Ассах (16-бит)
    func16bit();
    printf("\nCalculation on ASM 16-bit (unsigned int)\n");
    printf("num= %lld\nden= %lld\nres= %lld\n\n", num3, num4, res2);

    return 0;
}
