//Scott	Saunders
//March	4	2016

//System Timers:	0x20003000
//	+ 	0x0		:	Control / Status
//	+	0x4		:	Timer Counter Lower 32
TIMER_LOW	=	0x20003004
//	+	0x8		:	Timer Counter Higher 32
//	+	0xc		:	Timer Compair	0
//	+	0x10	:	Timer Compair	1
// 	+	0x14	:	Timer Compair	2
//	+	0x18	:	Timer Compair	3


//Simple mode, doesn't compair the higher at all
//Blocking:		Doesn't use an interrupt, just haults code execution till done.
block_timer:		//Time to wait in r0
	push	{r1,r2,lr}
	d_ldr	r1,	TIMER_LOW			//A macro to frist load the address, and then the value of it. (double_ldr)
	add		r0,	r1
	
blocking_timer_wait:
	d_ldr	r1,	TIMER_LOW
	cmp		r0, r1					//Wait till time has elapsed
	bgt 	blocking_timer_wait

block_timer_end:
	pop		{r1,r2,lr}
	bx		lr

.macro	block_timer_q	delay
	push	{r0,lr}
	ldr		r0,	=\delay				//A wrapper macro to call it quickly on one line
	bl	block_timer
	pop		{r0,lr}
.endm	
