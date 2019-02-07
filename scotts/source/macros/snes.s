//Scott Saunders	10163541
//Various SNES-controller functions/macros.


//Order of reading from Data:
//	B	Y	Slect	Start	Up	Down	Left	Right	A	X	L	R
//	0	1	2		3		4	5		6		7		8	9	10	11
//B will be the MSB, and R the LSB.

//Compair constants: (Are reverse order, due to shifting the first read)
SNES_B_B=0x800
SNES_B_Y=0x400
SNES_B_Sl=0x200
SNES_B_St=0x100
SNES_D_U=0x80
SNES_D_D=0x40
SNES_D_L=0x20
SNES_D_R=0x10
SNES_B_A=0x8
SNES_B_X=0x4
SNES_B_L=0x2
SNES_B_R=0x1

LATCH	=	9
DATA	=	10
CLOCK	=	11

LATCH_DELAY	=	 12
CLOCK_DELAY	=	 6
//Initalization: Set Latch/Clock to output:

snes_init:
	gpio_setup_quick	#LATCH,		#GPIO_OUTPUT
	gpio_setup_quick	#DATA,		#GPIO_INPUT
	gpio_setup_quick	#CLOCK,		#GPIO_OUTPUT
	gpio_setup_quick	#16,		#GPIO_OUTPUT
	bx	lr

.macro	snes_get_data	reg
	d_ldr	\reg,	snes_data1
	push	{r0,r1}
	ldr		r0,		=snes_data1			//Deletes the data
	mov		r1,	#1
	str		r1,		[r0]
	pop		{r0,r1}

.endm

snes_read_adv:
	push	{r0-r3,lr}

	bl	snes_read	//Load data
	cmp		r0,	#0
	ldrne	r1,	=snes_data1
	strne	r0,	[r1]

	pop		{r0-r3,lr}
	bx		lr

snes_read:
	push	{r1-r4,lr}

	gpio_set_hi_q		#CLOCK
	gpio_set_hi_q		#LATCH

	block_timer_q		LATCH_DELAY			//Wait 12 
	gpio_set_low_q		#LATCH

	block_timer_q		LATCH_DELAY			//Wait 12 
	
	mov					r1,	#0
	mov					r2,	#0

snes_r_loop:
	cmp		r1,	#12					//Loop Once for each button
	bge		snes_read_end			//End loop

	gpio_set_hi_q		#CLOCK		//Set hi
	block_timer_q		CLOCK_DELAY
	gpio_set_low_q		#CLOCK		//Set low
	block_timer_q		CLOCK_DELAY

	gpio_read_pin_q		#DATA
	lsl		r2,	#1					//Shift The saved data over	

	cmp		r0,	#0					//Put the data in		
	bne		snes_skip

	orreq	r2,	#1					//Put a 1 in the LSB if it is read as a zero
									//Done this way so there is a "1" if it is set.
										//Easy use of cmp pin, bge #SNES_B_B to test pins
//	gpio_set_low_q		#16
//	block_timer_q		1000		//Flashes LED on a button press.
//	gpio_set_hi_q		#16

snes_skip:
	add		r1,	#1					//Add 1 to counter and repeat
	b	snes_r_loop

snes_read_end:
	mov		r0,	r2					//Move the data to r0.
	pop		{r1-r4,lr}
	bx	lr


snes_print_buttons:					//Stolen code from A3, to print the button
									//currently pressed.

	push	{r0-r5,lr}
	
	bl	snes_read				//Read buttons

.macro  button_test lbl
    cmp r0, r3              //r3 the current value to test.
    blt button_t_end\@      //If the button is not pressed, ignore. 

    print_msg_q \lbl        //If the button was pressed, print it's string.
    sub     r0, r3          //Remove the current value.

button_t_end\@:
    lsr     r3, #1          //Shift the value of r3 down for the next test.
.endm

	print_msg_q     pressed
	ldr r3, =SNES_B_B
	button_test     b_b
    button_test     b_y
    button_test     b_sl
    button_test     b_st
    button_test     d_u
    button_test     d_d				
    button_test     d_l             //Passes in the lbl to print.
    button_test     d_r
    button_test     b_a
    button_test     b_x
    button_test     b_l
    button_test     b_r
	print_msg_q		endline

	pop		{r0-r5,lr}
	bx		lr

.section 	.data
.align 4
endline:            .asciz      ".\r\n"
pressed:        .asciz      "Pressed buttons:"
b_st:           .asciz      " Start"
b_sl:           .asciz      " Select"

b_a:            .asciz      " Button A"
b_b:            .asciz      " Button B"
b_x:            .asciz      " Button X"
b_y:            .asciz      " Button Y"

b_l:            .asciz      " Left Trigger"
b_r:            .asciz      " Right Trigger"

d_u:            .asciz      " D-pad Up"
d_d:            .asciz      " D-pad Down"
d_l:            .asciz      " D-pad Left"
d_r:            .asciz      " D-pad Right"


snes_data1:		.word		0
snes_data2:		.word		0
.section	.text
.align 4
