[ORG 0x500]

[SECTION .data]
READ_BUFFER_START_ADDR equ 0x8002
BUFFER_READ_COUNT_ADDR equ 0x8000
BUFFER_MEMORY_USE_COUNT_ADDR equ 0x8001
error_msg : db "memory initial fail!!!", 10, 13 , 0
msg : db "hello word", 10, 13, 0
read_count dw 0
last_pos dw 0


[SECTION .text]
[BITS 16]
call .print_hello_word
xchg bx, bx ; 傳統「bochs magic breakpoint」
call .init_memory_map_data
xchg bx,bx ; 傳統「bochs magic breakpoint」
call .read_memory_map
call .after_memory_read
jmp .done

.init_memory_map_data:
    mov ebx, 0
    ;xor ebx, ebx ; init the ebx to 0
    mov ax, 0
    mov es, ax
    mov di, READ_BUFFER_START_ADDR
    ret
.read_memory_map:
    mov edx, 0x534D4150  ; SMAP
    mov eax, 0xE820  ;the memory map port
    mov ecx, 24     ;set bufffer size
    int 0x15
    jc .E820_fail
    test ebx,ebx
    mov [last_pos], di
    add di, 24
    inc word [read_count]
    jnz .read_memory_map
    ret

.after_memory_read:
    mov ax, [read_count]
    mov [BUFFER_READ_COUNT_ADDR], ax

    mov ax, [last_pos]
    mov [BUFFER_MEMORY_USE_COUNT_ADDR], ax
    ret

.E820_fail:
    call .print_memory_init_error
    call .done


.print_hello_word:
    mov si ,msg
    call .print
    ret


.print_memory_init_error:
    mov si ,error_msg
    call .print
    ret


.print:
    lodsb                 ; 從 si 指向的位址載入一個字元到 al，si++
    or al, al             ; 判斷 al 是否為 0 (字串結尾)
    jz .ret              ; 如果是0，跳到結束
    mov ah, 0x0e          ; BIOS TTY 輸出字元服務
    int 0x10
    jmp .print

.ret:
    ret
.done:
    jmp $
times 1024 - ( $ - $$ ) db 0
