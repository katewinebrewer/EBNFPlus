;******************************************************************************
; X2X.asm interfaces the file system with the parser.
; Example code: .. F2I ("hi.bnf"), I2O(*Grammar), O2F ("hi.asm") .. loads the
; file "hi.bnf", parses it as by Grammar def. and saves result in "hi.asm".
; Process:       load          parse        save
;	 -----    F2I   -----   I2O   -----  O2F      -----
;     input file --o-->  sIn   --o-->  sOut --o--> output file
;	 -----	        -----         -----           -----
;		    In0..rInEnd      Out0..
;		    rInPnt-->	     rOutPnt--> (grows maximal to OutBufEnd)
; Note: IP.asm interfaces the network with the parser using S2I, O2S and alike.
;******************************************************************************

F2I:	; File to Memory
	; use:	~ (sFPN)
	; do:	1. open file, named sFpn
	; 	2. read into memory starting at In0
	;	3. when done, set rInEnd
	;	4. close file.

; 1. open file
	pop rbx			; 4ret
	lea rdi, [rsp+1]	; rdi = *fpn 4sys_open
	mov rsi, 2		; 2 = O_RDWR
	mov rax, rsi		; 2 = SYS_OPEN
	 syscall		; rax = fd
	or rax, rax
	jge .dr1
	   call ErrorMessage
	   db 18, "Input file unknown"
	.dr1:
	xor rcx, rcx		; remove sFpn from stack
	mov cl, [rsp]
	inc rcx
	shr rcx, 3
	inc rcx
	shl rcx, 3		; ax = ((dx+1)/8+1)*8 = ALen
	add rsp, rcx

; 2. read file starting at In0
	mov rdi, rax		; fd 4sys
	mov rsi, In0		; start add for load
	mov rdx, OutBufEnd
	sub rdx, rsi		; max len 4sys
	xor rax, rax		; 0=sys_read
				; rdi,  rsi, rdx
				;  fd, *buf, len
	 syscall      		; rax = InLen, rdi = fd
	or rax, rax
	jge .dr2
	   call ErrorMessage
	   db 22, "Cannot read input file"
	.dr2:	
	cmp rdx, rax		; rdx=avail rax=actual
	jg .dr3
	   call ErrorMessage
	   db 24, "No memory for input file"
	.dr3:

; 3. set rInEnd
	add rax, rsi		; rax := rsi+rax= In0+Len = rInEnd
	mov rInEnd, rax
	mov rInPnt, In0
; 4. Close file
	mov rax, 3		; 3=sysclose
				; rdi.
				;  fd.
	 syscall
	or rax, rax
	jge .dr4
	   call ErrorMessage
	   db 23, "Cannot close input file"
	.dr4:
	xor rcx, rcx
	inc rcx
	jmp rbx

;******************************************************************************
E2O:	; Empty to Memory, for creating only output without input.
	; use:	~(*function)
	; do:	Start function for output without source for parsing
	;	Output starts at Out0 and ends at rOutPnt
	;	No parse possible since sIn is empty
	
	mov rInEnd, In0		; Rest same as I2O
;------------------------------------------------------------------------------
I2O:	; In to Out, maps sIn to sOut as defined by grammar.
	; use:	~(*grammar) 	memory grows from Out0 to rOutPnt
	; do:	1. start grammar any out put starts from Out0
	; 	2. When all parsed, set OutEnd.
	; pOK is NOK if sIn is not parssed fine till end
	pop rdx			; 4ret
	pop rbx			; rbx = *Grammar
	push rdx

; 1. set up memory for grammar start and output
	xor rcx, rcx
	mov rInPnt,	In0
	mov Out0,	rInEnd
	mov rOutPnt,	rInEnd
	mov rLastIn,	rInPnt		; LastIn string still empty
 	mov rLastInLen, rcx		; =0
	mov InPntMax,	rInPnt		; not much success sofar
	mov InPntOld,	rInPnt
	mov InPrev,	rInPnt
	mov InPrevLen, rcx
	mov LblNxtNew, rcx
	mov rFactCnt, rcx
	mov rInChrCnt, rcx
	mov rInEndFlg, rcx
	inc rcx				; rcx = rPOk = TRUE

	call rbx
	
	mov OutEnd, rOutPnt

EOF:	xor rcx, rcx			; if end then conform grammar
	cmp rInPnt, rInEnd		; over the edge of sIn?
	jl .eof1

	inc rcx
.eof1:	ret
;******************************************************************************
O2F:	; Out to File
	; use:	~(sFPN)		memory use is implicit from Out0.. rOutPnt
	; Do:	1. create file (overwrite previous file if there)
	;	2. write file content Out0 to OutEnd.
	
; 1. create file
	pop rbx
	lea rdi, [rsp+1]	; rdi = *fpn 4sys_open
	mov rsi, 666q		; 2 = O_RDWR
	mov rax, 85		; 2 = SYS_OPEN
	 syscall		; rax = fd
	or rax, rax
	jge .m2f1
	   call ErrorMessage
	   db 18, "Cannot create file"
	   .m2f1:
	xor rcx, rcx		; remove sFPN from stack
	mov cl, [rsp]
	inc rcx
	shr rcx, 3
	inc rcx
	shl rcx, 3		; ax = ((dx+1)/8+1)*8 = ALen
	add rsp, rcx
; 2. write file
	mov rdi, rax
	mov rsi, Out0
	mov rdx, rOutPnt	; OutEnd probably no need for
	sub rdx, rsi		; rdx=length of Out
	mov rax, 1		; 1=SYS_WRITE
	 syscall
	or rax, rax
	jge .m2f2
	   call ErrorMessage
	   db 16, "Cannot save file"
	   .m2f2:
; 3. close file
	mov rax, sys_close	; =3, rdi contains fd already
	 syscall
	or rax, rax
	jge .m2f3
	   call ErrorMessage
	   db 23, "Cannot close saved file"
	   .m2f3:
	xor rcx, rcx
	inc rcx
	jmp rbx

;******************************************************************************
O2I:	; Output to In, so copy sOut to sIn, reset context to parse sIn
	; use:	~()
	; do:	copy Out to In. Based on In0 and length_of_Out (=rOutpnt-Out0)
	;	set rInPnt, rInEnd, Out0 (=rInEnd) and rOutPnt (=rInEnd)
	;	resets context overriding the previous context inc pOK.
	mov rcx, rOutPnt
	sub rcx, Out0			; rcx = length of buf to copy
	
	mov rsi, Out0
	mov rdi, In0
	mov rInPnt, rdi
	jrcxz .o2i1			; if nothing to copy no mov to do

	cld
	rep movsb
	mov rInEnd, rdi
	mov Out0, rdi
	mov rOutPnt, rdi
	mov rInEndFlg, rcx
	inc rcx
	ret

.o2i1:	xor rcx, rcx
	inc rcx				; set rOK		
	mov rInEndFlg, rcx		; set rInEndFlg (end reached)	
	mov rInEnd, rdi			; rInEnd=In0
	mov Out0, rdi
	mov rOutPnt, rdi
	ret
;******************************************************************************
F2O:	; File to Output, overwrite existing sOut
	; use:	~(sFpn)
	; do:	load file at Out0    (so renews Out)
	mov rOutPnt, Out0
				; rest same as F2OAppend
;------------------------------------------------------------------------------
F2OAppend:	; File to Output, append to existing sOut)
	; use:	~(sFpn),	
	; do:	1. open file, named sFpn
	; 	2. read into memory starting at Out0
	;	3. when done, set OutEnd
	;	4. close file.

; 1. open file
	pop rbx			; 4ret
	lea rdi, [rsp+1]	; rdi = *fpn 4sys_open
	mov rsi, 2		; 2 = O_RDWR
	mov rax, rsi		; 2 = SYS_OPEN
	push r11
	 syscall		; rax = fd
	pop r11
	or rax, rax
	jl .f2Err		; db 18, "Input file unknown"
	
	xor rcx, rcx		; remove sFpn from stack
	mov cl, [rsp]
	inc rcx
	shr rcx, 3
	inc rcx
	shl rcx, 3		; ax = ((dx+1)/8+1)*8 = ALen
	add rsp, rcx

; 2. read file			Set In0, rInPnt, rInEnd, Out0, rOutPnt
	mov rdi, rax		; fd 4sys
	mov rsi, rOutPnt	; start add for load
	mov rdx, OutBufEnd
	sub rdx, rsi		; max len 4sys
	xor rax, rax		; 0=sys_read
				; rdi,  rsi, rdx
				;  fd, *buf, len
	push r11
	 syscall      		; rax = InLen, rdi = fd
	or rax, rax
	jge .dr2
	   call ErrorMessage
	   db 22, "Cannot read input file"
	.dr2:	
	cmp rdx, rax		; rdx=avail rax=actual
	jge .dr3
	   call ErrorMessage
	   db 24, "Out of memory for input file"
	.dr3:

; 3. set OutEnd
	add rax, Out0		; =rsi?
	mov OutEnd, rax
	mov rOutPnt, rax
; 4. Close file
	mov rax, 3		; 3=sysclose
				; rdi.
				;  fd.
	 syscall
	pop r11
	or rax, rax
	jge .dr4
	   call ErrorMessage
	   db 19, "Cannot close InFile"
	.dr4:
	xor rcx, rcx
	inc rcx
	jmp rbx
	
.f2Err:				; in case file unknown then flag NOK
	xor rcx, rcx
	mov cl, [rsp]
	inc rcx
	shr rcx, 3
	inc rcx
	shl rcx, 3
	add rsp, rcx
	xor rcx, rcx
	jmp rbx


