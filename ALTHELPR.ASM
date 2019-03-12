; CDW-hez ALT_HELP kiiratasa
; TP5-hoz TASM form tumban

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

DB    "Cauta",00                ;{  1 }
DB    "Cauta si schimba",00     ;{  2 }
DB    "Cauta in cont.",00       ;{  3 }
DB    "Anul. cuvint",00         ;{  4 }
DB    "Anul. rind",00           ;{  5 }
DB    "Aranjare la dreapta",00  ;{  6 }
DB    "Fata rind. bloc",00      ;{  7 }
DB    "Bloc coloana",00         ;{  8 }
DB    "Rezultat calc.",00       ;{  9 }
DB    "Data de azi",00          ;{ 10 }
DB    "Salv. si iese",00        ;{ 11 }
DB    "Copiaza bloc",00         ;{ 12 }
; **************** Innen BlockHelp is ********************
DB    "Anuleaza bloc",00        ;{ 13 }
DB    "Bloc cu lit. mica",00    ;{ 14 } { Ide j”n a helyes¡r sellen“rz‚s }
DB    "Bloc cu lit. mare",00    ;{ 15 }
DB    "Lit mica <-> mare",00    ;{ 16 }
DB    "Rind tare/moale",00      ;{ 17 }
DB    "Taie bloc",00            ;{ 18 }
DB    "Salveaza bloc",00        ;{ 19 }
DB    "Dist. rind nr-1",00      ;{ 20 }
DB    "Dist. rind nr-2",00      ;{ 21 }
DB    "Dist. rind nr-3",00      ;{ 22 }
DB    "Dist. rind nr-4",00      ;{ 23 }
DB    "Dist. rind nr-5",00      ;{ 24 }
DB    "Dist. rind nr-6",00      ;{ 25 }
DB    "Dist. rind nr-7",00      ;{ 26 }
DB    "Dist. rind nr-8",00      ;{ 27 }
DB    "Dist. rind nr-9",00      ;{ 28 }
DB    "Dist. rind nr-10",00     ;{ 29 } ;DB    "Doc de publ.ant",00      ;{ 30 } ;DB    "Doc de publ.urm",00      ;{ 31 }
; **************** Eddig BlockHelp is ********************
DB    "Salt pe o pagina",00     ;{ 30 }
DB    "Rez. calc. cu lit.",00   ;{ 31 }
DB    "Space moale",00          ;{ 32 Mindig ez legyen a legutols¢ }

VEGE:

END
