ORG 0x7C00                                                  ; mem addr where bios loads boot sector (first 512 bytes)
BITS 16                                                     ; specifies we're working with 16 bits instead of 32

main:
    XOR ax, ax                                              ; zero out registers 
    MOV ds, ax
    MOV es, ax
    MOV ss, ax

    MOV sp, 0x7C00
    MOV si, os_boot_msg
    CALL print
    HLT

halt:
JMP halt                                                    ; used so if it doesnt halt it will call itself

print:
    PUSH si
    PUSH ax
    PUSH bx

print_loop:
    LODSB                                                   ; load byte from memory into al reg and inc SI by 1 since DF is not specified
    OR al, al                                               ; check if we reach null terminator
    JZ done_print

    MOV ah, 0x0E                                            ; Teletype output mode (print single char on screen) 
    MOV bh, 0                                               ; specifies the page number to display w 0 being default page
    INT 0x10                                                ; call for BIOS video services (video interrupt)

    JMP print_loop                                          ; jumps back to print another char untill we hit null terminator

done_print:
    POP bx
    POP ax
    POP si
    RET

os_boot_msg: DB 'OS has booted!!!! Please enjoy OS :)', 0x0D, 0x0A, 0

TIMES 510 - ($ - $$) DB 0                                   ; writes 0 for 510 lines minus what this program takes up
DW 0AA55h                                                   ; signature for BIOS to search for