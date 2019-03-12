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

DB    "Finner ikke filen  : ",00  ;        {  1 }
DB    "Ukjent s›kevei",00  ;               {  2 }
DB    "Feil med fil†pning",00  ;           {  3 }
DB    "For lite minne ",00  ;              {  4 }
DB    "For lang definisjon ",00  ;         {  5 }
DB    "Lesefeil p† disk ",00  ;            {  6 }
DB    "Max. 16 makroer kan def.",00  ;     {  7 }
DB    "Finner ikke teksten",00  ;          {  8 }
DB    "Tegnsettfilen finnes ikke ",00  ;   {  9 }
DB    "*** Minnet er fullt   ***",00  ;    { 10 }
DB    "Mangler skriverparametere ",00  ;   { 11 }
DB    "Filen finnes allerede!!  : ",00  ;  { 12 }
DB    "Feil makrofil : ",00  ;             { 13 }
DB    "Feil topptekstfil : ",00  ;         { 14 }
DB    "Diskettstasjon ikke klar : ",00  ;  { 15 }
DB    "Diskett er skrivebeskyttet",00  ;   { 16 }
DB    "Finner ikke makro: ",00  ;          { 17 }
DB    "Disk skrivefeil ",00  ;             { 18 }
DB    "Skriveren er ikke klar ",00  ;      { 19 }
DB    "Sorteringsfeil : ",00  ;            { 20 }
DB    "Ukorrekt filnavn    ",00  ;         { 21 }
DB    "Reservert filnavn:",00  ;           { 22 }
DB    "Finner ikke makro",00  ;            { 23 }
DB    "Feil fil : ",00  ;                  { 24 }
DB    "Samme filnavn ",00  ;               { 25 }
DB    "Filbehandlingsfeil",00  ;           { 26 }

DB    "Ulovlig filnavn  : ",00             ; { 27 }
DB    "Manglende struktur",00              ; { 28 }
DB    "Feil i betingelse  : ",00           ; { 29 }
DB    "Postnr. utenfor omr†det ",00        ; { 30 }
DB    "Ikke funnet : ",00                  ; { 31 }
DB    "IKKE Casio fil !",00                ; { 32 }
DB    "Identiske filnavn :",00             ; { 33 }
DB    "Fletting umulig : ",00              ; { 34 }
DB    "Ingen filer/katalog p† disken",00   ; { 35 }

VEGE:

END
