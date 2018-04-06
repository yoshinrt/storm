	text
	
main:	movi	r2, 0x8D7D
	movi	r3, 0x5B
	
	dec	r2
	nop
	sbb	r3, 0
	nop
	
loop:	jnc	loop
	dec	r2
	nop
	sbb	r3, 0
	
	jmp	main
	inc	r0
	