; CDW-hez Hiba string generalo rutin
; TP5-hoz TASM form�tumban

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

DB   "Nem tal�lhat� file : ",00           ; {  1 }
DB   "Nem l�tez� el�r�si �t ",00          ; {  2 }
DB   "File megnyit�si hiba ",00           ; {  3 }
DB   "Nincs el�g mem�ria",00              ; {  4 }
DB   "T�l hossz� defin�ci�",00            ; {  5 }
DB   "Diszk olvas�si hiba ",00            ; {  6 }
DB   "Max. 16 makr� defini�lhat�",00      ; {  7 }
DB   "A sz�veg nem tal�lhat�",00          ; {  8 }
DB   "Karakterk�szlet nem tal�lhat�",00   ; {  9 }
DB   "*** A mem�ria megtelt ***",00       ; { 10 }
DB   "Hi�nyz� printerparam�terek",00      ; { 11 }
DB   "Filen�v ism�tl�s : ",00             ; { 12 }
DB   "Nem megfelel� Makr� file: ",00      ; { 13 }
DB   "Nem megfelel� fejl�cfile: ",00      ; { 14 }
DB   "Diszk nem �zemk�sz: ",00            ; { 15 }
DB   "Ir�sv�dett lemez",00                ; { 16 }
DB   "Nem l�tez� makr� : ",00             ; { 17 }
DB   "Diszk �r�si hiba ",00               ; { 18 }
DB   "A nyomtat� nem �ll k�szen",00       ; { 19 }
DB   " ",00                               ; { 20 }
DB   "Sikertelen �tnevez�s",00            ; { 21 }
DB   "Foglalt filen�v : ",00              ; { 22 }
DB   "Overlay hiba ",00                   ; { 23 }
DB   "Nem megfelel� file : ",00           ; { 24 }
DB   "Azonos file-nevek",00               ; { 25 }
DB   "File m�veleti hiba ",00             ; { 26 }
DB   "Hib�s �tviteli sebess�g: ",00       ; { 27 }
DB   "Nem c�mlistafile: ",00              ; { 28 }
DB   "Hiba a felt�telben: ",00            ; { 29 }
DB   "Ismeretlen video k�rtya !",00       ; { 30 }
DB   "Winchester hiba !",00               ; { 31 }
DB   "Form�zatlan lemez!",00              ; { 32 }
DB   "Lemezkezel�si hiba !",00            ; { 33 }
DB   "Hib�s filen�v : ",00                ; { 34 }
DB   "Kiadv�ny-file hi�nyzik : ",00       ; { 35 }
DB   "�res kiadv�ny : ",00                ; { 36 }
DB   "Kiadv�ny betelt, Kimaradt: ",00     ; { 37 }
DB   "Kiadv�nyba nem j� file : ",00       ; { 38 }
DB   "Nincs megnyitott kiadv�ny !",00     ; { 39 }
DB   "L�zer-font let�lt�si hiba !",00     ; { 40 }
DB   "A file csak olvashat� : ",00        ; { 41 }
DB   "Indexsor elhagy�s t�rt�nt !",00     ; { 42 }
DB   "H�l�zati hiba ",00                                 ; { 43 }
DB   "Nem l�tez� h�l�zati hozz�f�r�si jog !",00          ; { 44 }
DB   "M�r minden h�l�zati hely foglalt !",00             ; { 45 }
DB   "H�l�zati �jrabejelentkez�s !",00                   ; { 46 }
DB   " ",00                                              ; { 47 }
DB   " ",00                                              ; { 48 }
DB   "Supervisori jog sz�ks�ges",00                      ; { 49 }
DB   "Ez NEM az igazi jelsz� : ",00                      ; { 50 }
DB   "T�l hossz� filen�v : ",00                          ; { 51 }
DB   "T�l hossz� kiterjeszt�s : ",00                     ; { 52 }
DB   "Nincs file �s k�nyvt�r a lemezen !",00             ; { 53 }
DB   "Nincs grafikus k�rtya a g�pben !",00               ; { 54 }
DB   "T�l hossz� sorok, lev�gva ",00                     ; { 55 }
; DB   "S�r� nyomtat�s csak GYORS m�dban van",00           ; { 56 }
VEGE:

END
