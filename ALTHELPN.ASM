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

KESZ: MOV    CX,31
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

DB    "Sõker",00                ;{  1 }
DB    "Sõker og bytter",00      ;{  2 }
DB    "Gjenta sõk",00         ;{  3 }
DB    "Sletter ord",00          ;{  4 }
DB    "Sletter linje",00        ;{  5 }
DB    "Hõyrejuster ",00         ;{  6 }
DB    "Hard/myk linje ",00      ;{  7 }
DB    "Linjebuffer start",00    ;{  8 }
DB    "Kolonnebuffer start",00         ;{  9 }
DB    "Utklippbuffer",00        ;{ 10 }
DB    "Elementbuffer ",00       ;{ 11 }
DB    "Kopier buffer  ",00      ;{ 12 }
; **************** Innen BlockHelp is ********************
DB    "Slette buffer",00        ;{ 13 }
DB    "SmÜ-bokstav buffer",00   ;{ 14 }
DB    "Stor-bokstav buffer",00  ;{ 15 }
DB    "SmÜ <-> stor bokstav",00 ;{ 16 }
DB    "Kalk. resultat",00       ;{ 17 }
DB    "Dagens dato",00          ;{ 18 }
DB    "Lagre og avslutt",00     ;{ 19 }
DB    "Enkel linjeavstand",00   ;{ 20 }
DB    "Dobbel linjeavstand",00  ;{ 21 }
DB    "Tredobbel linjeavstand",00;{22 }
DB    "Firedobbel linjeavst.",00;{ 23 }
DB    "Femdobbel linjeavst.",00 ;{ 24 }
DB    "Seksdobbel linjeavst.",00;{ 25 }
DB    "Syvdobbel linjeavst.",00 ;{ 26 }
DB    "èttedobbel linjeavst.",00;{ 27 }
DB    "Nidobbel linjeavst.",00  ;{ 28 }
DB    "Tidobbel linjeavst.",00  ;{ 29 }
; **************** Eddig BlockHelp is ********************
DB    "Velg side",00           ;{ 30 }
DB    "Kalk.summ/bokstav",00   ;{ 31 }
DB    "Myk mellomrom",00       ;{ 32 Mindig ez legyen a legutols¢ }

VEGE:

END
