//Scott Saunders
//	10163541
//	March 23,	2015

.section	.text

//Generate a bitmask of length N, starting at the LSB.
bitmask_gen:
	push	{r1,lr}
	mov		r1,		r0
	mov		r0,		#0

bitmask_gen_l:

	lsl		r0,	#1
	orr		r0,	#1
	sub		r1,	#1			//Dec counter by 1.

	cmp		r1,		#0
	bgt		bitmask_gen_l	

	pop		{r1,lr}
	bx		lr

.macro	bitmask_gen_q 	out,	reg:req
	//NOTE: DO NOT USE IF BITMASK return is r0.
	push 	{r0,lr}
	mov	r0,	\reg
	bl	bitmask_gen
	mov	\out,	r0
	pop		{r0,lr}
.endm
