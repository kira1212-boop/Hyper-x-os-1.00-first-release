; --- Read.asm | SECURE BUFFERED CORE TRACK FILE DECODER ---

run_file_reader_module:
    mov si, read_seeking_msg
    call print_spaced

    ; Configure system block reading arrays to scan storage block 50
    mov word [dap_packet + 4], file_contents_buffer
    mov dword [dap_packet + 8], 50         ; Locate targeted structural sector node
    
    mov ah, 0x42                           ; Extended BIOS Read Block Sector command link
    mov dl, [boot_drive]
    mov si, dap_packet
    int 0x13
    jc .read_fault
    
    mov si, read_header_msg
    call print_spaced
    
    ; Display data from memory array cache
    mov si, file_contents_buffer
    call print_spaced
    
    mov si, newline_str
    call print
    jmp shell_prompt

.read_fault:
    mov si, read_err_msg
    call print_spaced
    jmp shell_prompt

read_seeking_msg db '[READ] Initializing block driver pipelines for sector target 50...', 13, 10, 0
read_header_msg  db '--- FILE PAYLOAD ENVELOPE CONTENTS OUT FROM STORAGE SECTOR ---', 13, 10, 0
read_err_msg     db 'ERROR: Failed to map file structure data loops off designated drive blocks.', 13, 10, 0
