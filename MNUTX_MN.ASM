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
DB    "Tîrîl"               ,00
DB    "Betîlt"              ,00
DB    "Ment"                ,00
DB    "Kiadv†ny"            ,00
DB    "Csere"               ,00
DB    "Nyomtat"             ,00
DB    "File"                ,00
DB    "VÇge"                ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{2. Edit}
DB    "Puffer"              ,00
DB    "FejlÇc"              ,00
DB    "L†brÇsz"             ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{3. Delete}
DB    "Puffer"              ,00
DB    "FejlÇc"              ,00
DB    "L†brÇsz"             ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{4. Load}
DB    "Blokk puffer"        ,00
DB    "ParamÇter"           ,00
DB    "ASCII file"          ,00
DB    "WordStar file"       ,00
DB    "FejlÇc / L†brÇsz"    ,00
DB    "Makr¢ file"          ,00
;***********************************************************************
DB    "Dokumentum"          ,00           ;{5. Save}
DB    "Blokk puffer"        ,00
DB    "Konfigur†ci¢"        ,00
DB    "ParamÇter"           ,00
DB    "ASCII file"          ,00
DB    "Ventura file"        ,00
DB    "FejlÇc / L†brÇsz"    ,00
DB    "Makr¢k"              ,00
;***********************************************************************
DB    "LÇtrehoz†s"          ,00           ;{6. Publik†ci¢ }
DB    "Megnyit†s"           ,00
DB    "TîrlÇs kiadv†nyb¢l"  ,00
DB    "Kiadv†ny bîv°tÇse"   ,00
DB    "Filesorrend v†lt†s"  ,00
DB    "Lez†r†s"             ,00
DB    "Nyomtat†si opc."     ,00
;***********************************************************************
DB    "Munka kînyvt†r  "    ,00           ;{7. Change}
DB    "KarakterkÇszlet "    ,00
DB    "ParamÇterek     "    ,00
DB    "êkSzer kînyvt†r "    ,00
DB    "File maszk:     "    ,00
DB    "Editor:         "    ,00
DB    "T°pus:          "    ,00
DB    "Display:  Szines"    ,00
;***********************************************************************
DB    "Gyors"               ,00           ;{8. Print}
DB    "Norm†l"              ,00
DB    "SzÇp"                ,00
DB    "Ir¢gÇp"              ,00
DB    "Opci¢k"              ,00
DB    "L†tkÇp"              ,00
DB    "KîrlevelezÇs"        ,00
;***********************************************************************
DB    "Directory"           ,00           ;{9. File}
DB    "Erase"               ,00
DB    "Rename"              ,00
DB    "Copy"                ,00
;***********************************************************************
DB    "Oldalak hossza   170",00           ;{10. Change Parameters}
DB    "Sorkîz eloszt†s   50",00
DB    "MentÇsi idìkîz  9999",00
DB    "LeÅtÇsek sz†ma  1000",00
DB    "Ir¢gÇp              ",00
DB    "Nyomtat¢            ",00
;***********************************************************************
DB    "Elsì oldal         1",00           ;{11. Print Options}
DB    "Utols¢ oldal    9999",00
DB    "Az elsì lapsz†m    1",00
DB    "Nyomtat†si szÅnet Be",00
DB    "Bal marg¢          6",00
DB    "Darabsz†m          1",00
DB    "Lapdob†s          Be",00
DB    "Cimke t†vols†g  1.00",00
DB    "Soros vonal     COM1",00
DB    "P†rhuzamos von. LPT1",00
DB    "IdìzitÇs          10",00
;***********************************************************************
DB    "Minden"              ,00           ;{12. Edit headers   }
DB    "P†ros"               ,00
DB    "Nem p†ros"           ,00
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
DB    "P†ros"               ,00
DB    "Nem p†ros"           ,00
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
DB    "P†ros"               ,00
DB    "Nem p†ros"           ,00
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
DB    "P†ros"               ,00
DB    "Nem p†ros"           ,00
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
DB    "Adatb†zis:     Nincs",00           ;{16. KîrlevelezÇs}
DB    "RekordkÇp"           ,00
DB    "List†z†si feltÇtelek",00
DB    "FeltÇtelek betîltÇse",00
DB    "KimentÇse"           ,00
;***********************************************************************
DB    "Kiadv. nyomt.   Akt.",00           ;{17. Nyomtatasi opc.}
DB    "Lapsz†moz†s    Foly.",00

VEGE:

END
