JMP main

isr:
PUSH A ; Store the registers that ISR uses.
MOV A, 2 ; Set the second bit to clear the interrupt.
OUT 2 ; Clear the interrupt (A -> IRQEOI).
MOV B, 0x0F00
MOV A, 0x0400
CALL loop
POP A
IRET

loop:
CALL count
MOVB [A], CL
INC A
INC B
CMP B, 0x0FFF
JNA loop
MOV B, 0x0F00
MOV A, 0x0400
loop2:
CALL change
INC B
INC A
CMP B, 0x0FFF
JNA loop2
;MOV A, 0 ; Otherwise stop by disabling all interrupts.
;OUT 0 ; Unmask interrupts (A -> IRQMASK).
;POP A
RET

change:        
MOV D, 0       ;clear
MOVB DL, [B]
CMPB DL, 0xFF
JE white
MOVB DL, [A]
CMPB DL, 2
JE alive
CMPB DL, 3
JE alive
MOVB DL, 0xFF
MOVB [B], DL
RET

white:
MOVB DL, [A]
CMPB DL, 3
JE alive
RET

alive:
MOVB DL, 0
MOVB [B], DL
RET


image:
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\x00\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
DB "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"


up:
SUB B, 16
CMP B, 0x0F00
JB return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

upleft:
SUB B, 17
CMP B, 0x0F00
JB return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

upright:
SUB B, 15
CMP B, 0x0F00
JB return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

left:
SUB B, 1
CMP B, 0x0F00
JB return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

downleft:
ADD B, 15
CMP B, 0x0FFF
JA return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

down:
ADD B, 16
CMP B, 0x0FFF
JA return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

downright:
ADD B, 17
CMP B, 0x0FFF
JA return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

right:
ADD B, 1
CMP B, 0x0FFF
JA return
MOVB DL, [B]
CMPB DL, 0
JNE return
INC C
RET

return:
RET

count:
MOV C, 0
MOV D, 0
CALL up
ADD B, 16
CALL upleft
ADD B, 17
CALL upright
ADD B, 15
CALL left
ADD B, 1
CALL downright
SUB B, 17
CALL downleft
SUB B, 15
CALL down
SUB B, 16
CALL right
SUB B, 1
RET 

; Receives a pointer to 16x16 image in A.
draw_image:
MOV D, 0x0F00 ; The address of the first pixel.
draw_image_loop:
CMP D, 0x0FFF ; Fill the whole display.
JA draw_image_return
MOVB CL, [A] ; Get the color of the pixel.
MOVB [D], CL ; Set the pixel color.
INC A ; Next color.
INC D ; Next pixel.
JMP draw_image_loop
draw_image_return:
RET ; Nothing to return.

str: DB "Game of life"
     DB 0

;function strcpy receiving string as argument in A and destination in B
;return nothing
strcpy:
MOV C, 0             ;clear register C
cpy_loop:
MOVB CL, [A]         ;copying char by char in each iteration
                     ;(the value of the pointer, not the address)
CMPB CL, 0           ;see if it reached the end (equal to 0)
JE cpy_return        ;if so, go to return
MOVB [B], CL         ;else move the char to the value of the given addres
INC B                ;increment the pointer to the next address
INC A                ;increment the pointer to the next char
JMP cpy_loop         ;go to next iteration
cpy_return:
RET                  ;return nothing

main:
MOV SP, 0x0EDF
MOV A, str
MOV B, 0x0EE2
CALL strcpy
MOV A, image
CALL draw_image
MOV A, 2000 ; 1 second = 1000 cycles.
OUT 3 ; Preload counter to 1000.
MOV A, 2 ; Set the second bit to enable timer interrupts.
OUT 0 ; Enable timer interrupts (A -> IRQMASK).
STI ; Enable interrupts globally (M = 1).
HLT








