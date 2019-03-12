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

DB   "Fisier inexistent : ",00            ; {  1 }
DB   "Cale de acces inexistenta ",00      ; {  2 }
DB   "Eroare de deschidere fisier ",00    ; {  3 }
DB   "Memorie insuficienta",00            ; {  4 }
DB   "Definitie prea lunga",00            ; {  5 }
DB   "Eroare de citire disc ",00          ; {  6 }
DB   "Se pot defini max.16 MACRO-uri",00  ; {  7 }
DB   "Text inexistent",00                 ; {  8 }
DB   "Fisier de caractere inexistent",00  ; {  9 }
DB   "*** Memoria s-a umplut ***",00      ; { 10 }
DB   "Lipsesc parametrii pt.imprimanta",00; { 11 }
DB   "Nume de fisier existent : ",00      ; { 12 }
DB   "MACRO necorespunzator: ",00         ; { 13 }
DB   "Fisier antet necorespunzator: ",00  ; { 14 }
DB   "Discul nu e pregatit: ",00          ; { 15 }
DB   "Protejat la scriere",00             ; { 16 }
DB   "MACRO  inexistent : ",00            ; { 17 }
DB   "Eroare la scriere pe disc",00       ; { 18 }
DB   "Imprimanta inactiva",00             ; { 19 }
DB   " ",00                               ; { 20 }
DB   "Redenumire nereusita",00            ; { 21 }
DB   "Nume de fiser rezervat: ",00        ; { 22 }
DB   "Eroare Overlay ",00                 ; { 23 }
DB   "Fisier necorespunzator : ",00       ; { 24 }
DB   "Nume de fisiere identice",00        ; { 25 }
DB   "Eroare de operatii cu fisire ",00   ; { 26 }
DB   "Rata de transmisie eronata ",00     ; { 27 }
DB   "Nu este fisier listadr: ",00        ; { 28 }
DB   "Eroare la conditie ",00             ; { 29 }
DB   "Placa video necunoscuta !",00       ; { 30 }
DB   "Eroare de Winchester  !",00         ; { 31 }
DB   "Disc neformatat !",00               ; { 32 }
DB   "Eroare de lucru cu discul !",00     ; { 33 }
DB   "Nume de fisier eronat : ",00        ; { 34 }
DB   "Lipsa fisier publicatie : ",00      ; { 35 }
DB   "Publicatie vida : ",00              ; { 36 }
DB   "Publicatie completa, S-a omis:",00  ; { 37 }
DB   "Fisier necorespunzator in pub: ",00 ; { 38 }
DB   "Nu exista publicatie deschisa !",00 ; { 39 }
DB   "Eroare de incarcare font-laser !",00; { 40 }
DB   "Fisier accesibil numai la citire : ",00            ;{ 41 }
DB   "S-a omis rind index!",00                           ; { 42 }
DB   "Eroare la reteaua Novell !",00                     ; { 43 }
DB   "Drept de acces la retea inexistent !",00           ; { 44 }
DB   "Toate posturile in retea sint ocupate !",00        ; { 45 }
DB   "Reintrare in retea !",00                           ; { 46 }
DB   " ",00  						 ; { 47 }
DB   " ",00           					 ; { 48 }
DB   "Necesita drept de supervizare",00                  ; { 49 }
DB   "Parola eronata: ",00                               ; { 50 }
DB   "Nume de fisier prea lung: ",00                     ; { 51 }
DB   "Extensie prea lunga : ",00                         ; { 52 }
DB   "Nincs file ‚s k”nyvt r a lemezen !",00             ; { 53 }
DB   "Nincs grafikus k rtya a g‚pben !",00               ; { 54 }
DB   "T£l hossz£ sorok, lev gva ",00                     ; { 55 }

VEGE:

END
