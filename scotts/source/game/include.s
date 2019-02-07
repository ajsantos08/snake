//Scott Saunders	10163541


.include "./game/game.s"
.include "./game/snake.s"
.include "./game/snake_move.s"
.include "./game/draw_snake.s"
.include "./game/draw_misc.s"
.include "./game/pause.s"

.ltorg

.align 4
font:	.incbin	 "./imgs/font.bin"
.include "./imgs/img.s"

