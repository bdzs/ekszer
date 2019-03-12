Title   Video rutinok Turbo Pascal 4.0 hoz

;   ****************************************************************
;   *  A billentyuzet javito rutinok kiszedve !!! keresd a @@@ - t *
;   ****************************************************************
;
;   XT - AT vizsgalat :       1989.04.01  D.A.
;  ChangeLineFont kijavitva : 1990.05.08  D.A.

         col       equ 0B800H
         mon       equ 0B000H

.radix 16

CODE  SEGMENT WORD PUBLIC

         ASSUME  CS:CODE

         PUBLIC       SET_STRING
         PUBLIC       GET_STRING
         PUBLIC       DISPLAY
         PUBLIC       DISPCH
         PUBLIC       ATTRIBCH
         PUBLIC       ATTRIBUTE

;         PUBLIC       XT_AT

         Public       ChangeLineFont
;         Public       Set_Int_A0

;        Public       Int9_Kifuz

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


SET_STRING  PROC  FAR


         PUSH      bp
         MOV       bp,sp
         PushF

         CLD


         push      di
         push      si
         push      ds
         push      es

         MOV       AX,[BP+08]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET

         MOV       DI,[BP+06]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         LDS       SI,[BP+0A]          ; GET OFFSET OF STRING
         XOR       CX,CX
         MOV       CL,[DS:SI]
         INC       SI

         mov       BX,0040
         mov       ES,BX
         MUL       WORD PTR ES:[4A]
         ADD       DI,AX
         SHL       DI,1

         MOV       DX,ES:[63]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10h]
         AND       BX,0030
         CMP       BX,+30
         JNZ       COLOR1
         MOV       AX,mon

COLOR1:  MOV       ES,AX

         CALL     WRITE_STR

         pop      es
         pop      ds
         pop      si
         pop      di
         popf
         pop      bp

         RET      08

SET_STRING  ENDP


GET_STRING  PROC  FAR


         PUSH      bp
         MOV       bp,sp
         pushf
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       AX,[BP+08]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET

         MOV       SI,[BP+06]          ; load COL
         DEC       SI                  ; ADJUST COL. OFFSET

         LES       DI,[BP+0A]          ; GET OFFSET OF STRING
         PUSH      ES

         XOR       CX,CX
         MOV       CL,[ES:DI]
         INC       DI

         mov       BX,0040
         mov       ES,BX
         MUL       WORD PTR ES:[4A]
         ADD       SI,AX
         SHL       SI,1
         MOV       DX,ES:[63]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10h]
         AND       BX,0030
         CMP       BX,+30
         JNZ       COLOR5
         MOV       AX,mon

COLOR5:  MOV       DS,AX
         POP       ES

         CALL     WRITE_STR

         pop      es
         pop      ds
         pop      si
         pop      di
         popf
         pop      bp

         RET      08

GET_STRING  ENDP



DISPLAY  PROC FAR

         PUSH      bp
         MOV       bp,sp
         PushF
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       DI,[BP+06]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         MOV       AX,[BP+08]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET
         PUSH      AX

         LDS       SI,[BP+0A]          ; GET OFFSET OF STRING
         LODSB

         MOV       CL,AL
         XOR       CH,CH               ; SET CH TO ZERO

         POP       AX
         OR        CL,CL
         JZ        READY               ; IF LENGTH =ZERO EXIT

         mov       BX,0040
         mov       ES,BX
         MUL       WORD PTR ES:[4A]
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10h]
         AND       BX,0030
         CMP       BX,+30
         JNZ       COLOR
         MOV       AX,mon
COLOR:   MOV       ES,AX

RETR:    IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01
         JNZ       RETR
         CLI                           ;DISABLE INTERRUPTS
WAIT:    IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01
         JZ        WAIT
         MOVSB
         INC       DI                  ;SKIP ATTRIBCH BYTE
         LOOP      RETR

Ready:   pop      es
         pop      ds
         pop      si
         pop      di
         popf
         pop      bp

         RET      08

DISPLAY  ENDP


dispch   PROC FAR

         PUSH      bp
         MOV       bp,sp
         pushF
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       DI,[BP+06]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         MOV       AX,[BP+08]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET

         PUSH      SS
         POP       DS

         MOV       SI,BP
         ADD       SI,0A

         mov       BX,0040
         mov       ES,BX
         MUL       WORD PTR ES:[4A]
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10h]
         AND       BX,0030
         CMP       BX,+30
         JNZ       COLOR2
         MOV       AX,mon
COLOR2:  MOV       ES,AX

RETR2:   IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01
         JNZ       RETR2
         CLI                           ;DISABLE INTERRUPTS
WAIT2:   IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01
         JZ        WAIT2
         MOVSB

         pop      es
         pop      ds
         pop      si
         pop      di
         popf
         pop      bp

         RET      06

DISPCH   ENDP


ATTRIBCH  PROC FAR

         PUSH      bp
         MOV       bp,sp
         pushf
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       DI,[BP+06]          ; load COL
         DEC       DI                  ; ADJUST COL. OFFSET

         MOV       AX,[BP+08]          ; load ROW
         DEC       AX                  ; ADJUST ROW OFFSET

         PUSH      SS
         POP       DS

         MOV       SI,BP
         ADD       SI,0A

         mov       BX,0040
         mov       ES,BX
         MUL       WORD PTR ES:[4A]
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10h]
         AND       BX,0030
         CMP       BX,+30
         JNZ       COLOR4
         MOV       AX,mon
COLOR4:  MOV       ES,AX

RETR4:   IN        AL,DX               ;CATCH VERTICAL RETRACE
         TEST      AL,01
         JNZ       RETR4
         CLI                           ;DISABLE INTERRUPTS
WAIT4:   IN        AL,DX               ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01
         JZ        WAIT4
         INC       DI
         MOVSB

         pop      es
         pop      ds
         pop      si
         pop      di
         popf
         pop      bp

         RET      06

ATTRIBCH  ENDP


ATTRIBUTE PROC FAR

         PUSH      bp
         MOV       bp,sp
         pushf
         CLD

         push      di
         push      si
         push      ds
         push      es

         XOR       AX,AX
         MOV       AL,[BP+06]          ; ATTRIB
         PUSH      AX

         MOV       DI,[BP+0CH]          ; X1
         DEC       DI

         MOV       AX,[BP+0EH]         ; Y1
         DEC       AX

         MOV       SI,[BP+08]          ; X2

         MOV       BX,[BP+0A]          ; Y2


         SUB       BX,AX               ; VERTICAL LENGTH

         MOV       CX,SI               ; HORIZONTAL LENGTH
         SUB       CX,DI

         MOV       SI,CX               ; SAVE LENGTH TO SI

         PUSH      BX

         mov       BX,0040
         mov       ES,BX
         MOV       BP, ES:[04AH]
         MUL       BP
         ADD       DI,AX
         SHL       DI,1
         MOV       DX,ES:[63]
         ADD       DX,+06
         MOV       AX,col
         MOV       BX,ES:[10h]
         AND       BX,0030
         CMP       BX,+30
         JNZ       COLOR3
         MOV       AX,mon
COLOR3:  MOV       ES,AX

         POP       BX
         ADD       BP,BP

         CMP       CL,0
         JZ        READY3         ; IF LENGTH =ZERO EXIT

RETR3:   IN        AL,DX         ;CATCH VERTICAL RETRACE
         TEST      AL,01
         JNZ       RETR3
         CLI                     ;DISABLE INTERRUPTS
WAIT3:   IN        AL,DX         ;WAIT UNTIL REFRESHING FINISHED
         TEST      AL,01
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
         popf
         pop      bp

         RET      0A

ATTRIBUTE  ENDP

ChangeLineFont  PROC FAR

         PUSH      bp
         MOV       bp,sp
         pushf
         CLD

         push      di
         push      si
         push      ds
         push      es

         MOV       AX,[BP+0C]  ; Kezd

;         OR        AX,AX
;         PUSHF

         MOV       CX,[BP+0A]  ; Vege+1
         SUB       CX,AX
         OR        CX,CX
         JZ        NemJo

         LDS       SI,[BP+0E]  ; Address of line
         LES       DI,[BP+0E]  ; Address of line

         ; ADD       SI,AX
         ; ADD       DI,AX

         MOV       AH,[BP+06]  ; New Font
         MOV       BL,[BP+08]  ; Old Font

;         POPF                  ; Kezd = 0 ?
;         JNZ       Cik         ; Nem

Cik:     LODSB
         MOV       BH,AL       ; A felso 4 bit elmentese BH-ba
         AND       BH,00F0

         AND       AL,0F       ; Csak a Font

         CMP       AL,BL       ; Attrib = OldFont ?
         JNZ       NoChange    ; Nem

         MOV       AL,AH
         OR        AL,BH       ; A felso 4 bit visszamentese
;         Jmp       Short Store
;
;Cik:     LODSB             ; { Ez a regi Cik }
;         CMP       AL,BL       ; Attrib = OldFont ?
;         JNZ       NoChange    ; Nem
;
;         MOV       AL,AH

Store:   STOSB
         Loop      Cik

         JMP       SHORT NemJo

NoChange:
         INC       DI
         Loop      Cik

NemJo:   pop      es
         pop      ds
         pop      si
         pop      di
         popf
         pop      bp

         RET      0C

ChangeLineFont  ENDP

;XT_AT PROC FAR
;
;         PUSH      BP
;         MOV       BP,SP
;         PUSH   AX
;
;         MOV    AX,SP
;         DB     60     ; PUSHA
;         CMP    AX,SP
;         JZ     XT
;         DB     61     ; POPA
;         JMP    SHORT AT
;XT:      XOR    AX,AX
;         JMP    SHORT STORE1
;AT:      MOV    AX,01
;
;STORE1:  MOV    [BP+06],AX
;
;         POP    AX
;         POP    BP
;
;         RET    02
;
;XT_AT ENDP

;Set_Int_A0 PROC FAR
;
;         PUSH    DS
;         PUSH    ES
;
;         PUSH    CS
;         POP     DS
;         MOV     DX,OFFSET INT_A0
;         MOV     AX,25A0
;         INT     21
;
; ;        mov al,9              ; @@@
; ;        mov ah,35h
; ;        int 21h ; es:bx-ben vektor
; ;        mov ds:[int9cim], bx
; ;        mov ds:[int9cim2], es
;
; ;        mov dx, offset int9rutin   ; @@@
; ;        mov al,9 ; vektor num.
; ;        mov ah,25h ; set vektor
; ;        int 21h
;
;; befuz int 8be
;
;;               mov al,8    ; @@@
;;		mov ah,35h
;;               int 21h ; es:bx-ben vektor
;;               mov ds:[int8cim], bx
;;		mov ds:[int8cim2], es
;
;;         mov dx, offset int8rutin  ; @@@
;;         mov al,8 ; vektor num.
;;         mov ah,25h ; set vektor
;;         int 21h
;
;         POP     ES
;         POP     DS
;         RET
;
;Set_Int_A0 ENDP
;
;Int_A0 PROC FAR
;
;         PUSH    BP
;         PUSH    BX
;
;         NOP     ; EB   = JMP SHORT NO_MASK
;         NOP     ; 19
;
;         CMP     AL,8Dh
;         JG      NO_MASK
;
;         MOV     BL,AL
;         AND     AL,7Fh
;         CMP     BL,AL
;         JZ      NO_MASK
;
;         CMP     AL,0Dh
;         JNZ     NO_CR
;
;         PUSH    AX
;         PUSH    DS
;
;         XOR     AX,AX           ; WordStar soft CR (8Dh)
;         MOV     DS,AX
;         INC     AL
;         MOV     DS:[03F5],AL
;
;         POP     DS
;         POP     AX
;
;NO_MASK: CMP     AL,0Dh
;
;NO_CR:   PUSHF
;         POP     BX
;
;         MOV     BP,SP
;         MOV     [BP+08],BX
;
;         POP     BX
;         POP     BP
;
;         IRET
;
;Int_A0 ENDP

;Int9_Kifuz PROC FAR
;
;           RET ; @@@
;
;           PUSH  ES
;           PUSH  DS
;
;           PUSH  CS
;           POP   DS
;           XOR   AX,AX
;           MOV   ES,AX
;           MOV   DI,4*8 ; INT 8 VECTOR
;           MOV   SI,OFFSET INT8CIM
;           CLD
;           CLI
;           MOVSW
;           MOVSW
;           MOV   SI,OFFSET INT9CIM
;           MOVSW
;           MOVSW
;           STI
;           POP   DS
;           POP   ES
;           RET
;
;Int9_Kifuz ENDP

.RADIX 10

nezni equ 16

ktabla:
alt      db 38h
ctrl     db 1dh
caps     db 3ah
;enter    db 28
esc      db 1
shift1   db 42
shift2   db 54
fkeys    db 59,60,61,62,63,64,65,66,67,68


timer    db 00

;------------------------------------------------------------------------



int8rutin proc far

             pushf

             cmp byte ptr cs:[timer],255 ; lehet novelni?
             jz int8tova                 ; nem
             inc byte ptr cs:[timer]     ; novelni

 int8tova:   popf

          db 0eah    ; jump far
 int8cim  dw 0000
 int8cim2 dw 0000

int8rutin endp
;------------------------------------------------------------------------
int9rutin proc far

          pushf
          push ax
          push bx
          push cx
          push ds

          mov ax,cs
          mov ds,ax


          in al,60h    ; mit utott le?
          test al,80h  ; elengedes?
          jnz int9tova ; mehet

;----------------------------------------------------
lenyomas:
          mov bx,offset ktabla

          mov cx,nezni         ; ennyivel egybe vetni
  l_hur:  cmp al,byte ptr [bx] ; ez volt?
          jz l_megvan
          inc bx
          loop l_hur           ; next
 l_nincs: jmp int9tova

 l_megvan: cmp byte ptr [timer],2  ; volt 2 timer?
           jb  int9ignore

 int9tova:
             mov byte ptr [timer],0
             pop ds
             pop cx
             pop bx
             pop ax
             popf

          db 0eah    ; jump far
 int9cim  dw 0000
 int9cim2 dw 0000

 int9ignore:
           in al,61h
           or al,80h
           out 61h,al
           and al,7fh
           out 61h,al
           mov al,61h
           out 20h,al   ; interruptot tudomasul vette

             pop ds
             pop cx
             pop bx
             pop ax
             popf
             sti
             iret         ; billentyut ignoralni

int9rutin endp
;-------------------------------------------------------------------

CODE  ENDS

END


