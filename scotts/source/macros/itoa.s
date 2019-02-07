//Scott Saunders 	10163541

//Paramiters: 	*buffer,	intiger

//Return:	* buffer, int (length)

//	Note: The buffer needs it's size listed the address prior. 	//
//	Okay for A1, but will need to be redone in the future.		//

//Algorithm:	
//
//	Take an intiger, and solve int = q*10	+ r.
//		where 0 <= r <= 9 
//		Push r onto an ascending stack (that is initally at the bottom of the buffer)
//		repeat with int' = q till q is equal to zero (ie, q*10 q is zero,
//			and r is still an int (you still push this on a the ascending stack)
//		Then move the (via memcopy) the top of the ascending stack to the begging of
//			the buffer. (Like a string should)
//

buffer	.req	r0
int		.req	r1
cnt		.req	r2
remain	.req	r3
ebuff	.req	r5

itoa:	
	push	{r0,r2-r12,lr}
	mov		cnt, #1						//Start at 1 for correct offset at end of buff.
	mov		r4,	#10	

	//In hindsight, Implementing this this way, is not good for arbitrary buffers
	ldrb	ebuff,	[buffer , #-1]		//The length of buffer
	add		ebuff, buffer				//Now the end of buffer
	
itoa_loop:
	
	//intdiv int,#10
	push	{r0,lr}
	mov		r0,	int
	mov		r1,	r4		//Moves 10 to denominator
	bl	intdiv
	nop
	//quotent in r0
	//remainder in r1
	mov		remain,r1 
	mov		int,r0
	pop		{r0,lr}
	
	cmp 	int,	#0	
	add		remain,	#'0'		//Convert to ASCII
	//The offset of 1 for cnt is used here to keep it within the buffer's space.
	strb	remain,	[ebuff , -cnt]	
	add		cnt,	#1
	bne		itoa_loop

	
	sub		cnt,	#1			//Undose the inital count 
	sub		ebuff,	cnt			//Gets the top of values

	//Move the string to the top of the buffer
	mov		r1,	buffer			//Destination buffer
	mov		r0,	ebuff			//Source ebuff
	mov		r3,	cnt				//Save cnt (cnt already in r2)
	bl	memcopy	

	mov		r1,	r3				//Return length
	pop		{r0,r2-r12,lr}
	bx	lr

.unreq	buffer
.unreq	int
.unreq	cnt
.unreq	remain
.unreq	ebuff
