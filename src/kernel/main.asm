BITS 16                                                     

section _ENTRY CLASS=CODE 

extern _cstart_

global entry

entry:
    CLI                                                     ; disable all interupts
    MOV ax, ds
    MOV ss, ax
    XOR sp, sp
    XOR bp, bp
    STI                                                     ; enable interrupts

    CALL _cstart_                                           ; calling external C program

    CLI                                                     
    HLT                                                     ; stop program execution