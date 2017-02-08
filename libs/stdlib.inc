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

	struc STAT
	    .st_dev:        resd 1
	    .st_ino:        resd 1   
	    .st_mode:       resw 1   
	    .st_nlink:      resw 1   
	    .st_uid:        resw 1   
	    .st_gid:        resw 1   
	    .st_rdev:       resd 1       
	    .st_size:       resd 1   
	    .st_blksize:    resd 1   
	    .st_blocks:     resd 1   
	    .st_atime:      resd 1   
	    .st_atime_nsec: resd 1   
	    .st_mtime:      resd 1   
	    .st_mtime_nsec: resd 1
	    .st_ctime:      resd 1   
	    .st_ctime_nsec: resd 1   
	    .unused4:       resd 1   
	    .unused5:       resd 1   
	endstruc

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
	%define get_index(array, i, j)	(array + i * j)
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
		sys_io $1, $2, sys_write, stdout
	%endmacro

	%macro i_console 2
		sys_io $1, $2, sys_read, stdin
	%endmacro

	%macro open_file 2-4
		sys_io $2,0x0,sys_open,$1
		cmp eax, 0x0
		je %%error
		%%error:
			exit
	%endmacro

	%macro read_file 2-4
		sys_io $1,$2,sys_read,$3
	%endmacro

	%macro close_file 1
		mov ebx, $1
		mov eax, sys_close
		int 0x80
	%endmacro

	%macro free_memory 1
		mov ebx, $1
		mov eax, sys_close
		int 0x80
	%endmacro

	%macro newstat 2
		mov ebx, $1
		mov ecx, $2
		mov eax, sys_newstat
		int 0x80
	%endmacro

	%macro brk 1
		mov ebx, $1
		mov eax, sys_brk
		int 0x80		
	%endmacro

	%macro read_file_to_buffer 2-6
		newstat $1,$2
		brk 0x0

		mov [$3], eax
		mov [$4], eax
		mov ebx, eax

		add ebx, [$2 + STAT.st_size]
		brk ebx

		open_file $1,$3
		xchg eax, esi

		read_file [$4], dword [$2 + STAT.st_size], esi
		close_file esi
		free_memory [$3]
	%endmacro

	; fill buffer(src, dest, length)
	%macro fill_buffer 3

		mov esi, %1
		mov edi, %2
		xor ecx, ecx

		jmp %%set_buf

		%%set_buf:
			mov dl, byte [esi + ecx]	; mov char value to edx
			sub dl, 0x30			; sub and get 0 or 1
			mov byte [edi + ecx], dl		; mov edx value to buffer
			inc ecx					; increase by 1
			cmp ecx, %3 			; if ecx below X_len 
			jb %%set_buf

	%endmacro

	%macro buffer_to_acsii 2

		mov esi, %1
		xor ecx, ecx
		xor edx, edx

		jmp %%for

		%%for:
			mov dl, byte [esi + ecx]
			add dl, 0x30
			mov byte [esi + ecx], dl
			inc ecx
			cmp ecx, %2
			jb %%for

	%endmacro

	%macro invert 0-1
		mov eax, %1
		xor eax, 0xF
		sub eax, 0xE
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
		$1	resb	$2 * $3
	%endmacro

	%macro allocate_array_byte 2
		$1	resb	$2
	%endmacro

	%macro isdigit 1
		xor eax, eax
		cmp $1, 0x0
		jae %%ns
		
		%%ns:
			cmp $1, 0x9
			jbe %%ls
			ret

		%%ls:
			mov eax, 0x1
			ret

	%endmacro

%endif