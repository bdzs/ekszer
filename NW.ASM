; .MODEL TPASCAL
; .CODE


.RADIX 16


EXTRN PRINT: FAR

CODE SEGMENT
ASSUME CS:CODE,DS:CODE,ES:CODE

PUSH_ALL MACRO

   PUSH    AX
   PUSH    BX
   PUSH    CX
   PUSH    DX
   PUSH    SI
   PUSH    DI
   PUSH    DS
   PUSH    ES
   PUSHF

ENDM


POP_ALL MACRO

   POPF
   POP     ES
   POP     DS
   POP     DI
   POP     SI
   POP     DX
   POP     CX
   POP     BX
   POP     AX

ENDM

PUBLIC    WRITEOFF,WRITEON,STRLEN,INVIDEOFLAG

WRITEOFF PROC FAR

          PUSH_ALL

          XOR      AX,AX
          MOV      DS,AX

          PUSH     CS
          POP      ES

          MOV      SI,04*10
          MOV      DI,OFFSET JUMP

          CLD
          MOV      CX,02
          REPZ     MOVSW

          PUSH     DS
          POP      ES

          MOV      DI,04*10
          MOV      AX,OFFSET NEWINT10
          CLI
          STOSW
          MOV      AX,CS
          STOSW
          STI

          MOV      DX,OFFSET WSTRING
          MOV      CS:[STRCIM],DX

          POP_ALL

          PUSH     AX
          MOV      AX,DS
          MOV      CS:[DSVALUE],AX
          POP      AX

          RET

WRITEOFF  ENDP

WRITEON PROC FAR

          PUSH_ALL

          XOR      AX,AX
          MOV      ES,AX

          PUSH     CS
          POP      DS

          MOV      DI,04*10
          MOV      SI,OFFSET JUMP

          LODSW
          MOV      BX,AX
          LODSW
          ADD      AX,BX
          OR       AX,AX
          JZ       KILEP

          DEC      SI
          DEC      SI
          DEC      SI
          DEC      SI

          CLD
          MOV      CX,02
          CLI
          REPZ     MOVSW
          STI

KILEP:    POP_ALL
          RET

WRITEON   ENDP

DSVALUE   DW       0000
STRCIM    DW       0000
INVIDEOFLAG DB     00

STRLEN    DB       00
WSTRING   DB       200 DUP(00)

NEWINT10: CMP      AH,02
          JZ       GOTOXY

          CMP      AH,09
          JZ       OK
          CMP      AH,0AH
          JZ       OK
          CMP      AH,0EH ; TELETYPE
          JNZ      VEGE

OK:       PUSH_ALL

          CMP      AH,0EH
          JNZ      NOTELETYPE

          MOV      CX,01

NOTELETYPE:

          PUSH     CS
          POP      ES

          MOV      DI,CS:[STRCIM]

FLOOP:    CMP      DI,OFFSET NEWINT10
          JAE      READY

          STOSB
          DEC      CX
          JCXZ     READY
          JMP      SHORT FLOOP

READY:    MOV      CS:[STRCIM],DI

          JMP      SHORT KESZ

GOTOXY:   CMP      BYTE PTR CS:[INVIDEOFLAG],00
          JZ       VEGE

          OR       DL,DL
          JNZ      KISZALL

          PUSH_ALL

          MOV      AX,CS:[STRCIM]

          MOV      DX,OFFSET WSTRING
          MOV      CS:[STRCIM],DX

          SUB      AX,DX

          MOV      CS:[STRLEN],AL

          MOV      AX,CS:[DSVALUE]
          MOV      DS,AX

          CALL     PRINT

KESZ:     POP_ALL

KISZALL:  IRET

VEGE:     DB 00EA

JUMP:     DW 00
          DW 00

CODE ENDS

END
