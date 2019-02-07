//Scott Saunders	10163541
//A wrapper function to readlines for A1

.macro	readline	
	ldr		r0,		=buff
	mov		r1,		#BUFFSIZE
	bl	ReadLineUART
	//Returns r0: The number of ascii chars read.
.endm

