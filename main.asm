global _start

section .data
  board: times 3 db '---', 10
  boardSize: equ $-board
  clsAscii: db 27, '[2J', 27, '[H'
  rowPrompt: db 'Kerem adja meg a sorszamot (1-3) '
  rowPromptLen: equ $-rowPrompt
  colPrompt: db 'Kerem adja meg az oszlopszamot (1-3) '
  colPromptLen: equ $-colPrompt
  winPromptTemplate: db 'A gyoztes X', 10
  winPromptLen: equ $-winPromptTemplate
  drawPrompt: db 'Dontetlen', 10
  drawPromptLen: equ $-drawPrompt
section .text
_start:
  push rbp
  mov rbp, rsp
  sub rsp, 7     ; Hely a sor es oszlopszamoknak
  mov BYTE [rbp - 3], 0     ; X kore
  mov BYTE [rbp - 4], 1     ; Y kore
  mov BYTE [rbp - 5], 0     ; X pontszama
  mov BYTE [rbp - 6], 0     ; O pontszama
  mov BYTE [rbp - 7], 0     ; korok szama
  call _clearScreen
  _gameLoop:
    call _printBoard
    ; sorszam bekerese
    mov rsi, rowPrompt
    mov rdx, rowPromptLen
    call _primitivePrint
    call _readUserMove
    mov BYTE [rbp - 1], al
    ; oszlopszam bekerese
    mov rsi, colPrompt
    mov rdx, colPromptLen
    call _primitivePrint
    call _readUserMove
    mov BYTE [rbp - 2], al
    ; Offset kiszamitasa
    mov bl, BYTE [rbp-1]
    imul rbx, 4
    add rax, rbx
    ; Foglalt?
    mov bl, BYTE [board + rax]
    cmp bl, 45
    jne _gameLoop
    ; kor inkrementalasa
    mov cl, BYTE [rbp - 7]
    inc cl 
    mov BYTE [rbp - 7], cl
    ; szimbolum elhelyezese
    movzx rbx, BYTE [rbp - 3]   ; kor flag
    movzx rcx, BYTE [rbp - 4]   ; kor flag
    mov rdx, 88
    mov rsi, 79
    imul rdx, rbx
    imul rsi, rcx
    add rdx, rsi
    mov BYTE [board + rax], dl
    xor rbx, 1
    xor rcx, 1
    mov BYTE [rbp - 3], bl
    mov BYTE [rbp - 4], cl
    ; Gyozott valaki?
    call _checkCrossWin
    cmp rax, 0
    jne _winner
    call _checkHorizontalWin
    cmp rax, 0
    jne _winner
    call _checkVerticalWin
    cmp rax, 0
    jne _winner
    ; Dontetlen?
    mov cl, BYTE [rbp - 7]
    cmp rcx, 9
    je _draw ; Dontetlen --> Reset
    call _clearScreen
    jmp _gameLoop
    _winner:
    ; Eredmeny frissitese
    cmp rax, 79   ; O nyert?
    jne _otherWon
    mov bl, BYTE [rbp - 6]
    inc bl 
    mov [rbp - 6], bl
    jmp _gyoztesKiiras
    _otherWon:
    mov bl, BYTE [rbp - 5]
    inc bl 
    mov [rbp - 5], bl

    _gyoztesKiiras:
    mov BYTE [winPromptTemplate + winPromptLen - 2], al
    mov rsi, winPromptTemplate
    mov rdx, winPromptLen
    call _primitivePrint
    jmp _resetGame
    ; Reseteles
    _draw:
      mov rsi, drawPrompt
      mov rdx, drawPromptLen
      call _primitivePrint
      jmp _resetGame
    _resetGame:
    mov cl, 0
    mov BYTE [rbp - 7], 0
    mov rcx, 0
    _resetLoop:
      mov BYTE [board + rcx], 45
      mov BYTE [board + rcx + 1], 45
      mov BYTE [board + rcx + 2], 45
      add rcx, 4
      cmp rcx, 8
    jna _resetLoop
    ; Eredmenyek kiirasa
    mov dil, BYTE [rbp - 5]
    mov rsi, 88
    call _printPlayerScore
    mov dil, BYTE [rbp - 6]
    mov rsi, 79
    call _printPlayerScore
    jmp _gameLoop
  ; exit
  mov rsp, rbp
  pop rbp
  call _exit
_exit:
  mov rax, 60
  mov rdi, 0
  syscall

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

; rdi - jatekos pontszama 
; rsi - jatekos szimbolum
_printPlayerScore:
  push rbp
  mov rbp, rsp
  
  call _getNumberLength
  mov r9, rax                ; szamhossz elmentese
  add rax, 4                  ; rax buffer hossza
  sub rsp, rax

  mov BYTE [rbp - 1], 10      ; '\n' 
  mov BYTE [rsp + 2], 32      ; ' '
  mov BYTE [rsp + 1], 58      ; ':'
  mov BYTE [rsp], sil         ; 'O/X'
  
  lea rsi, [rsp + 3]
  mov rdx, r9
  call _numberToString
  
  add r9, 4
  mov rdx, r9
  mov rsi, rsp
  call _primitivePrint

  mov rsp, rbp
  pop rbp
  ret

; rdi - vizsgálandó szám
_getNumberLength:
  push rbp
  mov rbp, rsp
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; rdi - elso offset
; rsi - masodik offset
; rdx - harmadik offset
_checkOffsetEquality:
  push rbp
  push rcx
  mov rbp, rsp
  movzx rax, BYTE [board + rdi]
  movzx rcx, BYTE [board + rsi]
  movzx rbx, BYTE [board + rdx]
  add rbx, rax
  add rbx, rcx
  imul rcx, 3
  cmp rcx, rbx
  je _offsetEquExit
  mov rax, 0
  _offsetEquExit:
    mov rsp, rbp
    pop rcx
    pop rbp
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_readUserMove:
  push rbp
  mov rbp, rsp
  sub rsp, 2
  _readNum:
    mov rax, 0        ; READ syscall
    mov rdi, 0        ; STDIN
    mov rsi, rsp      ; 2 bytenyi buffer
    mov rdx, 2        ; 2 bytenyit olvas
    syscall           ; read(0, buff, 2)
  mov al, BYTE [rbp - 2]
  cmp al, 51
  jg _readNum
  cmp al, 49
  jl _readNum
  sub rax, 49         ; A beolvasott szam 0-2 kozott lesz
  mov rsp, rbp
  pop rbp
  ret

; rax - visszateresi ertek
; ha gyoztes - szimbolum ascii szama, ha nincs 0
_checkCrossWin:
  push rbp
  mov rbp, rsp
  mov rdi, 0
  mov rsi, 5
  mov rdx, 10
  call _checkOffsetEquality
  cmp rax, 0
  je _checkRightLeft
  cmp rax, 45
  je _checkRightLeft
  jne _crossWinExit
  _checkRightLeft:
  mov rdi, 2
  mov rsi, 5
  mov rdx, 8
  call _checkOffsetEquality
  cmp rax, 0
  je _crossWinExit
  cmp rax, 45
  jne _crossWinExit
  mov rax, 0
  _crossWinExit:
    mov rsp, rbp
    pop rbp
    ret

_checkHorizontalWin:
  push rbp
  mov rbp, rsp
  mov rcx, 0          ; szamlalo
  _horizontalLoop:
    mov rbx, rcx
    mov rdi, rbx
    inc rbx
    mov rsi, rbx
    inc rbx
    mov rdx, rbx
    call _checkOffsetEquality
    cmp rax, 88                  ; Van talalat?
    je _horizontalExit          ; Van!
    cmp rax, 79
    je _horizontalExit
    add rcx, 4
    cmp rcx, 8
    jna _horizontalLoop
    mov rax, 0
  _horizontalExit:
  mov rsp, rbp
  pop rbp
  ret


_checkVerticalWin:
  push rbp
  mov rbp, rsp
  mov rcx, 0
  _verticalLoop:
    mov rbx, rcx
    mov rdi, rbx
    add rbx, 4
    mov rsi, rbx
    add rbx, 4
    mov rdx, rbx
    call _checkOffsetEquality
    
    cmp rax, 88
    je _verticalExit
    cmp rax, 79
    je _verticalExit
    inc rcx
    cmp rcx, 2
    jna _verticalLoop
    mov rax, 0
  _verticalExit:
  mov rsp, rbp
  pop rbp
  ret
