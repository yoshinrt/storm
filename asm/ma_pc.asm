rr	equ	r7
rs	equ	r5

	text
	
	mov	r0, 10
	call	Sum
	hlt
	
Sum:	cmp	r0, 1
	jbe	exit
	push	r0	# slot x 2
	nop		# slot
	dec	r0
	push	rr
	call	Sum
	
	add	rs, 1
	mov	rr, [rs-1]
	jmp	rr
	nop
	
	pop	rr
	pop	r1
	ret
	add	r0, r1	# slot
	
exit:	ret
	inc	rs	# slot
