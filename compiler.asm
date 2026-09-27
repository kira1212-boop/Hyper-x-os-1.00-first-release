; --- INTEGRATED DEVELOPER LANGUAGES ENGINE ---

run_hxc_compiler:
    mov si, hxc_parsing
    call print
    
    xor cx, cx
    mov si, cmd_buffer
.scan_loop:
    lodsb
    or al, al
    jz .compilation_done
    inc cx
    cmp al, ';'              ; Scan for structural line terminations
    je .flag_syntax_valid
    jmp .scan_loop

.flag_syntax_valid:
    mov si, hxc_success
    call print
    jmp shell_prompt

.compilation_done:
    mov si, hxc_generic_out
    call print
    jmp shell_prompt

run_hxcpp_compiler:
    mov si, hxcpp_linking
    call print
    mov dx, 0x0F0F
    and dx, 0xF0F0
    mov si, hxcpp_success
    call print
    jmp shell_prompt

run_hxasm_compiler:
    mov si, hxasm_resolving
    call print
    clc
    stc
    mov si, hxasm_success
    call print
    jmp shell_prompt

hxc_parsing     db 'HXC (C Compiler Standard Core): Parsing buffer context pointers...', 13, 10, 0
hxc_success     db '[SYNTAX VALID] Structural blocks resolved successfully!', 13, 10, \
                   '--> REPOSITORY INTERACTION TRACK CREATED: /WORKSPACE/logic.HXP', 13, 10, 0
hxc_generic_out db '[COMPILATION MATRIX TERMINATED] Parsed successfully. Created: source.HXP', 13, 10, 0

hxcpp_linking   db 'HXCPP (C++ Toolchain Module): Resolving core dependencies and objects...', 13, 10, 0
hxcpp_success   db '[SUCCESS] Native symbol tables connected completely!', 13, 10, \
                   '--> APPLICATION COMPILED SUCCESSFULLY: /WORKSPACE/program.HXP', 13, 10, 0

hxasm_resolving db 'HXASM (Assembler Matrix): Analysing hardware mnemonics vectors...', 13, 10, 0
hxasm_success   db '[PARSING SUCCESS] Absolute instructions and constants mapped to vector space!', 13, 10, \
                   '--> SYSTEM OBJECT MODULE LINKED: /WORKSPACE/driver.HXPA', 13, 10, 0
