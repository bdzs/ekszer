; CDW-hez Menu textek kiiratasa
; TP5-hoz TASM form†tumban 
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

KESZ: MOV    CX,50
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
DB    "Editare"             ,00           ;{1. Main Menu }
DB    "Anulare"             ,00
DB    "å^ncarcare"          ,00
DB    "Salvare"             ,00
DB    "Modificare"          ,00
DB    "Imprimare"           ,00
DB    "Fisier"              ,00
DB    "Sfå^rsit"            ,00
;***********************************************************************
DB    "Document"            ,00           ;{2. Edit}
DB    "Buffer"              ,00
DB    "Antet"               ,00
DB    "Subsol"              ,00
DB    "Informatii"          ,00
;***********************************************************************
DB    "Document"            ,00           ;{3. Delete}
DB    "Buffer"              ,00
DB    "Antet"               ,00
DB    "Subsol"              ,00
;***********************************************************************
DB    "Document"            ,00           ;{4. Load}
DB    "Bloc buffer"         ,00
DB    "Parametru"           ,00
DB    "Fisier ASCII"        ,00
DB    "F^isier WordStar "   ,00
DB    "Antet / Subsol"      ,00
DB    "Fi^sier MACRO"       ,00
;***********************************************************************
DB    "Document"            ,00           ;{5. Save}
DB    "Bloc buffer"         ,00
DB    "Configuratie"        ,00
DB    "Parametru"           ,00
DB    "Fisier ASCII"        ,00
DB    "F^isier Ventura"      ,00
DB    "Antet / Subsol"      ,00
DB    "MACRO-uri"           ,00
;***********************************************************************
DB    "BibliotecÜ de Lucru "   ,00           ;{6. Change}
DB    "Set de caractere "      ,00
DB    "Parametrii "            ,00
DB    "B^ibliotecÜ Ed_Rom "    ,00
DB    "I^dentificator fis.     ",00
DB    "Editor:                ",00
DB    "Tipuri:                ",00
DB    "Di^splay:          Color",00
DB    "Configuratie"           ,00
DB    "C^onverzii"             ,00
;***********************************************************************
DB    "Rapid"               ,00           ;{7. Print}
DB    "Normal"              ,00
DB    "Frumos"              ,00
DB    "M.de scris"          ,00
DB    "Optiuni"             ,00
DB    "Preview"             ,00
DB    "CircularÜ"           ,00
;***********************************************************************
DB    "Directory"           ,00           ;{8. File}
DB    "Erase"               ,00
DB    "Rename"              ,00
DB    "Copy"                ,00
DB    "Sistem de op."       ,00
;***********************************************************************
DB    "Lungime pag.         170",00           ;{ 9. Change Parameters}
DB    "Spatiere rånduri      50",00
DB    "PerioadÜ salvare    9999",00
DB    "NumÜr de tastÜri    1000",00
DB    "Aranjare            Data",00
DB    "M. de scris             ",00
DB    "ImprimantÜ              ",00
DB    "Calculator              ",00
;***********************************************************************
DB    "Prima paginÜ          1",00           ;{10. Print Options}
DB    "Ultima paginÜ      9999",00
DB    "Nr. primei pag.       1",00
DB    "P^auzÜ de imprimare     ",00
DB    "Margine stånga        6",00
DB    "Copii                 1",00
DB    "A^vans paginÜ           ",00
DB    "Dist. etichetÜ     1.00",00
DB    "Linie serialÜ      COM1",00
DB    "L^inie paralelÜ     LPT1",00
DB    "Temporizare          10",00
DB    "Formatie (laser)   èll¢",00
DB    "Int^ensitate    Standard",00
DB    "Petrecere         OdatÜ",00
;***********************************************************************
DB    "General   "           ,00           ;{11. Edit headers   }
DB    "Par"                  ,00
DB    "Impar"                ,00
DB    " 1"                   ,00
DB    " 2"                   ,00
DB    " 3"                   ,00
DB    " 4"                   ,00
DB    " 5"                   ,00
DB    " 6"                   ,00
DB    " 7"                   ,00
DB    " 8"                   ,00
DB    " 9"                   ,00
;***********************************************************************
DB    "General"             ,00           ;{12. Edit footers   }
DB    "Par"                 ,00
DB    "Impar"               ,00
DB    " 1"                   ,00
DB    " 2"                   ,00
DB    " 3"                   ,00
DB    " 4"                   ,00
DB    " 5"                   ,00
DB    " 6"                   ,00
DB    " 7"                   ,00
DB    " 8"                   ,00
DB    " 9"                   ,00
;***********************************************************************
DB    "General"             ,00           ;{13. Delete headers }
DB    "Par"                 ,00
DB    "Impar"               ,00
DB    " 1"                   ,00
DB    " 2"                   ,00
DB    " 3"                   ,00
DB    " 4"                   ,00
DB    " 5"                   ,00
DB    " 6"                   ,00
DB    " 7"                   ,00
DB    " 8"                   ,00
DB    " 9"                   ,00
;***********************************************************************
DB    "General"             ,00           ;{14. Delete footers }
DB    "Par"                 ,00
DB    "Impar"               ,00
DB    " 1"                   ,00
DB    " 2"                   ,00
DB    " 3"                   ,00
DB    " 4"                   ,00
DB    " 5"                   ,00
DB    " 6"                   ,00
DB    " 7"                   ,00
DB    " 8"                   ,00
DB    " 9"                   ,00
;***********************************************************************
DB    "BazÜ de date:    Lipsa",00           ;{15. KîrlevelezÇs}
DB    "Structura inreg.      ",00
DB    "Conditii de listare   ",00
DB    "åncarcare conditii    ",00
DB    "Salvare conditii      ",00
;***********************************************************************
DB    "Mod grafic            AUTO"  ,00  ; { 16. Konfigur†ci¢ }
DB    "Lungime paginÜ         160"  ,00
DB    "L^ocul fis. OVR         EMS"  ,00
DB    "TastaturÜ               UJ"  ,00
DB    "L^inie de comunicatie  COM1"  ,00
DB    "VitezÜ de linie     115200"  ,00
DB    "Nr. liniilor indexate   80"  ,00
DB    "Memorie EMS              0"  ,00
DB    "M^emorie XMS              0"  ,00
DB    "Mo^d grafic privilest. AUTO"  ,00
DB    "Rotare                   8"  ,00
DB    "Biblioteca de bazÜ        "  ,00
DB    "Linii memo^rie disc       0"  ,00
DB    "Bibliote^cÜ memorie disc   "  ,00
DB    "Stingere monitor     60000" ,00
DB    "Volum                  50%" ,00
;***********************************************************************
DB    "Zecimi              2"  ,00  ; { 17. Kalkul†tor }
DB    "Formatie        1,000"  ,00
DB    "C^olectie de rez.   Af"  ,00
DB    "C^u numar             "  ,00
DB    "Cu ^literÜ            "  ,00
;***********************************************************************
DB    "TastaturÜ"      ,00
DB    "IncÜrcare ASCII",00
DB    "Salvare ASCII " ,00

VEGE:

END
