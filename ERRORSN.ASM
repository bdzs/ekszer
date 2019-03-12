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

DB   "Finner ikke filen  : ",00           ; {  1 }
DB   "Ingen assosiasjon for denne fil ",00; {  2 }
DB   "Feil ved †pning av filen",00        ; {  3 }
DB   "For lite minne    ",00              ; {  4 }
DB   "For lang definisjon ",00            ; {  5 }
DB   "Kan ikke lese fra disk",00          ; {  6 }
DB   "Maks 16 makroer kan defineres",00   ; {  7 }
DB   "Finner ikke teksten   ",00          ; {  8 }
DB   "Finner ikke tegnsettfil     ",00    ; {  9 }
DB   "***  Minnet er fullt  ***",00       ; { 10 }
DB   "Mangler skriverparametere ",00      ; { 11 }
DB   "Overskrive eksisterende fil:",00    ; { 12 }
DB   "Feil makro-fil          : ",00      ; { 13 }
DB   "Feil topptekst-fil      : ",00      ; { 14 }
DB   "Disken er ikke klar:",00            ; { 15 }
DB   "Skrivebeskyttet diskett",00         ; { 16 }
DB   "Denne makroen eksisterer ikke:",00  ; { 17 }
DB   "Feil ved skriving til disk",00      ; { 18 }
DB   "Skriveren er ikke klar",00          ; { 19 }
DB   " ",00                               ; { 20 }
DB   "Ukjent filnavn",00                  ; { 21 }
DB   "Reservert filnavn:",00              ; { 22 }
DB   "Overlay feil ",00                   ; { 23 }
DB   "Feil fil: ",00                      ; { 24 }
DB   "Filnavn finnes fra f›r",00          ; { 25 }
DB   "Feil ved filh†ndteringen",00        ; { 26 }
DB   "Feil overf›ringshastighet",00       ; { 27 }
DB   "Ikke adresseliste-fil:",00          ; { 28 }
DB   "Feil med parameter: ",00            ; { 29 }
DB   "Ukjent video-kort !",00             ; { 30 }
DB   "Harddiskfeil !",00                  ; { 31 }
DB   "Uformatert eller feil diskett",00   ; { 32 }
DB   "Diskett-h†nteringsfeil !",00        ; { 33 }
DB   "Feil filnavn: ",00                  ; { 34 }
DB   "Mangler............... : ",00       ; { 35 }
DB   "Tomt......... : ",00                ; { 36 }
DB   "Mangler eller full.......: ",00     ; { 37 }
DB   "Filen passer ikke i....: ",00       ; { 38 }
DB   "Mangler †pen............. !",00     ; { 39 }
DB   "Feil ved laserfont-henting!",00     ; { 40 }
DB   "Filen er kun lesbar: ",00           ; { 41 }
DB   "Indekslinje mistet !",00            ; { 42 }
DB   "Novell nettverksfeil !",00                         ; { 43 }
DB   "Ugyldig nettverkslisens-tilkopling !",00           ; { 44 }
DB   "Alle nettverkslisenser er opptatt !",00            ; { 45 }
DB   "Ny nettverkslisens-tilkopling",00                  ; { 46 }
DB   " ",00                                              ; { 47 }
DB   " ",00                                              ; { 48 }
DB   "Supervisor-adgang kreves !",00                     ; { 49 }
DB   "Ikke riktig passord: ",00                          ; { 50 }
DB   "For lang filnavn: ",00                             ; { 51 }
DB   "For lang parameter: ",00                           ; { 52 }
DB   "Ingen fil eller katalog p† denne disken !",00      ; { 53 }
DB   "Finner ikke grafikk-kort p† maskinen !",00         ; { 54 }
DB   "For lange linjer, er avkortet ",00                 ; { 55 }

VEGE:

END
