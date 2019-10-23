format binary as 'img' ;in order to export directly as IMG instead of fasm
BASE_OFFSET = $3F000000 ;Raspberry Pi 3B+ memory base
org $0000
mov sp,$1000

;r0 now contains address of the screen
;SCREEN_X and BITS_PER_PIXEL are global constants by FB_Init
mov r0,BASE_OFFSET
bl FB_Init

and r0,$3FFFFFFF ;Converts Mail Box frame pointer from bus address to physical address
str r0,[FB_POINTER] ; Store Frame Buffer Physical address

mov r7,r0 ;back-up a copy of the screen address + channel number

;Setup the GPIO registers
GPIO_OFFSET = $200000
mov r0,BASE_OFFSET
orr r0,GPIO_OFFSET ;Give GPIO address

;set color -white for 8BPP, Yellow for 16PP
mov r9,BITS_PER_PIXEL
 cmp r9,#8 ;if BITS_PER_PIXEL == 8 meaning the it has reached the next pixel
 beq sp_eight
 ;assuming a 16 bit number
  mov r6,$FF00
  orr r6,$000E
  b sp_endif
sp_eight:
 mov r6,#1 ;white for 8-bit color
sp_endif:

mov r4, #1 ;x coord
mov r5, #1 ;y coord
;Create Set-up for pong screen

;Draw the borders of the screen
mov r10, #480    ;y
mov r11, #640    ;x
borderloop:
borderxloop:
 push {r0-r3}
 mov r0,r7 ;screen address
 mov r1,r4 ;x
 mov r2,r5 ;y
 mov r3,r6 ;color
  ;assume BITS_PER_PIXEL, SCREEN_X are shared constants
  bl drawpixel
 pop {r0-r3}

;test if the border is drawn
 add r4,#1
 mov r8,r11
 cmp r4,r8
bls borderxloop
 mov r4,#1
 mov r5,#639
 cmp r5,r10
 add r5,#1
bls borderloop

Loop:
 b Loop ;wait forever

CoreLoop: ;infinite loop for core 1..3
 b CoreLoop

include "FBinit16.asm"
include "timer2_2Param.asm"
include "drawpixel.asm"