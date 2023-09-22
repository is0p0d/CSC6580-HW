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
extern fread
extern malloc
extern write
extern free
extern fclose
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
    push    r12 ; *fp
    push    r13 ; size
    push    r14 ; *content

    ; open ye file fiend
    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, [rsi+8]
    mov     rsi, (db "rt", 0)
    lea     rdx, [rel main]
    mov     r9, fopen wrt ..got
    call    [rbx+r9]    ;fopen, result is a descriptor int in rax
    ; error checking
    cmp     rax, 0      ;checking for C null
    je      _fopen_err
    mov     r12, rax    ;save that pointer baybeeeeee

    ; pass that to fstat to get file descriptor
    ; hoping i can get away without re push-pop'ing the register
    ; since i am overwriting them all anyway, we'll see.
    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, rax
    lea     rsi, [rel main]
    mov     r9, fstat wrt ..got
    call    [rbx+r9]
    ; error checking
    cmp     rax, -1
    je      _fstat_err

    mov     r13, QWORD PTR [rbp-0x70]   ; being honest, compiled a c program that
                                        ; only made the struct and accessed st_size
                                        ; this is the line that did it straight from that
    cmp     r13, 0
    je      _zerofile_err

    ;calling malloc the great
    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, r13
    lea     rsi, [rel main]
    mov     r9, malloc wrt ..got
    call    [rbx+r9]
    ; error checking
    cmp     rax, 0      ;checking for C null
    je      _malloc_err
    mov     r14, rax    ;save that pointer baybeeeeee

    ; your file is ready to be read, sire
    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, r14
    mov     rsi, r13
    mov     rdx, 1
    mov     rcx, r12
    lea     r8, [rel main]
    mov     r9, fopen wrt ..got
    call    [rbx+r9]    ;fopen, result is a descriptor int in rax
    ; error checking
    cmp     rax, 1      ;checking for C null
    je      _fread_err

_writeloop:

    lea     rbx, [rel _GLOBAL_OFFSET_TABLE_]
    mov     rdi, 1
    lea     rsi, [r14+r13-1]
    mov     rdx, 1
    mov     rcx, [rel main]
    mov     r9, fopen wrt ..got
    call    [rbx+r9]    ;fopen, result is a descriptor int in rax
    dec r13
    cmp r13, 0
    jne _writeloop

    ;get the HECK outta here!

    pop r14
    pop r13
    pop r12
    pop r9
    pop rsi
    pop rdi
    pop rdx
    pop rbx
    pop rax
    leave
    ret


; error land
_arg_err:
    push    rdi
    lea     rdi, [rel mg_argerr]
    jmp     _print_exit
_fopen_err:
    pop     r14
    pop     r13
    pop     r12
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
    pop     r14
    pop     r13
    pop     r12
    pop     r9
    pop     rsi 
    pop     rdi
    pop     rdx
    pop     rbx
    pop     rax
    push    rdi
    lea     rdi, [rel mg_fstaterr]
    jmp     _print_exit
_zerofile_err:
    pop     r14
    pop     r13
    pop     r12
    pop     r9
    pop     rsi 
    pop     rdi
    pop     rdx
    pop     rbx
    pop     rax
    push    rdi
    lea     rdi, [rel mg_zerofileerr]
    jmp     _print_exit
_malloc_err:
    pop     r14
    pop     r13
    pop     r12
    pop     r9
    pop     rsi 
    pop     rdi
    pop     rdx
    pop     rbx
    pop     rax
    push    rdi
    lea     rdi, [rel mg_mallocerr]
    jmp     _print_exit
_fread_err:
    pop     r14
    pop     r13
    pop     r12
    pop     r9
    pop     rsi 
    pop     rdi
    pop     rdx
    pop     rbx
    pop     rax
    push    rdi
    lea     rdi, [rel mg_freaderr]
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
    db      "ERROR: main - You must supply an input file as an argument.", 0
mg_fopenerr:
    db      "ERROR: fopen - Failed to open file.", 0
mg_fstarterr:
    db      "ERROR: fstat - reeeee", 0
mg_zerofileerr:
    db      "ERROR: fstat - file has size of 0 bytes (somethin wrong here)", 0
mg_mallocerr:
    db      "ERROR: malloc - memory allocation failed", 0
mg_freaderr:
    db      "ERROR: fread - failed to read file", 0

section .not.GNU-stack noexec
