
CODE SEGMENT

        ASSUME CS:CODE 
        
        CALL NEXT
NEXT:   POP  DI        
        PUSH DS
        PUSH ES
        MOV  AX,CS
        MOV  DS,AX
        MOV  ES,AX
        SUB  DI,0FH
        MOV  SI,DI
        ADD  SI,04
FLOOP:  CMP  BYTE PTR [DI],9AH
        JNZ  EXIT
        SUB  DI,05
        JMP  SHORT FLOOP
EXIT:   ADD  DI,05
        MOV  CX,SI
        SUB  CX,DI
        INC  CX
        ADD  SI,08
        CLD
        REPZ MOVSB
        POP  ES
        POP  DS
        
CODE ENDS

END
        