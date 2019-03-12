{$M 2000,0,0}


Uses dos, printer;

Procedure Int14(Flags, CS, IP, AX, BX,
CX, DX, SI, DI, DS, ES, BP: Word);Interrupt;
Begin
  Case HI(AX) of
    3: AX := 0;
    1: Begin
         Write(lst,chr(LO(AX)));
         AX := 0
       End;
   End;
End;


Begin
  SetIntVec($14,@Int14);
  Keep(0)
End.

