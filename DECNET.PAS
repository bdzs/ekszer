Unit decnet;

InterFace

Procedure CheckInterrupt;

Implementation

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
  ChkOk := NewChk = ChkSum;
End;

Begin
  If Not( ChkOk(Int08,28588) And
	  ChkOk(Int6C,23749)) Then
    Inline($EA/$F0/$FF/$00/$f0)                  { JMP F000:FF00  Elszall ! }
End;
End.