//Scott	Saunders
//	10163541
//	April 1,	2016

draw_all:
	push	{lr}
	bl	draw_all_grass
//	bl	draw_walls
//	bl	draw_misc
	bl	draw_snake
	
	pop		{lr}

	bx	lr

draw_all_grass:
	push	{r0-r8,lr}
	mov		r4,	#0	//X
	mov		r5,	#0	//Y

draw_grass_loop:

	lsl		r0,	r5,	#8
	orr		r0,	r4

	bl		draw_grass
	
	add		r4,	#1

	cmp		r4,	#32
	addgt	r5,	#1
	movgt	r4,	#0
	
	cmp		r5,	#24
	blt		draw_grass_loop
	
	pop		{r0-r8,lr}
	bx		lr


draw_grass:		//Takes a node with the X,Y format of the snake.
	push	{lr}
	mov		r3,	r0
    and     r0, r3,   #X_MASK
    and     r1, r3,   #Y_MASK
    lsr     r1, r1, #3          
    lsl     r0, r0, #5
    ldr     r2, =grass

	bl		draw_ascii
	pop		{lr}
	bx	lr
