; --- HYPER SYSTEM GRAPHICAL USER INTERFACE INFRASTRUCTURE ---

init_ui_environment:
    call draw_top_status_bar
    call draw_bottom_footer_bar
    call clear_workspace_area
    ret

refresh_ui_canvas:
    ; Re-allocates color states down active canvas limits
    mov ah, 0x06
    mov al, 0
    mov cx, 0x0100      ; Start at Row 1, Column 0
    mov dx, 0x174F      ; End at Row 23, Column 79
    mov bh, [current_theme_color]
    int 0x10
    ret

draw_top_status_bar:
    mov ah, 0x06
    mov al, 0
    mov cx, 0x0000
    mov dx, 0x004F      
    mov bh, 0x70        ; Black text on elegant Light Gray background bar
    int 0x10
    
    mov ah, 0x02
    xor bh, bh
    xor dh, dh
    mov dl, 2
    int 0x10
    mov si, ui_header_title
    call print
    ret

draw_bottom_footer_bar:
    mov ah, 0x06
    mov al, 0
    mov cx, 0x1800
    mov dx, 0x184F      
    mov bh, 0x74        ; Red accent labels over gray taskbar strip
    int 0x10
    
    mov ah, 0x02
    xor bh, bh
    mov dh, 24
    mov dl, 1
    int 0x10
    mov si, ui_footer_text
    call print
    ret

clear_workspace_area:
    mov ah, 0x06
    mov al, 0
    mov cx, 0x0100      ; Target tracking from row index 1
    mov dx, 0x174F      ; Stop before row index 24
    mov bh, [current_theme_color]
    int 0x10
    
    ; Safely drop cursor down to Row 1 to keep text out of the status header strip
    mov ah, 0x02
    xor bh, bh
    mov dh, 1
    mov dl, 0
    int 0x10
    ret

ui_header_title  db ' HYPER X OS 1.00  |  System Integrity: Secure  | Platform: Hybrid', 0
ui_footer_text   db ' Shortcuts: Type "theme" to alter system palette | "help" for modules', 0
