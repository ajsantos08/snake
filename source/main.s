_start:	

	b InstallIntTable


    
.section .text
.globl	main

main:

	
	bl	EnableJTAG
	
	bl	InitFrameBuffer
	
	bl	InitializeGPIO

drawMainStart:

	ldr	r0, =mainMenuStart
	bl	DrawFullPic
	bl	del_snes

	readMainLoop:
	
		bl		Read_SNES
		teq		r0, #9
		beq		startGame
		teq		r0, #6
		beq		drawMainEnd
		b		readMainLoop		
	
drawMainEnd:
	
	ldr	r0, =mainMenuEnd
	bl	DrawFullPic
	bl	del_snes

	readMainEndLoop:
	
		bl		Read_SNES
		teq		r0, #9		
		beq		doneBlack
		teq		r0, #5
		beq		drawMainStart
		b		readMainEndLoop

startGame:
	
	mov	r6, #0
	mov	r7, #20
	mov	r8, #0		//exit flag
	mov	r9, #0 		//win flag
	mov	r10, #0
	bl	DrawHeader

	

initSnake:	
	
	

	bl	ClearBerry
	bl	del_snes
	bl	del_ioff
	mov	r11, #1
	mov	r4, #2
	mov 	r5, #8
	bl	InitializeSnake
	bl	InitializeBerry
	
.globl drawMap
drawMap:
	
	bl	DrawMap
	bl	DrawScore	
	bl	DrawSnake

	teq	r8, #1
	beq	endLoop
		
	gameLoop:
		
		teq	r6, #20
		moveq	r8, #1
		beq	endLoop
		bl	DrawEgg
		bl	DrawBigBerry
		bl	Read_SNES
		teq	r0, #4
		bleq	save_timer
		beq	gameStartMenuRestart
		bl	UpdateDirection
		bl	CollisionCheck
		teq	r0, #1
		subeq	r7, #1
		cmp	r7, #0			
		blt	reset
		teq	r0, #1	
		beq	initSnake
		bl	CheckEgg
		teq	r0, #1
		addeq	r4, #1
		addeq	r6, #1
		addeq	r10, #1
		bleq	UpdateEgg
		bleq	AddSnake
		bl	CheckBerry
		teq	r0, #1
		addeq	r10, #1
		moveq	r11, #0
		bleq	ClearBerry
		blne	UpdateSnake
		
		bl	DrawScore
		bl	DrawLives
		bl	DrawSnake
			
		bl	GetSpeed
		bl	gamewait

		b	gameLoop


	endLoop:
		
		bl	DrawExit
		bl	Read_SNES
		teq	r0, #4
		beq	gameStartMenuRestart
		bl	UpdateDirection
		bl	CollisionCheck
		teq	r0, #1
		subeq	r7, #1
		cmp	r7, #0			
		blt	reset
		teq	r0, #1	
		beq	initSnake
		bl	CheckEgg
		teq	r0, #1
		moveq	r9, #1
		beq	reset
		bleq	AddSnake	
		blne	UpdateSnake
		bl	DrawScore
		bl	DrawLives
		bl	DrawSnake
		
		bl	GetSpeed
		bl	gamewait
		
		b	endLoop

		
reset:

	teq	r9, #0
	ldreq	r0, =gameOverLose
	teq	r9, #1
	ldreq	r0, =gameOverWin
	bl	DrawFullPic
	bl	Read_SNES_raw
	teq	r0, #0
	bne	drawMainStart
	b	reset

gameStartMenuRestart:
		
	ldr		r0, =startMenuRestart
	bl		DrawPic
	bl	del_snes

	gameStartRestartLoop:
	
		bl		Read_SNES_raw
		teq		r0, #9
		beq		startGame
		teq		r0, #6
		beq		gameStartMenuQuit
		teq		r0, #4
		bleq		restore_timer
		
		ldr		r0, =100000
		bl		wait
		b		gameStartRestartLoop
		
				
	
gameStartMenuQuit:
	
	ldr		r0, =startMenuQuit
	bl		DrawPic
	bl	del_snes

	gameStartEndLoop:
	
		bl		Read_SNES_raw
		teq		r0, #9
		beq		drawMainStart
		teq		r0, #5
		beq		gameStartMenuRestart
		teq		r0, #4
		bleq		restore_timer
		beq		drawMap
		ldr		r0, =100000
		bl		wait
		b		gameStartEndLoop

gameOverStartMenuRestart:
	
	ldr		r0, =startMenuRestart
	bl		DrawPic
	bl	del_snes

	gameOverStartRestartLoop:
	
		bl		Read_SNES_raw
		teq		r0, #9
		beq		startGame
		teq		r0, #6
		beq		gameOverStartMenuQuit
		teq		r0, #4
		beq		reset
		ldr		r0, =100000
		bl		wait
		b		gameOverStartRestartLoop
		
				
	
gameOverStartMenuQuit:
		
	ldr		r0, =startMenuQuit
	bl		DrawPic
	bl	del_snes
	
	gameOverStartQuitLoop:
	
		bl		Read_SNES_raw
		teq		r0, #9
		beq		drawMainStart
		teq		r0, #5
		beq		gameOverStartMenuRestart
		teq		r0, #4
		beq		reset
		ldr		r0, =100000
		bl		wait
		b		gameOverStartQuitLoop

doneBlack:
	
	ldr	r0, =0x0
	bl	DrawFullSolid
.globl haltLoop$
haltLoop$:
	b		haltLoop$



///////////////////////////////////
///////////////DRAW////////////////
///////////////////////////////////

DrawFullPic:
	
	push		{r1-r6}
	mov 		r4, r0		//pic in ascii address
	mov		r3, #0		//address offset
	mov 		r0, #0		//starting x
	mov 		r1, #0
	ldr		r5, =1024
	ldr		r6, =768
	
	yFullPicLoop:
	
		xFullPicLoop:
			
			ldrh		r2, [r4, r3]
			push 		{r0-r3,lr}
			
			bl		DrawPixel

			pop		{r0-r3, lr}
			
			add		r3, #2
		
			add		r0, #1
			cmp 		r0, r5
			blt		xFullPicLoop

	mov 		r0, #0 		//restarting x
	add 		r1, #1		//increment y
	cmp 		r1, r6
	blt		yFullPicLoop
	pop		{r1-r6}
	bx		lr

DrawPic:
	
	push		{r1-r6}
	mov 		r4, r0		//pic in ascii address
	mov		r3, #0		//address offset
	mov 		r0, #224		//starting x
	mov 		r1, #224
	ldr		r5, =800
	ldr		r6, =609
	
	yPicLoop:
	
		xPicLoop:
			
			ldrh		r2, [r4, r3]
			push 		{r0-r3,lr}
			
			bl		DrawPixel

			pop		{r0-r3, lr}
			
			add		r3, #2
		
			add		r0, #1
			cmp 		r0, r5
			blt		xPicLoop

	mov 		r0, #224 		//restarting x
	add 		r1, #1		//increment y
	cmp 		r1, r6
	blt		yPicLoop
	pop		{r1-r6}
	bx		lr

DrawHeader:
	
	push		{r1-r6}
	ldr 		r4, =Header		//pic in ascii address
	mov		r3, #0		//address offset
	mov 		r0, #0		//starting x
	mov 		r1, #0
	ldr		r5, =1024
	ldr		r6, =65
	
	yHeaderLoop:
	
		xHeaderLoop:
			
			ldrh		r2, [r4, r3]
			push 		{r0-r3,lr}
			
			bl		DrawPixel

			pop		{r0-r3, lr}
			
			add		r3, #2
		
			add		r0, #1
			cmp 		r0, r5
			blt		xHeaderLoop

	mov 		r0, #0		//restarting x
	add 		r1, #1		//increment y
	cmp 		r1, r6
	blt		yHeaderLoop
	pop		{r1-r6}
	bx		lr

DrawScore:
	
	push		{r0-r12}
	mov	r0, #7
	mov	r1, #0
	ldr	r3, =numbersHeader
	lsl	r9, r10, #2
	ldr	r2, [r3, r9]
	push	{lr}
	bl	DrawCell
	pop	{lr}
	
	pop		{r0-r12}
	
	bx 	lr

DrawLives:
	
	push	{r0-r12}
	mov	r0, #27
	mov	r1, #0
	ldr	r3, =numbersHeader
	lsl	r9, r7, #2
	ldr	r2, [r3, r9]
	push	{lr}
	bl	DrawCell
	pop	{lr}
	
	pop	{r0-r12}
	
	bx 	lr
	

DrawFullSolid:
	
	push		{r1-r6}
	mov 		r2, r0		//pic in ascii address
	mov 		r0, #0		//starting x
	mov 		r1, #0
	ldr		r3, =1024
	ldr		r4, =768
	
	ySolidLoop:
	
		xSolidLoop:
			
			push 		{r0-r3,lr}
			
			bl		DrawPixel

			pop		{r0-r3, lr}
			
		
			add		r0, #1
			cmp 		r0, r3
			blt		xSolidLoop

	mov 		r0, #0 		//restarting x
	add 		r1, #1		//increment y
	cmp 		r1, r4
	blt		ySolidLoop
	pop		{r1-r6}
	bx		lr
DrawCell:
	
	push		{r0-r7}
	mov 		r4, r2		//pic in ascii address
	mov		r3, #0		//address offset
	mov		r5, #32
	mul		r0, r5
	mul		r1, r5
	add		r6, r0, r5
	add		r7, r1, r5

	yCellLoop:
	
		xCellLoop:
			
			ldrh		r2, [r4, r3]
			push 		{r0-r3,lr}
			
			bl		DrawPixel

			pop		{r0-r3, lr}
			
			add		r3, #2
		
			add		r0, #1
			cmp 		r0, r6
			blt		xCellLoop

	sub		r0, r6, r5	//restarting x	
	add 		r1, #1		//increment y
	cmp 		r1, r7
	blt		yCellLoop
	pop		{r0-r7}
	bx		lr

DrawMap:
	push	{r0-r12}
	
	drawBorder:
		
		mov 		r0, #1
		mov		r1, #2

		topLoop:
			ldr		r2, =wallDown
			push		{r0-r12, lr}
			bl		DrawCell
			pop		{r0-r12,lr}
			add		r0, #1
			cmp		r0, #31
			blt		topLoop

			mov 		r0, #1
			mov		r1, #23
	
		bottomLoop:
			ldr		r2, =wallUp
			push		{r0-r12,lr}
			bl		DrawCell
			pop		{r0-r12,lr}
			add		r0, #1
			cmp		r0, #31
			blt		bottomLoop

			mov 		r0, #0
			mov		r1, #3

		leftLoop:
			ldr		r2, =wallRight
			push		{r0-r12,lr}
			bl		DrawCell
			pop		{r0-r12,lr}
			add		r1, #1
			cmp		r1, #24
			blt		leftLoop
	
			mov 		r0, #31
			mov		r1, #3
	

		rightLoop:

			ldr		r2, =wallLeft
			push		{r0-r12,lr}
			bl		DrawCell
			pop		{r0-r12,lr}
			add		r1, #1
			cmp		r1, #24
			blt		rightLoop

			mov 		r0, #0
			mov		r1, #2
			ldr		r2, =cornerTopLeft
			push		{r0-r12,lr}
			bl		DrawCell
			pop		{r0-r12,lr}
			mov 		r0, #31
			mov		r1, #2
			ldr		r2, =cornerTopRight
			push		{r0-r12,lr}
			bl		DrawCell
			pop		{r0-r12,lr}
			mov 		r0, #0
			mov		r1, #23
			ldr		r2, =cornerBottomLeft
			push			{r0-r12,lr}			
			bl		DrawCell
			pop		{r0-r12,lr}
			mov 		r0, #23
			mov		r1, #31
			ldr		r2, =cornerBottomRight
			push		{r0-r12,lr}
			bl		DrawCell
			pop		{r0-r12,lr}

		mov 		r0, #1
		mov		r1, #3
	
	drawFloor:
		
		floorYLoop:
	
			floorXLoop:
				
				ldr		r2, =Floor
				push		{r0-r12,lr}
				bl		DrawCell
				pop		{r0-r12,lr}				
				add		r0, #1
				cmp		r0, #31
				blt		floorXLoop
	
			mov	r0, #1
			add	r1, #1
			cmp	r1, #23
			blt	floorYLoop
	
	ldr	r10, =blockX
	ldr	r11, =blockY
	mov	r12, #0
	
	drawBoulder:
		
		ldr	r0, [r10], #4
		ldr	r1, [r11], #4
		
		ldr		r2, =Boulder
		push		{r0-r12,lr}
		bl		DrawCell
		pop		{r0-r12,lr}
		add		r12, #1
		teq		r12, #35
		bne		drawBoulder	

	pop	{r0-r12}
	bx 	lr

DrawSnake:
	
	push	{r0-r12}	
	ldr	r7, =snakeBodyX
	ldr	r8, =snakeBodyY
	
	BodyLoop:	
	
	teq	r4, #0
	beq	DrawHead
	
	lsl	r6, r4, #2
	
	ldr	r0,[r7, r6]
	ldr	r1,[r8, r6]
	push	{lr}
	bl	DrawSnakeBody
	pop	{lr}
	sub	r4, #1
	b	BodyLoop

	DrawHead:
	
	lsl	r6, r4, #2
	
	ldr	r0,[r7, r6]
	ldr	r1,[r8, r6]

	push	{lr}
	bl 	DrawSnakeHead
	pop	{lr}
	
	pop	{r0-r12}
	
	bx 	lr

DrawSnakeBody:
	
	push		{r0-r7}
	ldr		r4, =snakeBox	//pic in ascii address
	mov		r3, #0		//address offset
	mov		r5, #32
	mul		r0, r5
	mul		r1, r5
	add		r6, r0, r5
	add		r7, r1, r5

	yBodyLoop:
	
		xBodyLoop:
			
			ldrh		r2, [r4, r3]
			
			push 		{r0-r3, lr}
			
			bl		DrawPixel

			pop		{r0-r3, lr}
			
			add		r3, #2
			
			add		r0, #1
			cmp 		r0, r6
			blt		xBodyLoop

	sub		r0, r6, r5	//restarting x	
	add 		r1, #1		//increment y
	cmp 		r1, r7
	blt		yBodyLoop
	pop		{r0-r7}
	bx		lr

DrawSnakeHead:
	
	push		{r0-r7}
	teq		r5, #5
	ldreq		r4, =snakeHeadUp
	teq		r5, #6
	ldreq		r4, =snakeHeadDown
	teq		r5, #7
	ldreq		r4, =snakeHeadLeft
	teq		r5, #8
	ldreq		r4, =snakeHeadRight	//pic in ascii address
	mov		r3, #0		//address offset
	mov		r5, #32
	mul		r0, r5
	mul		r1, r5
	add		r6, r0, r5
	add		r7, r1, r5

	yHeadLoop:
	
		xHeadLoop:
			
			ldrh		r2, [r4, r3]
			
			push 		{r0-r3, lr}
			
			bl		DrawPixel

			pop		{r0-r3, lr}
			
			add		r3, #2
		
			add		r0, #1
			cmp 		r0, r6
			blt		xHeadLoop

	sub		r0, r6, r5	//restarting x	
	add 		r1, #1		//increment y
	cmp 		r1, r7
	blt		yHeadLoop
	pop		{r0-r7}
	bx		lr

DrawEgg:
	
	push	{r0-r12}
	
	ldr	r3, =eggXY
	ldr	r0, [r3]
	ldr	r1, [r3, #4]
	ldr	r2, =Egg

	push	{lr}
	bl	DrawCell
	pop	{lr}

	pop	{r0-r12}
	
	bx 	lr

DrawExit:
	
	push	{r0-r12}
	
	ldr	r3, =eggXY
	ldr	r0, [r3]
	ldr	r1, [r3, #4]
	ldr	r2, =Ladder
	
	push	{lr}
	bl	DrawCell
	pop	{lr}
	
	pop	{r0-r12}
	
	bx 	lr

DrawRareCandy:
	
	push	{r0-r12}	

	ldr	r3, =rareCandyXY
	ldr	r0, [r3]
	ldr	r1, [r3, #4]
	ldr	r2, =rareCandy
	
	push	{lr}
	bl	DrawCell
	pop	{lr}
	
	pop	{r0-r12}
	
	bx 	lr

DrawBigBerry:
	
	push	{r0-r12}
	
	ldr	r3, =bigBerryXY
	ldr	r0, [r3]
	ldr	r1, [r3, #4]

	ldr	r2, =bigBerry
	
	push	{lr}
	bl	DrawCell
	pop	{lr}
	
	pop	{r0-r12}
	
	bx 	lr



DrawPixel:
	
	push	{r4}

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop	{r4}
	bx	lr


///////////////////////////////////
///////////////DRAW////////////////
///////////////////////////////////


///////////////////////////////////
///////////////RANDOM//////////////
///////////////////////////////////

RandomX:
	
	push	{r1-r12}

	randomXStart:
	
		ldr 	r1, =0x20003004   //address of CLO
		ldr	r0, [r1]   //read CLO
	
		ldr	r1, =65535
		lsl	r1, #16
		bic	r0, r0, r1

		eor	r0, r0, r0, lsr #12	// x ^= x <<12
		eor	r0, r0, r0, lsl #25	// w ^= w <<25
		eor	r0, r0, r0, lsr #27 // w ^= w >>27
	
		ldr	r1, =65535
		lsl	r1, #16
		bic	r0, r0, r1
    
	subXLoop:
	
		sub 	r0, #30
	
		cmp	r0, #30
		bgt	subXLoop
		cmp 	r0, #1
		blt	randomXStart

	pop	{r1-r12}

	bx 	lr

RandomY:
	
	push	{r1-r12}
	
	randomYStart:

		ldr 	r1, =0x20003004   //address of CLO
		ldr	r0, [r1]   //read CLO
	
		ldr	r1, =65535
		lsl	r1, #16
		bic	r0, r0, r1

		eor	r0, r0, r0, lsr #12	// x ^= x <<12
		eor	r0, r0, r0, lsl #25	// w ^= w <<25
		eor	r0, r0, r0, lsr #27 // w ^= w >>27
	
		ldr	r1, =65535
		lsl	r1, #16
		bic	r0, r0, r1
	    
	subYLoop:
	
		sub 	r0, #22
	
		cmp	r0, #22
		bgt	subYLoop
		cmp 	r0, #2
		blt	randomYStart

	pop	{r1-r12}

	bx 	lr

///////////////////////////////////
///////////////RANDOM//////////////
///////////////////////////////////


///////////////////////////////////
/////////UPDATE/ACCESS DATA////////
///////////////////////////////////

UpdateSnake:
	
	push	{r0-r12}	
	
	ldr	r7, =snakeBodyX
	ldr	r8, =snakeBodyY

	lsl	r6, r4, #2

	ldr	r0,[r7, r6]
	ldr	r1,[r8, r6]

	ldr	r2, =Floor
	push	{lr}
	bl	DrawCell
	pop	{lr}
	
	sub	r4, #1	
	
	UpdateBodyLoop:	

		lsl	r9, r4, #2
	
		ldr	r0,[r7, r9]
		ldr	r1,[r8, r9]
	
		str	r0,[r7, r6]
		str	r1,[r8, r6]
	
		teq	r4, #0
		beq	UpdateHead
		mov	r6, r9
	
		sub	r4, #1
		b	UpdateBodyLoop

	UpdateHead:
	
		ldr	r0,[r7]
		ldr	r1,[r8]
		teq	r5, #5
		subeq	r1, #1		
		teq	r5, #6
		addeq	r1, #1
		teq	r5, #7
		subeq	r0, #1	
		teq	r5, #8
		addeq	r0, #1
	
		str	r0,[r7]
		str	r1,[r8]

	pop	{r0-r12}
	
	bx 	lr

AddSnake:
	
	push	{r0-r12}	
	
	ldr	r7, =snakeBodyX
	ldr	r8, =snakeBodyY

	lsl	r6, r4, #2

	sub	r4, #1	
	
	AddBodyLoop:	

		lsl	r9, r4, #2
	
		ldr	r0,[r7, r9]
		ldr	r1,[r8, r9]
	
		str	r0,[r7, r6]
		str	r1,[r8, r6]
	
		teq	r4, #0
		beq	AddHead
		mov	r6, r9
	
		sub	r4, #1
		b	AddBodyLoop

	AddHead:
	
		ldr	r0,[r7]
		ldr	r1,[r8]
		teq	r5, #5
		subeq	r1, #1		
		teq	r5, #6
		addeq	r1, #1
		teq	r5, #7
		subeq	r0, #1	
		teq	r5, #8
		addeq	r0, #1
	
		str	r0,[r7]
		str	r1,[r8]

	pop	{r0-r12}
	
	bx 	lr


UpdateDirection:

	push	{r1-r4,r6-r12}
	teq	r5, r0
	beq	doneUpdate
	teq	r0, #5
	beq	upCheck
	teq	r0, #6
	beq	downCheck
	teq	r0, #7
	beq	leftCheck
	teq	r0, #8
	beq	rightCheck


doneUpdate:
	
	pop	{r1-r4,r6-r12}
	bx 	lr

	upCheck:
			teq	r5, #6
			beq	doneUpdate
			mov	r5, r0
			b	doneUpdate
	downCheck:
			teq	r5, #5
			beq	doneUpdate
			mov	r5, r0
			b	doneUpdate

	leftCheck:
			teq	r5, #8
			beq	doneUpdate
			mov	r5, r0
			b	doneUpdate
	rightCheck:
			teq	r5, #7
			beq	doneUpdate
			mov	r5, r0
			b	doneUpdate

UpdateEgg:

	push	{r0-r12}

	ldr	r3, =eggXY
		
	randomEggStart:
	
		push	{lr}
		bl	RandomX
		pop	{lr}
	
	
		str	r0, [r3]

		push	{lr}
		bl	RandomY
		pop	{lr}
	
		str	r0, [r3, #4]

		ldr	r0, [r3]
		ldr	r1, [r3, #4]
		push	{lr}
		bl	SpawnCheck
		pop	{lr}
		teq	r0, #1
		beq	randomEggStart
	
	pop	{r0-r12}
	
	bx 	lr

.globl UpdateRare

UpdateRare:

	push	{r0-r12}

	ldr	r3, =rareCandyXY
		
	randomRareStart:
	
		push	{lr}
		bl	RandomX
		pop	{lr}
	
	
		str	r0, [r3]

		push	{lr}
		bl	RandomY
		pop	{lr}
	
		str	r0, [r3, #4]

		ldr	r0, [r3]
		ldr	r1, [r3, #4]
		push	{lr}
		bl	SpawnCheck
		pop	{lr}
		teq	r0, #1
		beq	randomRareStart
	
	pop	{r0-r12}
	
	bx 	lr

.globl UpdateBerry

UpdateBerry:

	push	{r0-r12}

	ldr	r3, =bigBerryXY
		
	randomBerryStart:
	
		push	{lr}
		bl	RandomX
		pop	{lr}
	
	
		str	r0, [r3]

		push	{lr}
		bl	RandomY
		pop	{lr}
	
		str	r0, [r3, #4]

		ldr	r0, [r3]
		ldr	r1, [r3, #4]
		push	{lr}
		bl	SpawnCheck
		pop	{lr}
		teq	r0, #1
		beq	randomBerryStart
	
	pop	{r0-r12}
	
	bx 	lr

ClearRare:

	push	{r0-r12,lr}

	ldr	r3, =rareCandyXY
	
	mov 	r0, #-1
	str	r0, [r3]
	
	mov	r0, #-1	
	str	r0, [r3, #4]
	
	ldr	r0, =3000000		//Again!
	bl	set_timer_1

	pop	{r0-r12,lr}
	
	bx 	lr

ClearBerry:

	push	{r0-r12,lr}

	ldr	r3, =bigBerryXY
	
	mov 	r0, #-1
	str	r0, [r3]
	
	mov	r0, #-1	
	str	r0, [r3, #4]
	
	ldr	r0, =3000000		//Again!
	bl	set_timer_1

	pop	{r0-r12,lr}
	
	bx 	lr

GetSpeed:
	
	push	{r1-r12}
	ldr	r1, =speed
	lsl	r11, #2
	ldr	r0, [r1, r11]
	pop	{r1-r12}
	
	bx 	lr

///////////////////////////////////
/////////UPDATE/ACCESS DATA////////
///////////////////////////////////


///////////////////////////////////
//////////////CHECK////////////////
///////////////////////////////////

CollisionCheck:
	
	push	{r1-r12}
	mov	r0, #0	
	mov	r6, #0	
	ldr 	r7, =snakeBodyX
	ldr 	r8, =snakeBodyY
	ldr	r9, =blockX
	ldr	r10,=blockY	
	ldr	r0, [r7], #4
	ldr	r1, [r8], #4
	
	
	hitBoulderLoop:
	
		teq	r6, #35
		beq	hitBody
		ldr	r2, [r9], #4
		ldr	r3, [r10], #4
		
		teq	r0, r2
		beq	matchBoulderY
		add 	r6, #1
		b 	hitBoulderLoop
	
		matchBoulderY:
		
			teq	r1, r3
			beq 	collisionTrue
			add 	r6, #1
			b 	hitBoulderLoop

	hitBody:
	
	mov	r6, #0	
	add	r4, #1
	
	hitBodyLoop:
	
		teq	r6, r4
		beq	checkBounds
		ldr	r2, [r7], #4
		ldr	r3, [r8], #4
	
		teq	r0, r2
		beq	matchBodyY
		add 	r6, #1
		b 	hitBodyLoop
	
		matchBodyY:
		
			teq	r1, r3
			beq 	collisionTrue
			add 	r6, #1
			b 	hitBodyLoop

	checkBounds:
	
		teq	r0, #0
		beq	collisionTrue
		teq	r0, #31
		beq	collisionTrue
		teq	r1, #2
		beq	collisionTrue
		teq	r1, #23
		beq	collisionTrue
	
	mov 	r0, #0

doneCollision:
	
	pop	{r1-r12}
	bx	lr

	collisionTrue:
	
		mov	r0, #1
		b	doneCollision




CheckEgg:
	
	push	{r1-r12}
	
	ldr 	r7, =snakeBodyX
	ldr 	r8, =snakeBodyY
	ldr	r0, [r7]
	ldr	r1, [r8]
	
	ldr	r9, =eggXY
	ldr	r2,[r9]
	ldr	r3,[r9, #4]
			
	teq	r0, r2
	beq	checkEggY	
	mov	r0, #0
	b 	doneEgg
	
	checkEggY:
			teq	r1, r3
			moveq	r0, #1
			beq	doneEgg
			mov	r0, #0
doneEgg:
	
	pop	{r1-r12}
	bx 	lr


CheckBerry:
	
	push	{r1-r12}
	
	ldr 	r7, =snakeBodyX
	ldr 	r8, =snakeBodyY
	ldr	r0, [r7]
	ldr	r1, [r8]
	
	ldr	r9, =bigBerryXY
	ldr	r2,[r9]
	ldr	r3,[r9, #4]
			
	teq	r0, r2
	beq	checkBerryY	
	mov	r0, #0
	b 	doneBerry
	
	checkBerryY:
			teq	r1, r3
			moveq	r0, #1
			beq	doneBerry
			mov	r0, #0
doneBerry:
	
	pop	{r1-r12}
	bx 	lr


CheckRare:
	
	push	{r1-r12}
	
	ldr 	r7, =snakeBodyX
	ldr 	r8, =snakeBodyY
	ldr	r0, [r7]
	ldr	r1, [r8]
	
	ldr	r9, =rareCandyXY
	ldr	r2,[r9]
	ldr	r3,[r9, #4]
			
	teq	r0, r2
	beq	checkRareY	
	mov	r0, #0
	b 	doneBerry
	
	checkRareY:
			teq	r1, r3
			moveq	r0, #1
			beq	doneRare
			mov	r0, #0
doneRare:
	
	pop	{r1-r12}
	bx 	lr


SpawnCheck:
	
	push	{r2-r12}
	mov	r6, #0	
	ldr 	r7, =snakeBodyX
	ldr 	r8, =snakeBodyY
	ldr	r9, =blockX
	ldr	r10,=blockY	
	
	spawnBoulderLoop:
	
	teq	r6, #35
	beq	spawnBody
	ldr	r2, [r9], #4
	ldr	r3, [r10], #4
		
	teq	r0, r2
	beq	spawnBoulderY
	add 	r6, #1
	b 	spawnBoulderLoop
	
	spawnBoulderY:
		
		teq	r1, r3
		beq 	spawnTrue
		add 	r6, #1
		b 	spawnBoulderLoop
	
	spawnBody:

	mov	r6, #0	
	add	r4, #1

	spawnBodyLoop:
	
	teq	r6, r4
	beq	spawnBounds
	ldr	r2, [r7], #4
	ldr	r3, [r8], #4
	
	teq	r0, r2
	beq	spawnBodyY
	add 	r6, #1
	b 	spawnBodyLoop
	
	spawnBodyY:
		
		teq	r1, r3
		beq 	spawnTrue
		add 	r6, #1
		b 	spawnBodyLoop

	spawnBounds:
	
		teq	r0, #0
		beq	spawnTrue
		teq	r0, #31
		beq	spawnTrue
		teq	r1, #2
		beq	spawnTrue
		teq	r1, #23
		beq	spawnTrue
	

		mov	r0, #0

spawnCollision:
	
	pop	{r2-r12}
	bx	lr

	spawnTrue:
	
		mov	r0, #1
		b	spawnCollision

///////////////////////////////////
//////////////CHECK////////////////
///////////////////////////////////


///////////////////////////////////
///////////////INIT////////////////
///////////////////////////////////

InitializeSnake:
	
	push	{r0-r12}	
	
	ldr	r7, =snakeBodyX
	ldr	r8, =snakeBodyY
	mov	r6, #0
	mov	r0, #9
	mov	r1, #15
	
	InitializeBodyLoop:	
	
		str	r0,[r7, r6]
		str	r1,[r8, r6]
	
		add	r6, #4
		sub	r0, #1
		teq	r0, #6
		bne	InitializeBodyLoop
	
		mov	r0, #-1
		mov	r1, #42

	InitializeArrayLoop:	
	
		str	r0,[r7, r6]
		str	r0,[r8, r6]
	
		add	r6, #4
		sub	r1, #1
		teq	r1, #0
		bne	InitializeArrayLoop

	pop	{r0-r12}
	
	bx 	lr

gamewait:      	// (r0 = parameter to check for waiting time)
	push	{r4,lr}
	ldr 	r1, =0x20003004   //address of CLO
	ldr	r2, [r1]   //read CLO
	add	r2, r0     //add time to wait
	ldr	r4, =snes_data
	
	gamewaitLoop:
		
		bl	Read_SNES_raw
		cmp	r0,	#0
		strne	r0,	[r4]

		ldr	r3,[r1]  //read CLO
		cmp 	r2, r3   //stop when CLO = 1
		bhi	gamewaitLoop 
	
	pop	{r4,lr}
	mov 	pc, lr   //return

Read_SNES:

	push	{r1,lr}	
	ldr	r1,	=snes_data
	bl	Read_SNES_raw
	cmp	r0,	#0
	strne	r0,	[r1]
	
	ldr	r0,	[r1]
	pop	{r1,lr}
	bx	lr


del_snes:
	push	{r0,r1}
	
	ldr	r0,	=snes_data
	mov	r1,	#0
	str	r1,	[r0]
	
	pop	{r0,r1}
	bx	lr

del_ioff:
	
	push	{r0,r1}
	
	ldr	r0,	=i_off1
	mov	r1,	#-1
	str	r1,	[r0]
	
	ldr	r0,	=i_off3
	mov	r1,	#-1
	str	r1,	[r0]	
	
	pop	{r0,r1}
	bx	lr

InitializeRare:
	
	push	{r0,r1}
	
	ldr	r0,	=rareCandyXY
	mov	r1,	#-1
	str	r1,	[r0]
	str	r1,	[r0, #4]	
	
	pop	{r0,r1}
	bx	lr


InitializeBerry:
	
	push	{r0,r1}
	
	ldr	r0,	=bigBerryXY
	mov	r1,	#-1
	str	r1,	[r0]
	str	r1,	[r0, #4]	
	
	pop	{r0,r1}
	bx	lr


InitializeGPIO:
	
	push	{r0-r12,lr}
	
	mov 	r0, #9        //passing in pin 9 (latch)  	parameter        
	mov 	r1, #1        //passing in output parameter   	
	bl 	init_GPIO	
	mov 	r0, #10       //passing in pin 10 (data) parameter
	mov 	r1, #0        //passing in input parameter
	bl 	init_GPIO
	mov 	r0, #11       //passing in pin 11 (clock) paramater
	mov 	r1, #1        //passing in output parameter	
	bl 	init_GPIO 

	pop	{r0-r12,lr}

	bx	lr	



///////////////////////////////////
///////////////INIT////////////////
///////////////////////////////////
	
.section .data
.align 4

snes_data:	.word	0
.globl	i_off1
.globl	i_off3
i_off1:		.word	-1	//Interrupt offsets for pause menu
i_off3:		.word	-1

snakeBodyX:
	
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1

snakeBodyY:
	
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1
	.int	-1

eggXY:
	.int 	9 
	.int 	12

bigBerryXY:
	.int 	-1
	.int 	-1

rareCandyXY:
	.int 	-1
	.int 	-1

speed:
	.int 	150000 	
	.int	74992
	.int	64992

valueFlag: .int 	0 

.section .data
.align 4
.globl	int_table
int_table:
    ldr     pc, reset_handler
    ldr     pc, undefined_handler
    ldr     pc, swi_handler
    ldr     pc, prefetch_handler
    ldr     pc, data_handler
    ldr     pc, unused_handler
    ldr     pc, irq_handler
    ldr     pc, fiq_handler
reset_handler:      .word InstallIntTable
undefined_handler:  .word haltLoop$
swi_handler:        .word haltLoop$
prefetch_handler:   .word haltLoop$
data_handler:       .word haltLoop$
unused_handler:     .word haltLoop$
irq_handler:        .word irq
fiq_handler:        .word haltLoop$

