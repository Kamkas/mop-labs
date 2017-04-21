section .data
	refl_msg			db		"Reflective: "
	refl_msg_len		equ		$-refl_msg

	anti_refl_msg		db		"Anti-reflective: "
	anti_refl_msg_len 	equ		$-anti_refl_msg
	
	simm_msg			db		"Simmetric: "
	simm_msg_len		equ		$-simm_msg
	
	asimm_msg			db		"A-simmetric: "
	asimm_msg_len		equ		$-asimm_msg
	
	anti_simm_msg		db		"Anti-simmetric: "
	anti_simm_msg_len	equ		$-anti_simm_msg

	newline				db 		nl

	in_filename			db 		"input",0

section .bss
	allocate_array2d_byte buffer,80,80
	buf_len				equ		$-buffer

	allocate_array_byte refl,1
	allocate_array_byte anti_refl,1
	allocate_array_byte simm,1
	allocate_array_byte asimm,1
	allocate_array_byte anti_simm,1

	allocate_array_byte rows,1
	allocate_array_byte cols,1

	allocate_array_byte fd,1
section .text
	global _start


_start:
	
	read_file_to_buffer in_filename, fd, buffer, buf_len

	pcall1 get_rows_and_cols, buffer

	movzx ecx, byte [rows]
	pcall2 check_for_refl, buffer, ecx
	
	movzx ecx, byte [rows]
	pcall3 check_for_simm, buffer, ecx, ecx

	movzx ecx, byte [rows]
	pcall3 check_for_antisimm, buffer, ecx, ecx

	call check_for_asimm

	o_console refl_msg, refl_msg_len
	o_console refl, 1
	o_console newline, 1

	o_console anti_refl_msg, anti_refl_msg_len
	o_console anti_refl, 1
	o_console newline, 1

	o_console simm_msg, simm_msg_len
	o_console simm, 1
	o_console newline, 1

	o_console anti_simm_msg, anti_simm_msg_len
	o_console anti_simm, 1
	o_console newline, 1
	
	o_console asimm_msg, asimm_msg_len
	o_console asimm, 1
	o_console newline, 1

	exit

get_rows_and_cols:
	push ebp
	mov ebp, esp
	sub esp, 4
	
	mov esi, [arg(1)]
	xor ecx, ecx

	.cycle_rows:
		mov dl, byte[esi + ecx]
		cmp dl, nl
		je ..@save_rows

		inc ecx
		cmp ecx, 80
		jb .cycle_rows

		..@save_rows:
			mov byte [rows], cl
			mov byte [cols], cl
			xor ecx, ecx
			jmp .exit

	.exit:
	mov esp, ebp
	pop ebp
	ret		


check_for_refl:
	push ebp
	mov ebp, esp
	sub esp, 8

	mov esi, [arg(1)]
	mov ebx, [arg(2)]
	mov [local(1)], ebx
	inc ebx

	xor ecx, ecx

	mov dl, byte [esi]

	cmp dl, 0x31
	je .refl

	cmp dl, 0x30
	je .antirefl
	jmp .exit

	.refl:

		and dl, byte [esi + ecx]

		cmp dl, 0x31
		jne .break

		add esi, ebx
		inc ecx
		cmp ecx, [local(1)]
		jb .refl

		mov byte [refl], 0x31
		mov byte [anti_refl], 0x30
		jmp .exit

	.antirefl:

		or dl, byte [esi + ecx]

		cmp dl, 0x30
		jne .break

		add esi, ebx
		inc ecx
		cmp ecx, [local(1)]
		jb .antirefl

		mov byte [refl], 0x30
		mov byte [anti_refl], 0x31
		jmp .exit

	.break:
		mov byte [refl], 0x30
		mov byte [anti_refl], 0x30
		jmp .exit


	.exit:
	mov esp, ebp
	pop ebp
	ret


check_for_simm:

	push ebp
	mov ebp, esp
	sub esp, 12
	
	mov esi, [arg(1)]
	mov eax, [arg(2)]
	mov [local(1)], eax
	mov eax, [arg(3)]
	mov [local(2)], eax
	mov [local(3)], eax
	add dword [local(3)], 1
	; inc eax

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	inc ecx

	.cycle:
		add eax, [local(3)]
		mov dl, byte [esi + ecx]
		and dl, byte [esi + eax]
		cmp dl, 0x31
		je ..@stepn

		mov dl, byte [esi + ecx]
		xor dl, byte [esi + eax]
		cmp dl, 1
		jne ..@stepn
		
		jmp .break
		
		..@stepn:
			inc ecx
			cmp ecx, [local(2)]
			jb .cycle
			jmp ..@next_step

		..@next_step:
			inc ebx
			sub dword [local(2)], 1
			xor ecx, ecx
			inc ecx
			add esi, [local(1)]
			add esi, 2
			xor eax, eax

			cmp ebx, [local(1)]
			jb .cycle

			mov byte [simm], 0x31
			jmp .exit


	.break:
	mov byte [simm], 0x30

	.exit:
	mov esp, ebp
	pop ebp
	ret


check_for_antisimm:

	push ebp
	mov ebp, esp
	sub esp, 12
	
	mov esi, [arg(1)]
	mov eax, [arg(2)]
	mov [local(1)], eax
	mov eax, [arg(3)]
	mov [local(2)], eax
	mov [local(3)], eax
	add dword [local(3)], 1
	; inc eax

	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	inc ecx

	.cycle:
		add eax, [local(3)]
		mov dl, byte [esi + ecx]
		xor dl, byte [esi + eax]
		cmp dl, 1
		je ..@stepn1

		mov dl, byte [esi + ecx]
		and dl, byte [esi + eax]
		cmp dl, 0x31
		jne ..@stepn1
		
		jmp .break
		
		..@stepn1:
			inc ecx
			cmp ecx, [local(2)]
			jb .cycle
			jmp ..@next_step1

		..@next_step1:
			inc ebx
			sub dword [local(2)], 1
			xor ecx, ecx
			inc ecx
			add esi, [local(1)]
			add esi, 2
			xor eax, eax

			cmp ebx, [local(1)]
			jb .cycle

			mov byte [anti_simm], 0x31
			jmp .exit


	.break:
	mov byte [anti_simm], 0x30

	.exit:
	mov esp, ebp
	pop ebp
	ret

check_for_asimm:
	push ebp
	mov ebp, esp

	mov dl, byte [anti_refl]
	and dl, byte [anti_simm]
	mov byte [asimm], dl

	mov esp, ebp
	pop ebp
	ret