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

DB    "Search",00               ;{  1 }
DB    "Search and replace",00   ;{  2 }
DB    "Repeat search",00        ;{  3 }
DB    "Del. word",00            ;{  4 }
DB    "Del. line",00            ;{  5 }
DB    "Justify right",00        ;{  6 }
DB    "Line end toggle",00      ;{  7 }
DB    "Mark line block",00      ;{  8 }
DB    "Mark column block",00    ;{  9 }
DB    "Cut marked text",00      ;{ 10 }
DB    "Dupl. marked text",00    ;{ 11 }
DB    "Copy marked text",00     ;{ 12 }
DB    "Del. marked text",00     ;{ 13 }
DB    "Flip case/small",00      ;{ 14 }
DB    "Flip case/capital",00    ;{ 15 }
DB    "Invert case",00          ;{ 16 }
DB    "Paste calc.result",00   ;{ 17 }
DB    "Today's date",00         ;{ 18 }
DB    "Save & exit",00          ;{ 19 }
DB    "Line spacing  1",00      ;{ 20 }
DB    "Line spacing  2",00      ;{ 21 }
DB    "Line spacing  3",00      ;{ 22 }
DB    "Line spacing  4",00      ;{ 23 }
DB    "Line spacing  5",00      ;{ 24 }
DB    "Line spacing  6",00      ;{ 25 }
DB    "Line spacing  7",00      ;{ 26 }
DB    "Line spacing  8",00      ;{ 27 }
DB    "Line spacing  9",00      ;{ 28 }
DB    "Line spacing 10",00      ;{ 29 } DB    "Prev publ. doc.",00      ;{ 30 } DB    "Next publ.doc.",00       ;{ 31 }
DB    "Jump to a page",00       ;{ 30 }
DB    "Paste calc.result",00    ;{ 31 }
DB    "Soft space",00           ;{ 32 Mindig ez legyen a legutols¢ }

VEGE:

END
