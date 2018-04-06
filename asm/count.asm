Loop2:	mov	r1, 5
loop:	inc	r2
	nop
	sbb	r1, 0
	jnz	loop
	nop
	nop
	nop
	
	inc	r0
	jmp	Loop2
	nop

	data
Cnt:	dw	366
