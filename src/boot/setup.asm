[ORG 0x500]


[SECTION .text]
[BITS 16]
start:
    xchg bx, bx ; 傳統「bochs magic breakpoint」
    call .print_hello_word
    call .init_memory_map_data
    call .read_memory_map
    call .after_memory_read
    call .change_to_protect_mode
    xchg bx,bx ; 傳統「bochs magic breakpoint」

    jmp .done


.change_to_protect_mode:


.init_memory_map_data:
    mov ebx, 0
    mov ax, 0
    mov es, ax
    mov di, READ_BUFFER_START_ADDR
    ret

.read_memory_map:
    mov eax, 0xE820  ;the memory map port
    mov edx, 0x534D4150  ; SMAP
    mov ecx, 24     ;set bufffer size
    int 0x15
    jc .E820_fail

    cmp eax, 0x534D4150         ; must return 'SMAP'
    jne .E820_fail


    mov [last_pos], di
    add di, 24
    inc word [read_count]

    test ebx,ebx

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


.print_memory_init_error:
    mov si ,error_msg
    call .print
    ret


.print_hello_word:
    mov si ,msg

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


[SECTION .data]
READ_BUFFER_START_ADDR equ 0x8002
BUFFER_READ_COUNT_ADDR equ 0x8000
BUFFER_MEMORY_USE_COUNT_ADDR equ 0x8001
error_msg : db "memory initial fail!!!", 10, 13 , 0
msg : db "hello word", 10, 13, 0
read_count dw 0
last_pos dw 0

times 1024 - ( $ - $$ ) db 0
