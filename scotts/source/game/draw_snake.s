//Scott	Saunders
//	10163541
//	March 30,2016

//This file contains the snake-logic

draw_snake:
	push	{r0-r4,lr}			//Simply iterates through the array, as there is a check in draw_snake_seg
	ldr		r4,	=snake
	ldr		r3,	=snake_end

draw_snake_l:
	ldr		r0,	[r4],	#4
	bl		draw_snake_seg

	cmp		r4,	r3
	ble		draw_snake_l

	pop		{r0-r4,lr}
	bx		lr


draw_snake_seg:		//Takes in a snake data-word
	push	{r1-r12,lr}
    head    .req    r5
    data    .req    r6

	mov		data,		r0

    and     r0,     data,       #X_MASK             
    and     r1,     data,       #Y_MASK
    and     r2,     data,       #O_MASK
	and		r3,		data,		#C_MASK
	and		r4,		data,		#T_MASK
	
	cmp		r4,		#0	//See if it actually exsists		//TYPE = 0 == dead
	beq			draw_snake_seg_exit

	lsl		r0,		#5		//Multiply it by 5 to get one of 32.
	lsr		r1,		#3		//Reduce it to a multiple of 32.
	
	lsr		r3,	r3,	#2	//Shift the r3 to be in the O mask range.
//	ldr		r3,		=snake_head_d
//	b		draw_snake_seg_end

	//Load the r3 required for the image to be drawn:
	cmp		r4,		#T_HEAD
	beq		draw_head
	cmp		r4,		#T_BODY
	beq		draw_body
	cmp		r4,		#T_TAIL
	beq		draw_tail

	nop		//Something bad has occured. Unknown type
	b		draw_snake_seg

draw_snake_seg_end:
	mov		r2,	r3
	bl	draw_ascii

draw_snake_seg_exit:
	.unreq	head
	.unreq	data
	pop		{r1-r12,lr}
	bx	lr

draw_head:
	cmp		r2,	#O_U
	ldreq	r3,	=snake_head_u
    cmp     r2, #O_D
    ldreq   r3, =snake_head_d
    cmp     r2, #O_L
    ldreq   r3, =snake_head_l
    cmp     r2, #O_R
    ldreq   r3, =snake_head_r
b	draw_snake_seg_end

draw_tail:
	cmp		r3,	#O_U
	ldreq		r3,	=snake_tail_u
    cmp     r3, #O_D
    ldreq     r3, =snake_tail_d
    cmp     r3, #O_L
    ldreq     r3, =snake_tail_l
    cmp     r3, #O_R
    ldreq     r3, =snake_tail_r
b	draw_snake_seg_end

draw_body:
    cmp     r2, #O_U
	beq			draw_body_u
    cmp     r2, #O_D
	beq			draw_body_d
    cmp     r2, #O_L
	beq			draw_body_l
    cmp     r2, #O_R
	beq			draw_body_r
b	draw_snake_seg_end


draw_body_d:
    cmp     r3, #O_D
    ldreq   r3,	=snake_body_d
    cmp     r3, #O_L
    ldreq   r3,	=snake_turn_dl
    cmp     r3, #O_R
    ldreq   r3,	=snake_turn_dr
b	draw_snake_seg_end

draw_body_u:
    cmp     r3, #O_U
    ldreq   r3,	=snake_body_u
    cmp     r3, #O_L
    ldreq   r3,  =snake_turn_ul
    cmp     r3, #O_R
    ldreq   r3,	=snake_turn_ur
b	draw_snake_seg_end

draw_body_l:
    cmp     r3, #O_L
    ldreq   r3,	=snake_body_l
    cmp     r3, #O_U
    ldreq   r3,	=snake_turn_ul
    cmp     r3, #O_D
    ldreq   r3, =snake_turn_dl
b	draw_snake_seg_end

draw_body_r:
    cmp     r3, #O_R
    ldreq   r3, =snake_body_r
    cmp     r3, #O_U
    ldreq   r3,	=snake_turn_ur
    cmp     r3, #O_D
    ldreq   r3, =snake_turn_dr
b	draw_snake_seg_end
