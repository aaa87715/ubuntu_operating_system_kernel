[org 0x7c00]

[section .text]
[bits 16]

mov ax,3
int 0x10
xchg bx, bx ; 傳統「bochs magic breakpoint」


mov ah, 0x02
mov dl, 0x80
mov al, 2             ; 讀取 2 個扇區（setup.o 有 1024 bytes）
mov ch, 0             ; 柱面（cylinder）0
mov dh, 0             ; 磁頭（head）0
mov cl, 2             ; 從第 2 扇區開始讀（邏輯LBA 1 = CHS 0/0/2）
mov ax, 0x0000
mov es,ax
mov bx,0x7e00
xchg bx, bx ; 傳統「bochs magic breakpoint」

int 0x13
xchg bx, bx ; 傳統「bochs magic breakpoint」

jc .error         ; 如果 CF 被設，表示錯誤

jmp 0x0000:0x7e00

.error:
    mov si, error_msg

.print_error:
    lodsb               ; 從 [SI] 取出一個字元到 AL，SI++
    or al, al           ; 如果 AL 為 0（結尾），則跳出
    jz .halt
    mov ah, 0x0E        ; TTY 輸出字元功能
    int 0x10
    jmp .print_error

.halt:
    jmp $

error_msg: db "Disk Read Error!", 13, 10, 0

times 510 - ($ - $$) db 0
db 0x55, 0xaa