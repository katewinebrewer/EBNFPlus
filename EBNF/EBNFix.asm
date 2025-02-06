;*******************************************************************************
; EBNFix shares pointers, variables, subroutine names with grammars and
; applications to link with the Kernel.
; This file should be included in a new grammar definition, eg. 
; a new compiler, interpreter or convertor.

; Have after the GLOBAL declarations in the App the line: 
;	"%include "../EBNF/EBNFix.asm"
; When in reversed order double definition errors will result.

;*******************************************************************************
;				MEMORY MAP
;*******************************************************************************
; for server
sMemL	equ	0x4000000	; 64MB total space 
sMemBL	equ	0x100		; 256B base length
sMemSL	equ	0x800		;   2k stack length

; for each thread
tMemL	equ	0x0800000	;  8MB total space
tMemBL	equ	0x100		; 256B base length
tMemSL	equ	0x800		;   2k stack length

;*******************************************************************************
;				CONTEXT PARAMETERS
;*******************************************************************************
; in registers
%define rPOk		rcx	; flag 1=match 0=no match during parse
%define rInPnt		r8	; moving pointer in sIn to continue parse 
%define rInEnd		r9	; flag if no further parse input available
%define rOutPnt		r10	; moving pointer to append in sOut
%define rLastIn		r11	; last term that matched in parse 
%define rLastInLen	r12	; length of LastIn
%define rFactCnt	r13	; index during factoring
%define rInEndFlg	r14	; end of Input message
%define rInChrCnt	r15	; character counter during text parsing

; memory available per thread (each thread has privat rbp area)
%define mMemEnd		rbp		; end of thread Mem
%define mMem0		qword [rbp-  8]	; start of Mem

; for EBNF parser in thread memory
%define In0		[rbp- 16]	; start of In
%define InPntMax	[rbp- 24]	; Pnt furthest parsed before mismatch
%define InPntOld	[rbp- 32]	; Used for display parsed terminal
%define InPrev		[rbp- 40]	; 
%define InPrevLen	[rbp- 48]	; 
%define OutEnd		[rbp- 56]	; end of out going msg
%define Out0		[rbp- 64]	; start of out going msg
%define OutBufEnd	[rbp- 72]	; end of space avail for outgoing msg
%define LblNxtNew	[rbp- 80]	;

%define SockFD		[rbp- 88]	; one thread max one Socket (for now)
%define MasterSockFD	[rbp- 96]	; socket to whch thread msgs are swtched


%define Tmp0		qword [rbp-104]	; general purpose var, ok for threading
%define Tmp1		qword [rbp-112]
%define Tmp2		qword [rbp-120]
%define Tmp3		qword [rbp-128]

%define InHold0		qword [rbp-136]	; todo: replace InPrev with InHold, remove automatic update of InPrev during context save/restore (used in Functions.
%define InHoldLen0	qword [rbp-144]
%define InHold1		qword [rbp-152]
%define InHoldLen1	qword [rbp-160]
%define InHold2		qword [rbp-168]
%define InHoldLen2	qword [rbp-176]
%define InHold3		qword [rbp-184]	
%define InHoldLen3	qword [rbp-192]
%define InHold4		qword [rbp-200]	
%define InHoldLen4	qword [rbp-208]
%define InHold5		qword [rbp-216]	
%define InHoldLen5	qword [rbp-224]

; threading return stack
%define mAddQuit	[rbp-tMemBL-8]	; BOS	= [rbp-248] (see line 16)
%define mAddThread	[rbp-tMemBL-16]	; 	= [rbp-256] (see line 16)			; check not tested yet!!!!


;******************************************************* Application **********
EXTERN Rum

;******************************************************* EBNFKernel  **********
EXTERN CLArg
EXTERN sOut, sPush, sPushA, sCLArg, sConcat, sLI, sMessage, sI2HS
EXTERN sLeft, sCutRight, sDrop, sDup, sKeyIn
EXTERN mRSP
EXTERN MemMap, MemUnmap

EXTERN InFile, OutFile
EXTERN EOF
EXTERN F2I, E2O, I2O, O2F, O2I, F2O, F2OAppend	; from X2X.asm
EXTERN a, b, n, sIFSF				; from abn.asm
EXTERN LILenMax, LIValMax

EXTERN pIn, pInterval, pIntervalQuad, pFindIn
EXTERN cPush, cPop, cTop, cAndProlog, cAndEpilog, cDrop, cDropExcept
EXTERN DropLastChar, IsNotDef

EXTERN cOpenTextGram, cCloseTextGram
EXTERN cOpenH2HGram, cCloseH2HGram

EXTERN lClear, LblNew, LblUse, LblCls, LblPush, LblTop, LblDrop, pOutLbl

EXTERN SDIdStart, SDIdOper, SDIdEnd
EXTERN pOut, pOutCr,  pOutLIHex, pOutLIHex2Bin, pOutLITrim, pOutLIdpTrim

EXTERN pOutLI, pOutLILen
EXTERN pPI, pOutPI, pOutPILen

EXTERN pHI0, pOutHI0, pOutHILen0
EXTERN pHI1, pOutHI1, pOutHILen1
EXTERN pHI2, pOutHI2, pOutHILen2
EXTERN pHI3, pOutHI3, pOutHILen3
EXTERN pHI4, pOutHI4, pOutHILen4
EXTERN pHI5, pOutHI5, pOutHILen5, sHI5

EXTERN OutSrcLin
EXTERN pOutInPnt, pOutLILenByte
EXTERN DspLstTrm, MsgLI, Message, MessageMem, ErrorMessage, Quit
EXTERN Bin2Dec, Bin4Dec, BinNDec, Bin1Hex, Bin2Hex, BinNHex, Dec2Bin, Hex2Bin
EXTERN WaitSecond, EcmaTime, IMFTime, GetTime
EXTERN iRandom

EXTERN dspebnf

;***************************************************** Heap.asm ***************
EXTERN hClear, hOpen, hAdd, hClose, hCap, hGC
EXTERN HeapPnt, Heap0, HeapEnd
EXTERN dspheap
;***************************************************** Thread.asm *************
Extern Thread, wQuit
;***************************************************** IP.asm *****************
Extern ServerSockOpen, ServerSockClose
Extern ClientSockOpen, ClientSockClose
Extern S2I, O2S
Extern dmpin, dmpout, dspin, dspout, dspfd, dspwmem
;***************************************************** DES.asm ****************
EXTERN DES, GenEncKeys, GenDecKeys
EXTERN SwapKeySet, DupKeySet, DropKeySet
;***************************************************** Dir.asm ****************
EXTERN pOutDir

;***************************************************** DebugTools.asm *********
EXTERN dspreg, dsprex, dspxmm, dspymm
EXTERN dmphex, dmpreg, dmprex, dmpxmm, dmpymm
EXTERN dmphexrsi, dmphex10, dmphexold
EXTERN msg, quit


