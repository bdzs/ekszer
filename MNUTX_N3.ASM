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
DB    "Rediger",00     ;               {1. Main menu }
DB    "Slett",00
DB    "Hent",00
DB    "Lagre",00
DB    "Endre",00
DB    "Utskrift",00
DB    "Fil",00
DB    "Slu^tt",00
;*****************************
DB    "Dokument",00     ;               {2.Edit}
DB    "Buffer",00
DB    "Topptekst",00
DB    "B^unntekst",00
DB    "Informasjon",00 ;
;*****************************
DB    "Dokument",00     ;               {3.Slette}
DB    "Buffer",00
DB    "Topptekst",00
DB    "B^unntekst",00
;*****************************
DB    "Dokument",00     ;               {4.Load}
DB    "Buffer",00
DB    "Parametere",00
DB    "ASCII-fil",00
DB    "WordStar-fil",00
DB    "Topp/Bunn-tekst",00
DB    "Makro-fil",00
;*****************************
DB    "Dokument",00     ;               {5.Save}
DB    "Buffer",00
DB    "Konfigurasjon",00
DB    "Parametere",00
DB    "ASCII-fil",00
DB    "Ventura-fil",00
DB    "Topp/Bunn-tekst",00
DB    "Makro-fil",00
;*****************************
DB    "Arbeidskatalog  ",00     ;               {6.Change}
DB    "Tegnsett        ",00
DB    "Grunnparametere" ,00
DB    "Protexkatalog"   ,00
DB    "Filmaske:       ",00
DB    "Editor:         ",00
DB    "T^ype:           ",00
DB    "Display:   Farge",00
DB    "Konfigurasjon"   ,00
DB    "K^onvertering"   ,00
;*****************************
DB    "Rask"           ,00     ;               {7.Print}
DB    "Normal"         ,00
DB    "Brevkvalitet"   ,00
DB    "Typehjulskriver",00
DB    "Andre valg"     ,00
DB    "Forh†ndsvisn."  ,00
DB    "Postfletting"   ,00
;*****************************
DB    "Katalog"        ,00     ;               {8.File}
DB    "Slett"          ,00
DB    "Forandre navn"  ,00
DB    "K^opier"         ,00
DB    "Ut til DOS"     ,00
;*****************************
DB    "Sidelengde/halve lin",00     ;  {9.Change Parameters}
DB    "Linjeavstand        ",00
DB    "Aut.backuptid       ",00
DB    "A^nt.makroer.        ",00
DB    "S^ortere             ",00
DB    "Typehjulskr.        ",00     ; Typehjulskriver
DB    "Sk^river             ",00     ; Matriseskriver
DB    "Kalkulator",00
;*****************************
DB    "Fra side           1",00     ;               {10.PrintOptions}
DB    "Til side         999",00
DB    "F›^rste sidenr.     1",00
DB    "Skriverpause      P†",00
DB    "Venstremarg        6",00
DB    "Antall kopier      1",00
DB    "S^ideskift         P†",00
DB    "T^oppmarg        1.00",00
DB    "S^erieport       COM1",00
DB    "Paralellport    LPT1",00
DB    "S^kriverforsinkels.10",00
DB    "Si^de-format         ",00
DB    "Bokstbredde Standard",00
DB    "Se^nd tegnsett       ",00
;*****************************
DB    "Alle",00    ;               {11. Edit Headers}
DB    "Like",00
DB    "Ulike",00
DB    "1",00
DB    "2",00
DB    "3",00
DB    "4",00
DB    "5",00
DB    "6",00
DB    "7",00
DB    "8",00
DB    "9",00
;*****************************
DB    "Alle",00    ;               {12. Edit Footers}
DB    "Like",00
DB    "Ulike",00
DB    "1",00
DB    "2",00
DB    "3",00
DB    "4",00
DB    "5",00
DB    "6",00
DB    "7",00
DB    "8",00
DB    "9",00
;*****************************
DB    "Alle",00   ;               {13. Delete Headers}
DB    "Like",00
DB    "Ulike",00
DB    "1",00
DB    "2",00
DB    "3",00
DB    "4",00
DB    "5",00
DB    "6",00
DB    "7",00
DB    "8",00
DB    "9",00
;*****************************
DB    "Alle",00  ;               {14. Delete Footers}
DB    "Like",00
DB    "Ulike",00
DB    "1",00
DB    "2",00
DB    "3",00
DB    "4",00
DB    "5",00
DB    "6",00
DB    "7",00
DB    "8",00
DB    "9",00
;*****************************
DB    "Database:           ",00     ;               {15.K”rlevelez‚s}
DB    "Poststruktur"        ,00
DB    "Listebetingelser"    ,00
DB    "Hente betingelser"   ,00
DB    "L^agre betingelser"   ,00
;***********************************************************************
DB    "Grafisk modus         AUTO" ,00  ; { 16. Konfigur ci¢ }
DB    "Linjebredde            160" ,00
DB    "OVR-fil plassering     EMS" ,00
DB    "Tastaturtype            AT" ,00
DB    "Kommunikasjon-kanal   COM1" ,00
DB    "L^injehastighet      115200",00
DB    "Antall indekslinjer     80" ,00
DB    "EMS-minne (KByte)        0" ,00
DB    "XMS-minne (KByte)        0" ,00
DB    "Vis siden grafisk     AUTO" ,00
DB    "Rulle sideveis           8" ,00
DB    "Gr^unnkatalog"              ,00
DB    "A^nt.tekstlinjer disk 00000",00
DB    "Diskminne-katalog    "      ,00
DB    "Sk^jermbildesparer    60000",00
DB    "L^yd                    50%",00
;***********************************************************************
DB    "Desimaler            2"  ,00  ; { 17. Kalkul tor }
DB    "Tall-format      1,000"  ,00
DB    "Mellomsummer          "  ,00
DB    "Sum med tall          "  ,00
DB    "S^um med bokstaver     "  ,00
;***********************************************************************
DB    "Konv. av ASCII tekst",00
DB    "Inng†ende ASCII tekst",00
DB    "Utg†ende ASCII tekst",00

VEGE:

END
