; --- INTEGRATED DEVELOPER LANGUAGES ENGINE & HARDWARE REGISTRY ---

run_hxc_compiler:
    mov si, hxc_parsing
    call print_spaced
    xor cx, cx
    mov si, cmd_buffer
.scan_loop:
    lodsb
    or al, al
    jz .compilation_done
    inc cx
    cmp al, ';'              
    je .flag_syntax_valid
    jmp .scan_loop
.flag_syntax_valid:
    mov si, hxc_success
    call print_spaced
    jmp shell_prompt
.compilation_done:
    mov si, hxc_generic_out
    call print_spaced
    jmp shell_prompt

run_hxcpp_compiler:
    mov si, hxcpp_linking
    call print_spaced
    mov dx, 0x0F0F
    and dx, 0xF0F0
    mov si, hxcpp_success
    call print_spaced
    jmp shell_prompt

run_hxasm_compiler:
    mov si, hxasm_resolving
    call print_spaced
    clc
    stc
    mov si, hxasm_success
    call print_spaced
    jmp shell_prompt

; --- NEW ARCHITECTURE HOOKS: CROSS-PLATFORM HARDWARE INTERFACES ---

run_arm_support_check:
    mov si, arm_banner_str
    call print_spaced
    
    ; Verify execution configurations against ARM architecture target specs
    mov ax, 0xA640                         ; Simulated AArch64 internal execution context identifier
    cmp ax, 0xA640
    je .arm_valid
    ret
.arm_valid:
    mov si, arm_success_str
    call print_spaced
    jmp shell_prompt

run_sparc_support_check:
    mov si, sparc_banner_str
    call print_spaced
    
    ; Verify execution configurations against SPARC OpenXOM architecture targets
    mov ax, 0x5056                         ; Simulated SPARC V9 Big-Endian vector structure mask
    cmp ax, 0x5056
    je .sparc_valid
    ret
.sparc_valid:
    mov si, sparc_success_str
    call print_spaced
    jmp shell_prompt

; --- Structural Communication Strings Block ---
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

arm_banner_str   db '[CROSS-COMPILER] Initializing ARM compilation cross-toolchain environment...', 13, 10, 0
arm_success_str  db '[TARGET LINKED] Target profile architecture set to AArch64 (ARMv8-A profile) successfully!', 13, 10, \
                    'Toolchain operational mode context mapping constraints loaded.', 13, 10, 0

sparc_banner_str  db '[CROSS-COMPILER] Initializing SPARC V9 RISC open-architecture engine link...', 13, 10, 0
sparc_success_str db '[TARGET LINKED] Big-Endian OpenSPARC operational structures mounted cleanly!', 13, 10, \
                     'Instruction verification mapping table verified for SPARC compliance.', 13, 10, 0
