//Scott Saunders	10163541

//A simple file including all my macros/functions

.include "./macros/m_prints.s" 		//A2 Onwards
.include "./macros/m_read.s"
.include "./macros/m_zeroreg.s"
.include "./macros/m_delay.s"
.include "./macros/m_doubleldr.s"

.include "./macros/div.s"
.include "./macros/atoi.s"
.include "./macros/memcopy.s"
.include "./macros/itoa.s"
.include "./macros/addnlcr.s"
.include "./macros/timer.s"			//A3 Onwards
.include "./macros/gpio.s"
.include "./macros/strings.s"						//New
.include "./macros/print.s"
.include "./macros/snes.s"

.include "./macros/masks.s"			//A4
.include "./macros/mailbox.s"
.include "./macros/ppm.s"		
.include "./macros/ascii_img.s"
.include "./macros/framebuff.s"
.include "./macros/random.s"

.include "./macros/interrupts.s"
.include "./macros/irq.s"
.include "./macros/sys_timer.s"

.include "./macros/tests.s"


.ltorg

