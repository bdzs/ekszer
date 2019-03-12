; CDW-hez kifejezes kiertekelo rutin
; TP5-hoz TASM form tumban
;
; ************* LOGIKAI OPERATOROK JELOLESE : *****************
;
; 00  = NINCS TOVABBI FELTETEL EZEN A SZINTEN
; 01  = AND
; 10  = OR
; 11  = XOR
;
; ************* RELACIOS OPERATOROK JELOLESE : ****************
;
; 000 = "="    = NOT("<>")
; 001 = "<"    = NOT(">=")
; 010 = "<="   = NOT(">")
; 011 = "IN"   = NOT("OUT")
; 100 = "OUT"  = NOT("IN")
; 101 = ">"    = NOT("<=")
; 110 = ">="   = NOT("<")
; 111 = "<>"   = NOT("=")

.MODEL TPASCAL
.CODE

VARSTLEN  EQU 21 ; STRING[20] A CDWHUN.DEF-BEN
VARIALEN  EQU 19 ; STRING[18] A CDWHUN.DEF-BEN
RESULTLEN EQU 128; ARRAY [1..128] OF BYTE;

STNUM     EQU 16 ; VARST : ARRAY [1..16]

KIERTEKEL PROC FAR VARNUM: BYTE, CONDI: DWORD, VARST: DWORD, VARIABLES: DWORD, RESULT: DWORD, HIBAKOD: DWORD, HIBAPOZ: DWORD

PUBLIC KIERTEKEL

      PUSH   AX
      PUSH   BX
      PUSH   CX
      PUSH   DX
      PUSH   DI
      PUSH   SI
      PUSH   DS
      PUSH   ES

      CLD

      MOV    BYTE PTR CS:[NUM],00
      MOV    BYTE PTR CS:[NOTOPER],00
      MOV    BYTE PTR CS:[COUNT],00
      MOV    BYTE PTR CS:[PEQ],00
      MOV    BYTE PTR CS:[LEVEL],00
      MOV    BYTE PTR CS:[OLEVEL],00
      MOV    BYTE PTR CS:[ERRORCODE],00
      MOV    WORD PTR CS:[POINTER],00

IFNDEF DEBUG

      LDS    SI,HIBAKOD
      MOV    BYTE PTR DS:[SI],00

      LES    DI,VARIABLES
      MOV    CX,STNUM*VARIALEN
      MOV    AL,00
      REPZ   STOSB

      LES    DI,RESULT
      MOV    CX,RESULTLEN
      REPZ   STOSB

ENDIF

      XOR    CX,CX

IFDEF DEBUG
      MOV    CL,1
ELSE
      MOV    CL,VARNUM         ; DEBUG ! = 1
ENDIF
      CMP    CL,00
      JNZ    NEM_VEGE

      JMP    VEGE

NEM_VEGE:

IFDEF DEBUG

      PUSH   CS               ;
      POP    DS               ;
      MOV    SI,OFFSET STRING ;

ELSE
      LDS    SI,CONDI     ; !!!
      MOV    CS:[CONDIOFS],SI
ENDIF

      PUSH   DS
      POP    ES
      MOV    DI,SI

      LODSB           ; LENGTH
      MOV    CL,AL

      MOV    BX,CX      ; ZARO NULLA A STRING UTAN
      MOV    AL,00
      MOV    [BX+SI],AL

CIK:  LODSB
      CMP    AL," "
      JNZ    NEMSP
      LOOP   CIK

      MOV    BYTE PTR CS:[ERRORCODE],03  ; EMPTY STRING ERROR = 3
      MOV    CS:[HIBAHELY],SI
      JMP    SHORT HIBA

NEMSP:CMP    AL,"("
      JNZ    NEMCL
      INC    CS:[LEVEL]
      LOOP   CIK

      MOV    BYTE PTR CS:[ERRORCODE],01  ; SYNTAX ERROR = 3
      MOV    CS:[HIBAHELY],SI
      JMP    SHORT HIBA

NEMCL:
      ;INT 3
      DEC    SI
      MOV    DI,SI
      MOV    BX,DI     ; ES:BX = AZ ELSO STRING

      CALL   NEXT_POS  ; ES:BX      AZ ELSO STRING CIME,
                       ; CS:LENGTH1 AZ ELSO STRING HOSSZA,
                       ; ES:DI      MASODIK STRING CIME,
                       ; CS:LENGTH2 MASODIK STRING HOSSZA,
                       ; CS:KOD = AZ OPERATOR KODJA
                       ; CS:ERRORCODE = 0 HA OK,
                       ; CS:ERRORCODE = 1 (SYNTAX) HA HIBA VOLT, ES CARRY YES

KIUG: JNC    JOK

HIBA: MOV    SI,CS:[HIBAHELY]
      SUB    SI,CS:[CONDIOFS]  ; A Hiba pozicioja
      PUSH   SI
      POP    BX
      LDS    SI,HIBAPOZ
      MOV    [SI],BL

      LDS    SI,HIBAKOD
      MOV    AL,CS:[ERRORCODE]
      MOV    DS:[SI],AL
      JMP    VEGE

JOK:  CALL   SCAN_STR  ; AZ ES:BX STRINGET KERESI A VARST
                       ; ARRAY [1..16] OF STRING[20] TOMBBEN
                       ; HA MEGVAN, CS:NUM A TOMBELEM SZAMA (0-TOL)
                       ; HA NINCS, CS:ERRORCODE = 02 (UNKNOWN IDENTIFIER)
                       ; ES CARRY YES

      MOV    CS:[HIBAHELY],BX
      JC     HIBA

      CALL   STORE_STR ; AZ ES:DI CIMU LENGTH2 HOSSZU STRINGET
                       ; LETAROLJA A VARIABLES[COUNT] PASCAL TOMBBE
                       ; HA "IN" VAGY "OUT" VOLT AZ OPERATOR, A STRINGET
                       ; ELLENORZI, HOGY RANGE TIPUSU-E ("X..X"), HA NEM
                       ; CARRY YES, ES CS:ERRORCODE = 7

      MOV    CS:[HIBAHELY],DI
      JC     HIBA

      DEC    BYTE PTR CS:[LEVEL]
      MOV    BYTE PTR CS:[VANCONDI],1
      MOV    DI,CS:[BEZAR]
      INC    DI

      MOV    AL,CS:[LEVEL]
      MOV    CS:[OLEVEL],AL

      MOV    AH,00

KOVC: MOV    AL," "
      CMP    BYTE PTR ES:[DI],AL
      JNZ    EZNEMSP

      REPZ   SCASB
      DEC    DI

EZNEMSP:
      MOV    AL,")"
      CMP    BYTE PTR ES:[DI],AL
      JNZ    NEM_DECLEVEL

      INC    AH
      DEC    BYTE PTR CS:[LEVEL]
      JGE    OK_DEC

      MOV    BYTE PTR CS:[ERRORCODE],05 ; TOO MANY ")" ERROR
      MOV    CS:[HIBAHELY],DI
      JMP    SHORT HIBA

OK_DEC:
      MOV    BYTE PTR CS:[VANCONDI],0  ; NINCS TOVABBI FELTETEL

      INC    DI
      JMP    SHORT KOVC

NEM_DECLEVEL:

      MOV    AL,00
      CMP    ES:[DI],AL
      JNZ    NINCS_VEGE

      XOR    CX,CX        ; 00 AZ UTOLSO KARAKTER : VEGE
      JMP    LEGUTOLSO

NINCS_VEGE:
      PUSH   CS
      POP    DS

      PUSH   CX

      XOR    CX,CX
      XOR    AX,AX

      MOV    SI,OFFSET AND_STR ; "AND"
      LODSB
      DEC    AL
      DEC    AL
      MOV    CL,AL
      REPZ   CMPSB
      JZ     OKAY

      SUB    AX,CX                    ; AZ "AND" VIZSGALATNAL ENNYIT MENT ELORE
      SUB    DI,AX                    ; UGYANANNYIT VISSZA
      MOV    SI,OFFSET OR_STR ; "OR"
      LODSB
      DEC    AL
      DEC    AL
      MOV    CL,AL
      REPZ   CMPSB
      JZ     OKAY

      SUB    AX,CX                    ; AZ "OR" VIZSGALATNAL ENNYIT MENT ELORE
      SUB    DI,AX                    ; UGYANANNYIT VISSZA
      MOV    SI,OFFSET XOR_STR ; "XOR"
      LODSB
      DEC    AL
      DEC    AL
      MOV    CL,AL
      REPZ   CMPSB
      JZ     OKAY

      POP    CX
      MOV    BYTE PTR CS:[ERRORCODE],04 ; "MISSING OPERATOR"
      MOV    CS:[HIBAHELY],DI
      JMP    HIBA   ; NINCS "AND"  "OR"  VAGY  "XOR": ERROR

OKAY: POP    CX
      PUSH   CX
      LODSB
      MOV    CS:[OPERATOR],AL

      MOV    AL," "
      CMP    BYTE PTR ES:[DI],AL
      JNZ    EZ_NEM_SPACE

      REPZ   SCASB
      DEC    DI

      MOV    BYTE PTR CS:[NCOUNT],00

EZ_NEM_SPACE:

;      CMP    BYTE PTR CS:[VANCONDI],00
;      JZ     NEM_KELL_KOV

      PUSH   DI
      PUSH   CX

NEXT_CHARACTER:

      MOV    AL," "
      CMP    BYTE PTR ES:[DI],AL
      JNZ    EZNEMSPACE

      MOV    CX,64
      REPZ   SCASB
      DEC    DI

EZNEMSPACE:

      MOV    AL,"("
      CMP    BYTE PTR ES:[DI],AL
      JZ     INC_NCOUNT

      CMP    BYTE PTR CS:[NCOUNT],00
      JNZ    NY_KESZ

      MOV    CS:[HIBAHELY],DI
      POP    CX
      POP    DI
      POP    CX
      MOV    BYTE PTR CS:[ERRORCODE],08 ; "MISSING "(" "
      JMP    HIBA

INC_NCOUNT:

      INC    DI
      INC    BYTE PTR CS:[NCOUNT]
      JMP    NEXT_CHARACTER

NY_KESZ:
      CMP    BYTE PTR CS:[NCOUNT],1
      JZ     NEM_TOBB_NYITO

      MOV    BYTE PTR CS:[VANCONDI],0  ; NINCS TOVABBI FELTETEL

NEM_TOBB_NYITO:

      POP    CX
      POP    DI

;NEM_KELL_KOV:

      MOV    AL,CS:[NOTOPER]
      MOV    CS:[O_NOTOPER],AL

      MOV    BYTE PTR CS:[NOTOPER],00

      MOV    SI,OFFSET NOT_STR ; "NOT"
      XOR    AX,AX
      XOR    CX,CX
      LODSB
      DEC    AL
      DEC    AL
      MOV    CL,AL
      REPZ   CMPSB
      JNZ    NEM_NOT

      LODSB
      MOV   CS:[NOTOPER],AL ; = 7
      POP   CX
      JMP   SHORT LEGUTOLSO

NEM_NOT:
      SUB   AX,CX
      SUB   DI,AX
      POP   CX

LEGUTOLSO:
      PUSH  CX

IFNDEF DEBUG
      LDS   SI,RESULT ; PASCAL PARAMETER
ELSE
      PUSH  CS
      POP   DS
      MOV   SI,OFFSET DEB_STR
ENDIF
      MOV   BX,CS:[POINTER]

      MOV   AL,CS:[NUM]     ; 1. BYTE = VARST TOMBINDEXE (1-TOL)
      INC   AL
      MOV   [BX+SI],AL
      INC   BX

      MOV   AL,CS:[COUNT]   ; 2. BYTE = VARIABLES TOMBINDEXE (1-TOL)
      MOV   [BX+SI],AL
      INC   BX

                            ; 3. BYTE :

      MOV   AL,CS:[OLEVEL]  ; ***.....  : SZINT
      MOV   CL,05
      SHL   AL,CL
      MOV   AH,CS:[KOD]     ; ...***..  : RELACIOS OPERATOR
      MOV   CL,02
      SHL   AH,CL
      OR    AL,AH
      MOV   AH,CS:O_NOTOPER ;...***..  : NOT OPERATOR (0 VAGY 7)
      SHL   AH,CL
      XOR   AL,AH

      CMP   BYTE PTR CS:[VANCONDI],0
      JNZ    NINCS_PLUSZBYTE

      AND   AL,0FCH         ; ......00  ; NINCS TOVABBI FELTETEL EZEN A SZINTEN
      MOV   [BX+SI],AL
      INC   BX              ; JON A PLUSZBYTE (4.)

      MOV   AL,CS:[LEVEL]   ; .***....  : A ")))" UTANI SZINT
      MOV   CL,04
      SHL   AL,CL

NINCS_PLUSZBYTE:
      MOV   AH,CS:[OPERATOR]; ......**  : LOGIKAI OPERATOR
      OR    AL,AH
      MOV   [BX+SI],AL
      INC   BX

      MOV   CS:[POINTER],BX

      POP   CX

      PUSH  ES
      POP   DS

      MOV   SI,DI

      OR    CX,CX
      JNZ   XLOOP

      CMP   BYTE PTR CS:[LEVEL],00
      JNZ   ERR6

      LDS   SI,RESULT ; PASCAL PARAMETER
      MOV   BX,CS:[POINTER]
      DEC   BX

      DEC   BX
      DEC   BX
      MOV   AL,CS:[NOTOPER]       ; A LEGUTOLSO NOT OPERATOR
      SHL   AL,1
      SHL   AL,1
      XOR   BYTE PTR [BX+SI],AL
      INC   BX
      INC   BX

      AND   BYTE PTR [BX+SI],0FCH ; AZ UTOLSO LOGOKAI KAPCSOLAT = 0
      INC   BX
      MOV   BYTE PTR [BX+SI],00   ; ZARO 0

      JMP   SHORT VEGE

ERR6: MOV    BYTE PTR CS:[ERRORCODE],06 ; NEM 0 SZINT ERROR
      MOV    CS:[HIBAHELY],SI
      JMP    HIBA

XLOOP:JMP   CIK

VEGE: POP    ES
      POP    DS
      POP    SI
      POP    DI
      POP    DX
      POP    CX
      POP    BX
      POP    AX

      RET

KIERTEKEL ENDP

; ****************************************************************************

STORE_STR:

      PUSH   DS
      PUSH   ES
      PUSH   SI
      PUSH   DI
      PUSH   CX

      PUSH   ES
      POP    DS
      MOV    SI,DI

IFDEF DEBUG
      PUSH   CS
      POP    ES
      MOV    DI,OFFSET DEB_VARI
ELSE
      LES    DI,VARIABLES
ENDIF
      MOV    BL,CS:[COUNT]
      DEC    BL            ; A COUNT 1-TOL KEZDODIK
      MOV    AX,VARIALEN   ; = 17 (ARRAY OF STRING[16])
      MUL    BL            ; N. TOMBELEM
      ADD    DI,AX

      XOR    CX,CX
      MOV    CL,CS:[LENGTH2]
      CMP    CL,VARIALEN-1 ; = 16
      JBE    VLEN_OK

      MOV    CL,VARIALEN-1 ; = 16

VLEN_OK:
      MOV    AL,CL
      STOSB

      PUSH   CX
      PUSH   DI

      REPZ   MOVSB

      POP    DI
      POP    CX

      CMP    BYTE PTR CS:KOD,03
      JZ     IN_OUT

      CMP    BYTE PTR CS:KOD,04
      JZ     IN_OUT

      CLC
      JMP    SHORT STORE_VEGE

IN_OUT:
      INC    DI        ; SKIP FIRST CHAR
      DEC    CX

      MOV    AL,'.'
      REPNZ  SCASB
      JNZ    PONTHIBA

      CMP    ES:[DI],AL
      JNZ    PONTHIBA

      CMP    CL,1
      JLE    PONTHIBA

      CLC
      JMP    SHORT STORE_VEGE

PONTHIBA:
      MOV    CS:[HIBAHELY],DI
      MOV     BYTE PTR CS:[ERRORCODE],07
      STC

STORE_VEGE:
      POP    CX
      POP    DI
      POP    SI
      POP    ES
      POP    DS
      RET

; ****************************************************************************

SCAN_STR:

      PUSH   BX
      PUSH   CX
      PUSH   SI
      PUSH   DI
      PUSH   DS

      MOV    DI,BX
      XOR    BX,BX
      XOR    CX,CX
      MOV    CL,CS:LENGTH1

IFDEF DEBUG

      PUSH   CS
      POP    DS
      MOV    SI,OFFSET TOM

ELSE

      LDS    SI,VARST  ; PASCAL TOMB

ENDIF

KOVI: LODSB
      CMP    AL,CL     ; A HOSSZ BYTE OK ?
      JZ     LEN_OK    ; IGEN, OSSZEHASONLITJUK A STRINGEKET

TNEXT:INC    BX
      DEC    SI

IFDEF DEBUG
      CMP    BL,07
ELSE
      CMP    BL,VARNUM ; PASCAL PARAMETER = A VALTOZOK SZAMA (DEBUG ! = 7)
ENDIF
      JZ     KESZ      ; UTOLSO VOLT

CIKI:
      MOV    AX,VARSTLEN ; 21 MERT ARRAY OF STRING[20]
      ADD    SI,AX       ; A KOVETKEZO ELEM
      JMP    SHORT KOVI

LEN_OK:

      PUSH   SI
      PUSH   DI
      PUSH   CX

      REPZ   CMPSB
      JZ     MEGTALALT

      POP    CX
      POP    DI
      POP    SI

      INC    BX
      DEC    SI
      JMP    SHORT CIKI

MEGTALALT:
      POP    CX
      POP    DI
      POP    SI

      INC    BYTE PTR CS:[COUNT]
      MOV    BYTE PTR CS:[NUM],BL
      CLC
      JMP    SHORT MEGVOLT

KESZ: MOV    BYTE PTR CS:[ERRORCODE],02 ; UNKNOWN IDENTIFIER
      STC

MEGVOLT:
      POP    DS
      POP    DI
      POP    SI
      POP    CX
      POP    BX
      RET

; ****************************************************************************

NEXT_POS:

      PUSH   AX
      PUSH   BX
      PUSH   CX
      PUSH   DX
      PUSH   DS
      PUSH   SI

      MOV    BYTE PTR CS:[PEQ],00

      CMP    BYTE PTR CS:[LEVEL],00
      JZ     NULL

      MOV    AL,")"
      REPNZ  SCASB
      JNZ    ERROR1        ; NYITVA VAN, DE NINCS BEZARO JEL

      DEC    DI            ; BEZARO JEL POZICIO
      MOV    CS:[BEZAR],DI ; ELMENTESE
      SUB    DI,BX         ; TAVOLSAGA A STRING ELEJETOL
      MOV    CX,DI         ; CSAK EDDIG KELL KERESNI
      MOV    DX,CX         ; CX MENTES
      MOV    DI,BX         ; EZ A STRING ELEJE
      JMP    SHORT NULL

ERROR1:
      MOV    CS:[ERRORCODE],01   ; MISSING ")"
      STC
      JMP    EXIT

ERROR4:
      MOV    CS:[ERRORCODE],04   ; MISSING OPERATOR
      STC
      JMP    EXIT

NULL: MOV    AL,"<"
      REPNZ  SCASB
      JNZ    NEXT1

      MOV    CS:[ELSO],DI

      MOV    AL,"="
      SCASB
      JNZ    NOEQ1

      MOV    CS:[PEQ],01
      JMP    SHORT NOEQ

NOEQ1:INC    CX     ; EGYET VISSZA
      DEC    DI
      MOV    AL,">"
      SCASB
      JNZ    NOGR

      MOV    CS:[PEQ],06
      JMP    SHORT NOEQ

NOGR: DEC    DI
NOEQ: MOV    AL,01    ; "<" KODJA
      JMP    SHORT OK

NEXT1:MOV    CX,DX
      MOV    DI,BX
      MOV    AL,">"
      REPNZ  SCASB
      JNZ    NEXT2

      MOV    CS:[ELSO],DI

      MOV    AL,"="
      SCASB
      JNZ    NOEQ2

      MOV    CS:[PEQ],01
      INC    DI

NOEQ2:DEC    DI
      MOV    AL,05    ; ">" KODJA
      JMP    SHORT OK

NEXT2:MOV    CX,DX
      MOV    DI,BX
      MOV    AL,"="
      REPNZ  SCASB
      JNZ    NEXT3

      MOV    CS:[ELSO],DI

      MOV    AL,00    ; "=" KODJA
      JMP    SHORT OK

NEXT3:MOV    CX,DX
      MOV    DI,BX
      MOV    AL," "
      REPNZ  SCASB
      JNZ    ERROR4   ; NINCS "<"  ">"  "="  " " : ERROR

      MOV    CS:[ELSO],DI

      CMP    ES:[DI],AL  ; VAN MEG SPACE ?
      JNZ    NINCS_SP

      REPZ   SCASB
      DEC    DI

NINCS_SP:
      PUSH   CS
      POP    DS

      XOR    CX,CX
      XOR    AX,AX

      MOV    SI,OFFSET IN_STR ; "IN"
      LODSB
      DEC    AL
      DEC    AL
      MOV    CL,AL
      REPZ   CMPSB
      JZ     OKIN

      SUB    AX,CX                    ; AZ "IN" VIZSGALATNAL ENNYIT MENT ELORE
      SUB    DI,AX                    ; UGYANANNYIT VISSZA
      MOV    SI,OFFSET OUT_STR ; "OUT"
      LODSB
      DEC    AL
      DEC    AL
      MOV    CL,AL
      REPZ   CMPSB
      JZ     OKOUT

      JMP    ERROR4    ; NINCS "IN"  "OUT" : ERROR

OKIN: MOV    AL,03    ; "IN" KODJA
      JMP    SHORT OK

OKOUT:MOV    AL,04    ; "OUT" KODJA

OK:   MOV    BX,CS:[ELSO]   ; AZ ELSO STRING UTANI BYTE
      DEC    BX             ; SCASB VOLT - VISSZA
      POP    SI             ; SI A STACKROL
      PUSH   SI             ; VISSZARAKVA

DLOOP:DEC    BX             ; VISSZAMEGY AZ ELSO STRING UTANI SPACE-KEN
      CMP    BYTE PTR ES:[BX]," "
      JZ     DLOOP

      INC    BX             ; A HOSSZ = AZ UTANA KOVETKEZO POZICIO - AZ ELSO POZICIO
      SUB    BX,SI          ; AZ ELSO STRING HOSSZA
      MOV    CS:[LENGTH1],BL

      ADD    AL,CS:[PEQ]   ; PLUSZ "=" : "<=" VAGY ">="
      MOV    CS:[KOD],AL

      MOV    AL," "
      CMP    ES:[DI],AL
      JNZ    NVEGE

      MOV    CX,CS:[BEZAR]
      SUB    CX,DI         ; CSAK A BEZARO JELIG
      REPZ   SCASB         ; ATUGRIK A MASODIK PARAMETER ELOTTI SPACE-KEN
      DEC    DI

NVEGE:MOV    BX,CS:[BEZAR]

DLOOP2:
      DEC    BX             ; VISSZAMEGY A MASODIK STRING UTANI SPACE-KEN
      CMP    BYTE PTR ES:[BX]," "
      JZ     DLOOP2

      INC    BX             ; A HOSSZ = AZ UTANA KOVETKEZO POZICIO - AZ ELSO POZICIO
      SUB    BX,DI
      MOV    CS:[LENGTH2],BL

      CLC

EXIT: MOV CS:[HIBAHELY],DI

      POP    SI
      POP    DS
      POP    DX
      POP    CX
      POP    BX
      POP    AX
      RET

; ****************************************************************************

IFDEF DEBUG

DEB_VARI  DB STNUM*VARIALEN DUP(0AAH)

TOM       DB 5,"VAROS               "   ; DEBUG !
          DB 2,"NA                  "
          DB 3,"NEM                 "
          DB 4,"NEVE                "
          DB 3,"NEV                 "
          DB 3,"CIM                 "
          DB 5,"UTCA                "
          DB 0,"                    "
          DB 0,"                    "
          DB 0,"                    "
          DB 0,"                    "
          DB 0,"                    "
          DB 0,"                    "
          DB 0,"                    "
          DB 0,"                    "
          DB 0,"                    "

DEB_STR   DB 16 DUP ("*")

STRING    DB OFFSET NUM - OFFSET STRING - 2
          DB "((NEV = KOVACS) AND NOT(CIM <> BP))",00

ENDIF

CONDIOFS  DW 00
HIBAHELY  DW 00

NUM       DB 00
COUNT     DB 00
VANCONDI  DB 00
OPERATOR  DB 00
NOTOPER   DB 00
O_NOTOPER DB 00

POINTER   DW 00

KOD       DB 00
PEQ       DB 00
ERRORCODE DB 00
LEVEL     DB 00
OLEVEL    DB 00
DIST      DB 00
ELSO      DW 00
BEZAR     DW 00
LENGTH1   DB 00
LENGTH2   DB 00
NCOUNT    DB 00

IN_STR   DB OFFSET OUT_STR  - OFFSET IN_STR,  "IN", 4
OUT_STR  DB OFFSET AND_STR  - OFFSET OUT_STR, "OUT",5

AND_STR  DB OFFSET OR_STR  - OFFSET AND_STR,  "AND",1
OR_STR   DB OFFSET XOR_STR - OFFSET OR_STR,   "OR", 2
XOR_STR  DB OFFSET NOT_STR - OFFSET XOR_STR,  "XOR",3
NOT_STR  DB OFFSET END_STR - OFFSET NOT_STR,  "NOT",7
END_STR  DB 00

END
