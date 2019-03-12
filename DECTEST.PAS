Procedure CheckInterrupt;

Type
     tt   = Array[0..$200] Of Byte;
     ttt  =^tt;
Var
     Int08 : ttt Absolute $0:$08*4;
     Int6C : ttt Absolute $0:$6C*4;
     Int56 : ttt Absolute $0:$56*4;

Function ChkOk(Po:ttt;ChkSum:Word):Boolean;
Var Cikl   : Word;
    NewChk : Word;
Begin
  NewChk := 33335;
  For Cikl := 0 To 511 Do
    Begin
      NewChk := Swap(NewChk);
      NewChk := NewChk Xor po^[Cikl];
      Inc(NewChk,po^[Cikl])
    End;
  Writeln(NewChk,'   ',ChkSum);
  ChkOk := NewChk = ChkSum;
End;

Begin
  If ChkOk(Int08,28588) Then;
  If ChkOk(Int6C,23749) Then;
  If ChkOk(Int56,56922) Then;
End;

Begin
  CheckInterrupt
End.