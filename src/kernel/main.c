#include "stdint.h"
#include "stdio.h"

void _cdecl cstart_()
{
    print_str("test func declared in c file...\r\n");
    printf("Formatted: %% %c %s \r\n", 'f', "Hello");
    printf("%d, %i, %x, %p, %ld", 1984, -2165, 0xaa, 0x7a, -105454545054l);
}
