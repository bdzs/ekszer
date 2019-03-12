; CDW-hez Menu textek kiiratasa
; TP5-hoz TASM form tumban
; normal magyar

.MODEL TPASCAL
.CODE

MENUSTR PROC FAR NUM: WORD, STRIN: DWORD, IRANY: BYTE

PUBLIC MENUSTR

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

      ; feluliras v kiolvasas?
      CMP    IRANY,0             ; FALSE = NINCS
      JE     STRINGET_FELTOLT
      MOV    AL,ES:[DI]          ; AL = ATVEENDO STRING HOSSZ
      CMP    AL,CL               ; CL = EBBE IRJA
      JA     CL_KISEBB
      MOV    CL,AL

    CL_KISEBB:
      INC    DI
      PUSH   CS
      POP    DS
      XCHG   SI,DI

      PUSH   DS
      PUSH   ES
      POP    DS
      POP    ES

      JMP SHORT PAKOL

 STRINGET_FELTOLT:
      DEC    CL
      MOV    AL,CL
      STOSB
      PUSH   CS
      POP    DS

 PAKOL:
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

MENUSTR ENDP

STRINGS:
DB    "Edit cia"      ,00                ;   {1. Main Menu }
DB    "Mazanie"       ,00
DB    "Nac¡tanie"     ,00
DB    "Ulozenie"      ,00
DB    "Zmena"         ,00
DB    "Tlac"          ,00
DB    "S£bor"         ,00
DB    "Koniec"        ,00
;*******************************************************************
DB    "Dokument"      ,00                ;   {2. Edit}
DB    "Buffer"        ,00
DB    "H.z hlavie"    ,00
DB    "D.z hlavie "   ,00
;*******************************************************************
DB    "Dokument"      ,00                ;   {3. Delete}
DB    "Buffer"        ,00
DB    "H.z hlavie"    ,00
DB    "D.z hlavie"    ,00
;*******************************************************************
DB    "Dokument"      ,00                ;   {4. Load}
DB    "Blok buffer"   ,00
DB    "Parameter"     ,00
DB    "ASCII s£bor"   ,00
DB    "WordStar s£bor",00
DB    "H.z hl-D.z hl" ,00
DB    "Makro s£bor"   ,00
;*******************************************************************
DB    "Dokument"      ,00                ;   {5. Save}
DB    "Blok buffer"   ,00
DB    "Konfigur cia"  ,00
DB    "Parameter"     ,00
DB    "ASCII s£bor"   ,00
DB    "Ventura s£bor" ,00
DB    "H.z hl-D.z hl ",00
DB    "Makr "         ,00
;*******************************************************************
DB    "Prac. adres r" ,00               ;   {6. Change}
DB    "Znakov  sada"  ,00
DB    "Parametre"     ,00
DB    "ProTex adres r",00
DB    "Rozs¡renie:   ",00
DB    "Editor:       ",00
DB    "Typ:          ",00
DB    "Display: Color",00
;*******************************************************************
DB    "Rychl"         ,00               ;   {7. Print}
DB    "Norm l"        ,00
DB    "Dopisov "      ,00
DB    "P¡sacy stroj"  ,00
DB    "Opcie"         ,00
DB    "Preview"       ,00
DB    "Obezn¡ky"      ,00
;*******************************************************************
DB    "Directory"     ,00               ;   {8. File}
DB    "Erase"         ,00
DB    "Rename"        ,00
DB    "Copy"          ,00
;*******************************************************************
DB    "Dlzka str n      170"      ,00   ;   {9. Change Parameters}
DB    "Riadkovanie       50"      ,00
DB    "Doba ulozenia   9999"      ,00
DB    "Pocet impulzov  1000"      ,00
DB    "P¡saci stroj        "      ,00
DB    "Tlaciaren           "      ,00
;*******************************************************************
DB    "Prv  strana        1"      ,00   ;   {10. Print Options}
DB    "Posledn  strana 9999"      ,00
DB    "Cislovat od        1"      ,00
DB    "Pausa            Zap"      ,00
DB    "Lavy okraj         6"      ,00
DB    "Kopie              1"      ,00
DB    "Eject            Zap"      ,00
DB    "Vzdial.st¡tkov  1.11"      ,00
DB    "Seriov  linka   COM1"      ,00
DB    "Paraleln  linka LPT1"      ,00
DB    "Casovanie         10"      ,00
;*******************************************************************
DB    "Vsetky"                    ,00   ;   {11. Edit headers   }
DB    "P rne"                     ,00
DB    "Nep rne"                   ,00
DB    " 1"                        ,00
DB    " 2"                        ,00
DB    " 3"                        ,00
DB    " 4"                        ,00
DB    " 5"                        ,00
DB    " 6"                        ,00
DB    " 7"                        ,00
DB    " 8"                        ,00
DB    " 9"                        ,00
;*******************************************************************
DB    "Vsetky"                    ,00   ;   {12. Edit footers   }
DB    "P rne"                     ,00
DB    "Nep rne"                   ,00
DB    " 1"                        ,00
DB    " 2"                        ,00
DB    " 3"                        ,00
DB    " 4"                        ,00
DB    " 5"                        ,00
DB    " 6"                        ,00
DB    " 7"                        ,00
DB    " 8"                        ,00
DB    " 9"                        ,00
;*******************************************************************
DB    "Vsetky"                    ,00   ;   {13. Delete headers }
DB    "P rne"                     ,00
DB    "Nep rne"                   ,00
DB    " 1"                        ,00
DB    " 2"                        ,00
DB    " 3"                        ,00
DB    " 4"                        ,00
DB    " 5"                        ,00
DB    " 6"                        ,00
DB    " 7"                        ,00
DB    " 8"                        ,00
DB    " 9"                        ,00
;*******************************************************************
DB    "Vsetky"                    ,00   ;   {14. Delete footers }
DB    "P rne"                     ,00
DB    "Nep rne"                   ,00
DB    " 1"                        ,00
DB    " 2"                        ,00
DB    " 3"                        ,00
DB    " 4"                        ,00
DB    " 5"                        ,00
DB    " 6"                        ,00
DB    " 7"                        ,00
DB    " 8"                        ,00
DB    " 9"                        ,00
;*******************************************************************
DB    "Databanka:    Nie je"      ,00   ;   {15. K”rlevelez‚s }
DB    "Z znam              "      ,00
DB    "Podmienky vyberu    "      ,00
DB    "Naplnenie podmienok "      ,00
DB    "Ulozenie            "      ,00

VEGE:

END
