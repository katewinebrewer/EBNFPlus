;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; 			     EBNF Kernel
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; 210801 V0.1	1st stable version
; 220127 V0.2	added: hex input;
;		fixed: label duplication in ebnf Factor
; 		changed: all .bss variables to rbp area
;		changed: file load, parse and save process from asm to EBNF
;		changed: file load and save by heap
;		added; identifier/integer lists allowed as function argument
; 220205 V0.3	changed: removed spearate context stack, now on machine stack
; 220207 V0.4	changed: comment symbols to /* and */ conform C-comments
;		changed: implicit address to explicit address using "*"
; 		added: Postfix function calls: argument then function
;		added: pOutPIn for previous input next to last input
; 220216 V0.5	added: list arguments of mixed integer, identifier and addreses
; 220406 V0.6	added: (h,h) functional rule
; 220420 V0.7	added: common memory mngmnt using mmap for both main and threads
;		changed: support stacked parameters for functions (with except
;		list for primary functions for speed)
; 220516 V0.8	changed: specific file load/save to F2M, M2M
; 220802 V0.9	fixed: pOK = true immediate after '|'
;		added: pHIi, pOutHIi, pHILeni, where i= 0..4
;		added: ** for factor construct <stacked variable> ** (expr)
; 220829 V0.10	fixed: rEndFlg reset at concatenation
; 220917 V0.11	added sOut, sLeft , sCutRight
; 221016 V0.12	added Bin4Dec, sPushA, Unix and Ecma time
; 240320 V0.13	fixed and streamlined abn primitives; renamed M2M to I2O,
;		F2M to F2I, M2F to O2F; added O2I; added module IP.
;		Added ServerRecv and ServerSend	
; 240527 v0.14	Added sKeyIn, removed Heap module, removed functional
;		rules, corrected MemUnmap
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; 				EXTERNALS
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

GLOBAL main

;******************************************************* Application **********
EXTERN Rum

;******************************************************* EBNFKernel  **********
GLOBAL CLArg
GLOBAL sOut, sPush, sPushA, sCLArg, sConcat, sLI, sMessage, sI2HS
GLOBAL sLeft, sCutRight, sDrop, sDup, sKeyIn
GLOBAL MemMap, MemUnmap

GLOBAL pIn, pInterval, pIntervalQuad, pFindIn
GLOBAL cPush, cPop, cTop, cAndProlog, cAndEpilog, cDrop, cDropExcept

GLOBAL DropLastChar, IsNotDef

GLOBAL cOpenTextGram, cCloseTextGram
GLOBAL cOpenH2HGram, cCloseH2HGram

GLOBAL lClear, LblNew, LblUse, LblCls, LblPush, LblTop, LblDrop, pOutLbl
GLOBAL SDIdStart, SDIdOper, SDIdEnd

GLOBAL pOut, pOutCr

GLOBAL pOutLI, pOutLILen
GLOBAL pOutPI, pOutPILen
GLOBAL pOutHI0, pOutHILen0, pHI0
GLOBAL pOutHI1, pOutHILen1, pHI1
GLOBAL pOutHI2, pOutHILen2, pHI2
GLOBAL pOutHI3, pOutHILen3, pHI3
GLOBAL pOutHI4, pOutHILen4, pHI4
GLOBAL pOutHI5, pOutHILen5, pHI5, sHI5

GLOBAL pOutLIHex, pOutLIHex2Bin
GLOBAL pOutLITrim, pOutLIdpTrim
GLOBAL pOutInPnt, pOutLILenByte

GLOBAL OutSrcLin

GLOBAL DspLstTrm, MsgLI, MessageMem, Message, ErrorMessage, Quit, dspebnf

GLOBAL Bin2Dec, Bin4Dec, BinNDec, Bin1Hex, Bin2Hex, BinNHex, Dec2Bin, Hex2Bin

GLOBAL WaitSecond, EcmaTime, IMFTime, GetTime
GLOBAL iRandom

GLOBAL mRSP

GLOBAL F2M, E2M, M2M, EOF, M2F
GLOBAL F2I, F2O, F2OAppend
GLOBAL E2O, I2O, O2I, O2F
GLOBAL a, b, n, sIFSF

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;				VARIABLES
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

section .bss

mRSP:	resq 1	; rsp of OS given stack. EBNF main and threads have own stack.
iArg:	resq 1
pArg:	resq 1


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;				MAIN
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
section .text

%include "../EBNF/EBNFix.asm"
%include "../EBNFKernel/abn.asm"
%include "../EBNFKernel/X2X.asm"

main:	; EBNF+ start process

; 1. save parameters in CLI
	mov [iArg], rdi
	mov [pArg], rsi
; 2. save rbp as by convention
	push rbp
	mov [mRSP], rsp
; 3. show starting
	call Message
 	 db 50, 11, "<EBNF Version 0.14 (c) 2021..2024 Hans Wijnands>", 10
 	call ChipInfo
; 4. Get a memory block.	 	Set mMem0, rbp, rsp.
	mov rsi, sMemL			; Ask OS for memory of length sMemL
	call MemMap			; rax = bottom of block
	mov rbp, rax
	add rbp, rsi
	lea rsp,[rbp-sMemBL]
	mov mMem0, rax

; 5. setup EBNF parameters		set start (In0) and I/O space available
	mov In0, rax
	mov rInPnt,  rax
	mov rInEnd,  rax
	mov rOutPnt, rax
	mov rLastIn, rax
	
	xor rcx, rcx
	mov rLastInLen, rcx
	mov rFactCnt,   rcx
	mov rInEndFlg,  rcx
	mov rInChrCnt,  rcx
	inc rcx			; pOK=True

	mov OutBufEnd, rsp
	sub qword OutBufEnd, sMemSL 	; keep safe distant from rsp area
; 6. Start parse as by user spec
 	call Rum
; 7. Assume a return from user
	mov rdi, mMem0


 	mov rsp, [mRSP]
 	pop rbp
 	ret
 
;******************************************************************************
Quit:	; EBNF+ end process
	call Message
	 db 10, 10, "Quiting.."
	mov rdi, rcx		; 0 = success exit code or error?
	mov rax, 60		; 60 = exit
   	syscall			; will not return back, memory regained by OS

;******************************************************************************
;			Memory (for main and thread)
;******************************************************************************
%define PROT_READ	0x1
%define PROT_WRITE	0x2
;%define PROT_EXEC	0x4
%define MAP_PRIVATE	0x0002
%define MAP_ANONYMOUS	0x0020
%define MAP_GROWSDOWN	0x0100

%define wMemProtF	PROT_WRITE | PROT_READ
%define wMemMapF	MAP_ANONYMOUS | MAP_PRIVATE | MAP_GROWSDOWN
		 	
MemMap:	; request system to allocate memory of size Len somewhere (OS choice)
	; in: rsi = Len
	; out: rax = Add0
	; used: rdi, rdx, r10,r8, r9, rax, rbx
	mov rdi, 0	; Let OS choose
	mov rdx, wMemProtF
	mov r10, wMemMapF
	mov r8, -1	; Anonymous fd, so -1
	mov r9, 0	; no fd, so no offset
	mov rax, 9
		; SYS_MMAP = 9
		; rax,    rdi,   rsi,       rdx,      r10,     r08,    r09.
		;   9, (0|Mem0),  MemL,     ProtF,    mmapF, (-1|fd), fdOffs.
		;   9,  0, 	  wMemL, wMemProtF, wMemMapF,  -1,      0.
	 syscall ; rax = Mem0 (mmap always returns bottom of mem)
	ret

MemUnmap:
	; returns memory allocated by MemMap back to system
	; in: rdi = Add0, rsi = Len
	; out: rax = Errno
	; used: rbx, rcx, r11
	pop rbx		; may be used also to unmap stack
	mov rax, 11
		; SYS_MUNMAP = 11
		; rax,  rdi, rsi.
		;  11, Add0, Len
	 syscall	; this line was lost in last 5 versions!
	jmp rbx

;******************************************************************************
;				CHIP INFO
;******************************************************************************
ChipInfo:	; Display if cpu supports AVX, VAES, VPCLMUL, FMA and SHA

%define MaskAVX		0x18000000	; AVX 		bit 28, 27
%define MaskVAES	0x1A000000	; VAES 	bit 28, 27, and 25
%define MaskVPCLMULQDQ	0x18000002	; VPCLMULQDQ 	bit 28, 27, and 1
%define MaskFMA		0x18001000	; FMA 		bit 28, 27, and 12
%define MaskSHA		0x20000000	; SHA instr (7) bit 29

	call Message
	 db 18,"Your PC supports: "
; AVX------------------------
	mov ebx, MaskAVX
	call ChipDetect
	je ChpInf1
	call Message
	 db 3, "no "
ChpInf1:
	call Message
	 db 5, "AVX, "
; VAES-----------------------
	mov ebx, MaskVAES
	call ChipDetect
	je ChpInf2
	call Message
	 db 3, "no "
ChpInf2:
	call Message
	 db 6, "VAES, "
; VPCLMUL--------------------
	mov ebx, MaskVPCLMULQDQ
	call ChipDetect
	jne ChpInf3
	call Message
	 db 3, "no "
ChpInf3:
	call Message
	 db 12, "VPCLMULQDQ, "
; FMA------------------------
	mov ebx, MaskFMA
	call ChipDetect
	je ChpInf4
	call Message
	 db 3, "no "
ChpInf4:
	call Message
	 db 5, "FMA, "
; SHA------------------------
	mov ebx, MaskSHA
	call ChipDetect
	je ChpInf5
	call Message
	 db 3, "no "
ChpInf5:
	call Message
	 db 5, "SHA.", 10
; END------------------------
	ret

ChipDetect:
	mov eax, 1
	cpuid
	and ecx, ebx
	cmp ecx, ebx	; check desired feature flags
	jne ChInf1 
	   			; processor supports features
	mov ecx, 0		; specify 0 for XFEATURE_ENABLED_MASK register
	XGETBV			; result in EDX:EAX
	and eax, 06H
	cmp eax, 06H	; check OS has enabled both XMM and YMM state support
ChInf1:	ret			; zf=1 support, zf=0 notsupported


;******************************************************************************
;				String operators
;******************************************************************************
 
CLArg1:	; ~() rdx
	; out:	rsi = address 1st command line argument delimited db 0x0
	mov rdx, 1

;--------------------------------------
CLArg:	; ~(rdx)rsi
	; out:	rsi = address of command (rdx=0) or its rdx_th argument (rdx>0)
	;	delimited by db 0x0
	; 	rdx is limited to mod 8
	and edx, 7		; max 7 arguments
	cmp dl, [iArg]		; request more than available? iArg=1 if no arg
	jl .cla1
	   call Message
	    db 33, "Insufficient number of arguments", 10
	    jmp quit
	.cla1:
	mov rsi, [pArg]
	mov rsi, [rsi+rdx*8]
	ret
	
;--------------------------------------
sCLArg:	; ~(i) s
	; in:	i index
	; out:	s string
	; do:	return s which equals the ith argument in the command line,
	; 	where 0 returns the command, 1 the first argument etc.

	pop rbx		; rbx = 4ret
	pop rdx		; rdx = index
	call CLArg	; rsi = *CLArgument
	push rsi
	xor cx, cx
	dec cx
.cla1:	inc cx
	lodsb
	or al, al
	jnz .cla1	; cx = len(CLAargument)			
	mov ax, cx	; ax = len
	mov dx, ax	; dx = len
	inc rdx
	shr rdx, 3
	inc rdx
	shl rdx, 3	; rdx = ((dx+1)/8+1)*8
	pop rsi		; rsi = *CLArgument
	sub rsp, rdx

	sub rdx, rcx
	dec rdx	
	mov rdi, rsp
	stosb		; len stored on BOS
	rep movsb	; s stored on stack
	
	mov cx, dx	; cx = len
	xor ax, ax
	rep stosb	; 0 filled until stack 8 byte aligned
	inc rcx
	jmp rbx

;------------------------------------------------------------------------------
sLI:	; ~() s
	; put on stack last parsed string

	pop rbx			; 4ret
	mov rdx, rLastInLen	; put on stack the pfn, keep 8B stack alignment
	inc rdx			; 4syscall add the file delimiter byte (0)
	shr rdx,3
	inc rdx
	shl rdx, 3
	sub rsp, rdx
	mov rdi, rsp
	mov rsi, rLastIn

	mov rcx, rLastInLen
	mov ax, cx
	cld
	stosb
	jrcxz .sli1
	rep movsb
.sli1:	xor eax, eax		; place pfn delimiter (0)
	stosb
	inc rcx
	jmp rbx
	
;------------------------------------------------------------------------------
sConcat:; ~(s1,s2) s3
	; do: replace s1 and s2 with s3 = s1 & s2, all on stack
	; legenda: *=address, A=8 byte aligned, l = length
	;	   BOS bottum of stack (1st unused in high mem)
	;	   TOS top of stack; (latest stacked in low mem)
	pop rbx
; 0. extend stack with 0x100 bytes
	cld
	mov rsi, rsp	; rsi = *s2
	sub rsp, 0x100
; 1. move s2 intoto TOS (omit l2 byte)
	mov rdi, rsp
	xor rax, rax
	lodsb		; rax = l2, rsi = *s2 + 1
	 push rax	; >1  = l2
	mov rcx, rax	; rcx = l2
	jrcxz .sC1
	rep movsb	; rcx = 0, rdi free, rsi = *s2 + l2 + 1
   .sC1:
; 2. calc Al2
	mov cl, al	; rcx = l2
	  inc rcx
	  shr rcx, 3
	  inc rcx
	  shl rcx, 3	; rcx = Al2
; 3. calc *s1	  
	sub rsi, rax	; rsi = *s2 + l2  +1 - l2 = *s2 + 1
	add rsi, rcx	; rsi = *s2 + Al2 +1 = *s1 + 1
	dec rsi
; 4. calc l3, Al1, BOS
	mov cl, [rsi]	; rcx = l1
	  push rcx	; >2 = l1
	add rax, rcx	; rax = l2 + l1 = l3
	  inc rcx
	  shr rcx, 3
	  inc rcx
	  shl rcx, 3	; rcx = Al1
	mov rdi, rsi	; rdi = *s1
	add rdi, rcx	; rdi = *s1 + Al1 = BOS
; 5. calc Al3
	mov rdx, rax	; rdx = l3
	 inc rdx
	 shr rdx, 3
	 inc rdx
	 shl rdx, 3	; rdx = Al3
; 6. calc dst TOS
	sub rdi, rdx	; rdi = BOS - Al3 = *s3 (later rsp/TOS)
; 7. mov l3 to dst
	stosb		; l3 in dst
; 8. mov s1 to dst
	   pop rcx	; 2> rcx = l1
	 inc rsi
	 rep movsb
; 9. mov s2 to dst
	  pop rcx	; 1> rcx = len2
	 mov rsi, rsp
	 rep movsb
; 10. fill with 0s
	mov rcx, rdx	; rcx = Al3
	sub rcx, rax	; rcx = Al3 - l3
	dec rcx		; ! inc cnt byte
	xor al, al	; append 0's
	rep stosb	; rdi = BOS
; 11. set rsp to *s3
	sub rdi, rdx	; rdi = BOS - Al3 = TOS
	mov rsp, rdi
	inc rcx
	jmp rbx

; -----------------------------------------------------------------------------
DropLastChar:	;
	; Drop the last character from object
	dec rOutPnt
	ret

; -----------------------------------------------------------------------------
sI2HS:	; Convert the 64b integer on stack into 4 hex characters (Little Endian)
	; in: 	db xx, xx, dd, dd, dd, zz, zz, zz ; where dd = dont care, zz=0x0
	; out:	db 04, hh, hh, hh, hh, zz, zz, zz ; where hh is in xx in hex format
	pop rbx
	pop rax
	push rax
	mov byte [rsp], 4
	lea rdi, [rsp+1]
	push rbx
	jmp Bin2Hex
	
; -----------------------------------------------------------------------------
sLeft:	; (s1,n)s2    leave on stack s2 = the n left side characters of s1
	pop rbx
	pop rdx				; dl = n
	mov rsi, rsp
	cmp dl, [rsi]
	jle .sCR1
	mov dl, [rsi]
		
.sCR1:	mov byte [rsi+rdx+1], ch	; delimit s2 with 0	
	xchg byte [rsi], dl		; dl=len(s1)

.sLft1: 			; IF Alen(s1)=Alen(s2) THEN done,
				; ELSE move s2 Alen(s1)-Alen(s2) 8B blocks up
	inc dl
	shr dl, 3
	inc dl
	shl dl, 3			; dl ALen(s1)
	mov rdi, rsi
	add rdi, rdx			; rdi = BOS (so high up in memory)
	sub rdi, 8			; addr in stack for last 8B of s2
 	mov cl, [rsi]			; rcx = len(s2)
	inc cl
	shr cl, 3
	inc cl
	shl cl, 3			; dl = ALen(s2)
	add rsi, rcx
	sub rsi, 8
	shr rcx, 3
	jrcxz .sLft2			; if 0 nothing to move
	std
	rep movsq
	mov rsp, rdi
	add rsp, 8

.sLft2:	inc rcx
	jmp rbx

; -----------------------------------------------------------------------------
sCutRight:
	; (s1,n) s2    leave on stack s2 = s1 cut with n bytes right
	pop rbx
	pop rdx				; dl = n
	mov rsi, rsp
	cmp dl, [rsi]
	jle .sCR1
	mov dl, [rsi]
		
.sCR1:	sub dl, [rsi]			; dl = n -len(s1)
	neg dl				; dl = len(s1)-n=len(s2)
	
	mov byte [rsi+rdx+1], ch	; delimit s2 with 0
	xchg byte [rsi], dl		; dl=len(s1)
				; IF Alen(s1)=Alen(s2) THEN done,
				; ELSE move s2 Alen(s1)-Alen(s2) 8B blocks up
	inc dl
	shr dl, 3
	inc dl
	shl dl, 3			; dl ALen(s1)
	
	mov rdi, rsi
	add rdi, rdx			; rdi = BOS (so high up in memory)
	sub rdi, 8			; addr in stack for last 8B of s2
 	mov cl, [rsi]			; rcx = len(s2)
 	
	inc cl
	shr cl, 3
	inc cl
	shl cl, 3			; dl = ALen(s2)
	
	add rsi, rcx
	sub rsi, 8
	shr rcx, 3
	jrcxz .sCR2			; if 0 nothing to move
	std
	rep movsq
	mov rsp, rdi
	add rsp, 8

.sCR2:	inc rcx
	jmp rbx
	
; -----------------------------------------------------------------------------
sOut:	; (s)   append s1 to sOut
	pop rbx
	mov rsi, rsp
	cld
	lodsb
	mov cl, al
	mov rdx, rcx
	inc rdx
	shr rdx, 3
	inc rdx
	shl rdx, 3
	mov rdi, rOutPnt
	jrcxz .sO1
	rep movsb
	mov rOutPnt, rdi
.sO1:	add rsp, rdx
	inc rcx
	jmp rbx
; -----------------------------------------------------------------------------
sDrop:	; (s)
	; do:	drop last string on stack
	; uses:	rax, rdx
	pop rdx
	xor rax, rax
	mov al, [rsp]
	inc rax
	shr rax,3
	inc rax
	shl rax, 3
	add rsp, rax
	jmp rdx

sDup:	; (s)s,s
	; do:	duplicate string on stack
	; uses:	rdx, rax, rdi, rsi
	pop rdx
	mov rsi, rsp
	
	xor rcx, rcx
	mov cl, [rsi]
	inc rcx	
	shr rcx, 3
	inc rcx
	mov rax, rcx
	shl rax, 3
	sub rsp, rax
	mov rdi, rsp
	
	cld
	rep movsq
	
	inc rcx
	jmp rdx
	
;------------------------------------------------------------------------------

sKeyIn:	; push on stack the string keyed in until closed by a return
	; in:	void
	; out:	string on stack (mod 8 alligned, LSB in low mem)
	;	delimited with 0x0 byte, return not included
	;	max len = 254
	; ass:	rsp0 mod 8 = 0
	; 	[rspEnd] = length byte of string
	;	rsp0-100h is within allowed memory space
	; prop:	rsp mod 8 = 0
	;	allwed empty string to return
	; used:	rax, rbx, rcx=1, rdx=0x100, rsi, rdi.
	; todo: what if typed string len is >255? 

 	pop rbx			; 4ret
 
 ; 1. Reserve 0x100 bytes on stack, get console input and move string into BOS
 	mov rdx, 0x100
 	sub rsp, rdx
 	dec rdx
 	mov rsi, rsp
 	inc rsi			; start above len byte
	xor rax, rax		; mov rax, SYS_read=0
	mov rdi, rax		; mov rdi, STDIN=0
				; rax=0=sys_read
				; rax	rdi	rsi	rdx
				; 0	fd	*buf	len=FF
	 syscall                ; rax = len
	inc rdx

	mov byte [rsp+rax],0	; overwrite 0x0a with delimiter 0
	dec eax			; adapt len since 0x0a is dropped
	mov [rsp], al		; store len at LSB

; 2. move string into lower free stack (higher mem)
	inc rax
	shr rax, 3
	inc rax
	mov rcx, rax		; we mov per 8B
	shl rax, 3
	mov rsi, rsp
	sub rsi, 8		; movs is post de/in-crement
	mov rdi, rsi
	add rdi, rdx		; destiny add for MSB
	add rsi, rax		; source add of MSB
	 std			; mov MSB of string first
	 rep movsq		; rest is moved below MSB
	add rdi, 8
	mov rsp, rdi
	inc rcx
	jmp rbx

; -----------------------------------------------------------------------------
IsNotDef:
	; IsNotDef (Is the last parsed string Not already Defined?)
	; Since this requires check through all sofar compiled code it is made primitive
	; Implementation: Search (from Out0 to rOutPnt) for the text:
	; 	<LastIn> ws "=", where ws is {0x00 to 0x0d}*.

	cld
	mov rdx, rLastInLen
	dec rdx			; one less since we test first char separately by scasb
	js .IND3		; if len= 0 then full match
	mov rdi, Out0

.IND1:	mov rsi, rLastIn
	mov rcx, rOutPnt
	sub rcx, Out0		; length search area =  object are (not source!)
	lodsb
	repne scasb

	mov rbx, rdi		; keep as start for possible continued search
	jne .IND2		; jmp if no match
	
	cmp rdi, Out0		; check if match is 1st word in Out
;	je .IND4
	cmp byte [rdi-2], 0x0d	; if not check if it starts with ws
	ja .IND1

.IND4:	mov rcx, rdx
	jrcxz .IND3		; if empty then full match
	repe cmpsb		; check if rest of key is there in sIn
	je .IND3		; full match

	mov rdi, rbx		; continue further for 1st char search
	jmp .IND1

.IND2:	xor rcx, rcx		; no match, so true
	inc rcx
	ret
	
.IND3:	mov al, [rdi]		; parse ws
	inc rdi
	cmp al,0x0d
	jbe .IND3

	cmp al, "="
	jne .IND2

	xor rcx, rcx
	ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;				DISPLAY
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
sMessage:	;
	; Display stacked string
	; on stack byte order: n, c1, c2, .. cn, 0, .. 0.
	; 	where n is string length
	;	must be delimited by at least one zero

	pop rbx		; rbx = 4ret
	
	mov rsi, rsp
	cld
	lodsb		; al = len
	xor rdx, rdx
	mov dl, al
	mov rax,1	; rax=sys_write=1		for syscall
	mov rdi,1	; rdi=fd=1=display		for syscall
	push rcx
	push r11
	syscall
	pop r11
	pop rcx
	xor rdx, rdx
	mov dl, [rsp]
	add rdx, rsp
	inc rdx			; 4syscall add the file delimiter byte (0)
	shr rdx,3
	inc rdx
	shl rdx, 3
	mov rsp, rdx

	jmp rbx

;--------------------------------------
Message:
	; Display inline string
	; inline argument: bOffset, String
	; Example:	call Message
	;		 db 4, "test"

			; offset
			; 0 (return address)
	push rax	; -8  / 40
	push rcx	; -16 / 32
	push rdx	; -24 / 24
	push rdi	; -32 / 16
	push rsi	; -40 /  8
	push r11 	; -48 /  0
	mov rsi, [rsp+48]	; return address = start of inline text
	xor rax, rax
	cld		; save by pushf?
	lodsb		; rsi points now to string	ready for syscall
	mov rdx, rax	; rdx = length string,		ready for syscall
	add rax, rsi
	mov [rsp+48], rax
	mov rax,1
	mov rdi,1
	syscall
	
	pop r11
	pop rsi
	pop rdi
	pop rdx
	pop rcx
	pop rax

	ret
;--------------------------------------
MessageMem:	;
	; Display string in memory
	;	in:	rsi=*msg, rdx=len(msg)
	;	lost:	rax, rdi

	push rcx	; retain rcx=rPOk
	mov rax,1	; rax=sys_write=1		for syscall
	mov rdi,1	; rdi=fd=1=display		for syscall
	push r11
	syscall
	pop r11
	pop rcx
	ret
;------------------------------------------------------------------------------
ErrorMessage:	;
	; Display inline string as error message, dspebnf and quit 
	; Example	call ErrorMessage
	;		 db 7, "Pardon?"

	call Message
	 db 15, "----error---->", 0x0a
	call dmpreg
	call dmprex
	dec qword InPntMax
	call Message
	 db 8, 10, "Error: "
	pop rsi
	xor rax, rax
	cld
	lodsb		; rsi points now to string 	for syscall
	mov rdx, rax	; rdx = length string,		for syscall
	mov rax, 1		; = sys_write
	mov rdi, 1		; = stdout
	 syscall
	call Message
	 db 2, "!", 10

  	call Message
   	 db 19, 'Grammar NOK at "^"', 10
	mov rsi, InPntMax
	mov rdx, 0x20
	sub rsi, rdx
	cmp rsi, In0
	jg .em1
	   mov rsi, In0
	   mov rdx, InPntMax
	   sub rdx, In0 
	   .em1:
	mov rax, 1		; = sys_write
	mov rdi, 1		; = stdout
	 syscall
	call Message
	 db 1, "^"		; db 4, 27, "[1m"
	mov rsi, InPntMax
	mov rdx, 0x20
	mov rax, 1		; = sys_write
	mov rdi, 1		; = stdout
	 syscall
	call Message
	 db 2, "^", 10		;  db 05, 27, "[0m", 10

	mov rdi, InPntMax
	mov rsi, rdi
	mov rdx, 0x40
	sub rsi, rdx
	cmp rsi, In0
	jg .em2
	   mov rsi, In0
	   .em2:
	call dmphexold
	call Message
	 db 2, "^", 10		; db 4, 27, "[1m"
	mov rsi, InPntMax
	call dmphexrsi
				; call Message
				;  db 4, 27, "[0m"
;	 
	mov rdi, 0		; 0 = success exit code;later change to error
	mov rax, 60		; 60 = exit
   	syscall			; Quit
   	
;------------------------------------------------------------------------------
MsgLI:	; Displays LI
	mov rsi, rLastIn	; 4syscall rsi = *string_to_display
	mov rdx, rLastInLen	; 4syscall rdx = length string
	push rcx	; retain rcx=rPOk
	mov rax,1	; rax=sys_write=1		for syscall
	mov rdi,1	; rdi=fd=1=display		for syscall
	push r11
	syscall
	pop r11
	pop rcx
	ret
;------------------------------------------------------------------------------
DspLstTrm:	;
	; Display last compiled non terminal. Used in EBNF grammar
	push r11
	push rcx
	mov rsi, InPntOld
	xor rdx, rdx
DspLI2:	
	inc rdx
	mov al, [rsi+rdx]
	cmp al, "="
	je DspLI1
	cmp al, " "
	je DspLI1
	cmp al, 9
	jne DspLI2
DspLI1:	mov rax, sys_write	; = 1
	mov rdi, stdout		; = 1
	syscall			; in: rdx=len rsi=add of string
	call Message
	 db 2, ", "
	pop rcx
	pop r11
	ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;				MATH
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

iRandom:		; push on stack hardware generated random 64 bit value  
	pop rbx
.iRnd1:	rdrand rax
	jnc .iRnd1
	push rax
	jmp rbx

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; 	           		TIMER
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
section .data
EcmaTime	db "20YY-MM-DD HH:mm:ss.ssssssss", 0
IMFTime		db "Sun, 06 Nov 2094 08:49:37 GMT", 0
;------------------------------------------------------------------------------
section .bss
SecTime 	resq	1
NanTime		resq	1
ScrapTime	resq	2
TimReq		resq	1	
		resq	1
LockVar		resd	1
;------------------------------------------------------------------------------
section .text
	
WaitSecond:	; waits n seconds in it's thread, then continues
	; eg. usage in bnf:	WaitSecond (60)
	; this compiles to:	push 60
	;			call WaitSecond
	pop rsi
	pop rbx
	push rsi
	push rcx
	push r11
 	 mov rax, 35		; syscall;  35 = *struct_time_request, [*struct_time_remainder]
	 mov rdi, TimReq	; 4syscall rdi=*Timer1
	 mov [rdi], rbx		; seconds on line
	 xor rsi, rsi		; TimRem not used, no time remained required
	  syscall
	pop r11
	pop rcx
	ret

;------------------------------------------------------------------------------
aIMFDayName:	db "Thu,Fri,Sat,Sun,Mon,Tue,Wed,"
aIMFMonth:	db "Dec Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov "

; EcmaTime:	db "20YY-MM-DD HH:mm:ss.ssssssss", 0
;		    01234567890123456789012345678
; IMFTime:	db "Sun, 06 Nov 1994 08:49:37 GMT", 0

GetTime:	;
	; Get current UTC in Ecma format "20YY-MM-DD HH:mm:ss.sss"
	; Out: updated string at EcmaTime.
	; uses var in .bss: SecTime, NanTime, ScrapTime; in .data: EcmaTime

	mov rax, 228		; = sys_clock_gettime
	xor rdi, rdi
	lea rsi, [SecTime]	; address for time in seconds since epoch (unix time)
	syscall			;(struct timeval *tv, struct timezone *tz) *tv,
	mov rax, [SecTime]	; rax = Unix time in seconds since 1 jan 1970
	push rax

	xor rdx, rdx		; calculate day-name
	mov rbx, (7*24*3600)
	div rbx
	mov rax, rdx
	xor rdx, rdx
	mov rbx, 24*3600
	div rbx
	mov eax, [aIMFDayName+4*rax]
	mov [IMFTime], eax
	
	pop rax
	mov rcx, 22
	mov rdx, rax
	sub rax, 0x61CF9980	; 1 jan 2022 = 61CF9980 UTC
	jl .GTErr1

.GTY:	mov rdx, rax		;					63B0CD00
	sub rax, 0x01E13380	; 1 jan 2023 - 1 jan 2022 = 63B0CD00 -	61CF9980
	jl .GTYEnd		;					01E13380

	inc rcx
	mov rdx, rax		;					65920080
	sub rax, 0x01E13380	; 1 jan 2024 - 1 jan 2023 = 65920080 - 	63B0CD00
	jl .GTYEnd		;					01E13380
	
	inc rcx
	mov rdx, rax		;					67748580
	sub rax, 0x01E28500	; 1 jan 2025 - 1 jan 2024 = 67748580 -	65920080
	jl .GTYEndLeap		;				 (Leap)	01E28500
	
	inc rcx
	mov rdx, rax		;					6955B900
	sub rax, 0x01E13380	; 1 jan 2026 - 1 jan 2025 = 6955B900 -	67748580
	jl .GTYEnd		;					01E13380
	
	inc rcx
	jmp .GTY
.GTErr1:
	call ErrorMessage
	 db 11, "Year < 2022"

.GTYEndLeap:
	push rdx		; left-over after current year calculation
	mov rax, rcx		; = current year - 2000 
	lea rdi, [ScrapTime]
	call Bin2Dec
	mov ax, [ScrapTime]
	mov [EcmaTime+2], ax	; year done
	mov [IMFTime+14], ax
	pop rax			; = SecTime-Time(1 jan 2022)- Time(1 jan curyear)
	
	xor rcx, rcx		; start with month 1 and repeat deducting
	inc rcx			; from left-over a month until negative time
	mov rdx, rax
	sub rax, 0x28DE80	; jan = 31*24*3600 = 0x28DE80
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x263B80	; feb = 29*24*3600 = 0x263B80
	jl .GTMEnd
	jmp .Y

.GTYEnd:
	push rdx		; left-over after current year calculation
	mov rax, rcx		; = current year - 2000 
	lea rdi, [ScrapTime]
	call Bin2Dec
	mov ax, [ScrapTime]
	mov [EcmaTime+2], ax	; year done
	mov [IMFTime+14], ax
	pop rax			; = SecTime-Time(1 jan 2022)- Time(1 jan curyear)
	
	xor rcx, rcx		; start with month 1 and repeat deducting
	inc rcx			; from left-over a month until negative time
	mov rdx, rax
	sub rax, 0x28DE80	; jan = 31*24*3600 = 0x28DE80
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x24EA00	; feb = 28*24*3600 = 0x24EA00
	jl .GTMEnd
.Y:				; leap year has extra day!
	inc rcx
	mov rdx, rax
	sub rax, 0x28DE80	; mar = 31*24*3600 = 0x28DE80
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x278D00	; apr = 30*24*3600 = 0x278D00
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x28DE80	; may = 31*24*3600
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x278D00	; jun = 30*24*3600
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x28DE80	; jul = 31*24*3600
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x28DE80	; aug = 31*24*3600
	jl .GTMEnd
.GTM:	inc rcx
	mov rdx, rax
	sub rax, 0x278D00	; sept|nov = 30*24*3600
	jl .GTMEnd
	inc rcx
	mov rdx, rax
	sub rax, 0x28DE80	; oct|dec = 31*24*3600
	jge .GTM

.GTMEnd:
	push rdx		; left over after current month calculation
	
	mov eax,[aIMFMonth+4*rcx]
	mov [IMFTime+8],eax
	
	mov rax, rcx
	lea rdi, [ScrapTime]	
	call Bin2Dec
	mov ax, [ScrapTime]
	mov [EcmaTime+5], ax	; month done
	pop rax
	
	xor rcx, rcx
.GTD:	inc rcx
 	mov rdx, rax
	sub rax, 0x15180	; = 24*3600
	jge .GTD

.GTDEnd:
	push rdx
	mov rax, rcx
	lea rdi, [ScrapTime]	
	call Bin2Dec
	mov ax, [ScrapTime]
	mov [EcmaTime+8], ax	; day done
	mov [IMFTime+5],ax	
	pop rax

	xor rcx, rcx
	dec rcx
.GTh:	inc rcx
 	mov rdx, rax
	sub rax, 0xE10		; = 3600
	jge .GTh

.GThEnd:
	push rdx
	mov rax, rcx
	lea rdi, [ScrapTime]	
	call Bin2Dec
	mov ax, [ScrapTime]
	mov [EcmaTime+11], ax	; hour done
	mov [IMFTime+17],ax	
	pop rax

	xor rcx, rcx
	dec rcx
.GTm:	inc rcx
 	mov rdx, rax
	sub rax, 0x3C		; = 60
	jge .GTm

.GTmEnd:
	push rdx
	mov rax, rcx
	lea rdi, [ScrapTime]	
	call Bin2Dec
	mov ax, [ScrapTime]
	mov [EcmaTime+14], ax	; minute done
	mov [IMFTime+20],ax	
	pop rax

; 0x3C
	lea rdi, [ScrapTime]	
	call Bin2Dec
	mov ax, [ScrapTime]
	mov [EcmaTime+17], ax	; second done
	mov [IMFTime+23],ax	

	mov rax, [NanTime]
	lea rdi, [ScrapTime]
	call Bin4Dec
	
	mov eax, [ScrapTime]
	and eax, 0x00FFFFFF
	mov [EcmaTime+20], eax
	
	ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; 	           Terminal parsers    pIn, pInterval, pFindIn
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pIn:	; Parse string at InPnt if it matches sTerm
	; The string argument is just behind the call:
	;	e.g.  call pIn
	;		db 5, "sTerm"
                       
	pop rsi			; OK 200821, overwrite rpOk(=rcx)
	cld
	xor rax,rax
	lodsb			; rax > rcx = Len(sTerm)
	mov rcx, rax
	mov rdi, rInPnt
	mov rdx, rdi		; start of compare at InPnt0		; unclear what for !!!!!!!!!!
	repe cmpsb
	je pIn1			; z=0 means match (rcx > 0)

	add rsi, rcx		; checked, looks amazing correct
	xor rPOk, rPOk		; No match! > POk = 0
	
	cmp rdi,InPntMax
	jle pInE
	mov InPntMax,rdi

pInE:	jmp rsi

pIn1:	xor rPOk, rPOk
	inc rPOk		; rPOk=1
	mov rLastIn, rdx	; Match!
	mov rLastInLen, rax	; 
	mov rInPnt, rdi		; update iInPnt forward
	cmp rdi, rInEnd		; over the edge of sIn?
	jae pIn3

	jmp rsi
	
pIn3:	inc rInEndFlg		; rInEndFlg = 1
	jmp rsi

;------------------------------------------------------------
pInterval:	; OK 200821
	; Parses byte at InPnt
	; The string argument is just behind the call:
	;	e.g.  call pInterval
	;		db "a", "z"
	; Operands are only as byte allowed. So 2 bytes after call
	; this must be enforced by compiler

	pop	rsi		; rsi = ^sTerm1
 	cld
	lodsb			; al  = sTerm1
	cmp al, [rInPnt]	; sTerm1 < char in sIn?
	ja	pInt4

	lodsb			; al = aTerm2
   	cmp al,	[rInPnt]	; sTerm2  > char in sIn?
	jb	pInt1

	xor rPOk, rPOk
	inc rPOk		; rPOk=1
	mov rLastIn, rInPnt	; within interval! update LastIn
	inc rInPnt
	mov rLastInLen, 1
	cmp rInPnt, rInEnd	; iInPnt at end parsed text?
	jb pInt3

	inc rInEndFlg	 	; reached end! rInEndFlg = 1
pInt3:	jmp rsi

pInt4:	inc rsi
pInt1:	xor rPOk, rPOk		; outside interval!
	jmp rsi

;------------------------------------------------------------
pIntervalQuad:	;
	; Parses 8 byte string at InPnt if it false in byte range
	; The string argument is just behind the call:
	;	e.g.  call pInterval
	;		dq 0x12345678 , 0x9abcdef0
	; Operands are only as quad allowed. So 16 bytes after call
	; this must be be enforced by compiler

	pop	rsi		; rsi = ^sTerm1
 	cld
	lodsq			; rax  = sTerm1
	cmp rax, [rInPnt]	; sTerm1 < quad in sIn?
	ja pIntQ4

	lodsq			; rax = aTerm2
   	cmp rax, [rInPnt]	; sTerm2  > char in sIn?
	jb pIntQ1

	xor rPOk, rPOk
	inc rPOk		; rPOk=1
	mov rLastIn, rInPnt	; within interval! update LastIn
	inc rInPnt
	mov rLastInLen, 1
	cmp rInPnt, rInEnd	; iInPnt at end parsed text?
	jb pIntQ3

	inc rInEndFlg	 	; reached end! rInEndFlg = 1
pIntQ3:	jmp rsi

pIntQ4: add rsi, 04
pIntQ1:	xor rPOk, rPOk		; outside interval!
	jmp rsi	

;------------------------------------------------------------
pFindIn:	;
	; finds a string beyond InPnt
	; The string argument is inline coded
	;	e.g.  call pFindIn
	;		db 10, "first find"
	; When found, InPnt points to the find (not behind the find!)

	pop rsi		; OK 200821
	xor rax,rax
	cld
	lodsb			; get len key
;	mov ebx, eax		; rbx len left to check				not used is it?
	mov edx, eax		; rdx keep len of key for retry
	dec rdx			; one less since wil test 1 first.
	mov rdi, rInPnt		; start search
pFndNxt:
	mov rcx, rInEnd
	sub rcx, rdi		; length search area

	push rsi		; get 1st char of key
	lodsb
	repne scasb		; try finding in sIn
	push rdi		; keep as start for possible next search
	jne pFndNOk		; jmp if no matching char

	mov rcx, rdx		; if key is one char than finalize
	jrcxz pFndOk
	repe cmpsb		; check if rest of key is there in sIn
	je pFndOk		; jmp if full match
	
	pop rdi			; continue further for 1st char search
	pop rsi
	jmp pFndNxt

pFndNOk:
	add rsp, 2*8
	add rsi, rdx
	xor rPOk, rPOk
	jmp rsi

pFndOk:	add rsp, 2*8
	mov rLastIn, rInPnt
	sub rdi, rdx
	dec rdi
	mov rInPnt, rdi
	sub rdi, rLastIn
	mov rLastInLen, rdi
	xor rPOk, rPOk
	inc rPOk
	jmp rsi

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;		CONTEXT STACK		cPush, cTop, cDrop.rFactCnt
; 					cAndProlog, cAndEpilog, cDropExcept.
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

cPush:	pop rdi
	push rInPnt	; [sp+56]
  	push rInEndFlg	; [sp+48]
 	push rOutPnt	; [sp+40]
	push rLastIn	; [sp+32]
	push rLastInLen	; [sp+24]
 	push rFactCnt	; [sp+16]
 	push rInChrCnt	; [sp+ 8]						needed?
 	push r15	; [sp+ 0]
	jmp rdi

cTop:	mov rdi, rsp
	mov rInPnt,	[rdi+64]
	mov rInEndFlg,	[rdi+56]
	mov rOutPnt,	[rdi+48]
	mov rLastIn,	[rdi+40]
	mov rLastInLen,	[rdi+32]
	mov rFactCnt,	[rdi+24]
	mov r15,	[rdi+ 8]
	ret

;--------------------------------------------------------
cAndProlog:	;Concord function will reparse LastIn 

	pop rdi
	push rInPnt	; [sp+56]
  	push rInEndFlg	; [sp+48]
 	push rOutPnt	; [sp+40]
	push rLastIn	; [sp+32]
	push rLastInLen	; [sp+24]
 	push rFactCnt	; [sp+16]
 	push rInChrCnt	; [sp+ 8]						needed?
 	push r15	; [sp+ 0]
	mov rInPnt, rLastIn
	xor rInEndFlg, rInEndFlg	 ; in 0V10 added
	jmp rdi

;--------------------------------------------------------
cAndEpilog:		; same as cDrop
;--------------------------------------------------------
cDrop:	cmp rInPnt,InPntMax		; enables tracing errors
	jbe .cD1			; to see how far max it went OK
	mov InPntMax,rInPnt

.cD1:	jrcxz cPop

	pop rsi
	mov rdi, rsp
	mov rax, [rdi+32]
	mov InPrev, rax
	mov rax, [rdi+24]
	mov InPrevLen, rax
	mov rLastIn,	[rdi+56]	; rLastin := previous rInPnt
	mov rLastInLen, rInPnt
	sub rLastInLen, rLastIn
	mov rFactCnt,	[rdi+16]	; restore rFactCnt
	add rsp, 64
	jmp rsi

;--------------------------------------------------------	
cPop:	pop rsi
	pop r15		; [sp+ 0]
 	pop rInChrCnt	; [sp+ 8]
	pop rFactCnt	; [sp+16]
	pop rLastInLen	; [sp+24]
	pop rLastIn	; [sp+32]
 	pop rOutPnt	; [sp+40]
	pop rInEndFlg	; [sp+48]
	pop rInPnt	; [sp+56]
	jmp rsi

;--------------------------------------------------------
cDropExcept:
	pop rsi
	cmp rInPnt,InPntMax
	jle .cDE1
	mov InPntMax, rInPnt

.cDE1:	jrcxz .cDE2
	add rsp, 64
	xor rcx, rcx
	jmp rsi

.cDE2:	pop r15		; [sp+ 0]
 	pop rFactCnt	; [sp+ 8]	dummy
	pop rFactCnt	; [sp+16] ok
	pop rLastInLen	; [sp+24] ok
	pop rLastIn	; [sp+32] ok
 	pop rOutPnt	; [sp+40] ok
	pop rInEndFlg	; [sp+48] ok
	pop rInPnt	; [sp+56] ok
	xor rcx, rcx
	inc rcx
	jmp rsi

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;			   LABEL MECHANISM	(compile time only)
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
; For multiple exits of constructs use LblPush to declare and LblTop to apply.
; For single or multiple jmps to same location use LblNew to as first label and 
; LblUse for further use. See "DefinitionsList" in EBNF.bnf as mixed example.
; Label mechanism uses EBNF context variable rFactCnt (r13) for loop nesting.
; This is allowed since label and factoring mechanisms are never used mixed.

msklabL: dq 0x00000000ffffffff
msklabH: dq 0xffffffff00000000

lClear:	mov qword LblNxtNew, 0x145a
	ret

LblNew:	mov eax, LblNxtNew		; get fresh new label, upper dw is 0
	and rFactCnt, [msklabH]		; clear lower dword
	or rFactCnt, rax		; combine the lot
	inc dword LblNxtNew		; create a new label for next time
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret

LblCls:
LblUse:	mov rax, rFactCnt
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret
;---------------	
LblPush:
	mov rax, LblNxtNew
	shl rax, 32
	and rFactCnt, [msklabL]
	or rFactCnt, rax
	ret

LblTop: mov rax, rFactCnt
	shr rax, 32
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret

LblDrop:ret		; will autimatically drop when leaving context level

pOutLbl:
	pop rsi		; store as with LblTop, but avoid doubles
	xor rax, rax
	cld
	lodsb
	mov ecx, eax
	mov rdx, rcx	; rdx = len str
	mov rdi, rOutPnt
	rep movsb
	push rsi	; 4ret

	mov rax, rFactCnt
	shr rax, 32	; rdi is start add
	call Bin2Hex
	mov al, ":"
	cld
	stosb
				; delete double labels.
	mov rOutPnt, rdi
	dec rdi			; rdi = pntr to last char
	mov rcx, rdx
		
	add rcx, 5	; = len(inline lblprefix) + len(4d hex ID) + len(":")
	mov rsi, rdi
	sub rsi, rcx
	std			; pOutLbl leaves direction flag set !
	repe cmpsb
	jne nomatch
	inc rdi
	mov rOutPnt, rdi	; ignore 2nd label.

nomatch:inc rcx			; pOk=true in all cases
	ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;                            Parameters over stack
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	
sPush:	; ~(s_inline_code) S		only on asm level
	; Do: Put inline string on stack (add ending 08 or 00)
	; Eg: Call sPush
	;	db "5. ".txt"
	; not yet to be used in bnf level, maybe add to exception list as sOut
	pop rsi
	xor rax, rax
	cld
	lodsb		; ax = len;
	mov rcx, rax	; rcx = len
	mov rdx, rax	; rdx = len
	inc rdx
	shr rdx, 3
	inc rdx
	shl rdx, 3	; dx = ((dx+1)/8+1)*8
	sub rsp, rdx

	sub rdx, rcx
	dec rdx	
	mov rdi, rsp
	stosb		; len stored on bos
	jrcxz .sP1
	
	rep movsb	; s stored on stack

.sP1:	mov rcx, rdx	; cx = len
	xor ax, ax
	rep stosb	; 0 filled to allign stack
	inc rcx
	jmp rsi

;------------------------------------------------------------------------------
sPushA:	; ~(a)s	Push addressed string alligned on stack				; todo merge with sCLArg in Kernel
	; In:	address on stack
	; Out:	string found at address. (string ends with zero byte)
	; used:	rax, rbx, rdx, rdi, rsi

	pop rbx		; rbx = 4ret
	pop rsi		; address of string in memory
	push rsi
	xor cx, cx	; 1. find out length
	dec cx
.sPA1:	inc cx
	cld
	lodsb
	or al, al
	jnz .sPA1	; cx = len(CLAargument)
			; 2. 8 byte allign (LSB of add = 0 or 8)
	mov rax, rcx	; ax = len
	mov rdx, rax	; dx = len
	inc rdx
	shr rdx, 3
	inc rdx
	shl rdx, 3	; dx = ((dx+1)/8+1)*8
	pop rsi		;  address of string in memory
	sub rsp, rdx

	sub rdx, rcx	; 3. move the string on stack
	dec rdx	
	mov rdi, rsp
	stosb		; len stored on bos
	rep movsb	; s stored on stack
			; zero fill rest of stack space
	mov cx, dx	; cx = len
	xor ax, ax
	rep stosb	; 0 filled until stack 8 byte aligned
	inc rcx
	jmp rbx

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;                        	OUTPUT
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pOut:	; Append inline string to Out.
	; Examples:	call pOut
	;		 db 6, "Hello!"
	; In EBNF: 	pOut("Hello!"), pOut("Hi ","there")
	; Note:	pOut(sVariablename) is not allowed!
	pop rsi
	xor rax, rax
	cld
	lodsb			; get length in rcx
	mov ecx, eax
	mov rdi, rOutPnt
add rax, rdi
cmp rax, OutBufEnd
jae pOutErr
	rep movsb
	mov rOutPnt, rdi
;	cmp rdi, OutBufEnd	; dan is t te laat!
;	jae pOutErr
	inc rcx
	jmp rsi

pOutErr:
	call ErrorMessage
	 db 22, "Output buffer overflow"

;Last In-------------------------------
pOutLI:	; Append last parsed string to Out.
	mov rcx, rLastInLen
	jrcxz .pO1
	mov rsi, rLastIn
	mov rdi, rOutPnt
	cld
mov rax, rcx
add rax, rdi
cmp rax, OutBufEnd
jae pOutErr
	rep movsb
	mov rOutPnt, rdi
.pO1:	inc rcx
	ret
;--------------------------------------
pOutLILen:
	; Append length of last parsed string to Out.
	; The length is in hex format
	mov rax, rLastInLen
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret
;Previous In --------------------------
pOutPILen:
	; Append length of last parsed string to Out.
	; The length is in hex format
	mov rax, InPrevLen
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret
	
;--------------------------------------
pOutPI:	; Append last parsed string to Out
	mov rcx, InPrevLen		; no zero LI?
	mov rsi, InPrev
	mov rdi, rOutPnt
	cld
	rep movsb
	mov rOutPnt, rdi
	inc rcx
	ret
	
;0 Hold In-----------------------------		
pHI0:	; Hold last parsed string in vault 0
	; Each thread may reference up to 6 strings.
	mov InHoldLen0, rLastInLen
	mov InHold0, rLastIn
	ret
pOutHI0:
	mov rdx, rcx
	mov rcx, InHoldLen0
	jrcxz .pOHI
	mov rsi, InHold0
	mov rdi, rOutPnt
	cld
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
.pOHI:	ret

pOutHILen0:
	mov rax, InHoldLen0
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret

;1-------------------------------------
pHI1:	; Hold last parsed string in vault 1
	mov InHoldLen1, rLastInLen
	mov InHold1, rLastIn
	ret

pOutHI1:
	mov rdx, rcx
	mov rcx, InHoldLen1
	jrcxz .pOHI
	mov rsi, InHold1
	mov rdi, rOutPnt
	cld
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
.pOHI:	ret

pOutHILen1:
	mov rax, InHoldLen1
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret

;2-------------------------------------
pHI2:	; Hold last parsed string in vault 2
	mov InHoldLen2, rLastInLen
	mov InHold2, rLastIn
	ret

pOutHI2:
	mov rdx, rcx
	mov rcx, InHoldLen2
	jrcxz .pOHI
	mov rsi, InHold2
	mov rdi, rOutPnt
	cld
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
.pOHI:	ret

pOutHILen2:
	mov rax, InHoldLen2
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret
	
;3-------------------------------------	
pHI3:	; Hold last parsed string in vault 3
	mov InHoldLen3, rLastInLen
	mov InHold3, rLastIn
	ret

pOutHI3:
	mov rdx, rcx
	mov rcx, InHoldLen3
	jrcxz .pOHI
	mov rsi, InHold3
	mov rdi, rOutPnt
	cld
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
.pOHI:	ret

pOutHILen3:
	mov rax, InHoldLen3
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret
;4-------------------------------------
pHI4:	; Hold last parsed string in vault 4
	mov InHoldLen4, rLastInLen
	mov InHold4, rLastIn
	ret

pOutHI4:
	mov rdx, rcx
	mov rcx, InHoldLen4
	jrcxz .pOHI
	mov rsi, InHold4
	mov rdi, rOutPnt
	cld
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
.pOHI:	ret

pOutHILen4:
	mov rax, InHoldLen4
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret
;5-------------------------------------
pHI5:	; Hold last parsed string in vault 5
	mov InHoldLen5, rLastInLen
	mov InHold5, rLastIn
	ret

pOutHI5:
	mov rdx, rcx
	mov rcx, InHoldLen5
	jrcxz .pOHI
	mov rsi, InHold5
	mov rdi, rOutPnt
	cld
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
.pOHI:	ret

pOutHILen5:
	mov rax, InHoldLen5
	mov rdi, rOutPnt
	call Bin2Hex
	mov rOutPnt, rdi
	ret
	
 sHI5:	pop rbx
	mov rdx, InHoldLen5
	inc rdx
	shr rdx, 3
	inc rdx
	shl rdx, 3
	mov rdi, rsp
	sub rdi, rdx
	mov rsp, rdi
	xor rcx, rcx
	mov rcx, InHoldLen5
	mov al, cl
	cld
	stosb			; len on stack
	mov rsi, InHold5
	rep movsb		; string on stack
	mov al, cl		; delimit with 0
	stosb
	inc rcx			; pOk true
	jmp rbx
;------------------------------------------------------------------------------
pOutLIHex2Bin:
	mov rsi, rLastIn
	mov rdi, rOutPnt
	cld
	lodsw
	call Hex2Bin	
	stosb
	mov rOutPnt, rdi
	ret
;--------------------------------------
pOutLITrim:
	mov rdx, rcx
	cld
	mov rcx, rLastInLen
	mov rsi, rLastIn
	mov rdi, rOutPnt
pOLIT1:	jrcxz pOLIT2
	dec rcx
	lodsb
	cmp al, "0"
	je pOLIT1
			; last is not zero
	stosb		; so it is stored
	jrcxz pOLIT3	; are there more
			; there is a rest
	rep movsb	; so rest is are moved
pOLIT3:			; no rest
	mov rOutPnt, rdi ; done
	mov rcx, rdx
	ret
pOLIT2: 		; all were 0! (or string was empty, then strange)
	mov al, "0"	; to cover also the case if str is empty
	stosb		; so store the zero
	mov rOutPnt, rdi	
	mov rcx, rdx
	ret
;--------------------------------------
pOutLIdpTrim:
	mov rdx, rcx
	mov rsi, rLastIn	; = len, number;
	mov rcx, rLastInLen	; len of the number + 1
	mov rdi, rOutPnt

	cld
	lodsb			; number of decimals after decimal point
	xor rbx,rbx
	mov bl, al
	sub bl, 030h
	cmp rcx, rbx
	jl .T5
.T1:	
	jrcxz .T2
	dec rcx
	 cmp cl, bl
	 je .T4
	lodsb
	cmp al, "0"
	je .T1		; if an="0" then skip input

	dec rsi
.T3	jrcxz .T5
	movsb
	dec rcx
	cmp cl, bl
	jg .T3
	
	mov al, "."
	stosb
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
	ret

.T2	mov rax, "0.00"
	stosd
	mov rOutPnt, rdi
	mov rcx, rdx
	ret
	
.T4	mov ax, "0."
	stosw
	rep movsb
	mov rOutPnt, rdi
	mov rcx, rdx
	ret
	
.T5	mov rax, "-dp err-"
	stosq
	mov rOutPnt, rdi
	mov rcx, rdx
	ret
;--------------------------------------
pOutCr: mov byte [rOutPnt], 10
	inc rOutPnt
	ret
;--------------------------------------
pOutLIHex:
	mov rsi, rLastIn
	mov rdx, rLastInLen
	mov rdi, rOutPnt
pOutLIH2:
	lodsb
	push rsi
	call Bin1Hex
	pop rsi
	
;	mov al, " "
;	stosb
	
	dec rdx
	jnz pOutLIH2

pOutLIH1:
	mov rOutPnt, rdi
	ret

;-------------------------------  still required ?????
pOutInPnt:	; used by tls to append to sOut the binary pointer pIntPnt
		; as quad
		mov rdi, rOutPnt
		mov rax, rInPnt
		sub rax, In0
		cld
		stosq
		mov rOutPnt, rdi
		ret
;-------------------------------
pOutLILenByte:	; used by tls to append to sOut the binary length of last in
		; as byte
		mov rdi, rOutPnt
		mov rax, rLastInLen
		cld
		stosb
		mov rOutPnt, rdi
		ret
; -----------------------------------------------------------------------------
OutSrcLin:
	mov rsi, InPntOld     
	mov rdi, rOutPnt
	cld
OutSL2:	mov ax, 0x3B0A
	stosw
OutSL1:	cmp rsi, rInPnt
	je OutSL3
	
	lodsb
	cmp al,0x0A
	je OutSL2

	stosb
	jmp OutSL1

OutSL3:	dec rdi
	mov rOutPnt, rdi
	ret

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;				CONVERSIONS
;	Bin1Hex, Bin2Hex,Bin2Dec, Bin4Dec, BinNDec, Dec2Bin, Hex2Bin
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Bin1Hex:; convert 1 byte binary to hex (2 byte).
	; in: al byte, rdi = address for output
	; out: hex digit at [rdi]
	; uses: aiHex (array), rax, rbx, rsi
	mov rsi, aiHex
	xor rbx, rbx
	mov bl, al
	mov rax, rbx
	shr al, 4
	mov al, [rsi+rax]
	cld		
	stosb
	mov al, bl
	and al, 0x0f
	mov al, [rsi+rax]
	stosb
	ret

;--------------------------------------
aiHex:	db	"0123456789ABCDEF"

Bin2Hex:	;
	; convert 2 bytes binary to 4 char hex string
	; in: ax (ah=MSByte, al=LSByte), rdi = add for output
	; out: at [rdi]; MS hex digit at lowest mem
	mov rsi, aiHex	; aiHex= array of 16 byte chars used for conversion
	add rdi, 03
	push rdi
	std		; so watch out leaves directio bit as such!

	mov bx, ax
	and rax, 0x0f
	mov al, [rsi+rax]
	stosb

	shr rbx, 4
	mov rax, rbx
	and rax, 0x0f
	mov al, [rsi+rax]
	stosb

	shr rbx, 4
	mov rax, rbx
	and rax, 0x0f
	mov al, [rsi+rax]
	stosb

	shr rbx, 4
	mov rax, rbx
	and rax, 0x0f
	mov al, [rsi+rax]
	stosb

	pop rdi
	inc rdi
	ret
;--------------------------------------
BinNHex:	; in:	on stack: X= Bin value, N =1..16 number of Hex chars
		; do: 	cvt Bin to Hex format with N chars in Out
		; out:  appended to Out the N chars long Hex format in GE
		;	If too small pad left with "0" 
		; 	If too long drop MS part
		;	Hex uses uppercase ("A" to "F")

; 1. prepare fields with zero's
	pop rbx			; return address
	mov rdi, rOutPnt
	cld
	mov al, "0"
	pop rcx			; =N
	and rcx, 0x1f		; safety: max 31 hex char output
	mov rdx, rcx		; rcx = rdx = N
	rep stosb		; rdi pnts to 1st non filled
	dec rdi			; pnts to the lsd to be calculated
	
	pop rax			; =X
	push rbx		; 4ret

; 2. convert rax niblles to hex digits

.bnh1:	cmp rdi, rOutPnt
	jl .bnh2
	mov	bl, al
	and 	bl, 0x0F
	add	bl, "0"
	cmp 	bl, "9"
	jbe	.bnh3
	add	bl,"A"-"9"-1
	
.bnh3:	mov [rdi], bl
	shr rax, 4		; rax=X' = X' / 2^4 
	dec rdi
	dec rcx			; rcx=N' := N'-1
	jnz .bnh1

.bnh2:	add rOutPnt, rdx	; extend sOut with N chars
	xor rcx, rcx
	inc rcx
	ret

;--------------------------------------
Bin2Dec:
	; convert one byte value to decimal bcd unpacked
	; in:	rax (< 0x100)
	; out:	at [rdi] in GE, at [rdi +4] in LE order
	; uses:	rbx, rsi
	xor rbx, rbx
	mov bl, al
	and al, 0x0f
	cmp al, 10
	jl Bin2D4
	add rax, 0xf6
Bin2D4:	and bl, 0xf0
	shr bl, 2
	mov rsi, aMul16
	add eax, [rsi+rbx]
	cmp al, 10
	jl Bin2D1
	add rax, 0x100
	sub al, 10
Bin2D1:	cmp ah, 10
	jl Bin2D2
	add rax, 0x010000
	sub ah, 10
Bin2D2:	add eax,"0000"
	mov [rdi+4], eax
	mov bl, [rdi+6]
	cmp bl, "0"
	je Bin2D3
	mov [rdi], bl
	inc rdi
Bin2D3: mov [rdi], ah
	inc rdi
	cld
	stosb
	ret
	
aMul16:	db 0,0,0,0, 6,1,0,0, 2,3,0,0, 8,4,0,0, 4,6,0,0, 0,8,0,0, 6,9,0,0, 2,1,1,0
	;  0        1        2        3        4        5        6        7
	db 8,2,1,0, 4,4,1,0, 0,6,1,0, 6,7,1,0, 2,9,1,0, 8,0,2,0, 4,2,2,0, 0,4,2,0
	;  8        9        A        B        C        D        E        F

;------------------------------------------------------------------------------

Bin4Dec:	; in:	rax=X binary value 4 byte LSB, MSB is ingored,
		; do: 	cvt X to decimal value in N=10 ascii digits format at rdi
		; out:  append to [rdi] the N digit value of X
		;	pad left with "0" if too small
		; 	truncate left if too big
		
; 1. prepare fields with zero's (can also be spaces)
	push	rcx
	push	rax
	mov	rsi, rdi
	cld
	mov	al, "0"
	mov	rcx, 10		; max 10 digits significant
	mov	rdx, rcx
	rep	stosb		; rdi pnts to 1st non filled
	dec	rdi			; pnts to the lsd to be calculated
	
	pop	rax
	mov	rbx, 10		; rbx = max number of digits to cvt

; 2. convert rax to ascii decimal (20 digits)
	mov	rcx, 10		; divisor
.B4D1:	cmp	rdi, rsi
	jl 	.B4D2
	xor	rdx, rdx
	div	rcx		; rax = quotient of rdx:rax/100, rdx = remainder
	add	byte [rdi], dl
	dec	rdi
	or	rax, rax	; check if last digit done = quotient is zero
	jnz .B4D1

.B4D2:	pop	rcx
	ret

;------------------------------------------------------------------------------

BinNDec:	; in:	on stack: X binary value 8 bytes, N=number of digits
		; do: 	cvt X to decimal value in N decimal digits (=N chars)
		; out:  append to Out the N decimal digits value of X
		;	If to small padded left with "0" 
		; 	If to big truncated left (MS part)

; 1. prepare fields with zero's
	pop rbx			; return address
	mov rdi, rOutPnt
	cld
	mov al, "0"
	pop	rcx		; =N
	and	rcx, 0x1f	; max 31 digits, but max only then 20 filled
	mov	rdx, rcx
	rep	stosb		; rdi pnts to 1st non filled
	dec	rdi		; pnts to the lsd to be calculated
	
	pop	rax		; =X
	push	rbx		; on stack return address
	mov	rbx, rdx	; rbx = max number of digits to out

; 2. convert rax to ascii decimal (20 digits)
	mov	rcx, 10
.BND1:	cmp	rdi, rOutPnt
	jl	.BND2
	xor	rdx, rdx
	div	rcx		; rax = quotient of rdx:rax/100, rdx = remainder
	add	byte [rdi], dl
	dec	rdi
	or	rax, rax	; check if last digit done = quotient is zero
	jnz	.BND1

.BND2:	add	rOutPnt, rbx
	xor	rcx, rcx
	inc	rcx
	ret
;------------------------------------------------------------------------------
Dec2Bin:	;
	; Decimal ascii (at rLastIN) to binary (in rax)
	; msb to lsb
	; in: rLastIn, rLastinLen
	; out: rax = 8b binary value of ascii decimals at rLastIn
	; uses: rdi, rsi, rdx, rax, rbx, rcx=1
	mov	rsi, rLastIn
	mov	rcx, rLastInLen
	mov	rdi, 10		; rdx used by mul-operator! 
	xor	rax, rax
	xor	rbx, rbx
	cld
Dec2B2:
	lodsb
	sub	al, 0x30
	cmp	al, 10
	jge	Dec2BEr1
	add	rax, rbx
	jc	Dec2BEr1
	
	dec	ecx
	jz	Dec2B1

	mov	rdx, rdi
	mul	edx
	mov	rbx, rax
	jmp	Dec2B2

Dec2B1:
	inc	rcx
	ret

Dec2BEr1:
	mov	rax, 01	
	xor	rcx, rcx
	ret
									; todo?
	call	ErrorMessage
	 db 27, 'Overflow decimal conversion'
	
; -----------------------------------------------------------------------------
Hex2Bin:	;
	; convert 2 hex ascii digits to bin value
	; in: ax with ah = MSDigit, al = LSDigit
	; out: al
	sub ah, 0x30
	jc Hex2BErr
	cmp ah, 0x09		; 0..9? (30-39)
	jle Hex2B1
	sub ah, 0x07
	jc Hex2BErr
	cmp ah, 0x0F		; A..F? (41..46)
	jle Hex2B1
	sub ah, 0x20
	jc Hex2BErr
	cmp ah, 0x0F		; a..f? (61..66)
	jg Hex2BErr
Hex2B1:
	sub al, 0x30
	jc Hex2BErr
	cmp al, 0x09		; 0..9? (30-39)
	jle Hex2B2
	sub al, 0x07
	jc Hex2BErr
	cmp al, 0x0F		; A..F? (41..46)
	jle Hex2B2
	sub al, 0x20
	jc Hex2BErr
	cmp al, 0x0F		; a..f? (61..66)
	jg Hex2BErr
Hex2B2:	
	shl al, 4
	add al, ah
	ret
	
Hex2BErr:
	call ErrorMessage
	 db 39, "Illegal input during Hex2Bin conversion"

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;                        	   FILING
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

;-------------- File descriptors ----------------------------------------------
stdin		equ	0		; nu
stdout		equ	1
stderr		equ	2		; nu

;-------------- FileSyscall (some common used)---------------------------------
sys_read	equ	0
sys_write	equ	1
sys_open	equ	2
sys_close	equ	3
sys_stat	equ	4	; in: rdi= pnt_filename,
				; rsi= pnt struct stat *statbuf
sys_fstat	equ	5	; in: rdi= fd, rsi= pnt struct stat *statbuf
sys_lseek	equ	008
sys_create	equ	085
sys_unlink	equ	087	; = delete file

;-------------- FileFlag-------------------------------------------------------
O_RDONLY	equ	00000q	; request open with read only
O_WRONLY	equ	00001q
O_RDWR		equ	00002q
O_SHLOCK	equ	00020q	; ? open with share file lock
O_EXLOCK	equ	00040q	; ? open with exclusive file lock
O_CREAT		equ	00100q	; = 0x0040
O_EXCL		equ	00200q	; in combination with O_CREATE,
				; if the file exits, do not open it
O_TRUNC		equ	01000q	; = 0x0200
O_APPEND	equ	02000q	; = 0x0400
O_NONBLOCK	equ	04000q	; open file in non blocking mode-sensitive
O_SYNC		equ	10000q	; allow only one write at a time ??
O_ASYNC		equ	20000q	; allow multiple writes at a time

;-------------- FilePermission-------------------------------------------------
PermUR		equ	0400q
PermUW		equ	0200q
PermUX		equ	0100q
PermURW		equ	0600q	; create / overwrite if exists
PermARW		equ	0666q	; all read write
PermARWX	equ	0777q

				; FileSeekWhence
SEEK_SET	equ	0	; offset from start of file
SEEK_CUR	equ	1	; offset from current offset
SEEK_END	equ	2	; offset from end of file, so over the edge


;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;		Display EBNF context (for debugging) (delete in PROD)
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
dspebnf:	; dspebnf shows the status of the EBNF parser.

	call Message			; display pOK
	 db 14, 10, "Context: pOk="
	jrcxz dspeb1
	call Message
	 db 4,  "True"
	jmp dspeb2
dspeb1: call Message
	 db 5,  "False"
dspeb2:

	call Message			; display InEnd
	 db 7, " InEnd="
	 or rInEndFlg, rInEndFlg
	jz dspeb3
	call Message
	 db 5,  "True",10
	jmp dspeb4
dspeb3: call Message
	 db 6,  "False",10
dspeb4:
					; display sIn + sInPnt position
	mov rsi, rInPnt
	sub rsi, 0x40
	cmp rsi, mMem0
	jl .de1
	call dmphexrsi
.de1:	call Message
	 db 8, "<InPnt>", 10
	mov rsi, rInPnt
	call dmphexrsi
	
	call Message
	 db 5,  "Out:",10	
					; display sOut + sOutPnt position
	mov rsi, rOutPnt
	sub rsi, 0x40
	cmp rsi, mMem0
	jl .de2
	call dmphexrsi
.de2:	call Message
	 db 9, "<OutPnt>", 10
	mov rsi, rOutPnt
	call dmphexrsi

					; display LastIn and LastInLen
	call Message
	 db 10, "LastIn    "
	call dsprex
	 db "r11"

	call Message
	 db 10, "LastInLen "
	call dsprex
	 db "r12"

	call Message
   	 db 1, 34
	mov rsi, rLastIn
	mov rdx, rLastInLen
	mov rax,1
	mov rdi,1
	push rcx	; retain rcx=rPOk
	push r11	; retain r11=LastIn
	syscall
	pop r11
	pop rcx
	call Message
   	 db 2, 34, 10

   	  push r14

	call Message
	 db 10, "InBeg     "
	 mov r14, In0
   	call dsprex
	 db "r14"

	call Message
	 db 10, "InEnd     "
	 mov r14, rInEnd
   	call dsprex
	 db "r14"

	call Message
	 db 10, "InPntMax  "
	 mov r14, InPntMax
   	call dsprex
	 db "r14"

	call Message
	 db 10, "OutBeg    "
	 mov r14, Out0
   	call dsprex
	 db "r14"

	call Message
	 db 10, "OutBufEnd "
	 mov r14, OutBufEnd
   	call dsprex
	 db "r14"

	call Message
	 db 10, "LblNxtNew "
	 mov r14, LblNxtNew
   	call dsprex
	 db "r14"

	  pop r14

ret


