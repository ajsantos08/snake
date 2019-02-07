//Scott Saunders	10163541

//Divides with quotent and remainder and returns them in r0 and r1 respectivly.
//Takes in numerator as r0, and denominator as r1

//Paramiters:	r0	-	Numerator
//				r1	-	Denominator

//Returns		r0	-	Quotent
//				r1	-	Remainder


//TODO: Implment with binary long division instead.


intdiv:
	push {r2-r12}
	numer .req r0
	denom .req r1
	count .req r2
	
	mov		count, #0			//set counter

	cmp		denom,	#0			//Div by zero
	beq enddiv


	cmp		numer,	denom		
divloop:
	subge	numer,	denom	//Sub, if numer >= denom, 
	addge	count,	#1		//
	cmp		numer,	denom	
	blt		enddiv			//End if the numerator is too small to subtract again.
	b		divloop			//Else keep going.

enddiv:
	//count contains the quotient
	//numerator contains the remainder 
	mov		r1,		numer
	mov 	r0,		count
	.unreq numer
	.unreq denom
	.unreq count
	pop  {r2-r12}
	bx lr
