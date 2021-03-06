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
DB    "Szerkeszt�s"         ,00           ;{1. Main Menu }
DB    "T�rl�s"              ,00
DB    "Bet�lt�s"            ,00
DB    "Ment�s"              ,00
DB    "Csere"               ,00
DB    "Nyomtat�s"           ,00
DB    "File"                ,00
DB    "V�ge"                ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{2. Edit}
DB    "Puffer"              ,00
DB    "Fejl�c"              ,00
DB    "L�br�sz"             ,00
DB    "Inform�ci�k"         ,00
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
DB    "Munka k�nyvt�r"      ,00           ;{6. Change}
DB    "Karakterk�szlet"     ,00
DB    "Param�terek"         ,00
DB    "�k^Szer k�nyvt�r"    ,00
DB    "File maszk:     "    ,00
DB    "Editor:         "    ,00
DB    "T�pus:          "    ,00
DB    "Display:  Szines"    ,00
DB    "K^onfigur�ci�"       ,00
DB    "Ko^nverzi�k"         ,00
;***********************************************************************
DB    "Gyors"               ,00           ;{7. Print}
DB    "Norm�l"              ,00
DB    "Sz�p"                ,00
DB    "Ir�g�p"              ,00
DB    "Opci�k"              ,00
DB    "L�tk�p"              ,00
DB    "K�rlevelez�s"        ,00
;***********************************************************************
DB    "Directory"           ,00           ;{8. File}
DB    "Erase"               ,00
DB    "Rename"              ,00
DB    "Copy"                ,00
DB    "Op. rendszer"        ,00
;***********************************************************************
DB    "Oldalak hossza   170",00           ;{9.  Change Parameters}
DB    "Sork�z eloszt�s   50",00
DB    "Ment�si id�k�z  9999",00
DB    "Le�t�sek sz�ma  1000",00
DB    "Rendez�s       D�tum",00
DB    "Ir�g�p              ",00
DB    "Nyomtat�            ",00
DB    "Kalkul�tor"          ,00
;***********************************************************************
DB    "Els� oldal           1",00           ;{10. Print Options}
DB    "Utols� oldal      9999",00
DB    "Az els� lapsz�m      1",00
DB    "Nyomtat�si sz�net   Be",00
DB    "Bal marg�            6",00
DB    "Darabsz�m            1",00
DB    "Lapdob�s            Be",00
DB    "Cimke t�vols�g    1.00",00
DB    "S^oros vonal       COM1",00
DB    "P�rhuzamos von.   LPT1",00
DB    "Id�zit�s            10",00
DB    "Form�tum (l�zer)  �ll�",00
DB    "S�r�s�g       Standard",00
DB    "Le^t�lt�s       Egyszer",00
;***********************************************************************
DB    "Minden"              ,00           ;{11. Edit headers   }
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
DB    "Minden"              ,00           ;{12. Edit footers   }
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
DB    "Minden"              ,00           ;{13. Delete headers }
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
DB    "Minden"              ,00           ;{14. Delete footers }
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
DB    "Adatb�zis:     Nincs",00           ;{15. K�rlevelez�s}
DB    "Rekordk�p"           ,00
DB    "List�z�si felt�telek",00
DB    "Felt�telek bet�lt�se",00
DB    "Kiment�se"           ,00
;***********************************************************************
DB    "Grafikus m�d         AUTO"  ,00  ; { 16. Konfigur�ci� }
DB    "Sorhossz              160"  ,00  
DB    "OVR file helye        EMS"  ,00
DB    "Billenty�zet           UJ"  ,00
DB    "Kommunik�ci�s vonal  COM1"  ,00
DB    "Vonali sebess�g    115200"  ,00
DB    "Indexsorok sz�ma       80"  ,00
DB    "EMS mem�ria             0"  ,00
DB    "XMS mem�ria             0"  ,00
DB    "L�tk�p grafikus m�d  AUTO"  ,00
DB    "G�rget�s                8"  ,00
DB    "Alap k�nyvt�r"              ,00
DB    "Disk mem�ria sorok      0"  ,00
DB    "Disk ^mem/sz�t�r k�nyvt�r"  ,00
DB    "K�^perny� kiolt�s    60000" ,00
DB    "Hanger�                50%" ,00
;***********************************************************************
DB    "Tizedesek           2"  ,00  ; { 17. Kalkul�tor }
DB    "Form�tum        1,000"  ,00
DB    "Eredm�ny gy�jt�s   Ki"  ,00
DB    "Sz�mmal              "  ,00
DB    "Bet�vel              "  ,00
;***********************************************************************
DB    "Billenty�zet",00
DB    "ASCII bet�lt�s",00
DB    "ASCII kiment�s",00

VEGE:

END
