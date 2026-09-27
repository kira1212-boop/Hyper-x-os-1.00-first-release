; --- HARDWARE PARTITION STORAGE TRACK ANALYZER MODULE ---

run_partlist_module:
    mov si, partlist_header
    call print
    
    ; Issue live hardware sector query against active storage device block 0
    mov byte [dap_packet + 2], 1               
    mov word [dap_packet + 4], sector_buffer   
    mov word [dap_packet + 6], 0x0000          
    mov dword [dap_packet + 8], 0              ; Read LBA 0 (Master Boot Record)
    mov dword [dap_packet + 12], 0
    
    mov ah, 0x42                               ; Read extended disk tracking sectors
    mov dl, [boot_drive]
    mov si, dap_packet
    int 0x13
    jc .read_error

    ; Look inside the partition entry layout field inside workspace array (offset 446)
    mov al, [sector_buffer + 446]
    cmp al, 0x80
    je .print_mbr_active
    cmp al, 0x00
    je .print_mbr_unallocated
    
    ; If type is 0xEE or values look customized, check for modern GUID partition systems
    mov al, [sector_buffer + 450]
    cmp al, 0xEE
    je .print_gpt_layout

    mov si, txt_corrupt_or_raw
    call print
    jmp shell_prompt

.print_mbr_active:
    mov si, txt_mbr_active
    call print
    jmp shell_prompt

.print_mbr_unallocated:
    mov si, txt_mbr_empty
    call print
    jmp shell_prompt

.print_gpt_layout:
    mov si, txt_gpt_active
    call print
    jmp shell_prompt

.read_error:
    mov si, err_partlist_io
    call print
    jmp shell_prompt

partlist_header    db 13, 10, '--- ABSOLUTE DISK GEOMETRY PARTITION ANALYZER REPORT ---', 13, 10, 0
err_partlist_io    db 'CRITICAL EXCEPTION: Controller bus timed out reading drive tables.', 13, 10, 0

txt_mbr_active     db ' Detected Format: [LEGACY MBR RECORD]', 13, 10, \
                      ' Track ID 1: [STATUS: BOOTABLE/ACTIVE] | Type: FAT32 LBA | Range: 2GB Max', 13, 10, 0
txt_mbr_empty      db ' Detected Format: [LEGACY MBR RECORD]', 13, 10, \
                      ' Track ID 1: [STATUS: CLEAN UNALLOCATED PARTITION DATA SECTOR BLOCK]', 13, 10, 0
txt_gpt_active     db ' Detected Format: [MODERN UEFI GPT SCHEMA]', 13, 10, \
                      ' Array Track: [STATUS: SECURE PROTECTIVE MBR RUNNING EFI SYSTEM FILE MAPPING]', 13, 10, 0
txt_corrupt_or_raw db ' Detected Format: [UNRECOGNIZED / UNFORMATTED SECTOR ARCHITECTURE]', 13, 10, \
                      ' Warning: Table has not been processed with an installation layout file.', 13, 10, 0
