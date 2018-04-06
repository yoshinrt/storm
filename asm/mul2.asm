	text
	
	mov	r0, [Op1]
	mov	r1, [Op2]
	mov	r2, 0
	
	shr	r0
	sbb	r3, r3		# r3 = ( cy ) ? r1 : 0;
	and	r3, r1		# r3 = r1 / 0
Loop:	add	r2, r3
	shl	r1
	jnz	Loop
	shr	r0
	sbb	r3, r3		# r3 = ( cy ) ? r1 : 0;
	and	r3, r1		# r3 = r1 / 0
	
	mov	[Ans], r2
	hlt
	
	data
	
Op1:	dw	0xAA
Op2:	dw	0x55
Ans:	dw	0
