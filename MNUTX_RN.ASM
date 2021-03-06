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
DB    "Incarcare"           ,00 
DB    "Salvare"             ,00 
DB    "Publicatie"          ,00 
DB    "Modificare"          ,00 
DB    "Listare"             ,00 
DB    "Fisier"              ,00 
DB    "Terminare"           ,00 
;*********************************************************************** 
DB    "Document"            ,00           ;{2. Edit} 
DB    "Buffer"              ,00 
DB    "Antet"               ,00 
DB    "Subsol"              ,00 
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
DB    "Fisier WordStar "    ,00 
DB    "Subsol / Antet"      ,00 
DB    "Fisier MACRO"        ,00 
;*********************************************************************** 
DB    "Document"            ,00           ;{5. Save} 
DB    "Bloc buffer"         ,00 
DB    "Configuratie"        ,00 
DB    "Parametru"           ,00 
DB    "Fisier ASCII"        ,00 
DB    "Fisier Ventura"      ,00 
DB    "Subsol / Antet"      ,00 
DB    "Fisier MACRO"        ,00 
;*********************************************************************** 
DB    "Creare"              ,00           ;{6. Publik�ci� } 
DB    "Deschidere"          ,00 
DB    "Stergere din publ."  ,00 
DB    "Extindere publicatie",00 
DB    "Modif. ordine fisier",00 
DB    "Inchidere"           ,00 
DB    "Optiuni de tiparire" ,00 
;*********************************************************************** 
DB    "Biblioteca de Lucru"   ,00           ;{6. Change}
DB    "Set de caractere"      ,00
DB    "Parametri"             ,00
DB    "Biblioteca Ed_Rom"     ,00
DB    "Identificator fis.    ",00
DB    "Editor:               ",00
DB    "Tipuri:               ",00
DB    "Display:         Color",00
;***********************************************************************
DB    "Rapid"               ,00           ;{8. Print} 
DB    "Normal"              ,00 
DB    "Frumos"              ,00 
DB    "Masina de scris"     ,00 
DB    "Optiuni"             ,00 
DB    "Preview"             ,00
DB    "Circulara"           ,00 
;*********************************************************************** 
DB    "Directori"           ,00           ;{9. File} 
DB    "Stergere"            ,00 
DB    "Redenumire"          ,00 
DB    "Copiere"             ,00 
;*********************************************************************** 
DB    "Lungime pagina       170",00           ;{10. Change Parameters}
DB    "Spatiere rinduri      50",00
DB    "Perioada salvare    9999",00
DB    "Numar tastare       1000",00
DB    "Masina de scris:        ",00
DB    "Imprimanta:             ",00
;*********************************************************************** 
DB    "Prima pagina       1",00           ;{11. Print Options} 
DB    "Ultima pagina   9999",00 
DB    "Nr. primei pag.    1",00 
DB    "Suspendarea imprim. ",00 
DB    "Margine stinga     6",00 
DB    "Copii              1",00 
DB    "Avans pagina        ",00 
DB    "Dist. eticheta  1.00",00 
DB    "Port Serial     COM1",00 
DB    "Port Paralel    LPT1",00 
DB    "Temporizare       10",00 
;*********************************************************************** 
DB    "General   "          ,00           ;{12. Edit headers   } 
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
DB    "General"             ,00           ;{13. Edit footers   }
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
DB    "General"             ,00           ;{14. Delete headers }
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
DB    "General"             ,00           ;{15. Delete footers }
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
DB    "Baza de date:    Lipsa",00           ;{16. K�rlevelez�s}
DB    "Structura inreg."    ,00
DB    "Conditi de listare " ,00
DB    "Incarcare conditii"  ,00
DB    "Salvare conditii"    ,00
;***********************************************************************
DB    "Tip. publ.      Act.",00           ;{17. Nyomtatasi opc.}
DB    "Numerotare pg. Cont.",00

VEGE: 

END 
