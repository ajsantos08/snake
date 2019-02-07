//Scott Saunders	10163541

//Macros to print things in various ways.

.macro  print   lbl,p_int:req
    ldr     r0, =\lbl
    mov     r1, #\p_int
    bl      WriteStringUART   
	//Note: This may be an issue in new projects. 
	//I will need to make the function myself at somepoint.
.endm


//Note: This one is prone to odd bugs (like breaking WriteStringUART...)
//Good for debugging.
.macro strprint str,int:req
	print   str_prnt\@, \int
.data
str_prnt\@:     .asciz  "\str"
	.align 4
.text
.endm



