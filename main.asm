global _start
global _main

section .data
  board: times 3 db '---', 10
  boardSize: equ $-board
  clsAscii: db 27, '[2J', 27, '[H'

section .text
_main:
  jmp _start

_start:
  push rbp
  mov rbp, rsp
  
  ; exit
  mov rsp, rbp
  pop rbp
  call _exit

_exit:
  mov rax, 60       ; exit(
  mov rdi, 0        ;   EXIT_SUCCESS
  syscall           ; );

; rsi - const char* message
; rdx - msglen
_primitivePrint:
  push rbp 
  mov rbp, rsp
  
  mov rax, 1
  mov rdi, 1

  syscall

  mov rsp, rbp
  pop rbp
  ret

; rdi - vizsgálandó szám
_getNumberLength:
  push rbp
  mov rbp, rsp
  ; Stack setup

  mov rax, rdi
  mov rcx, 0
  mov rbx, 10

  _getNumberLengthLoopBegin:
    inc rcx
    xor rdx, rdx
    div rbx
    cmp rax, 0
  jne _getNumberLengthLoopBegin
  
  mov rax, rcx ; visszatérési érték beállítása
  ; Cleanup
  mov rsp, rbp
  pop rbp
  ret

;rdi - átalakítandó szám
;rsi - char* buffer
;rdx - szám hossza
_numberToString:
  push rbp
  mov rbp, rsp
  ; stack setup

  mov rcx, rdx        ; szám hossza
  mov rbx, 10         ; osztó
  mov rax, rdi
  
  _converterLoop:
    xor rdx, rdx
    dec rcx
    div rbx
    add dl, 48
    mov [rsi + rcx], dl 
    cmp rax, 0
  jne _converterLoop

  ; Cleanup
  mov rsp, rbp
  pop rbp
  ret

_clearScreen:
  push rbp
  mov rbp, rsp
  
  mov rsi, clsAscii
  mov rdx, 7

  call _primitivePrint

  mov rsp, rbp
  pop rbp
  ret


_printBoard:
  push rbp
  mov rbp, rsp

  mov rsi, board
  mov rdx, boardSize
  call _primitivePrint

  mov rsp, rbp
  pop rbp
  ret

; rdi - elso offset
; rsi - masodik offset
; rdx - harmadik offset
_checkOffsetEquality:
  push rbp
  mov rbp, rsp
  ; L - R
  movzx rax, BYTE [board + rdi]
  movzx rcx, BYTE [board + rsi]
  movzx rbx, BYTE [board + rdx]

  add rbx, rax
  add rbx, rcx
  imul rcx, 3
  
  cmp rcx, rbx
  jmp _offsetEquExit
  mov rax, 0
  
  _offsetEquExit:
    mov rsp, rbp
    pop rbp
    ret
