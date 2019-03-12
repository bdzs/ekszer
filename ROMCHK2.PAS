Unit Romchk2;


InterFace
Uses Windowm;


Procedure RomCheck;
Procedure Fproc;
Procedure Eproc;


Implementation
Uses crt;

Const
       ChainLen = 12;

  {$IFDEF FOLDHIV}
       Entry    = 23196;
  {$ELSE}
       Entry    = 23194;
  {$ENDIF}
       {$IFDEF ANGOL}
              CFn      = 'PROTEX.IDF';
       {$ELSE}
         {$IFDEF PACKARD}
              CFn      = 'EKIDF.LST';
         {$ELSE}
              CFn      = 'EKSZER.IDF';
         {$ENDIF}
       {$ENDIF}
       NoOfWords = $8000;
       BufL      = NoOfWords Div 2;

Var
       Cs       : Word;
Type   ListT    = Array[1..200] Of Word;
       BufT     = Array[0..BufL-1] Of Word;


Procedure Fproc;
Begin
  CS := CS
End;

Procedure ChkSum;
Var Cikl   : Word;
Begin
  CS := 33335;
  For Cikl := 0 To $0FFF Do  { M r ki van jav¡tva ! }
    Begin
      CS := Swap(CS);
      CS := CS Xor Mem[$FE00:Cikl];
      Inc(CS,Mem[$FE00:Cikl])
    End;
End;

{$IFNDEF PACKARD}
Function ReadChkSumOK: Boolean;
Var   F   : File;
      Poz : Word;
      Cik : Word;
      NewCs: Word;
      XX   : Integer;
Begin
  ReadChkSumOk := False;
  Assign(F,AlapPath+CFn);

  {$I-}
  Reset(F,1);
  {$I+}

  If IoResult <> 0 Then Exit;

  Poz := Entry;

  For Cik := 1 To ChainLen+1 Do
  Begin
    {$I-}
    Seek(F,Poz);
    If IoResult <> 0 Then Exit;
    BlockRead(F,Poz,2);
    If IoResult <> 0 Then Exit;
    {$I+}
  End;


  {$I-}
  Seek(F,Poz);
  If IoResult <> 0 Then Exit;

  BlockRead(F,NewCs,2);
  If IoResult <> 0 Then Exit;
  {$I+}

  ChkSum;

  {$I-}
  Close(F);
  If IoResult <> 0 Then Exit;
  {$I+}

  {Writeln(Cs);
  Writeln(NewCs);
  If ReadKey=' ' Then;
  }

  ReadChkSumOK := (NewCs = Cs);
End;

{$ELSE}

Function ReadChkSum : Boolean;

Var   F    : File;
      Poz  : Word;
      Cik  : Word;
      Buf  : Array[0..1] Of ^BufT;
      LL   : Longint;
      WW   : Word;
      Num  : Word;
      List : ListT;

Begin
  ReadChkSum := False;
  Assign(F,AlapPath+CFn);
  {$I-}
  Reset(F,1);
  If IoResult <> 0 Then Exit;
  For Cik := 0 To 1 Do
    Begin
      New(Buf[Cik]);
      BlockRead(F,Buf[Cik]^,$8000);
      If IoResult <> 0 Then Exit;
    End;

  Close(F);
  If IoResult <> 0 Then Exit;

  Poz := Entry Div 2;

  For Cik := 1 To ChainLen Do
    Begin
      If Cik = ChainLen Then
        Num := $3456 XOR Buf[(Poz+1) Div $4000]^[(Poz+1) Mod $4000];
      Poz := Buf[Poz Div $4000]^[Poz Mod $4000] Div 2;
    End;

  For Cik := 1 To Num Do
    Begin
      List[Cik] := $3456 XOR Buf[(Poz+1) Div $4000]^[(Poz+1) Mod $4000];
      Poz := Buf[Poz Div $4000]^[Poz Mod $4000] Div 2;
    End;

  Dispose(Buf[0]);
  Dispose(Buf[1]);

  ChkSum;

  For Cik := 1 To Num Do
    If List[Cik] = CS Then
      ReadChkSum := True;
End;

{$ENDIF}

Procedure RomCheck;


{$IFDEF VIDEOTON}
Function VanVideoton : Boolean;
Type Pr = Record
            Offset  : Word;
            Segment : Word;
          End;
Var
P    : Pointer;
Ws   : String[16];
Prec : Pr Absolute P;
Begin
  P := Ptr(MemW[0000:4*9+2],MemW[0000:4*9]);
  Dec(Prec.Offset,8);
  Move(P^,Ws[1],8);
  Ws[0] := #8;
  VanVideoton := (Ws = 'VIDEOTON');
End;
{$ENDIF}

Begin
  Fproc;
  Eproc;
  {$IFNDEF PACKARD}
  If Not ReadChkSumOk {$IFDEF VIDEOTON} OR Not VanVideoton {$ENDIF} Then
    Inline($EA/$F0/$FF/$00/$f0)                  { JMP F000:FF00  Elszall ! }
  {$ELSE}
  If Not ReadChkSum Then
    Inline($EA/$F0/$FF/$00/$f0)                  { JMP F000:FF00  Elszall ! }
  {$ENDIF}
end;

Procedure Eproc;
Begin
  CS := CS
End;


End.