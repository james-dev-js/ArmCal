; Raspberry Pi B+,2 'Bare Metal' 16BPP Draw text based on input:
; 1. Setup Frame Buffer
;    assemble struct with screen requirements
;    receive pointer to screen or NULL
; 2. Set up GPIO input
;    GPIOs:
;    pin 17: +3.3v
;    pin 19: GPI10  (input)
;    NC: pin 19 not connected (GPIO 10)
;    Pull-up: pin 19 connected to +3.3V (pin 17)
; 3. Draw some text depending on the state of the GPIO pin.
;    Some code, DrawChar, Font8x8 by Peter Lemon (Krom)

;r0 = pointer + x * BITS_PER_PIXEL/8 + y * SCREEN_X * BITS_PER_PIXEL/8
format binary as 'img'
;constants

;memory addresses of BASE
BASE = $3F000000 ; 2
;BASE = $20000000 ; B+
org $0000
mov sp,$1000

;set up GPIOs
GPIO_OFFSET = $200000
mov r10,BASE
orr r10,GPIO_OFFSET ;Base address of GPIO
ldr r8,[r10,#4] ;read function register for GPIO 10 - 19
bic r8,r8,#27  ;bit clear  27 = 9 * 3    = read access
str r8,[r10,#4];10 input
ldr r12,[r10,#4] ;read function register for GPIO 10 - 19
bic r12,r12,#56
str r12,[r10,#4]; 11 input

;set up input
mov r8,#1
lsl r8,#10  ;bit 10 to enable input GPIO10
mov r12,#1
lsl r12,#11 ;bit 11 to enable input GPIO11

;setup outputs
ldr r13,[r10,#4] ;LED 1 (GPIO18)
orr r13, $1000000 ;set bit 24
str r13,[r0,#4]

ldr r14,[r10,#8] ;LED 2 (GPIO23)
orr r14,$200     ;set bit 9
str r14,[r10,#8] ;GPIO23 output

mov r13,#1
lsl r13,#18

mov r14,#1
lsl r14,#23

mov r0,BASE
bl FB_Init
;r0 now contains address of screen
;SCREEN_X and BITS_PER_PIXEL are global constants in FB_Init
and r0,$3FFFFFFF ; Convert Mail Box Frame Buffer Pointer From BUS Address To Physical Address ($CXXXXXXX -> $3XXXXXXX)
str r0,[FB_POINTER] ; Store Frame Buffer Pointer Physical Address

mov r7,r0 ;back-up a copy of the screen address

; Setup Characters
CHAR_X = 8
CHAR_Y = 8

loop$:
 ;call timer (stop keybounce)
 push {r0-r11}
 mov r0,BASE
 mov r1,$3D0000
 orr r1,$000900   ;TIMER_MICROSECONDS = 4,000,000
 bl TIMER
 pop {r0-r11}

;read first block of GPIOs
ldr r9,[r10,#52] ;read gpios 0-31
tst r9,#1024  ; use tst to check bit 10
bne Paper ;if ==0 e.g user selects Rock

;ldr r9,[r10,#52] ;read gpios 0-31

;else user selects Scissors
bl setup_chars
adr r2,rock ; R2 = Text Offset "Scissors"
b DrawChars
b cont

Paper:
 tst r9,#2048
 bne Scissors ;if user selects Paper
 bl setup_chars
 adr r2,paper; R2 = Text Offset "Rock"
 b DrawChars
 str r13,[r10,#28]
 b cont

Scissors:
 bl setup_chars_ai
 adr r2,scissors ; R2 = Text Offset "Paper"
 b DrawChars
 b cont

cont:

b loop$

setup_chars:
; Setup Characters
 mov r0,r7
 mov r1,SCREEN_X
 lsl r1,r1,5 ;32
 orr r1,#256
 add r0,r1 ; Place Text At XY Position 256,32
 adr r1,Font ; R1 = Characters
 mov r3,#8 ; R3 = Number Of Text Characters To Print
bx lr

setup_chars_ai:
 ; Setup Characters
 mov r0,r7
 mov r1,SCREEN_X
 lsl r1,r1,10 ;32
 orr r1,#256
 add r0,r1 ; Place Text At XY Position 256,32
 adr r1,Font ; R1 = Characters
 mov r3,#8 ; R3 = Number Of Text Characters To Print
bx lr

include "FBinit8.asm"
include "timer2_2Param.asm"
include "DrawChar.asm"
align 4
rock:
  db " Rock !"
align 4
paper:
  db " Paper !"
align 4
scissors:
 db "Scissors"

align 4
Font:
  include "Font8x8.asm"



