//Scott	Saunders
//	10163541
//	March 30, 2016
.macro	d_ldr	reg,val:req
		ldr	\reg,	=\val		//Gets the addr
		ldr	\reg,	[ \reg ]		//Loads the value of addr
.endm

.section	.text
.align	4
init_xor_rand:
	push	{r0-r4,lr}

	d_ldr		r0,	0x20003004		//Load system timer
	ldr		r1,	=xorshift_data
	str		r0,	[r1,#0xc]		//Store into w
	
	mov		r1,	#0
xorshift_init_loop:			//Generate a bunch of random numbers to populate it.
	bl	xorshift

	cmp		r1,	#0xf000
	addle	r1, #1
	ble		xorshift_init_loop

	pop		{r0-r4,lr}
	bx		lr

random:
xorshift:
	push	{r1-r5}
	ldr		r6,	=xorshift_data

	ldr		r0,	[r6], #4
	ldr		r1,	[r6], #4
	ldr		r2,	[r6], #4
	ldr		r3,	[r6]

	eor		r5, r0,	r0, lsl	#11
	eor		r5,	r5, lsr #8
	
	mov		r0,	r1	//x=y
	mov		r1,	r2	//y=z
	mov		r2,	r3	//z=w

	eor		r3,	r3,	lsr	#19
	eor		r3,	r5

	str		r3,	[r6],	#-4		
	str		r2,	[r6],	#-4
	str		r1,	[r6],	#-4
	str		r0,	[r6]
	
	mov		r0,		r3

	pop		{r1-r5}
	bx	lr



.section	.data
xorshift_data:
.word	0	//x	0x0
.word	0	//y	0x4
.word	0	//z	0x8
.word	0	//w	0xc

.section	.text
.align	4
