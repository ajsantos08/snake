//Scott Saunders
//March 4,9 2016

//Setup
//GPIO is setup in sets of registers, 10 Lines per register
	GPFSEL0	= 0x20200000	//(0-9)
	GPFSEL1	= 0x20200004	//(10-19)
	GPFSEL2	= 0x20200008	//(20-29)
	GPFSEL3	= 0x2020000c	//(30-39)
	GPFSEL4	= 0x20200010	//(40-49)
	GPFSEL5	= 0x20200014	//(50-53) 	//Special, only 4 Lines
//
//	Each pin has 3 bits (starting at the addr)
//	 ex: GPIO *0 : .....000
//
	GPIO_INPUT	=	000	//	-	Input 	(Read)
 	GPIO_OUTPUT	=	001	//	-	Output 	(Write)
//	Else:	-	"Alternative functions"

gpio_setup: //Arguments: r0 the pin to set, r1 the value to set
	push	{r2-r4,lr}

	value	.req	r2
	addr	.req	r0

	mov 	value,	r1		//Moves the value somewhere else
	mov		r1,	#10		
	bl		intdiv					//Div the pin by 10
	ldr		r3,	=GPFSEL0			//Uses the define above to get base addr.
	add		addr,	r3, r0, lsl #2		//Adds the two togeather, after multiplying r0 by 4.

	//At this point r0(addr) has the GPFSELn for our pin.

	add		r1,	r1,	r1, LSL #1		//Multiply r1 by 3		//The position of our 3 bits.
	lsl		value,	r1					//Shift the pin left by remainder*3 times.
	//At this point r2(value) has the value with the correct offset

	mov		r3,	#7					// 0111 is the last byte
	lsl		r3,	r1					//Shift the pattern to the right position
	
	ldr		r4,	[addr]					//Load the register
	bic		r4,	r3					//Clear the bits for our pin
	orr		r4,	value				//Or our bits in
	
	str		r4,	[addr]				//Saves the GPFSEL0

	pop		{r2-r4,lr}
	.unreq	value
	.unreq	addr
	bx	lr

.macro	gpio_setup_quick	pin,value:req
	push	{r0,r1,lr}
	mov		r0,	\pin
	mov		r1,	\value
	bl		gpio_setup
	pop		{r0,r1,lr}
.endm


//Writing.
//GPIO SET is:   	(Sets HI when a 1 in the register)
//					0x20200000 + #28 (0x1c)	
	GPIOSET0	=	0x2020001c		//First 32 GPIO LINES
//	GPIOSET1	=	0x20200020		//54-32 GPIO Lines
//GPIO Clear is:	(Sets LOW when 1 in the register)
//					0x20200000	+ #40	(0x28)
	GPIOCLR0	=	0x20200028		// + 0, First 32 GPIO Lines
//	CPIOCLR1	=	0x2020002c		// + 4, 54-32 GPIO Lines


//Note: The above table comes from the BCM2835 Documentation	(pg 90)
//Note:	But the below code, uses miss-matching addresses, 
//	as GPIOSET0 seems to make an LED turn off
//	and GPIOCLR0 seems to make an LED turn on 

//That is, a GPIOSET0 makes a line turn off
//and GPIOCLR0	makes a line turn on.

//After several hours, it turns out that that is only the case for the LED. I have no idea why.


gpio_set_hi:		//Arguments: r0 the pin to set hi

	//r0 the pin to set
    addr    .req    r0
    push    {r1-r4,lr}
    
    mov     r1, #32
    bl      intdiv
    ldr     r3, =GPIOSET0
    add     addr, r3,   r0, lsl #2      //Mul r0 by 4 to get GPIOSET1 when needed.

    mov     r4,     #1                  //Move a bit in
    lsl     r4,     r1                  //Shift it by remainder so it's in the right position.
    str     r4,     [addr]              //Store the bit in addr.

    pop     {r1-r4,lr}
    .unreq  addr
	bx		lr


gpio_set_low:		//Arguments: r0 the pin to set low
					//r0 the pin to set
    addr    .req    r0
    push    {r1-r4,lr}
    
    mov     r1, #32
    bl      intdiv
    ldr     r3, =GPIOCLR0
    add     addr, r3,   r0, lsl #2      //Mul r0 by 4 to get GPIOCLR1 when needed.

    mov     r4,     #1                  //Move a bit in
    lsl     r4,     r1                  //Shift it by remainder so it's in the right position.
    str     r4,     [addr]              //Store the bit in addr.

    pop     {r1-r4,lr}
    .unreq  addr
	bx		lr

.macro 	gpio_set_hi_q	pin
	push	{r0,lr}
	mov		r0,	\pin					//Quick call macro
	bl		gpio_set_hi
	pop		{r0,lr}
.endm
.macro	gpio_set_low_q	pin
	push	{r0,lr}
	mov		r0,	\pin					//Quick Call Macro
	bl		gpio_set_low
	pop		{r0,lr}
.endm

//Reading.
//GPIO Level		(Reads the value of GPIO pins)
//					0x20200000	+ #52	(0x34)
	GPIOLEC0	=	0x20200034		//	+ 0, First 32 GPIO Lines
	GPIOLEC1	=	0x20200038		// 	+ 4, 54-32 GPIO Lines

gpio_read_pin:	
    //r0 the pin to get (starts at 0)
    addr    .req    r0  
    push    {r1-r4,lr}

    mov     r1, #32
    bl      intdiv
	ldr		r3,	=GPIOLEC0
    add     addr, r3,   r0, lsl #2      //Mul r0 by 4 to get GPIOLEC1 when needed.
	ldr		r3,	[addr]					//Load the value of registers into r3


	.unreq	addr
	//r3 now has the register with the set of pins of the ones we want.
	rsb		r0,	r1,	#31					//get 32-r1 (remainder)
	lsl		r3,	r0						//Push everything larger than the bit wanted into oblivion
	lsr		r3,	#31						//Pull it down into the one's spot.
		
	mov		r0,	r3
	pop		{r1-r4,lr}
	bx		lr

.macro	gpio_read_pin_q	pin
	push 	{lr}
	mov		r0,	\pin
	pop		{lr}
	bl	gpio_read_pin
.endm

.macro	gpio_read_reg_0				//If I wanted this in the future
	ldr		r0,	[GPIOLEC0]
.endm
.macro	gpio_read_reg_1
	ldr		r0,	[GPIOLEC1]				//If I wanted this.
.endm

