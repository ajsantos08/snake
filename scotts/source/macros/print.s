//Scott Saunders	10163541
//March	11	2016


	//Takes an address, and prints it.
	//Uses the null terminal to print to the end of the string.
print_msg:
	push	{r1-r4,lr}
	mov		r2,	r0	//Back-up the origonal address

//	bl	find_next_null		//Finds the end of the string (should be a null)
	
	mov		r1,	#0
	bl	find_next_char

	sub		r3,	r0,	r2		//Gets the length of the string (End_addr - First_addr)
	mov		r0,	r2			//Move the address into r0
	mov		r1,	r3			//Move the length into r1

	bl	WriteStringUART		//Prints it via UART.	
	
	pop		{r1-r4,lr}	
	bx		lr


.macro	print_msg_q		lbl
	push	{r0,lr}
	ldr		r0,	=\lbl				//A macro to quickly print a message
	bl		print_msg
	pop		{r0,lr}
.endm
	
find_next_null:		//Takes an address, returns the address with the next null.
	push	{r1,lr}
	mov		r1,	#0
	//Note: This is an inclusive find. If the given address is null it will return it.
find_next_null_loop:
	ldrb	r1,	[r0]	//Load a byte (a char)
	cmp		r1,	#0
	beq		find_next_null_end
	add		r0,	#1
	b		find_next_null_loop

find_next_null_end:
	pop		{r1,lr}
	bx	lr

