macro	zz:rm	mov $1, $2
macro	zz:mr	mov $1, $2

macro	add:r[Mmri][ri]	mov $1, $2\; add $1, $3
	
	add	r1, r2, r3
	add	r1, [r5+2], 3

	zz	r1, [r1]
	zz	[r0], r1
	
	push	r3, r4, r5
	pop	r3, r4, r5
	
	push	r1
	pop	r0
	