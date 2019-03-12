Title   WAV library kezelo rutinok

.MODEL LARGE,PASCAL
.CODE
.286C
	  PUBLIC  _INIT_MEM
	  PUBLIC  _INIT_LIB
	  PUBLIC  _CSOMAG_FEL
	  PUBLIC  _KIBONTAS
	  PUBLIC  _LEZAR

          DB 10 Dup(0)
XmsCim    DW 0
          DW 0
XmsHandle DW 0
XmsOke    DB 0
XmsErr    DB 0
EnnyiKell DW 0
HolTartL  DW 0
HolTartH  DW 0
PB        DB 16 DUP(0)
DW 0

MaxWav    EQU 2000
;  *********************   WFL fejlec   **********************


Azon       DB "      ";
FejHossz   DW 0
Verzio     DW 0
Tipus      DB 0
StartOfDL  DW 0
StartOfDH  DW 0
DirHossz   DW 0
Comment    DB 0
	   DB 128 DUP(0)

	   DB 50  DUP(0) ; Ha kesobb kell valami

StartCimek DB MaxWav*6 DUP(0)

DI_Szam   DW 0
DI_Szoveg DB 17 DUP(0)
DI_StartL DW 0
DI_StartH DW 0
          DB 11 Dup(0)
;******************   PCMHUF fejlec   ********************
HAzon       DB "      "
HFejHossz   DW 0
HVerzio     DW 0
HTipus      DB 0
FullHosszL  DW 0
FullHosszH  DW 0
TomHosszL   DW 0
TomHosszH   DW 0
Frekv       DD 0
Felbontas   DB 0
Csatorna    DB 0
            DB 0
ELOZO       DB 80H
AXMENT      DW 0

KibontT DB 0
DB   1,  -1,   2,  -2,   3,  -3,   4,  -4,   5,  -5
DB   6,  -6,   7,  -7,   8,  -8,   9,  -9,  10, -10
DB  11, -11,  12, -12,  13, -13,  14, -14,  15, -15
DB  16, -16,  17, -17,  18, -18,  19, -19,  20, -20
DB  21, -21,  22, -22,  23, -23,  24, -24,  25, -25
DB  26, -26,  27, -27,  28, -28,  29, -29,  30, -30
DB  31, -31,  32, -32,  33, -33,  34, -34,  35, -35
DB  36, -36,  37, -37,  38, -38,  39, -39,  40, -40
DB  41, -41,  42, -42,  43, -43,  44, -44,  45, -45
DB  46, -46,  47, -47,  48, -48,  49, -49,  50, -50
DB  51, -51,  52, -52,  53, -53,  54, -54,  55, -55
DB  56, -56,  57, -57,  58, -58,  59, -59,  60, -60
DB  61, -61,  62, -62,  63, -63,  64, -64,  65, -65
DB  66, -66,  67, -67,  68, -68,  69, -69,  70, -70
DB  71, -71,  72, -72,  73, -73,  74, -74,  75, -75
DB  76, -76,  77, -77,  78, -78,  79, -79,  80, -80
DB  81, -81,  82, -82,  83, -83,  84, -84,  85, -85
DB  86, -86,  87, -87,  88, -88,  89, -89,  90, -90
DB  91, -91,  92, -92,  93, -93,  94, -94,  95, -95
DB  96, -96,  97, -97,  98, -98,  99, -99, 100,-100
DB 101,-101, 102,-102, 103,-103, 104,-104, 105,-105
DB 106,-106, 107,-107, 108,-108, 109,-109, 110,-110
DB 111,-111, 112,-112, 113,-113, 114,-114, 115,-115
DB 116,-116, 117,-117, 118,-118, 119,-119, 120,-120
DB 121,-121, 122,-122, 123,-123, 124,-124, 125,-125
DB 126,-126, 127,-127,-128


Van_Xms PROC NEAR;  Ha van Xms akkor AX=0 egyebkent AX=1
  MOV   AX,4300H
  Int   2FH
  CMP   AL,80H
  MOV   AX,1
  JNZ   Nincs_Xms
  MOV   AX,4310H
  Int   2FH
  MOV   CS:[XmsCim],BX
  MOV   CS:[XmsCim+2],ES
  XOR   AX,AX
Nincs_Xms:
  RET
Van_Xms ENDP


Xms_Avail PROC NEAR;
  MOV   AH,08
  Call  Dword Ptr CS:[XmsCim]
					; AX-ben a legnagyob osszefuggo block
					; DX-ben az egesz merete
  OR   AL,AH
  JZ   HIBA1
  XOR  BL,BL
HIBA1:
  MOV  AL,BL
  RET
xms_Avail ENDP

Xms_Alloc PROC NEAR ; Input DX = Hany Kilobyte-ot
  MOV   AH,09
  Call  Dword Ptr CS:[XmsCim]
  MOV   CS:[XmsHandle],DX  ; Ez lesz a handle
  OR   AL,AH
  JZ   HIBA2
  XOR  BL,BL
HIBA2:
  MOV  AL,BL
  RET
Xms_Alloc EndP

Xms_DeAlloc PROC NEAR
  MOV   AH,0AH
  MOV   DX,CS:[XmsHandle]
  Call  Dword Ptr CS:[XmsCim]
  OR   AL,AH
  JZ   HIBA3
  XOR  BL,BL
HIBA3:
  MOV  AL,BL
  RET
Xms_DeAlloc ENDP

Xms_Move Proc NEAR
  PUSH  DS
  MOV   AH,0BH
  MOV   SI,Offset PB
  PUSH  CS
  POP   DS
  Call  Dword Ptr CS:[XmsCim]
  OR    AL,AH
  JZ    HIBA4
  XOR   BL,BL
HIBA4:
  MOV   AL,BL
  POP   DS
  RET
Xms_Move ENDP


_INIT_MEM PROC FAR KBytes:WORD ;   Vissza : AL= Hibakod

  MOV   DX,[KBytes] ; DX = SIZE IN Kbytes
  MOV   CS:[EnnyiKell],DX
  CALL  VAN_Xms
  OR    AL,AL
  JNZ   HibaVan
  MOV   DX,CS:[EnnyiKell]
  Call  Xms_Alloc
HibaVan:
  RET
_INIT_MEM ENDP


_INIT_LIB PROC FAR   ; Vissza: AX=0 : semmi baj

  PUSHA
  PUSH  DS
  PUSH  ES

  MOV   CX,8
  XOR   BX,BX
  XOR   DX,DX
  MOV   AX,CS
  MOV   ES,AX
  MOV   DI,Offset Azon
  CALL  Csomag_Le

  OR    BL,BL
  JNZ   RosszLib1

  CMP   WORD PTR CS:[Azon+0],4350H ; PC
  JNZ   RosszLib1
  CMP   WORD PTR CS:[Azon+2],4C4DH ; ML
  JNZ   RosszLib1
  CMP   WORD PTR CS:[Azon+4],4249H ; IB    vagyis : PCMLIB
  JNZ   RosszLib1
  Jmp   JoLib
RosszLib1:
  MOV   CS:[AXMENT],AX
  Jmp   LInitV
JoLib:
  MOV   CX,CS:[FejHossz]   ; Most mar az egesz fejlec johet
  XOR   BX,BX
  XOR   DX,DX
  MOV   AX,CS
  MOV   ES,AX
  MOV   DI,Offset Azon
  CALL  Csomag_Le

  OR    BL,BL
  JNZ   RosszLib1


  MOV   CX,CS:[DirHossz]

DirCik:
  PUSH  CX
  MOV   CX,23+1      ; Ennyi byte egy dir bejegyzes
  MOV   AX,CS
  MOV   ES,AX
  MOV   DI,Offset DI_Szam
  MOV   DX,CS:[StartOfDL]
  MOV   BX,CS:[StartOfDH]
  CALL  Csomag_Le

  OR    BL,BL
  JZ    JoVan

  POP   CX
  JMP   SHORT RosszLib1

JoVan:
  ADD   CS:[StartOfDL],23
  ADC   CS:[StartOfDH],0
  MOV   BX,CS:[DI_Szam]        ; Hanyas szamu
  MOV   DX,BX
  ADD   BX,BX  ;*2
  ADD   BX,DX  ;*3
  ADD   BX,BX                  ; *6
  ADD   BX,Offset StartCimek

  MOV   DX,CS:[DI_StartL]       ; ennek a hullamnak a filepos-a
  MOV   CS:[BX],DX
  MOV   AX,CS:[DI_StartH]
  MOV   CS:[BX+2],AX
  PUSH  BX
  MOV   BX,AX
  MOV   CX,25+1          ; Ennyi byte egy PCMHUF fejlec
  MOV   AX,CS
  MOV   ES,AX
  MOV   DI,Offset HAzon       ; Ide toltjuk le
  CALL  Csomag_Le

  OR    BL,BL
  POP   BX

  JZ    JovanNa

  POP   CX
  MOV   AX,CX
  JMP   RosszLib1

JovanNa:
  ADD   Word Ptr CS:[BX],25
  ADC   Word Ptr CS:[BX+2],0
  MOV   AX,CS:[TomHosszL]
  ADD   AX,4
  MOV   CS:[BX+4],AX
  POP   CX
  LOOP  DirCik

  XOR   AX,AX
  MOV   CS:[AXMENT],AX
LInitV:
  POP   ES
  POP   DS
  POPA
  MOV   AX,CS:[AXMENT]
  RET
_INIT_LIB ENDP


_CSOMAG_FEL PROC FAR BlokkMeret:Word,PCim:DWord

  PUSH  ES
  PUSH  DS

  MOV   CX,[BlokkMeret]  ; Mennyit
  LES   DI,[PCim]        ; Honnan

  MOV   Word Ptr CS:[PB],CX    ; +0  Hanyat
  MOV   Word Ptr CS:[PB+4],0   ; +4  Source handle  { 0 = mem }
  MOV   Word Ptr CS:[PB+6],DI  ; +6  Source offset
  MOV   Word Ptr CS:[PB+8],ES  ; +8  Source segment
  MOV   AX,CS:[XmsHandle]
  MOV   Word Ptr CS:[PB+10],AX ; +10 Dest. handle
  MOV   AX,CS:[HolTartL]
  MOV   Word Ptr  CS:[PB+12],AX ; +12 Dest. Offset Low Word
  MOV   AX,CS:[HolTartH]
  MOV   Word Ptr  CS:[PB+14],AX ; +12 Dest. Offset High Word

  ADD   CS:[HolTartL],CX
  ADC   CS:[HolTartH],0

  CALL  Xms_Move

  POP   DS
  POP   ES

  RET
_CSOMAG_FEL ENDP


CSOMAG_LE PROC NEAR  ; CX = Mennyit  ES:DI = Hova   BX:DX = Offset

  MOV   Word Ptr CS:[PB],CX     ; +0  Hanyat
  MOV   AX,CS:[XmsHandle]
  MOV   Word Ptr CS:[PB+4],AX   ; +4  Source handle
  MOV   Word Ptr CS:[PB+6],DX   ; +6  Source offset
  MOV   Word Ptr CS:[PB+8],BX   ; +8  Source segment
  MOV   Word Ptr CS:[PB+10],0   ; +10 Dest. handle    { 0 = MEM }
  MOV   Word Ptr  CS:[PB+12],DI ; +12 Dest. Offset
  MOV   Word Ptr  CS:[PB+14],ES ; +12 Dest. Segment

  CALL  Xms_Move
  MOV   AX,BX
  RET
CSOMAG_LE ENDP


KIBONT PROC NEAR
;               { DS:SI Tomoritett puffer      }
;               { ES:DI Tomoritetlen puffer    }
;               { CX    Tomoritetlen hossz     }

  MOV   CS:[ELOZO],80H
  CLD
  MOV   AH,8                ;{ Ennyi feldolgozatlan bit van benne }
  LODSB

UjOutByte:
  PUSH  CX
  XOR   CX,CX
  MOV   BX,Offset KibontT   ;{ Kiindulasi cim             }
  MOV   DX,1                ;{ Ennyivel kell majd eltolni }
Elagazas:

  RCL   AL,1
  PUSHF
  DEC   AH
  JNZ   VanMegBit
  LODSB
  MOV   AH,8                ;{ Ennyi feldolgozatlan bit van benne }
VanMegBit:
  POPF
  JNC   NeTovabb

  ADD   BX,DX
  ADD   DX,DX
  INC   CX
  JMP   Elagazas

NeTovabb:
							;{ A baziscim BX-ben}
  XOR   DX,DX               ;{ DX-be a hasznos biteket gyujtom ossze }
  JCXZ  EnnyiBit
BitCik1:
  RCL   AL,1
  PUSHF
  DEC   AH
  JNZ   VanMegBit2
  LODSB
  MOV   AH,8                ;{ Ennyi feldolgozatlan bit van benne }
VanMegBit2:
  POPF

  RCL   DL,1
  LOOP  BitCik1
EnnyiBit:
  POP   CX

  PUSH  AX
  ADD   BX,DX               ;{ A bazishoz hozzaadom a hasznos bitek erteket }
  MOV   AL,CS:[BX]
  ADD   AL,CS:[Elozo]         ;{ A kulonbseget visszaalakitjuk byte-ra }
  MOV   CS:[Elozo],AL
  STOSB

  POP   AX

  LOOP  UjOutByte
  RET
KIBONT ENDP


_KIBONTAS PROC FAR INDEX:Word,TempBuf:DWord,PCim:DWord

  PUSH   ES
  MOV    AX,[Index]    ; AX = Hanyadik

  LES    DI,[PCim]
  MOV    BX,ES         ; BX:DX = ide bontsuk ki
  MOV    DX,DI         ;

  LES    DI,[TempBuf]  ; ES:DI = atmeneti puffer


  PUSH   DS
  PUSH   BX
  PUSH   DX

  MOV    BX,AX
  ADD    BX,BX
  ADD    BX,AX
  ADD    BX,BX   ; *6
  ADD    BX,Offset StartCimek
  MOV    CX,CS:[BX+4]
  MOV    DX,CS:[BX+0]
  MOV    BX,CS:[BX+2]

  INC    CX
  AND    CX,0FFFEH      ; Mindig paros !!

  JZ     HIBA
  CALL   Csomag_Le
  OR     BL,BL
  JNZ    Hiba
  MOV    CX,ES:[DI]   ; Fmeret
  MOV    AX,ES        ; DS:SI az atmeneti puferre all
  MOV    DS,AX
  MOV    SI,DI
  ADD    SI,4

  POP    DI  ; DX-kent raktam be
  POP    ES  ; BX-kent raktam be

  PUSH   CX
  CALL   KIBONT
  POP    AX
  JMP    KibontasVege

Hiba:
  POP    DI
  POP    ES
  XOR    AX,AX

KibontasVege:
  POP    DS
  POP    ES
  RET
_KIBONTAS ENDP


_LEZAR  PROC FAR
  Call XMS_DeAlloc
  RET
_LEZAR  ENDP

END


