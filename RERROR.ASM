; CIMLIST-hez Hiba string generalo rutin
; TP5-hoz TASM form tumban

.MODEL TPASCAL
.CODE

ERRORSTR PROC FAR NUM: WORD, STRIN: DWORD

PUBLIC ERRORSTR

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

ERRORSTR ENDP

STRINGS:

DB   "Fisier inexistent : ",00            ; {  1 }
DB   "Cale de acces inexistenta",00       ; {  2 }
DB   "Eroare deschidere fisier",00        ; {  3 }
DB   "Memorie insuficienta",00            ; {  4 }
DB   "Definitie prea lunga",00            ; {  5 }
DB   "Eroare la citire disc",00           ; {  6 }
DB   "Se pot defini max.16 MACRO-uri",00  ; {  7 }
DB   "Text inexistent",00                 ; {  8 }
DB   "Fisier de caractere inexistent",00  ; {  9 }
DB   "*** Memoria s-a umplut ***",00      ; { 10 }
DB   "Lipsesc parametrii pt. imprimanta",00      ; { 11 }
DB   "Nume de fisier existent: ",00              ; { 12 }
DB   "Fisier MACRO necorespunzator: ",00         ; { 13 }
DB   "Fisier antet necorespunzator: ",00         ; { 14 }
DB   "Discul nu e pregatit: ",00          ; { 15 }
DB   "Protejat la scriere",00             ; { 16 }
DB   "Fisier MACRO inexistent: ",00       ; { 17 }
DB   "Eroare la scriere pe disc",00       ; { 18 }
DB   "Imprimanta inactiva",00             ; { 19 }
DB   "Eroare de ordonare : ",00           ; { 20 }
DB   "Redenumire nereusita",00            ; { 21 }
DB   "Nume de fisier rezervat: ",00       ; { 22 }
DB   "Fisier MACRO inexistent !",00       ; { 23 }
DB   "Fisier necorespunzator: ",00        ; { 24 }
DB   "Nume de fisiere identice",00        ; { 25 }
DB   "Eroare de operatii cu fisiere",00   ; { 26 }
DB   "Nume de fisier eronat: ",00         ; { 27 }
DB   "Structura inexistentat",00          ; { 28 }
DB   "Eroare in conditie: ",00            ; { 29 }
DB   "Nr. de ordine eronat !",00          ; { 30 }
DB   "N-am gasit : ",00                   ; { 31 }
DB   "Extensie .BAK interzisa",00         ; { 32 }

VEGE:

END
