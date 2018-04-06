PORT_GetData		equ	6
	
	movi	r1, 0x4000
	mov	r4, r1
	
	mov	[r4 + PORT_GetData], r2
	
loop:	mov	r2, [r4]
	tst	r2
	js	skip
	swp	r1, r2
	nop
	nop
	mov	[r4 + PORT_GetData], r2
#	jmp	loop
	inc	r0
	
skip:
	mov	r7, 400
	dec	r7
wait:	jnz	wait
	dec	r7
	nop
	nop
	jmp	loop
	nop
