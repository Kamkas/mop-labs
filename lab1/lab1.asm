section .data

	newline:	db		nl
	
	X: 			db 		"00001011010000010111" ; 46103
	X_len:		equ		$-X
	Y: 			db 		"10101111100101110110" ; 719222
	Y_len:		equ		$-Y

	msg1:			db		"Enter 1st(X) binary number (20 char) >> "
	msg1_len		equ		$-msg1

	msg2:			db		"Enter 2nd(Y) binary number (20 char) >> "
	msg2_len		equ		$-msg2

	ovr_msg:		db		"Overflow bits(from 20 to 28 digits)",nl
	ovr_msg_len		equ		$-ovr_msg

	result_msg:		db		"Result bits(20..0 digits)",nl
	result_msg_len	equ		$-result_msg

	bool_func:		db		"Result of F(x1, x2, x3, x4) >> "
	bool_func_len	equ		$-bool_func

	z1_msg:			db 		"z19 &= z16", nl
	z1_msg_len	    equ		$-z1_msg

	z2_msg:			db 		"z15 |= z16", nl
	z2_msg_len	    equ		$-z2_msg

	z3_msg:			db 		"z11 = !z10", nl
	z3_msg_len	    equ		$-z3_msg

	final_res_msg:	db		"Final result ->  "
	final_res_msg_len 		equ		$-final_res_msg

	fst_msg:		db		"Z = Y-X*8", nl
	fst_msg_len		equ		$-fst_msg

	scnd_msg:		db		"Z = X*8+Y*8", nl
	scnd_msg_len	equ		$-scnd_msg

	bin_func_msg			db		"F_27 = !x1x3|!x1x2|x1x3x4|!x1x2x3|!x1!x2", nl
	bin_func_msg_len		equ 	$-bin_func_msg

	F_msg			db		"Z = "
	F_msg_len		equ 	$-F_msg

section .bss

	bufferOvflw:		resb	8
	bufOvflw_len:		equ		$-bufferOvflw

	bufferX: 	resb	20
	bufX_len:	equ		$-bufferX
	
	bufferY: 	resb	20
	bufY_len:	equ		$-bufferY

	allocate_array_byte bul_f, 1
	allocate_array_byte temp, 1

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
	
	o_console msg1, msg1_len
	o_console X, X_len
	o_console newline, 1
	; i_console bufferX, bufX_len
	fill_buffer X, bufferX, bufX_len


	o_console msg2, msg2_len
	o_console Y, Y_len
	o_console newline, 1
	; i_console bufferY, bufY_len
	fill_buffer Y, bufferY, bufY_len

	o_console bin_func_msg, bin_func_msg_len
	pcall4 do_function, x1_index, x2_index, x3_index, x4_index

	mov byte [bul_f], al
	add byte [bul_f], 0x30

	o_console bool_func, bool_func_len
	o_console bul_f, 1
	o_console newline, 1

	cmp eax, true
	je fc_func

	cmp eax, false
	je sc_func
	
	.back:

	pcall3 from_hex_to_bin, eax, bufferX, bufX_len

	buffer_to_acsii bufferOvflw, 7
	; buffer_to_acsii bufferX, bufX_len
	buffer_to_acsii bul_f, 1
	
	jmp z_func
	.back_z:

	o_console ovr_msg, ovr_msg_len
	o_console bufferOvflw, bufOvflw_len
	o_console newline, 1
	
	o_console result_msg, result_msg_len
	o_console bufferX, bufX_len
	o_console newline, 1

	exit



; result stores in eax
do_function:

	push ebp
	mov ebp, esp
	sub esp, 16

	xor eax, eax
	xor ebx, ebx

	; !(x1+x2)
	mov esi, [arg(1)]
	mov al, byte [esi]
	mov esi, [arg(2)]
	mov bl, byte [esi]

	or al, bl
	invert eax
	push ax

	; ; x3*x4
	mov esi, [arg(3)]
	mov al, byte [esi]
	mov esi, [arg(4)]
	mov bl, byte [esi]

	and al, bl
	push ax

	; $1 + $2
	pop ax
	pop bx
	or al, bl
	
	mov esp, ebp
	pop ebp
	ret


; if true
; Y - X * 8
; result sores in eax
fc_func:

	o_console fst_msg, fst_msg_len

	pcall2 from_bin_to_hex, bufferY, bufY_len
	push eax

	pcall2 from_bin_to_hex, bufferX, bufX_len

	pop edx
	sal eax, 3

	cmp eax, edx
	ja .negtive

	sub edx, eax
	mov eax, edx
	
	.negtive:
		sub eax, edx
	jmp _start.back


; if false
; X * 8 + Y * 8
sc_func:

	o_console scnd_msg, scnd_msg_len
	
	pcall2 from_bin_to_hex, bufferY, bufY_len
	push eax

	pcall2 from_bin_to_hex, bufferX, bufX_len
	
	pop edx
	add eax, edx
	sal eax, 3

	jmp _start.back


from_bin_to_hex:
	
	push ebp
	mov ebp, esp
	sub esp, 8

	mov esi, [arg(1)]
	mov ecx, [arg(2)]
	sub ecx, 0x1

	xor eax, eax
	xor ebx, ebx
	xor edx, edx
	mov ebx, 0x1
	mov al, byte [esi + ecx]

	dec ecx

	.cycle:
		mov dl, byte [esi + ecx]
		sal ebx, 1
		cmp dl, byte 0x1
		je ..@pow2
		
		cmp dl, byte 0x1
		jne ..@continue

		..@pow2:
			add eax, ebx
			jmp ..@continue

		..@continue:
		dec ecx

		cmp ecx, 0x0
		jge .cycle
		jmp .end


	.end:
	mov esp, ebp
	pop ebp
	ret



; TODO: change to shr, and check CF
from_hex_to_bin:

	push ebp
	mov ebp, esp
	sub esp, 16

	mov eax, [arg(1)]
	mov edi, [arg(2)]
	mov ecx, [arg(3)]
	dec ecx

	.cycle:
		test eax, 0x1
		jnz ..@odd

		; cmp ecx, -1
		; je ..@set_overflow

		; ..@set_overflow:
		; 	mov edi, bufferOvflw
		; 	mov ecx, bufOvflw_len

		mov dl, 0x0
		jmp ..@r0

		..@odd:
			mov dl, 0x1
			jmp ..@r0

		..@r0:
		mov byte [edi + ecx], dl
		dec ecx

		sar eax, 1
		cmp eax, 0x0
		jnz .cycle

	mov esp, ebp
	pop ebp
	ret


z_func:

	o_console F_msg, F_msg_len

	buffer_to_acsii bufferX, bufX_len

	o_console bufferX, bufX_len
	o_console newline, 1

	o_console z1_msg, z1_msg_len

	fill_buffer bufferX, bufferX, bufX_len

	; z19 &= z16
	mov al, byte [z19_index]
	mov dl, byte [z16_index]
	and al, dl
	mov byte [z19_index], al

	buffer_to_acsii bufferX, bufX_len

	o_console bufferX, bufX_len
	o_console newline, 1

	o_console z2_msg, z2_msg_len

	fill_buffer bufferX, bufferX, bufX_len

	; z15 |= z16
	mov al, byte [z15_index]
	; mov dl, byte [z16_index]
	or al, dl
	mov byte [z15_index], al

	buffer_to_acsii bufferX, bufX_len

	o_console bufferX, bufX_len
	o_console newline, 1

	o_console z3_msg, z3_msg_len

	fill_buffer bufferX, bufferX, bufX_len

	; z11 = !z10
	xor eax, eax
	mov al, byte [z10_index]
	invert eax
	mov byte [z11_index], al

	buffer_to_acsii bufferX, bufX_len

	o_console bufferX, bufX_len
	o_console newline, 1

	o_console final_res_msg, final_res_msg_len

	o_console bufferX, bufX_len
	o_console newline, 1

	jmp _start.back_z
