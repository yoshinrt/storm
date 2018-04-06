PORT_BeepDivider	equ	14
PORT_BeepDivident	equ	15
	
macro	SetBeep		movi r2, $1\; call SetBeepWait
	
	text
	
	movi	r1, 0x4000	# I/O port base addr
	mov	r3, 8		# sound length
MainLoop:
	SetBeep	11467
	SetBeep	10216
	SetBeep	9101
	SetBeep	8590
	SetBeep	7653
	SetBeep	6818
	SetBeep	6074
	SetBeep	5733
	jmp	MainLoop
	nop


SetBeepWait:
	# set beep freq
	mov	[r1+PORT_BeepDivider], r2
	shr	r2
	mov	[r1+PORT_BeepDivident], r2
	
	# wait
	and	r4, 0	# means r4 = 0; clc;
	mov	r5, r3
	
loop:	jnc	loop
	
	#slot
	dec	r4
	nop
	sbb	r5, 0
	
	ret
	nop
