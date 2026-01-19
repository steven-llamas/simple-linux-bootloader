#include "stdio.h"
#include "print.h"
#include "stdint.h"

void print_c(const char c)
{
    x86_video_write_char_teletype(c, 0);
}

void print_str(const char *str)
{
    while (*str) // while deref addr value != \0
    {
        print_c(*str);
        str++;
    }
}
