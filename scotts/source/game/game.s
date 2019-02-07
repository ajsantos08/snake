//Scott	Saunders
//	10163541
//	March 30,2016

//This file contains the main game-logic

game_init:

    bl  fb_reset_info
    bl  fb_initalize

	bl	init_xor_rand				//Initalize the random-number generator
	bl	snes_init

	bl	snake_init

	bl	draw_all
	
	//TODO:		Initalize walls
	//TODO:		Initalize apple
	//TODO:		Render the above

game_loop:
	ldr	r0,	=300000
	bl	game_wait
	bl	snake_action

//	b	halt
	b	game_loop

game_wait:							//Same as the block_timer wait, except it probes for input as it waits.
									//Takes in r0, the delay to wait.
	push    {r1,r2,lr}
	d_ldr   r1, TIMER_LOW 
	add     r0, r1

game_wait_l:
	bl		snes_read_adv
	d_ldr   r1, TIMER_LOW
	cmp     r0, r1
	bgt		game_wait_l	

    pop     {r1,r2,lr}
    bx      lr


check_collide:		//Takes in a data (r0)
	push	{r1-r10,lr}

	//Checks for Snake Collide

    ldr     r4, =snake
    ldr     r3, =snake_end

    and     r1, r0, #X_MASK
    and     r0, r0, #Y_MASK
	orr		r5,	r0,	r1

check_snake_l:
    ldr     r0, [r4],   #4
	and		r1,	r0,	#X_MASK
	and		r0,	r0,	#Y_MASK
	orr		r1,	r0
	
	cmp		r1,	r5	
	moveq	r0,	#1			//Hard collision
	beq		collide_end

    cmp     r4, r3
    ble     check_snake_l

	//Check for misc collision

    ldr     r4, =misc
    ldr     r3, =misc_end

check_misc_l:
    ldr     r0, [r4],   #4
	and		r1,	r0,	#X_MASK
	and		r0,	r0,	#Y_MASK
	orr		r1,	r0
	
	cmp		r1,	r5		
	ldreq	r0,	[r4],	#4			//Soft(?) Collision
	
	beq		collide_end

    cmp     r4, r3
    ble     check_snake_l

	///TODO:	Searches through each array to see if there is a collison on (x,y)
	///			Returns	1 for collision,	returns 3 for consumable,	returns 0 if free.
						///			3 for bitmasking purposes.


	//Searches through the misc  array	(Obsticals, Walls, Boarders.)


collide_end:
	pop		{r1-r10,lr}
	bx	lr


.section		.data
.align  4
misc:
.rept   	128
.word       0
.endr
misc_end:

COLID_MASK=	0x30000
.section	.text
.align	4
                //Data      0-7:    X
                //          8-15:   Y
                //          16-17:  soft/hard collid
                //          18-19:  
                //          20-23:  Type
                //          25-32:  Misc

nuke_misc:
    push    {r0-r4,lr}
    addr    .req    r4
    ldr     addr,   =misc              //Resets the pointers

    mov     r1, #128
    mov     r2, #0

nuke_misc_loop:
    cmp     r1, #0
    subne   r1, #1
    strne   r2, [addr], #4
    bne     nuke_misc_loop

    .unreq  addr
    pop     {r0-r4,lr}
    bx  lr
		
//Add's a data to the misc_add.
misc_add:
	push    {r0-r4,lr}
    pnta    .req    r4
    data    .req    r3
	mov		data,	r0
	
    d_ldr   addr, =misc
    ldr     addr,   [pnta]

misc_add_search_loop:
    ldr     r0, [misc],   #4
    and     r1, r0, #COLID_MASK
	cmp		r1,	#0
	bne		misc_add_search_loop
		
	str		data,	[

    .unreq  pnta                //Pain in the ass or  Pointer address?
    .unreq  addr
    pop     {r0-r4,lr}
    bx      lr

misc_del:

