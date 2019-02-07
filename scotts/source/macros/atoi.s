//Scott Saunders 10163541 


//Algorithm: Read the leftmost charector, do error checks, and add to the sum
//				Read the next left charector, 
//				do error checks, if good multiply sum by 10 and then add it.
//				repeat count times.

//Paramiters: 
//			 First is a buffer is a register with a pointer to a buffer.
//			 Second is a intiger with the number of elements to process form the buffer.
//


//Returns:
//	int in r0
//	-1 if the string is a negative or not a number.
//

atoi_err_msg_under:		.asciz		"Not an integer\n\r"
atoi_err_msg_over:		.asciz		"Not an integer\n\r"
.align 4

atoi:
	push {r1-r12,lr}
	buffer 	.req	r9
	end		.req	r8
	cnt		.req	r7
	sum		.req	r0
	char	.req	r1
	int		.req	r1
	a10		.req	r12
	mov		a10,	#10
	mov	buffer,	r0				//Copys the addr of the buffer to r9 //
	mov end,	r1				//Put the count in r8
	mov	cnt,	#0				//Setup an incrmenting counter
	mov	sum,	#0				//Store zero in the sum


//Check for negative number:
	ldrb	char,	[buffer]
	cmp		char,	#'-'
	bne		atoi_loop
	//todo properly, however for A1, this will do.
	mov		r0,	#-1		//Just needs to be out of range
	b		atoi_end

atoi_loop:					//Is a do-while loop, so it will always convert 1 intiger.
	ldrb	char, [buffer , cnt]   //Load the char
	add		cnt,#1			//Increment counter.
	sub		int,	#'0'		//Get the "intiger" (if it is in range..)
	cmp		int,	#0			//Do a check for lower bound
	blt		atoi_e_tosmall
	cmp		int,	#9			//Do a check for upper bound
	bgt		atoi_e_tolarge

//	mul		sum,	a10

	lsl		r3,		sum,	#3	//r7 = sum*8
	lsl		sum,	sum,	#1	//sum = sum*2			//A better multiplication.
	add		sum,	r3			//sum = (sum*8 + sum*2) = sum * 10 

	add		sum, int		//Add the current integer to the sum.
	cmp		cnt, end		//See if count has been reached.
	blt		atoi_loop
	b		atoi_end
	
//Uses the print message macro and global atoi_error messages.

atoi_e_tosmall:
	print	atoi_err_msg_under,16
	mov		r0,	#-1   					//ERROR CODE (not a number)
	b 		atoi_end

atoi_e_tolarge:
	print	atoi_err_msg_over,16
	mov		r0,	#-1						//ERROR CODE (not a number)
	b 		atoi_end

atoi_end:
	.unreq	buffer
	.unreq	end
	.unreq	cnt
	.unreq	sum	
	.unreq	char
	.unreq	int
	.unreq	a10	

	pop {r1-r12,lr}
	bx	lr
