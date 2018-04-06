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
	
	jmp	GetKey
	nop
	
GetKey9:
	
	jmp	GetKey
	inc	r0

	data
PreKey:	dw	0
