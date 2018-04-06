# LED gradation

BRIGHT_STEP	equ	16
LOOP_COUNT	equ	6532 * 3
	
	text
	
Main:
	mov	r3, -1
#up:
	inc	r3
	movi	r2, LOOP_COUNT
	mov	r0, r3
up:
	call	SetBright
	cmp	r3, BRIGHT_STEP
	jnz	up
	
	#slot
	inc	r3
	movi	r2, LOOP_COUNT
	mov	r0, r3
	
	mov	r3, BRIGHT_STEP + 1
#down:
	dec	r3
	movi	r2, LOOP_COUNT
	mov	r0, r3
down:
	call	SetBright
	tst	r3
	jnz	down
	
	#slot
	dec	r3
	movi	r2, LOOP_COUNT
	mov	r0, r3
	
	jmp	Main
	nop
	
	
# LED ‚Ì–¾‚é‚³ƒZƒbƒg
# r0 : brightness
# r2 : loop count

SetBright:
#SetB1:
	mov	r6, BRIGHT_STEP - 1

#SetB1:
	cmp	r6, r0
	mov	r5, 0
SetB0:
	sbb	r5, 0
SetB1:
	dec	r6
	mov	r1, r5
	jnb	SetB1
	
	#slot
	cmp	r6, r0
	mov	r5, 0
	sbb	r5, 0
	
	dec	r2
	jnz	SetB0
	
	#slot
	mov	r6, BRIGHT_STEP - 1
	cmp	r6, r0
	mov	r5, 0
	
	ret
	nop
