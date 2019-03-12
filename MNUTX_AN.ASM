; CDW-hez Menu textek kiiratasa
; TP5-hoz TASM form tumban
; Normal angol

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
;***************************************************************************
DB   "Edit"                   ,00      ;{1. Main Menu }
DB   "Delete"                 ,00
DB   "Load"                   ,00
DB   "Save"                   ,00
DB   "Publicat"               ,00
DB   "Change"                 ,00
DB   "Print"                  ,00
DB   "File"                   ,00
DB   "Quit"                   ,00
;***************************************************************************
DB   "Document"               ,00      ;{2. Edit}
DB   "Buffer"                 ,00
DB   "Header"                 ,00
DB   "Footer"                 ,00
;DB   "Graphic editor"         ,00
;***************************************************************************
DB   "Document"               ,00      ;{3. Delete}
DB   "Buffer"                 ,00
DB   "Header"                 ,00
DB   "Footer"                 ,00
;***************************************************************************
DB   "Document"               ,00       ;{4. Load}
DB   "Buffer"                 ,00
DB   "Parameter"              ,00
DB   "ASCII file"             ,00
DB   "WordStar file"          ,00
DB   "Header / Footer"        ,00
DB   "Macro file"             ,00
;***************************************************************************
DB   "Document"               ,00       ;{5. Save}
DB   "Buffer"                 ,00
DB   "Configuration"          ,00
DB   "Parameter"              ,00
DB   "ASCII file"             ,00
DB   "Ventura file"           ,00
DB   "Header / Footer"        ,00
DB   "Macros"                 ,00
;***************************************************************************
DB   "Create"                 ,00      ;{6. publikacio }
DB   "Open"                   ,00
DB   "Substract"              ,00
DB   "Add. to publication"    ,00
DB   "File-order chage"       ,00
DB   "Close"                  ,00
;***************************************************************************
DB   "Work directory  "       ,00   ;{7. Change}
DB   "Fonts           "       ,00
DB   "Base parameters "       ,00
DB   "ProTex directory"       ,00
DB   "File mask:      "       ,00
DB   "Editor:         "       ,00
DB   "Type :          "       ,00
DB   "Display:  Color "       ,00
;***************************************************************************
DB   "Fast (draft)"           ,00          ;{8. Print}
DB   "Normal"                 ,00
DB   "Letter quality"         ,00
DB   "Typewriter"             ,00
DB   "Options"                ,00
DB   "Preview"                ,00
DB   "Mail merge"             ,00
;***************************************************************************
DB   "Directory"              ,00        ;{9. File}
DB   "Erase"                  ,00
DB   "Rename"                 ,00
DB   "Copy"                   ,00
;***************************************************************************
DB   "Page length      170"   ,00   ;{10. Change Parameters}
DB   "Line spacing (%)  50"   ,00
DB   "Auto.backuptime 9999"   ,00
DB   "Macro keys      1000"   ,00
DB   "Typewriter          "   ,00
DB   "Printer             "   ,00
;***************************************************************************
DB   "First page         1"   ,00  ;{11. Print Options}
DB   "Last page       9999"   ,00
DB   "First page num.    1"   ,00
DB   "Pause printing    On"   ,00
DB   "Left margin        6"   ,00
DB   "Number of copies   1"   ,00
DB   "Form feed         On"   ,00
DB   "Label distance  1.00"   ,00
DB   "Serial line     COM1"   ,00
DB   "Parallel line   LPT1"   ,00
DB   "Printer delay     10"   ,00
;***************************************************************************
DB   "All"                    ,00           ;{12. Edit headers   }
DB   "Even"                   ,00
DB   "Odd"                    ,00
DB   " 1"                     ,00
DB   " 2"                     ,00
DB   " 3"                     ,00
DB   " 4"                     ,00
DB   " 5"                     ,00
DB   " 6"                     ,00
DB   " 7"                     ,00
DB   " 8"                     ,00
DB   " 9"                     ,00
;***************************************************************************
DB   "All"                    ,00           ;{13. Edit footers   }
DB   "Even"                   ,00
DB   "Odd"                    ,00
DB   " 1"                     ,00
DB   " 2"                     ,00
DB   " 3"                     ,00
DB   " 4"                     ,00
DB   " 5"                     ,00
DB   " 6"                     ,00
DB   " 7"                     ,00
DB   " 8"                     ,00
DB   " 9"                     ,00
;***************************************************************************
DB   "All"                    ,00           ;{14. Delete headers }
DB   "Even"                   ,00
DB   "Odd"                    ,00
DB   " 1"                     ,00
DB   " 2"                     ,00
DB   " 3"                     ,00
DB   " 4"                     ,00
DB   " 5"                     ,00
DB   " 6"                     ,00
DB   " 7"                     ,00
DB   " 8"                     ,00
DB   " 9"                     ,00
;***************************************************************************
DB   "All"                    ,00           ;{15. Delete footers }
DB   "Even"                   ,00
DB   "Odd"                    ,00
DB   " 1"                     ,00
DB   " 2"                     ,00
DB   " 3"                     ,00
DB   " 4"                     ,00
DB   " 5"                     ,00
DB   " 6"                     ,00
DB   " 7"                     ,00
DB   " 8"                     ,00
DB   " 9"                     ,00
;***************************************************************************
DB   "Database:       None"   ,00         ;{16. K”rlevelez‚s}
DB   "Record structure"       ,00
DB   "New condition"          ,00
DB   "Load condition"         ,00
DB   "Save condition"         ,00
;***************************************************************************
DB   "Publ. print     Act."   ,00         ;{17. Publ./nyomt.opci¢k}
DB   "Page numbering Cont."   ,00

VEGE:

END
