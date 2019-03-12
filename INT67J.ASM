
CODE SEGMENT

ASSUME CS:CODE,DS:CODE

INT67 PROC NEAR


	JMP SHORT NEXT
DATA    DB "        EMMXXXX0   "
NEXT:   PushF
        CMP SI,0AAAAH
        JZ   OK

        Push Cx
        pUSH Ax

        Xor  Cx,Cx
        Mov  Al,04H
        Out  42H,Al
        Xor  Al,Al

        DEC  Al
        Out  61H,Al
        Loop $
        inc  Al
        Out  61H,Al


        Xor  Cx,Cx
        Mov  Al,07H
        Out  42H,Al
        Xor  Al,Al

        dec  Al
        Out  61H,Al
        Loop $
        INC  Al
        Out  61H,Al


        POP Ax
        POP CX
OK:
        POPF
        DB 00EAH
KILEP	DW 00
        DW 00

INT67 ENDP

MAIN PROC FAR

	PUSH DS
	XOR AX,AX
	MOV DS,AX
	MOV SI,4*67H
	MOV CX,02
	CLD
	PUSH CS
	POP ES
	MOV DI,OFFSET KILEP
	REPZ MOVSW
	POP DS

	MOV AX,2567H
	PUSH CS
	POP DS
	MOV DX,OFFSET INT67
	INT 21H

	MOV AX,3100H
	MOV DX,18H
	INT 21H

MAIN ENDP

CODE ENDS

END MAIN

