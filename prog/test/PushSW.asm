	text

PORT_PushSW	equ	0
PORT_LEDData	equ	0
PORT_LEDLine	equ	1
	
	movi	r1, 8000h
	
loop:
	mov	r0, [r1+PORT_PushSW]
	mov	[r1+PORT_LEDData], r0
	mov	r0, 5
	mov	[r1+PORT_LEDLine], r0
	
	jmp	loop
	nop
	