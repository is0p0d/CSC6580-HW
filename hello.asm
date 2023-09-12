; mk: $mkAS && $mkGCC

; Jim Moroney
; due: 09.14.23
; hello.asm
; a program that writes a user specified string N number of times
; usage: hello N string

extern atoi
extern puts

global main

section .text

; NOTE: eax is the exit status

main:
    push    rbp
    mov     rbp, rsp
    push    rdi
    push    rax
    push    rbx
    push    rcx
    pushf

    cmp     rdi, 2
    jne     _arg_exit

    push    qword [rsi+8]         ;put value on stack
    call    atoi
    pop     rcx             ;put result in counter
    add     rsp, 8          ;clean up the stack

_print:
    push    qword [rsi+16]
    call    puts
    add     rsp, 8
    dec     rcx
    
    cmp     rcx, 0
    jne     _print

_done:
    mov     rbx, 0          ;set exit status to 0
    
    popf
    pop     rcx
    pop     rbx
    pop     rax
    pop     rdi
    leave
    ret

_arg_exit:
    push    arg_error
    call    puts
    add     rsp, 8
    mov     rbx, 1          ;set exit status to 1
    
    popf
    pop     rcx
    pop     rbx
    pop     rax
    pop     rdi
    leave
    ret


section .data
arg_error:
    db      "ERROR: You must uspply a number and a string as arguments", 0

section .note.GNU-stack noexec


; COMPILATION ERROR: 
; nasm -f elf64 "hello.asm" -o "hello.o" && gcc -o "hello" "hello.o" -fPIE
; /usr/bin/ld: hello.o: relocation R_X86_64_32S against `.data' can not be used when making a PIE object; recompile with -fPIE
; /usr/bin/ld: failed to set dynamic section sizes: bad value
; collect2: error: ld returned 1 exit status
