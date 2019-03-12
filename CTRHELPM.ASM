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

DB      "K‚pet kirajzol",00           ; { 01 }
DB      "Jobb marg¢",00               ; { 02 }
DB      "Bal marg¢",00                ; { 03 }
DB      "Tabul tor ki/be",00          ; { 04 }
DB      "Uj indexsor",00              ; { 05 }
DB      "Indexsort t”r”l",00          ; { 06 }
DB      "Szinkron ki/be",00           ; { 07 }
DB      "Igaz¡t s ki/be",00           ; { 08 }
DB      "Elv laszt s ki/be",00        ; { 09 }
DB      "Makr¢ definici¢",00          ; { 10 }
DB      "Makr¢ lej tsz s",00          ; { 11 }
DB      "Bekezd‚s form z s",00        ; { 12 }
DB      "Sort k”z‚pre tesz",00        ; { 13 }
DB      "Sort balraigaz¡t",00         ; { 14 }
DB      "Sort kiz r",00               ; { 15 }
DB      "Lapsz m jelz”",00            ; { 16 }
DB      "Sz”veg eleje",00             ; { 17 }
DB      "Sz”veg v‚ge",00              ; { 18 }
DB      "Indexsorral fel",00          ; { 19 }
DB      "Indexsorral le",00           ; { 20 }
DB      "Sz¢val balra",00             ; { 21 }
DB      "Sz¢val jobbra",00            ; { 22 }
DB      "Keretez‚s ki/be",00          ; { 23 }
DB      "Kiadv nyb¢l v laszt",00      ; { 24 }
DB      "K‚pet v laszt",00            ; { 25 }
DB      "Uj kiv‚telsz¢",00            ; { 26 }
DB      "Pontoz s ki/be",00           ; { 30  Mindig ez az utols¢ }

VEGE:

END
