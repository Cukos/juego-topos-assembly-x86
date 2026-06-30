@echo off

tasm main.asm
tasm lib.asm

tlink main.obj lib.obj

echo Compilacion terminada
pause