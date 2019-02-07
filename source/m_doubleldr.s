//Scott Saunders	10163541
//March	10,	2016

.macro	d_ldr	reg,val:req
		ldr	\reg,	=\val		//Gets the addr
		ldr	\reg,	[ \reg ]		//Loads the value of addr
.endm

