section .data

	X: 			db 		"00000110101111011111" ; 27615
	X_len:		equ		$-X
	Y: 			db 		"10100111101110010101" ; 686997
	Y_len:		equ		$-Y

section .bss

	bufferX: 	resb	X_len
	bufX_len:	equ		$-bufferX
	bufferY: 	resb	Y_len
	bufY_len:	equ		$-bufferY
	
	bufferOvflw:		resd	8
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

	pcall4 do_function, x1_index, x2_index, x3_index, x4_index

	cmp eax, true
	je fc_func

	cmp eax, false
	je sc_func
	
	.back:

	pcall3 from_hex_to_bin, eax, bufferX, bufX_len

	jmp z_func
	.back_z:

	buffer_to_acsii bufferX, bufX_len

	sys_io bufferX, bufX_len, sys_write, stdout

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

	; ; $1 + $2
	pop bx
	or al, bl

	mov esp, ebp
	pop ebp
	ret


; if true
; Y - X * 8
; result sores in eax
fc_func:

	pcall2 from_bin_to_hex, bufferY, bufY_len
	push eax

	pcall2 from_bin_to_hex, bufferX, bufX_len

	pop edx
	sal eax, 3
	neg eax

	add eax, edx

	jmp _start.back


; if false
; X * 8 + Y * 8
sc_func:
	
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
		ja .cycle

	mov esp, ebp
	pop ebp
	ret


z_func:

	; z19 &= z16
	mov al, byte [z19_index]
	mov dl, byte [z16_index]
	and al, dl
	mov byte [z19_index], al

	; z15 |= z16
	mov al, byte [z15_index]
	; mov dl, byte [z16_index]
	or al, dl
	mov byte [z15_index], al

	; z11 = !z10
	xor eax, eax
	mov al, byte [z10_index]
	invert eax
	mov byte [z11_index], al

	jmp _start.back_z