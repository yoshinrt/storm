rr	equ	r7
rs	equ	r5

	text
	
	mov	r0, 10
	call	Sum
	hlt
	
Sum:	cmp	r0, 1
	jbe	exit
	push	r0	# slot x 2
	dec	r0	# slot
	push	rr
	call	Sum
	#pop	rr
	#pop	r1
	mov	rr, [rs]
	mov	r1, [rs+1]
	add	rs, 2
	ret
	add	r0, r1	# slot
	
exit:	inc	rs	# slot
	ret
	inc	r0
