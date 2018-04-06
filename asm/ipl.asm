	# receive 16bit data
Resv:	movi	r1, 0x4000
	or	r2, -1
	js	$
	swp	r2, r0
	mov	r0, [r1]
	tst	r0
	js	$
	mov	r0, r3
	mov	r3, [r1]
	tst	r3
	ret
	and	r0, r2
	
	# request loading prog
	
	movi	r0, 0x40FF
	or	r2, -1
	js	$
	mov	r2, [r0]
	nop
	shl	r2
	mov	r0, 0
