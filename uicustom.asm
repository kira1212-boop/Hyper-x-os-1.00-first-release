; --- UI GRAPHICAL THEME AND CONFIGURATION MANAGER ---

run_uicustom_panel:
    mov si, theme_menu_title
    call print
    mov si, theme_options_list
    call print

.prompt_theme:
    mov si, theme_prompt_str
    call print
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10            ; Echo entry byte
    push ax
    mov si, newline_str
    call print
    pop ax

    cmp al, '1'
    je .set_ocean_blue
    cmp al, '2'
    je .set_matrix_green
    cmp al, '3'
    je .set_classic_gray
    cmp al, '4'
    je .set_error_red
    cmp al, '5'
    je .set_green_table
    cmp al, '6'
    je .set_monochrome_white
    cmp al, '7'
    je .set_temple_os 

    mov si, err_theme_selection
    call print
    jmp .prompt_theme

.set_ocean_blue:
    mov byte [current_theme_color], 0x1F  ; White text on deep ocean blue background
    jmp .apply_theme

.set_matrix_green:
    mov byte [current_theme_color], 0x0A  ; Light green code print arrays on terminal black background
    jmp .apply_theme

.set_classic_gray:
    mov byte [current_theme_color], 0x70  ; Charcoal terminal blocks over crisp light desk background sheets
    jmp .apply_theme

.set_error_red:
    mov byte [current_theme_color], 0x41 ; Blue text and Red background
    jmp .apply_theme

.set_green_table:
    mov byte [current_theme_color], 0x2F ;Tennis ball lookalike
    jmp .apply_theme

.set_monochrome_white:
    mov byte [current_theme_color], 0x0F ;pure 1995 prime
    jmp .apply_theme

.set_temple_os:
    mov byte [current_theme_color], 0x61 ;Temple Os!!!
    jmp .apply_theme

.apply_theme:
    call init_ui_environment              ; Instantly redraw entire shell window interface matrix
    mov si, theme_success_msg
    call print
    jmp shell_prompt

; --- Custom UI Theme Core Allocation Markers ---
current_theme_color db 0x1F  ; Default initialized state parameter

theme_menu_title      db 13, 10, '--- INTERFACE COLOR PALETTE CONFIGURATION ---', 13, 10, 0
theme_options_list    db ' [1] Deep Ocean Blue (Standard Core Layout)', 13, 10, \
                         ' [2] Terminal Matrix Cyber Green (Dark Room Layout)', 13, 10, \
                         ' [3] Retro Desktop Professional Gray (High Contrast Layout)', 13, 10, \
                         ' [4] Error Red and Blue (blue text and red background layout)', 13, 10, \
                         ' [5] Green table tennis ball (just green and white layout)', 13, 10, \
                         ' [6] Monochrome White (if you want 1995 look)', 13, 10, \
                         ' [7] Temple Os theme (hxos 1.00 is temple os cousin)', 13, 10, 0
theme_prompt_str      db 'Select desired layout scheme code number -> ', 0
theme_success_msg     db '[SUCCESS] Interface design specifications linked successfully!', 13, 10, 0
err_theme_selection   db 13, 10, 'ERROR: Color layout mapping values out of range.', 13, 10, 0
