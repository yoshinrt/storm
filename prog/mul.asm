	text
	
	mov	r0, [Op1]
	mov	r1, [Op2]
	mov	r2, 0
	
Loop:	shr	r0
	jnc	skip
	mov	r3, r1		# slot
	shl	r1		# slot
	nop			# slot
	add	r2, r3
	tst	r0
skip:	jnz	Loop
	mov	[Ans], r2	# slot
	nop			# slot
	nop			# slot
	hlt
	
	data
	
Op1:	dw	0xAA
Op2:	dw	0x55
Ans:	dw	0
