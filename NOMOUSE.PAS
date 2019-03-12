Uses Dos;
{$M 1024,0,0}

Procedure MouseInt;Interrupt;
Begin
End;


Begin
  SetIntVec($33,@MouseInt);
  Keep(0);
End.