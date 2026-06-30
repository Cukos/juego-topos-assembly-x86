[README.md](https://github.com/user-attachments/files/29517273/README.md)
# juego-topos-assembly-x86
Tipico juego de atrapar topos, esta vez en pc para jugaron con el pad numerico
# 🐹 Juego del Topo — Assembly x86

Juego de "atrapa al topo" desarrollado completamente en **Assembly x86** (16 bits, modo real), corriendo sobre interrupciones de BIOS/DOS. Inspirado en el clásico "Whack-a-Mole".

## 🎮 Cómo se juega

- En pantalla aparecen 9 hoyos distribuidos en una grilla de 3x3.
- En cada hoyo hay un número (del 1 al 9) que corresponde a una tecla del teclado numérico.
- Un topo (`^`) aparece de forma aleatoria en uno de los hoyos.
- El jugador debe presionar la tecla correspondiente a la posición del topo **antes de que se esconda**.
- Cada acierto suma un punto. Cada vez que el topo escapa sin ser atrapado, o se presiona la tecla incorrecta, se pierde una vida (❤️ x3).
- A medida que sube el puntaje, el juego sube de nivel y el topo aparece y desaparece cada vez más rápido.
- El juego termina cuando se pierden las 3 vidas.
- Se puede salir en cualquier momento presionando **ESC**.

## ⚙️ Cómo compilar y ejecutar

Este proyecto fue desarrollado con **TASM/TLINK** (Turbo Assembler), por lo que requiere un entorno DOS o un emulador como **DOSBox**.

1. Tener instalado TASM y TLINK (o correrlo dentro de DOSBox con esas herramientas cargadas).
2. Ejecutar el script de compilación:
   ```
   compila.bat
   ```
   Este script compila `main.asm` y `lib.asm` por separado, y luego los enlaza en un único ejecutable.
3. Correr el `.exe` generado.

## 🧠 Estructura del proyecto

| Archivo | Contenido |
|---|---|
| `main.asm` | Lógica principal del juego: loop de juego, manejo de niveles, vidas, puntaje, lectura de teclado y control de la interrupción del timer. |
| `lib.asm` | Librería de funciones reutilizables: manejo de cursor, impresión en pantalla, generación de números aleatorios, conversión de números a texto e inicialización de la pantalla. |
| `compila.bat` | Script batch para compilar y enlazar el proyecto con TASM/TLINK. |

## 🔧 Detalles técnicos

- **Generador de números aleatorios propio**: usa el reloj interno del sistema (interrupción `1Ah`) como semilla, combinado con un algoritmo de congruencia lineal para generar la posición del topo.
- **Temporizador personalizado**: se reprograma la interrupción `1Ch` (tick del timer del sistema) para controlar cuánto tiempo permanece el topo visible antes de "escapar", ajustando la dificultad según el nivel.
- **Manejo directo de video por BIOS** (interrupción `10h`) para mover el cursor, imprimir caracteres y pintar áreas de la pantalla.
- **Restauración del vector de interrupción original** al salir del juego, para no dejar el sistema en un estado inestable.
- Sin uso de librerías externas: todo el manejo de hardware (teclado, pantalla, timer) se hace a bajo nivel mediante interrupciones de BIOS/DOS.

## 📚 Qué aprendí haciendo este proyecto

- Manejo de interrupciones de hardware y software en x86 (BIOS `10h`, `16h`, `1Ah`, DOS `21h`).
- Reprogramación de vectores de interrupción (IVT) de forma segura.
- Diseño de un loop de juego en tiempo real sin sistema operativo de por medio.
- Implementación de un generador de números pseudoaleatorios desde cero.
- Organización de código en múltiples archivos `.asm` con `extrn`/`public` para reutilización de funciones.

---

*Proyecto académico desarrollado en Assembly x86 (TASM).*
