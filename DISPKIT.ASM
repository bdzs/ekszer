Title   Video rutinok Turbo Pascal 4.0 hoz

         col       equ 0B800H
         mon       equ 0B000H


CODE  SEGMENT WORD PUBLIC

         ASSUME  CS:CODE

         PUBLIC       SET_STRING
         PUBLIC       GET_STRING
         PUBLIC       DISPLAY
         PUBLIC       DISPCH
         PUBLIC       ATTRIBCH
         PUBLIC       ATTRIBUTE
         PUBLIC       VERT_MODE
         PUBLIC       SCREEN_STEP
         PUBLIC       STRING_STEP
         PUBLIC       STR_HOSSZ

WRITE_STR PROC NEAR

         OR        CX,CX
         JZ        READY1

RETR1:   IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01
         JNZ       RETR1
         CLI                           ;DISABLE INTERRUPTS
WAIT1:   IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01
         JZ        WAIT1
         MOVSB
         LOOP RETR1

READY1:  RET

WRITE_STR ENDP



SET_STRV PROC NEAR

         MOV       CL,CS:[Str_Hossz]
         DEC       SI

         SHR       CX,1
         OR        CX,CX
         JZ        READY8

RETR8:   IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01
         JNZ       RETR8
         CLI                           ;DISABLE INTERRUPTS
WAIT8:   IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01
         JZ        WAIT8
         MOVSW

         DEC       SI
         DEC       SI
         DEC       DI
         DEC       DI

         ADD       DI,CS:[SCREEN_STEP]
         ADD       SI,CS:[STRING_STEP]

         LOOP RETR8

READY8:  RET

SET_STRV ENDP

GET_STRV PROC NEAR

         MOV       CL,CS:[Str_Hossz]
         DEC       DI

         SHR       CX,1
         OR        CX,CX
         JZ        READY9

RETR9:   IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01
         JNZ       RETR9
         CLI                           ;DISABLE INTERRUPTS
WAIT9:   IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01
         JZ        WAIT9
         MOVSW

         DEC       SI
         DEC       SI
         DEC       DI
         DEC       DI

         ADD       DI,CS:[STRING_STEP]
         ADD       SI,CS:[SCREEN_STEP]

         LOOP RETR9

READY9:  RET

GET_STRV ENDP



SET_STRING  PROC  FAR


         PUSH      bp
         MOV       bp,sp
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       AX,[BP+08H]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET

         MOV       DI,[BP+06H]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         LDS       SI,[BP+0AH]          ; GET OFFSET OF STRING
         XOR       CX,CX
         MOV       CL,[DS:SI]
         INC       SI

         mov       BX,0040H
         mov       ES,BX
         MUL       WORD PTR ES:[4AH]
         ADD       DI,AX
         SHL       DI,1

         MOV       DX,ES:[63H]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10H]
         AND       BX,0030H
         CMP       BX,+30H
         JNZ       COLOR1
         MOV       AX,mon

COLOR1:  MOV       ES,AX


         CMP      CS:[VERT_MODE],1
         JZ       VertSet
         CALL     WRITE_STR
         JMP      SHORT NemVset
VertSet:
         CALL     SET_STRV
NemVset:

         pop      es
         pop      ds
         pop      si
         pop      di
         pop      bp

         RET      08

SET_STRING  ENDP


GET_STRING  PROC  FAR


         PUSH      bp
         MOV       bp,sp
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       AX,[BP+08H]          ; load ROW
         DEC       AX                   ; ADJUST ROW OFFSET

         MOV       SI,[BP+06H]          ; load COL
         DEC       SI                   ; ADJUST COL. OFFSET

         LES       DI,[BP+0AH]          ; GET OFFSET OF STRING
         PUSH      ES

         XOR       CX,CX
         MOV       CL,ES:[DI]
         INC       DI

         mov       BX,0040H
         mov       ES,BX
         MUL       WORD PTR ES:[4AH]
         ADD       SI,AX
         SHL       SI,1
         MOV       DX,ES:[63H]
         ADD       DX,+06H
         MOV       AX,col
         MOV       BX,ES:[10H]
         AND       BX,0030H
         CMP       BX,+30H
         JNZ       COLOR5
         MOV       AX,mon

COLOR5:  MOV       DS,AX
         POP       ES

         CMP      CS:[VERT_MODE],1
         JZ       VertGet
         CALL     WRITE_STR
         JMP      SHORT NemVget
VertGet:
         CALL     GET_STRV
NemVget:

         pop      es
         pop      ds
         pop      si
         pop      di
         pop      bp

         RET      08

GET_STRING  ENDP



DISPLAY  PROC FAR

         PUSH      bp
         MOV       bp,sp
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       DI,[BP+06H]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         MOV       AX,[BP+08H]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET
         PUSH      AX

         LDS       SI,[BP+0AH]          ; GET OFFSET OF STRING
         LODSB

         MOV       CL,AL
         XOR       CH,CH               ; SET CH TO ZERO

         POP       AX
         OR        CL,CL
         JZ        READY               ; IF LENGTH =ZERO EXIT

         mov       BX,0040H
         mov       ES,BX
         MUL       WORD PTR ES:[4AH]
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63H]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10H]
         AND       BX,0030H
         CMP       BX,+30H
         JNZ       COLOR
         MOV       AX,mon
COLOR:   MOV       ES,AX

RETR:    IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01H
         JNZ       RETR
         CLI                           ;DISABLE INTERRUPTS
WAIT:    IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01H
         JZ        WAIT
         MOVSB
         INC       DI                  ;SKIP ATTRIBCH BYTE
         LOOP      RETR

Ready:   pop      es
         pop      ds
         pop      si
         pop      di
         pop      bp

         RET      08H

DISPLAY  ENDP


dispch   PROC FAR

         PUSH      bp
         MOV       bp,sp
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       DI,[BP+06H]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         MOV       AX,[BP+08H]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET

         PUSH      SS
         POP       DS

         MOV       SI,BP
         ADD       SI,0AH

         mov       BX,0040H
         mov       ES,BX
         MUL       WORD PTR ES:[4AH]
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63H]
         ADD       DX,+06H
         MOV       AX,col
         MOV       BX,ES:[10H]
         AND       BX,0030H
         CMP       BX,+30H
         JNZ       COLOR2
         MOV       AX,mon
COLOR2:  MOV       ES,AX

RETR2:   IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01H
         JNZ       RETR2
         CLI                           ;DISABLE INTERRUPTS
WAIT2:   IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01H
         JZ        WAIT2
         MOVSB

         pop      es
         pop      ds
         pop      si
         pop      di
         pop      bp

         RET      06H

DISPCH   ENDP


ATTRIBCH  PROC FAR

         PUSH      bp
         MOV       bp,sp
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       DI,[BP+06H]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         MOV       AX,[BP+08H]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET

         PUSH      SS
         POP       DS

         MOV       SI,BP
         ADD       SI,0AH

         mov       BX,0040H
         mov       ES,BX
         MUL       WORD PTR ES:[4AH]
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63H]
         ADD       DX,+06H
         MOV       AX,col
         MOV       BX,ES:[10H]
         AND       BX,0030H
         CMP       BX,+30H
         JNZ       COLOR4
         MOV       AX,mon
COLOR4:  MOV       ES,AX

RETR4:   IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01H
         JNZ       RETR4
         CLI                           ;DISABLE INTERRUPTS
WAIT4:   IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01H
         JZ        WAIT4
         INC       DI
         MOVSB

         pop      es
         pop      ds
         pop      si
         pop      di
         pop      bp

         RET      06H

ATTRIBCH  ENDP


ATTRIBUTE PROC FAR

         PUSH      bp
         MOV       bp,sp
         CLD

         push      di
         push      si
         push      ds
         push      es

         XOR       AX,AX
         MOV       AL,[BP+06H]          ; ATTRIB
         PUSH      AX

         MOV       DI,[BP+0CH]          ; X1
         DEC       DI

         MOV       AX,[BP+0EH]         ; Y1
         DEC       AX

         MOV       SI,[BP+08H]          ; X2

         MOV       BX,[BP+0AH]          ; Y2


         SUB       BX,AX               ; VERTICAL LENGTH

         MOV       CX,SI               ; HORIZONTAL LENGTH
         SUB       CX,DI

         MOV       SI,CX               ; SAVE LENGTH TO SI

         PUSH      BX

         mov       BX,0040H
         mov       ES,BX
         MOV       BP, ES:[04AH]
         MUL       BP
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63H]
         ADD       DX,+06H
         MOV       AX,col
         MOV       BX,ES:[10H]
         AND       BX,0030H
         CMP       BX,+30H
         JNZ       COLOR3
         MOV       AX,mon
COLOR3:  MOV       ES,AX

         POP       BX
         ADD       BP,BP

         CMP       CL,0H
         JZ        READY3         ; IF LENGTH =ZERO EXIT

RETR3:   IN        AL,DX         ;CATCH VERTICAL RETRACE
         TEST      AL,01H
         JNZ       RETR3
         CLI                     ;DISABLE INTERRUPTS
WAIT3:   IN        AL,DX         ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01H
         JZ        WAIT3
         POP       AX
         INC       DI            ;SKIP CODE BYTE
         STOSB
         PUSH      AX
         LOOP      RETR3
         DEC       BX
         JZ        READY3

         SUB       DI,SI     ; DI = DI - LENGTH
         SUB       DI,SI
         ADD       DI,BP
         MOV       CX,SI     ; RESTORE LENGTH VALUE
         JMP       RETR3

Ready3:  POP      AX
         pop      es
         pop      ds
         pop      si
         pop      di
         pop      bp

         RET      0AH

ATTRIBUTE  ENDP


VERT_MODE    DB    0
SCREEN_STEP  DW  160
STRING_STEP  DW    2
Str_Hossz    DB    0

CODE  ENDS

END


