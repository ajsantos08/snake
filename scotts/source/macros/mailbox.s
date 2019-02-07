// Scott Saunders
//	10163541
//	March 28 2016

/* Write to mailbox
 * Args:
 *  r0 - value (4 LSB must be 0)
 *  r1 - channel
 */

.globl MailboxWrite
MailboxWrite:
    tst     r0, #0b1111                     // if lower 4 bits of r0 != 0 (must be a valid message)
    movne   pc, lr                          //  return
    
    cmp     r1, #15                         // if r1 > 15 (must be a valid channel)
    movhi   pc, lr                          //  return
    
    channel .req r1
    value   .req r2
    mov     value, r0
    
    mailbox .req r0
	ldr     mailbox,=0x2000B880
    
mb_w_wait:
    status  .req r3
    ldr     status, [mailbox, #0x18]        // load mailbox status
    
    tst     status, #0x80000000             // test bit 32
    .unreq  status
    bne     mb_w_wait                          // loop while status bit 32 != 0
    
    add     value, channel                  // value += channel
    .unreq  channel
    
    str     value, [mailbox, #0x20]         // store message to write offset
    
    .unreq  value
    .unreq  mailbox
    
    bx		lr


/* Read from mailbox
 * Args:
 *  r0 - channel
 * Return:
 *  r0 - message
 */
.globl MailboxRead
MailboxRead:
    cmp     r0, #15                         // return if invalid channel (> 15)
    movhi   pc, lr
    
    channel .req r1
    mov     channel, r0
    
    mailbox .req r0
	ldr     mailbox,=0x2000B880
    
mb_r_wait:
    status  .req r2
    ldr     status, [mailbox, #0x18]        // load mailbox status
    
    tst     status, #0x4000000              // test bit 30
    .unreq  status
    bne     mb_r_wait                          // loop while status bit 30 != 0
    
    mail    .req r2
    ldr     mail, [mailbox, #0]             // retrieve message
    
    inchan  .req r3
    and     inchan, mail, #0b1111           // mask out lower 4 bits of message into inchan
    
    teq     inchan, channel
    .unreq  inchan
    bne     mb_r_wait                      // if not the right channel, loop
    
    .unreq  mailbox
    .unreq  channel
    
    and     r0, mail, #0xfffffff0           // mask out channel from message, store in return (r0)
    .unreq  mail
    
	bx		lr




fix_mailbox:
	push	{r0}
	d_ldr   r0, 0x2000B880
	cmp		r0,	#0
//	bne		fix_mailbox
	pop		{r0}
	bx 		lr
