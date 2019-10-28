  DrawChar:
    ldr r6,[r5],4 ; Load Font Text Character 1/2 Row
    str r6,[r0],4 ; Store Font Text Character 1/2 Row To Frame Buffer
    ldr r6,[r5],4 ; Load Font Text Character 1/2 Row
    str r6,[r0],4 ; Store Font Text Character 1/2 Row To Frame Buffer
    add r0,SCREEN_X ; Jump Down 1 Scanline
    sub r0,CHAR_X ; Jump Back 1 Char
    subs r4,1 ; Decrement Character Row Counter
    bne DrawChar ; IF (Character Row Counter != 0) ;DrawChar
bx lr

DrawChars:
  mov r4,CHAR_Y ; R4 = Character Row Counter
  ldrb r5,[r2],1 ; R5 = Next Text Character
  add r5,r1,r5,lsl 6 ; Add Shift To Correct Position In Font (* 64)
  bl DrawChar
  subs r3,1 ; Subtract Number Of Text Characters To Print
  subne r0,SCREEN_X * CHAR_Y ; Jump To Top Of Char
  addne r0,CHAR_X ; Jump Forward 1 Char
  bne DrawChars ; IF (Number Of Text Characters != 0) Continue To Print Characters
