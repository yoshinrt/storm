	data
	
aa:	dw	0xABCD
	
	text
	
	mov	r0, 0x3FF
	mov	r1, 0xABCD
	mov	r3, 0xFF00
	mov	r2, aa
	hlt
	