PORT_PushSW		equ	0
PORT_LEDData		equ	0
PORT_LEDLine		equ	1
PORT_BeepDivider	equ	2
PORT_BeepDivident	equ	3

PushKeyCnt	equ	16

macro	in		movi r1, 0x8000 \; mov $1, [r1 + $2]
macro	out		movi r1, 0x8000 \; mov [r1 + $1], $2
macro	SetBeep1	movi r2, $1\; call SetBeep

	text
	
Up:	mov	r4, Pat0
	mov	r2, 0
	call	WaitEvent
	jnz	Up
	nop
	nop
	nop
	
Left:	mov	r4, Pat1
	mov	r2, 1
	call	WaitEvent
	jnz	Up
	nop
	nop
	nop
	
Down:	mov	r4, Pat2
	mov	r2, 2
	call	WaitEvent
	jnz	Up
	nop
	nop
	nop
	
Right:	mov	r4, Pat3
	mov	r2, 3
	call	WaitEvent
	jnz	Up
	nop
	nop
	nop
	
	# super event!!
	
	mov	r3, 8		# sound length
MainLoop:
	SetBeep1	11467
	SetBeep1	10216
	SetBeep1	9101
	SetBeep1	8590
	SetBeep1	7653
	SetBeep1	6818
	SetBeep1	6074
	SetBeep1	5733
	jmp	Up
	nop
	
#*** pat •\Ž¦ & ‰Ÿ‚³‚ê‚½ key ‚É‚æ‚è sound ”­¶ *********************
# -->	r4 : pattern addr
#	r2 : key#
# <--	r1 : 0:succ -1:fail
	
WaitEvent:
	push	rr
	sub	rs, 2
	mov	[rs + 1], r4
	mov	[rs], r2
	
WEvent1:
	mov	r4, [rs + 1]
	call	DispPat
	call	GetKey
	
	js	WEvent1		# loop until pushed
	nop
	nop
	nop
	
	mov	r2, [rs]
	cmp	r1, r2
	jnz	WEventErr	# if wrong key, beep
	nop
	mov	r3, 15		# success sound
	movi	r2, 3409
	call	SetBeep
	movi	r2, 4295
	call	SetBeep
	mov	r1, 0

WEvent9:
	add	rs, 2
	pop	rr
	ret
	tst	r1

WEventErr:
	movi	r2, 20000
	mov	r3, 30
	call	SetBeep
	jmp	WEvent9
	mov	r1, -1

#*** get key *******************************************************
# <-- r1 : pushed key ( -1 / sign == not pushed )

GetKey:
	in	r2, PORT_PushSW
	mov	r1, 0
	
	mov	r3, [PreKey]
	mov	[PreKey], r2
	
GetKey1:
	# if( !r3[0] && r2[0] ) return;
	shr	r3
	
	jc	GetKey5
	shr	r2
	nop
	nop
	
	jc	GetKey9
	nop
	nop
	nop
	
GetKey5:
	jnz	GetKey1
	inc	r1
	nop
	nop
	
	mov	r1, -1
	
GetKey9:
	ret
	tst	r1

	data
PreKey:	dw	0
	
	text

#*** set beep freq & wait ******************************************
# -->	r2 : freg
#	r3 : len
	
SetBeep:
	# set beep freq
	out	PORT_BeepDivider, r2
	shr	r2
	out	PORT_BeepDivident, r2
	
	# wait
	and	r4, 0	# means r4 = 0; clc;
	mov	r6, r3
	
loop:	jnc	loop
	
	#slot
	dec	r4
	nop
	sbb	r6, 0
	
	mov	r2, 0
	out	PORT_BeepDivider, r2
	out	PORT_BeepDivident, r2
	ret
	nop

#*** disp LED Matrix pattern ***************************************
# -->	r4 : pat address

macro	SetMatrix
	mov	r6, [r4 + $1]
	mov	[r1 + PORT_LEDData], r6
	mov	r6, $1
	mov	[r1 + PORT_LEDLine], r6
endm

DispPat:
	# setup reg
	
	movi	r1, 0x8000
	SetMatrix	0
	SetMatrix	1
	SetMatrix	2
	SetMatrix	3
	SetMatrix	4
	SetMatrix	5
	SetMatrix	6
	SetMatrix	7
	SetMatrix	8
	SetMatrix	9
	
	mov	r6, 0
	mov	[r1 + PORT_LEDData], r6
	mov	r6, 9
	mov	[r1 + PORT_LEDLine], r6
	
	ret; nop

	data

Pat0:	dw	0000110000b
	dw	0001111000b
	dw	0011111100b
	dw	0110110110b
	dw	1100110011b
	dw	0000110000b
	dw	0000110000b
	dw	0000110000b
	dw	0000110000b
	dw	0000110000b

Pat1:	dw	0000100000b
	dw	0001100000b
	dw	0011000000b
	dw	0110000000b
	dw	1111111111b
	dw	1111111111b
	dw	0110000000b
	dw	0011000000b
	dw	0001100000b
	dw	0000100000b

Pat2:	dw	0000110000b
	dw	0000110000b
	dw	0000110000b
	dw	0000110000b
	dw	0000110000b
	dw	1100110011b
	dw	0110110110b
	dw	0011111100b
	dw	0001111000b
	dw	0000110000b

Pat3:	dw	0000010000b
	dw	0000011000b
	dw	0000001100b
	dw	0000000110b
	dw	1111111111b
	dw	1111111111b
	dw	0000000110b
	dw	0000001100b
	dw	0000011000b
	dw	0000010000b
	