#include "stdio.h"
#include "print.h"
#include "stdint.h"

const char possibleCharacters[] = "0123456789abcdef";

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

void print_far(const char far *s)
{
    while (*s)
    {
        print_c(*s);
        s++;
    }
}

void _cdecl printf(const char *format, ...)
{
    printf_context context;
    context.argp = ((int *)&format + 1); // address of format on the stack adv by 1
    context.state = PRINTF_STATE_START;
    context.length = PRINTF_LEN_START;
    context.sign = false;
    context.radix = 10;

    while (*format)
    {
        set_state(&context, format);
        format++;
    }
}

void set_state(printf_context *ctx, const char *fmt)
{

    switch (ctx->state)
    {
    case PRINTF_STATE_START:
        if (*fmt == FORMAT_PERCENT)
        {
            ctx->state = PRINTF_STATE_LEN;
        }
        else
        {
            print_c(*fmt);
        }
        break;

    case PRINTF_STATE_LEN:
        if (*fmt == FORMAT_SHORT)
        {
            ctx->length = PRINTF_LEN_SHORT;
            ctx->state = PRINTF_STATE_SHORT;
        }
        else if (*fmt == FORMAT_LONG)
        {
            ctx->length = PRINTF_LEN_LONG;
            ctx->state = PRINTF_STATE_LONG;
        }
        else
        {
            goto PRINTF_STATE_SPEC_;
        }
        break;

    case PRINTF_STATE_SHORT:
        if (*fmt == FORMAT_SHORT)
        {
            ctx->length = PRINTF_LEN_SHORT_SHORT;
            ctx->state = PRINTF_STATE_SPEC;
        }
        else
        {
            goto PRINTF_STATE_SPEC_;
        }
        break;

    case PRINTF_STATE_LONG:
        if (*fmt == FORMAT_LONG)
        {
            ctx->length = PRINTF_LEN_LONG_LONG;
            ctx->state = PRINTF_STATE_SPEC;
        }
        else
        {
            goto PRINTF_STATE_SPEC_;
        }
        break;

    case PRINTF_STATE_SPEC:
    PRINTF_STATE_SPEC_:
        check_format(ctx, fmt);

        ctx->state = PRINTF_STATE_START;
        ctx->length = PRINTF_LEN_START;
        ctx->radix = 10;
        ctx->sign = false;

        break;
    }
}

void check_format(printf_context *ctx, const char *fmt)
{
    switch (*fmt)
    {
    case FORMAT_CHAR:
        print_c((char)*ctx->argp);
        ctx->argp++;
        break;

    case FORMAT_STRING:
        if (ctx->length == PRINTF_LEN_LONG ||
            ctx->length == PRINTF_LEN_LONG_LONG)
        {
            print_far(*(const char far **)ctx->argp);
            ctx->argp += 2;
        }
        else
        {
            print_str(*(const char **)ctx->argp);
            ctx->argp++;
        }
        break;

    case FORMAT_PERCENT:
        print_c(FORMAT_PERCENT);
        break;

    case FORMAT_DECIMAL:
    case FORMAT_INT:
        ctx->radix = 10;
        ctx->sign = true;
        ctx->argp = printf_num(ctx->argp, ctx->length,
                               ctx->sign, ctx->radix);
        break;

    case FORMAT_U_INT:
        ctx->radix = 10;
        ctx->sign = false;
        ctx->argp = printf_num(ctx->argp, ctx->length,
                               ctx->sign, ctx->radix);
        break;

    case FORMAT_HEX_UPPER:
    case FORMAT_HEX_LOWER:
    case FORMAT_HEX_POINTER:
        ctx->radix = 16;
        ctx->sign = false;
        ctx->argp = printf_num(ctx->argp, ctx->length,
                               ctx->sign, ctx->radix);
        break;
    case FORMAT_OCTAL:
        ctx->radix = 8;
        ctx->sign = false;
        ctx->argp = printf_num(ctx->argp, ctx->length,
                               ctx->sign, ctx->radix);
        break;
    default:
        break;
    }
}

const int *printf_num(const int *argp, int length,
                      bool sign, int radix)
{
    char buffer[32];
    unsigned long long number;
    int number_sign = 1;
    int pos = 0;

    switch (length)
    {
    case PRINTF_LEN_SHORT_SHORT:
    case PRINTF_LEN_SHORT:
    case PRINTF_LEN_START:
        if (sign)
        {
            int num = *argp;
            if (num < 0)
            {
                num = -num;
                number_sign = -1;
            }
            number = (unsigned long long)num;
        }
        else
        {
            number = *(unsigned int *)argp;
        }
        argp++;
        break;

    case PRINTF_LEN_LONG:
        if (sign)
        {
            long int num = *(long int *)argp;
            if (num < 0)
            {
                num = -num;
                number_sign = -1;
            }
            number = (unsigned long long)num;
        }
        else
        {
            number = *(unsigned long int *)argp;
        }
        argp += 2;
        break;

    case PRINTF_LEN_LONG_LONG:
        if (sign)
        {
            long long int num = *(long long int *)argp;
            if (num < 0)
            {
                num = -num;
                number_sign = -1;
            }
            number = (unsigned long long)num;
        }
        else
        {
            number = *(unsigned long long int *)argp;
        }
        argp += 4;
        break;
    }

    do
    {
        uint32_t rem;
        x86_div64_32(number, radix, &number, &rem);
        buffer[pos++] = possibleCharacters[rem];
    } while (number > 0);

    if (sign && number_sign < 0)
    {
        buffer[pos++] = '-';
    }

    while (--pos >= 0)
    {
        print_c(buffer[pos]);
    }

    return argp;
}
