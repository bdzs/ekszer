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

DB      "Preview picture",00          ; { 01 }
DB      "Right margin",00             ; { 02 }
DB      "Left margin",00              ; { 03 }
DB      "Tabulators ON/OFF",00        ; { 04 }
DB      "New indexline",00            ; { 05 }
DB      "Del. indexline",00           ; { 06 }
DB      "Sync. ON/OFF",00             ; { 07 }
DB      "Justify ON/OFF",00           ; { 08 }
DB      "Hyphenat. ON/OFF",00         ; { 09 }
DB      "Def. macro",00               ; { 10 }
DB      "Play macro",00               ; { 11 }
DB      "Format paragraph",00         ; { 12 }
DB      "Line center",00              ; { 13 }
DB      "Justify left",00             ; { 14 }
DB      "Justify both",00             ; { 15 }
DB      "Page numbering",00           ; { 16 }
DB      "Beginning of text",00        ; { 17 }
DB      "End of text",00              ; { 18 }
DB      "Indexline up",00             ; { 19 }
DB      "Indexline down",00           ; { 20 }
DB      "Word left",00                ; { 21 }
DB      "Word right",00               ; { 22 }
DB      "Frame ON/OFF",00             ; { 23 }
DB      "Choose a document",00        ; { 24 }
DB      "Choose a pic.file",00        ; { 25 }
DB      "New word to dict.",00        ; { 26 }
DB      "Show/hide spaces",00         ; { 30 Mindig ez az utols¢ }

VEGE:

END
