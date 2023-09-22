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


    section .text  
main:
    push    rbp
    mov     rbp, rsp
    
    
    
    
    
    section .data nowrite
mg_argerr:
    db      "ERROR: main - You must supply an input file as an argument.", 0
mg_fopenerr:
    db      "ERROR: fopen - Failed to open file.", 0
mg_fstaterr:
    db      "ERROR: fstat - unable to get size", 0
mg_zerofileerr:
    db      "ERROR: fstat - file has size of 0 bytes (somethin wrong here)", 0
mg_mallocerr:
    db      "ERROR: malloc - memory allocation failed", 0
mg_freaderr:
    db      "ERROR: fread - failed to read file", 0
fopen_arg:
    db      "rt", 0

section .not.GNU-stack noexec