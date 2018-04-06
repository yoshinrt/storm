IOPORT	equ	0x4000
	
	mov	r0, 0
	movi	r3, IOPORT
	mov	r4, r3
read:	mov	[r4+6], r1
wait:	mov	r1, [r4]
	tst	r1
	js	wait
	nop
	nop
	nop
	
	jmp	read
	inc	r0
