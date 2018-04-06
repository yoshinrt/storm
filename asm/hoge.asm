rs	equ	r4
rr	equ	r7

hog:	mov	[r4 + 0x55], r4
hoge:	mov	r2, r4
	mov	r3, [0xAB]
	mov	r5, 0xAB
	tst	r1
	push	r0
	ret
	jmp	r7
