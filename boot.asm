org 0x7C00

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ax, 0x0013
    int 10h

    call fill_green_background

    mov ax, 190
    mov cx, 320
    mul cx
    add ax, 91
    mov [text_off], ax

    mov si, text_str
    mov bx, [text_off]
    call draw_string

    call draw_oval

end_loop:
    jmp end_loop

fill_green_background:
    mov ax, 0xA000
    mov es, ax
    mov di, 0
    mov cx, 320*200
    mov al, 0x0E
    rep stosb
    ret

draw_oval:
    mov word [center_x], 160
    mov word [center_y], 20
    mov word [radius_x], 30
    mov word [radius_y], 20
    mov byte [color], 0x04

    mov word [y], -20
.y_loop:
    mov word [x], -30
.x_loop:
    mov ax, [x]
    imul ax
    mov bx, ax
    
    mov ax, [y]
    imul ax
    
    shr bx, 1
    add ax, bx
    
    cmp ax, 400
    ja .skip_pixel
    
    mov ax, [center_x]
    add ax, [x]
    mov [screen_x], ax
    
    mov ax, [center_y]
    add ax, [y]
    mov [screen_y], ax
    
    call draw_pixel

.skip_pixel:
    inc word [x]
    cmp word [x], 30
    jle .x_loop
    
    inc word [y]
    cmp word [y], 20
    jle .y_loop
    ret

draw_pixel:
    pusha

    mov ax, [screen_x]
    cmp ax, 0
    jl .end
    cmp ax, 319
    jg .end
    
    mov ax, [screen_y]
    cmp ax, 0
    jl .end
    cmp ax, 199
    jg .end
    
    mov ax, [screen_y]
    mov bx, 320
    mul bx
    add ax, [screen_x]
    mov di, ax
    
    mov ax, 0xA000
    mov es, ax
    
    mov al, [color]
    mov [es:di], al

.end:
    popa
    ret

draw_string:
    push bp
    mov bp, sp
.next_char:
    lodsb
    cmp al, 0
    je .done_string

    mov di, chars_db
    xor dx, dx
.find_loop:
    mov cl, [di]
    cmp cl, 0
    je .char_not_found
    cmp cl, al
    je .found_index
    inc di
    inc dx
    jmp .find_loop

.char_not_found:
    add bx, 6
    jmp .next_char

.found_index:
    mov ax, dx
    shl ax, 2
    add ax, dx
    mov di, font_table
    add di, ax

    push si
    push bp
    push ds

    mov cx, 5
    mov si, di
    mov di, bx

.col_loop:
    mov al, [si]
    mov di, bx
    mov bp, 0
.row_loop:
    test al, 1
    jz .skip
    mov byte [es:di], 0x04
.skip:
    add di, 320
    shr al, 1
    inc bp
    cmp bp, 7
    jl .row_loop

    add bx, 1
    inc si
    dec cx
    jnz .col_loop

    add bx, 1

    pop ds
    pop bp
    pop si

    jmp .next_char

.done_string:
    pop bp
    ret

text_off dw 0
text_str db 'Filiaevskih Z.O. NMT-333901',0

chars_db db 'F','i','l','a','e','v','s','k','h',' ','Z','.','O','N','M','T','-','3','9','0','1',0

font_table:
    db 0x7F,0x09,0x09,0x01,0x01
    db 0x00,0x00,0x7D,0x00,0x00
    db 0x00,0x41,0x7F,0x40,0x00
    db 0x20,0x54,0x54,0x54,0x78
    db 0x38,0x54,0x54,0x54,0x18
    db 0x3C,0x40,0x20,0x10,0x0C
    db 0x48,0x54,0x54,0x54,0x20
    db 0x7F,0x10,0x28,0x44,0x00
    db 0x7F,0x08,0x08,0x08,0x70
    db 0x00,0x00,0x00,0x00,0x00
    db 0x61,0x51,0x49,0x45,0x43
    db 0x00,0x60,0x60,0x00,0x00
    db 0x3E,0x41,0x41,0x41,0x3E
    db 0x7F,0x02,0x04,0x08,0x7F
    db 0x7F,0x06,0x18,0x06,0x7F
    db 0x01,0x01,0x7F,0x01,0x01
    db 0x08,0x08,0x08,0x08,0x08
    db 0x42,0x49,0x49,0x49,0x36
    db 0x46,0x49,0x49,0x29,0x1E
    db 0x3E,0x45,0x49,0x51,0x3E
    db 0x00,0x41,0x7F,0x40,0x00

center_x dw 0
center_y dw 0
radius_x dw 0
radius_y dw 0
color db 0
x dw 0
y dw 0
screen_x dw 0
screen_y dw 0

times 510-($-$$) db 0
dw 0xAA55
