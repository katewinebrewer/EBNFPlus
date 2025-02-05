

%include "../EBNF/EBNFix.asm"

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Rum:
	call cPush
	call Message
	 db 0x0A, 'Starting..'
	or rPOk, rPOk
	jnz SD0000
	jmp SDEnd0000
SD0000:
	push 1
	call sCLArg
	call sPush
	 db 0x0004, '.bnf'
	call sConcat
	call F2I
	or rPOk, rPOk
	jnz SD0001
	jmp SDEnd0000
SD0001:
	call Message
	 db 0x1F, 'Loaded source..Compiled items: '
	or rPOk, rPOk
	jnz SD0002
	jmp SDEnd0000
SD0002:
	push Grammar
	call I2O
	or rPOk, rPOk
	jnz SD0003
	jmp SDEnd0000
SD0003:
	call Message
	 db 0x0C, 'Grammar OK..'
	or rPOk, rPOk
	jnz SD0004
	jmp SDEnd0000
SD0004:
	push 1
	call sCLArg
	call sPush
	 db 0x0004, '.asm'
	call sConcat
	call O2F
	or rPOk, rPOk
	jnz SD0005
	jmp SDEnd0000
SD0005:
	call Message
	 db 0x16, 'Saved object.. Done !', 0x0A
SDEnd0000:
	jrcxz DL0006
	jmp DLEnd0006
DL0006:	inc rcx
	call cTop
	call ErrorMessage
	 db 0x0E, 'Aj, some error'
DLEnd0006:
	call cDrop
	ret

;Rum	 = 	Message('Starting..')	, F2I (sConcat(sCLArg(1),'.bnf'))	, Message('Loaded source..Compiled items: ')
;					, I2O (*Grammar)			, Message('Grammar OK..')
;					, O2F (sConcat(sCLArg(1),'.asm'))	, Message('Saved object.. Done !', 0x0A)
;    					| ErrorMessage('Aj, some error');
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GrammarEOF:
	call cPush
	call Grammar
	or rPOk, rPOk
	jnz SD0007
	jmp SDEnd0007
SD0007:
	call EOF
SDEnd0007:
	call cDrop
	ret

;GrammarEOF = Grammar, EOF;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pLetter:
	call cPush
	call pInterval
	 db 'a', 'z'
	jrcxz DL0008
	jmp DLEnd0008
DL0008:	inc rcx
	call cTop
	call pInterval
	 db 'A', 'Z'
	jrcxz DL0009
	jmp DLEnd0008
DL0009:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "_"
DLEnd0008:
	call cDrop
	ret

;pLetter		= 'a'..'z' | 'A'..'Z' | "_" ;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pDigit:
	call cPush
	call pInterval
	 db '0', '9'
	call cDrop
	ret

;pDigit		= '0'..'9';

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pSymbol:
	call cPush
	call pIn
	 db 0x0001, '['
	jrcxz DL000A
	jmp DLEnd000A
DL000A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, ']'
	jrcxz DL000B
	jmp DLEnd000A
DL000B:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '{'
	jrcxz DL000C
	jmp DLEnd000A
DL000C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '}'
	jrcxz DL000D
	jmp DLEnd000A
DL000D:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '('
	jrcxz DL000E
	jmp DLEnd000A
DL000E:	inc rcx
	call cTop
	call pIn
	 db 0x0001, ')'
	jrcxz DL000F
	jmp DLEnd000A
DL000F:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '<'
	jrcxz DL0010
	jmp DLEnd000A
DL0010:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '>'
	jrcxz DL0011
	jmp DLEnd000A
DL0011:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '='
	jrcxz DL0012
	jmp DLEnd000A
DL0012:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '|'
	jrcxz DL0013
	jmp DLEnd000A
DL0013:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '.'
	jrcxz DL0014
	jmp DLEnd000A
DL0014:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '!'
	jrcxz DL0015
	jmp DLEnd000A
DL0015:	inc rcx
	call cTop
	call pIn
	 db 1, 35
	jrcxz DL0016
	jmp DLEnd000A
DL0016:	inc rcx
	call cTop
	call pIn
	 db 0x0001, ','
	jrcxz DL0017
	jmp DLEnd000A
DL0017:	inc rcx
	call cTop
	call pIn
	 db 0x0001, ';'
	jrcxz DL0018
	jmp DLEnd000A
DL0018:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '+'
	jrcxz DL0019
	jmp DLEnd000A
DL0019:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '-'
	jrcxz DL001A
	jmp DLEnd000A
DL001A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, ':'
	jrcxz DL001B
	jmp DLEnd000A
DL001B:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '&'
	jrcxz DL001C
	jmp DLEnd000A
DL001C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '^'
	jrcxz DL001D
	jmp DLEnd000A
DL001D:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '*'
	jrcxz DL001E
	jmp DLEnd000A
DL001E:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '\'
	jrcxz DL001F
	jmp DLEnd000A
DL001F:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '_'
	jrcxz DL0020
	jmp DLEnd000A
DL0020:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '?'
	jrcxz DL0021
	jmp DLEnd000A
DL0021:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '@'
	jrcxz DL0022
	jmp DLEnd000A
DL0022:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '/'
	jrcxz DL0023
	jmp DLEnd000A
DL0023:	inc rcx
	call cTop
	call pIn
	 db 1, 36
	jrcxz DL0024
	jmp DLEnd000A
DL0024:	inc rcx
	call cTop
	call pIn
	 db 1, 37
DLEnd000A:
	call cDrop
	ret

;pSymbol 	= '[' | ']' | '{' | '}' | '(' | ')' | '<' | '>' | '=' | '|' | '.' |
;		  '!' | ^35 | ',' | ';' | '+' | '-' | ':' | '&' | '^' | '*' | '\' |
;		  '_' | '?' | '@' | '/' | ^36 | ^37 ;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pCtrlChar:
	call cPush
	call pIn
	 db 1, 09
	jrcxz DL0025
	jmp DLEnd0025
DL0025:	inc rcx
	call cTop
	call pIn
	 db 1, 10
	jrcxz DL0026
	jmp DLEnd0025
DL0026:	inc rcx
	call cTop
	call pIn
	 db 1, 13
DLEnd0025:
	call cDrop
	ret

;pCtrlChar	= ^09 | ^10 | ^13 ;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pCharacter:
	call cPush
	call pLetter
	jrcxz DL0027
	jmp DLEnd0027
DL0027:	inc rcx
	call cTop
	call pDigit
	jrcxz DL0028
	jmp DLEnd0027
DL0028:	inc rcx
	call cTop
	call pSymbol
	jrcxz DL0029
	jmp DLEnd0027
DL0029:	inc rcx
	call cTop
	call pCtrlChar
	jrcxz DL002A
	jmp DLEnd0027
DL002A:	inc rcx
	call cTop
	call pIn
	 db 0x0001, " "
DLEnd0027:
	call cDrop
	ret

;pCharacter	= pLetter| pDigit| pSymbol| pCtrlChar| " ";

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pHexChar:
	call cPush
	call pInterval
	 db '0', '9'
	jrcxz DL002B
	jmp DLEnd002B
DL002B:	inc rcx
	call cTop
	call pInterval
	 db 'a', 'f'
	jrcxz DL002C
	jmp DLEnd002B
DL002C:	inc rcx
	call cTop
	call pInterval
	 db 'A', 'F'
DLEnd002B:
	call cDrop
	ret

;pHexChar	= '0'..'9' |'a'..'f'| 'A'..'F';

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pComment:
	call cPush
	call pIn
	 db 0x0002, '/*'
	or rPOk, rPOk
	jnz SD002D
	jmp SDEnd002D
SD002D:
	call cPush
RSRep0030:
	call cPush
	call pInterval
	 db 0, 255
	or rPOk, rPOk
	jnz ExChk0031
	jmp ExEnd0031
ExChk0031:
	call cPush
	sub rInPnt, rLastInLen
	call pIn
	 db 0x0002, '*/'
	call cDropExcept
ExEnd0031:
	call cDrop
	jrcxz RSEnd0030
	or rInEndFlg, rInEndFlg
	jnz RSEnd0030
	jmp RSRep0030
RSEnd0030:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0032
	jmp SDEnd002D
SD0032:
	call pIn
	 db 0x0002, '*/'
SDEnd002D:
	call cDrop
	ret

;pComment	= '/*' , {^0..^255-'*/'} , '*/' ;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pCode:
	call cPush
	call cPush
	call cPush
KSRep0033:
	call cPush
	call pIn
	 db 0x0002, '<<'
	or rPOk, rPOk
	jnz SD0034
	jmp SDEnd0034
SD0034:
	call cPush
RSRep0037:
	call cPush
	call pInterval
	 db 0, 255
	or rPOk, rPOk
	jnz ExChk0038
	jmp ExEnd0038
ExChk0038:
	call cPush
	sub rInPnt, rLastInLen
	call pIn
	 db 0x0002, '>>'
	call cDropExcept
ExEnd0038:
	call cDrop
	jrcxz RSEnd0037
	or rInEndFlg, rInEndFlg
	jnz RSEnd0037
	jmp RSRep0037
RSEnd0037:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0039
	jmp SDEnd0034
SD0039:
	call pOut
	 db 1, 10
	call pOutLI
	or rPOk, rPOk
	jnz SD003A
	jmp SDEnd0034
SD003A:
	call pIn
	 db 0x0002, '>>'
	or rPOk, rPOk
	jnz SD003B
	jmp SDEnd0034
SD003B:
	call cPush
RSRep003E:
	call cPush
	call pCtrlChar
	jrcxz DL003F
	jmp DLEnd003F
DL003F:	inc rcx
	call cTop
	call pIn
	 db 0x0001, " "
DLEnd003F:
	call cDrop
	jrcxz RSEnd003E
	or rInEndFlg, rInEndFlg
	jnz RSEnd003E
	jmp RSRep003E
RSEnd003E:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd0034:
	call cDrop
	jrcxz KS0033
	or rInEndFlg, rInEndFlg
	jnz KS0033
	jmp KSRep0033
KS0033:
	xor rPOk, rPOk
	cmp rInPnt, [rsp+56]
	jz KSEnd0033
	inc rPOk
KSEnd0033:
	add rsp, 64
	call cDrop
	call cDrop
	ret

;pCode		= {'<<' , {^0..^255-'>>'},					<.	call pOut.>	
;										<.	 db 1, 10.>
;										<.	call pOutLI.>,
;					  '>>' , {pCtrlChar|" "}}*;
;				  

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pCodeCond:
	call cPush
	call cPush
	call cPush
KSRep0040:
	call cPush
	call pIn
	 db 0x0002, '<.'
	or rPOk, rPOk
	jnz SD0041
	jmp SDEnd0041
SD0041:
	call cPush
RSRep0044:
	call cPush
	call pInterval
	 db 0, 255
	or rPOk, rPOk
	jnz ExChk0045
	jmp ExEnd0045
ExChk0045:
	call cPush
	sub rInPnt, rLastInLen
	call pIn
	 db 0x0002, '.>'
	call cDropExcept
ExEnd0045:
	call cDrop
	jrcxz RSEnd0044
	or rInEndFlg, rInEndFlg
	jnz RSEnd0044
	jmp RSRep0044
RSEnd0044:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0046
	jmp SDEnd0041
SD0046:
	call pOut
	 db 1, 10
	call pOutLI
	or rPOk, rPOk
	jnz SD0047
	jmp SDEnd0041
SD0047:
	call pIn
	 db 0x0002, '.>'
	or rPOk, rPOk
	jnz SD0048
	jmp SDEnd0041
SD0048:
	call cPush
RSRep004B:
	call cPush
	call pCtrlChar
	jrcxz DL004C
	jmp DLEnd004C
DL004C:	inc rcx
	call cTop
	call pIn
	 db 0x0001, " "
DLEnd004C:
	call cDrop
	jrcxz RSEnd004B
	or rInEndFlg, rInEndFlg
	jnz RSEnd004B
	jmp RSRep004B
RSEnd004B:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd0041:
	call cDrop
	jrcxz KS0040
	or rInEndFlg, rInEndFlg
	jnz KS0040
	jmp KSRep0040
KS0040:
	xor rPOk, rPOk
	cmp rInPnt, [rsp+56]
	jz KSEnd0040
	inc rPOk
KSEnd0040:
	add rsp, 64
	call cDrop
	call cDrop
	ret

;pCodeCond	= {'<.' , {^0..^255-'.>'},					<.	call pOut.>
;										<.	 db 1, 10.>
;										<.	call pOutLI.>,
;					  '.>' , {pCtrlChar|" "}}*;
;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pS:
	call cPush
	call cPush
RSRep0051:
	call cPush
	call pIn
	 db 0x0001, ' '
	jrcxz DL0052
	jmp DLEnd0052
DL0052:	inc rcx
	call cTop
	call pCtrlChar
	jrcxz DL0053
	jmp DLEnd0052
DL0053:	inc rcx
	call cTop
	call pComment
	jrcxz DL0054
	jmp DLEnd0052
DL0054:	inc rcx
	call cTop
	call pCode
DLEnd0052:
	call cDrop
	jrcxz RSEnd0051
	or rInEndFlg, rInEndFlg
	jnz RSEnd0051
	jmp RSRep0051
RSEnd0051:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	call cDrop
	ret

;pS		= {' ' |pCtrlChar |pComment| pCode};

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pInteger:
	call cPush
	call pDigit
	or rPOk, rPOk
	jnz SD0055
	jmp SDEnd0055
SD0055:
	call cPush
RSRep0057:
	call cPush
	call pDigit
	call cDrop
	jrcxz RSEnd0057
	or rInEndFlg, rInEndFlg
	jnz RSEnd0057
	jmp RSRep0057
RSEnd0057:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd0055:
	call cDrop
	ret

;pInteger	= pDigit, {pDigit};

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pIdentifier:
	call cPush
	call pLetter
	or rPOk, rPOk
	jnz SD0058
	jmp SDEnd0058
SD0058:
	call cPush
RSRep005B:
	call cPush
	call pLetter
	jrcxz DL005C
	jmp DLEnd005C
DL005C:	inc rcx
	call cTop
	call pDigit
DLEnd005C:
	call cDrop
	jrcxz RSEnd005B
	or rInEndFlg, rInEndFlg
	jnz RSEnd005B
	jmp RSRep005B
RSEnd005B:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd0058:
	call cDrop
	ret

;pIdentifier	= pLetter, { pLetter | pDigit } ;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pTerminal:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD005D
	jmp SDEnd005D
SD005D:
	call cPush
	call cPush
	call pIn
	 db 0x0002, '0x'
	or rPOk, rPOk
	jnz SD005E
	jmp SDEnd005E
SD005E:
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd005F
FacRep005F:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd005F
	jz FacEnd005F
	jmp FacRep005F
FacEnd005F:
SDEnd005E:
	call cDrop
	or rPOk, rPOk
	jnz SD0060
	jmp SDEnd0060
SD0060:
	call pOut
	 db 20, 10, 9, "call pIntervalQuad"
	call pOut
	 db 6, 10, 9, ' dq '
	call pOutLI
	or rPOk, rPOk
	jnz SD0061
	jmp SDEnd0060
SD0061:
	call pS
	or rPOk, rPOk
	jnz SD0062
	jmp SDEnd0060
SD0062:
	call pIn
	 db 0x0002, '..'
	or rPOk, rPOk
	jnz SD0063
	jmp SDEnd0060
SD0063:
	call pS
	or rPOk, rPOk
	jnz SD0064
	jmp SDEnd0060
SD0064:
	call cPush
	call pIn
	 db 0x0002, '0x'
	or rPOk, rPOk
	jnz SD0065
	jmp SDEnd0065
SD0065:
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd0066
FacRep0066:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd0066
	jz FacEnd0066
	jmp FacRep0066
FacEnd0066:
SDEnd0065:
	call cDrop
	or rPOk, rPOk
	jnz SD0067
	jmp SDEnd0060
SD0067:
	call pOut
	 db 6, 10, 9, ' dq '
	call pOutLI
SDEnd0060:
	jrcxz DL0068
	jmp DLEnd0068
DL0068:	inc rcx
	call cTop
	call cPush
	call pIn
	 db 0x0002, '0x'
	or rPOk, rPOk
	jnz SD0069
	jmp SDEnd0069
SD0069:
	mov rFactCnt, 16
	or rFactCnt, rFactCnt
	jz FacEnd006A
FacRep006A:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd006A
	jz FacEnd006A
	jmp FacRep006A
FacEnd006A:
SDEnd0069:
	call cDrop
	or rPOk, rPOk
	jnz SD006B
	jmp SDEnd006B
SD006B:
	call pOut
	 db 10, 10, 9, "call pIn"
	call pOut
	 db 13, 10, 9, ' db 8', 10, 9, ' dq '
	call pOutLI
SDEnd006B:
	jrcxz DL006C
	jmp DLEnd0068
DL006C:	inc rcx
	call cTop
	call cPush
	call pIn
	 db 0x0002, '0x'
	or rPOk, rPOk
	jnz SD006D
	jmp SDEnd006D
SD006D:
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd006E
FacRep006E:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd006E
	jz FacEnd006E
	jmp FacRep006E
FacEnd006E:
SDEnd006D:
	call cDrop
	or rPOk, rPOk
	jnz SD006F
	jmp SDEnd006F
SD006F:
	call pOut
	 db 16, 10, 9, "call pInterval"
	call pOut
	 db 6, 10, 9, " db "
	call pOutLI
	call pOut
	 db 2, ", "
	or rPOk, rPOk
	jnz SD0070
	jmp SDEnd006F
SD0070:
	call pS
	or rPOk, rPOk
	jnz SD0071
	jmp SDEnd006F
SD0071:
	call pIn
	 db 0x0002, '..'
	or rPOk, rPOk
	jnz SD0072
	jmp SDEnd006F
SD0072:
	call pS
	or rPOk, rPOk
	jnz SD0073
	jmp SDEnd006F
SD0073:
	call cPush
	call pIn
	 db 0x0002, '0x'
	or rPOk, rPOk
	jnz SD0074
	jmp SDEnd0074
SD0074:
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0075
FacRep0075:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd0075
	jz FacEnd0075
	jmp FacRep0075
FacEnd0075:
SDEnd0074:
	call cDrop
	or rPOk, rPOk
	jnz SD0076
	jmp SDEnd006F
SD0076:
	call pOutLI
SDEnd006F:
	jrcxz DL0077
	jmp DLEnd0068
DL0077:	inc rcx
	call cTop
	call cPush
	call pIn
	 db 0x0002, "0x"
	or rPOk, rPOk
	jnz SD0078
	jmp SDEnd0078
SD0078:
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0079
FacRep0079:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd0079
	jz FacEnd0079
	jmp FacRep0079
FacEnd0079:
SDEnd0078:
	call cDrop
	or rPOk, rPOk
	jnz SD007A
	jmp SDEnd007A
SD007A:
	call pOut
	 db 10, 10, 9, "call pIn"
	call pOut
	 db 8, 10, 9, " db 0x"
	mov r15, rOutPnt
	call pOut
	 db 4, 1, 0, ", "
	call pOutLI
	or rPOk, rPOk
	jnz SD007B
	jmp SDEnd007A
SD007B:
	call cPush
RSRep0081:
	call cPush
	call pIn
	 db 0x0001, " "
	or rPOk, rPOk
	jnz SD0082
	jmp SDEnd0082
SD0082:
	call pS
	or rPOk, rPOk
	jnz SD0083
	jmp SDEnd0082
SD0083:
	call cPush
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd0084
FacRep0084:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd0084
	jz FacEnd0084
	jmp FacRep0084
FacEnd0084:
	call cDrop
	or rPOk, rPOk
	jnz SD0085
	jmp SDEnd0082
SD0085:
	inc byte [r15]
	call pOut
	 dB 4, ", 0x"
	call pOutLI
SDEnd0082:
	call cDrop
	jrcxz RSEnd0081
	or rInEndFlg, rInEndFlg
	jnz RSEnd0081
	jmp RSRep0081
RSEnd0081:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0086
	jmp SDEnd007A
SD0086:
	mov rdi, r15
	mov al, [r15]
	call Bin1Hex
SDEnd007A:
	jrcxz DL0087
	jmp DLEnd0068
DL0087:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '^'
	or rPOk, rPOk
	jnz SD0088
	jmp SDEnd0088
SD0088:
	call cPush
RSRep008A:
	call cPush
	call pDigit
	call cDrop
	jrcxz RSEnd008A
	or rInEndFlg, rInEndFlg
	jnz RSEnd008A
	jmp RSRep008A
RSEnd008A:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD008B
	jmp SDEnd0088
SD008B:
	call pOut
	 db 16, 10, 9, "call pInterval"
	call pOut
	 db 6, 10, 9, " db "
	call pOutLI
	call pOut
	 db 2, ", "
	or rPOk, rPOk
	jnz SD008C
	jmp SDEnd0088
SD008C:
	call pS
	or rPOk, rPOk
	jnz SD008D
	jmp SDEnd0088
SD008D:
	call pIn
	 db 0x0002, '..'
	or rPOk, rPOk
	jnz SD008E
	jmp SDEnd0088
SD008E:
	call pS
	or rPOk, rPOk
	jnz SD008F
	jmp SDEnd0088
SD008F:
	call pIn
	 db 0x0001, '^'
	or rPOk, rPOk
	jnz SD0090
	jmp SDEnd0088
SD0090:
	call cPush
RSRep0092:
	call cPush
	call pDigit
	call cDrop
	jrcxz RSEnd0092
	or rInEndFlg, rInEndFlg
	jnz RSEnd0092
	jmp RSRep0092
RSEnd0092:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0093
	jmp SDEnd0088
SD0093:
	call pOutLI
SDEnd0088:
	jrcxz DL0094
	jmp DLEnd0068
DL0094:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '^'
	or rPOk, rPOk
	jnz SD0095
	jmp SDEnd0095
SD0095:
	call cPush
RSRep0097:
	call cPush
	call pDigit
	call cDrop
	jrcxz RSEnd0097
	or rInEndFlg, rInEndFlg
	jnz RSEnd0097
	jmp RSRep0097
RSEnd0097:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0098
	jmp SDEnd0095
SD0098:
	call pOut
	 db 10, 10, 9, "call pIn"
	call pOut
	 db 9, 10, 9, " db 1, "
	call pOutLI
SDEnd0095:
	jrcxz DL0099
	jmp DLEnd0068
DL0099:	inc rcx
	call cTop
	call pIn
	 db 0x0003, '>>"'
	or rPOk, rPOk
	jnz SD009A
	jmp SDEnd009A
SD009A:
	call cPush
RSRep009D:
	call cPush
	call pCharacter
	jrcxz DL009E
	jmp DLEnd009E
DL009E:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
DLEnd009E:
	call cDrop
	jrcxz RSEnd009D
	or rInEndFlg, rInEndFlg
	jnz RSEnd009D
	jmp RSRep009D
RSEnd009D:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD009F
	jmp SDEnd009A
SD009F:
	call pOut
	 db 14, 10, 9, "call pFindIn"
	call pOut
	 db 8, 10, 9, " db 0x"
	call pOutLILen
	call pOut
	 db  3, ', "'
	call pOutLI
	call pOut
 	 db 1, '"'
	or rPOk, rPOk
	jnz SD00A0
	jmp SDEnd009A
SD00A0:
	call pIn
	 db 1, 34
SDEnd009A:
	jrcxz DL00A1
	jmp DLEnd0068
DL00A1:	inc rcx
	call cTop
	call pIn
	 db 0x0003, ">>'"
	or rPOk, rPOk
	jnz SD00A2
	jmp SDEnd00A2
SD00A2:
	call cPush
RSRep00A5:
	call cPush
	call pCharacter
	jrcxz DL00A6
	jmp DLEnd00A6
DL00A6:	inc rcx
	call cTop
	call pIn
	 db 1, 34
DLEnd00A6:
	call cDrop
	jrcxz RSEnd00A5
	or rInEndFlg, rInEndFlg
	jnz RSEnd00A5
	jmp RSRep00A5
RSEnd00A5:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD00A7
	jmp SDEnd00A2
SD00A7:
	call pOut
	 db 14, 10, 9, "call pFindIn"
	call pOut
	 db 8, 10, 9, " db 0x"
	call pOutLILen
	call pOut
	 db  3, ", '"
	call pOutLI
	call pOut
 	 db 1, "'"
	or rPOk, rPOk
	jnz SD00A8
	jmp SDEnd00A2
SD00A8:
	call pIn
	 db 0x0001, "'"
SDEnd00A2:
	jrcxz DL00A9
	jmp DLEnd0068
DL00A9:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD00AA
	jmp SDEnd00AA
SD00AA:
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD00AB
	jmp SDEnd00AA
SD00AB:
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD00AC
	jmp SDEnd00AA
SD00AC:
	call pOut
	 db 10, 10, 9, "call pIn"
	call pOut
	 db 11, 10, 9, " db 1, 34"
SDEnd00AA:
	jrcxz DL00AD
	jmp DLEnd0068
DL00AD:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD00AE
	jmp SDEnd00AE
SD00AE:
	call cPush
	call pCharacter
	jrcxz DL00AF
	jmp DLEnd00AF
DL00AF:	inc rcx
	call cTop
	call pIn
	 db 1, 34
DLEnd00AF:
	call cDrop
	or rPOk, rPOk
	jnz SD00B0
	jmp SDEnd00AE
SD00B0:
	call pOut
	 db 16, 10, 9, "call pInterval"
	call pOut
	 db 7, 10, 9, " db '"
	call pOutLI
	call pOut
	 db 4, "', '"
	or rPOk, rPOk
	jnz SD00B1
	jmp SDEnd00AE
SD00B1:
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD00B2
	jmp SDEnd00AE
SD00B2:
	call pS
	or rPOk, rPOk
	jnz SD00B3
	jmp SDEnd00AE
SD00B3:
	call pIn
	 db 0x0002, '..'
	or rPOk, rPOk
	jnz SD00B4
	jmp SDEnd00AE
SD00B4:
	call pS
	or rPOk, rPOk
	jnz SD00B5
	jmp SDEnd00AE
SD00B5:
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD00B6
	jmp SDEnd00AE
SD00B6:
	call cPush
	call pCharacter
	jrcxz DL00B7
	jmp DLEnd00B7
DL00B7:	inc rcx
	call cTop
	call pIn
	 db 1, 34
DLEnd00B7:
	call cDrop
	or rPOk, rPOk
	jnz SD00B8
	jmp SDEnd00AE
SD00B8:
	call pOutLI
	call pOut
	 db 1, "'"
	or rPOk, rPOk
	jnz SD00B9
	jmp SDEnd00AE
SD00B9:
	call pIn
	 db 0x0001, "'"
SDEnd00AE:
	jrcxz DL00BA
	jmp DLEnd0068
DL00BA:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD00BB
	jmp SDEnd00BB
SD00BB:
	call cPush
RSRep00BE:
	call cPush
	call pCharacter
	jrcxz DL00BF
	jmp DLEnd00BF
DL00BF:	inc rcx
	call cTop
	call pIn
	 db 1, 34
DLEnd00BF:
	call cDrop
	jrcxz RSEnd00BE
	or rInEndFlg, rInEndFlg
	jnz RSEnd00BE
	jmp RSRep00BE
RSEnd00BE:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD00C0
	jmp SDEnd00BB
SD00C0:
	call pOut
	 db 10, 10, 9, "call pIn"
	call pOut
	 db 8, 10, 9, " db 0x"
	call pOutLILen
	call pOut
	 db 3, ", '"
	call pOutLI
	call pOut
	 db 1, "'"
	or rPOk, rPOk
	jnz SD00C1
	jmp SDEnd00BB
SD00C1:
	call pIn
	 db 0x0001, "'"
SDEnd00BB:
	jrcxz DL00C2
	jmp DLEnd0068
DL00C2:	inc rcx
	call cTop
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD00C3
	jmp SDEnd00C3
SD00C3:
	call cPush
	call pCharacter
	jrcxz DL00C4
	jmp DLEnd00C4
DL00C4:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
DLEnd00C4:
	call cDrop
	or rPOk, rPOk
	jnz SD00C5
	jmp SDEnd00C3
SD00C5:
	call pOut
	 db 16, 10, 9, "call pInterval"
	call pOut
	 db 7, 10, 9, ' db "'
	call pOutLI
	call pOut
	 db 4, '", "'
	or rPOk, rPOk
	jnz SD00C6
	jmp SDEnd00C3
SD00C6:
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD00C7
	jmp SDEnd00C3
SD00C7:
	call pS
	or rPOk, rPOk
	jnz SD00C8
	jmp SDEnd00C3
SD00C8:
	call pIn
	 db 0x0002, '..'
	or rPOk, rPOk
	jnz SD00C9
	jmp SDEnd00C3
SD00C9:
	call pS
	or rPOk, rPOk
	jnz SD00CA
	jmp SDEnd00C3
SD00CA:
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD00CB
	jmp SDEnd00C3
SD00CB:
	call cPush
	call pCharacter
	jrcxz DL00CC
	jmp DLEnd00CC
DL00CC:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
DLEnd00CC:
	call cDrop
	or rPOk, rPOk
	jnz SD00CD
	jmp SDEnd00C3
SD00CD:
	call pOutLI
	call pOut
	 db 1, '"'
	or rPOk, rPOk
	jnz SD00CE
	jmp SDEnd00C3
SD00CE:
	call pIn
	 db 1, 34
SDEnd00C3:
	jrcxz DL00CF
	jmp DLEnd0068
DL00CF:	inc rcx
	call cTop
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD00D0
	jmp SDEnd00D0
SD00D0:
	call cPush
RSRep00D3:
	call cPush
	call pCharacter
	jrcxz DL00D4
	jmp DLEnd00D4
DL00D4:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
DLEnd00D4:
	call cDrop
	jrcxz RSEnd00D3
	or rInEndFlg, rInEndFlg
	jnz RSEnd00D3
	jmp RSRep00D3
RSEnd00D3:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD00D5
	jmp SDEnd00D0
SD00D5:
	call pOut
	 db 10, 10, 9, "call pIn"
	call pOut
	 db 8, 10, 9, " db 0x"
	call pOutLILen
	call pOut
	 db 3, ", ", 34
	call pOutLI
	call pOut
	 db 1, 34
	or rPOk, rPOk
	jnz SD00D6
	jmp SDEnd00D0
SD00D6:
	call pIn
	 db 1, 34
SDEnd00D0:
DLEnd0068:
	call cDrop
SDEnd005D:
	call cDrop
	ret

;pTerminal	= pS,
;		(('0x', 16*pHexChar)						,
;										<.	call pOut.>
;										<.	 db 20, 10, 9, "call pIntervalQuad".>	
;										<.	call pOut.>
;										<.	 db 6, 10, 9, ' dq '.>
;										<.	call pOutLI.>
;				    , pS,'..', pS, ('0x', 16*pHexChar) 		,
;				    						<.	call pOut.>
;										<.	 db 6, 10, 9, ' dq '.>
;										<.	call pOutLI.>			
;		|('0x', 16*pHexChar)						,
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "call pIn".>	
;										<.	call pOut.>
;										<.	 db 13, 10, 9, ' db 8', 10, 9, ' dq '.>
;										<.	call pOutLI.>
;		|('0x', 2*pHexChar)						,
;										<.	call pOut.>
;										<.	 db 16, 10, 9, "call pInterval".>
;										<.	call pOut.>
;										<.	 db 6, 10, 9, " db ".>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 2, ", ".>
;			       , pS,'..', pS, ('0x', 2*pHexChar)		,
;			      	     						<.	call pOutLI.>
;		| ("0x", 2*pHexChar)						,
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "call pIn".>
;		      								<.	call pOut.>
;							     			<.	 db 8, 10, 9, " db 0x".>
;		 								<.	mov r15, rOutPnt.>
;		      								<.	call pOut.>
;							     			<.	 db 4, 1, 0, ", ".>
;							     			<.	call pOutLI.>
;			,{" ", pS, (2*pHexChar)					,
;										<.	inc byte [r15].>
;										<.	call pOut.>
;										<.	 dB 4, ", 0x".>
;										<.	call pOutLI.>
;			      			 }				,
;				 						<.	mov rdi, r15.>
;			        						<.	mov al, [r15].>
;			        						<.	call Bin1Hex.>
;
;		|'^', {pDigit}							,
;										<.	call pOut.>
;										<.	 db 16, 10, 9, "call pInterval".>
;										<.	call pOut.>
;										<.	 db 6, 10, 9, " db ".>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 2, ", ".>
;			       , pS,'..', pS, '^', {pDigit}			,
;			      	     						<.	call pOutLI.>
;		|'^', {pDigit} 							,
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "call pIn".>
;										<.	call pOut.>
;										<.	 db 9, 10, 9, " db 1, ".>
;										<.	call pOutLI.>
;		|'>>"', {pCharacter| "'"}					,
;										<.	call pOut.>
;										<.	 db 14, 10, 9, "call pFindIn".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, " db 0x".>
;										<.	call pOutLILen.>
;										<.	call pOut.>
;										<.	 db  3, ', "'.>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<. 	 db 1, '"'.>,
;			     		 '"'
;		|">>'", {pCharacter| '"'},					<.	call pOut.>
;										<.	 db 14, 10, 9, "call pFindIn".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, " db 0x".>
;										<.	call pOutLILen.>
;										<.	call pOut.>
;										<.	 db  3, ", '".>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<. 	 db 1, "'".>,
;			     		 "'"
;		|"'" ,'"' ,"'",							<.	call pOut.>
;										<.	 db 10, 10, 9, "call pIn".>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, " db 1, 34".>
;										
;		|"'", (pCharacter| '"'),					<.	call pOut.>
;										<.	 db 16, 10, 9, "call pInterval".>
;										<.	call pOut.>
;										<.	 db 7, 10, 9, " db '".>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 4, "', '".>,
;		  		"'", pS, '..', pS, "'", (pCharacter|'"'),	<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 1, "'".>,
;									 "'"
;		|"'", {pCharacter| '"'},					<.	call pOut.>
;										<.	 db 10, 10, 9, "call pIn".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, " db 0x".>
;										<.	call pOutLILen.>
;										<.	call pOut.>
;										<.	 db 3, ", '".>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 1, "'".>,						
;					"'"
;		|'"', (pCharacter| "'"),					<.	call pOut.>
;										<.	 db 16, 10, 9, "call pInterval".>
;										<.	call pOut.>
;										<.	 db 7, 10, 9, ' db "'.>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 4, '", "'.>,
;		  		'"', pS, '..', pS, '"', (pCharacter|"'"),	<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 1, '"'.>,
;							    		 '"'
;	 	|'"', {pCharacter| "'"},					<.	call pOut.>
;										<.	 db 10, 10, 9, "call pIn".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, " db 0x".>
;										<.	call pOutLILen.>
;										<.	call pOut.>
;										<.	 db 3, ", ", 34.>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 1, 34.>,
;					 '"' );
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pArgument:
	call cPush
	call pOut
	db 8, 10, 9, " db 0x"
	mov r15, rOutPnt
	call pOut
	 db 4, 0, 0, ", "
	or rPOk, rPOk
	jnz SD00D7
	jmp SDEnd00D7
SD00D7:
	call cPush
	call cPush
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD00D8
	jmp SDEnd00D8
SD00D8:
	call cPush
RSRep00DC:
	call cPush
	call pInterval
	 db 0, 255
	or rPOk, rPOk
	jnz ExChk00DD
	jmp ExEnd00DD
ExChk00DD:
	call cPush
	sub rInPnt, rLastInLen
	call pIn
	 db 0x0001, "'"
	call cDropExcept
ExEnd00DD:
	or rPOk, rPOk
	jnz SD00DE
	jmp SDEnd00DE
SD00DE:
	inc byte [r15]
SDEnd00DE:
	call cDrop
	jrcxz RSEnd00DC
	or rInEndFlg, rInEndFlg
	jnz RSEnd00DC
	jmp RSRep00DC
RSEnd00DC:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD00DF
	jmp SDEnd00D8
SD00DF:
	call pIn
	 db 0x0001, "'"
SDEnd00D8:
	call cDrop
	jrcxz DL00E0
	jmp DLEnd00E0
DL00E0:	inc rcx
	call cTop
	call cPush
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD00E1
	jmp SDEnd00E1
SD00E1:
	call cPush
RSRep00E5:
	call cPush
	call pInterval
	 db 0, 255
	or rPOk, rPOk
	jnz ExChk00E6
	jmp ExEnd00E6
ExChk00E6:
	call cPush
	sub rInPnt, rLastInLen
	call pIn
	 db 1, 34
	call cDropExcept
ExEnd00E6:
	or rPOk, rPOk
	jnz SD00E7
	jmp SDEnd00E7
SD00E7:
	inc byte [r15]
SDEnd00E7:
	call cDrop
	jrcxz RSEnd00E5
	or rInEndFlg, rInEndFlg
	jnz RSEnd00E5
	jmp RSRep00E5
RSEnd00E5:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD00E8
	jmp SDEnd00E1
SD00E8:
	call pIn
	 db 1, 34
SDEnd00E1:
	call cDrop
	jrcxz DL00E9
	jmp DLEnd00E0
DL00E9:	inc rcx
	call cTop
	call cPush
	call pIn
	 db 0x0002, "0x"
	or rPOk, rPOk
	jnz SD00EA
	jmp SDEnd00EA
SD00EA:
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd00EB
FacRep00EB:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd00EB
	jz FacEnd00EB
	jmp FacRep00EB
FacEnd00EB:
SDEnd00EA:
	call cDrop
	or rPOk, rPOk
	jnz SD00EC
	jmp SDEnd00EC
SD00EC:
	inc byte [r15]
SDEnd00EC:
DLEnd00E0:
	call cDrop
	or rPOk, rPOk
	jnz SD00ED
	jmp SDEnd00D7
SD00ED:
	call pOutLI
	or rPOk, rPOk
	jnz SD00EE
	jmp SDEnd00D7
SD00EE:
	call cPush
RSRep0108:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD0109
	jmp SDEnd0109
SD0109:
	call pIn
	 db 0x0001, ","
	or rPOk, rPOk
	jnz SD010A
	jmp SDEnd0109
SD010A:
	call pS
	or rPOk, rPOk
	jnz SD010B
	jmp SDEnd0109
SD010B:
	call cPush
	call cPush
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD010C
	jmp SDEnd010C
SD010C:
	call cPush
RSRep0110:
	call cPush
	call pInterval
	 db 0, 255
	or rPOk, rPOk
	jnz ExChk0111
	jmp ExEnd0111
ExChk0111:
	call cPush
	sub rInPnt, rLastInLen
	call pIn
	 db 0x0001, "'"
	call cDropExcept
ExEnd0111:
	or rPOk, rPOk
	jnz SD0112
	jmp SDEnd0112
SD0112:
	inc byte [r15]
SDEnd0112:
	call cDrop
	jrcxz RSEnd0110
	or rInEndFlg, rInEndFlg
	jnz RSEnd0110
	jmp RSRep0110
RSEnd0110:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0113
	jmp SDEnd010C
SD0113:
	call pIn
	 db 0x0001, "'"
SDEnd010C:
	call cDrop
	jrcxz DL0114
	jmp DLEnd0114
DL0114:	inc rcx
	call cTop
	call cPush
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD0115
	jmp SDEnd0115
SD0115:
	call cPush
RSRep0119:
	call cPush
	call pInterval
	 db 0, 255
	or rPOk, rPOk
	jnz ExChk011A
	jmp ExEnd011A
ExChk011A:
	call cPush
	sub rInPnt, rLastInLen
	call pIn
	 db 1, 34
	call cDropExcept
ExEnd011A:
	or rPOk, rPOk
	jnz SD011B
	jmp SDEnd011B
SD011B:
	inc byte [r15]
SDEnd011B:
	call cDrop
	jrcxz RSEnd0119
	or rInEndFlg, rInEndFlg
	jnz RSEnd0119
	jmp RSRep0119
RSEnd0119:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD011C
	jmp SDEnd0115
SD011C:
	call pIn
	 db 1, 34
SDEnd0115:
	call cDrop
	jrcxz DL011D
	jmp DLEnd0114
DL011D:	inc rcx
	call cTop
	call cPush
	call pIn
	 db 0x0002, "0x"
	or rPOk, rPOk
	jnz SD011E
	jmp SDEnd011E
SD011E:
	mov rFactCnt, 2
	or rFactCnt, rFactCnt
	jz FacEnd011F
FacRep011F:
	call pHexChar
	dec rFactCnt
	jrcxz FacEnd011F
	jz FacEnd011F
	jmp FacRep011F
FacEnd011F:
	or rPOk, rPOk
	jnz SD0120
	jmp SDEnd011E
SD0120:
	inc byte [r15]
SDEnd011E:
	call cDrop
DLEnd0114:
	call cDrop
SDEnd0109:
	call cDrop
	jrcxz RSEnd0108
	or rInEndFlg, rInEndFlg
	jnz RSEnd0108
	jmp RSRep0108
RSEnd0108:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0121
	jmp SDEnd00D7
SD0121:
	call pOutLI
	mov rdi, r15
	mov al, [r15]
	call Bin1Hex
SDEnd00D7:
	jrcxz DL0122
	jmp DLEnd0122
DL0122:	inc rcx
	call cTop
	call pInteger
	or rPOk, rPOk
	jnz SD0123
	jmp SDEnd0123
SD0123:
	call pOut
	 db 6, 10, 9, " dq "
	call pOutLI
	or rPOk, rPOk
	jnz SD0124
	jmp SDEnd0123
SD0124:
	call cPush
RSRep012A:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD012B
	jmp SDEnd012B
SD012B:
	call pIn
	 db 0x0001, ","
	or rPOk, rPOk
	jnz SD012C
	jmp SDEnd012B
SD012C:
	call pS
	or rPOk, rPOk
	jnz SD012D
	jmp SDEnd012B
SD012D:
	call cPush
	call pInteger
	call cDrop
	or rPOk, rPOk
	jnz SD012E
	jmp SDEnd012B
SD012E:
	call pOut
	 db 6, 10, 9, " dq "
	call pOutLI
SDEnd012B:
	call cDrop
	jrcxz RSEnd012A
	or rInEndFlg, rInEndFlg
	jnz RSEnd012A
	jmp RSRep012A
RSEnd012A:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd0123:
	jrcxz DL012F
	jmp DLEnd0122
DL012F:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "*"
	or rPOk, rPOk
	jnz SD0130
	jmp SDEnd0130
SD0130:
	call pIdentifier
	or rPOk, rPOk
	jnz SD0131
	jmp SDEnd0130
SD0131:
	call pOut
	 db 6, 10, 9, " dq "
	call pOutLI
	or rPOk, rPOk
	jnz SD0132
	jmp SDEnd0130
SD0132:
	call cPush
RSRep0139:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD013A
	jmp SDEnd013A
SD013A:
	call pIn
	 db 0x0001, ","
	or rPOk, rPOk
	jnz SD013B
	jmp SDEnd013A
SD013B:
	call pS
	or rPOk, rPOk
	jnz SD013C
	jmp SDEnd013A
SD013C:
	call pIn
	 db 0x0001, "*"
	or rPOk, rPOk
	jnz SD013D
	jmp SDEnd013A
SD013D:
	call pIdentifier
	or rPOk, rPOk
	jnz SD013E
	jmp SDEnd013A
SD013E:
	call pOut
	 db 6, 10, 9, " dq "
	call pOutLI
SDEnd013A:
	call cDrop
	jrcxz RSEnd0139
	or rInEndFlg, rInEndFlg
	jnz RSEnd0139
	jmp RSRep0139
RSEnd0139:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd0130:
DLEnd0122:
	call cDrop
	ret

;pArgument	= 								<.	call pOut.>
;		      								<.	db 8, 10, 9, " db 0x".>
;										<.	mov r15, rOutPnt.>
;		      								<.	call pOut.>
;						     				<.	 db 4, 0, 0, ", ".>,
;		( ("'", {^0..^255-"'"						,<.	inc byte [r15].>
;					}, "'") |
;		  ('"', {^0..^255-'"'						,<.	inc byte [r15].>
;					}, '"') |
;		  ("0x", 2*pHexChar)						,<.	inc byte [r15].>
;		)								,<.	call pOutLI.>
;
;		, {pS, ",", pS, (("'",{^0..^255-"'"				,<.	inc byte [r15].>
;		     				        }, "'") |
;				 ('"',{^0..^255-'"'				,<.	inc byte [r15].>
;		     				        }, '"') |
;				 ("0x", 2*pHexChar				,<.	inc byte [r15].>
;						  ))}				,<.	call pOutLI.>
;										<.	mov rdi, r15.>
;										<.	mov al, [r15].>
;										<.	call Bin1Hex.>
;		|pInteger							,<.	call pOut.>
;										<.	 db 6, 10, 9, " dq ".>
;										<.	call pOutLI.>
;			 , {pS, ",", pS, (pInteger) 				,<.	call pOut.>
;										<.	 db 6, 10, 9, " dq ".> 
;										<.	call pOutLI.>
;						     }
;		|"*", pIdentifier						,<.	call pOut.>
;										<.	 db 6, 10, 9, " dq ".>
;										<.	call pOutLI.>
;			 , {pS, ",", pS, "*", pIdentifier			,<.	call pOut.>
;										<.	 db 6, 10, 9, " dq ".> 
;										<.	call pOutLI.>
;						     };
;						     
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pFunction:
	call cPush
	call cPush
	call cPush
	call pIn
	 db 0x0004, "pOut"
	jrcxz DL013F
	jmp DLEnd013F
DL013F:	inc rcx
	call cTop
	call pIn
	 db 0x0006, "IsBit1"
	jrcxz DL0140
	jmp DLEnd013F
DL0140:	inc rcx
	call cTop
	call pIn
	 db 0x0005, "IsBit"
	jrcxz DL0141
	jmp DLEnd013F
DL0141:	inc rcx
	call cTop
	call pIn
	 db 0x0007, "Message"
	jrcxz DL0142
	jmp DLEnd013F
DL0142:	inc rcx
	call cTop
	call pIn
	 db 0x000C, "ErrorMessage"
	jrcxz DL0143
	jmp DLEnd013F
DL0143:	inc rcx
	call cTop
	call pIn
	 db 0x0007, "LIStore"
	jrcxz DL0144
	jmp DLEnd013F
DL0144:	inc rcx
	call cTop
	call pIn
	 db 0x000C, "SetBitMapCur"
DLEnd013F:
	call cDrop
	or rPOk, rPOk
	jnz SD0145
	jmp SDEnd0145
SD0145:
	call pOut
	 db 7, 10, 9, "call "
	call pOutLI
	or rPOk, rPOk
	jnz SD0146
	jmp SDEnd0145
SD0146:
	call pS
	or rPOk, rPOk
	jnz SD0147
	jmp SDEnd0145
SD0147:
	call pIn
	 db 0x0001, '('
	or rPOk, rPOk
	jnz SD0148
	jmp SDEnd0145
SD0148:
	call pS
	or rPOk, rPOk
	jnz SD0149
	jmp SDEnd0145
SD0149:
	call pArgument
	or rPOk, rPOk
	jnz SD014A
	jmp SDEnd0145
SD014A:
	call pS
	or rPOk, rPOk
	jnz SD014B
	jmp SDEnd0145
SD014B:
	call pIn
	 db 0x0001, ')'
SDEnd0145:
	call cDrop
	jrcxz DL014C
	jmp DLEnd014C
DL014C:	inc rcx
	call cTop
	call pIdentifier
	or rPOk, rPOk
	jnz SD014D
	jmp SDEnd014D
SD014D:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD014E
	jmp SDEnd014E
SD014E:
	call pIn
	 db 0x0001, '('
	or rPOk, rPOk
	jnz SD014F
	jmp SDEnd014E
SD014F:
	call pS
	or rPOk, rPOk
	jnz SD0150
	jmp SDEnd014E
SD0150:
	call cPush
	call pFunction
	jrcxz DL0151
	jmp DLEnd0151
DL0151:	inc rcx
	call cTop
	call pInteger
	or rPOk, rPOk
	jnz SD0152
	jmp SDEnd0152
SD0152:
	call pOut
	 db 7, 10, 9, "push "
	call pOutLI
SDEnd0152:
	jrcxz DL0153
	jmp DLEnd0151
DL0153:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "*"
	or rPOk, rPOk
	jnz SD0154
	jmp SDEnd0154
SD0154:
	call pIdentifier
	or rPOk, rPOk
	jnz SD0155
	jmp SDEnd0154
SD0155:
	call pOut
	 db 7, 10, 9, "push "
	call pOutLI
SDEnd0154:
	jrcxz DL0156
	jmp DLEnd0151
DL0156:	inc rcx
	call cTop
	call StringExp
DLEnd0151:
	call cDrop
	or rPOk, rPOk
	jnz SD0157
	jmp SDEnd014E
SD0157:
	call cPush
RSRep0162:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD0163
	jmp SDEnd0163
SD0163:
	call pIn
	 db 0x0001, ','
	or rPOk, rPOk
	jnz SD0164
	jmp SDEnd0163
SD0164:
	call pS
	or rPOk, rPOk
	jnz SD0165
	jmp SDEnd0163
SD0165:
	call cPush
	call pFunction
	jrcxz DL0166
	jmp DLEnd0166
DL0166:	inc rcx
	call cTop
	call pInteger
	or rPOk, rPOk
	jnz SD0167
	jmp SDEnd0167
SD0167:
	call pOut
	 db 7, 10, 9, "push "
	call pOutLI
SDEnd0167:
	jrcxz DL0168
	jmp DLEnd0166
DL0168:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "*"
	or rPOk, rPOk
	jnz SD0169
	jmp SDEnd0169
SD0169:
	call pIdentifier
	or rPOk, rPOk
	jnz SD016A
	jmp SDEnd0169
SD016A:
	call pOut
	 db 7, 10, 9, "push "
	call pOutLI
SDEnd0169:
	jrcxz DL016B
	jmp DLEnd0166
DL016B:	inc rcx
	call cTop
	call StringExp
DLEnd0166:
	call cDrop
SDEnd0163:
	call cDrop
	jrcxz RSEnd0162
	or rInEndFlg, rInEndFlg
	jnz RSEnd0162
	jmp RSRep0162
RSEnd0162:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD016C
	jmp SDEnd014E
SD016C:
	call pS
	or rPOk, rPOk
	jnz SD016D
	jmp SDEnd014E
SD016D:
	call pIn
	 db 0x0001, ')'
SDEnd014E:
	call cDrop
	or rPOk, rPOk
	jnz SD016E
	jmp SDEnd014D
SD016E:
	call pOut 
	 db 7, 10, 9, "call "
	call pOutPI
SDEnd014D:
	jrcxz DL016F
	jmp DLEnd014C
DL016F:	inc rcx
	call cTop
	call pIdentifier
	or rPOk, rPOk
	jnz SD0170
	jmp SDEnd0170
SD0170:
	call pOut 
	 db 7, 10, 9, "call "
	call pOutLI
SDEnd0170:
DLEnd014C:
	call cDrop
	ret

;pFunction	= (("pOut"|"IsBit1"| "IsBit"|"Message"| "ErrorMessage"| "LIStore"| "SetBitMapCur"),		/* Exception list for inline parameters */
;										<.	call pOut.>
;										<.	 db 7, 10, 9, "call ".>
;										<.	call pOutLI.>,
;				pS, '(', pS, pArgument, pS, ')')
;		  |pIdentifier,
;		  
;			  (pS, '(', pS, (pFunction|pInteger			,<.	call pOut.>
;		    								<.	 db 7, 10, 9, "push ".>
;		    								<.	call pOutLI.>
;		    		  			  |"*", pIdentifier	,<.	call pOut.>
;		    								<.	 db 7, 10, 9, "push ".>
;		    								<.	call pOutLI.>
;		    					  | StringExp		    )
;
;			, {pS, ',', pS, (pFunction|pInteger			,<.	call pOut.>
;		    								<.	 db 7, 10, 9, "push ".>
;		    								<.	call pOutLI.>
;							  
;		    		  			  |"*", pIdentifier	,<.	call pOut.>
;		    								<.	 db 7, 10, 9, "push ".>
;		    								<.	call pOutLI.>
;		    					  | StringExp
;		    							    ) }, pS,  ')' )
;		    							    
;		    							    	,<.	call pOut .>
;										<.	 db 7, 10, 9, "call ".>
;										<.	call pOutPI.>
;		  |pIdentifier							,<.	call pOut .>
;										<.	 db 7, 10, 9, "call ".>
;										<.	call pOutLI.>;
;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pFunctionList:
	call cPush
	call pFunction
	or rPOk, rPOk
	jnz SD0171
	jmp SDEnd0171
SD0171:
	call cPush
RSRep0174:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD0175
	jmp SDEnd0175
SD0175:
	call pFunction
SDEnd0175:
	call cDrop
	jrcxz RSEnd0174
	or rInEndFlg, rInEndFlg
	jnz RSEnd0174
	jmp RSRep0174
RSEnd0174:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd0171:
	call cDrop
	ret

;pFunctionList = pFunction , { pS, pFunction };
;
;
;
;			/* todo proper expr with "&" */

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
StringExp:
	call cPush
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD0176
	jmp SDEnd0176
SD0176:
	call cPush
RSRep0179:
	call cPush
	call pCharacter
	jrcxz DL017A
	jmp DLEnd017A
DL017A:	inc rcx
	call cTop
	call pIn
	 db 1, 34
DLEnd017A:
	call cDrop
	jrcxz RSEnd0179
	or rInEndFlg, rInEndFlg
	jnz RSEnd0179
	jmp RSRep0179
RSEnd0179:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD017B
	jmp SDEnd0176
SD017B:
	call pOut
	 db 12, 10, 9, "call sPush"
	call pOut
	 db 8, 10, 9, " db 0x"
	call pOutLILen
	call pOut
	 db 3, ", '"
	call pOutLI
	or rPOk, rPOk
	jnz SD017C
	jmp SDEnd0176
SD017C:
	call pIn
	 db 0x0001, "'"
	or rPOk, rPOk
	jnz SD017D
	jmp SDEnd0176
SD017D:
	call pOutLI
SDEnd0176:
	jrcxz DL017E
	jmp DLEnd017E
DL017E:	inc rcx
	call cTop
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD017F
	jmp SDEnd017F
SD017F:
	call cPush
RSRep0182:
	call cPush
	call pCharacter
	jrcxz DL0183
	jmp DLEnd0183
DL0183:	inc rcx
	call cTop
	call pIn
	 db 0x0001, "'"
DLEnd0183:
	call cDrop
	jrcxz RSEnd0182
	or rInEndFlg, rInEndFlg
	jnz RSEnd0182
	jmp RSRep0182
RSEnd0182:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
	or rPOk, rPOk
	jnz SD0184
	jmp SDEnd017F
SD0184:
	call pOut
	 db 12, 10, 9, "call sPush"
	call pOut
	 db 8, 10, 9, " db 0x"
	call pOutLILen
	call pOut
	 db 3, ', "'
	call pOutLI
	or rPOk, rPOk
	jnz SD0185
	jmp SDEnd017F
SD0185:
	call pIn
	 db 1, 34
	or rPOk, rPOk
	jnz SD0186
	jmp SDEnd017F
SD0186:
	call pOutLI
SDEnd017F:
DLEnd017E:
	call cDrop
	ret

;StringExp	= "'", {pCharacter| '"'}					,<.	call pOut.>
;										<.	 db 12, 10, 9, "call sPush".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, " db 0x".>
;										<.	call pOutLILen.>
;										<.	call pOut.>
;										<.	 db 3, ", '".>
;										<.	call pOutLI.>
;					, "'"					,<.	call pOutLI.>
;		| '"', {pCharacter| "'"}					,<.	call pOut.>
;										<.	 db 12, 10, 9, "call sPush".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, " db 0x".>
;										<.	call pOutLILen.>
;										<.	call pOut.>
;										<.	 db 3, ', "'.>
;										<.	call pOutLI.>
;					, '"'					,<.	call pOutLI.>
;						;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
OptionalSequence:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD0187
	jmp SDEnd0187
SD0187:
	call pIn
	 db 0x0001, '['
	or rPOk, rPOk
	jnz SD0188
	jmp SDEnd0187
SD0188:
	call pOut
	 db 12, 10, 9, "call cPush"
	or rPOk, rPOk
	jnz SD0189
	jmp SDEnd0187
SD0189:
	call DefinitionsList
	or rPOk, rPOk
	jnz SD018A
	jmp SDEnd0187
SD018A:
	call pS
	or rPOk, rPOk
	jnz SD018B
	jmp SDEnd0187
SD018B:
	call pIn
	 db 0x0001, ']'
	or rPOk, rPOk
	jnz SD018C
	jmp SDEnd0187
SD018C:
	call pOut
	 db 12, 10, 9, "call cDrop"
	call pOut
	 db 16, 10, 9, "xor rPOk, rPOk"
	call pOut
	 db 10, 10, 9, "inc rPOk"
SDEnd0187:
	call cDrop
	ret

;OptionalSequence= pS, '[',							<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>,
;			   DefinitionsList, pS, ']',				<.	call pOut.>
;										<.	 db 12, 10, 9, "call cDrop".>
;										<.	call pOut.>
;										<.	 db 16, 10, 9, "xor rPOk, rPOk".>
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "inc rPOk".> ;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
RepeatedSequence:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD018D
	jmp SDEnd018D
SD018D:
	call pIn
	 db 0x0001, '{'
	or rPOk, rPOk
	jnz SD018E
	jmp SDEnd018D
SD018E:
	call pOut
	 db 12, 10, 9, "call cPush"
	call pOut
	 db 6, 10, "RSRep"
	call LblNew
	call pOut
	 db 1, ":"
	call pOut
	 db 12, 10, 9, "call cPush"
	or rPOk, rPOk
	jnz SD018F
	jmp SDEnd018D
SD018F:
	call DefinitionsList
	or rPOk, rPOk
	jnz SD0190
	jmp SDEnd018D
SD0190:
	call pS
	or rPOk, rPOk
	jnz SD0191
	jmp SDEnd018D
SD0191:
	call pIn
	 db 0x0001, '}'
	or rPOk, rPOk
	jnz SD0192
	jmp SDEnd018D
SD0192:
	call pOut
	 db 12, 10, 9, "call cDrop"
	call pOut
	 db 13, 10, 9, "jrcxz RSEnd"
	call LblUse
	call pOut
	 db 25, 10, 9, "or rInEndFlg, rInEndFlg"
	call pOut
	 db 11, 10, 9, "jnz RSEnd"
	call LblUse
	call pOut
	 db 11, 10, 9, "jmp RSRep"
	call LblUse
	call pOut
	 db 6, 10, "RSEnd"
	call LblCls
	call pOut
	 db 1, ":"
	call pOut
	 db 16, 10, 9, "xor rPOk, rPOk"
	call pOut
	 db 10, 10, 9, "inc rPOk"
	call pOut
	 db 12, 10, 9, "call cDrop"
SDEnd018D:
	call cDrop
	ret

;RepeatedSequence= pS, '{',							<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>
;										<.	call pOut.>
;										<.	 db 6, 10, "RSRep".>
;										<.	call LblNew.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>,
;			   DefinitionsList, pS, '}',				<.	call pOut.>
;										<.	 db 12, 10, 9, "call cDrop".>
;										<.	call pOut.>
;										<.	 db 13, 10, 9, "jrcxz RSEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 25, 10, 9, "or rInEndFlg, rInEndFlg".>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jnz RSEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jmp RSRep".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 6, 10, "RSEnd".>
;										<.	call LblCls.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;										<.	call pOut.>
;										<.	 db 16, 10, 9, "xor rPOk, rPOk".>
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "inc rPOk".>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "call cDrop".> ;
;		

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
KleeneSequence:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD0193
	jmp SDEnd0193
SD0193:
	call pIn
	 db 0x0001, '{'
	or rPOk, rPOk
	jnz SD0194
	jmp SDEnd0193
SD0194:
	call pOut
	 db 12, 10, 9, "call cPush"
	call pOut
	 db 12, 10, 9, "call cPush"
	call pOut
	 db 6, 10, "KSRep"
	call LblNew
	call pOut
	 db 1, ":"
	call pOut
	 db 12, 10, 9, "call cPush"
	or rPOk, rPOk
	jnz SD0195
	jmp SDEnd0193
SD0195:
	call DefinitionsList
	or rPOk, rPOk
	jnz SD0196
	jmp SDEnd0193
SD0196:
	call pS
	or rPOk, rPOk
	jnz SD0197
	jmp SDEnd0193
SD0197:
	call pIn
	 db 0x0002, '}*'
	or rPOk, rPOk
	jnz SD0198
	jmp SDEnd0193
SD0198:
	call pOut
	 db 12, 10, 9, "call cDrop"
	call pOut
	 db 10, 10, 9, "jrcxz KS"
	call LblUse
	call pOut
	 db 25, 10, 9, "or rInEndFlg, rInEndFlg"
	call pOut
	 db 8, 10, 9, "jnz KS"
	call LblUse
	call pOut
	 db 11, 10, 9, "jmp KSRep"
	call LblUse
	call pOut
	 db 3, 10, "KS"
	call LblUse
	call pOut
	 db 1, ":"
	call pOut
	 db 16, 10, 9, "xor rPOk, rPOk"
	call pOut
	 db 22, 10, 9, "cmp rInPnt, [rsp+56]"
	call pOut
	 db 10, 10, 9, "jz KSEnd"
	call LblUse
	call pOut
	 db 10, 10, 9, "inc rPOk"
	call pOut
	 db 6, 10, "KSEnd"
	call LblCls
	call pOut
	 db 1, ":"
	call pOut
	 db 13, 10, 9, "add rsp, 64"
	call pOut
	 db 12, 10, 9, "call cDrop"
SDEnd0193:
	call cDrop
	ret

;KleeneSequence= pS, '{',							<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>
;										<.	call pOut.>
;										<.	 db 6, 10, "KSRep".>
;										<.	call LblNew.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>,
;			DefinitionsList, pS, '}*',				<.	call pOut.>
;										<.	 db 12, 10, 9, "call cDrop".>
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "jrcxz KS".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 25, 10, 9, "or rInEndFlg, rInEndFlg".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, "jnz KS".>
;										<.	call LblUse.>
;										
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jmp KSRep".>
;										<.	call LblUse.>
;										
;										<.	call pOut.>
;										<.	 db 3, 10, "KS".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;										<.	call pOut.>
;										<.	 db 16, 10, 9, "xor rPOk, rPOk".>
;										<.	call pOut.>
;										<.	 db 22, 10, 9, "cmp rInPnt, [rsp+56]".>
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "jz KSEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 10, 10, 9, "inc rPOk".>
;										<.	call pOut.>
;										<.	 db 6, 10, "KSEnd".>
;										<.	call LblCls.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;										
;										<.	call pOut.>
;										<.	 db 13, 10, 9, "add rsp, 64".>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "call cDrop".> ;
;										

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
GroupedSequence:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD0199
	jmp SDEnd0199
SD0199:
	call pIn
	 db 0x0001, '('
	or rPOk, rPOk
	jnz SD019A
	jmp SDEnd0199
SD019A:
	call pOut
	 db 12, 10, 9, "call cPush"
	or rPOk, rPOk
	jnz SD019B
	jmp SDEnd0199
SD019B:
	call DefinitionsList
	or rPOk, rPOk
	jnz SD019C
	jmp SDEnd0199
SD019C:
	call pS
	or rPOk, rPOk
	jnz SD019D
	jmp SDEnd0199
SD019D:
	call pIn
	 db 0x0001, ')'
	or rPOk, rPOk
	jnz SD019E
	jmp SDEnd0199
SD019E:
	call pOut
	 db 12, 10, 9, "call cDrop"
SDEnd0199:
	call cDrop
	ret

;GroupedSequence = pS, '(',							<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>,
;			   DefinitionsList, pS, ')'				,<.	call pOut.>
;										<.	 db 12, 10, 9, "call cDrop".> ;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Primary:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD019F
	jmp SDEnd019F
SD019F:
	call cPush
	call OptionalSequence
	jrcxz DL01A0
	jmp DLEnd01A0
DL01A0:	inc rcx
	call cTop
	call KleeneSequence
	jrcxz DL01A1
	jmp DLEnd01A0
DL01A1:	inc rcx
	call cTop
	call RepeatedSequence
	jrcxz DL01A2
	jmp DLEnd01A0
DL01A2:	inc rcx
	call cTop
	call pTerminal
	jrcxz DL01A3
	jmp DLEnd01A0
DL01A3:	inc rcx
	call cTop
	call GroupedSequence
	jrcxz DL01A4
	jmp DLEnd01A0
DL01A4:	inc rcx
	call cTop
	call pFunctionList
	jrcxz DL01A5
	jmp DLEnd01A0
DL01A5:	inc rcx
	call cTop
	call pCodeCond
DLEnd01A0:
	call cDrop
SDEnd019F:
	call cDrop
	ret

;Primary	= pS,	( OptionalSequence
;		| KleeneSequence
;		| RepeatedSequence
;		| pTerminal
;		| GroupedSequence
;		| pFunctionList
;		| pCodeCond);
;		

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Exception:
	call cPush
	call pOut
	 db 15, 10, 9, "or rPOk, rPOk"
	call pOut
	 db 11, 10, 9, "jnz ExChk"
	call LblNew
	call pOut
	 db 11, 10, 9, "jmp ExEnd"
	call LblUse
	call pOut
	 db 6, 10, "ExChk"
	call LblUse
	call pOut
	 db 1, ":"
	call pOut
	 db 12, 10, 9, "call cPush"
	call pOut
	 db 24, 10, 9, "sub rInPnt, rLastInLen"
	or rPOk, rPOk
	jnz SD01A6
	jmp SDEnd01A6
SD01A6:
	call Term
	or rPOk, rPOk
	jnz SD01A7
	jmp SDEnd01A6
SD01A7:
	call pOut
	 db 18, 10, 9, "call cDropExcept"
	call pOut
	 db 6, 10, "ExEnd"
	call LblCls
	call pOut
	 db 1, ":"
SDEnd01A6:
	call cDrop
	ret

;Exception	=								<.	call pOut.>
;										<.	 db 15, 10, 9, "or rPOk, rPOk".>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jnz ExChk".>
;										<.	call LblNew.>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jmp ExEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 6, 10, "ExChk".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>
;										<.	call pOut.>
;										<.	 db 24, 10, 9, "sub rInPnt, rLastInLen".>,
;			Term,							<.	call pOut.>
;										<.	 db 18, 10, 9, "call cDropExcept".>
;										<.	call pOut.>
;										<.	 db 6, 10, "ExEnd".>
;										<.	call LblCls.>
;										<.	call pOut.>
;										<.	 db 1, ":".>	;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Factor:
	call cPush
	call Primary
	or rPOk, rPOk
	jnz SD01A8
	jmp SDEnd01A8
SD01A8:
	call pS
	or rPOk, rPOk
	jnz SD01A9
	jmp SDEnd01A8
SD01A9:
	call cPush
	call cPush
	call pIn
	 db 0x0002, '**'
	or rPOk, rPOk
	jnz SD01AA
	jmp SDEnd01AA
SD01AA:
	call pOut
	 db 9, 10, 9, "pop rax"
;	call pOut
;	 db 12, 10, 9, "call cPush"
SDEnd01AA:
	jrcxz DL01AB
	jmp DLEnd01AB
DL01AB:	inc rcx
	call cTop
	call pIn
	 db 0x0001, '*'
	or rPOk, rPOk
	jnz SD01AC
	jmp SDEnd01AC
SD01AC:
;	call pOut
;	 db 12, 10, 9, "call cPush"
	call pOut
	 db 14, 10, 9, "call Dec2Bin"
SDEnd01AC:
DLEnd01AB:
	call cDrop
	or rPOk, rPOk
	jnz SD01AD
	jmp SDEnd01AD
SD01AD:
	call pOut
	 db 19, 10, 9, "mov rFactCnt, rax"
	call pOut
	 db 13, 10, 9, "or rax, rax"
	call pOut
	 db 12, 10, 9, "jnz FacRep"
	call LblNew
	call pOut
	 db 12, 10, 9, "jmp FacEnd"
	call LblUse
	call pOut
	 db 7, 10, "FacRep"
	call LblUse
	call pOut
	 db 1, ":"
	or rPOk, rPOk
	jnz SD01AE
	jmp SDEnd01AD
SD01AE:
	call Primary
	or rPOk, rPOk
	jnz SD01AF
	jmp SDEnd01AD
SD01AF:
	call pOut
	 db 14, 10, 9, "dec rFactCnt"
	call pOut
	 db 14, 10, 9, "jrcxz FacEnd"
	call LblUse
	call pOut
	 db 11, 10, 9, "jz FacEnd"
	call LblUse
	call pOut
	 db 12, 10, 9, "jmp FacRep"
	call LblUse
	call pOut
	 db 7, 10, "FacEnd"
	call LblCls
	call pOut
	 db 1,":"
;	call pOut
;	 db 12, 10, 9, "call cDrop"
SDEnd01AD:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
SDEnd01A8:
	jrcxz DL01B0
	jmp DLEnd01B0
DL01B0:	inc rcx
	call cTop
	call pS
	or rPOk, rPOk
	jnz SD01B1
	jmp SDEnd01B1
SD01B1:
	call pInteger
	or rPOk, rPOk
	jnz SD01B2
	jmp SDEnd01B1
SD01B2:
	call pOut
	 db 16, 10, 9, "mov rFactCnt, "
	call pOutLI
	call pOut
	 db 23, 10, 9, "or rFactCnt, rFactCnt"
	call pOut
	 db 11, 10, 9, "jz FacEnd"
	call LblNew
	call pOut
	 db 7, 10, "FacRep"
	call LblUse
	call pOut
	 db 1, ":"
	or rPOk, rPOk
	jnz SD01B3
	jmp SDEnd01B1
SD01B3:
	call pS
	or rPOk, rPOk
	jnz SD01B4
	jmp SDEnd01B1
SD01B4:
	call pIn
	 db 0x0001, '*'
	or rPOk, rPOk
	jnz SD01B5
	jmp SDEnd01B1
SD01B5:
	call Primary
	or rPOk, rPOk
	jnz SD01B6
	jmp SDEnd01B1
SD01B6:
	call pOut
	 db 14, 10, 9, "dec rFactCnt"
	call pOut
	 db 14, 10, 9, "jrcxz FacEnd"
	call LblUse
	call pOut
	 db 11, 10, 9, "jz FacEnd"
	call LblUse
	call pOut
	 db 12, 10, 9, "jmp FacRep"
	call LblUse
	call pOut
	 db 7, 10, "FacEnd"
	call LblCls
	call pOut
	 db 1, ":"
SDEnd01B1:
DLEnd01B0:
	call cDrop
	ret

;Factor	=  Primary, pS, [ ( '**'						,<.	call pOut.>
;										<.	 db 9, 10, 9, "pop rax".>
;										<.;	call pOut.>
;										<.;	 db 12, 10, 9, "call cPush".>
;				| '*'						,<.;	call pOut.>
;										<.;	 db 12, 10, 9, "call cPush".>
;			      							<.	call pOut.>
;			      							<.	 db 14, 10, 9, "call Dec2Bin".>
;			      	    )						,<.	call pOut.>
;										<.	 db 19, 10, 9, "mov rFactCnt, rax".>	
;										<.	call pOut.>
;										<.	 db 13, 10, 9, "or rax, rax".>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "jnz FacRep".>
;										<.	call LblNew.>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "jmp FacEnd".>
;										<.	call LblUse.>			
;
;										<.	call pOut.>
;										<.	 db 7, 10, "FacRep".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;
;			     , Primary						,<.	call pOut.>
;										<.	 db 14, 10, 9, "dec rFactCnt".>
;										<.	call pOut.>
;										<.	 db 14, 10, 9, "jrcxz FacEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jz FacEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "jmp FacRep".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 7, 10, "FacEnd".>
;										<.	call LblCls.>
;										<.	call pOut.>
;										<.	 db 1,":".>
;
;										<.;	call pOut.>
;										<.;	 db 12, 10, 9, "call cDrop".>
;				      ]
;	| pS, pInteger								,<.	call pOut.>
;										<.	 db 16, 10, 9, "mov rFactCnt, ".>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 23, 10, 9, "or rFactCnt, rFactCnt".>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jz FacEnd".>
;										<.	call LblNew.>
;
;										<.	call pOut.>
;										<.	 db 7, 10, "FacRep".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;
;						  , pS, '*', Primary		,<.	call pOut.>
;										<.	 db 14, 10, 9, "dec rFactCnt".>
;						     				<.	call pOut.>
;										<.	 db 14, 10, 9, "jrcxz FacEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jz FacEnd".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 12, 10, 9, "jmp FacRep".>
;										<.	call LblUse.>	
;										<.	call pOut.>
;										<.	 db 7, 10, "FacEnd".>
;										<.	call LblCls.>
;										<.	call pOut.>
;										<.	 db 1, ":".>	;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Term:
	call cPush
	call Factor
	or rPOk, rPOk
	jnz SD01B7
	jmp SDEnd01B7
SD01B7:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD01B8
	jmp SDEnd01B8
SD01B8:
	call pIn
	 db 0x0001, '-'
	or rPOk, rPOk
	jnz SD01B9
	jmp SDEnd01B8
SD01B9:
	call Exception
SDEnd01B8:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
SDEnd01B7:
	call cDrop
	ret

;Term	= Factor, [pS, '-', Exception];
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SingleDefinition:
	call cPush
	call Term
	or rPOk, rPOk
	jnz SD01BA
	jmp SDEnd01BA
SD01BA:
	call cPush
	call LblPush
	or rPOk, rPOk
	jnz SD01BB
	jmp SDEnd01BB
SD01BB:
	call cPush
	call cPush
KSRep01BC:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD01BD
	jmp SDEnd01BD
SD01BD:
	call pIn
	 db 0x0001, ','
	or rPOk, rPOk
	jnz SD01BE
	jmp SDEnd01BD
SD01BE:
	call pOut
	 db 15, 10, 9, "or rPOk, rPOk"
	call pOut
	 db 8, 10, 9, "jnz SD"
	call LblNew
	call pOut
	 db 11, 10, 9, "jmp SDEnd"
	call LblTop
	call pOut
	 db 3,10, "SD"
	call LblUse
	call pOut
	 db 1, ":"
	or rPOk, rPOk
	jnz SD01BF
	jmp SDEnd01BD
SD01BF:
	call Term
SDEnd01BD:
	call cDrop
	jrcxz KS01BC
	or rInEndFlg, rInEndFlg
	jnz KS01BC
	jmp KSRep01BC
KS01BC:
	xor rPOk, rPOk
	cmp rInPnt, [rsp+56]
	jz KSEnd01BC
	inc rPOk
KSEnd01BC:
	add rsp, 64
	call cDrop
	or rPOk, rPOk
	jnz SD01C0
	jmp SDEnd01BB
SD01C0:
	call pOut
	 db 6,10, "SDEnd"
	call LblTop
	call pOut
	 db 1, ":"
SDEnd01BB:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
SDEnd01BA:
	call cDrop
	ret

;SingleDefinition= Term	, [							<.	call LblPush.>
;			    , {pS, ','						,<.	call pOut.>
;										<.	 db 15, 10, 9, "or rPOk, rPOk".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, "jnz SD".>
;										<.	call LblNew.>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jmp SDEnd".>
;										<.	call LblTop.>
;										<.	call pOut.>
;										<.	 db 3,10, "SD".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;				        , Term }*				,<.	call pOut.>
;										<.	 db 6,10, "SDEnd".>
;										<.	call LblTop.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;						   ];
;
;
;				   
;				   
;				   	 

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AndDefinition:
	call cPush
	call SingleDefinition
	or rPOk, rPOk
	jnz SD01C1
	jmp SDEnd01C1
SD01C1:
	call cPush
	call LblPush
	or rPOk, rPOk
	jnz SD01C2
	jmp SDEnd01C2
SD01C2:
	call cPush
	call cPush
KSRep01C3:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD01C4
	jmp SDEnd01C4
SD01C4:
	call pIn
	 db 0x0001, '+'
	or rPOk, rPOk
	jnz SD01C5
	jmp SDEnd01C4
SD01C5:
	call pOut
	 db 15, 10, 9, "or rPOk, rPOk"
	call pOut
	 db 8, 10, 9, "jnz AD"
	call LblNew
	call pOut
	 db 11, 10, 9, "jmp ADEnd"
	call LblTop
	call pOut
	 db 3, 10, "AD"
	call LblUse
	call pOut
	 db 1, ":"
	call pOut
	 db 17, 10, 9, "call cAndProlog"
	or rPOk, rPOk
	jnz SD01C6
	jmp SDEnd01C4
SD01C6:
	call SingleDefinition
	or rPOk, rPOk
	jnz SD01C7
	jmp SDEnd01C4
SD01C7:
	call pOut
	 db 17, 10, 9, "call cAndEpilog"
SDEnd01C4:
	call cDrop
	jrcxz KS01C3
	or rInEndFlg, rInEndFlg
	jnz KS01C3
	jmp KSRep01C3
KS01C3:
	xor rPOk, rPOk
	cmp rInPnt, [rsp+56]
	jz KSEnd01C3
	inc rPOk
KSEnd01C3:
	add rsp, 64
	call cDrop
	or rPOk, rPOk
	jnz SD01C8
	jmp SDEnd01C2
SD01C8:
	call pOutLbl
	 db 6, 10, "ADEnd"
SDEnd01C2:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
SDEnd01C1:
	call cDrop
	ret

;AndDefinition	= SingleDefinition, [						<.	call LblPush.>
;			              ,  {pS, '+'				,<.	call pOut.>
;										<.	 db 15, 10, 9, "or rPOk, rPOk".>
;										<.	call pOut.>
;										<.	 db 8, 10, 9, "jnz AD".>
;										<.	call LblNew.>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jmp ADEnd".>
;										<.	call LblTop.>
;										
;										<.	call pOut.>
;										<.	 db 3, 10, "AD".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 1, ":".>
;										
;										<.	call pOut.>
;										<.	 db 17, 10, 9, "call cAndProlog".>
;					         , SingleDefinition		,<.	call pOut.>
;										<.	 db 17, 10, 9, "call cAndEpilog".>
;								     }*		,<.	call pOutLbl.>
;										<.	 db 6, 10, "ADEnd".>
;						    	                ];
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
DefinitionsList:
	call cPush
	call AndDefinition
	or rPOk, rPOk
	jnz SD01C9
	jmp SDEnd01C9
SD01C9:
	call cPush
	call LblPush
	or rPOk, rPOk
	jnz SD01CA
	jmp SDEnd01CA
SD01CA:
	call cPush
	call cPush
KSRep01CB:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD01CC
	jmp SDEnd01CC
SD01CC:
	call pIn
	 db 0x0001, '|'
	or rPOk, rPOk
	jnz SD01CD
	jmp SDEnd01CC
SD01CD:
	call pOut
	 db 10, 10, 9, "jrcxz DL"
	call LblNew
	call pOut
	 db 11, 10, 9, "jmp DLEnd"
	call LblTop
	call pOut
	 db 3, 10, "DL"
	call LblUse
	call pOut
	 db 9, ":", 9, "inc rcx"
	call pOut
	 db 11, 10, 9, "call cTop"
	or rPOk, rPOk
	jnz SD01CE
	jmp SDEnd01CC
SD01CE:
	call AndDefinition
SDEnd01CC:
	call cDrop
	jrcxz KS01CB
	or rInEndFlg, rInEndFlg
	jnz KS01CB
	jmp KSRep01CB
KS01CB:
	xor rPOk, rPOk
	cmp rInPnt, [rsp+56]
	jz KSEnd01CB
	inc rPOk
KSEnd01CB:
	add rsp, 64
	call cDrop
	or rPOk, rPOk
	jnz SD01CF
	jmp SDEnd01CA
SD01CF:
	call pOutLbl
	 db 6, 10, "DLEnd"
SDEnd01CA:
	call cDrop
	xor rPOk, rPOk
	inc rPOk
SDEnd01C9:
	call cDrop
	ret

;DefinitionsList = AndDefinition, [						<.	call LblPush.>
;			           , { pS, '|'					,<.	call pOut.>
;										<.	 db 10, 10, 9, "jrcxz DL".>
;										<.	call LblNew.>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "jmp DLEnd".>
;										<.	call LblTop.>
;										<.	call pOut.>
;										<.	 db 3, 10, "DL".>
;										<.	call LblUse.>
;										<.	call pOut.>
;										<.	 db 9, ":", 9, "inc rcx".>
;										<.	call pOut.>
;										<.	 db 11, 10, 9, "call cTop".>
;					         , AndDefinition }*		,<.	call pOutLbl.>
;										<.	 db 6, 10, "DLEnd".>
; 								    ];
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
pRule:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD01D0
	jmp SDEnd01D0
SD01D0:
	call pIdentifier
	or rPOk, rPOk
	jnz SD01D1
	jmp SDEnd01D0
SD01D1:
	call pOut
	 db 81, 10, ";xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",10
	call pOutLI
	call pOut
	 db 1, ":"
	or rPOk, rPOk
	jnz SD01D2
	jmp SDEnd01D0
SD01D2:
	call pS
	or rPOk, rPOk
	jnz SD01D3
	jmp SDEnd01D0
SD01D3:
	call cPush
	call pIn
	 db 0x0001, '='
	or rPOk, rPOk
	jnz SD01D4
	jmp SDEnd01D4
SD01D4:
	call pOut
	 db 12, 10, 9, "call cPush"
	or rPOk, rPOk
	jnz SD01D5
	jmp SDEnd01D4
SD01D5:
	call cPush
	call DefinitionsList
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01D6
	jmp SDEnd01D4
SD01D6:
	call pS
	or rPOk, rPOk
	jnz SD01D7
	jmp SDEnd01D4
SD01D7:
	call pIn
	 db 0x0001, ';'
	or rPOk, rPOk
	jnz SD01D8
	jmp SDEnd01D4
SD01D8:
	call pOut
	 db 12, 10, 9, "call cDrop"
	call pOut
	 db 6, 10, 9, "ret", 10
SDEnd01D4:
	jrcxz DL01D9
	jmp DLEnd01D9
DL01D9:	inc rcx
	call cTop
	call pIn
	 db 0x0002, '()'
	or rPOk, rPOk
	jnz SD01DA
	jmp SDEnd01DA
SD01DA:
	call pS
	or rPOk, rPOk
	jnz SD01DB
	jmp SDEnd01DA
SD01DB:
	call pIn
	 db 0x0001, '='
	or rPOk, rPOk
	jnz SD01DC
	jmp SDEnd01DA
SD01DC:
	call pOut
	 db 20, 10, 9, "call cOpenTextGram"
	or rPOk, rPOk
	jnz SD01DD
	jmp SDEnd01DA
SD01DD:
	call cPush
	call DefinitionsList
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01DE
	jmp SDEnd01DA
SD01DE:
	call pS
	or rPOk, rPOk
	jnz SD01DF
	jmp SDEnd01DA
SD01DF:
	call pIn
	 db 0x0001, ';'
	or rPOk, rPOk
	jnz SD01E0
	jmp SDEnd01DA
SD01E0:
	call pOut
	 db 21, 10, 9, "call cCloseTextGram"
	call pOut
	 db 6, 10, 9, "ret", 10
SDEnd01DA:
	jrcxz DL01E1
	jmp DLEnd01D9
DL01E1:	inc rcx
	call cTop
	call pIn
	 db 0x0005, '(h,h)'
	or rPOk, rPOk
	jnz SD01E2
	jmp SDEnd01E2
SD01E2:
	call pS
	or rPOk, rPOk
	jnz SD01E3
	jmp SDEnd01E2
SD01E3:
	call pIn
	 db 0x0001, '='
	or rPOk, rPOk
	jnz SD01E4
	jmp SDEnd01E2
SD01E4:
	call pOut
	 db 19, 10, 9, "call cOpenH2HGram"
	or rPOk, rPOk
	jnz SD01E5
	jmp SDEnd01E2
SD01E5:
	call cPush
	call DefinitionsList
	call cDrop
	xor rPOk, rPOk
	inc rPOk
	or rPOk, rPOk
	jnz SD01E6
	jmp SDEnd01E2
SD01E6:
	call pS
	or rPOk, rPOk
	jnz SD01E7
	jmp SDEnd01E2
SD01E7:
	call pIn
	 db 0x0001, ';'
	or rPOk, rPOk
	jnz SD01E8
	jmp SDEnd01E2
SD01E8:
	call pOut
	 db 20, 10, 9, "call cCloseH2HGram"
	call pOut
	 db 6, 10, 9, "ret", 10
SDEnd01E2:
DLEnd01D9:
	call cDrop
SDEnd01D0:
	call cDrop
	ret

;pRule		= pS, pIdentifier,						<.	call pOut.>
;										<.	 db 81, 10, ";xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",10.>
;										<.	call pOutLI.>
;										<.	call pOut.>
;										<.	 db 1, ":".>,
;			 	  pS,('=',					<.	call pOut.>
;										<.	 db 12, 10, 9, "call cPush".>,
;					 [DefinitionsList], pS, ';',		<.	call pOut.>
;										<.	 db 12, 10, 9, "call cDrop".>
;										<.	call pOut.>
;										<.	 db 6, 10, 9, "ret", 10.> 
;				     |'()', pS, '=',				<.	call pOut.>
;										<.	 db 20, 10, 9, "call cOpenTextGram".>,
;					 [DefinitionsList], pS, ';',		<.	call pOut.>
;										<.	 db 21, 10, 9, "call cCloseTextGram".>
;										<.	call pOut.>
;										<.	 db 6, 10, 9, "ret", 10.>
;				     |'(h,h)', pS, '=',				<.	call pOut.>
;										<.	 db 19, 10, 9, "call cOpenH2HGram".>,
;					 [DefinitionsList], pS, ';',		<.	call pOut.>
;										<.	 db 20, 10, 9, "call cCloseH2HGram".>
;										<.	call pOut.>
;										<.	 db 6, 10, 9, "ret", 10.>
;				     );
;
;

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Grammar:
	call cPush
	call pS
	or rPOk, rPOk
	jnz SD01E9
	jmp SDEnd01E9
SD01E9:
	call cPush
RSRep01EE:
	call cPush
	mov InPntOld, rInPnt
	or rPOk, rPOk
	jnz SD01EF
	jmp SDEnd01EF
SD01EF:
	call pRule
	or rPOk, rPOk
	jnz SD01F0
	jmp SDEnd01EF
SD01F0:
	call pS
	or rPOk, rPOk
	jnz SD01F1
	jmp SDEnd01EF
SD01F1:
	call OutSrcLin
	call DspLstTrm
SDEnd01EF:
	call cDrop
	jrcxz RSEnd01EE
	or rInEndFlg, rInEndFlg
	jnz RSEnd01EE
	jmp RSRep01EE
RSEnd01EE:
	xor rPOk, rPOk
	inc rPOk
	call cDrop
SDEnd01E9:
	call cDrop
	ret

;Grammar	= pS, {									<.	mov InPntOld, rInPnt.>
;			, pRule, pS,						<.	call OutSrcLin.>
;										<.	call DspLstTrm.>
;				     } ;
;
;
