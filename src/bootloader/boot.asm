ORG 0x7C00                                                  ; mem addr where bios loads boot sector (first 512 bytes)
BITS 16                                                     ; specifies we're working with 16 bits instead of 32

JMP SHORT main                                              ; jump to address within -128 + 127 bytes relative to current
NOP                                                         ; placeholder/padding

bdb_oem:                        DB      'MSWIN4.1'          ; BIOS parameter Block
bdb_bytes_per_sector:           DW      512                 ; Disk sector size
bdb_sectors_per_cluster:        DB      1                   ; amount of contiguous sectors per cluster
bdb_reserved_sectors:           DW      1                   ; number of sectors reserved for special use
bdb_fat_count:                  DB      2                   ; # of File Allocation Tables in volume
bdb_dir_entries_count:          DW      0E0h                ; max # of directory entries for root directory
bdb_total_sectors:              DW      2880                ; 16-bit total number sectors 
bdb_media_descriptor_type:      DB      0F0h                ; legacy value to ID physical media type 0F0h = floppy disk
bdb_sectors_per_fat:            DW      9                   ; # of sectors occupied by single FAT
bdb_sectors_per_track:          DW      18                  ; # indicates how many sectors exist on each track of disk
bdb_heads:                      DW      2                   ; # of heads/surfaces used by disk 
bdb_hidden_sectors:             DD      0                   ; # of sectors preceding start of this volume
bdb_large_sector_count:         DD      0                   ; 32-bit sector count, used when count > 16-bits

ebr_drive_number:               DB      0                   ; to ID drive number from volume that was loaded
                                DB      0                   ; padding
ebr_signature:                  DB      29h                 ; fixed-signature that indicates there is an EBR 
ebr_volume_id:                  DB      12h, 34h, 56h, 78h  ; 4 bytes, stored in little-endian order to ID volume
ebr_volume_label:               DB      'EKKO_OS    '       ; 11-byte, ASCII label used as volume name 
ebr_system_id:                  DB      'FAT12   '          ; 8-byte, label of the file system type

main:
    XOR ax, ax                                              ; zero out registers 
    MOV ds, ax
    MOV es, ax
    MOV ss, ax

    MOV sp, 0x7C00                                          ; pointer to location of bootloader
                
    ; MOV [ebr_drive_number], dl
    ; MOV ax, 1                                             ; LBA index
    ; MOV cl, 1
    ; MOV bx, 0x7E00                                        ; mem address where disk sector is to be loaded
    ; CALL disk_read

    MOV si, os_boot_msg
    CALL print_msg
                                                            ;  FAT 12 -> 4 segments
                                                            ; reserved segment = bdb_reserved_sectors = 1
                                                            ; FAT: bdb_sectors_per_fat(9) * bdb_fat_count(2) = 18 sectors 
                                                            ; Root Directory: 
                                                            ; Data
    MOV ax, [bdb_sectors_per_fat]
    MOV bl, [bdb_fat_count]                                 
    XOR bh, bh
    MUL bx ;  bdb_sectors_per_fat * bdb_fat_count

    ADD ax, [bdb_reserved_sectors]                          ; LBA of root directory         
    PUSH ax

    MOV ax, [bdb_dir_entries_count]                         ; number of root entries
    SHL ax, 5                                               ; bit shift -> ax *= 32
    XOR dx, dx                                                        
    DIV word [bdb_bytes_per_sector]                         ; (32 * num of entries) / bytes per sector
    
    TEST dx, dx                                             ; check if there was a remainder after division
    JZ read_dir_from_disk                                   ; if no remainder then we dont incremenht
    INC ax                                                  ; otherwise we do to round

    HLT
    JMP halt

read_dir_from_disk:
    MOV cl, al                                              ; size of root dir into cl
    POP ax
    MOV dl, [ebr_drive_number]
    MOV bx, disk_buffer
    CALL disk_read

    XOR bx, bx
    MOV di, disk_buffer

search_kernel:
    MOV si, file_kernel_bin                                 ; address of kernel bin file
    MOV cx, 11                                              ; size in bytes of file name
    PUSH di
    REPE CMPSB                                              ; compare s
    POP di
    JE found_kernel

    ADD di, 32                                              ; next directory entry
    INC bx                                                  ; inc, used to keep track of directories checked
    CMP bx, [bdb_dir_entries_count]                         ; check if we've looked through all directories
    JL search_kernel                                        ; search again if we havnt reached the count

    JMP kernel_not_found


kernel_not_found:
    MOV si, kernel_not_found_msg
    CALL print_msg
    
    HLT
    JMP halt

found_kernel:
    MOV ax, [di + 26]

halt:
    JMP halt                                                ; used so if it doesnt halt it will call itself

                                                            ; input LBA index in ax
                                                            ; cx [bits 0- 5]: sector number
                                                            ; cx [bits 6- 15]: cylinder
lba_to_chs:                                                 ; dh: head 
    PUSH ax
    PUSH dx

    XOR dx, dx                                              ; LBA -> CHS Sector = (LBA % sectors per track ) + 1
    DIV WORD [bdb_sectors_per_track]                        ; LBA index is ax dividing by sectors per track, quotient in ax remainder in dx
    INC dx                                                  ; ading one to to modulus used in calc CHS sector 
    MOV cx, dx                                              
                                                            ; LBA -> CHS Head = (LBA % sectors per track) % number of heads 
    XOR dx, dx                                              ; LBA -> CHS Cylinder (LBA / sectors per trac) / number of heads
    DIV WORD [bdb_heads]

    MOV dh, dl                                              ; head
    MOV ch, al                                              ; lower 8 bits of cylinder
    SHL ah, 6                                               ; bit shift to keep top 2 bits, since we already stored lower 8 bits 
    OR cl, ah                                               ; add the result

    POP ax
    MOV dl, al                                              ; moving drive number into al
    POP ax 

    RET                                                     ; returns to disk_read

disk_read:
    PUSH ax
    PUSH bx
    PUSH cx
    PUSH dx
    PUSH di

    CALL lba_to_chs                                         ; file format conversion 

    MOV ah, 02h                                             ; INT 13 status that were setting to read 
    MOV di, 3                                               ; counter for loop  disk reads tries >= 3 

retry: 
    STC                                                     ; sets CF to 1 in case BIOS doesnt, CF used to indicate error
    INT 13h                                                 ; INT 13,2 BIOS disk interrupt to read disk sectors  
    JNC done_read                                           ; Jump if interrupt set carry to 0 (success)

    call disk_reset                                         ; else we reset the disk to retry and decrement counter (di) 
    DEC di

    TEST di, di                                             ; process to retry if we still have tries left (di)
    JNZ retry                                               

fail_disk_read:                                             ; used to print out that the disk read has failed
    MOV si, read_fail_msg                                   
    CALL print_msg
    HLT
    JMP halt                                                ; in cause it doesnt halt we call inf halt    

disk_reset:
    PUSHA                                                   ; push all GPR onto stack 
    MOV ah, 0                                               ; INT 13, status 0 (ah) will reset disk, req drive_num in dl
    STC                                                     ; carry set again in case its not already set
    INT 13h

    JC fail_disk_read                                       ; incase drive fails to reset 

    POPA                                                    ; pop all GPR 
    RET                                                     ; returns to retry

done_read:
    POP di
    POP dx
    POP cx
    POP bx
    POP ax

    RET


print_msg:                                                  ; pushing registers used to print msg into stack
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

done_print:                                                 ; pops items in stack used, returns regs to addresses when they were first pushed
    POP bx
    POP ax
    POP si
    RET                                                     ; returns back to main

os_boot_msg:         DB 'Loading... ', 0x0D, 0x0A, 0
read_fail_msg:       DB 'Failed to read disk after retying!', 0x0D, 0x0A, 0

file_kernel_bin      DB 'KERNEL  BIN'                        ; kernel filename, 11 bytes for FAT12 file format
kernel_not_found_msg DB 'KERNEL.BIN not found!!'
kernel_cluster       DW 0                                   ; starting cluster of kernel
kernel_load_segment  EQU 0x2000                             ; location where kernel will be loaded
kernel_load_offset   EQU 0                                  ; offset if needed from where loaded

TIMES 510 - ($ - $$) DB 0                                   ; writes 0 for 510 lines minus what this program takes up
DW 0AA55h                                                   ; signature for BIOS to search for

disk_buffer: