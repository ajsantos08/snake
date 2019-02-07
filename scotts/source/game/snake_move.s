//Scott	Saunders
//	10163541
//	March 30,2016


snake_move:	
	push	{r1-r12,lr}		
//Takes:	(O)
	head	.req	r5
	data	.req	r6
	addr	.req	r7	


	d_ldr	head,		snake_head		//Loads the pointer to the head 
	ldr		data,		[head]
	
	and		r1,		data,		#X_MASK				
	and		r2,		data,		#Y_MASK
	and		r3,		data,		#O_MASK
	lsl		r4,		r3,		#2			//Shifts the O_MASK to the C_MASK

	bic		data,	#O_MASK		//Sets the new 0_MASK
	orr		data,	r0
	
	cmp		r0,		#O_U
	subeq	r2,		#0x100

    cmp     r0,     #O_D
    addeq   r2,     #0x100

    cmp     r0,     #O_L
    subeq   r1,     #1

	cmp		r0,		#O_R
	addeq	r1,		#1		
	
	bic		data,	#X_MASK
	bic		data,	#Y_MASK

	and		r1,		#X_MASK
	and		r2,		#Y_MASK

	orr		data,	r1			//Or's the X and Y back in.
	orr		data,	r2			

	bic		data,	#T_MASK
	orr		data,	#T_HEAD
	
	mov		r0,		data

	bl		check_collide

	cmp		r0,		#1		//This is gonna hurt
	moveq	r0,		#-1	
	bleq	snake_move_end

	cmp		r0,		#3		//OM-NOMS
	//TODO

	//Else:
skipbug:
	
	bl		snake_inc_head			//Move the pointer of head up.

	d_ldr	r3,		snake_head			
	str		data,		[r3]			//Save it.


	mov		r0,		data				//Draws the head.
	bl	draw_snake_seg

	//Makes the old head a body:
	ldr		data,	[head]			//Re-loads the old head.
	bic		data,	data,	#C_MASK		//Loads the C-mask
	orr		data,	r4
	bic		data,	data,	#T_MASK			
	orr		data,	#T_BODY								//NOTE:		Could need to be a bend. (Is handled by drawer)
	str		data,		[head]			

	mov		r0,	data					//Draws the body
	bl	draw_snake_seg


	//Remove the tail:
	d_ldr	addr,	snake_tail
	ldr		data,	[addr]
	mov		r1,	#0
	str		r1,	[addr]				//Nukes the tail segment

	mov		r0,	data
	bl		draw_grass
/*
	and		r0,	data,	#X_MASK
	and		r1,	data,	#Y_MASK
	lsr		r1,	r1,	#3				//Remove the image (ie, draw grass ontop)
	lsl		r0,	r0,	#5
	ldr		r2,	=grass

	bl		draw_ascii				//Works
*/
	bl		snake_inc_tail
	
	//Make the last body-segment a tail
	d_ldr	head,	snake_tail
	ldr		data,	  [head]
	bic     data,     #T_MASK
    orr     data,     #T_TAIL
    str     data,     [head] 
	
	mov		r0,	data					//Draw the tail
	bl		draw_snake_seg				//Draw the tail
		

snake_move_end:
	.unreq	head
	.unreq	data
	.unreq	addr
	pop		{r1-r12,lr}
	bx		lr
