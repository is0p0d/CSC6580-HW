; mk: $mkAS && $mkGCC

; Jim Moroney
; due: 09.14.23
; hello.asm
; a program that writes a user specified string N number of times
; usage: hello N string

; There has to be a cleaner way to do this, but brain no worky after RGA work....

global main

extern atoi
extern puts
extern _GLOBAL_OFFSET_TABLE_

    section .text
main:
    push    rbp
    mov     rbp, rsp
    cmp     rdi, 3
    jl      _arg_exit
    push    r12

;num convert

    push    rax
    push    rbx
    push    rdi
    push    rsi
    push    r9


    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, [rsi+8]
    lea     rsi, [rel main]
    mov     r9, atoi wrt ..got
    call    [rbx+r9]
    mov     r12, rax ; move into counter

    pop     r9
    pop     rsi
    pop     rdi
    pop     rbx 
    pop     rax

_print:

    push    rax
    push    rbx
    push    rdi
    push    rsi
    push    r9

    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, [rsi+16]
    lea     rsi, [rel main]
    mov     r9, puts wrt ..got

    cmp     r12, 0
    jle     _done_print
    call    [rbx+r9]
    dec     r12

    pop     r9
    pop     rsi
    pop     rdi
    pop     rbx 
    pop     rax
    jmp     _print

_done_print:
    mov     eax, 0 ; successful return
    pop     r9
    pop     rsi
    pop     rdi
    pop     rbx 
    pop     rax 
    pop     r12
    leave
    ret

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
    db     "ERROR: You must supply a number and a string as arguments.", 0
    

section .not.GNU-stack noexec
