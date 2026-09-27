; --- HARDWARE PARTITION & FAT32 FORMATTING UTILITY ENGINE (DUAL TARGET) ---

run_installer_module:
    mov si, inst_welcome
    call print_spaced

    ; --- STEP 1: INTERACTIVE TARGET DEVICE SELECTOR ---
    mov si, select_target_drive_msg
    call print_spaced

.prompt_drive_selection:
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10            ; Echo character selection to the active screen
    push ax
    mov si, newline_str
    call print
    pop ax

    cmp al, '1'
    je .target_real_disk
    cmp al, '2'
    je .target_fake_disk
    
    mov si, err_invalid_drive_choice
    call print_spaced
    jmp .prompt_drive_selection

.target_real_disk:
    mov byte [target_drive_id], 0x80      ; Bind execution parameter vectors to Primary Boot Disk
    mov si, selected_real_msg
    call print_spaced
    jmp .prompt_table_type

.target_fake_disk:
    mov byte [target_drive_id], 0x81      ; Bind execution parameter vectors to Secondary Sandbox Disk
    mov si, selected_fake_msg
    call print_spaced

; --- STEP 2: FORMAT SPECIFICATION PARAMETER CHECK ---
.prompt_table_type:
    mov si, target_menu_msg
    call print
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10            
    push ax
    mov si, newline_str
    call print
    pop ax

    cmp al, 'M'
    je .deploy_real_mbr
    cmp al, 'm'
    je .deploy_real_mbr
    
    mov si, err_invalid_choice
    call print_spaced
    jmp .prompt_table_type

.deploy_real_mbr:
    mov si, inst_progress_mbr
    call print_spaced
    call clear_shared_buffer
    
    ; --- STEP 3: LAYOUT REAL MBR PARTITION LAYOUT ---
    mov byte [sector_buffer + 446], 0x80      ; Bootable partition tracking flag state: ACTIVE
    mov byte [sector_buffer + 450], 0x0C      ; Partition Structural Format Identifier: FAT32 LBA Mode
    mov dword [sector_buffer + 454], 2048     ; Standard MBR layout baseline cluster alignment sector: 2048
    mov dword [sector_buffer + 458], 122880   ; Partition Capacity Sector Bounds Scale Mapping: 60MB Size
    mov word [sector_buffer + 510], 0xAA55    ; Absolute Master Boot Signature

    xor ax, ax                                ; Force alignment vector target to Absolute Sector LBA 0
    call write_real_hardware_sector
    jc .disk_error

    ; --- STEP 4: DEPLOY REAL SPECIFICATION COMPLIANT FAT32 VBR METADATA ---
    mov si, inst_progress_vbr
    call print_spaced
    call clear_shared_buffer

    mov word [sector_buffer + 11], 512        ; Sector Byte Configuration Footprint Limits: 512B
    mov byte [sector_buffer + 13], 8          ; Sectors Per Dynamic Allocation Cluster Frame: 8 (4KB Clusters)
    mov word [sector_buffer + 14], 32         ; Reserved Bootstrap Structural Sectors Count: 32
    mov byte [sector_buffer + 16], 2          ; Identical Redundant File Allocation Tables Count: 2
    mov byte [sector_buffer + 21], 0xF8       ; Hard Storage Fixed Media ID flag descriptor
    mov dword [sector_buffer + 32], 122880    ; Total Large Sectors allocation space parameters
    mov dword [sector_buffer + 36], 120       ; Sector capacity scale limit sizes for each active FAT grid: 120
    mov dword [sector_buffer + 44], 2         ; Native initialization location root entry cluster layer index: 2
    mov word [sector_buffer + 48], 1          ; Active System File Allocation tracking block trace info: LBA 1
    mov word [sector_buffer + 50], 6          ; Active cluster parameters storage recovery mirror: LBA 6
    mov byte [sector_buffer + 66], 0x29       ; Extended execution authorization sign identification code
    mov dword [sector_buffer + 67], 0x87654321 ; Random Serial Volume identification tracking register code

    ; Volume Label: "HXOS_VOLUME" (11 Character padded array block structure string)
    mov dword [sector_buffer + 71], 0x534f5848 ; "HXOS"
    mov dword [sector_buffer + 75], 0x4f565f5f ; "__VO"
    mov dword [sector_buffer + 79], 0x454d554c ; "LUME"
    mov dword [sector_buffer + 83], 0x33544146 ; "FAT3"
    mov word [sector_buffer + 87], 0x2032      ; "2 "
    mov word [sector_buffer + 510], 0xAA55    ; Valid Boot Signature Code

    mov ax, 2048                              ; Flash VBR parameter array payload straight down to LBA Block 2048
    call write_real_hardware_sector
    jc .disk_error

    ; --- STEP 5: DEPLOY BASELINE ALLOCATION FILE ALLOCATION METADATA TRACKS (FAT 1 & FAT 2) ---
    mov si, inst_progress_fats
    call print_spaced
    call clear_shared_buffer
    
    mov dword [sector_buffer], 0x0FFFFFF8      ; Entry 0: Media Type Copy Descriptor Code Flag
    mov dword [sector_buffer + 4], 0xFFFFFFFF ; Entry 1: End of Cluster Chain Marker Code Flag
    mov dword [sector_buffer + 8], 0x0FFFFFFF ; Entry 2: Root Directory Cluster Chain End Marker Code Flag

    ; Write out FAT 1 start boundary sector (Partition Offset 2048 + 32 Reserved blocks = LBA 2080)
    mov ax, 2080
    call write_real_hardware_sector
    jc .disk_error

    ; Write out FAT 2 backup copy sector (FAT 1 offset 2080 + 120 Sectors Size Matrix = LBA 2200)
    mov ax, 2200
    call write_real_hardware_sector
    jc .disk_error

    ; --- STEP 6: ALLOCATE CLEAN INITIAL ROOT DIRECTORY STRUCTURAL SECTORS ---
    mov si, inst_progress_root
    call print_spaced
    call clear_shared_buffer                  ; Generate clean, blank unallocated folder data spaces

    ; Write Root Directory cluster start sector (LBA 2200 + 120 Sectors Size Matrix = LBA 2320)
    mov ax, 2320
    call write_real_hardware_sector
    jc .disk_error

    mov si, inst_success_real
    call print_spaced
    jmp shell_prompt

.disk_error:
    mov si, err_hardware_disk
    call print_spaced
    jmp shell_prompt

clear_shared_buffer:
    mov di, sector_buffer
    mov cx, 256
    xor ax, ax
    rep stosw
    ret

write_real_hardware_sector:
    mov byte [dap_packet + 2], 1               
    mov word [dap_packet + 4], sector_buffer   
    mov word [dap_packet + 6], 0x0000          
    mov [dap_packet + 8], ax                   
    mov dword [dap_packet + 10], 0
    mov dword [dap_packet + 12], 0
    
    mov ah, 0x43                               ; BIOS INT 0x13 Extensions: Extended Hardware Write Sector Command
    mov al, 0x00
    mov dl, [target_drive_id]                  ; Safely inject our dynamically selected target device parameter block
    mov si, dap_packet
    int 0x13
    ret

; --- Persistent Module Target Identity State Variables ---
target_drive_id db 0x80

; --- Module Communication Strings Blocks ---
inst_welcome              db '--- HYPER X OS REAL BARE-METAL SECTOR INSTALLER ---', 13, 10, 0
select_target_drive_msg   db 'Detecting target volumes... Select Drive Target Destination Index:', 13, 10, \
                             '  [1] Real Primary Disk Drive (Boot Source: 0x80)', 13, 10, \
                             '  [2] Virtual Fake Disk Drive (Sandbox Unit: 0x81)', 13, 10, \
                             'Choose Target Drive Number -> ', 0
                             
err_invalid_drive_choice  db 13, 10, 'ERROR: Device choice invalid. Press index 1 or 2.', 13, 10, 0
selected_real_msg         db '[WARN] Target linked explicitly to Boot Sector. Emulator locks may protect LBA 0.', 13, 10, 0
selected_fake_msg         db '[SAFE] Target linked cleanly to Secondary Sandbox Device Volume map storage array.', 13, 10, 0

target_menu_msg           db 'Confirm Formatting Table Array Type [M = Real MBR & Real FAT32 Format] -> ', 0
err_invalid_choice        db 13, 10, 'ERROR: Selection validation key missing. Type letter M.', 13, 10, 0
inst_progress_mbr         db '[STAGE 1/4] Overwriting hard partition tables mapping arrays... Syncing LBA 0...', 13, 10, 0
inst_progress_vbr         db '[STAGE 2/4] Injecting native FAT32 VBR geometry headers directly down to LBA 2048...', 13, 10, 0
inst_progress_fats        db '[STAGE 3/4] Streaming valid spec cluster configuration maps... Syncing FAT 1 & 2...', 13, 10, 0
inst_progress_root        db '[STAGE 4/4] Writing initial empty Root Directory cluster maps space bounds grid...', 13, 10, 0
inst_success_real         db '[SUCCESS] CORE INSTALLATION STEP COMPLETE! Storage target carries a real valid FAT32 mapping framework.', 13, 10, 0
err_hardware_disk         db 'CRITICAL DISK IO EXCEPTION: Peripheral signature bad or drive write access was rejected by host layers.', 13, 10, 0
