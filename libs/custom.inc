%ifndef CUSTOM_INC
	%define CUSTOM_INC

	%define div_char	'='
	%define u(x)		__utf8__(x)

	%define sys_gettimeofday	78

	%macro allocate_unicode_string 2
		%1:		dw		u(%2)
	%endmacro

	%macro init_header 0

		; div_line:	times 78 db 0
		allocate_unicode_string req_fio, "Фимилия И.О.: "
		allocate_unicode_string	min_obr_h, "МИНИСТЕРСТВО ОБРАЗОВАНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ"
		allocate_unicode_string ulstu_h, "УЛЬЯНОВСКИЙ ГОСУДАРСТВЕННЫЙ ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ"
		allocate_unicode_string dept_h, "Кафедра вычислительной техники"
		allocate_unicode_string mop_h, "Машинно-ориентированное программирование"
		allocate_unicode_string lab_rab_h, "Лабораторная работа №1"
		allocate_unicode_string sname, "Сердитов Иван"
		allocate_unicode_string req1, "Замедлить время работы в тактах(-), ускорить время работы в тактах (+),"
		allocate_unicode_string req2, "вычислить функцию (f), выйти(ESC)?"
		allocate_unicode_string time_msg, "Время работы: "

		req_fio_len			equ		$-req_fio
		min_obr_h_len		equ		$-min_obr_h
		ulstu_h_len			equ		$-ulstu_h
		dept_h_len			equ		$-dept_h
		mop_h_len			equ		$-mop_h
		lab_rab_h_len		equ		$-lab_rab_h
		req1_len			equ		$-req1
		req2_len			equ		$-req2
		time_msg_len		equ		$-time_msg
		; dl_len				equ		$-div_line
		sname_len			equ		$-sname
		
	%endmacro

	%macro print_h 3

		; o_console div_line, dl_len
		o_console %1, %2
		o_console newline, 1

	%endmacro

	%macro print_header 0

		print_h req_fio, req_fio_len
		print_h min_obr_h, min_obr_h_len
		print_h ulstu_h, ulstu_h_len
		print_h dept_h, dept_h_len
		print_h mop_h, mop_h_len
		print_h lab_rab_h, lab_rab_h_len
		print_h sname, sname_len
		print_h req1, req1_len
		print_h req2, req2_len
		print_h time_msg, time_msg_len

	%endmacro

	%macro gettimeofday 3
		mov eax, sys_gettimeofday
		mov ebx, %2
		mov ecx, 0
		int 0x80

		push dword [%2]
		push dword [%3]

		pop dword [%1 + %1.tv_usec]
		pop dword [%1 + %1.tv_sec]
	%endmacro

	%macro get_interval 3

		push eax

		; sec interval
		mov eax, dword [%2 + %2.tv_sec]
		sub eax, dword [%1 + %1.tv_sec]
		mov dword [%3 + %3.tv_sec], eax

		; usec interval
		mov eax, dword [%2 + %2.tv_usec]
		sub eax, dword [%1 + %1.tv_usec]
		; mov dword [%3 + %3.tv_usec], eax

		cmp eax, 0
		jb %%adding
		jmp %%q
		
		%%adding:
			sub dword [%3 + %3.tv_sec], 1
			add eax, 1000000
			jmp %%q 

		%%q:
		pop eax

	%endmacro
%endif