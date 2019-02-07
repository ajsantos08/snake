.section .text

/////////////////////////////
/////////SNES DRIVER/////////
/////////////////////////////
.globl	init_GPIO
init_GPIO:  //(parameters - (r0 = pin #) / (r1 = pin function)
	push	{r0-r12}
		
	mov 	r3, r1
	
	cmp	r0, #9 //check if it's pin 9
	beq	pin9

	cmp	r0, #10 //check if it's pin 10
	beq	pin10

	cmp	r0, #11 //check if it's pin 11    
	beq	pin11

	pin9:	
	
		ldr  	r0, =0x20200000 //address for GPFSEL0 
		ldr	r1, [r0]  //copy GPFSEL into r1
	
		mov 	r2, #7   //create bits for bic
		bic 	r1, r2, lsl #27	//clear pin 9 bits
	
		orr	r1, r3, lsl #27   //set pin 11 to output in r1
		str 	r1, [r0]     //write back to GPFSEL0
		pop	{r0-r12}
		mov 	pc, lr   //return
	
	pin10:
		
		ldr  	r0, =0x20200004 //address for GPFSEL1
		ldr	r1, [r0]  //copy GPFSEL into r1 
	
		mov 	r2, #7   //  create bits for bic
		bic 	r1, r2	// clear pin10 bits  
	
		orr     r1, r3 //set pin 10 to input in r1       
		str 	r1, [r0] //write back to GPFSEL1
		pop	{r0-r12}
		mov 	pc, lr   //return
	
	pin11:
	
		ldr  	r0, =0x20200004 //address for GPFSEL1
		ldr	r1, [r0]  //copy GPFSEL into r1
	
		mov 	r2, #7   // create bits for bic
        	bic 	r1, r2, lsl #3 //clear pin11 bits     
		
       		orr     r1, r3, lsl #3 //set pin11 to output in r1
       		str 	r1, [r0]   //write back to GPFSEL1
		pop	{r0-r12}
		mov 	pc, lr //return

	
Write_Latch:    // (r0 = parameter for writing {0,1})
	
	ldr	r1, =0x20200000    // address for base GPIO
	mov 	r3, #1    //creating bit for alignment
	lsl	r3, #9    //align bit for pin#9
	teq 	r0, #0    //test to determine write 0 or 1
	streq	r3, [r1, #40]    //GPCLR0    
	strne	r3, [r1, #28]    //GPSET0

	mov 	pc, lr    //return

Write_Clock:    // (r0 = parameter for writing {0,1})
	
	ldr	r1, =0x20200000 //  address for base GPIO    
	mov 	r3, #1    //creating bit for alignment
	lsl	r3, #11   //align bit for pin#11     
	teq 	r0, #0    //test to determine write 0 or 1
	streq	r3, [r1, #40]    //GPCLR0
	strne	r3, [r1, #28]    //GPSET0

	mov 	pc, lr    //return

Read_Data:

	ldr	r1, =0x20200000    // address for base GPIO
	ldr 	r2, [r1, #52]     // GPLEV0
	mov 	r3, #1    //creating bit for alignment
	lsl 	r3, #10   //align bit for pin#10
	and 	r2, r3    //mask eveything else
	teq 	r2, #0    //test
	moveq	r0, #0    //return 0 in r0
	movne	r0, #1    //return 1 in r0

	mov 	pc, lr    //return
.globl wait	
wait:       	// (r0 = parameter to check for waiting time)
	
	ldr 	r1, =0x20003004   //address of CLO
	ldr	r2, [r1]   //read CLO
	add	r2, r0     //add time to wait

	waitLoop:
		
		ldr	r3,[r1]  //read CLO
		cmp 	r2, r3   //stop when CLO = 1
		bhi	waitLoop 
	
	mov 	pc, lr   //return
.globl Read_SNES_raw
Read_SNES_raw:
	push	{r1-r12}
	mov 	r0, #1		// passing in 1 - write GPIO(CLOCK, #1)
	push	{lr}            // preserve state
	bl 	Write_Clock        
	pop	{lr}   //return state
	
	mov	r0, #1		// passing in 1 - write GPIO(LATCH, #1)
	push	{lr}  		//preserve state
	bl 	Write_Latch
	pop	{lr}   		//return state
	
	mov   	r0, #12       	// passing in 12 - (wait 12 microseconds / signal to SNES to sample buttons)
	push	{lr}  		//preserve state
	bl 	wait
	pop	{lr}   		//return state
	
	mov	r0, #0     	// passing in 0 - writeGPIO(LATCH, #0)
	push	{lr}  		//preserve state
	bl 	Write_Latch
	pop	{lr}   		//return state
	
	mov 	r4, #1		//set i to 1
	
	pulseLoop:

		mov 	r0, #6  // passing in 6 to wait function (wait 6 microseconds)
		push	{lr} 	//preserve state
		bl 	wait
		pop	{lr}  	//return state
		
		mov 	r0, #0  // passing in 0 to write clock function - writeGPIO(CLOCK, #0)
		push	{lr} 	//preserve state
		bl 	Write_Clock
		pop	{lr}  	//return state
		
		push	{lr} 	//preserve state
		bl	Read_Data
		pop 	{lr}
		
		teq	r0, #0	//check if button pressed
		moveq	r0, r4
		popeq	{r1-r12}
		moveq	pc, lr
		
		mov 	r0, #1   // rising edge new cycle - writeGPIO(CLOCK, #1)
		push	{lr}	 //preserve state
		bl 	Write_Clock
		pop	{lr}  	 //return state

		add 	r4, #1	//i++
		
		cmp	r4, #16  //if (i < 16) branch pulse loop
		blt	pulseLoop
		
	mov	r4, #0	//i = 0
	mov	r0, r4
	pop	{r1-r12}	
	mov 	pc, lr   //return

/////////////////////////////
/////////SNES DRIVER/////////
/////////////////////////////
