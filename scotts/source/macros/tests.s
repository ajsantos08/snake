//	Scott Saunders
//	10163541
//	March 29 2016

.section 	.text
run_tests:
	push	{lr}

	bl	test_bitmasks
	bl	test_fbs

	zeroreg
	pop		{lr}
	bx		lr


//bitmask_generators tests


test_bitmasks:
	push	{lr}
	
bitmask_test1:
    mov r0, #4
    mov r1, #0b1111
    bl  bitmask_gen
	cmp	r0,	r1
    bne bitmask_test1
	b	bitmask_test2

bitmask_test2:
    mov r0, #3
    mov r1, #0b111
    bitmask_gen_q   r3, r0
	mov	r0,	r3
	cmp	r3,	r1
    bne bitmask_test2

	pop		{pc}



test_fbs:
	push	{lr}

	bl	bundck_test1
	
	pop		{lr}
	bx		lr


bundck_test1:
	push	{lr}
	d_ldr	r2,	fbuff_wid
	d_ldr	r3,	fbuff_hig
	

	add		r0,	r2,	#1
	mov		r1,	r3

	bl	fb_boundck
	
	cmp		r0, #0
	bne 	bundck_test1
bundck_test2:
	mov		r0,	r2
	add		r1,	r3,	#1

    bl  fb_boundck

    cmp     r0, #0
    bne    bundck_test2

bundck_test3:
    add     r0, r2,	#1
    add     r1, r3, #1

    bl  fb_boundck

    cmp     r0, #0
    bne    bundck_test3

bundck_test4:
    sub		r0, r2,	#1
    sub     r1, r3,	#1

    bl  fb_boundck

    cmp     r0, #1
    bne    bundck_test4
	
	pop		{lr}
	bx		lr


	


	
























