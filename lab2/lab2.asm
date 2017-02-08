section .data

	filename	db 		"input",0
	file_len	equ		$-filename

section .bss
	
	stat 		resb	sizeof(STAT)

	allocate_array2d_byte buffer,16,16
	allocate_array_byte output_carrige,16

section .text
	global _start

_start:
	

	exit

from_oct_to_dec:
	
	mov esi, [arg(1) + arg(2)]
	mov ecx, [arg(2)]

	xor eax, eax
	mov ebx, 0x1
	mov eax, [esi + ecx]

	dec ecx

	.cycle:

		sal ebx, 3

		push eax
		push [esi + ecx]

		pop eax
		mul ebx
		pop edx

		add eax, edx

		dec ecx

		cmp ecx, 0x0
		jae .cycle
		ret


from_dec_to_chars:

	mov eax, [arg(1)]
	mov edi, [arg(2) + arg(3)]
	mov ecx, [arg(3)]

	mov ebx, 0x1