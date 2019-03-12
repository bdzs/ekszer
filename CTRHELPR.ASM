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

DB      "Deseneaza imagine",00        ; { 01 }
DB      "Marg. dreapta",00            ; { 02 }
DB      "Marg. stinga",00             ; { 03 }
DB      "Tabulator in/af",00          ; { 04 }
DB      "Rind index nou",00           ; { 05 }
DB      "Anul. rind index",00         ; { 06 }
DB      "Sincron in/af",00            ; { 07 }
DB      "Aranjare in/af",00           ; { 08 }
DB      "Impartire in/af",00          ; { 09 }
DB      "Definitie macro",00          ; { 10 }
DB      "Alergare macro",00           ; { 11 }
DB      "Formare paragraf",00         ; { 12 }
DB      "Pune rind la mij.",00        ; { 13 }
DB      "Aranj. rind la st.",00       ; { 14 }
DB      "Inchide rind",00             ; { 15 }
DB      "Semnal pagina",00            ; { 16 }
DB      "Incep. textului",00          ; { 17 }
DB      "Sfirs. textului",00          ; { 18 }
DB      "Sus cu rind index",00        ; { 19 }
DB      "Jos cu rind index",00        ; { 20 }
DB      "Cuvint la st.",00            ; { 21 }
DB      "Cuvint la dr.",00            ; { 22 }
DB      "Ramare in/af",00             ; { 23 }
DB      "Alege din publicatie",00     ; { 24 }
DB      "Alege imagine",00            ; { 25 }
DB      "Cuv. exceptie nou",00        ; { 26 }
DB      "Punctare in/af",00           ; { 30  Mindig ez az utols¢ }

VEGE:

END
