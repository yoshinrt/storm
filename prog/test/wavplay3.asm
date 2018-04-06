##############################################################################
#
#	WAV file player for STORM
#	Copyrignt(C) 2002 by Deuy Deyu Software
#
#	1088clk = 22.05KHz
#
##############################################################################

PORT_GetData		equ	6
PORT_LEDData		equ	0
PORT_LEDLine		equ	1
PORT_BeepDivider	equ	2
PORT_BeepDivident	equ	3

### macro ####################################################################

macro SetLEDBit
	shl	r0
	mov	r6, $1
	cmp	r6, r1
	adc	r0, 0
endm

### main #####################################################################
	
	text
	#jmp	main, 0	# デバッグ用
	
	movi	r0, 0x4000
	mov	r4, r0
	movi	r0, 0x8000
	mov	r5, r0
	
	mov	r0, [r4]			# 1byte 読む
	tst	r0
WaitStart:
	js	WaitStart
	mov	[r4 + PORT_GetData], r6		# 1byte read 要求
	
	### main loop ###
main:
	mov	r0, [r4]			# 1byte 読む
	
	tst	r0
	js	main
	nop
	nop
	nop
	
	mov	[r4 + PORT_GetData], r6		# 1byte read 要求
	
	mov	r6, 0xFF	# clear PIO status bit
	and	r0, r6
	mov	r1, r0
	shr	r6, r0		# r6 = r0 >> 4
	shr	r6, r6
	shr	r6, r6
	shr	r6, r6
	add	r0, r6		# r0 = r0 + r6
	#nop
	shr	r0, r0		# r0 >>= 1
	
	#mov	r6, -1
	mov	r6, 136
	mov	[r5 + PORT_BeepDivider],  r6	# 22KHz セット
	mov	[r5 + PORT_BeepDivident], r0	# Beep レジスタにセット
	
	# LED Matrix に表示するデータを作る
	
	sub	r1, r6, 0x80
	jnc	MakeDt1
	mov	r0, 0
	nop
	xor	r1, -1	# r1 = ~r1
	
	jmp	MakeDt5
	inc	r1
	
MakeDt1:
	xor	r1, -1
	nop
MakeDt5:
	cmp	r7, 10
	jb	MakeDt6
	nop
	nop
	nop
	
	SetLEDBit 11
	SetLEDBit 23
	SetLEDBit 34
	SetLEDBit 46
	SetLEDBit 58
	SetLEDBit 69
	SetLEDBit 81
	SetLEDBit 93
	SetLEDBit 104
	SetLEDBit 116
	jmp	MakeDt7
	nop
	
MakeDt6:
	SetLEDBit 116
	SetLEDBit 104
	SetLEDBit 93
	SetLEDBit 81
	SetLEDBit 69
	SetLEDBit 58
	SetLEDBit 46
	SetLEDBit 34
	SetLEDBit 23
	SetLEDBit 11
	nop
	nop
MakeDt7:
	or	r3, r0
	dec	r2
	jc	MakeDt8
	nop
	nop
	nop
	
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	jmp	MakeDt9
	nop
MakeDt8:
	mov	r2, 30
	
	# LED に表示
	mov	[r5+PORT_LEDData], r3
	mov	[r5+PORT_LEDLine], r7
	
	inc	r7
	nop
	cmp	r7, 20
	
	jnz	MakeDt9
	mov	r3, 0
	nop
	nop
	
	jmp	Loop0
	mov	r7, 0
	
MakeDt9:
	nop
	nop
Loop0:
	mov	r6, 248
	dec	r6
	# 1088 - (↑ここまでの clk 数 + 2 ) / 4 を r6 に set
	# あまりを nop で補う
	
Loop:	jnz	Loop
	dec	r6
	nop
	nop
	
	### 2clk ###
	
	jmp	main
	nop

mainz:	hlt
