; mk: $mkAS && $mkGCC

; Jim Moroney
; due: 09.21.23
; reverse.asm
; a program that prints the input given to it... but backwards!
; usage: ./reverse inputfile

global main
extern puts
extern fopen
extern fileno
extern fstat
extern _GLOBAL_OFFSET_TABLE_

    section .text

main:
    push    rbp
    mov     rbp, rsp
    
    cmp     rdi, 2      ; Checking for an input file
    jne      _arg_err

    ; wo! weary travellers rest here and stack ye registers
    ; for we must obtain the size of the input file before
    ; we wee computing folk continue 

    push    rax
    push    rbx
    push    rdx
    push    rdi
    push    rsi
    push    r9
    ; open ye file fiend
    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, [rsi+8]
    mov     rsi, (db "rt", 0)
    lea     rdx, [rel main]
    mov     r9, fopen wrt ..got
    call    [rbx+r9]
    ; error checking
    cmp     rax, 0      ;checking for C null
    je      _fopen_err
    ; pass that to fstat to get file descriptor
    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, rax
    lea     rsi, [rel main]
    mov     r9, fstat wrt ..got
    call    [rbx+r9]
    ; error checking
    cmp     rax, -1
    je      _fstat_err





_arg_err:
    push    rdi
    lea     rdi, [rel mg_argerr]
    jmp     _print_exit
_fopen_err:
    pop     r9
    pop     rsi 
    pop     rdi
    pop     rdx
    pop     rbx
    pop     rax
    push    rdi
    lea     rdi, [rel mg_fopenerr]
    jmp     _print_exit
_fstat_err:
    pop     r9
    pop     rsi 
    pop     rdi
    pop     rdx
    pop     rbx
    pop     rax
    push    rdi
    lea     rdi, [rel mg_fstaterr]
    jmp     _print_exit

_print_exit:
    push    rbx
    push    rsi
    push    r9

    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    lea     rsi, [rel main]
    mov     r9, puts wrt ..got
    call    [rbx+r9]
    mov     eax, 1 ; error return
   
    pop     r9
    pop     rsi
    pop     rbx
    pop     rdi
    leave
    ret


    section .data nowrite
mg_argerr:
    db      "ERROR: You must supply an input file as an argument.", 0
mg_fopenerr:
    db      "ERROR: Failed to open file.", 0
mg_fstarterr:
    db      "ERROR: reeeee", 0
    

section .not.GNU-stack noexec
