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
DB    "Kiadv ny*"            ,00
DB    "Endre",00
DB    "Utskrift",00
DB    "Fil",00
DB    "Slutt",00
;*****************************
DB    "Dokument",00     ;               {2.Edit}
DB    "Buffer",00
DB    "Topp",00
DB    "Bunn",00
;*****************************
DB    "Dokument",00     ;               {3.Slette}
DB    "Buffer",00
DB    "Topp",00
DB    "Bunn",00
;*****************************
DB    "Dokument",00     ;               {4.Load}
DB    "Buffer",00
DB    "Parameter",00
DB    "ASCII-fil",00
DB    "WordStar-fil",00
DB    "Topp/Bunn",00
DB    "Makro-fil",00
;*****************************
DB    "Dokument",00     ;               {5.Save}
DB    "Buffer",00
DB    "Konfigurer",00
DB    "Parameter",00
DB    "ASCIIfil",00
DB    "Venturafil",00
DB    "Topp/Bunn",00
DB    "Makro",00
;***********************************************************************
DB    "L‚trehoz s*"          ,00           ;{6. Publik ci¢ }
DB    "Megnyit s*"           ,00
DB    "T”rl‚s kiadv nyb¢l*"  ,00
DB    "Kiadv ny b”v¡t‚se*"   ,00
DB    "Filesorrend v lt s*"  ,00
DB    "Lez r s*"             ,00
DB    "Nyomtat si opc.*"     ,00
;*****************************
DB    "Arbeidskatalog  ",00     ;      {7.Change}
DB    "Tegnsett        ",00
DB    "Grunnparametere ",00
DB    "Protexkatalog   ",00
DB    "Filmaske:       ",00
DB    "Editor:         ",00
DB    "Type:           ",00
DB    "Display:Farge   ",00
;*****************************
DB    "Hurtig",00     ;               {8.Print}
DB    "Normal",00
DB    "NLQ",00
DB    "LQ",00
DB    "Opsjon",00
DB    "Preview"        ,00
DB    "Postfletting",00
;*****************************
DB    "Katalog",00     ;               {9.File}
DB    "Slett",00
DB    "Navn",00
DB    "Kopi",00
;*****************************
DB    "Sidelengde          ",00     ;  {10.Change Parameters}
DB    "Linjeavstand        ",00
DB    "Aut.backuptid       ",00
DB    "Ant.makroer.        ",00
DB    "Typehjulskr.        ",00     ; Typehjulskriver
DB    "Matriseskr.         ",00     ; Matriseskriver
;*****************************
DB    "F›rsteside1         ",00     ;  {11.Print options}
DB    "Sisteside        999",00
DB    "F›rstesidenr.      1",00
DB    "Skrivepause       P†",00
DB    "Venstremarg        6",00
DB    "Antallkopier       1",00
DB    "Nyside            P†",00
DB    "Toppmarg        1.00",00
DB    "Serieport       COM1",00
DB    "Paralellport    LPT1",00
DB    "Delay             10",00
;*****************************
DB    "Alle",00    ;               {12. Edit Headers}
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
DB    "Alle",00    ;               {13. Edit Footers}
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
DB    "Alle",00   ;               {14. Delete Headers}
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
DB    "Alle",00  ;               {15. Delete Footers}
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
DB    "Database:",00     ;               {16.K”rlevelez‚s}
DB    "Poststruktur",00
DB    "Nyebetingelser",00
DB    "Hentbetingelser",00
DB    "Lagrebetingelser",00
;***********************************************************************
DB    "Kiadv. nyomt.   Akt.",00           ;{17. Nyomtatasi opc.}
DB    "Lapsz moz s    Foly.",00

VEGE:

END
