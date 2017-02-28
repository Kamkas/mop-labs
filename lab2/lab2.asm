section .data

	in_filename	db 		"input",0
	out_filename	db 		"output",0

	; text		db		"leaf",nl,"lying",nl,"on",nl,"177777",0

section .bss

	allocate_array2d_byte buffer,16,16
	buf_len		equ		$-buffer
	
	allocate_array2d_byte output_buffer,16,16
	outbuf_len	equ		$-output_buffer
	
	; allocate_array_byte output_carrige,16
	; output_carrige_len	equ		$-output_carrige

	allocate_array_byte fd,1
	allocate_array_byte words_number,1
	allocate_array_byte max_number,1
	allocate_array_byte fst_index,1
	allocate_array_byte lst_index,1

section .text
	global _start

_start:
	; push ebp
	; mov ebp, esp

	read_file_to_buffer in_filename, fd, buffer, buf_len

	pcall2 get_string_values, buffer, buf_len

	pcall1 check_for_nums, buffer

	pcall2 transpose_buffer, buffer, output_buffer

	; write_file_from_buffer out_filename, fd, output_buffer, outbuf_len
	; pcall3 save_to_file, output_buffer, out_filename, fd
	; write_file_from_buffer out_filename, fd, output_buffer, 5

	xor ecx, ecx
	mov esi, output_buffer
	movzx edx, byte [words_number]
	inc edx
	inc edx
	; mov [local(1)], edx
	.cycle:
		push ecx
		push edx

		o_console esi, edx

		add esi,16
		pop edx
		pop ecx

		inc cl
		cmp cl, byte [max_number]
		jb .cycle 


	exit

from_oct_to_hex:
	
	push ebp
	mov ebp, esp
	sub esp, 8

	mov esi, [arg(1)]
	mov ecx, [arg(2)]

	xor eax, eax
	mov ebx, 1
	movzx eax, byte [esi + ecx]

	dec ecx

	.cycle:

		sal ebx, 3

		push eax
		; push dword [esi + ecx]
		xor eax, eax
		mov al, byte [esi + ecx]
		; pop eax
		mul ebx
		pop edx

		add eax, edx

		dec ecx

		cmp ecx, 0
		jge .cycle

		mov esp, ebp
		pop ebp
		ret


from_hex_to_dec:

	push ebp
	mov ebp, esp
	sub esp, 12

	mov eax, [arg(1)]
	mov edi, [arg(2)]
	mov ecx, [arg(3)]

	mov ebx, 10

	.cycle:
		xor edx, edx
		div ebx
		
		cmp eax, 0
		jae ..@save

		..@save:
			cmp eax, 0
			jz ..@check
			jmp ..@nexts
			
			..@check:
				cmp edx, 0
				jz .exit

			..@nexts:
			mov byte [edi + ecx], dl
			dec ecx
			jmp .cycle

	.exit:
	mov esp, ebp
	pop ebp
	ret


transpose_buffer:

	push ebp
	mov ebp, esp
	sub esp, 16

	mov esi, [arg(1)]
	mov edi, [arg(2)]
	xor ecx, ecx
	xor ebx, ebx
	xor eax, eax

	.cycle:
		mov dl, byte [esi + ecx]

		cmp dl, nl
		je ..@processed
		jmp ..@step1

		..@processed:
			inc ebx

			; cmp al, byte [max_number]
			; ja ..@save_max
			; jmp ..@step2

			; ..@save_max:
				; mov byte [max_number], al

			; ..@step2:
			xor eax, eax
			inc ecx
			jmp .cycle

		..@step1:
		cmp dl, 0
		je .continue

		; mov byte [edi + ecx * 8 + ecx * 8 + ebx], dl

		push eax
		push ebx

		add ebx, eax

		mov byte [edi + ebx], dl
		
		pop ebx
		pop eax

		add eax, 16
		
		inc ecx
		jmp .cycle


	.continue:
	mov byte [words_number], bl
	
	; cmp byte [words_number], 0
	; je .exit


	movzx ecx, byte [words_number]
	movzx ebx, byte [max_number]


	pcall3 fill_zeros, edi, ebx, ecx


	.exit:
	mov esp, ebp
	pop ebp
	ret


check_for_nums:

	push ebp
	mov ebp, esp
	sub esp, 4
	
	mov esi, [arg(1)]
	xor ecx, ecx

	.cycle:
		isdigit byte [esi + ecx]
		cmp eax, true
		je ..@save_fst

		cmp eax, false
		je ..@continue

		..@continue:
			inc ecx
			cmp byte [esi + ecx], 0
			jnz .cycle
			jmp .exit


		..@save_fst:
			mov byte [fst_index], cl
			jmp ..@next_cycle

		..@next_cycle:
			inc ecx
			isdigit byte [esi + ecx]
			cmp eax, false
			je ..@save_lst

			cmp byte [esi + ecx], 0
			jnz ..@next_cycle
			jmp .exit

		..@save_lst:
			dec ecx ; ?? 
			mov byte [lst_index], cl

			push eax
			push edx

			xor eax, eax
			xor edx, edx

			movzx eax, byte [fst_index]
			movzx edx, byte [lst_index]

			pcall3 from_oct_to_dec, esi, eax, edx

			pop edx			
			pop eax

			xor ecx, ecx
			mov cl, byte [lst_index]
			inc ecx
			cmp byte [esi + ecx], 0
			jnz .cycle
			jmp .exit


	.exit:
	mov esp, ebp
	pop ebp
	ret



from_oct_to_dec:
	push ebp
	mov ebp, esp
	sub esp, 8

	mov esi, [arg(1)]
	mov edx, [arg(2)]
	mov ecx, [arg(3)]
	
	mov [local(2)], esi

	add esi, edx
	sub ecx, edx

	; mov dword [local(1)], esi
	mov dword [local(1)], ecx

	fill_buffer esi, esi, ecx

	pcall2 from_oct_to_hex, esi, dword [local(1)]

	push eax

	buffer_to_char esi, dword [local(1)], 0

	pop eax

	pcall3 from_hex_to_dec, eax, esi, dword [local(1)]

	buffer_to_acsii esi, dword [local(1)]

	mov esi, [local(2)]

	mov esp, ebp
	pop ebp
	ret


get_string_values:
	
	push ebp
	mov ebp, esp
	sub esp, 8

	mov esi, [arg(1)]
	mov eax, dword [arg(2)]
	mov dword [local(1)], eax

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	
	.for:
		mov dl, byte [esi + ecx]
		cmp dl, 0
		je .exit

		cmp dl, nl
		je ..@save_mn
		jmp ..@continue1

		..@save_mn:
			inc ebx
			cmp al, byte [max_number]
			ja ..@next
			jmp ..@next1

			..@next:
				mov byte [max_number], al
				jmp ..@next1

			..@next1:
			xor eax, eax
			inc ecx
			jmp .for

		..@continue1:
		inc eax
		inc ecx

		cmp ecx, [local(1)]
		jb .for

	
	.exit:
	
	cmp al, byte [max_number]
	ja .save
	jmp .stepn
	.save:
		mov byte [max_number], al

	.stepn:
	inc ebx
	mov byte [words_number], bl

	mov esp, ebp
	pop ebp
	ret


fill_zeros:
	push ebp
	mov ebp, esp
	sub esp, 12
	
	mov esi, [arg(1)]
	mov eax, [arg(2)]
	mov [local(1)], eax 		; rows
	mov eax, [arg(3)]
	mov [local(2)], eax 		; cols

	add esi, [local(2)]
	inc esi

	xor ecx, ecx

	.set_nl:
		mov byte [esi], nl 
		add esi, 16
		inc ecx
		cmp ecx, [local(1)]
		jbe .set_nl

	mov esi, [arg(1)]
	xor ebx, ebx
	xor ecx, ecx
	xor eax, eax

	.cycle:

		cmp ecx, [local(2)]
		je ..@next_row

		mov dl, byte [esi + ecx]
		cmp dl, 0
		je ..@change
		jmp ..@s1

		..@change:
			mov byte [esi + ecx], spc
		..@s1:
		cmp ecx, [local(2)]
		jb ..@next_char
		jmp .cycle

		..@next_char:
			inc ecx
			jmp .cycle

		..@next_row:
			inc ebx
			xor ecx, ecx
			add esi, 16
			cmp ebx, [local(1)]
			jbe .cycle
			jmp .exit

	.exit:
	mov esp, ebp
	pop ebp
	ret


save_to_file:

	push ebp
	mov ebp, esp
	sub esp, 12
	
	mov esi, [arg(1)]
	mov edx, [arg(2)]
	mov [local(1)], edx
	mov edx, [arg(3)]
	mov [local(2)], edx

	movzx ebx, byte [words_number]
	sub byte [max_number], 1
	xor ecx, ecx

	; write_file_from_buffer out_filename, fd, esi, 5

	; open_file [local(1)], O_APPEND
	; mov [local(2)], eax

	.cycle:
		o_console esi, ebx
		add esi, 16
		inc ecx
		cmp ecx, dword [max_number]
		jb .cycle

	mov esp, ebp
	pop ebp
	ret