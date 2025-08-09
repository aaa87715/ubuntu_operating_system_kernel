[ORG 0x7c00]
[SECTION .data]
BOOT_MAIN_ADDR equ 0X500

[SECTION .text]
[BITS 16]

global _start
_start:
    xchg bx, bx ; 傳統「bochs magic breakpoint」
    mov ax,3
    int 0x10
    xchg bx, bx ; 傳統「bochs magic breakpoint」

    call .load_setup_init
    call .load_setup_send_meta_to_IO_port
    call .wait_for_not_busy
    call .read_disk_execute


    xchg bx, bx ; 傳統「bochs magic breakpoint」

    jmp 0x0000:BOOT_MAIN_ADDR

.halt:
    jmp $

.load_setup_init:
    mov edi, BOOT_MAIN_ADDR
    mov ecx, 1
    mov bl, 2
    ret
.load_setup_send_meta_to_IO_port:
    ;0x1f2 initial the seek
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    ;0x1f3  is low 8 bit of address
    mov dx, 0x1f3
    mov eax, ecx
    and eax, 0xFF
    out dx, al

    ;0x1f4 is send middle 8bit of address
    mov dx, 0x1f4
    mov eax, ecx
    shr eax, 8
    and eax, 0xFF
    out dx, al

    ;0x1f5 is send middle 8bit of address
    mov dx, 0x1f5
    mov eax, ecx
    shr eax, 16
    and eax, 0xFF
    out dx, al


    ;0x1f6 is send middle 8bit of address
    mov dx, 0x1f6
    mov eax, ecx
    shr eax, 24
    and al, 0b00001111
    or al, 0b11100000
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20   ; 0x20 = read sectors with retries
    out dx, al

    ret

    ;0x1f7 read the flag if the disk is busy
.wait_for_not_busy:
    in al,dx
    and al, 0x80
    cmp al,0x80
    je .wait_for_not_busy
    call .wait_drq
    ret
.wait_drq:
    in al, dx
    and al, 0x08
    cmp al, 0x08
    jne .wait_drq
    ret

.read_disk_execute:
    mov dx, 0x1f0

    mov cx, 256

    mov bx, BOOT_MAIN_ADDR
    mov di, bx

    ;!!! importain the es only accept ax register!!
    mov ax, 0x0000
    mov es, ax

    xchg bx,bx
.read_pool:
    call .wait_drq
    in ax,dx
    mov [es:di], ax
    add di, 2
    loop .read_pool
    ret

times 510 - ($ - $$) db 0
db 0x55, 0xaa