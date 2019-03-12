Title   Sound Blaster DMA-s lejatszo es felvevo rutinok

.286
;MODEL TINY
;MODEL LARGE
MODEL TPASCAL

  PUBLIC  SB_INIT
  PUBLIC  SB_REC
  PUBLIC  SB_PLAY
  PUBLIC  SB_ADDPUFFER
  PUBLIC  SB_CLOSE
  PUBLIC  SB_DMAWORK

  BLOCKTYPE STRUC
    BADDR   DD 00
    BLEN    DW 00
    Allapot DB 0FFH
  BLOCKTYPE ENDS

  BLSZAM    EQU 40


;/* Include file for Soundblaster library */

;/* Defines for Soundblaster and Soundblaster Pro IO address */
LEFT_FM_STATUS      EQU 00H    ;/* Pro only */
LEFT_FM_ADDRESS     EQU 00H    ;/* Pro only */
LEFT_FM_DATA        EQU 01H    ;/* Pro only */
RIGHT_FM_STATUS     EQU 02H    ;/* Pro only */
RIGHT_FM_ADDRESS    EQU 02H    ;/* Pro only */
RIGHT_FM_DATA       EQU 03H    ;/* Pro only */
MIXER_ADDRESS       EQU 04H    ;/* Pro only */
MIXER_DATA          EQU 05H    ;/* Pro only */
DSP_RESET           EQU 06H    ;
FM_STATUS           EQU 08H
FM_ADDRESS          EQU 08H
FM_DATA             EQU 09H
DSP_READ_DATA       EQU 0AH
DSP_WRITE_DATA      EQU 0CH
DSP_WRITE_STATUS    EQU 0CH
DSP_DATA_AVAIL      EQU 0EH
CD_ROM_DATA         EQU 10H    ;/* Pro only */
CD_ROM_STATUS       EQU 11H    ;/* Pro only */
CD_ROM_RESET        EQU 12H    ;/* Pro only */
CD_ROM_ENABLE       EQU 13H    ;/* Pro only */

ADLIB_FM_STATUS     EQU 388H
ADLIB_FM_ADDRESS    EQU 388H
ADLIB_FM_DATA       EQU 389H

;/* Defines for 8237 DMA Controller IO addresses */
DMA         EQU 00H
CH0_BASE    EQU DMA+0
CH0_COUNT   EQU DMA+1
CH1_BASE    EQU DMA+2
CH1_COUNT   EQU DMA+3
CH2_BASE    EQU DMA+4
CH2_COUNT   EQU DMA+5
CH3_BASE    EQU DMA+6
CH3_COUNT   EQU DMA+7
DMA_STATUS  EQU DMA+8
DMA_CMD     EQU DMA+8
DMA_REQUEST EQU DMA+9
DMA_MASK    EQU DMA+10
DMA_MODE    EQU DMA+11
DMA_FF      EQU DMA+12
DMA_TMP     EQU DMA+13
DMA_CLEAR   EQU DMA+13
DMA_CLRMSK  EQU DMA+14
DMA_WRMSK   EQU DMA+15
DMAPAGE     EQU 80H

;/* DSP Commands */
DIRECT_8_BIT_DAC    EQU 010H
DMA_8_BIT_DAC	    EQU 014H
DMA_2_BIT_DAC	    EQU 016H
DMA_2_BIT_REF_DAC   EQU 017H
DIRECT_ADC	    EQU 020H
DMA_ADC 	    EQU 024H
MIDI_READ_POLL	    EQU 030H
MIDI_READ_IRQ	    EQU 031H
MIDI_WRITE_POLL     EQU 038H
TIME_CONSTANT	    EQU 040H
DMA_4_BIT_DAC	    EQU 074H
DMA_4_BIT_REF_DAC   EQU 075H
DMA_26_BIT_DAC	    EQU 076H
DMA_26_BIT_REF_DAC  EQU 077H
HALT_DMA	    EQU 0D0H
CONTINUE_DMA	    EQU 0D4H
SPEAKER_ON	    EQU 0D1H
SPEAKER_OFF	    EQU 0D3H
DSP_ID		    EQU 0E0H
DSP_VER 	    EQU 0E1H
MDAC1		    EQU 061H
MDAC2		    EQU 062H
MDAC3		    EQU 063H
MDAC4		    EQU 064H
MDAC5		    EQU 065H
MDAC6		    EQU 066H
MDAC7		    EQU 067H


.DATA

VARELEJE   DB ?
BLOUTP     DW ?
BLINP      DW ?
Blocks     BLOCKTYPE BLSZAM DUP(?)
DIRECTION  DW ?
ActBuffer  DD ?
ActLen     DW ?
DMA_ERRNO  DB ?
DMA_Active DW ?
BLCOUNT    DW ?

PageNum    DB ?
Rel_Addr   DW ?

VARKOZEPE  DB ?

CallB      DD ?
BaseP      DW ?
DMAC       DW ?
IRQN       DW ?
SAVEINT    DD ?
VARVEGE    DB ?
.CODE


WRITEDAC MACRO param
LOCAL @@1
  MOV    DX,BaseP
  ADD    DX,DSP_WRITE_STATUS
@@1:
  IN     AL,DX
  AND    AL,80H
  JNZ    @@1
  MOV    DX,BaseP
  ADD    DX,DSP_WRITE_DATA
  MOV    AL,param
  OUT    DX,AL
ENDM

OUTPORT MACRO portadd,value
  MOV    DX,portadd
  MOV    AL,value
  OUT    DX,AL
ENDM


DMA_Mask     EQU 0AH
DMA_FF       EQU 0CH
DMA_TRMODE   EQU 0BH
DMA_READ     EQU 48H
DMA_WRITE    EQU 44H
RESET_CMD    EQU 04H

Make_Relative Proc ; Act_Buffer -> PageNum + Rel_Addr
        MOV   AX,WORD Ptr [ActBuffer+2] ; szegmens
        MOV   BX,AX
        MOV   CX,12
        SHR   AX,CL       ; Felso 4 bit : ez lesz a Page
        MOV   CX,4
        SHL   BX,CL       ; Also 12 bit : atalakitjuk offset-te
        ADD   BX,Word Ptr [ActBuffer]   ; az eredeti offset
        JNC   KeszIsVan
        INC   AX
KeszIsVan:
        MOV   PageNum,AL
        MOV   Rel_Addr,BX
        Ret
Make_Relative EndP

DMA_Setup Proc                  ; programming the DMAC
                                ; ActBuffer DWORD puffercim
                                ; ActLen    WORD  Pufferhossz
                                ; Direction BYTE  0 = Play
                                ;                 1 = REC
                                ; DMAC      WORD  csatornaszam

        CALL    Make_Relative
        MOV     BL,Byte Ptr [DMAC]
        OR      BL,4
        OUTPORT DMA_Mask,BL     ; DMA keres letiltasa
        OUTPORT DMA_FF,0
        MOV     DX,[DMAC]
        SHL     DX,1            ; Current Address Registers
        MOV     AX,[Rel_Addr]
        OUT     DX,AL           ; Offset
        MOV     AL,AH
        OUT     DX,AL           ; Szegmens

        INC     DX              ; Current Word Count Registers
        MOV     AX,ActLen
        OUT     DX,AL
        MOV     AL,AH
        OUT     DX,AL

        OUTPORT 83H,PageNum     ; Page register

        CMP     DIRECTION,1
        JZ      DMA_RECMODE
        MOV     AX,DMA_READ
        JMP     SHORT DJ1
DMA_RECMODE:
        MOV     AX,DMA_WRITE
DJ1:
        ADD     AX,DMAC
        MOV     DX,DMA_TRMODE
        OUT     DX,AL           ; Mode register

        OUTPORT DMA_MASK,Byte Ptr [DMAC] ; DMA keres engedelyezese
        Ret
DMA_Setup EndP


SbCard_Init  proc
    mov al,1
    mov dx,[BaseP]
    add dx,DSP_RESET
    out dx,al
    in	al,dx
    in	al,dx
    in	al,dx
    in	al,dx
    mov al,0
    out dx,al
    add dx,4
    mov cx,100
@@1:
    in al,dx
    cmp al,0AAh
    je @@2
    loop @@1
    mov  ax,1
    ret
@@2:
    mov ax,0
    ret
SbCard_Init  endp

;+---------------------------------------------------------------------------+
;| dma_reset                                                                  |
;| ------------------------------------------------------------------------- |
;| AX = Channel = 0-3                                                        |
;|         Resets the specified channel.                                     |
;+---------------------------------------------------------------------------+

dma_reset Proc
        push dx
        mov  dx,DMA_Mask
        add  ax,reset_cmd
        out  dx,al
        pop  dx
        ret
dma_reset EndP


AddBlock PROC  ; BX:DX=cim, CX=hossz, ha AX=1 akkor igazi blokkvege
   PUSH  CX
   PUSH  BX
   PUSH  DX
   PUSH  AX
   MOV   AX,Size BlockType
   MOV   CX,BLINP
   MUL   CL
   MOV   BX,AX
   POP   AX      ; igazi vege jelzo
   MOV   CX,7
   SHL   AL,CL
   OR    AL,1
   MOV   [Blocks+Allapot+BX],AL
   POP   AX      ; offset
   MOV   Word Ptr [Blocks+BAddr+BX],AX
   POP   AX      ; szegmens
   MOV   Word Ptr [Blocks+BAddr+2+BX],AX
   POP   AX      ; hossz
   MOV   [Blocks+BLen+BX],AX

   MOV   AX,BLINP          ; noveljuk a pointert
   INC   AX
   CMP   AX,BLSZAM
   JNZ   MegNemFutottTul
   XOR   AX,AX
MegNemFutottTul:
   MOV   BLINP,AX

   RET
AddBlock ENDP

NextBlock PROC
   CMP    DMA_Active,1
   JNZ    TalanKell
   JMP    NemKellMost
TalanKell:
   MOV   AX,Size BlockType
   MOV   CX,BLOUTP
   MUL   CL
   MOV   BX,AX
   MOV   AL,[Blocks+Allapot+BX]
   AND   AL,3                   ; A felso bit most nem erdekes
   CMP   AL,1                   ; 1 - inditando blokk
   JZ    MostKell
   JMP   NemKellMost
MostKell:
   INC   [Blocks+Allapot+BX]    ; 2 - Lejatszas alatt

   MOV   AX,Word Ptr [Blocks+BADDR+BX]      ; Puffercim
   MOV   Word Ptr ActBuffer,AX
   MOV   AX,Word Ptr [Blocks+BADDR+2+BX]    ; szegmens
   MOV   Word Ptr [ActBuffer+2],AX

   MOV   CX,[Blocks+BLEN+BX]                ; Pufferhossz
   DEC   CX                                 ; !!!!!!!!!
   MOV   ActLen,CX

   CMP   Direction,1                        ; felvetel ?
   JZ    REC_START

   CALL  Dma_Setup
   MOV   CX,ActLen

   WRITEDAC DMA_8_BIT_DAC
   WRITEDAC CL
   WRITEDAC CH
   JMP   StartVege

REC_START:
   CALL  DMA_Setup
   MOV   CX,ActLen
   WRITEDAC DMA_ADC
   WRITEDAC CL
   WRITEDAC CH

StartVege:

   MOV   DMA_ACTIVE,1                       ; DMA elindult

   MOV   AX,BLOUTP                          ; Raallunk a kovetkezore
   INC   AX
   CMP   AX,BLSZAM
   JNZ   NemCsordul
   XOR   AX,AX
NemCsordul:
   MOV   BLOUTP,AX                          ; es visszatoltjuk
NemKellMost:
   RET
NextBlock ENDP

Torol1 PROC
   PUSH   ES
   MOV    AX,DS
   MOV    ES,AX
   MOV    DI,Offset VARELEJE
   MOV    CX,offset VARKOZEPE-offset VARELEJE
   XOR    AL,AL
   CLD
   REPZ   STOSB
   POP    ES
   RET
Torol1 ENDP

SAMPLE_RATE PROC
   MOV   DX,15
   MOV   AX,16960

   DIV   BX
   MOV   BX,256
   SUB   BX,AX

   writedac TIME_CONSTANT     ;/* Command byte for sample rate */
   writedac BL                ;/* Sample rate time constant */

   RET
SAMPLE_RATE ENDP


SBINT:
  STI
  PUSHA
  PUSH   DS
  PUSH   ES

  ;MOV    AX,0B800H
  ;MOV    DS,AX
  ;INC    Word Ptr DS:[0000]

  MOV    AX,@DATA
  MOV    DS,AX

  MOV    DX,BaseP
  ADD    DX,DSP_DATA_AVAIL
  IN     AL,DX             ; SB Acknowledge

  MOV    DMA_ACTIVE,0      ; Mar nem aktiv, a NextBlock majd bekapcsolja
  PUSH   [BLOUTP]
  CALL   NextBlock
  POP    AX
  SUB    AX,1   ; !!!!!! a DEC NEM allitja a carryt ; Az elozo blockra allunk
  JNC    NemTul
  MOV    AX,BLSZAM-1
NemTul:       ; AX-ben a lejatszott blokkra mutato index
  MOV    CX,Size BlockType
  MUL    CL
  MOV    BX,AX
  AND    Byte Ptr [Blocks+Allapot+BX],0FCH
  JZ     NemIgazi
  MOV    Byte Ptr [Blocks+Allapot+BX],00H
  INC    BLCOUNT
  MOV    AX,Word Ptr [CallB]
  OR     AX,Word Ptr [CallB+2]
  JZ     NemIgazi          ; Nincs beallitva callback cim

  MOV    AX,BLCOUNT
  CALL   DWORD PTR [CallB] ; callback hivas

NemIgazi:
  MOV    AL,20H
  OUT    20H,AL            ; INT vezerlo acknowledge

  POP    ES
  POP    DS
  POPA
  IRET

INT_BEFUZ PROC
  PUSH   ES
  XOR    AX,AX
  MOV    ES,AX
  MOV    BX,[IRQN]
  ADD    BX,8
  ADD    BX,BX
  ADD    BX,BX
  MOV    AX,ES:[BX]
  MOV    WORD PTR [SAVEINT],AX
  MOV    AX,ES:[BX+2]
  MOV    WORD PTR [SAVEINT+2],AX
  CLI
  MOV    ES:[BX],Offset SBINT
  MOV    WORD PTR ES:[BX+2],SEG SBINT

  MOV    DX,21H
  IN     AL,DX
  MOV    CX,IRQN
  MOV    AH,1
  SHL    AH,CL
  NOT    AH
  AND    AL,AH
  OUT    DX,AL
  STI

  POP    ES
  RET
INT_BEFUZ ENDP

INT_KIFUZ PROC
  PUSH   ES
  MOV    BX,[IRQN]
  XOR    AX,AX
  MOV    ES,AX
  MOV    BX,[IRQN]
  ADD    BX,8
  ADD    BX,BX
  ADD    BX,BX
  CLI
  MOV    AX,WORD PTR [SAVEINT]
  MOV    ES:[BX],AX
  MOV    AX,WORD PTR [SAVEINT+2]
  MOV    ES:[BX+2],AX

  MOV    DX,21H
  IN     AL,DX
  MOV    CX,IRQN
  MOV    AH,1
  SHL    AH,CL
  OR     AL,AH
  OUT    DX,AL
  STI

  POP    ES
  RET
INT_KIFUZ ENDP

SB_INIT PROC
ARG BASEPORT:WORD,IRQNUM:WORD,DMACHAN:WORD,CALLBACK:DWORD

   MOV   AX,BASEPORT
   MOV   [BaseP],AX
   LES   DI,CALLBACK
   MOV   WORD PTR [CallB],DI
   MOV   WORD PTR [CallB+2],ES
   MOV   AX,DMACHAN
   MOV   [DMAC],AX
   MOV   AX,IRQNUM
   MOV   [IRQN],AX
   CALL  Int_Befuz
   CALL  SBCard_Init  ; AX = 0 vagy 1
   RET
SB_INIT ENDP

SB_REC PROC
ARG FREKV : WORD
   CALL  SBCard_Init
   CALL  TOROL1
   MOV   Direction,1
   MOV   BX,FREKV
   CALL  Sample_Rate
   CALL  DMA_reset
   MOV   BLINP,0
   MOV   BLOUTP,0
   MOV   DMA_ACTIVE,0
   RET
SB_REC ENDP

SB_PLAY PROC
ARG FREKV : WORD
   CALL  SBCard_Init
   CALL TOROL1
   MOV  Direction,0
   MOV  BX,FREKV
   CALL Sample_Rate
   WRITEDAC SPEAKER_ON
   CALL DMA_Reset
   MOV   BLINP,0
   MOV   BLOUTP,0
   MOV   DMA_ACTIVE,0
   RET
SB_PLAY ENDP

SB_ADDPUFFER PROC
ARG BlAddr:DWORD,LEN:WORD
   MOV   DX,WORD PTR [BlAddr]    ; Offset
   MOV   BX,WORD PTR [BlAddr+2]  ; Szegmens
   MOV   CX,[LEN]               ; Hossz
   MOV   AX,BX
   SHL   AX,1
   SHL   AX,1
   SHL   AX,1
   SHL   AX,1        ; A szegmenst atszamoljuk offset-be
   ADD   AX,DX       ; Hozzaadjuk az offset-et
   ADD   AX,CX       ; + hossz tullog-e a hataron ?
   JNC   Egy_Block
   SUB   CX,AX       ; levonjuk a tullogast
   PUSH  CX          ; 1. resz hossza
   PUSH  AX          ; 2. resz hossza
   XOR   AX,AX
   CALL  AddBlock    ; hozzaadjuk az elso reszt BX:DX, CX, AX
   POP   CX          ; 2. resz hossza
   POP   AX          ; 1. resz hossza
   MOV   DX,WORD PTR [BlAddr]     ; Offset
   MOV   BX,WORD PTR [BlAddr+2]   ; Szegmens
   ADD   DX,AX                   ; az 1. reszt kihagyjuk
   JNC   Egy_Block
   ADD   BX,1000H                ; Ha az offset tulcsordul, a szegmens ++

Egy_Block:
   MOV   AX,1
   CALL  AddBlock
   CALL  NextBlock
   RET
SB_ADDPUFFER ENDP

SB_CLOSE PROC
   CMP   DMA_ACTIVE,1
   JNZ   NEM_ACTIVE
   WRITEDAC HALT_DMA
   CALL  DMA_reset
NEM_ACTIVE:
   CMP   Direction,1
   JZ    NincsHangsz
   WRITEDAC SPEAKER_OFF
NincsHangsz:
   CALL  Int_Kifuz
   RET
SB_CLOSE ENDP

SB_DMAWORK PROC
   MOV   AX,DMA_ACTIVE
   RET
SB_DMAWORK ENDP


END
