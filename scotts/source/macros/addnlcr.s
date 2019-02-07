//Scott Saunders 10163541

//Paramiters:	*Buffer,	int (length)
//Returns	: 	*Buffer,	int (length)

//Simply appends /n/r at the end of buffer (more correctly at buff+len+1)

addnlcr:
	push	{r2,r3,r4}
	mov	r3,	r0		//Copys the buffer addr
	add	r3,	r1		//Increments it by the length of chars
	//At this point it points to the last char
	mov		r4,	#0x0A		// \n
	strb	r4,	[r3 ]
	mov		r4,	#0x0D
	strb	r4,	[r3, #1 ]	// \r
	add 	r1,	#2
	
	pop	{r2,r3,r4}
	bx	lr
