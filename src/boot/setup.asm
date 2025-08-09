[org 0x500]
[section .text]
[bits 16]

mov si ,msg

xchg bx, bx ; 傳統「bochs magic breakpoint」

.print
    lodsb                 ; 從 si 指向的位址載入一個字元到 al，si++
    or al, al             ; 判斷 al 是否為 0 (字串結尾)
    jz .done              ; 如果是0，跳到結束
    mov ah, 0x0e          ; BIOS TTY 輸出字元服務
    int 0x10
    jmp .print

.done
    jmp $

msg : db "heelo word", 10, 13, 0

times 1024 - ( $ - $$ ) db 0
