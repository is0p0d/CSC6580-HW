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
    jl      _arg_exit

_arg_exit:
    push    rbx
    push    rdi
    push    rsi
    push    r9

    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    lea     rdi, [rel mg_argerr]
    lea     rsi, [rel main]
    mov     r9, puts wrt ..got
    call    [rbx+r9]
    mov     eax, 1 ; error return

    pop     r9
    pop     rsi
    pop     rdi
    pop     rbx
    leave
    ret


    section .data nowrite
mg_argerr:
    db     "ERROR: You must supply an input file as an argument.", 0
    

section .not.GNU-stack noexec
