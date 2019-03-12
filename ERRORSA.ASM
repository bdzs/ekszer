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

      MOV    BX,NUM
      MOV    AL,00
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

DB   "File not found : ",00          ;  {  1 }
DB   "Invalid path ",00              ;  {  2 }
DB   "File opening error ",00        ;  {  3 }
DB   "Not enough memory ",00         ;  {  4 }
DB   "Macro definition too long",00  ;  {  5 }
DB   "Disk read error ",00           ;  {  6 }
DB   "16 macros can be defined",00   ;  {  7 }
DB   "String not found",00           ;  {  8 }
DB   "Fontfile not found",00         ;  {  9 }
DB   "*** Memory full ***",00        ;  { 10 }
DB   "Missing printer parameters",00 ;  { 11 }
DB   "Duplicate filename : ",00      ;  { 12 }
DB   "Invalid Macro file : ",00      ;  { 13 }
DB   "Invalid Headerfile: ",00       ;  { 14 }
DB   "Drive not ready : ",00         ;  { 15 }
DB   "Disk write protected",00       ;  { 16 }
DB   "Undefined macro : ",00         ;  { 17 }
DB   "Disk write error ",00          ;  { 18 }
DB   "Printer not ready",00          ;  { 19 }
DB   " ",00                          ;  { 20 }
DB   "Unsuccessful rename",00        ;  { 21 }
DB   "Reserved filename : ",00       ;  { 22 }
DB   "Overlay error ",00             ;  { 23 }
DB   "Invalid file : ",00            ;  { 24 }
DB   "Duplicate filename",00         ;  { 25 }
DB   "File error ",00                ;  { 26 }
DB   "Invalid modem baud rate: ",00  ;  { 27 }
DB   "Invalid Database : ",00        ;  { 28 }
DB   "Error in condition : ",00      ;  { 29 }
DB   "Unknown video card",00         ;  { 30 }
DB   "Winchester error !",00         ;  { 31 }
DB   "Unformatted or bad disk!",00   ;  { 32 }
DB   "Disk operation error ! ",00    ;  { 33 }
DB   "Invalid filename ! ",00        ;  { 34 }
DB   "Publ. file not found !",00     ;  { 35 }
DB   "Empty publication !",00        ;  { 36 }
DB   "Publication is full !",00      ;  { 37 }
DB   "Bad file into publication : ",00; { 38 }
DB   "Publication file isn't open !",00;{ 39 }
DB   "Laser-font loading error !",00 ;  { 40 }
DB   "This file is read only : ",00  ;  { 41 }
DB   "Index line(s) ignored !",00    ;  { 42 }
DB   "Novell Netware Error !",00                  ;  { 43 }
DB   "Network access right required !",00         ;  { 44 }
DB   "All place in the network is reserved !",00  ;  { 45 }
DB   "You are already logged in !",00             ;  { 46 }
DB   "Can't save !",00                            ;  { 47 }
DB   "The key was restarted !",00                 ;  { 48 }
DB   "Supervisor right required !",00             ;  { 49 }
DB   "Invalid password : ",00                     ;  { 50 }
DB   "Filename too long : ",00                    ;  { 51 }
DB   "Extension too long : ",00                   ;  { 52 }
DB   "No file and directory in disk !",00         ;  { 53 }
DB   "Graphics hardware not detected !",00        ;  { 54 }
DB   "Too long lines, truncated ",00              ;  { 55 }

VEGE:

END
