ORG 0x0                                                     ; starting memeory address
BITS 16                                                     ; specifies we're working with 16 bits instead of 32

start:
    MOV si, os_boot_msg
    CALL print
    HLT

halt:
JMP halt                                                    ; used so if it doesnt halt it will call itself
; ----------------------------------------------------------
print:
    PUSH si
    PUSH ax
    PUSH bx

print_loop:
    LODSB                                                   ; load byte from memory into al reg and inc SI by 1 since DF is not specified
    OR al, al                                               ; check if we reach null terminator
    JZ done_print

    MOV ah, TELETYPE_OUTPUT                                 ; Teletype output mode (print single char on screen) 
    MOV bh, 0                                               ; specifies the page number to display w 0 being default page
    INT BIOS_VIDEO                                          ; call for BIOS video services (video interrupt)

    JMP print_loop                                          ; jumps back to print another char untill we hit null terminator

done_print:
    POP bx
    POP ax
    POP si
    RET

os_boot_msg:                    DB 'OS has booted!!!! Please enjoy :)', 0x0D, 0x0A, 0
BIOS_VIDEO                      EQU 0x10
TELETYPE_OUTPUT                 EQU 0x0E
