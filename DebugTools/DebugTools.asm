;******************************************************************************
GLOBAL dspreg, dsprex, dspxmm, dspymm, dmphex, dmpreg, dmprex, dmpxmm, dmpymm
GLOBAL dmphexrsi, dmphexold
GLOBAL quit, msg

 
;------------------ DEBUG TOOLS -----------------------------------------------
;	<dspstr> display string, code inline operands
;	<dmpreg> dump registers rax..
;	<dmprex> dump registers r08..r15
;	<dmpxmm> dump registers xmm0..xmm15
;	<dmphex> dump memory, call dsphex, dq address will print out 0x40 bytes
;	<dspreg> display rnx, e.g. call dspreg, db "rbp"
;	copyright 2020 hans wijnands
;----------------------------------------------------


;----------------------------------------------------
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;                            EBNF Debug tools
; dspebnf shows the status of the EBNF parser:
; line 1	pOK = True/False	InEnd = True/False
; line 2..5 	hex dump sIn up to <InPnt>
; line 7..10	hex dump sIn as from <InPnt>
; line 11 ..12  LastIn pointer & length
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

SECTION .text

;******************************************************************************
dspreg: 	; usage
		;   call dspreg
		;    db "rax"  ; rbx, rcx, rdx, rcx, rsi, rdi also supported
;******************************************************************************
	pushf		; 64
	push rax	; 56
	push rbx	; 48
	push rcx	; 40
	push rdx	; 32
	push rsi	; 24
	push rdi	; 16
	push rbp	; 8
	push rsp	; 0

	mov rbp, [rsp+72]
	mov rax, [rbp]
	add qword [rsp+72], 03
	and rax, 0xFFFFFF

	 cmp rax, "rax"
	 jne dspreg1
	 mov rbx, [rsp+56]
	 jmp dspreg0
dspreg1: cmp rax, "rbx"
	 jne dspreg2
	 mov rbx, [rsp+48]
	 jmp dspreg0
dspreg2: cmp rax, "rcx"
	 jne dspreg3	 
	 mov rbx, [rsp+40]
	 jmp dspreg0
dspreg3: cmp rax, "rdx"
	 jne dspreg4
	 mov rbx, [rsp+32]
	 jmp dspreg0
dspreg4: cmp rax, "rsi"
	 jne dspreg5
	 mov rbx, [rsp+24]
	 jmp dspreg0
dspreg5: cmp rax, "rdi"
	 jne dspreg6
	 mov rbx, [rsp+16]
	 jmp dspreg0
dspreg6: cmp rax, "rbp"
	 jne dspreg7
	 mov rbx, [rsp+8]
	 jmp dspreg0
dspreg7: cmp rax, "flg"
	 jne dspreg8
	 mov rbx, [rsp+64]
	 jmp dspreg0
dspreg8: cmp rax, "rsp"
	 jne dspregerr
	 mov rbx, [rsp]
	 add rbx, 0x48
;	 jmp dspreg0
	 
dspreg0:
	mov rdi, sOutDmp
	cld
	stosd
	mov byte [rdi-1],":"
	mov byte [rdi+8],"-"
	mov byte [rdi+17],10

	push rbx
	mov eax,[rsp]
	mov rdi,21
	call inthex
	mov eax,[rsp+4]
	mov rdi,12
	call inthex
	pop rbx
	
	mov rax,1
	mov rdi,1
	mov rsi, sOutDmp
	mov rdx, 22
	push r11
	syscall
	pop r11

	pop rsp
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	popf
	ret
dspregerr:
	call msg		
	 db 18,10, "Unknown register", 10

 	mov rdi, 21		; 0 = success exit code
	mov rax, 60		; 60 = exit
	syscall	; quit  

;******************************************************************************
dsprex: 	; usage
		;   call dsprex
		;    db "r08"  ; r09 ..r15 also supported
;******************************************************************************
	pushf		; 64
	push rax	; 56
	push rbx	; 48
	push rcx	; 40
	push rdx	; 32
	push rsi	; 24
	push rdi	; 16
	push rbp	; 8
	push rsp	; 0
	
	mov rbp, [rsp+72]
	mov rax, [rbp]
	add qword [rsp+72], 03
	and rax, 0xFFFFFF

	 cmp rax, "r08"
	 jne dsprex1
	 mov rbx, r8
	 jmp dsprex0
dsprex1: cmp rax, "r09"
	 jne dsprex2
	 mov rbx, r9
	 jmp dsprex0
dsprex2: cmp rax, "r10"
	 jne dsprex3	 
	 mov rbx, r10
	 jmp dsprex0
dsprex3: cmp rax, "r11"
	 jne dsprex4
	 mov rbx, r11
	 jmp dsprex0
dsprex4: cmp rax, "r12"
	 jne dsprex5
	 mov rbx, r12
	 jmp dsprex0
dsprex5: cmp rax, "r13"
	 jne dsprex6
	 mov rbx, r13
	 jmp dsprex0
dsprex6: cmp rax, "r14"
	 jne dsprex7
	 mov rbx, r14
	 jmp dsprex0
dsprex7: cmp rax, "r15"
	 jne dspregerr
	 mov rbx, r15
	 
dsprex0:
	mov rdi, sOutDmp
	cld
	stosd
	mov byte [rdi-1],":"
	mov byte [rdi+8],"-"
	mov byte [rdi+17],10

	push rbx
	mov eax,[rsp]
	mov rdi,21
	call inthex
	mov eax,[rsp+4]
	mov rdi,12
	call inthex
	pop rbx
	
	mov rax,1
	mov rdi,1
	mov rsi, sOutDmp
	mov rdx, 22
	push r11
	syscall
	pop r11

	pop rsp
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax

	popf
	ret

;--------------------------------------
dmprex:
	call dsprex
	 db "r08"
	call dsprex
	 db "r09"
	call dsprex
	 db "r10"
	call dsprex
	 db "r11"
	call dsprex
	 db "r12"
	call dsprex
	 db "r13"
	call dsprex
	 db "r14"
	call dsprex
	 db "r15"
	ret
;******************************************************************************
dspxmm: 	; usage
		;   call dspxmm
		;    db "0"  ; "1" .. "f"
;******************************************************************************
	pushf		; 64
	push rax	; 56
	push rbx	; 48
	push rcx	; 40
	push rdx	; 32
	push rsi	; 24
	push rdi	; 16
	push rbp	; 8
	push rsp	; 0
	
	mov rbp, [rsp+72]
	
	mov al, [rbp]
	inc qword [rsp+72]
	and rax, 0xFF

	sub rsp, 16
	
	 cmp rax, "0"
	 jne dspxmm1
	 movdqu [rsp], xmm0
	 jmp dspxmm0
dspxmm1: cmp rax, "1"
	 jne dspxmm2
	 movdqu [rsp], xmm1
	 jmp dspxmm0
dspxmm2: cmp rax, "2"
	 jne dspxmm3	 
	 movdqu [rsp], xmm2
	 jmp dspxmm0
dspxmm3: cmp rax, "3"
	 jne dspxmm4
	 movdqu [rsp], xmm3
	 jmp dspxmm0
dspxmm4: cmp rax, "4"
	 jne dspxmm5
	 movdqu [rsp], xmm4
	 jmp dspxmm0
dspxmm5: cmp rax, "5"
	 jne dspxmm6
	 movdqu [rsp], xmm5
	 jmp dspxmm0
dspxmm6: cmp rax, "6"
	 jne dspxmm7
	 movdqu [rsp], xmm6
	 jmp dspxmm0
dspxmm7: cmp rax, "7"
	 jne dspxmm8
	 movdqu [rsp], xmm7
	 jmp dspxmm0
; ----
dspxmm8: cmp rax, "8"
	 jne dspxmm9
	 movdqu [rsp], xmm8
	 jmp dspxmm0
dspxmm9: cmp rax, "9"
	 jne dspxmma
	 movdqu [rsp], xmm9
	 jmp dspxmm0
dspxmma: cmp rax, "a"
	 jne dspxmmb	 
	 movdqu [rsp], xmm10
	 jmp dspxmm0
dspxmmb: cmp rax, "b"
	 jne dspxmmc
	 movdqu [rsp], xmm11
	 jmp dspxmm0
dspxmmc: cmp rax, "c"
	 jne dspxmmd
	 movdqu [rsp], xmm12
	 jmp dspxmm0
dspxmmd: cmp rax, "d"
	 jne dspxmme
	 movdqu [rsp], xmm13
	 jmp dspxmm0
dspxmme: cmp rax, "e"
	 jne dspxmmf
	 movdqu [rsp], xmm14
	 jmp dspxmm0
dspxmmf: cmp rax, "f"
	 jne dspregerr
	 movdqu [rsp], xmm15
; ---- 
dspxmm0:
	mov rdi, sOutDmp
	cld
	shl rax, 16
	mov ax, "xm"
	stosd
	mov byte [rdi- 1],":"
	mov byte [rdi+ 8],"-"
	mov byte [rdi+17]," "
	mov byte [rdi+26],"-"
	mov byte [rdi+35],10

	mov eax,[rsp]
	mov rdi,39	;21
	call inthex
	mov eax,[rsp+4]
	mov rdi,30	;12
	call inthex

	mov eax,[rsp+8]
	mov rdi,21	;39
	call inthex
	mov eax,[rsp+12]
	mov rdi,12	;30
	call inthex

	add rsp, 16	

	mov rax,1
	mov rdi,1
	mov rsi, sOutDmp
	mov rdx, 40
	push r11
	syscall
	pop r11

	pop rsp
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax

	popf
	ret
;--------------------------------------
dmpxmm:
	call dspxmm
	 db "0"
	call dspxmm
	 db "1"
	call dspxmm
	 db "2"
	call dspxmm
	 db "3"
	call dspxmm
	 db "4"
	call dspxmm
	 db "5"
	call dspxmm
	 db "6"
	call dspxmm
	 db "7"
	call dspxmm
	 db "8"
	call dspxmm
	 db "9"
	call dspxmm
	 db "a"
	call dspxmm
	 db "b"
	call dspxmm
	 db "c"
	call dspxmm
	 db "d"
	call dspxmm
	 db "e"
	call dspxmm
	 db "f"
	ret

;******************************************************************************
dspymm: 	; usage
		;   call dspymm
		;    db "0"  ; "1" .. "7" also supported
;******************************************************************************
	pushf		; 64
	push rax	; 56
	push rbx	; 48
	push rcx	; 40
	push rdx	; 32
	push rsi	; 24
	push rdi	; 16
	push rbp	; 8
	push rsp	; 0
	
	mov rbp, [rsp+72]
	
	mov al, [rbp]
	inc qword [rsp+72]
	and rax, 0xFF

	sub rsp, 32
	
	 cmp rax, "0"
	 jne dspymm1
	 vmovdqu [rsp], ymm0
	 jmp dspymm0
dspymm1: cmp rax, "1"
	 jne dspymm2
	 vmovdqu [rsp], ymm1
	 jmp dspymm0
dspymm2: cmp rax, "2"
	 jne dspymm3	 
	 vmovdqu [rsp], ymm2
	 jmp dspymm0
dspymm3: cmp rax, "3"
	 jne dspymm4
	 vmovdqu [rsp], ymm3
	 jmp dspymm0
dspymm4: cmp rax, "4"
	 jne dspymm5
	 vmovdqu [rsp], ymm4
	 jmp dspymm0
dspymm5: cmp rax, "5"
	 jne dspymm6
	 vmovdqu [rsp], ymm5
	 jmp dspymm0
dspymm6: cmp rax, "6"
	 jne dspymm7
	 vmovdqu [rsp], ymm6
	 jmp dspymm0
dspymm7: cmp rax, "7"
	 jne dspregerr
	 vmovdqu [rsp], ymm7
	 
dspymm0:
	mov rdi, sOutDmp
	cld
	shl rax, 16
	mov ax, "ym"
	stosd
	mov byte [rdi- 1],":"
	mov byte [rdi+ 8],"-"
	mov byte [rdi+17]," "
	mov byte [rdi+26],"-"
	mov byte [rdi+35]," "
	mov byte [rdi+44],"-"
	mov byte [rdi+53]," "
	mov byte [rdi+62],"-"
	mov byte [rdi+71],10

	mov eax,[rsp]
	mov rdi,21
	call inthex
	mov eax,[rsp+4]
	mov rdi,12
	call inthex

	mov eax,[rsp+8]
	mov rdi,39
	call inthex
	mov eax,[rsp+12]
	mov rdi,30
	call inthex
	
	mov eax,[rsp+16]
	mov rdi,57
	call inthex
	mov eax,[rsp+20]
	mov rdi,48
	call inthex

	mov eax,[rsp+24]
	mov rdi,75
	call inthex
	mov eax,[rsp+28]
	mov rdi,66
	call inthex

	add rsp, 32	

	mov rax,1
	mov rdi,1
	mov rsi, sOutDmp
	mov rdx, 76
	push r11
	syscall
	pop r11

	pop rsp
	pop rbp
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax

	popf
	ret
;--------------------------------------
dmpymm:
	call dspymm
	 db "0"
	call dspymm
	 db "1"
	call dspymm
	 db "2"
	call dspymm
	 db "3"
	call dspymm
	 db "4"
	call dspymm
	 db "5"
	call dspymm
	 db "6"
	call dspymm
	 db "7"
	ret
; -----------------------------------------------------------------------------	
MessageOld:
	pop rsi
	xor rax, rax
	cld
	lodsb		; rsi points now to string	ready for syscall
	mov rdx, rax	; rdx = length string,		ready for syscall
	mov rdi, rsi
	add rdi, rdx
	push rdi	; return address
	push rcx	; retain rcx=rPOk
	mov rax,1
	mov rdi,1
	push r11
	syscall
	pop r11
	pop rcx
	ret
	
msg:			; offset to rsp0
	push rax	; -8
	push rcx	; -16
	push rdx	; -24
	push rsi	; -32
	push rdi	; -40
	push r11 	; -48
	pushf 		; -56
	
	mov rsi, [rsp+ 56]
	xor rax, rax
	cld
	lodsb		; rsi points now to string	ready for syscall
	mov rdx, rax	; rdx = length string,		ready for syscall
	inc rax		; step also over len byte
	add [rsp+56], rax ; adapt return address
	mov rax,1
	mov rdi,1
	syscall
	
	popf
	pop r11
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rax
	ret
	
;******************************************************************************
dspstr: ; <call dspstr> <dd len>  <dq add>
;	.text	call	dmphex
;	 	 dd	lsEBNF
;	 	 dq	sEBNF
;******************************************************************************
	push rax
	push rcx
	push rsi
	push rdi
	push rdx

   	mov rax, 1	; 1 = write
	mov rdi, 1	; 1 = to stdout
	mov rdx, [rsp+40]	; get pntr after the call instr
	mov rsi, [rdx+4]	; get string add next 4 but 
	mov edx, [rdx]		; get length; destroying rdx so don't use for more inline operands
	add qword [rsp+40], 12	; correct return stack (dd+dq=12b)
	push r11
	syscall
	pop r11		; display the string, what is syscall using actually? if a real call,
 			; then we can jmp and skip ret
 	pop rdx
 	pop rdi
 	pop rsi
 	pop rcx
 	pop rax
 	ret
 
;----------------------------------------------------
dmphexrsi:		;dump memory,
; syntax: call dmphex with rsi as start address 40 bytes will be displayed
;----------------------------------------------------
	pushf
	push rsi
	push rdi
	mov rdi, rsi
 	add rdi, 0x40
 	call dmphexold
 	pop rdi
 	pop rsi
 	popf
 	ret

;----------------------------------------------------
dmphex10:	;dump memory, syntax: call dmphex dq add, with add as start address
		;10 bytes will be displayed
;----------------------------------------------------
	pushf
	push rsi
	push rdi
	mov rsi, [rsp+24]
	mov rsi, [rsi]

	add qword [rsp+24],08
	mov rdi, rsi
 	add rdi, 0x10

 	call dmphexold

 	pop rdi
 	pop rsi
 	popf
 	ret

;----------------------------------------------------
dmphex:		;dump memory, syntax: call dmphex dq add, with add as start address
		;40 bytes will be displayed
;----------------------------------------------------
	pushf
	push rsi
	push rdi
	mov rsi, [rsp+24]
	mov rsi, [rsi]

	add qword [rsp+24],08
	mov rdi, rsi
 	add rdi, 0x40

 	call dmphexold

 	pop rdi
 	pop rsi
 	popf

 	ret
 
 ;----------------------------------------------------
dmphexold:		;dump memory, syntax: call dmphex with rsi as begin and rdi as end address
;----------------------------------------------------


	push rax
	push rbx
	push rcx
	push rdx
	push rdi
	push rsi
	
	cld		;mov the table to bss
	mov ecx, 85
	mov esi, aHxDmp
	mov edi, sOutDmp
	rep movsb

dmphex1:
	mov	eax, [rsp+4]
	mov	edi,8
	call	inthex		; dmp high address
	mov	eax, [rsp]
	mov	edi,17
	call	inthex		; low address

	mov	rdi, [rsp]	; first 8 bytes
	mov	rax, [rdi]
	mov	edi,20
	call	b8hex
	mov	rdi, [rsp]	; next 8 bytes
	mov	rax, [rdi+8]
	mov	edi,44
	call	b8hex

	mov	rdi, [rsp]	; first 8 bytes
	mov	rax, [rdi]
	mov	edi,67
	call	b8chr
	mov	rdi, [rsp]	; next 8 bytes
	mov	rax, [rdi+8]
	mov	edi,76
	call	b8chr

dmphex2:
	mov rax, 1	; 1 = write
	mov rdi, 1	; 1 = to stdout
	mov rsi, sOutDmp	; string to display in rsi
	mov rdx, 85	; length of the string
	push r11
	syscall
	pop r11	; display the string
	
	pop	rax	; pop start address
	add	rax, 16
	push	rax
	cmp	rax, [rsp+8]	; cmp to end address
	jb	dmphex1

	pop rsi
	pop rdi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret
 ;----------------------------------------------------
 ;	<dmpreg> dump registers	
 ;----------------------------------------------------
dmpreg:
	pushfq			;68 64 position on stack later

	push	rsp		;60 56
	push	rbp		;52 48
	push	rsi		;44 40
	push	rdi		;36 32

	push	rax		;28 24
	push	rbx		;20 16
	push	rcx		;12 8
	push	rdx		;4  0

	cld			;mov the table to bss
	mov ecx, 352
	mov esi, acDsp
	mov edi, sOutDmp
	rep movsb

	mov eax, [rsp+28]	;get rax Upper Half
		mov edi, 12
		call	inthex
		mov eax, [rsp+24]	;get rax LH
		mov edi, 21
		call	inthex
		
	mov eax, [rsp+20]	;get rbx Upper Half
		mov edi, 34
		call	inthex
		mov eax, [rsp+16]	;get rbx LH
		mov edi, 43
		call	inthex
		 
	mov eax, [rsp+12]	;get rcx Upper Half
		mov edi, 56
		call	inthex
		mov eax, [rsp+8]	;get rcx LH
		mov edi, 65
		call	inthex
		
	mov eax, [rsp+4]	;get rdx Upper Half
		mov edi, 78
		call	inthex
		mov eax, [rsp+0]	;get rdx LH
		mov edi, 87
		call	inthex
			
	mov eax, [rsp+60]	;get rsp Upper Half
		mov edi, 100
		call	inthex
		mov eax, [rsp+56]	;get rsp LH
		mov edi, 109
		call	inthex
		
	mov eax, [rsp+52]	;get rbp Upper Half
		mov edi, 122
		call	inthex
		mov eax, [rsp+48]	;get rbp LH
		mov edi, 131
		call	inthex
		 
	mov eax, [rsp+44]	;get rsi Upper Half
		mov edi, 144
		call	inthex
		mov eax, [rsp+40]	;get rsi LH
		mov edi, 153
		call	inthex
		
	mov eax, [rsp+36]	;get rdi Upper Half
		mov edi, 166
		call	inthex
		mov eax, [rsp+32]	;get rdi LH
		mov edi, 175
		call	inthex
 
 	mov eax, [rsp+68]	;get eflg 16 bit upper
		mov edi, 197
		call	intbin
		mov eax, [rsp+64]	;get eflg LH
		mov edi, 214
		call	intbin

 	mov eax, [rsp+76]	;Looks from the return address available
		mov edi, 232		
		call	inthex
		mov eax, [rsp+72]	;get rip LH
		mov edi, 241
		call	inthex
 
	mov rax, 1	; 1 = write
	mov rdi, 1	; 1 = to stdout
	mov rsi, sOutDmp	; string to display in rsi
	mov rdx, 352	; length of the string, without 0
	push r11
	syscall
	pop r11	; display the string
	
		pop	 rdx		;restore registers
		pop	 rcx
		pop	 rbx
		pop	 rax

		pop	 rdi
		pop	 rsi
		pop	 rbp
		pop	 rsp

		popfq

		ret
		

	
;--------------------------------------
quit:
tmpend:
	mov rax, 60	; 60 = exit
	mov rdi, 0	; 0 = success exit code
	syscall	; quit

;--------------------------------------------
inthex: mov cx , 8		; convert eax into hex 
inthex1:mov esi, eax		; in1: eax, so 4 bytes, 8
	and esi, 0xF		; take lower significant nibble
	mov BH, [aiHex + esi]
	shr eax, 4		; mov to higer significant niblle
	dec edi			; decrement next store location,
	dec cx			; so lower memory but higher significance.
	mov [sOutDmp + edi], BH	; the hex digits are stored at [sOutDmp+edi]
	jnz	inthex1
	ret
;--------------------------------------------
b8hex:	mov cx , 8		;convert rax into 8 bytes hex string starting at rdi separted by space
b8hex1: mov rsi, rax
	and rsi, 0xF
	mov BH, [aiHex + rsi]
	shr rax, 4
	mov [sOutDmp + rdi], BH
	inc rdi

	mov rsi, rax
	and rsi, 0xF
	mov BH, [aiHex + rsi]
	shr rax, 4
	mov [sOutDmp + rdi-2], BH	
	inc rdi
	inc rdi
	dec cx
	jnz  b8hex1

	ret
;--------------------------------------------
b8chr:	mov cx , 8		;convert rax into 8 bytes to printable char else dot starting at rdi 
b8chr1: mov bl, al
	cmp bl,0x20
	jb  b8chr2
	cmp bl,0x80
	jb b8chr3
b8chr2: mov bl,0x2E
b8chr3: mov [sOutDmp +rdi],bl
	dec cx
	jz  b8chr4
	inc rdi
	shr rax,8
	jmp b8chr1
b8chr4: ret
;--------------------------------------------	
intbin: mov cx , 16		;convert eax into bin string ending at edi
intbin1:mov esi, eax
	and esi, 0x1
	mov BH, [aiHex + esi]
	shr eax, 1
	dec edi
	dec cx
	mov [sOutDmp + edi], BH
	jnz	intbin1
	ret

;--------------------------------------------------------------	
section .data	; for debugger
;--------------------------------------------------------------
aiHex:	db	"0123456789ABCDEF"

aDspRax: db	"rax:01234567 01234567", 0x0A
aDspRcx: db	"rcx:01234567 01234567", 0x0A

acDsp:	db	"rax:12345678 12345678 rbx:12345678 12345678 rcx:12345678 12345678 rdx:12345678 12345678", 0x0A; 88
	db	"rsp:12345678 12345678 rbp:12345678 12345678 rsi:12345678 12345678 rdi:12345678 12345678", 0x0A; 88
	db	"eflg:1234567812345678 1234567812345678      rip:12345678 12345678                      ", 0x0A; 88
	db	"             --dpfavr -nlpoditsz-a-p-c                                                 ", 0x0A; 88
		;123456789012345678901234567890123456789012345678901234567890123456789012345678901234567
		;         10        20        30        40        50        60        70        80        total 352

aHxDmp: db	"01234567 01234567: 01 23 45 67 01 23 45 67-01 23 45 67 01 23 45 67 01234567-01234567", 0x0A;
		;123456789012345678901234567890123456789012345678901234567890123456789012345678901234567

;--------------------------------------------------------------
section .bss	; for debugger
;--------------------------------------------------------------

sOutDmp:	resb 352

