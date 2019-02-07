.section    .init
.globl     _start

_start:
    b       InstallIntTable
    
.section .text
.include "./macros/include.s"
.include "./game/include.s"
.section .text

.align 4
main:
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART

	bl		game_init

	bl	fb_reset_info
	bl	fb_initalize

//	b		demo

	mov		r0,	#32
	mov		r1,	#32
	ldr		r2,	=test
	bl		draw_ascii

	mov		r0,	#64
	mov		r1,	#64
	ldr		r2,	=snake_head_d
	bl		draw_ascii

	mov     r0, #64
    mov     r1, #32
    ldr     r2, =snake_body_d
	bl		draw_ascii

	mov		r0,	#64
	mov		r1,	#0
	ldr		r2,	=snake_tail_d
	bl		draw_ascii

	b		halt

demo:

	bl		init_xor_rand	// Initalize xor_rand

	print_msg_q	created

	

	block_timer_q	3000

	ldr	r0,	=3000000
//	bl	set_timer_1	
	bl	enable_irq

	ldr	r0,	=1000000
//	bl	set_timer_3
	
	bl	snes_init

	mov	r0,	#0
	mov	r1,	#0
	ldr	r2,	=0xffff	//White
	ldr	r3,	=0x0000	//Black
	mov	r4,	#'A'
	bl	fb_drawchar

//	ldr	r2,	=0b0000011111100000

//	bl	fb_setpixle

    mov r0, #0
    mov r1, #0
    ldr r2, =0xffff //White
    ldr r3, =0x0000 //Black
	ldr	r4,	=msg
	bl	fb_drawstring


//	mov	r0,	#0
//	mov	r1,	#200
//	mov	r2,	#'A'
//	ldr	r3,	=0xffff

//	bl	fb_drawchar

//	mov	r0,	#0
//	mov	r1,	#100

//	ldr		r2,	=0xffff
//	ldr		r3,	=msg

//	bl		fb_drawstring	

b	halt

msg:	.asciz	"Hello! Sorry, Did this work? Text me: 4039037272. \0"
.align	4

b	halt

loop1:
	nop
loop2:
	add		r2,	#0x1
loop3:

	bl	fb_setpixle
	cmp		r0,	#-1
	addne	r0,	#0x1
	addeq	r1, #0x1
	moveq	r0,	#0
	cmp		r1,	#0xf000
	movge	r1,	#0

	b	loop1 

halt:
//	bl	snes_print_buttons
//	block_timer_q 	30000

	ldr		r12,	=snake
	b halt

hackwritemem:
	push	{r0-r3,lr}
	mov	r3,	#0
sets:
	nop
	nop			//Set r0 to addr
	nop			//Set r1 to value
	str		r1,	[r0]
	nop
	nop			//Set r3 to 1 to return to prior code
	
	cmp		r3,	#1
	bne		sets
	pop		{r0-r3,pc}

created:	.asciz	"Created by Scott Saunders.\n\r"

.section .data
.align 4
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
undefined_handler:  .word halt
swi_handler:        .word halt
prefetch_handler:   .word halt
data_handler:       .word halt
unused_handler:     .word halt
irq_handler:        .word irq
fiq_handler:        .word halt
