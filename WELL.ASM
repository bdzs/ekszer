TITLE    Winchester ellenorzo program                     Darvas Akos 89.11.17

CODE    SEGMENT PARA PUBLIC

ASSUME CS:CODE

.RADIX 16

Public Well

Well PROC FAR

     Push BX
     Push CX
     Push DX
     Push DS
     Push ES
     Push DI
     Push SI

     Push CS
     Pop  ES
     Push CS
     Pop  DS

     Mov  Dx,0080
     Mov  Cx,0001
     Mov  Ax,0201

     Call Next
Next:Pop  Bx

     Add  Bx,Offset Buf - Offset Next

     Mov  Di,Bx

     Push Bx

     Int  13

     Mov  Si,Di
     Sub  Si,Offset Buf - Offset Inv
     Push Si

     Mov  Cx,08
     Mov  Di,Si
     Mov  Bl,0F8

Kc:  Lodsb
     Xor  Al,Bl
     Dec  Bl
     Stosb
     Loop Kc

     Pop  Si
     Pop  Di

     Mov  Cx,0200

     Lodsb

Cik: Repnz
     Scasb

     Jz   Megvan

Ki:  Xor  Ax,Ax
     Jmp  Short Vege

Megvan:

     Push Cx
     Push Si
     Mov  Cx,07

     Repz
     Cmpsb

     Jz   Ok

     Pop  Si
     Pop  Cx
     Jmp  Short Cik

Ok:  Pop  Si
     Pop  Cx
     Mov  Ax,0001

Vege:
     Pop  SI
     Pop  DI
     Pop  ES
     Pop  DS
     Pop  DX
     Pop  CX
     Pop  BX

     RET

Inv  DB "I" XOR 0F8
     DB "n" XOR 0F7
     DB "v" XOR 0F6
     DB "a" XOR 0F5
     DB "l" XOR 0F4
     DB "i" XOR 0F3
     DB "d" XOR 0F2
     DB 0FF XOR 0F1

Buf  DB 200 Dup(0AA)

Well ENDP


CODE   ENDS

End
