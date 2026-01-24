BITS 16

section _TEXT class=CODE                                    ; class=CODE is for linker

TELETYPE_OUTPUT  EQU 0x0E
BIOS_VIDEO       EQU 0x10

global _x86_div64_32
    _x86_div64_32:
        push bp
        MOV bp, sp

        PUSH bx

        MOV eax, [bp + 8] ; upper 32 bits 
        MOV ecx, [bp + 12] ;divisor
        XOR edx, edx
        DIV ecx

        MOV bx, [bp + 16] ; upper 32 bits of quotient
        MOV [bx + 4], eax

        MOV eax, [bp + 4] ; lower 32 bits of dividend
        DIV ecx

        MOV [bx], eax
        
        MOV bx, [bp + 18]
        MOV [bx], edx

        POP bx

        MOV sp, bp
        POP bp
        RET

global _x86_video_write_char_teletype                      ; global -> directive that marks func as visable allows it to be accessed from outside file
_x86_video_write_char_teletype:
    PUSH bp
    MOV bp, sp                                             

    PUSH bx                                                 ; preserve address

    MOV ah, TELETYPE_OUTPUT
    MOV al, [bp + 4]                                        ; char to be printed
    MOV bh, [bp + 6]                                        ; page number

    INT BIOS_VIDEO

    POP bx
    MOV sp, bp

    POP bp

    RET 
    
