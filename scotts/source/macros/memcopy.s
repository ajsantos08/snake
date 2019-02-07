//	Memcopy
//	Scott Saunders 10163541
//	Paramiters:	* Buffer,	* Buffer,	Count
//	Returns:	Nothing
//
// 	Works top down


buff1	.req	r0
buff2	.req	r1
count	.req	r2


//This is a buffer overflow check/error statments,
//	Sadly this doesn't work for any given bufer
//		It is still usefull for debugging though.


/*			Commented out, as the size isn't always available.
buff1overflow:
	strprint	"\n\rMemcopy: Buff1 overflow, check your count.\r\n",46
	b	overflow

buff2overflow:
	strprint	"\n\rMemcopy: Buff2 overflow, check your count.\r\n",46
	b	overflow

overflow:
	b overflow
*/

memcopy:
//	lsl		count, 	#2
	push	{r3,r4}

//Again, the buffer overflow stuff that is commented out (Good for debugging things)

/* 
	ldrb	r4		,	[buff1 , #-1]	//Check Buffer sizes
	cmp		r4		,	count
	blt		buff1overflow
	ldrb	r4		,	[buff2 , #-1]
	cmp		r4		,	count
	blt		buff2overflow				//Check buffer sizes
*/	
	mov		r4,	#0

memcopy_loop:
	LDRb		r3,	[buff1,	r4]		//Load a byte
	STRb		r3,	[buff2,	r4]		//Save the byte
	addne	r4,	#1					//Inc
	cmp		r4,	count				//Cmp
	blt		memcopy_loop			//Loop

memcopy_end:
	pop		{r3,r4}
	bx 		lr

