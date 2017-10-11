%ifndef STDLIB_INC
	%define STDLIB_INC

	; kernel calls
	%define sys_exit      	1
	%define sys_read      	3
	%define sys_write     	4
	%define sys_create    	8
	%define sys_open		5
	%define sys_close     	6
	%define sys_lseek		19     	
	%define sys_brk			46     	
	%define sys_newstat		106

	; file permissons
	%define O_RDONLY		0
	%define O_WRONLY		1
	%define O_RDWR			2
	%define O_APPEND		2001q

	; io codes
	%define stdin         0
	%define stdout        1
	%define stderr        3

	; define stack args for calls
	%define arg(n)		ebp + (4 * n) + 4
	%define local(n)	ebp - (4 * n)

	; macros for custom programs
	%define true		1
	%define false		0
	%define nl			0xA
	%define spc			0x20
	
	; %define get_index(array, i, j, len)	(array + len * i + j)
	%define sdots		0xB0
	%define mdots		0xB1
	%define ldots		0xB2
	%define digit(var)	(var - 0x30)
	%define sizeof(x) x %+ _size

	; exit program
	%macro exit 0
		mov eax, sys_exit
		xor ebx, ebx
		int 0x80
	%endmacro

	%macro error 1
		mov ebx, %1
		mov eax, sys_exit
		int 0x80
	%endmacro

	; std io msg in console
	; io_sys(msg, length, sys, std_io)
	%macro sys_io 4
		mov eax, %3
		mov ebx, %4

		mov ecx, %1
		mov edx, %2
		int 0x80
	%endmacro

	%macro o_console 2
		sys_io %1, %2, sys_write, stdout
	%endmacro

	%macro i_console 2
		sys_io %1, %2, sys_read, stdin
	%endmacro

	%macro open_file 2
		sys_io 0,%2,sys_open,%1
	%endmacro

	%macro read_file 3
		sys_io %1,%2,sys_read,%3
	%endmacro

	%macro write_file 3
		sys_io %1,%2,sys_write,%3
	%endmacro

	%macro sync_file 1
		mov ebx, %1
		mov eax, 36
		int 0x80
	%endmacro

	%macro close_file 1
		mov ebx, %1
		mov eax, sys_close
		int 0x80
	%endmacro

	%macro free_memory 1
		mov ebx, %1
		mov eax, sys_brk
		int 0x80
	%endmacro

	%macro newstat 2
		mov ebx, %1
		mov ecx, %2
		mov eax, sys_newstat
		int 0x80
	%endmacro

	%macro brk 1
		mov ebx, %1
		mov eax, sys_brk
		int 0x80		
	%endmacro

	%macro read_file_to_buffer 4
		open_file %1, O_RDONLY
		mov [%2], eax
		read_file %3,%4,[%2]
		close_file [%2]
	%endmacro

	%macro write_file_from_buffer 4
		open_file %1, O_APPEND
		mov [%2], eax
		write_file %3,%4,[%2]
		sync_file [%2]
		close_file [%2]
	%endmacro

	; fill buffer(src, dest, length)
	%macro fill_buffer 3

		mov esi, %1
		mov edi, %2
		mov ebx, %3
		xor ecx, ecx


		jmp %%set_buf

		%%set_buf:
			mov dl, byte [esi + ecx]	; mov char value to edx
			sub dl, 0x30			; sub and get 0 or 1
			mov byte [edi + ecx], dl		; mov edx value to buffer
			inc ecx					; increase by 1
			cmp ecx, ebx 			; if ecx below X_len 
			jbe %%set_buf

	%endmacro

	%macro buffer_to_acsii 2

		mov esi, %1
		mov ebx, %2
		xor ecx, ecx

		jmp %%for

		%%for:
			; mov dl, byte [esi + ecx]
			; add dl, 0x30
			; mov byte [esi + ecx], dl
			add byte [esi + ecx], 0x30
			inc ecx
			cmp ecx, ebx
			jbe %%for

	%endmacro

	%macro buffer_to_char 3
		mov esi, %1
		xor ecx, ecx

		jmp %%for

		%%for:
			mov byte [esi + ecx], %3
			inc ecx
			cmp ecx, %2
			jbe %%for

	%endmacro

	%macro invert 0-1
		mov eax, %1
		xor eax, 1
	%endmacro

	%macro pcall1 2
		push %2
		call %1
		add esp, 4
	%endmacro

	%macro pcall2 3
		push %3
		push %2
		call %1
		add esp, 8
	%endmacro

	%macro pcall3 4
		push %4
		push %3
		push %2
		call %1
		add esp, 12
	%endmacro

	%macro pcall4 5
		push %5
		push %4
		push %3
		push %2
		call %1
		add esp, 16
	%endmacro

	%macro allocate_array2d_byte 3
		%1	resb	%2 * %3
	%endmacro

	%macro allocate_array_byte 2
		%1	resb	%2
	%endmacro

	%macro isdigit 1
		xor eax, eax
		xor edx, edx
		mov dl, %1
		sub dl, 0x30
		cmp dl, 9
		jbe %%ns
		
		jmp %%exit

		%%ns:
			cmp dl, 0
			jae %%ls
			jmp %%exit

		%%ls:
			mov eax, true
		
		%%exit:

	%endmacro



%endif