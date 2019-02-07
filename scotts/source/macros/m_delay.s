//Scott Saunders 10163541
//Somes macros/delay loops
//Mostly for debugging/ odd bugs

.macro	mdelay num	//Uses tooo much ram. Do not use.
	.rept	\num
	qdelay	\num
	.endr
.endm

.macro	qdelay num
	push	{r0,lr}
	ldr		r0, =\num
	bl		delay
	pop		{r0,lr}
.endm


delay:
	cmp	r0,	#0
	subgt r0, #1
	bgt delay
	bx 	lr

rec_delay:
	cmp	r0,	#0
	subgt r0, #1
	push 	{r0, lr}
	bl delay
	pop		{r0,lr}
	bx 	lr
