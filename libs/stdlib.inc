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

	; io codes
	%define stdin         0
	%define stdout        1
	%define stderr        3


	; define stack args for calls
	%define arg(n)		ebp + (4 * n) + 4
	%define local(n)	ebp - (4 * n)


	; exit program
	%macro exit 0

		mov eax, sys_exit
		xor ebx, ebx
		syscall 

	%endmacro


	; std io msg in console
	; io_sys(msg, length, sys, std_io)
	%macro sys_io 4

		push eax
		push ebx
		push ecx
		push edx

		mov eax, %3
		mov ebx, %4

		mov ecx, %1
		mov edx, %2
		syscall

		pop eax
		pop ebx
		pop ecx
		pop edx

	%endmacro


	%macro o_console 2
		sys_io $1, $2, sys_write, stdout
	%endmacro

	%macro i_console 2
		sys_io $1, $2, sys_read, stdin
	%endmacro


	; fill buffer(src, dest, length)
	%macro fill_buffer 3

		push eax
		push ecx
		push edx
		push esi
		push edi

		mov eax, 0x30

		mov esi, %1
		mov edi, %2
		xor ecx, ecx

		call %%set_buf

		%%set_buf:
			mov edx, [esi + ecx]	; mov char value to edx
			sub edx, eax			; sub and get 0 or 1
			mov [edi + ecx], dl		; mov edx value to buffer
			inc ecx					; increase by 1
			cmp ecx, %3 			; if ecx below X_len 
			jb %%set_buf
			ret

		pop eax
		pop ecx
		pop edx
		pop esi
		pop edi

	%endmacro


	%macro invert 1

		mov eax, $1
		xor eax, 0xF
		sub eax, 0xE

	%endmacro

%endif