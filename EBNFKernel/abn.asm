
;******************************************************************************
;			Data Primitives
; EBNF terminals that ar coded directly into assembly for fast execution.
; Version 0.1	220807
; Version 0.2	240323	2x faster: removed cpush and cdrop
; Supports:
;	a	= "A".."Z"| "a".."z";	alfabetic
;	b	= ^0..^255;		byte
;	n	= "0".."9";		numeric digit
;	sIFSF	= "="| "?"| "_";	special character ifsf (s is taken by nasm)

GLOBAL a, b, n, sIFSF
GLOBAL LILENMax, LIVALMax
;******************************************************************************

a:	; a = "A".."Z"| "a".."z";	alfabetic

	mov al, [rInPnt]
	cmp al, 0x41	; "A"
	jb .aNOk
	cmp al, 0x7A	; "z"
	ja .aNOk
	cmp al, 0x5A	; "Z"
	jbe b
	cmp al, 0x61	; "a"
	jae b
	
.aNOk:	xor rPOk, rPOk
	ret
;--------------------------------------

b:	; b = ^0..^255;		byte

	xor rPOk, rPOk
	cmp rInPnt, rInEnd	; InPnt at end parsed text? rPok = false!
	jae .bEnd
	
	inc rPOk
	mov InPntMax, rInPnt
	mov rLastIn, rInPnt
	mov rLastInLen, rPOk
	inc rInPnt
	cmp rInPnt, rInEnd	; InPnt at end parsed text?
	jb .bEnd
	
	inc rInEndFlg
.bEnd:	ret
;--------------------------------------

n:	; n = "0".."9"		numeric digit

	mov al, [rInPnt]
	cmp al, 0x30	; "0"
	jb .nNOk
	cmp al, 0x39	; "9"
	jbe b

.nNOk:	xor rPOk, rPOk
	ret
;--------------------------------------

sIFSF:	; sIFSF = "="|"?"|"_";	special sign in IFSF

	mov al, [rInPnt]
	cmp al, "="
	je b			; can also call .nOk and skip .sOk
	cmp al, "?"
	je b
	cmp al, "_"
	je b

	xor rPOk, rPOk
	ret
;--------------------------------------

 LILenMax:	; use in bnf: ~(m)
 		; do:	If length of LI > m then rPOK=F else rPOK=T
 	pop rbx
 	pop rax
 	xor rcx, rcx
 	cmp rLastInLen, rax
 	ja .LILM
 	inc rcx
 .LILM:	jmp rbx
 	
LIValMax:	; use in bnf:	~(v)
 		; do:	If integer value of LI > v then rPOK=F else rPOK=T
	call Dec2Bin		; integer value of decimal LI
	pop rbx
	pop rdx
 	xor rcx, rcx
 	cmp rax, rdx
 	ja .LIVM
 	inc rcx
 .LIVM:	jmp rbx
	
	
	
	
	
	
