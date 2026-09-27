[org 0x7c00]

KERNEL_SECTORS equ 40   ; Increased allocation footprint to cover your new UI subsystems

hyperboot_start:
    cli                 
    xor ax, ax          
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00      
    sti                 

    mov [boot_drive], dl

    ; Clear Screen initially
    mov ah, 0x06
    mov al, 0
    mov cx, 0x0000
    mov dx, 0x1950
    mov bh, 0x1F        ; Default initial blue theme
    int 0x10

    mov ah, 0x02
    xor bh, bh
    xor dh, dh
    xor dl, dl
    int 0x10

    mov si, boot_msg
    call boot_print

    ; Safe Sector-by-Sector Loop loading payload
    mov bx, 0x8000      
    mov cl, 2           
    mov ch, 0           
    mov dh, 0           

.read_loop:
    push cx             
    mov ah, 0x02        
    mov al, 1           
    mov dl, [boot_drive] 
    int 0x13
    jc .disk_error      

    pop cx              
    inc cl              
    add bx, 512         
    cmp cl, 2 + KERNEL_SECTORS
    jne .read_loop      

    jmp 0x0000:0x8000   

.disk_error:
    mov si, err_disk
    call boot_print
    hlt

boot_print:
    lodsb
    or al, al
    jz .done
    mov ah, 0x0e
    int 0x10
    jmp boot_print
.done:
    ret

boot_drive db 0x80
boot_msg db 'HyperBOOT 1.00: Loading complete desktop stack modules...', 13, 10, 0
err_disk db 'BOOT ERROR: Storage read matrix interrupted!', 13, 10, 0

times 510-($-$$) db 0
dw 0xaa55
