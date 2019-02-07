//My macro to be lazy and print things for me.
.macro	print 	ptr,p_int:req
	ldr		r0,	=\ptr
	mov		r1,	#\p_int
	bl		WriteStringUART
.endm

//A simple macro to print a string (instead of pointer as above)
.macro strprint	str,int:req
//	ldr		r0,	=str_prnt\@
//	mov		r1,	#\int
	print	str_prnt\@,	\int

str_prnt\@:		.ascii	"\str"
	.align	4
.endm

.macro	readline	
	ldr		r0,		=buff
	mov		r1,		#BUFFSIZE
	bl	ReadLineUART
.endm

.macro	chartoint	reg
	sub		\reg,	#'0'
.endm
.macro	inttochar	reg
	add		\reg,	#'0'	
.endm

//Takes an ASCIZ string, and returns a valid (positive) intiger.
	//Returns -1 if negative
.macro	ascitoint str_buff 
	push`	{r1-r9}
	ldr		r9,		=buff
	ldrb	r8,		[r9]
	chartoint	r8
	//TODO IDK	
	pop		{r1-r9}
.endm

/*
.macro clr_buf\@:	
	ldr		r0,		=buff
	add		r1,		r0,		#BUFFSIZE
	strb	#0,		[r0]
	add		r0,		#1
	cmp 	r0,		r1
	bne		clr_buf\@
.endm
*/
.section .text
main:
   	mov     	sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG // Enable JTAG
	bl		InitUART    // Initialize the UART
		
	mov		r0,	#0


// You can use WriteStringUART and ReadLineUART functions here after the UART initializtion.



	print 	str_cre,32 //prints created by

prmt:
	print		str_please,17 //prints the please
	print		str_stdnts,22 //prints the number of students part
	readLine 	//Another macro made above, reads and puts it in the buffer
	print		buff,256 //Debug prints back what it got.
//	strprint	"\n\r",2 //Puts it to a new line/left aligned.

	ldr 	r0,	=str_num
	mov		r1,		32
	WriteStringUART 
str_num:	.ascii "%d"


	
	ldr		r9,	=buff //Reads the addr of buffer
	ldrb	r8,	[r9]	  //Reads the first value of the buffer
	sub		r8,	#'0' //Subtracts it by ASCII value of 0 to get sin.digit value
buffnuke:
	clearbuf			//nukes the buffer
	
haltLoop$:
	b	haltLoop$

.section .data  
BUFFSIZE=5
buff:
	.rept	BUFFSIZE
	.byte	0
	.endr

str_cre:	.asciz	"Created by Scott Saunders. \n \n\r"
str_please:	.ascii	"Please enter the "
str_stdnts: .asciz  "number of students: \n\r"

str_1:		.asciz	"first grade:\n\r"
str_2:		.asciz	"second grade:\n\r"
str_3:		.asciz	"third grade:\n\r" 
str_4:		.asciz	"fourth grade:\n\r"
str_5:		.asciz	"fifth grade:\n\r"
str_6:		.asciz	"sixth grade:\n\r"
str_7:		.asciz	"seventh grade:\n\r"
str_8:		.asciz	"eighth grade:\n\r"
str_9:		.asciz	"ninth grade:\n\r"
