DataSize equ	1000
	text
	
	# create random data
	
	movi	r0, 0xABCD
	movi	r3, 0x1021
	movi	r4, DataSize - 1;
	
	# r0 = random number
	shl	r0
	mov	r2, 0
	sbb	r2, 0
Init1:	dec	r4
	and	r2, r3
	xor	r0, r2
	mov	[r4 + 1], r0
	tst	r4
	jnz	Init1
	shl	r0	#slot
	mov	r2, 0	#slot
	sbb	r2, 0	#slot
	
	# buble sort
	movi	r5, DataSize - 1
	mov	r0, [r5]	# key
	mov	r4, 0
	
	# if( r0 < *r4 ) swap( r0, *r4 );
	mov	r1, [r4]
BSort0:	cmp	r0, r1
BSort1:	jge	BSort5
	inc	r4		#slot
	mov	r2, r0		#slot
	cmp	r5, r4		#slot
	mov	r0, r1
	mov	[r4 - 1], r2
	
BSort5:
	jnz	BSort1
	mov	r1, [r4]
	mov	[r5], r0
	cmp	r0, r1
	
	dec	r5
	jnz	BSort0
	mov	r0, [r5]	# key
	mov	r4, 0
	mov	r1, [r4]
	
	# check sort status
	
	mov	r4, 0
	movi	r7, DataSize
	mov	r0, [r4]
	
	mov	r1, [r4 + 1]
	inc	r4
	cmp	r0, r1
Check1:	jg	Error
	inc	r4		#slot
	mov	r0, r1		#slot
	cmp	r4, r7		#slot
	jnz	Check1
	mov	r1, [r4]
	nop
	cmp	r0, r1
	#succ
	mov	r0, 0
	hlt
	
Error:	mov	r0, 0xFF
	hlt
