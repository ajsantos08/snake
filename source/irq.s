//Scott	Saunders
//	10163541
//	March 29,	2016

.section	.text
irq_base	=	0x2000B200
//0x204 is pending1
//0x208 pending2
//0x20C FIQ control
//0x210 Enable IRQs 1
//0x214 Enable IRQs 2
//0x218 Enable Basic IRQs
//0x21C Disable IRQs 1
//0x220 Disable IRQs 2
//0x224 Disable Basic IRQs


//The IRQ handler.
.globl irq
irq:	
	push	{r0-r12, lr}
	
	bl	disable_irq
	
	ldr		r0,	=irq_base		//Loads the basic_irq_state
//	ldr		r1,	[r0]				//Seems to be a composition of the other two.
//	cmp		r1,	#0							
//	blne		irq_basic			//Branch if that triggered it.

	ldr		r1,	[r0, #4]			//Pending1
	cmp		r1,	#0
	blne		irq_pend1
	
	ldr		r1,	[r0, #8]
	cmp		r1,	#0
	blne	irq_pend2

.globl	irq_end

irq_end:

	bl  enable_irq

	pop		{r0-r12, lr}
	subs	pc, lr, #4

.globl	irq_basic
irq_basic:
	//Not handled.
	bx	lr

.globl	irq_pend1
irq_pend1:

	push	{r0,lr}
	//System_timer IRQ handling:
	//0x20003000 -- reg check
	ldr		r0, =0x20003000 
	ldr		r0,	[r0]
	cmp			r0,	#0
	blne		sys_timer_irq	//In sys_timer.s

	pop		{r0,lr}
	//Else, I do not handle it, so end!
	b	irq_end
.globl	irq_pend2
irq_pend2:
	//Not handled.
	bx	lr	

.section	.data


.section	.text
