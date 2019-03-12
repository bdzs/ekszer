Program Password_archivalo;

Uses Dos,Crt;

Const
       Exe       : String[4] = '.EXE';
       Ovr       : String[4] = '.OVR';
       VerFile   : String[12] = 'VER.NUM';
       ListFile  : String[16] = 'PASSWORD.LST';
       Nev       : Array[False..True] Of String[4] = ('CDW','CDWA');
       VedettNev : Array[False..True] Of String[3] = ('EX','PRO');
       KeszNev   : Array[False..True] Of String[6] = ('EKSZER','PROTEX');


Var Fi,Fo     : Array[1..2] Of File;
    Angol     : Boolean;
    Ver       : String[6];
    Ws2,Ws3,
    Ws4,Ws5,
    Ws6,Ws7,
    Ws8,Ws9   : String[8];
    Tx        : Text;
    Ora,Perc,
    Mp,Mp100,
    Ev,Ho,Nap,
    HetNapja  : Word;
    Cik,Bc,
    Result,
    Sorsz     : Word;
    Code      : Integer;
    Fs,FSize,
    Ft        : LongInt;
    R         : Real;
    Ido       : DateTime;
    SorszSt   : String[5];
    Pwr       : Array[1..5] Of Real;
    Pw        : Array[1..5] Of String[13];
    Ch        : Char;
    Ws        : String;
    Sort      : Array[0..128] Of Char Absolute Ws;
    Lf        : File;
    CopyBuf   : Array [0..40960] Of Byte;
    FiNev,
    FoNev     : Array [1..2] Of String[40];

Procedure Error(St : String);
Begin
  TextAttr := 79;
  Sound(666);
  Write(St);
  Delay(300);
  TextAttr := 15;
  Writeln;
  NoSound;
  Ch := ReadKey;
  Halt(1);
End;

Begin
  If ParamCount = 2 Then
  Begin

    Ws := ParamStr(1);
    Ws[1] := UpCase(Ws[1]);
    Case Ws[1] Of
      'M' : Angol := False;
      'A' : Angol := True;
      Else Error('Az elsî paramÇter "M" vagy "A" lehet !');
    End;

    SorszSt := ParamStr(2);

    Val(SorszSt,Sorsz,Code);

    If Code <> 0 Then Error('A m†sodik paramÇter 0..65535 lehet');

    Assign(Tx,VerFile);
    {$I-} Reset(Tx); {$I+}

    If IOResult <> 0 Then Error('Nem tal†lhat¢ a '+VerFile+' file !');

    GetFtime(Tx,Ft);
    UnpackTime(Ft,Ido);

    GetDate(Ev,Ho,Nap,HetNapja);
    GetTime(Ora,Perc,Mp,Mp100);

    With Ido Do
      If (Ev <> Year) OR (Ho <> Month) OR (Nap <> Day) OR
         (60*Ora+Perc > 60*Hour+Min+5) Then Error('T£l rÇgi file : '+VerFile);

    {$I-} ReadLn(Tx,Ver); {$I+}

    If IOResult <> 0 Then Error('Nem j¢ a '+VerFile+' file !');

    Close(Tx);

    Val(Ver,R,Code);

    If (Code <> 0) OR (R < 3) OR (R >= 11) Then
      Error('A verzi¢sz†m 3.0 .. 10.99 lehet');

    For Cik := 1 To 5 Do Pwr[Cik] := R;

    FiNev[1] := VedettNev[Angol]+SorszSt+Exe;
    FiNev[2] := Nev[Angol]+Ovr;

    FoNev[1] := 'A:\'+KeszNev[Angol]+Exe;
    FoNev[2] := 'A:\'+KeszNev[Angol]+Ovr;

    TextAttr := 15;

    For Cik := 1 To 2 Do
    Begin

      Assign(Fi[Cik],FiNev[Cik]);
      Assign(Fo[Cik],FoNev[Cik]);

      {$I-} Reset(Fi[Cik],1); {$I+}

      If IOResult <> 0 Then Error('Nem tal†lhat¢ file : '+FiNev[Cik]);

      GetFtime(Fi[Cik],Ft);
      UnpackTime(Ft,Ido);

      Fs := FileSize(Fi[Cik]);

      {$I-} Rewrite(Fo[Cik],1); {$I+}

      If IOResult <> 0 Then Error('Nem megnyithat¢ file : '+FoNev[Cik]);

      Write(FiNev[Cik]);
      GotoXY(15,WhereY);
      Write('-> ',FoNev[Cik],'    ');

      FSize := Fs;

      While FSize > 0 Do
      Begin
        {$I-} BlockRead(Fi[Cik],CopyBuf,40960,Result); {$I+}
        If IOResult <> 0 Then Error('Olvas†si hiba : '+FiNev[Cik]);
        Write('€');
        {$I-} BlockWrite(Fo[Cik],CopyBuf,Result); {$I+}
        If IOResult <> 0 Then Error('Ir†si hiba : '+FoNev[Cik]);
        Write('€');
        Dec(FSize,Result);
      End;

      WriteLn;

      SetFtime(Fo[Cik],Ft);

      {$I-} Close(Fo[Cik]); {$I+}

      If IOResult <> 0 Then Error('Nem z†rhat¢ le a file : '+FoNev[Cik]);

      Close(Fi[Cik]);

    End;

    Str(Fs:5,Ws2);
    Str(Ft:10,Ws3);

    With Ido Do
    Begin
      Str(Year-1900:2,Ws4);
      Str(Month:2,Ws5); Ws5[1] := Char(Byte(Ws5[1]) OR $30);
      Str(Day:2,Ws6);   Ws6[1] := Char(Byte(Ws6[1]) OR $30);
      Str(Hour:2,Ws7);  Ws7[1] := Char(Byte(Ws7[1]) OR $30);
      Str(Min:2,Ws8);   Ws8[1] := Char(Byte(Ws8[1]) OR $30);
      Str(Sec:2,Ws9);   Ws9[1] := Char(Byte(Ws9[1]) OR $30);
    End;

    Ver := Copy(Ver+'    ',1,4);

    Ws:=Concat(Ver,'  ',SorszSt,'  ');


    For Cik := 1 To 5 Do
    Begin

      Pwr[Cik] := Frac (Frac(Sqrt(Sorsz)) + Frac(Sqrt(1.11111*Cik*Ft/(Pwr[Cik]*Fs))));

      Str(Pwr[Cik]:1:11,Pw[Cik]);
      Delete(Pw[Cik],1,3);

      For Bc := 1 To 10 Do
        Pw[Cik][Bc] :=
          Char( ( 25*Bc*(Byte(Pw[Cik][Bc])+13) MOD 26 )+65 );

    End;

    For Cik := 1 To 5 Do Ws := Ws + Pw[Cik]+' ∫ ';

    Dec(Byte(Ws[0]),2);

    Ws:=Concat(Ws,Ws2,' ',Ws3,' ',Ws4,'.',Ws5,'.',
               Ws6,' ',Ws7,':',Ws8,':',Ws9,' '#13#10);

    Repeat

      Assign(Lf,ListFile);
      {$I-} Reset(Lf,1);

      If IOResult <> 0 Then
      Begin
        TextAttr := 79;
        Sound(99);
        Write('*** Hi†nyzik a ',ListFile,' file, lÇtrehozom *** ');
        TextAttr := 15;
        WriteLn;
        Ch := ReadKey;
        NoSound;
        Rewrite(Lf,1);
      End
      Else Seek(Lf,FileSize(Lf));

      {$I+}

      If IOResult <> 0 Then Error('Megnyit†si hiba : '+ListFile);

      Write(Ver,'  ',SorszSt);
      GotoXY(15,WhereY);
      WriteLn('-> ',ListFile);

      {$I-} BlockWrite(Lf,Sort[1],110); {$I+}

      If IOResult <> 0 Then Error('Ir†si hiba : '+ListFile);

      {$I-} Close(Lf); {$I+}

      If IOResult <> 0 Then Error('Lez†r†si hiba : '+ListFile);

      Insert('\',ListFile,1);

    Until ListFile[2] = '\';

    {Writeln(Ws);}

    Inc(Sorsz);

  End
  Else Error('KÇt paramÇter szÅksÇges !');
End.
