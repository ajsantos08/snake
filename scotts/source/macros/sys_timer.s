//	Scott Saunders
//	10163541
//	March 29	2016

//System timers / IRQ for them


//  +   0x0     :   Control / Status
//  +   0x4     :   Timer Counter Lower 32
TIMER_LOW   =   0x20003004
//  +   0x8     :   Timer Counter Higher 32
//  +   0xc     :   Timer Compair   0
//  +   0x10    :   Timer Compair   1
//  +   0x14    :   Timer Compair   2
//  +   0x18    :   Timer Compair   3
.section	.text

.align 4

sys_timer_irq:
	push	{lr}
	//Note:	r0 is already loaded with 0x20003000
		//Bit	:	Timer	:	Mask
		//0		:	0		:	0x1
		//1 	:	1		:	0x2
		//2		:	2		:	0x4
		//3		:	3		:	0x8

	mov		r1,		#15
	and		r0,		r1,		r0				//Only grab the non-"reserved" bits.	

	tst			r0,	#1				//For completeness, not actually useable.

	tst			r0,	#2
	blne		t_1_handler

	tst			r0,	#4				//For completeness, not acutally useable..

	tst			r0,	#8
	blne		t_3_handler


	ldr		r1,	=0x20003000			//Write that we handled all the sys_timer IRQ's
	str		r0,	[r1]				

	pop		{lr}
	bx		lr		//Return to irq handlers



t_1_handler:	//The IRQ handler for c1.
	push	{r0-r12,lr}
	print_msg_q	debugmsg
	pop		{r0-r12,lr}	
	bx	lr


debugmsg:	.asciz	"The 1 timer interrupt occurred.\n\r"
debugmsg2:	.asciz	"The 3 timer interrupt occurred.\n\r"
.align 4
t_3_handler:
    push    {r0-r12,lr}
	print_msg_q	debugmsg2
    pop     {r0-r12,lr}
    bx  lr



set_timer_1:					//Could be made generic, but not terribly
								//important.
	//Takes time-delay in r0,
	push	{r1-r4,lr}
	mov		r1,	r0

	ldr		r0,	=TIMER_LOW
	ldr		r2,	[r0]
	add		r1,	r2
	str		r1,	[r0 , #0xc ]	//Offset from Timer_LOW to timer_compiar 1

	mov		r0,	#2
	bl		enable_a_irq

//	bl		enable_irq
	pop		{r1-r4,lr}
	bx		lr

set_timer_3:
	//Takes time-delay in r0,
	push	{r1-r4,lr}
	mov		r1,	r0

	ldr		r0,	=TIMER_LOW
	ldr		r2,	[r0]
	add		r1,	r2
	str		r1,	[r0 , #0x14 ]	//Offset from Timer_LOW to timer_compiar 2

	mov		r0,	#8
	bl		enable_a_irq

//	bl		enable_irq
	pop		{r1-r4,lr}
	bx		lr

	
adv_timer_add:
	//Takes 	address,	time_offset
	


.section	.data
TIMERBUFFSIZE	=	32
timer_buff:
	.rept	TIMERBUFFSIZE
	.byte	0				//It's timer value.
	.byte 	0				//It's branch value.
	.endr