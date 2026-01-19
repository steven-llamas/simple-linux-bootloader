BITS 16 

section _ENTRY CLASS=CODE 

extern _cstart_

global entry

entry:
    CLI
    MOV ax, ds
    MOV ss, ax
    XOR sp, sp
    XOR bp, bp
    STI

    CALL _cstart_

    CLI
    HLT