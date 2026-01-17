ORG 0x7C00 ; mem addr where bios loads boot sector (first 512 bytes)
BITS 16 ; specifies we're working with 16 bits instead of 32


JMP SHORT main ; jump to address within -128 + 127 bytes relative to current
NOP ; placeholder/padding

bdb_oem:                        DB      'MSWIN4.1' ; BIOS parameter Block
bdb_bytes_per_sector:           DW      512  ; Disk sector size
bdb_sectors_per_cluster:        DB      1    ; amount of contiguous sectors per cluster
bdb_reserved_sectors:           DW      1    ; number of sectors reserved for special use
bdb_fat_count:                  DB      2    ; # of File Allocation Tables in bolume
bdb_dir_entries_count:          DW      0E0h ; max # of directory entries for root directory
bdb_total_sectors:              DW      2880 ; 16-bit total number sectors 
dbd_media_descriptor_type:      DB      0F0h ; legacy value to ID physical media type 0F0h = floppy disk
dbd_sectors_per_fat:            DW      9    ; # of sectors occupied by single FAT
bdb_sectors_per_track:          DW      18   ; # indicates how many sectors exist on each track of disk
bdb_heads:                      DW      2    ; # of heads/surfaces used by disk 
bdb_hidden_sectors:             DD      0    ; # of sectors preceding start of this volume
bdb_large_sector_count:         DD      0    ; 32-bit sector count, used when count > 16-bits

ebr_drive_number:               DB      0    ; to ID drive number from volume that was loaded
                                DB      0    ; padding
ebr_signature:                  DB      29h  ; fixed-signature that indicates there is an EBR 
ebr_volume_id:                  DB      12h, 34h, 56h, 78h ; 4 bytes, stored in little-endian order to ID volume
ebr_volume_label:               DB      'EKKO_OS    ' ; 11-byte, ASCII label used as volume name 
ebr_system_id:                  DB      'FAT12   '    ; 8-byte, label of the file system type

main:
    XOR ax, ax ; zero out registers 
    MOV ds, ax
    MOV es, ax
    MOV ss, ax

    MOV sp, 0x7C00
    MOV si, os_boot_msg
    CALL print
    HLT

halt:
    JMP halt ; used so if it doesnt halt it will call itself

print:
    PUSH si
    PUSH ax
    PUSH bx

print_loop:
    LODSB ; load byte from memory into al reg and inc SI by 1 since DF is not specified
    OR al, al ; check if we reach null terminator
    JZ done_print

    MOV ah, 0x0E ; Teletype output mode (print single char on screen) 
    MOV bh, 0 ; specifies the page number to display w 0 being default page
    INT 0x10 ; call for BIOS video services (video interrupt)

    JMP print_loop ; jumps back to print another char untill we hit null terminator

done_print:
    POP bx
    POP ax
    POP si
    RET

os_boot_msg: DB 'OS has booted!!!! Please enjoy OS :)', 0x0D, 0x0A, 0

TIMES 510 - ($ - $$) DB 0 ; writes 0 for 510 lines minus what this program takes up
DW 0AA55h ; signature for BIOS to search for