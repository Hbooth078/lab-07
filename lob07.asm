; WriteScaled.asm
; MASM/TASM 16-bit DOS program
; Demonstrates WriteScaled procedure
.model small
.stack 100h
.data
DECIMAL_OFFSET  EQU 5                ; change to 3 to test the other example
decimal_one     BYTE "100123456789765",0

; helper strings
msg1            BYTE "WriteScaled output: ",0

.code
; printChar - prints AL using DOS int 21h AH=02
printChar PROC
    push ax
    mov dl, al
    mov ah, 02h
    int 21h
    pop ax
    ret
printChar ENDP

; printString - DS:SI -> zero-terminated string
printString PROC
    push ax
    push si
.nextChar:
    mov al, [si]
    cmp al, 0
    je .done
    call printChar
    inc si
    jmp .nextChar
.done:
    pop si
    pop ax
    ret
printString ENDP

; WriteScaled
; Input: DS:SI -> zero-terminated ASCII digits string
; Uses DECIMAL_OFFSET constant
WriteScaled PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov di, si            ; DI = start pointer
    xor bx, bx            ; BX = length counter
.len_loop:
    mov al, [si]
    cmp al, 0
    je .len_done
    inc bx
    inc si
    jmp .len_loop
.len_done:
    mov si, di            ; restore SI to start of string
    mov cx, DECIMAL_OFFSET
    cmp cx, bx
    jae .offset_ge_len    ; if offset >= length

    ; offset < length: print first (length - offset) chars
    mov dx, bx
    sub dx, cx            ; DX = digits before decimal
.print_before:
    cmp dx, 0
    je .print_dot
    mov al, [si]
    call printChar
    inc si
    dec dx
    jmp .print_before

.print_dot:
    mov al, '.'
    call printChar

.print_after:
    cmp cx, 0
    je .done_print
    mov al, [si]
    call printChar
    inc si
    dec cx
    jmp .print_after

    jmp .finish

.offset_ge_len:
    ; offset >= length: print "0.", then (offset - length) zeros, then digits
    mov al, '0'
    call printChar
    mov al, '.'
    call printChar

    mov dx, DECIMAL_OFFSET
    sub dx, bx            ; dx = number of leading zeros
.print_zeros:
    cmp dx, 0
    je .print_all_digits
    mov al, '0'
    call printChar
    dec dx
    jmp .print_zeros

.print_all_digits:
    mov cx, bx
.print_digits:
    cmp cx, 0
    je .done_print
    mov al, [si]
    call printChar
    inc si
    dec cx
    jmp .print_digits

.done_print:
.finish:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
WriteScaled ENDP

; Program entry
start:
    mov ax, @data
    mov ds, ax

    lea si, msg1
    call printString

    lea si, decimal_one
    call WriteScaled

    ; newline
    mov al, 0Dh
    call printChar
    mov al, 0Ah
    call printChar

    ; exit
    mov ah, 4Ch
    xor al, al
    int 21h

end start
