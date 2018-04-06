	text

PORT_LEDData	equ	0
PORT_LEDLine	equ	1
	
macro	SetLED
	movi	r0, $2
	mov	[r1+PORT_LEDData], r0
	mov	r0, $1
	mov	[r1+PORT_LEDLine], r0
	
	mov	r3, 1023
	dec	r3
	jnz	$
	dec	r3
	nop
	nop
endm
	
	movi	r1, 8000h
	
loop:	SetLED	0,  0000110000b
	SetLED	1,  0011001100b
	SetLED	2,  0100000010b
	SetLED	3,  0100000010b
	SetLED	4,  1000000001b
	SetLED	5,  1000000001b
	SetLED	6,  0100000010b
	SetLED	7,  0100000010b
	SetLED	8,  0011001100b
	SetLED	9,  0000110000b
	SetLED	10, 0000110000b
	SetLED	11, 0011001100b
	SetLED	12, 0100000010b
	SetLED	13, 0100000010b
	SetLED	14, 1000000001b
	SetLED	15, 1000000001b
	SetLED	16, 0100000010b
	SetLED	17, 0100000010b
	SetLED	18, 0011001100b
	SetLED	19, 0000110000b
	jmp	loop
	nop
	