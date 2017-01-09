section .data

	X: 			db 		"00000110101111011100" ; 27606
	X_len:		equ		$-X
	Y: 			db 		"10100111101110010101" ; 686997
	Y_len:		equ		$-Y

section .bss

	bufferX: 	resb	X_len
	bufX_len:	equ		$-bufferX
	bufferY: 	resb	Y_len
	bufY_len:	equ		$-bufferY
	
	bufferOvflw:		resb	8
	bufOvflw_len:		equ		$-bufferOvflw

	x1_index:			equ		bufferX + bufX_len - 1
	x2_index:			equ		bufferX + bufX_len - 2
	x3_index:			equ		bufferX + bufX_len - 3
	x4_index:			equ		bufferX + bufX_len - 4

	z10_index:			equ		bufferX + bufX_len - 10
	z11_index:			equ		bufferX + bufX_len - 11
	z15_index:			equ		bufferX + bufX_len - 15
	z16_index:			equ		bufferX + bufX_len - 16
	z19_index:			equ		bufferX + bufX_len - 19

section .text
	global _start


_start:
	
	fill_buffer X, bufferX, bufX_len
	fill_buffer Y, bufferY, bufY_len

	
