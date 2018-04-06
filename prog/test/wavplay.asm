# wave player

PORT_GetData		equ	6
PORT_BeepDivider	equ	2
PORT_BeepDivident	equ	3

	text
	
	movi	r2, 0x4000
	mov	r4, r2
	movi	r2, 0x8000
	mov	r5, r2
	
	movi	r3, -1			# 22KHz セット
	
	### 18clk ###
main:
	mov	r2, [r4]			# 1byte 読む
	mov	[r4 + PORT_GetData], r7		# 1byte read 要求
	
	mov	r6, 0xFF	# clear PIO status bit
	and	r2, r6
	shr	r6, r2		# r6 = r2 >> 4
	shr	r6, r6
	shr	r6, r6
	shr	r6, r6
	add	r2, r6		# r2 = r2 + r6
	#nop
	shr	r0, r2		# r2 >>= 1
	
	mov	r6, 267				# On 時間
	mov	[r5 + PORT_BeepDivider],  r3	# 22KHz セット
	mov	[r5 + PORT_BeepDivident], r0	# Beep レジスタにセット
	
	dec	r6
	
	nop
	nop
	nop
	
	### 4 x 267 = 1068clk ###
	
Loop:	jnz	Loop
	dec	r6
	nop
	nop
	
	### 2clk ###
	
	jmp	main
	nop
