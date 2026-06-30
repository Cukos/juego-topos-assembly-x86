.model small
.stack 200h

.data
    hoyoborde db 219,219,219,219,219,0
    hoyomedio db 219,32,32,32,219,0
    hoyos_fil  db  6,  6,  6, 12, 12, 12, 18, 18, 18
    hoyos_col  db 15, 35, 55, 15, 35, 55, 15, 35, 55
    topo_pos db 0
    teclas  db "7","8","9","4","5","6","1","2","3"
    puntaje db 0  
    vidas db 3
    bufferpuntos db "000",0
    tick_contador dw 0
    tick_limite dw 32    
    topo_escapo db 0
    vector_original_off dw 0
    vector_original_seg dw 0
    cartel_perdio db "Perdiste :(",0
    titulo db 10,13,"JUEGO DEL TOPO!!",0
    textoPuntaje db "Puntuacion: ",0
    textoSalir db "| Pulse ESC para salir |",0
    nivel db 1
    texto_nivel db "Nivel:" , 0

.CODE
    extrn mover_cursor:proc
    extrn imprimir_pantalla:proc
    extrn random:proc
    extrn imprimir_string:proc
    extrn reg2ascii:proc
    extrn pintarFranjas:proc
    extrn inicializar:proc

;defino la nueva rutina
    timer proc 
        push ax
        push ds
        mov ax, @data
        mov ds, ax
        inc word ptr [tick_contador]
        mov ax, [tick_contador]
        cmp ax, [tick_limite]
        jb  timer_fin
        mov word ptr [tick_contador], 0
        mov byte ptr [topo_escapo], 1
    timer_fin:
        mov al, 20h
        out 20h, al
        pop ds 
        pop ax
        iret ; Vuelve y restaura el registro de flags
    timer endp

    main proc
    inicio:
        mov ax, @data
        mov ds, ax
        call inicializar
        call pintarFranjas

        ; Imprimir titulo
            mov dh, 0 ; Fila
            mov dl, 0 ; Columna
            call mover_cursor ;Apunta a las coordenadas que le mandemos
            mov si, offset titulo
            call imprimir_string

        ; Imprimir texto de puntos
            mov dh, 23
            mov dl, 0
            call mover_cursor
            mov si, offset textoPuntaje
            call imprimir_string

        ; Mensaje de salida
                mov dh, 23
                mov dl, 55
                call mover_cursor
                mov si, offset textoSalir
                call imprimir_string

        ; Guardo el segment y el offset del timer
                mov ah, 35h ; Get interrupt vector ->Devuelve el offset y el segment del vector que seleccionemos
                mov al, 1ch ; Dirección de la IVT donde está el timer
                int 21h
                mov [vector_original_off], bx ; Devuelve en bx el offset
                mov [vector_original_seg], es ; Devuelve en es el segmento

        ; Inicializamos el vector de interrupción en 1ch
                push ds

                mov ax, SEG timer ;Guardo en ax el segmento de la interrupción "timer"
                mov ds, ax
                mov dx, OFFSET timer

                ;Guardamos en 1ch del IVT la dirección de nuestra propia función timer (antes guardamos la original en variables)

                mov ah, 25h ; "Set interrupt vector"
                mov al, 1ch ; Dirección de la IVT
                int 21h

                pop ds

        ; No funcionaba bien asi que vuelvo a cargar el datasegment
                mov ax, @data
                mov ds, ax

        call dibujarHoyos

    loopprincipal:
        ; Imprimo el primer topo
            xor ax, ax

            mov al, [topo_pos] ; Muevo a al el índice del topo
            mov di, ax

            mov dh, hoyos_fil[di] ; Coordenada x del topo actual
            mov dl, hoyos_col[di] ; Coordenada y del topo actual
            add dl, 2 ; Muevo el topo 2 posiciones a la derecha
            ;No hace falta hacerlo con las filas porque la propia lógica del dibujado de topos ya lo hace :p

            call mover_cursor

            mov al, "^"
            call imprimir_pantalla

        ; Imprimo los puntos
            mov dh, 23
            mov dl, 12
            call mover_cursor

            mov bx, offset bufferpuntos
            mov dl, [puntaje]
            call reg2ascii

            mov si, offset bufferpuntos
            call imprimir_string

        ; Imprmir nivel
            mov dh, 1
            mov dl, 42
            call mover_cursor

            mov si, offset texto_nivel
            call imprimir_string
            mov al, [nivel]
            add al, '0' ; Lo mismo que sumarle 30h, es asciipara que en al quede el ascii del nivel
            call imprimir_pantalla

        ; Loop para imprir corazones, los borra cuando se pierde una vida y los vuelve a imprimir en el loop con cx = vidas
            mov dh, 23
            mov dl, 30
            call mover_cursor

            mov cx, 3

            borrar_corazones:
                mov al, ' '
                call imprimir_pantalla
            loop borrar_corazones
                
            mov dh, 23
            mov dl, 30
            call mover_cursor

            xor cx, cx
            mov cl, [vidas]
            cmp cl, 0 ; En caso de error ponemos esta comparación extra
            je saltar_corazones
            mov al, 3 ; Ascii del corazón

            imprimir_corazones:
                call imprimir_pantalla
            loop imprimir_corazones

            saltar_corazones:

        ; Veo el estado del topo, o sea, hace cuanto está en el hoyo, si supero el lÍmite, reinicio tick_contador y topo_escapo.
        ; Tambien quita una vida y salta para volver a imprimir otro topo. 
            cmp byte ptr [topo_escapo], 0 ; topo_escapo es el flag de si el topo escapó o no (0 o 1)
            je no_escapo

            ;Si escapó
            mov byte ptr [topo_escapo], 0
            mov word ptr [tick_contador], 0
            dec vidas

            cmp vidas, 0
            je borrar_y_perder

            jmp sigueloop ; Si aun seguimos con vidas seguimos

        ; Solicito ingreso al usuario
            no_escapo:
                mov ah, 01h ; Función para comprobar si se pulsó algo
                int 16h
                jnz continuar_tecla ; Si se tecleó algo va a continuar_tecla
                jmp loopprincipal ; Si no sigue con normalidad

            continuar_tecla:
                mov ah, 00h ; Guarda en al la tecla ingresada
                int 16h
                cmp al, 27 ; Tecla ESC
                
                jne sigueesc
                jmp salir

        ; Chequeo qué tecla ingreso el usuario, si coincide con topo_pos salta a acierto y si no quita una vida
            sigueesc:
                mov bl, al
                xor ax, ax
                mov al, [topo_pos]
                mov di, ax

                cmp bl, teclas[di] ;Comparo la tecla que se ingresó (bl) con el índice correspondiente al topo actual
                je acerto
                dec vidas
                cmp vidas, 0
                je borrar_y_perder
                jmp sigueloop

            acerto:
                inc puntaje
                jmp sigueloop

        ; Si vidas = 0 se termina el juego
            borrar_y_perder:
                mov dh, 23
                mov dl, 30
                call mover_cursor

                mov cx, 3

            borrar_todo:
                mov al, ' ' ; Imprimo 3 " " para borrar los 3 corazones
                call imprimir_pantalla
            loop borrar_todo
            jmp perdio

            perdio:
                mov dh, 23
                mov dl, 30
                call mover_cursor

                mov si, offset cartel_perdio
                call imprimir_string

                mov ah, 00h ; Espera que se ingrese algo (para que no se cierre apenas perdemos)
                int 16h
                jmp salir

            sigueloop:
        ; Comparacion para subir niveles
                cmp puntaje, 10
                je subenivel2

                cmp puntaje, 20
                je subenivel3

                cmp puntaje, 35
                je subenivel4

                cmp puntaje,50
                je subenivel5

                cmp puntaje,70
                je subenivel6

                cmp puntaje,100
                je subenivel7
                
                cmp puntaje, 120
                je subenivel8

                jmp siguejuego

        ; Subir los niveles bajando tick_limite
            subenivel2:
                mov word ptr [tick_limite],27
                mov byte ptr [nivel], 2
                jmp siguejuego

            subenivel3:
                mov word ptr [tick_limite],23
                mov byte ptr [nivel], 3
                jmp siguejuego
            subenivel4:
                mov word ptr [tick_limite], 18
                mov byte ptr [nivel], 4
                jmp siguejuego
            subenivel5:
                mov word ptr [tick_limite],13
                mov byte ptr [nivel], 5
                jmp siguejuego
            subenivel6:
                mov word ptr [tick_limite],9
                mov byte ptr [nivel], 6
                jmp siguejuego
            subenivel7:
                mov word ptr [tick_limite],5
                mov byte ptr [nivel], 7
                jmp siguejuego

            subenivel8:
                mov word ptr [tick_limite],3
                mov byte ptr [nivel], 8
                jmp siguejuego


            siguejuego:
        ; Reinicia el topo y el tick_contador, o sea, borra el topo actual, genera un rand nuevo y tick_contador = 0
                xor ax, ax
                mov al, [topo_pos]
                mov di, ax
                mov dh, hoyos_fil[di]
                mov dl, hoyos_col[di]
                add dl, 2

                call mover_cursor
                mov al, ' '
                call imprimir_pantalla

                call random
                xor ah, ah
                mov [topo_pos], al
                mov word ptr [tick_contador], 0
                jmp loopprincipal

        ; Devuelvo a la int 1ch su segmento y su offset original para evitar errores
            salir:
                mov ah, 25h ; Para setear una interrupción en el ivt
                mov al, 1Ch

                push ds
                mov ax, [vector_original_seg]
                mov ds, ax
                mov dx, [vector_original_off]
                
                int 21h
                pop ds

                mov ax, 4c00h
                int 21h
    main endp

    ; Función para imprimir hoyos 
        dibujarHoyos proc
            mov bx, 0
            mov cx, 9
            
            hoyoloop:
    ;imprime borde superior
                xor ax, ax
                mov ah, hoyos_fil[bx]
                dec ah
                dec ah
                mov al, hoyos_col[bx] 
                mov dh, ah
                mov dl, al
                call mover_cursor
                mov si, offset hoyoborde
                call imprimir_string

    ;imprime medio superior
                mov ah, hoyos_fil[bx]
                dec ah
                mov al, hoyos_col[bx] 
                mov dh, ah
                mov dl, al
                call mover_cursor
                mov si, offset hoyomedio
                call imprimir_string

    ;imprime medio medio
                mov ah, hoyos_fil[bx]
                mov al, hoyos_col[bx] 
                mov dh, ah
                mov dl, al
                call mover_cursor
                mov si, offset hoyomedio
                call imprimir_string

    ;imprime medio inferior 
                mov ah, hoyos_fil[bx]
                inc ah
                mov al, hoyos_col[bx] 
                mov dh, ah
                mov dl, al
                call mover_cursor
                mov si, offset hoyomedio
                call imprimir_string

    ;imprime borde inferior
                mov ah, hoyos_fil[bx]
                inc ah
                inc ah
                mov al, hoyos_col[bx] 
                mov dh, ah
                mov dl, al
                call mover_cursor
                mov si, offset hoyoborde
                call imprimir_string

                inc bx
                dec cx
                jz finhoyoloop
                jmp hoyoloop
            finhoyoloop:
            ret
        dibujarHoyos endp
END inicio