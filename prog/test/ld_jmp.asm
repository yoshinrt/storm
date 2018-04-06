	text
	
	mov	r5, a
	call	z
	hlt
	
z:	mov	[r5], r7
	mov	r7, [r5]
	ret
	inc	r0

	data
a:	dw	0
