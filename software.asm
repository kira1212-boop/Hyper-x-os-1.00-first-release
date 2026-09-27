; --- APPLICATIONS PACKAGING AND DEPLOYMENT HUB ---

run_swc_module:
    mov si, swc_title
    call print
    mov si, swc_apps
    call print

.prompt_install_app:
    mov si, swc_prompt
    call print
    mov di, cmd_buffer

.swc_key:
    mov ah, 0x00
    int 0x16
    cmp al, 13          
    je .process_app
    cmp al, 8           
    je .swc_key
    stosb
    mov ah, 0x0e
    int 0x10
    jmp .swc_key

.process_app:
    mov byte [di], 0
    mov si, newline_str
    call print
    
    cmp byte [cmd_buffer], 0
    je .exit_swc

    mov si, cmd_buffer
    mov di, app_name_calc
    call string_compare
    jc .deploy_calc
    
    mov si, err_swc_missing
    call print
    jmp run_swc_module

.deploy_calc:
    mov si, swc_downloading
    call print
    
    mov si, internal_calc_binary
    mov di, sector_buffer
    mov cx, 32
    rep movsd
    
    mov si, swc_success
    call print
.exit_swc:
    jmp shell_prompt

swc_title       db 13, 10, '--- HYPER SYSTEM DIGITAL SOFTWARE REPOSITORY ---', 13, 10, \
                   'Package Target Identifiers | Application Class Type | Size Details', 13, 10, \
                   '------------------------------------------------------------------', 13, 10, 0
swc_apps        db '  calc                     | Machine Binary (.HXP) | 256B Size Block', 13, 10, \
                   '  terminal-pro             | Extension Link (.HXPA)| 512B Size Block', 13, 10, \
                   'Press [Enter] with a blank parameter string to back out to shell.', 13, 10, 0
swc_prompt      db 'Enter target software identifier to install -> ', 0
swc_downloading db '[FETCH] Accessing catalog index... Unpacking binary contents... Done.', 13, 10, 0
swc_success     db '[SUCCESS] App deployment tracked: /APPS/CALC.HXP registered into index.', 13, 10, 0
err_swc_missing db 'ERROR: Target package identifier signature not found in local log file.', 13, 10, 0

app_name_calc   db 'calc', 0
internal_calc_binary:
    db 0xB8, 0x01, 0x00, 0xBB, 0x02, 0x00, 0x01, 0xD8, 0xC3  
    times 119 db 0x00
