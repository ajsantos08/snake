//Scott	Saunders
//	10163541
//	March 30,2016

//This file contains the snake-logic


snake_death:	//It runs into something
	//TODO
	b	snake_death
	
snake_consumeable:	//The snake eats something
	//TODO
	b	snake_consumeable

.macro	make_snake_data	x,	y:req,	o:req,	c:req,	t:req
	push	{r1,r6,lr}
	ldr		r0,	=\x	
	ldr		r1,	=\y
	orr		r0,	r1,	lsl	#8
	ldr		r1,	=\o
	orr		r0,	r1,	lsl	#16
	ldr		r1,	=\c
	orr		r0,	r1,	lsl	#18
	ldr		r1,	=\t
	orr		r0,	r1
	pop		{r1,r6,lr}
.endm

snake_init:
	push	{r0-r12,lr}
	data	.req	r5
	node	.req	r6
	addr	.req	r7

	bl	snake_nuke		//Removes any old snakes.
	
	
	d_ldr	addr,	snake_tail
						//X,Y ,R,	R,	T_TAIL
	make_snake_data		1,	1,	3,	3,	T_TAIL
	str		r0,		[addr]
//	bl	draw_snake_seg

	bl	snake_inc_head
	d_ldr		addr,	snake_head
	make_snake_data		2,	1,	3,	3,	T_BODY
	str		r0,		[addr]
//	bl	draw_snake_seg

    bl  snake_inc_head
    d_ldr       addr,   snake_head
    make_snake_data     3,  1,  3,  3,  T_BODY
    str     r0,     [addr]
	
    bl  snake_inc_head
    d_ldr       addr,   snake_head
    make_snake_data     4,  1,  3,  3,  T_BODY
    str     r0,     [addr]


	bl	snake_inc_head
	d_ldr		addr,	snake_head
	make_snake_data		5,	1,	3,	3,	T_HEAD
	str		r0,		[addr]
//	bl	draw_snake_seg

	bl	draw_snake

	pop		{r0-r12,lr}	
	.unreq	data
	.unreq	node
	.unreq	addr
	bx	lr


snake_action:
	data	.req	r5
	node	.req	r6
	addr	.req	r7
	push	{r1-r12,lr}
	bl		snes_read_adv			//Read the input one last time.
	
	snes_get_data	r0	

	tst		r0,	#SNES_B_St			//Check for Start button
	blne	pause_game

	d_ldr	addr,	snake_head			//Loads the snake pnt
	ldr		data,	[addr]				//Loads the data value of the head.
	and		r2,		data,		#O_MASK			//Bitmask for Orientation.

	//Note:		These return with a value in r1, and disable the others via setting r0 to zero (yes, two checks.)
	tst		r0,	#SNES_D_U
	blne		sa_up	
		
	tst		r0,	#SNES_D_D
	blne		sa_down

	tst		r0,	#SNES_D_L
	blne		sa_left

	tst		r0,	#SNES_D_R
	blne		sa_right

	b		sa_none						//No buttons, go strait

sa_skip:

	mov		r0,	r1
	bl		snake_move

	.unreq	data
	.unreq	node
	.unreq	addr
	pop		{r1-r12,lr}
	bx		lr


//Catch-all.
sa_none:
	cmp		r2,	#O_D
	beq		sa_down
	cmp		r2,	#O_U
	beq		sa_up
	cmp		r2,	#O_L
	beq		sa_left
	cmp		r2,	#O_R
	beq		sa_right
	b	 sa_none			//If it somehow doesn't branch, hang in this loop to debug.

sa_up:
	cmp		r2,	#O_D
	bxeq	lr	//return in hopes they had another button pressed
	mov		r0,	#0		//If accept remove the input
	mov		r1,	#O_U
	b		sa_skip	

sa_down:
	cmp		r2,	#O_U
	bxeq	lr	//return in hopes they had another button pressed
	mov		r0,	#0		//If accept remove the input
	mov		r1,	#O_D
	b		sa_skip	

sa_left:
	cmp		r2,	#O_R
	bxeq	lr	//return in hopes they had another button pressed
	mov		r0,	#0		//If accept remove the input
	mov		r1,	#O_L
	b		sa_skip	

sa_right:
	cmp		r2,	#O_L
	bxeq	lr	//return in hopes they had another button pressed
	mov		r0,	#0		//If accept remove the input
	mov		r1,	#O_R
	b		sa_skip	




X_MASK		=	0x0000ff
Y_MASK		=	0x00ff00
O_MASK		=	0x030000
C_MASK		=	0x0c0000
T_MASK		=	0x700000		//Type mask:	0 = head,	1 = body, 2=tail
T_NONE		=	0x000000		//The non-type.
T_HEAD		=	0x100000
T_BODY		=	0x200000
T_TAIL		=	0x300000
T_A			=	0x400000		//Extra types
T_B			=	0x500000		//Extra types
T_C			=	0x600000
T_D			=	0x700000		//Extra types
O_U			=	0x00000		//Up
O_L			=	0x10000		//Left
O_D			=	0x20000		//Down
O_R			=	0x30000		//Right



//Note: It's a circular buffer!
.section	.data
.align 	4
snake_head:	.word	snake
snake_tail:	.word	snake
snake:
.rept	64		
.word		0
.endr	
snake_end:
				//Data		0-7: 	X
				//			8-15: 	Y
				//			16-17:	Orientation
				//			18-19:	Match-orientation (for corners)
				//			20-23:	Type
				//			25-32:	Misc

.section	.text
.align		4

snake_nuke:
nuke_snake:
	push	{r0-r4,lr}
	addr	.req	r4
	ldr		addr,	=snake				//Resets the pointers
	ldr		r3,	=snake_head
	str		addr,	[r3]
	ldr		r3,	=snake_tail
	str		addr,	[r3]

	mov		r1,	#64
	mov		r2,	#0

nuke_snake_loop:
	cmp		r1,	#0
	subne	r1,	#1
	strne	r2,	[addr],	#4
	bne		nuke_snake_loop

	.unreq	addr
	pop		{r0-r4,lr}
	bx	lr




.macro	snake_inc	type
snake_inc_\type:
	push	{r0-r4,lr}
	pnta	.req	r4
	addr	.req	r3
	
	ldr		pnta, =snake_\type
	ldr		addr,	[pnta]
	add		addr,	#4

	ldr		r1,	=snake_end
	cmp		addr,	r1
	ldrge	addr,	=snake			//If it goes past the end of the buffer, put it to the start.
	str		addr,	[pnta]

	.unreq	pnta				//Pain in the ass or  Pointer address?
	.unreq	addr
	pop		{r0-r4,lr}
	bx		lr
.endm


.macro  snake_dec   type
snake_dec_\type:
    push    {r0-r4,lr}
    pnta    .req    r4
    addr    .req    r3

    ldr     pnta, =snake_\type
    ldr     addr,   [pnta]
    sub   	addr,   #4

    ldr     r1, =snake_tail
    cmp     addr,   r1
    ldreq   addr,   =snake_end          //If it goes past the end of the buffer, put it to the start.
	subeq	addr,	#4					//Go back a byte from the end.
    str     addr,   [pnta]

    .unreq  pnta                //Pain in the ass or  Pointer address?
    .unreq  addr
    pop     {r0-r4,lr}
    bx      lr
.endm


snake_dec	head
snake_dec	tail
snake_inc	head
snake_inc	tail
