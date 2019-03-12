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

DB   "Nenachadzam subor: ",00         ; {  1 }
DB   "Neexistujuca cesta",00          ; {  2 }
DB   "Chyba nacitania",00             ; {  3 }
DB   "Nedostatok pamate",00           ; {  4 }
DB   "Dlha definicia",00              ; {  5 }
DB   "Chyba nacitania disku",00       ; {  6 }
DB   "Max. 16 makrier definovat",00   ; {  7 }
DB   "Nenachadzam text",00            ; {  8 }
DB   "Nenachadzam znakovu sadu",00    ; {  9 }
DB   "*** Naplnena pamat ***",00      ; { 10 }
DB   "Chybaju parametre tlaciarne",00 ; { 11 }
DB   "Opakovanie nazvu: ",00          ; { 12 }
DB   "Nevhodny makro subor: ",00      ; { 13 }
DB   "Nevhodny subor h.zahlavia: ",00 ; { 14 }
DB   "Nepripraveny disk: ",00         ; { 15 }
DB   "Chraneny disk",00               ; { 16 }
DB   "Neexistujuce makro: ",00        ; { 17 }
DB   "Chyba zapisu disku",00          ; { 18 }
DB   "Tlaciaren OFF LINE",00          ; { 19 }
DB   " ",00                           ; { 20 }
DB   "Neuspesne premenovanie",00      ; { 21 }
DB   "Obsadene meno : ",00            ; { 22 }
DB   "Overlay chyba ",00              ; { 23 }
DB   "Nevhodny subor : ",00           ; { 24 }
DB   "Rovnake mena suborov",00        ; { 25 }
DB   "Operacna chyba",00              ; { 26 }
DB   "Zla prenosov  rychlost: ",00    ; { 27 }
DB   "Nie st¡tkovy subor : ",00       ; { 28 }
DB   "Chyba v podmienke : ",00        ; { 29 }
DB   "Neznama video karta !",00       ; { 30 }
DB   "Winchester chyba !",00          ; { 31 }
DB   "Neformatovan  disketa !",00     ; { 32 }
DB   "Chyba - floppy !",00            ; { 33 }
DB   "Chyba - meno : ",00             ; { 34 }
DB   "Neexistuje publikacny s£bor: ",0; { 35 }
DB   "Pr zny publikacny s£bor : ",00  ; { 36 }
DB   "Publikacia zaplnen , nenacitan‚: ",00 ; { 37 }
DB   "Nevhodny s£bor do publik cie : ",00   ; { 38 }
DB   "Neotvoreny pulikacny s£bor !",00      ; { 39 }
DB   "Laser-font download chyba !",00       ; { 40 }
DB   "Subor len citatelny: ",00             ; { 41 }
DB   "Nenacitan‚ indexov‚ riadky",00        ; { 42 lenne }
DB   "Chyba siete Novell !",00              ; { 43 }
DB   "Neexistujuci pristup do siete !",00   ; { 44 }
DB   "Siet celkom obsadena !",00            ; { 45 }
DB   "Znovu nahlasenie do siete !",00       ; { 46 }
DB   " ",00  			            ; { 47 }
DB   " ",00                                 ; { 48 }
DB   "Supervisor pravo nutne !",00          ; { 49 }
DB   "Nespravne heslo: ",00                 ; { 50 }
DB   "Dlhe meno suboru: ",00                ; { 51 }
DB   "Dlhe rozsirenie: ",00                 ; { 52 }
DB   "Nincs file ‚s k”nyvt r a lemezen !",00; { 53 }
DB   "Nincs grafikus k rtya a g‚pben !",00  ; { 54 }
DB   "T£l hossz£ sorok, lev gva ",00        ; { 55 }

VEGE:

END
