; --- HXcalu.asm | HYPER X OS BASIC MATH INTEGRATION UNIT ---

run_calculator_module:
    mov si, calc_title_str
    call print_spaced

.calc_loop:
    mov si, calc_prompt_val
    call print
    
    ; Capture Entry Digit Number 1
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10
    sub al, '0'
    mov bl, al          ; Store inside active register tracker B

    ; Capture Arithmetic Operational Command Sign
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10
    push ax             ; Preserve functional operator symbol trace flag

    ; Capture Entry Digit Number 2
    mov ah, 0x00
    int 0x16
    mov ah, 0x0e
    int 0x10
    sub al, '0'
    mov cl, al          ; Store inside secondary storage register tracker C

    mov si, calc_equals_str
    call print

    pop ax              ; Restore operator tracking variable
    cmp al, '+'
    je .do_add
    cmp al, '-'
    je .do_sub
    
    mov si, calc_err_msg
    call print_spaced
    jmp .exit_calc

.do_add:
    add bl, cl
    mov al, bl
    add al, '0'
    mov ah, 0x0e
    int 0x10
    jmp .exit_calc

.do_sub:
    sub bl, cl
    mov al, bl
    add al, '0'
    mov ah, 0x0e
    int 0x10

.exit_calc:
    mov si, newline_str
    call print
    jmp shell_prompt

calc_title_str  db '--- HXcalu 1.00 Native Arithmetic Computation Unit ---', 13, 10, \
                   'Usage instruction format: Type [Digit][Operator][Digit] (ex: 5+2, 9-4)', 13, 10, 0
calc_prompt_val db 'Enter expression -> ', 0
calc_equals_str db ' = ', 0
calc_err_msg    db 'ERROR: Unsupported math operator tracking logic token.', 13, 10, 0
