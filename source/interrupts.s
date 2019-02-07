//	Scott	saunders
//	10163541
//	March 29	2016


.section	.text
Interrupt_base	=	0x2000B000



.globl	enable_irq
enable_irq:
	push	{r0}
	mrs		r0, cpsr
	bic		r0, #0x80		//Enables the IRQ in cpsr.
	msr		cpsr_c, r0
	pop		{r0}
	bx		lr

.globl	enable_a_irq
enable_a_irq:
	//TODO: Make it work on the high 32 and 64 channels instead of just 0.
	//Takes in r0, the bit in the "array" of irq's to set.

	push	{r1,lr}
	ldr		r1,	=0x2000B210		//Address for 0-32 IRQ's
	ldr		r3,	[r1]
	orr		r3,	r0
	str		r3,	[r1]

//	bl	enable_irq				//Enables the cpsr IRQ.

	pop		{r1,lr}
	bx		lr

.global	disable_a_irq
disable_a_irq:
	//TODO: Make it work on the high 32 and 64 channels instead of just 0.
	//Takes in r0, the bit in the "array" of irq's to set.

	push	{r1,lr}
	ldr		r1,	=0x2000B21C		//Address for 0-32 IRQ's
	str		r0,	[r1]

	pop	{r1,lr}
	bx	lr

.globl	disable_irq
disable_irq:
	push	{r0}
	mrs		r0, cpsr
	orr		r0, #0xc0		//Disables the IRQ in cpsr.
	msr		cpsr_c, r0
	pop		{r0}
	bx		lr
		
.globl	setup_irq_handler
setup_irq_handler:
	push	{lr}
	bl	InstallIntTable
	nop
	pop		{lr}
	bx		lr

//From TA's Code:
.globl	InstallIntTable
InstallIntTable:
	ldr		r0, =int_table
	mov		r1, #0x00000000

	bl	disable_irq	

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x80000000

//	mov			r0,	#0
//	d_ldr		r0,	=main				//I have no idea why this doesn't work.
//	bx			r0

	b		main
//	bx		lr			///Didn't seem to work, infinite loop in int_table
