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

DB      "Tegner bildet ",00           ; { 01 }
DB      "H›yre marg",00               ; { 02 }
DB      "Venstre marg",00             ; { 03 }
DB      "Tabulator av/p†",00          ; { 04 }
DB      "Ny indekslinje",00           ; { 05 }
DB      "Sletter indekslinje",00      ; { 06 }
DB      "Synkron  av/p†",00           ; { 07 }
DB      "Rette    av/p†",00           ; { 08 }
DB      "Ord-deling  av/p†",00        ; { 09 }
DB      "Makro-definisjon",00         ; { 10 }
DB      "Makro-avspill",00            ; { 11 }
DB      "Dokument start",00           ; { 12 }
DB      "Sentrert tekst",00           ; { 13 }
DB      "Venstrejustert",00           ; { 14 }
DB      "H›yre/venstre justert",00    ; { 15 }
DB      "Fast sideskift.",00          ; { 16 }
DB      "Tekst-start ",00             ; { 17 }
DB      "Tekst-slutt",00              ; { 18 }
DB      "Forrige Indekslin",00      ; { 19 }
DB      "Neste Indekslinje",00        ; { 20 }
DB      "Ord til venstre",00          ; { 21 }
DB      "Ord til h›yre",00            ; { 22 }
DB      "Ramme av/p†",00              ; { 23 }
DB      "Utklippsvalg",00             ; { 24 }
DB      "Bildevalg",00                ; { 25 }
DB      "Nytt unntaksord",00          ; { 26 }
DB      "Punkter av/p†",00            ; { 27  Mindig ez az utols¢ }

VEGE:

END

