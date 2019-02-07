//Scott	Saunders
//	10163541
//	April	1


.macro	makemenu	 name:req, posx:req, posy:req, baseimg:req, imgtop:req, imgbot:req, offsetx:req, offsety:req, b_top:req, b_bot:req, b_start:req

\name:
	push	{r0-r12,lr}
	ldr		r0,	\posx
	ldr		r1,	\posy
	ldr		r2,	\baseimg

	bl		draw_ascii


loop_\name:
	bl	snes_read		//Returns to r0

    tst     r0, #SNES_D_U
    movne	r4,	#1				

    tst     r0, #SNES_D_D
    movene	r4,	#2

	tst		r0,	#SNES_B_St
	movene	r4,	#3
	bne		\name_end	

	tst		r0,	#SNES_B_A
	bne		\name_end

draw_\name:

	ldr		r0,	\offsetx
	ldr		r1,	\offsety

	cmp		r4,	#1
	ldreq	r2,	\imgtop

	cmp		r4,	#2
	ldreq	r2,	\imgbot

	bl		draw_ascii

b	loop_\name:

end_\name:
	
	cmp		r1,	#1	//Top
	ldr		pc,	\b_top

	cmp		r1,	#2
	ldr		pc, \b_bot

	cmp		r1,	#3
	ldr		pc,	\b_start

	pop		{r0,r12,lr}
	bx	lr
.endm


//			Name		X	Y	Img		topimg	botimg				,	Xoffset, Yoffset ,branch: top, down, start
makemenu	432 , =0 , =0  , =test , =snake_head_u , =snake_head_d , =512 , =256 , =demo , =halt , =lr ,	=32 ,	=32


