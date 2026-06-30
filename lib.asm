.model small
.stack 200h

.data
    semilla dw 0

.code
    public mover_cursor
    public imprimir_pantalla
    public random
    public imprimir_string
    public reg2ascii
    public pintarFranjas
    public inicializar

;----------------------------------------------------------------------------------------------------------
    ; Devuelve en al un numero entre 0 y 8

    random proc
        push bx
        mov ah,00h 
        int 1ah     ; la int 1ah, devuelve en un numero en dx:cx (32 bits) de la cantidad de ticks del dia
        mov [semilla], dx   ;la muevo a [semilla]
        mov ax, [semilla]
        mov bx, 25173
        mul bx               ; ax = ax * 25173
        add ax, 13849
        mov [semilla], ax    ; guardar nueva semilla
        mov dx, 0
        mov bx, 9
        div bx               ; dividir por 9
        mov al, dl           ; el resto (0-8) queda en dl
        pop bx
        ret
    random endp

;----------------------------------------------------------------------------------------------------------
    ; Recibe en dh la fila 
    ; Recibe en dl la columna
    ; Donde se va a escribir

    mover_cursor proc
        push dx
        push bx

        mov ah, 02h
        mov bh, 0
        int 10h

        pop bx
        pop dx  
        RET
    mover_cursor endp

;----------------------------------------------------------------------------------------------------------
    ; Recibe en al el caracter a imprimir 

    imprimir_pantalla proc
        push ax
        push bx
            mov ah, 0eh
            mov bh, 0
            INT 10h
        pop bx
        pop ax
        ret
    imprimir_pantalla endp

;----------------------------------------------------------------------------------------------------------
    ; Recibe en si la direccion del string (terminado en 0)

    imprimir_string proc
        push ax
        push si
        push bx

        il_loop:
            mov al, [si]
            cmp al, 0
            je  il_fin
            push bx
            mov ah, 0Eh
            mov bh, 0
            int 10h
            pop bx
            inc si
            jmp il_loop
        il_fin:

        pop bx
        pop si
        pop ax
        ret
    imprimir_string endp

;----------------------------------------------------------------------------------------------------------

    ; Recibo en bx offset del buffer 
    ; Recibo en dl un número menor a 256
    reg2ascii proc
        push bx
        push dx
        push cx
            xor ax,ax
            mov al,dl
            mov cx,10
            add bx,2

            ; Unidades
            xor dx,dx
            div cx
            add dl,'0'
            mov [bx],dl

            dec bx

            ; Decenas
            xor dx,dx
            div cx
            add dl,'0'
            mov [bx],dl

            dec bx

            ; Centenas
            xor dx,dx
            div cx
            add dl,'0'
            mov [bx],dl
        pop cx
        pop dx
        pop bx
        ret
    reg2ascii endp

;----------------------------------------------------------------------------------------------------------
    ; Pinta la franja superior e inferior de negro

    pintarFranjas proc
        push ax bx cx dx
        
        ;ah = 06h -> Función desplazar hacia arriba
        ;al = 00h -> Si al es mayor a 0 desplaza x cantidad de lineas hacia arriba
                 ;-> Si al es igual a 0 borra toda el area seleccionada y la pinta con el color en bh

        ;bh -> color fondo|color texto

        ;cx -> Esquina superior izquierda
        ;dx -> Esquina inferior derecha

        ; Franja superior
        mov ax, 0600h
        mov bh, 0Fh           
        mov cx, 0000h         
        mov dx, 024Fh         
        int 10h               

        ; Franja inferior
        mov bh, 0Fh           
        mov cx, 1600h         
        mov dx, 184Fh         
        int 10h               

        pop dx cx bx ax
        ret
    pintarFranjas endp

    inicializar proc
        push ax bx cx dx
        mov ax, 0600h 
        mov bh, 1Fh ; Fondo azul oscuro, letras blancas
        mov cx, 0000h 
        mov dx, 184Fh
        int 10h
        pop dx cx bx ax
        ret   
    inicializar endp
end