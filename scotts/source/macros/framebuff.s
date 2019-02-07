//Scott Saunders
// 	10163541
//	March 23.	2015


.section .text


//Initalizes the frame buffer
fb_initalize:
	push	{r1-r5,lr}
	
	d_ldr	r1,	fbuff_adr
	cmp		r1,	#0
	bne		fb_init_end


	ldr		r0, =framebuffer_info			//Load framebuff adr
	add		r0,	#0x40000000					//Disable GPU cache
	mov		r1,	#1							//Channel 1

	bl	MailboxWrite
	mov		r0,	#1
	bl	MailboxRead
	teq		r0,	#0
	
	movne	r0,	#-1
	popne	{r1-r5,pc}				//Return on error
	
fb_init_wait:
	d_ldr	r0,	fbuff_adr
	cmp		r0,	#0
	beq		fb_init_wait


fb_init_end:
	pop		{r1-r5,lr}
	bx lr
	
	b halt
	b halt
	b halt






//	Bounds checker: (X,Y)
//Checks it is in bounds of framebuffer (x,y)
//Returns 1 if in range
fb_boundck:

	push	{r2-r4,lr}

	mov		r3,	r0					//Copy the X to r3
	mov		r0,	#1					//Set the output to return true

	d_ldr		r4,	fbuff_vwd		//Loads the fbuff_width into r3.
	sub			r4,	#1
	cmp			r3,	r4
	movhi		r0,	#0				//Set output false if Addr is out of range on X
	
	d_ldr		r4,	fbuff_vhi		//Loads the fbuff_height
	sub			r4,	#1
	cmp			r1,	r4		
	movhi		r0,	#0				//Set output false

	pop		{r2-r4,lr}
	bx		lr



//Calculate the pixle address.
//16-bit dpi
.macro fb_getpixleaddr	tmp,	x:req, y:req
 //Calculates the pixel address (No bounds checking)
	push	{\y}
	d_ldr	\tmp,	fbuff_vwd			//Loads the value in fbuff_wid
	mul		\tmp,		\y		
	add		\tmp,		\x				//tmp = y*width + x
										
//	d_ldr	\y,		fbuff_dep			//Multiply the above with the bit-depth.
//	mul		\tmp,	\y					//This is wrong. Not sure what would be correct.
	
	lsl		\tmp,		#1				//Each address is half-word	16bpi
//	lsl		\tmp,		#2				//Each address is a word.	32bpi

	d_ldr	\y,		fbuff_adr		//Gets address offset
	add		\tmp,		\y			
	pop		{\y}					//Puts the Y back as it was

.endm

//TODO: Set_Pixel(X,Y,color)

fb_setpixle:

	addr		.req	r1
	color		.req	r2
	x 			.req 	r3
	y			.req	r4
	baddr		.req	r5	
	Bitd		.req	r6
	Bitm		.req	r7
	
	
	push	{r1-r10,lr}

	mov		x,	r0			//Moves the input x to reg x
	mov		y,	r1			//Moves the input y to reg y
	
	bl	fb_boundck			//Checks bounds of the pixle
	cmp		r0,	#0			//Checks if it is in bound.
	moveq	r0,	#-1			//An error returned
	beq		fb_setpixle_end	//Skip to end on error

	fb_getpixleaddr		addr,	x,	y,

	strh		color,	[addr]	//16bpi
//	str		color,	[addr]			//32bpi

//	mov		baddr,	#0b1111
//	bic 	baddr,	addr,	baddr 			//As each 32-byte is within a single word, which are 4 byte aligned

//	d_ldr	Bitd	fbuff_dep			//Loads the framebuffer depth
//	bitmask_gen_q	Bitm,	Bitd		//Generate a bitmask of the length of the framebuffer's pixel.
	
//	tmp1		.req	r8
//	tmp2		.req	r9

//	sub		tmp1,	addr,	baddr			//blanks to left
//	sub		tmp1,	Bitd					//Taking in account of the size of the mask
//	rsb		tmp2,	tmp1,		#32				//blank to right
	


//	lsl		Bitm,	tmp2					//Shift to the left as needed.

//	lsl		color,	tmp1					//Sanitize the input
//	lsr		color,	tmp2					//Put it back to where it was.

//	ldr		r10,	[baddr]
//	bic		r10,	Bitm
//	orr		r10,	color
//	str		r10,	[baddr]


	//Normal Exit: Put the address back to X:
	mov		r0,		x


fb_setpixle_end:
	.unreq 		x 
	.unreq		y
	.unreq 		color 
	.unreq 		addr
	.unreq		baddr
	.unreq		Bitd
	.unreq		Bitm
//	.unreq		tmp1
//	.unreq		tmp2
	pop		{r1-r10,lr}	//Returns

	bx		lr

fb_drawchar:	//(x,y,color,bgcolor,char)
	push	{r0-r12,lr}

	x		.req	r5
	y		.req	r6
	color	.req	r7
	data	.req	r8
	caddr	.req	r9
	row		.req	r10
	col		.req	r11
	mask	.req	r12
	bgcolor	.req	r4

	mov		x,	r0
	mov		y,	r1
	mov		color,	r2


	ldr		caddr,	=font
	add		caddr,	caddr,	r4,	lsl #4	// char address = font base + (char * 16)

	mov		bgcolor,	r3		//Sets bg_color after the address calculated

	mov		row,	#0

fb_drawchar_loop:

	mov		mask,		#1		//shifting mask	
	mov		col,		#0
	ldrb	data,	[caddr,	row]	//

	//Note:	Mask propigates from left to right, and hence so dose reading pixles
	//		Also note: Drawing them goes from right to left.

fb_drawchar_rowloop:
	tst		data,	mask
//	beq		fb_drawchar_rowskip
	moveq	r2,		bgcolor
	movne	r2,		color

		//Draw Pixle
	add		r1,	x,	row
	add		r0,	y,	col

	bl		fb_setpixle

fb_drawchar_rowskip:


	lsl		mask,	#1
	add		col,	#1

	cmp		col,	#8
	blt		fb_drawchar_rowloop				//Draws all of the row
		
	add		row,	#1
	cmp		row,	#16						//Does the next row.
	ble		fb_drawchar_loop

	.unreq	x
	.unreq	y
	.unreq	color
	.unreq	data
	.unreq	caddr
	.unreq	row
	.unreq	col
	.unreq	mask
	.unreq	bgcolor
	pop		{r0-r12,lr}				//Note: Has no return value.
	bx	lr

fb_drawstring:				//(x,y,color,bgcolor,*str)
	push		{r0-r10,lr}
	color	.req	r6
	strpnt	.req	r7
	bgcolor	.req	r8
	x		.req	r9
	y		.req	r10

	mov		x,			r0
	mov		y,			r1
	mov		color,		r2
	mov		bgcolor, 	r3
	mov		strpnt,		r4

fb_drawstring_loop:
	ldrb	r5,		[strpnt],	#1		//Load first char
	cmp		r5,		#0		//Check if it is null.
	beq		fb_drawstring_end
	

	mov		r0,	y
	mov		r1,	x
	mov		r2,	color
	mov		r3,	bgcolor
	mov		r4,	r5

	bl		fb_drawchar

	add		x,	#8		//Move to the right 1 charector

	b		fb_drawstring_loop

fb_drawstring_end:
	.unreq	color
	.unreq	strpnt
	.unreq	bgcolor
	.unreq	x
	.unreq	y
	pop			{r0-r10,lr}
	bx		lr


fb_reset_info:
	push		{r0-r5,lr}

	ldr		r0,		=framebuffer_info

.macro	setfbvalue	val
	ldr		r1,		=\val
	str		r1,	[r0]
	add		r0,	#4
.endm

	setfbvalue	1024	//Width
	setfbvalue	768		//Hight
//	setfbvalue	1024	//virtual Width
//	setfbvalue	768		//Virtual Hight
//	setfbvalue	32//128		//Width
//	setfbvalue	32//95		//Hight
	setfbvalue	1024	//virtual Width
	setfbvalue	768		//Virtual Hight
	add	r0, #4			//Skip pitch
	
	setfbvalue	16		//Depth
						//Skip the rest.

	pop			{r0-r5,pc}




.data
.align	4
framebuffer_info:
fbuff_wid:	.word			1024		//Width:  /0x00
fbuff_hig:	.word			768			//Height: /0x04
fbuff_vwd:	.word			1024		//V_width: //0x08 
fbuff_vhi:	.word			768			//V_Height: /0x0c
fbuff_pit:	.word			0			//Pitch: (setup by gpu) /0x10
fbuff_dep:	.word			16			//Depth:	(Bits per pixle) \0x14
fbuff_xof:	.word			0			//X Offset	\0x18	//for the real <-> virt.	
fbuff_yof:	.word			0			//Y Offset  \0x1c	//For the real <-> virt.
fbuff_adr:	.word			0			//Pointer to framebuff, set by gpu   \0x20
fbuff_siz:	.word			0			//Size			\0x24

.text
.align 4
