# led gradation

loop:	mov	r2, 1
	mov	r4, 0
	
	cmp	r0, 1	# if( r0 < 1 )
	mov	r3, 0
	sbb	r3, 0	#   r3 = 0xFFFF;
	and	r3, r2	# r3 = ( r0 < 1 ) ? r2 : 0;
	or	r4, r3
	shl	r2
	
	cmp	r0, 2
	mov	r3, 0
	sbb	r3, 0
	and	r3, r2
	or	r4, r3
	shl	r2
	
	cmp	r0, 3
	mov	r3, 0
	sbb	r3, 0
	and	r3, r2
	or	r4, r3
	shl	r2
	
	cmp	r0, 4
	mov	r3, 0
	sbb	r3, 0
	and	r3, r2
	or	r4, r3
	shl	r2
	
	cmp	r0, 5
	mov	r3, 0
	sbb	r3, 0
	and	r3, r2
	or	r4, r3
	shl	r2
	
	cmp	r0, 6
	mov	r3, 0
	sbb	r3, 0
	and	r3, r2
	or	r4, r3
	shl	r2
	
	cmp	r0, 7
	mov	r3, 0
	sbb	r3, 0
	and	r3, r2
	or	r4, r3
	shl	r2
	
	cmp	r0, 8
	mov	r3, 0
	sbb	r3, 0
	and	r3, r2
	or	r4, r3
	shl	r2
	
	######
	
	inc	r0
	mov	r1, r4
	jmp	loop
	and	r0, 0x7		# slot
	