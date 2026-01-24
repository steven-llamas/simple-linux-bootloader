#ifndef STDIO_H
#define STDIO_H
#include "stdint.h"

// state machine for printf recreation
#define PRINTF_STATE_START 0
#define PRINTF_STATE_LEN 1
#define PRINTF_STATE_SHORT 2
#define PRINTF_STATE_LONG 3
#define PRINTF_STATE_SPEC 4

#define PRINTF_LEN_START 0
#define PRINTF_LEN_SHORT_SHORT 1
#define PRINTF_LEN_SHORT 2
#define PRINTF_LEN_LONG 3
#define PRINTF_LEN_LONG_LONG 4

#define FORMAT_PERCENT '%'
#define FORMAT_SHORT 'h'
#define FORMAT_LONG 'l'
#define FORMAT_CHAR 'c'
#define FORMAT_STRING 's'
#define FORMAT_DECIMAL 'd'
#define FORMAT_INT 'i'
#define FORMAT_U_INT 'u'
#define FORMAT_HEX_UPPER 'X'
#define FORMAT_HEX_LOWER 'x'
#define FORMAT_HEX_LOWER 'x'
#define FORMAT_HEX_POINTER 'p'
#define FORMAT_OCTAL 'o'

typedef struct
{
    const int *argp;
    int state;
    int length;
    int radix;
    bool sign;
} printf_context;

// @param c the character to print
void print_c(char c);
// @param s far ptr to a '/0' string. Required to support strings located outside default data segment in 16-bit real mode.
void print_far(const char far *s);
// @param str the pointer to the first char in char array
void print_str(const char *str);
// @param format structures how text is printed
// @param ... signifies there can ba a multitude of text,
// which is based on format
void _cdecl printf(const char *format, ...);
// @param ctx pointer to struct containing values to set state
// @param fmt the original format from printf func
void set_state(printf_context *ctx, const char *fmt);
// @param ctx pointer to struct containing values to set state
// @param fmt the original format from `printf` func
void check_format(printf_context *ctx, const char *fmt);
// @param argp pointer to arguments
// @param length length of number
// @param sign whether number is signed/unsigned
// @param radix number system's base (decimal, hexadicmal, etc.)
const int *printf_num(const int *argp, int length, bool sign, int radix);

#endif // STDIO_H
