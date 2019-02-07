//Scott	Saunders
//	10163541
//	March 31, 2016

draw_ascii:
	//Takes in (x,y,addr)
    push     {r4-r12, lr}
	xpos	.req	r5
	ypos	.req	r6
	addr	.req	r7
	width	.req	r8
	hight	.req	r9
	picx	.req	r10
	picy	.req	r11

	mov		xpos,	r0
	mov		ypos,	r1
	mov		addr,	r2

	mov		picx,	#0
	mov		picy,	#0

    ldr     width, 	[addr],	#4		
    ldr     hight, 	[addr],	#4			//Load the first 2 bytes (width,hight)


draw_ascii_loop:
	ldrh	r2,		[addr],			#2
	add		r0,	xpos,	picx
	add		r1,	ypos,	picy

	bl		fb_setpixle
	
	add		picx,	#1

    cmp     picx,   width
    addhs   picy,   #1
    movhs   picx,   #0
	
	cmp     picy,  hight
	blo		draw_ascii_loop

	pop		{r4-r12, lr}
	.unreq	xpos
	.unreq	ypos
	.unreq	addr
	.unreq	width
	.unreq	hight
	.unreq	picx
	.unreq	picy
	bx		lr

