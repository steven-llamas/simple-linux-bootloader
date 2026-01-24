#ifndef PRINT_H
#define PRINT_H

#include "stdio.h"

// @param c the char to be printed
// @param page used to select which monitor to output text
void _cdecl x86_video_write_char_teletype(char c, uint8_t page); // call to extern print.asm func
// @param dividend the 64-bit value to be divided
// @param divisor the 32-bit value to divide by
// @param quotient_out pointer to variable where quotient stored
// @param remainder_out pointer to variable where remainder stored
void _cdecl x86_div64_32(uint64_t dividend, uint32_t divisor,
                         uint64_t *quotient_out, uint32_t *remainder_out);

#endif // PRINT_H
