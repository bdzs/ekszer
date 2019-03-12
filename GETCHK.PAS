Program get_chks;

Var Cikl : Integer;
    cs   : word;


Begin
  cs := 0;
  For Cikl := 0 To $1FFF Do
    Inc(Cs,Mem[$FE00:Cikl]);


  writeln(cs);
End.