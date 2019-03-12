; CDW-hez Hiba string generalo rutin
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

KESZ: MOV    CX,50
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

DB   "Fisier inexistent : ",00               ; {  1 }
DB   "Cale de acces inexistent ",00          ; {  2 }
DB   "Eroare de deschidere fisier ",00       ; {  3 }
DB   "Memorie insuficient†",00               ; {  4 }
DB   "Definitie prea lung†",00               ; {  5 }
DB   "Eroare de citire disc ",00             ; {  6 }
DB   "Se pot defini max.16 MACRO-uri",00     ; {  7 }
DB   "Text inexistent",00                    ; {  8 }
DB   "Set de caractere inexistent†",00       ; {  9 }
DB   "*** Memoria s-a umplut ***",00         ; { 10 }
DB   "Parametrii de imprimant† absente",00   ; { 11 }
DB   "Repetitie de nume de fisier : ",00     ; { 12 }
DB   "MACRO necorespunz†tor: ",00            ; { 13 }
DB   "Fisier de antet necorespunz†tor: ",00  ; { 14 }
DB   "Discul nu e preg†tit: ",00             ; { 15 }
DB   "Disc protejat la scriere",00           ; { 16 }
DB   "MACRO  inexistent : ",00               ; { 17 }
DB   "Eroare la scriere pe disc",00          ; { 18 }
DB   "Imprimanta inactiv†",00                ; { 19 }
DB   " ",00                                  ; { 20 }
DB   "Redenumire nereusit†",00                ; { 21 }
DB   "Nume de fisier rezervat: ",00           ; { 22 }
DB   "Eroare Overlay ",00                     ; { 23 }
DB   "Fisier necorespunz†tor : ",00           ; { 24 }
DB   "Nume de fisiere identice",00            ; { 25 }
DB   "Eroare de operatii cu fisire ",00       ; { 26 }
DB   "Viteza de transmisie eronata ",00       ; { 27 }
DB   "Nu este fisier de lista de adr: ",00    ; { 28 }
DB   "Eroare Œn conditie ",00                 ; { 29 }
DB   "Placa video necunoscut† !",00           ; { 30 }
DB   "Eroare de Winchester  !",00             ; { 31 }
DB   "Disc neformatat !",00                   ; { 32 }
DB   "Eroare de operatie cu discul !",00      ; { 33 }
DB   "Nume de fisier eronat : ",00            ; { 34 }
DB   "Fisierul de publicatie lipseste: ",00   ; { 35 }
DB   "Publicatie goal† : ",00                 ; { 36 }
DB   "Publicatie umplut†, S-a omis:",00       ; { 37 }
DB   "Fisier necorespunz†tor in pub: ",00     ; { 38 }
DB   "Nu exist† publicatie deschis† !",00     ; { 39 }
DB   "Eroare de inc†rcare font-laser !",00    ; { 40 }
DB   "Fisier accesibil numai la citire : ",00            ; { 41 }
DB   "S-a omis rŒnd index!",00                           ; { 42 }
DB   "Eroare de reteau† !",00                            ; { 43 }
DB   "Nu exist† drept de acces la retea !",00            ; { 44 }
DB   "Toate posturile Œn retea sŒnt ocupate !",00        ; { 45 }
DB   "Reintrare Œn retea !",00                           ; { 46 }
DB   " ",00  						 ; { 47 }
DB   " ",00           					 ; { 48 }
DB   "Este necesar drept de supervizare",00              ; { 49 }
DB   "NU este parola adev†rat†: ",00                     ; { 50 }
DB   "Nume de fisier prea lung: ",00                     ; { 51 }
DB   "Extensie prea lung† : ",00                         ; { 52 }
DB   "Nu este fisier si bibliotec† pe disc !",00         ; { 53 }
DB   "Nu este plac† grafic† Œn aparat !",00              ; { 54 }
DB   "RŒnduri prea lungi,t†iate ",00                     ; { 55 }
DB   "Imprimare des† nu este numai Œn mod rapid",00      ; { 56 }
VEGE:

END

