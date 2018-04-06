	mov	r1, 0x3FF
	mov	r2, [r1]
	dec	r1
loop:	jnc	loop
	mov	r2, [r1]
	inc	r0
	dec	r1
	jmp	loop
	mov	r1, 0x3FF

IOPORT	equ	0x4000
	
	mov	r1, 0
	movi	r3, IOPORT
	mov	r4, r3
wait:	mov	r0, [r4]
	shl	r0
	js	wait
	nop
	nop
	nop
	
	mov	[r4+7], r1
	jmp	wait
	inc	r1
	
	
	movi	r3, IOPORT
	mov	r4, r3
	
Empty:	mov	r0, [r4]
	shr	r2, r0
	shr	r2
	shr	r2
	shr	r2
	shr	r2
	tst	r0
	js	Empty
	shr	r2
	shr	r2
	shr	r1, r2
	
	xor	r1, 00100000b
	hlt
