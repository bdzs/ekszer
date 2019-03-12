
Type
     tt   = Array[0..$1FF] Of Byte;
     ttt  =^tt;

Var
   ize : tt;
   ii  : ttt;
   ff  : File of tt;

Function Check(Po:ttt):Word;
Var Cikl   : Word;
    NewChk : Word;
Begin
  NewChk := 33335;
  For Cikl := 0 To $1FF Do
    Begin
      NewChk := Swap(NewChk);
      NewChk := NewChk Xor po^[Cikl];
      Inc(NewChk,po^[Cikl])
    End;
  Check := NewChk;
End;

Begin
  Assign(ff,ParamStr(1));
  {$I-}
  Reset(ff);
  {$I+}
  If IoResult = 0 Then
    Begin
      read(ff,ize);
      close(ff);
      ii := @ize;
      writeln(check(ii));
    End
End.