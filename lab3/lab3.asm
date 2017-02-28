section .data
	refl_msg			db		"Reflective: ",0,nl
	refl_msg_len		equ		$-refl_msg

	anti_refl_msg		db		"Anti-reflective: ",0,nl
	anti_refl_msg_len 	equ		$-anti_refl_msg
	
	simm_msg			db		"Simmetric: ",0,nl
	simm_msg_len		equ		$-simm_msg
	
	asimm_msg			db		"A-simmetric: ",0,nl
	asimm_msg_len		equ		$-asimm_msg
	
	anti_simm_msg		db		"Anti-simmetric: ",0,nl
	anti_simm_msg_len	equ		$-anti_simm_msg

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
			; jmp .cycle_cols
			jmp .exit

	; .cycle_cols:
	; 	push eax
	; 	push ecx
		
	; 	mov eax, ecx
		
	; 	sal ecx, 6
	; 	sal eax, 4
	; 	add ecx, eax

	; 	mov dl, byte [esi + ecx]

	; 	pop ecx
	; 	pop eax

	; 	cmp dl, 0
	; 	je ..@save_cols

	; 	inc ecx
	; 	cmp ecx, 80
	; 	jb .cycle_cols

	; 	..@save_cols:
	; 		mov byte [cols], cl
	; 		jmp .check


	; .check:
		; push eax
		; push ebx
		; sub byte [cols], 1
		; movzx eax, byte [rows]
		; cmp al, byte [cols] 
		; pop ebx
		; pop eax
		; jne .error
		; jmp .exit

	; .error:
		; exit

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

	mov eax, 1
	xor ebx, ebx
	; xor ecx, ecx

	.for_rows:
		xor ecx, ecx

		..@for_cols:

			cmp ecx, dword [local(1)]
			jnb ..@inc_cols

			cmp ecx, ebx
			je ..@contiunue

			push ecx
			push ebx
			push ebx

			mov ebx, ecx
			sal ebx, 6
			sal ecx, 4
			add ecx, ebx

			pop ebx
			add ebx, ecx
	
			mov dl, byte [esi + ebx]
	
			pop ebx		
			pop ecx

			; mov dl, byte [get_index(esi, ecx, ebx, 80)]
			cmp dl, 1
			je ..@next

			cmp dl, 0
			jz ..@contiunue

			..@next:

				push ecx
				push ebx
				push ecx

				mov ebx, ecx
				sal ebx, 6
				sal ecx, 4
				add ebx, ecx

				pop ecx
				add ebx, ecx
	
				and dl, byte [esi + ebx]
	
				pop ebx		
				pop ecx

				; and dl, byte [get_index(esi, ebx, ecx, 80)]
				cmp dl, 1
				je ..@contiunue

				xor eax, eax
				cmp dl, 0
				je .exit


			..@contiunue:
				inc ecx
				jmp ..@for_cols	

		..@inc_cols:
			inc ebx
			cmp ebx, dword [local(2)]
			jb .for_rows

	.exit:
	mov esp, ebp
	pop ebp
	ret


check_for_antisimm:
	
	push ebp
	mov ebp, esp
	sub esp, 8
	
	mov esi, [arg(1)]
	mov eax, [arg(2)]
	mov [local(1)], eax
	mov eax, [arg(3)]
	mov [local(2)], eax

	mov eax, 1
	xor ebx, ebx

	.for_rows:
		xor ecx, ecx

		..@for_cols1:

			cmp ecx, dword [local(1)]
			jnb ..@inc_cols1

			cmp ecx, ebx
			je ..@contiunue1

			push ecx
			push ebx
			push ebx

			mov ebx, ecx
			sal ebx, 6
			sal ecx, 4
			add ecx, ebx

			pop ebx
			add ebx, ecx
	
			mov dl, byte [esi + ebx]
	
			pop ebx		
			pop ecx

			; mov dl, byte [get_index(esi, ecx, ebx, 80)]
			cmp dl, 1
			je ..@next1

			cmp dl, 0
			jz ..@contiunue1

			..@next1:
				push ecx
				push ebx
				push ecx

				mov ebx, ecx
				sal ebx, 6
				sal ecx, 4
				add ebx, ecx

				pop ecx
				add ebx, ecx
	
				xor dl, byte [esi + ebx]
	
				pop ebx		
				pop ecx

				; xor dl, byte [get_index(esi, ebx, ecx, 80)]
				cmp dl, 1
				je ..@contiunue1

				xor eax, eax
				cmp dl, 0
				je .exit


			..@contiunue1:
				inc ecx
				jmp ..@for_cols1	

		..@inc_cols1:
			inc ebx
			cmp ebx, dword [local(2)]
			jb .for_rows


	.exit:
		mov esp, ebp
		pop ebp
		ret


check_for_asimm:
	push ebp
	mov ebp, esp
	sub esp, 8

	mov dl, byte [anti_refl]
	and dl, byte [anti_simm]
	mov dl, byte [asimm]

	mov esp, ebp
	pop ebp
	ret