; CDW-hez Menu textek kiiratasa
; TP5-hoz TASM form�tumban
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
DB    "Szerkeszt"           ,00           ;{1. Main Menu }
DB    "T�r�l"               ,00
DB    "Bet�lt"              ,00
DB    "Ment"                ,00
DB    "Kiadv�ny"            ,00
DB    "Csere"               ,00
DB    "Nyomtat"             ,00
DB    "File"                ,00
DB    "V�ge"                ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{2. Edit}
DB    "Puffer"              ,00
DB    "Fejl�c"              ,00
DB    "L�br�sz"             ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{3. Delete}
DB    "Puffer"              ,00
DB    "Fejl�c"              ,00
DB    "L�br�sz"             ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{4. Load}
DB    "Blokk puffer"        ,00
DB    "Param�ter"           ,00
DB    "ASCII file"          ,00
DB    "WordStar file"       ,00
DB    "Fejl�c / L�br�sz"    ,00
DB    "Makr� file"          ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{5. Save}
DB    "Blokk puffer"        ,00
DB    "Konfigur�ci�"        ,00
DB    "Param�ter"           ,00
DB    "ASCII file"          ,00
DB    "Ventura file"        ,00
DB    "Fejl�c / L�br�sz"    ,00
DB    "Makr�k"              ,00
;***********************************************************************
DB    "L�trehoz�s"          ,00           ;{6. Publik�ci� }
DB    "Megnyit�s"           ,00
DB    "T�rl�s kiadv�nyb�l"  ,00
DB    "Kiadv�ny b�v�t�se"   ,00
DB    "Filesorrend v�lt�s"  ,00
DB    "Lez�r�s"             ,00
DB    "Nyomtat�si opc."     ,00
;***********************************************************************
DB    "Munka k�nyvt�r  "    ,00           ;{7. Change}
DB    "Karakterk�szlet "    ,00
DB    "Param�terek     "    ,00
DB    "�kSzer k�nyvt�r "    ,00
DB    "File maszk:     "    ,00
DB    "Editor:         "    ,00
DB    "T�pus:          "    ,00
DB    "Display:  Szines"    ,00
;***********************************************************************
DB    "Gyors"               ,00           ;{8. Print}
DB    "Norm�l"              ,00
DB    "Sz�p"                ,00
DB    "Ir�g�p"              ,00
DB    "Opci�k"              ,00
DB    "L�tk�p"              ,00
DB    "K�rlevelez�s"        ,00
;***********************************************************************
DB    "Directory"           ,00           ;{9. File}
DB    "Erase"               ,00
DB    "Rename"              ,00
DB    "Copy"                ,00
;***********************************************************************
DB    "Oldalak hossza   170",00           ;{10. Change Parameters}
DB    "Sork�z eloszt�s   50",00
DB    "Ment�si id�k�z  9999",00
DB    "Le�t�sek sz�ma  1000",00
DB    "Ir�g�p              ",00
DB    "Nyomtat�            ",00
;***********************************************************************
DB    "Els� oldal         1",00           ;{11. Print Options}
DB    "Utols� oldal    9999",00
DB    "Az els� lapsz�m    1",00
DB    "Nyomtat�si sz�net Be",00
DB    "Bal marg�          6",00
DB    "Darabsz�m          1",00
DB    "Lapdob�s          Be",00
DB    "Cimke t�vols�g  1.00",00
DB    "Soros vonal     COM1",00
DB    "P�rhuzamos von. LPT1",00
DB    "Id�zit�s          10",00
;***********************************************************************
DB    "Minden"              ,00           ;{12. Edit headers   }
DB    "P�ros"               ,00
DB    "Nem p�ros"           ,00
DB    " 1"                  ,00
DB    " 2"                  ,00
DB    " 3"                  ,00
DB    " 4"                  ,00
DB    " 5"                  ,00
DB    " 6"                  ,00
DB    " 7"                  ,00
DB    " 8"                  ,00
DB    " 9"                  ,00
;***********************************************************************
DB    "Minden"              ,00           ;{13. Edit footers   }
DB    "P�ros"               ,00
DB    "Nem p�ros"           ,00
DB    " 1"                  ,00
DB    " 2"                  ,00
DB    " 3"                  ,00
DB    " 4"                  ,00
DB    " 5"                  ,00
DB    " 6"                  ,00
DB    " 7"                  ,00
DB    " 8"                  ,00
DB    " 9"                  ,00
;***********************************************************************
DB    "Minden"              ,00           ;{14. Delete headers }
DB    "P�ros"               ,00
DB    "Nem p�ros"           ,00
DB    " 1"                  ,00
DB    " 2"                  ,00
DB    " 3"                  ,00
DB    " 4"                  ,00
DB    " 5"                  ,00
DB    " 6"                  ,00
DB    " 7"                  ,00
DB    " 8"                  ,00
DB    " 9"                  ,00
;***********************************************************************
DB    "Minden"              ,00           ;{15. Delete footers }
DB    "P�ros"               ,00
DB    "Nem p�ros"           ,00
DB    " 1"                  ,00
DB    " 2"                  ,00
DB    " 3"                  ,00
DB    " 4"                  ,00
DB    " 5"                  ,00
DB    " 6"                  ,00
DB    " 7"                  ,00
DB    " 8"                  ,00
DB    " 9"                  ,00
;***********************************************************************
DB    "Adatb�zis:     Nincs",00           ;{16. K�rlevelez�s}
DB    "Rekordk�p"           ,00
DB    "List�z�si felt�telek",00
DB    "Felt�telek bet�lt�se",00
DB    "Kiment�se"           ,00
;***********************************************************************
DB    "Kiadv. nyomt.   Akt.",00           ;{17. Nyomtatasi opc.}
DB    "Lapsz�moz�s    Foly.",00

VEGE:

END
