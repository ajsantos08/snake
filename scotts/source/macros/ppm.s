//Scott Saunders
//	10163541
//	March 30,	2016.


//	Makes and manages the reading of .ppm

.section	.text

//Note: this version is hard-coded for 32bpi

draw_img:
	//Takes (x,y) (for the top-left corner), and the address of the picture to draw.
	//Address is assumed to be the start of a .ppm image created by gimp (It has a comment in the header)
	push	{r3-r11,lr}
	xpos	.req	r5
	ypos	.req	r6
	picaddr	.req	r7
	picw	.req	r8
	pich	.req	r9
	picx	.req	r10
	picy	.req	r11

	mov		xpos,	r0
	mov		ypos,	r1
	mov		picaddr,	r2
	
	//Assumes the size of the .incbin is written in two words just before.
	ldr		picw,	[picaddr],	#4
	ldr		pich,	[picaddr],	#4	//Postfix addition

	add		picaddr,	#0x34

	//Note: THere was a string parser implemented to get width/hight, (see ppm.s.old)
		//But due to a apparent re-ordering of bytes, the string parser get messed up.
		//The picure data was odd initally, but is actually perfect after importing, so yay.
		//Maybe not.

//	b	draw_img_loop
//
//	d_ldr		r1,	fbuff_adr			//Loads the address
//	
//
///	ldr			r0,	[picaddr],	#4		//Loads a pixle
//	str			r0,	[r1],	#4
//	ldr			r0,	[picaddr],	#4		//Loads a pixle
///	str			r0,	[r1],	#4
//	ldr			r0,	[picaddr],	#4		//Loads a pixle
//	str			r0,	[r1],	#4
//	ldr			r0,	[picaddr],	#4		//Loads a pixle
//	str			r0,	[r1],	#4
//	
//	b			draw_img_end
	
draw_img_loop:
	ldrb	r3,		[picaddr],	#1
	lsl		r2,		r2,		#2
	orr		r2,		r3
	ldrb	r3,		[picaddr],	#1
	lsl		r2,		r2,		#2
	orr		r2,		r3
	ldrb	r3,		[picaddr],	#1
	lsl		r2,		r2,		#2
	orr		r2,		r3
	ldrb	r3,		[picaddr],	#1
	lsl		r2,		r2,		#2
	orr		r2,		r3


	

	add		r0,		xpos,	picx
	add		r1,		ypos,	picy
	bl	fb_setpixle

	add		picx,	#1		//
	
	cmp		picx,	picw
	addhs	picy,	#1
	movhs	picx,	#0

	cmp		picy,	pich
	blo		draw_img_loop	//Unsined less

draw_img_end:
	.unreq	xpos
	.unreq	ypos
	.unreq	picaddr
	.unreq	picw
	.unreq	pich
	.unreq	picx
	.unreq	picy

	pop		{r3-r11,lr}
	bx		lr
.section	.text
	
	
	




