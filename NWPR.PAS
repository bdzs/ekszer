Uses Dos,Crt;

{$M 16000,0,0}
{$L NW.OBJ}
{$F+}

Type  SPoint = ^String;

Var   S : String;
      Pt: SPoint;

Procedure WriteOn;  External;
Procedure WriteOff; External;

Function StrLen:Byte;        External;
Function InVideoFlag:Byte;   External;

Procedure SetVideoFlag(B:Boolean);
Begin
  Pt := @InVideoFlag;
  Pt^[0] := Char(B);
End;

Procedure Print;
Var Ws : String;
    Pt : SPoint;
Begin
  Pt := @StrLen;
  Ws[0] := Char(Pt^[0]);
  Move(Pt^[1],Ws[1],Length(Ws));

  SetVideoFlag(False);

  If Length(Ws) > 59 Then Ws[0] := #59;
  GotoXY(1,1);
  Write(Ws);
  InsLine;

  SetVideoFlag(True);

End;

Begin

  ClrScr;

  TextAttr := 30;

  Window(10,12,70,19);
  ClrScr;

  WriteOff;

  SetVideoFlag(True);
  Exec('C:\UTIL\PKZIP.EXE','');
  SetVideoFlag(False);

  WriteOn;

End.
