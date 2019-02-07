//Scott	Saunders
//	10163541
//	April	1



pause_game:
	push	{r0-r12,lr}
	ldr		r0,	=0
	ldr		r1,	=0
	ldr		r2,	=test

	bl		draw_ascii

	mov		r4,	#1	//initalize menu selector

pause_game_loop:
	bl	snes_read		//Returns to r0

    tst     r0, #SNES_D_U
    movne	r4,	#1				

    tst     r0, #SNES_D_D
    movne	r4,	#2

	tst		r0,	#SNES_B_St
	movne	r4,	#3
	bne		pause_game_end

	tst		r0,	#SNES_B_A
	bne		pause_game_end

pause_game_draw:

	ldr		r0,	=512
	ldr		r1,	=256

	cmp		r4,	#1
	ldreq	r2,	=snake_head_u
	bleq	draw_ascii

	cmp		r4,	#2
	ldreq	r2,	=snake_head_d
	bleq	draw_ascii


b	pause_game_loop

pause_game_end:
	cmp		r4,	#1
	beq		pause_game_end1
	
	cmp		r4,	#2	//Top
	beq		pause_game_end2

	cmp		r4,	#3	//Top
	beq		pause_game_end3

	pop     {r0-r12,lr}
	bx		lr

pause_game_end1:
	pop		{r0-r12,lr}
	bx	lr

pause_game_end2:
	pop		{r0-r12,lr}
	bx	lr

pause_game_end3:
	pop		{r0-r12,lr}
	bx	lr
