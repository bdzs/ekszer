; CDW-hez CTRL_HELP kiiratasa
; TP5-hoz TASM form tumban

.MODEL TPASCAL
.CODE

CTRL_HELP PROC FAR NUM: WORD, STRIN: DWORD

PUBLIC CTRL_HELP

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

CTRL_HELP ENDP

STRINGS:

DB      "Afisare desen",00              ; { 01 }
DB      "Margine drepta",00             ; { 02 }
DB      "Margine stinga",00             ; { 03 }
DB      "Tabulare da/nu",00             ; { 04 }
DB      "Rind index noua",00            ; { 05 }
DB      "Stergere rind index",00        ; { 06 }
DB      "Mod sincron/asincron",00       ; { 07 }
DB      "Egalizare da/nu",00            ; { 08 }
DB      "Despartire da/nu",00           ; { 09 }
DB      "Definire MACRO ",00            ; { 10 }
DB      "Rulare MACRO ",00              ; { 11 }
DB      "Formare paragraf",00           ; { 12 }
DB      "Centrare rind",00              ; { 13 }
DB      "Aliniere la stinga",00         ; { 14 }
DB      "Excludere rind",00             ; { 15 }
DB      "Indicator nr.de pagina",00     ; { 16 }
DB      "Inceput de text",00            ; { 17 }
DB      "Sfirsit de text",00            ; { 18 }
DB      "Rind index in sus",00          ; { 19 }
DB      "Rind index in jos",00          ; { 20 }
DB      "Cu un cuvint in stinga",00     ; { 21 }
DB      "Cu un cuvint in dreapta",00    ; { 22 }
DB      "Incadrare da/nu",00            ; { 23 }
DB      "Alegere dintr-un document",00  ; { 24 }
DB      "Alegere desen",00              ; { 25 }
DB      "Nou cuvint de exceptie",00     ; { 26 }
DB      "Punere/omitere puncte",00      ; { 27  Mindig ez az utols¢ }

VEGE:

END
