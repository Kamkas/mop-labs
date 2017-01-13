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
	
	; fill_buffer X, bufferX, bufX_len
	; fill_buffer Y, bufferY, bufY_len

	pcall4 do_function, x1_index, x2_index, x3_index, x4_index
	add esp, 16

	cmp eax, true
	je 

; result sores in eax
do_function:

	push ebp
	mov ebp, esp
	sub esp, 16

	; !(x1+x2)
	mov eax, [arg(1)]
	or eax, [arg(2)]
	invert eax
	push eax

	; x3*x4
	mov eax, [arg(3)]
	and eax, [arg(4)]

	; $1 + $2
	pop ebx
	or eax, ebx

	mov esp, ebp
	pop ebp
	ret


; if true
; Y - X * 8
; result sores in eax
fc_func:
	push ebp
	mov ebp, esp
	sub esp, 8

	; xor eax, eax
	; mov ecx, bufY_len
	; call from_bin_to_hex

	pcall2 from_bin_to_hex, bufferY, bufY_len
	add esp, 8
	push eax

	pcall2 from_bin_to_hex, bufferX, bufX_len
	add esp, 8

	pop edx
	sal eax, 3
	neg eax

	add eax, edx

	mov esp, ebp
	pop ebp
	ret


; if false
; X * 8 + Y * 8
sc_func:
	push ebp
	mov ebp, esp
	sub esp, 8

	pcall2 from_bin_to_hex, bufferY, bufY_len
	add esp, 8
	push eax

	pcall2 from_bin_to_hex, bufferX, bufX_len
	add esp, 8
	
	pop edx
	add eax, edx
	sal eax, 3

	mov esp, ebp
	pop ebp
	ret



from_bin_to_hex:
	
	push ebp
	mov ebp, esp
	sub esp, 8

	mov esi, [arg(1) + arg(2)]
	mov ecx, arg(2)

	xor eax, eax
	mov ebx, 0x1
	mov eax, [esi + ecx]

	dec ecx

	.cycle:
		
		mov edx, [esi + ecx]
		add ebx, ebx
		cmp edx, 0x1
		je ..@pow2

		dec ecx

		cmp ecx, 0x0
		jae .cycle
		ret

		..@pow2:
			add eax, ebx		
			ret

	mov esp, ebp
	pop ebp
	ret


from_hex_to_bin:

	push ebp
	mov ebp, esp
	sub esp, 16

	push eax
	push ecx
	push edx
	push edi

	mov eax, [arg(1)]
	mov edi, [arg(2)]
	mov ecx, [arg(3)]

	.cycle:

		test eax, eax
		jpo ..@odd

		mov dl, 0x0
		jmp ..@r0

		..@odd:
			mov dl, 0x1
			jmp ..@r0

		..@r0:
			mov [edi + ecx], dl
			dec ecx

			sar eax, 1
			cmp eax, 0x0
			ja .cycle
			ret

		ret

	pop edi
	pop edx
	pop ecx
	pop eax

	mov esp, ebp
	pop ebp
	ret


z_func:
	enter 16, 0

	; z19 &= z16
	mov eax, [z19_index]
	mov edx, [z16_index]
	and eax, edx
	mov [z19_index], al

	; z15 |= z16
	mov eax, [z15_index]
	mov edx, [z16_index]
	or eax, edx
	mov [z15_index], al

	; z11 = !z10
	mov eax, [z10_index]
	invert eax
	mov [z11_index], al

	leave
	ret