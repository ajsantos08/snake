//	Scott	Saunders
//	10163541
//	March 30,	2016


//returns the next "n\"


ASCII_SPACE	=	0x20
ASCII_NEWLINE=	0x0a
ASCII_CHARRET=	0x0c

.section .text

find_next_char:	//*address, char
	push	{r2}
	//Takes an address, and a char, returns the address with the next char.
find_next_char_loop:
	ldrb	r2,		[r0]
	cmp		r2,	r1
	addne	r0,	#1
	bne		find_next_char_loop

	pop		{r2}
	bx		lr

