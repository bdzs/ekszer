; CDW-hez ALT_HELP kiiratasa
; TP5-hoz TASM form†tumban

.MODEL TPASCAL
.CODE

ALT_HELP PROC FAR NUM: WORD, STRIN: DWORD

PUBLIC ALT_HELP

      PUSH   AX
      PUSH   BX
      PUSH   CX
      PUSH   DX
      PUSH   DI
      PUSH   SI
      PUSH   DS
      PUSH   ES

      PUSH   CS
      POP    ES

      MOV    DI,OFFSET STRINGS

      MOV    AL,00
      MOV    BX,NUM
      DEC    BX

      CLD
      MOV    CX,OFFSET VEGE - OFFSET STRINGS

CIK:  OR     BX,BX
      JZ     KESZ

      REPNZ  SCASB
      JNZ    NINCS

      DEC    BX
      JMP    SHORT CIK

NINCS:LES    DI,STRIN
      XOR    AL,AL
      STOSB
      JMP    SHORT VEG

KESZ: MOV    CX,30
      MOV    SI,DI
      REPNZ  SCASB
      SUB    DI,SI
      MOV    CX,DI

      LES    DI,STRIN
      DEC    CL
      MOV    AL,CL
      STOSB
      PUSH   CS
      POP    DS
      REPZ   MOVSB

VEG:  POP    ES
      POP    DS
      POP    SI
      POP    DI
      POP    DX
      POP    CX
      POP    BX
      POP    AX

      RET

ALT_HELP ENDP

STRINGS:

DB    "Keres",00                ;{  1 }
DB    "Keres Çs cserÇl",00      ;{  2 }
DB    "Tov†bb keres",00         ;{  3 }
DB    "Sz¢t tîrîl",00           ;{  4 }
DB    "Sort tîrîl",00           ;{  5 }
DB    "Jobbraigaz°t",00         ;{  6 }
DB    "Sor blokk eleje",00      ;{  7 }
DB    "Oszlop blokk",00         ;{  8 }
DB    "Kalk. eredmÇny",00       ;{  9 }
DB    "Mai d†tum",00            ;{ 10 }
DB    "Ment Çs kilÇp",00        ;{ 11 }
DB    "Blokkot bem†sol",00      ;{ 12 }
; **************** Innen BlockHelp is ********************
DB    "Blokkot tîrîl",00        ;{ 13 }
DB    "Kisbetñs blokk",00       ;{ 14 } { Ide jîn a helyes°r†sellenìrzÇs }
DB    "Nagybetñs blokk",00      ;{ 15 }
DB    "Kis <-> nagybetÅ",00     ;{ 16 }
DB    "KemÇny/l†gy sor",00      ;{ 17 }
DB    "Blokkot kiv†g",00        ;{ 18 }
DB    "Blokkot elment",00       ;{ 19 }
DB    "Egyes sort†v",00         ;{ 20 }
DB    "Kettes sort†v",00        ;{ 21 }
DB    "H†rmas sort†v",00        ;{ 22 }
DB    "NÇgyes sort†v",00        ;{ 23 }
DB    "îtîs sort†v",00          ;{ 24 }
DB    "Hatos sort†v",00         ;{ 25 }
DB    "Hetes sort†v",00         ;{ 26 }
DB    "Nyolcas sort†v",00       ;{ 27 }
DB    "Kilences sort†v",00      ;{ 28 }
DB    "T°zes sort†v",00         ;{ 29 } ;DB    "Elîzî kiadv.dok",00      ;{ 30 } ;DB    "Kîv. kiadv.dok",00       ;{ 31 }
; **************** Eddig BlockHelp is ********************
DB    "Ugr†s egy oldalra",00    ;{ 30 }
DB    "Kalk.eredm.betÅvel",00   ;{ 31 }
DB    "L†gy space",00           ;{ 32 Mindig ez legyen a legutols¢ }

VEGE:

END
