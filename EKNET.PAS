Unit EKNET;

{ $DEFINE NOCDW}

Interface
Uses  Dos,crt;

Const  KodMeret =   1024;
       StartKod =     50;
       LenLanc  =     20;
       Kutya    : String[5] = 'kutya';
       {Kutya    : String[5] = '8395';}
       Jogos    : Word =  2;    { Jogosultak szama }
       CHkSzam  : Word = 59671;    { Sajat gepem }

       KodPath  : String[80] = 'P:\';
       KodName  = 'EKNET.KOD';

Type   KodArr   = Array[0..KodMeret-1] Of Byte;
       tt       = Array[0..$1FFF] Of Byte;
       ttt      = ^tt;

Var   KodFile   : File Of KodArr;
      EzAHandle : Word;
      GlobHaszn : Word;

Function  Estart:Boolean;
Procedure EEnd;
Function  ESave:Boolean;
Function  RezStart:Boolean;
Procedure RezService;


Implementation

{$IFNDEF NOCDW}
Uses MenuErr;
{$ELSE}
Procedure Error(x:Byte;S:String);
Begin
  Writeln(X:3,' ',S);
End;
{$ENDIF}

Function NewChkSzam(Po:ttt):Word;
Var Cikl   : Word;
    NewChk : Word;
Begin
  (*
  NewChk := 33335;
  For Cikl := 0 To $1FFF Do
    Begin
      NewChk := Swap(NewChk);
      NewChk := NewChk Xor po^[Cikl];
      Inc(NewChk,po^[Cikl])
    End;
  NewChkSzam := NewChk;
  *)
  NewChk := 0;
  For Cikl := 0 To $1FFF Do
    Inc(NewChk,Mem[$FE00:Cikl]);
  NewChkSzam := NewChk
End;


Procedure Dekodolo(Var Haszn,Handle,Romchk,Used:Word;Var K : KodArr);
Var Cikl : Integer;
    P    : Word;
Begin
  P := StartKod*4;

  For Cikl := 1 To LenLanc Do
    P := (K[P] Xor $34) *4;
  Haszn  := K[P+1] Xor $67;

  P := (K[P] Xor $34)*4;
  Handle := (K[P+1] Xor $23) Or (Word(K[P+3] Xor $34) Shl 8);

  P := (K[P] Xor $34)*4;
  RomChk := (K[P+1] Xor $45) Or (Word(K[P+3] Xor $56) Shl 8);

  P := (K[P] Xor $34)*4;
  Used := (K[P+1] Xor $67);
End;

Procedure Kodolo(Var Haszn,Handle,Romchk,Used:Word;Var K : KodArr);
Var Cikl : Integer;
    HH   : Array[0..(KodMeret Div 4)-1] Of Boolean;
    P,PE : Word;

Function UjSzem:Word;
Var P :Word;
Begin
  Repeat
    P := Random(256);
  Until Not(HH[P]);
  K[PE*4] := P Xor $34;
  HH[P]   := True;
  PE := P;
  UjSzem := P;
End;

Begin
  Randomize;
  FillChar(HH,SizeOf(HH),False);
  For Cikl := 0 To KodMeret-1 Do
    K[Cikl] := Random(256);

  PE := StartKod;
  HH[PE] := True;

  For Cikl := 1 To LenLanc Do
    P := UjSzem;

  K[P*4+1] := Haszn XOR $67;

  P        := UjSzem;
  K[P*4+1] := Lo(Handle) Xor $23;
  K[P*4+3] := Hi(Handle) Xor $34;

  P        := UjSzem;
  K[P*4+1] := Lo(Romchk) Xor $45;
  K[P*4+3] := Hi(Romchk) Xor $56;

  P        := UjSzem;
  K[P*4+1] := Lo(Used) Xor $67;

End;

Function GetT:LongInt;
Var X      : Longint;
    D      : DateTime;
    Sec100 : Word;
Begin
  With D Do
    Begin
      GetTime(Hour,Min,Sec,Sec100);
      GetDate(Year,Month,Day,Sec100);
    End;
  PackTime(D,X);
  GetT := X;
End;


Function WaitForRead(Var K:KodArr;TimeOut:Word):Byte;

Var DT    : DateTime;
    P1,P2 : LongInt;
    IO    : Integer;
Begin
  Assign(KodFile,KodPath+KodName);
  P1 := GetT;
  Repeat
    {$I-}
    Reset(KodFile);
    {$I+}

    IO := IOResult;
    P2 := GetT;
  Until (IO = 0) Or ((P2-P1) >= TimeOut);
  If IO = 0 Then
    Begin
      {$I-}
      Read(KodFile,K);
      {$I+}
      IO := IoResult
    End;
  WaitForRead := IO;
End;

Function WaitForReadU(Var K:KodArr;TimeOut:Word):Byte;

Var DT    : DateTime;
    P1,P2 : LongInt;
    IO    : Integer;
    Haszn,Handle,Romchk,Used : Word;

Begin
  Assign(KodFile,KodPath+KodName);
  P1 := GetT;
  Repeat
    {$I-}
    Reset(KodFile);
    {$I+}
    IO := IOResult;
    If IO = 0 Then
      Begin
        {$I-}
        Read(KodFile,K);
        IO := IoResult;
        {$I+}

        Dekodolo(Haszn,Handle,Romchk,Used,K);
        IO := (IoResult Or IO) Or (Used Xor 1);
        If IO <> 0 Then
          Begin
            {$I-}
            Close(KodFile);
            {$I+}
            IO := IOResult;
            IO := 22;
            Delay(TimeOut*200);
          End;
      End
    Else
      Delay(TimeOut*200);
    P2 := GetT;
  Until (IO = 0) Or ((P2-P1) >= TimeOut);
  WaitForReadU := IO;
End;

Function EStart:Boolean;
Var K  : KodArr;
    IO : Byte;
    EE : Integer;
    Haszn,Haszn2,Handle,Romchk,Used : Word;
Begin
  Estart := False;
  Val(Kutya,ChkSzam,EE);

  IO := WaitForReadU(K,20);

  If IO = 0 Then
    Begin
      Dekodolo(Haszn,Handle,Romchk,Used,K);
      If RomChk = ChkSzam Then
        If Haszn < Jogos Then
          Begin
            {$I-}
            Close(KodFile);
            IO := IoResult;
            Erase(KodFile);
            {$I+}
            IO := IOResult Or IO;
            If IO = 0 Then
              Begin
                IO := WaitForReadU(K,20);
                If IO = 0 Then
                  Begin
                    Dekodolo(Haszn2,Handle,Romchk,Used,K);
                    If (Haszn2 = (Haszn+1)) Then
                      If (RomChk = ChkSzam) Then
                        Begin
                          EzAHandle := Handle;
                          GlobHaszn := Haszn2;
                          Estart := True;
                        End
                      Else
                        Error(43,' /6')
                    Else
                      Error(43,' /5')
                  End
                Else
                  Error(43,' /4');
              End
            Else
              Error(43,' /3');
          End
        Else
          Error(45,'')
      Else
        Error(43,' /2');
    End
  Else
    Error(43,' /1');

  {$I-}
  Close(KodFile);
  {$I+}
  IO := IOResult;
End;

Procedure EEnd;
Var K  : KodArr;
    IO : Byte;
    Haszn,Haszn2,Handle,Romchk,Used : Word;
Begin
  IO := WaitForReadU(K,20);
  If IO = 0 Then
    Begin
      Dekodolo(Haszn,Handle,Romchk,Used,K);
      If (Handle = EzAHandle) And
         (Haszn <> 0) Then
        Begin
          Dec(Haszn);
          Used := 0;
          Kodolo(Haszn,Handle,Romchk,Used,K);
          {$I-}
          Seek(KodFile,0);
          IO := IoResult;
          Write(KodFile,K);
          IO := IoResult Or IO;
          Close(KodFile);
          {$I+}
          IO := IoResult Or IO;
        End;
    End;
  {$I-}
  Close(KodFile);
  {$I+}
  IO := IOResult;
End;

Function ESave:Boolean;
Var K  : KodArr;
    IO : Byte;
    Haszn,Haszn2,Handle,Romchk,Used : Word;
    X : Boolean;
Begin
  Esave := False;
  IO := WaitForReadU(K,20);
  If IO = 0 Then
    Begin
      Dekodolo(Haszn,Handle,Romchk,Used,K);
      X := (Handle = EzAHandle);
      If Not X Then
        Error(46,'')
      Else
        Esave := True;
    End
  Else
    Begin
      Error(43,'');
      Esave := True
    End;
  {$I-}
  Close(KodFile);
  {$I+}
  IO := IOResult;
End;

Function RezStart:Boolean;
Var CS,Used : Word;
    K  : KodArr;
    IO : Byte;
    EE : Integer;
Begin
  RezStart := False;
  Val(Kutya,ChkSzam,EE);
  CS := NewChkSzam(Ptr($FE00,$0000));
  {Writeln(cs);
  Writeln(chkszam);}
  If CS = ChkSzam Then
    Begin
      GlobHaszn := 0;
      Randomize;
      EzAHandle := Random(65535);

      Used := 1;
      Kodolo(GlobHaszn,EzAHandle,CS,Used,K);

      Assign(KodFile,KodPath+KodName);

      {$I-}
      ReWrite(KodFile);
      IO := IOResult;
      Write(KodFile,K);
      IO := IOResult Or IO;
      Close(KodFile);
      IO := IOResult Or IO;
      {$I+}
      RezStart := (IO = 0);
    End;
End;

Procedure RezService;
Var
    K       : KodArr;
    IO      : Byte;
    Handle,
    Romchk  : Word;
    CS,Used : Word;
Begin
  IO := WaitForRead(K,0);
  Case IO Of
    0 : Begin
          Dekodolo(GlobHaszn,Handle,Romchk,Used,K);
          
          If Used = 0 Then
            Begin
              Used := 1;
              Kodolo(GlobHaszn,Handle,Romchk,Used,K);
              Seek(KodFile,0);
              IO := IOResult Or IO;
              Write(KodFile,K);
              IO := IOResult Or IO;
            End;

          {$I-}
          Close(KodFile);
          IO := IOResult Or IO;
          {$I+}

        End;
    2 : Begin
          CS := ChkSzam;
          If GlobHaszn < Jogos Then
            Inc(GlobHaszn);
          Used := 1;
          Kodolo(GlobHaszn,EzAHandle,CS,Used,K);

          Assign(KodFile,KodPath+KodName);
          {$I-}
          ReWrite(KodFile);
          IO := IOResult;
          Write(KodFile,K);
          IO := IoResult Or IO;
          Close(KodFile);
          IO := IoResult Or IO;
          {$I+}
        End
    End; { Case }
End;

End. { Unit EKNET}