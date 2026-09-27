; --- HXedit.asm | MINIMAL NON-BLOATED WORKSPACE TEXT EDITOR ---

run_text_editor_module:
    mov si, edit_welcome_msg
    call print_spaced
    
    ; Flush workspace buffer pointers
    mov di, file_contents_buffer
    mov cx, 512
    xor ax, ax
    rep stosb
    
    mov di, file_contents_buffer ; Reset target destination array tracking index

.capture_keys_loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 27          ; Escape Key breaks execution thread loop and triggers save routing
    je .save_commit_phase
    
    cmp al, 13          ; Carriage Return
    je .echo_newline
    
    ; Store text inside RAM buffer
    stosb
    
    ; Standard character echo out to display
    mov ah, 0x0e
    xor bh, bh
    int 0x10
    jmp .capture_keys_loop

.echo_newline:
    mov al, 13
    stosb
    mov ah, 0x0e
    int 0x10
    mov al, 10
    stosb
    mov ah, 0x0e
    int 0x10
    jmp .capture_keys_loop

.save_commit_phase:
    mov byte [di], 0    ; Append termination marker signature
    mov si, edit_saving_msg
    call print_spaced

    ; Point Disk Address Packet to our written text buffer
    mov word [dap_packet + 4], file_contents_buffer
    mov dword [dap_packet + 8], 50         ; Write directly down to clean storage LBA Block 50
    
    mov ah, 0x43                           ; Extended BIOS Hardware Sector Write Command
    mov dl, [boot_drive]
    mov si, dap_packet
    int 0x13
    jc .disk_fault
    
    mov si, edit_success_msg
    call print_spaced
    jmp shell_prompt

.disk_fault:
    mov si, edit_err_msg
    call print_spaced
    jmp shell_prompt

edit_welcome_msg db '--- HXedit 1.00 Sandbox Area | Press [ESC] to Save Track & Exit ---', 13, 10, 0
edit_saving_msg  db 13, 10, '[FLUSH] Committing raw document streams directly to storage LBA block 50...', 13, 10, 0
edit_success_msg db '[SUCCESS] Storage synchronization lock complete! Asset filed cleanly.', 13, 10, 0
edit_err_msg     db 'CRITICAL EXCEPTION: Storage IO write target rejected sector write sequence.', 13, 10, 0
