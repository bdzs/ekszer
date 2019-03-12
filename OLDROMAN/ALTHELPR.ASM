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
DB    "Cauta in continuare",00  ;{  3 }
DB    "Sterge cuvint",00        ;{  4 }
DB    "Sterge rind",00          ;{  5 }
DB    "Aliniere la dreapta",00  ;{  6 }
DB    "Sfirsit rind/paragraf",00;{  7 }
DB    "Inceput bloc linie",00   ;{  8 }
DB    "Bloc coloana",00         ;{  9 }
DB    "Decupare bloc",00        ;{ 10 }
DB    "Salvare bloc",00         ;{ 11 }
DB    "Copiere bloc",00         ;{ 12 }
DB    "Stergere bloc",00        ;{ 13 }
DB    "Bloc cu litere mici",00  ;{ 14 }
DB    "Bloc cu litere mari",00  ;{ 15 }
DB    "Litere mici <-> mari",00 ;{ 16 }
DB    "Rezultat calcul",00      ;{ 17 }
DB    "Data curenta",00         ;{ 18 }
DB    "Salvare si iesire",00    ;{ 19 }
DB    "Spatiere la un rind",00  ;{ 20 }
DB    "Spatiere la doua rinduri",00        ;{ 21 }
DB    "Spatiere la trei rinduri",00        ;{ 22 }
DB    "Spatiere la patru rinduri",00       ;{ 23 }
DB    "Spatiere la cinci rinduri",00       ;{ 24 }
DB    "Spatiere la sase rinduri",00        ;{ 25 }
DB    "Spatiere la sapte rinduri",00       ;{ 26 }
DB    "Spatiere la opt rinduri",00         ;{ 27 }
DB    "Spatiere la noua rinduri",00        ;{ 28 }
DB    "Spatiere la zece rinduri",00        ;{ 29 }
DB    "Precedenta edit.doc",00             ;{ 30 }
DB    "Urmatoarea edit.doc",00             ;{ 31 }
DB    "Spatiu flexibil",0           ;{ 32   Mindig ez legyen a legutols¢ }

VEGE:

END
