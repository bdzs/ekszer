
Type
     tt   = Array[0..$1FFF] Of Byte;
     ttt  =^tt;

Function NewChkSzam(Po:ttt):Word;
Var Cikl   : Word;
    NewChk : Word;
Begin
  NewChk := 33335;
  For Cikl := 0 To $1FFF Do
    Begin
      NewChk := Swap(NewChk);
      NewChk := NewChk Xor po^[Cikl];
      Inc(NewChk,po^[Cikl])
    End;
  NewChkSzam := NewChk;
End;

Var t:TTT;
Begin
  T := Ptr($FE00,$0000);
  writeln(NewChkSzam(t));
End.

