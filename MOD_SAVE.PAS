UNIT Mod_save;

{$O+}

INTERFACE

USES Crt,WindowM,ModemCdw,Dos,Video,HeapCdw,MenuErr;

Procedure SaveModem(Var Filename: FnTyp; SaveMode : SaveType; FileMode : Filetype);

IMPLEMENTATION


(********************* Regi save rutinok ************************)

VAR Exital : boolean;


Function EofM(Var FF : Text):Boolean;
BEGIN
  If ModemMode Then
    EofM := Eof_Modem
  Else
    EofM := EOF(FF)
End;

Procedure ReadLnM(Var FF : Text;Var Sor : String);
BEGIN
  {$I-}
  If ModemMode Then
    ReadLn_Modem(Sor)
  Else
    ReadLn(FF,Sor);
  {$I+}
End;


Procedure WriteLnM(Var FF : Text;Sor : String);
BEGIN
  {$I-}
  If ModemMode Then
    WriteLn_Modem(Sor,True)
  Else
    WriteLn(FF,Sor)
  {$I+}
End;

Procedure WriteM(Var FF : Text;Sor : Char);
Var z : String[1];
BEGIN
  {$I-}
  Z := Sor+'';
  If ModemMode Then
    WriteLn_Modem(Z,False)
  Else
    Write(FF,Sor)
  {$I+}
End;


Procedure CloseM(Var FF : Text);
BEGIN
  {$I-}
  If ModemMode Then
    If ModemIras then
      Close_Modem_Out
    Else
      Close_Modem_Inp
  Else
    Close(FF);
  {$I+}
End;

Procedure ResetM(Var FF : Text);
BEGIN
  {$I-}
  ModemIras := False;
  If ModemMode Then
    Open_Modem_Inp
  Else
    Reset(FF);
  {$I+}
End;


Procedure RewriteM(Var FF : Text);
BEGIN
  {$I-}
  ModemIras := TRUE;
  If ModemMode Then
    Open_Modem_Out
  Else
    Rewrite(FF);
  {$I+}
End;


Procedure AssignM(Var FF : Text; ez: string);
BEGIN
  {$I-}
  ModemMode := Ez = 'XMODEM';
  If Not ModemMode Then
    Assign(FF, ez)
  {$I+}
End;


Function IoResultM : Integer;
BEGIN
  If Not ModemMode Then
    IoresultM := IoResult
  Else IoResultM := ModemError
End;




Procedure ASCII_Save (Var Fil : Szoveg);

Var FoAtt : Array[1..255] Of Byte;
    Fosor : String[255];
    MainP : Integer;
    FL    : Boolean;
    PP,
    Cik   : Byte;
    Ch    : Char;
    Po    : Lpoint;

Const

    ConvSt: Array[0..1] Of String[29] =

     (';''[]=\`0-:"{}+|~)_!@#$^&*(<>/',
      'Ç†É£¢ñ°îÅêèãóïòçôö0"+!/=();:-');

Begin

   Mainp := StartLine[EditNum];
   While Not MainLine(MainP) Do Inc(MainP);
   Fl := True;

   Repeat
      If Fl Then Fl := False
      Else
        Mainp := NextMain(MainP);

      Heap_Pos(Po,PointerTomb^[MainP]);

      Fosor[0] := Char(LenLine(MainP));

      Move(Po^.Chars[C80],Fosor[1],Byte(Fosor[0]));
      Move(Po^.Attribs,FoAtt[1],Byte(Fosor[0]));

      FreeEms1(PointerTomb^[MainP]);

      For Cik := 1 To Length(FoSor) Do
      Begin

        If FoSor[Cik] = #00 Then FoSor[Cik] := ' '

        {$IFNDEF ANGOL}

        Else

        If MagyarE(FoAtt[Cik] AND 15) Then { Magyar }
        Begin
          PP := Pos(FoSor[Cik],ConvSt[0]);
          If Boolean(PP) Then
            FoSor[Cik] := ConvSt[1][PP]
        End;

        {$ENDIF}

      End;

     WritelnM(Fil,Fosor);

     If IOResultM <> 0 Then
     Begin
       If Not ModemMode Then Error(18,'');
       Exital := True;
       Exit;
     End;


   Until (Exital) Or LastMain(MainP);

End;

Procedure Only_Save(Var Fil : Szoveg);

Const DefaultAlso  = 0;
      DefaultFelso = 1;

Var

Fosor,Sor  : String[255];
Poz,Opoz,Mainp  : Integer;
Pt,Opt : Lpoint;
Legelso: Boolean;
Also_Korr,Felso_Korr,Fdist,Adist,Lastupind,
Lastdownind,Font,Alsok,Felsok,Ix,FMax,
A_Korr,A_Okorr,F_Korr,F_Okorr: Integer;
Crst : String[2];
Ch : Char;

Procedure Convert_And_WriteLine;
Var X,P : Integer;
    Ch  : Char;

Procedure Create_Sor;
Var X    : Integer;
    Attr : Byte;
Begin
  Cik := c77;
  While (Cik >= 0) AND (Pt^.Chars[C80+Cik] = #00) Do Dec(Cik);
  If Cik >= 0 Then
  Begin
    P := 0;
    Sor[0] := Char(Cik+1);
    For X := 0 To Cik Do
    Begin


      Ch := Pt^.Chars[C80+X];


      If Pt^.Chars[C80+X] = #00 Then { Soft Space }
      Begin
        If Not MainLine(Poz) Then Ch := ' '
        Else Begin
               Ch := '.';
               Sor[X+1+P] := '\';
               Inc(P);
             End;
      End
      Else
      Begin
        Attr := Pt^.attribs[X] AND 15;
        If Attr <> Font Then  { font valtas }
        Begin
           Sor[X+1+P] := '\';
           If Attr = 0 Then
           Begin
             Ch := '@';
             Dec(P);
           End
           Else
           Begin
             Font := Attr;
             Sor[X+2+P] := Char((Font Mod 10) + 48);
           End;
           Inc(P,2);
        End;

        If Ch = '\' Then     { '\'  =>  '\\' }
        Begin
          Sor[X+1+P] := Ch;
          Inc(P);
        End;

      End;

      Sor[X+1+P] := Ch;

    End;  {For Cik}

    Sor[0] := Char(Byte(sor[0]) + P);

  End {If Cik >= 0}
  Else Sor := '';

End;   {Create_Sor}

Begin  {Convert_And_WriteLine}

  If Mainline(Poz) Then
  Begin
    Create_sor;
    Fosor := Sor;
    If HardCr(Poz) Then Fosor:= Fosor + #27;
    If LapVeg(Poz) Then FoSor := ^L + FoSor;
  End
  Else
  If Upindex(Poz) Then
  Begin
    Create_sor;
    Sor :=  '\+'+Sor;
    If LapVeg(Poz) Then Sor := ^L + Sor;
    WritelnM(Fil,Sor);
    If IOResultM <> 0 Then
    Begin
      If Not ModemMode Then Error(18,'');
      Exital := True;
      Exit;
    End;
  End
  Else
  Begin
    Create_sor;
    Sor := '\-' + Sor;
    If LapVeg(Poz) Then Sor := ^L + Sor;
    WritelnM(Fil,Sor);
    If IOResultM <> 0 Then
    Begin
      If Not ModemMode Then Error(18,'');
      Exital := True;
      Exit;
    End;
  End;

End;  {Convert_And_WriteLine}

Begin {Only_Save}

   Poz   := StartLine[Editnum];

   If EndLine[EditNum] >= Poz Then
     Begin
        Mainp := Poz;
        Fdist := 0; Adist := 0;

        Font    := 1;

        A_Okorr := DefaultAlso;  {0}
        F_Okorr := DefaultFelso; {1}

        While Not(Mainline(Mainp)) Do Inc(Mainp); {Raall az elso fo sorra}
        Legelso := True;

        WriteM(Fil,^Q);   { Ekszer 2.0 jelzo ! }

        Repeat

           If Not Legelso Then Mainp := Nextmain(Mainp);

           FMax := Upind(Mainp);

           If (Not(Legelso)) Or (Fmax <> 0) Then
           Begin
             If Upline(Poz) Then Dec(Fmax,Upind(Poz));
             If (Legelso And (Fmax > 4)) Or ((Fmax <= 4) And Not(Legelso))
             Then Fmax := 0;
           End;

           For Cik := 1 To Fmax-1 Do
           Begin
             WritelnM(Fil,'\+');
             If IOResultM <> 0 Then
             Begin
               If Not ModemMode Then Error(18,'');
               Exital:= True;
               Exit;
             End;
           End;

           LastUpInd := 0;

           While Upline(Poz) Do
           Begin
             Heap_pos(Pt,PointerTomb^[Poz]);
             For Cik := 1 To LastUpind-Upind(Poz)-1 Do
             Begin
               WritelnM(Fil,'\+');
               If IOResultM <> 0 Then
               Begin
                 If Not ModemMode Then Error(18,'');
                 Exital:= True;
                 FreeEms1(PointerTomb^[Poz]);
                 Exit;
               End;
             End;

             Convert_And_WriteLine;
             If Exital Then
               Begin
                 FreeEms1(PointerTomb^[Poz]);
                 Exit;
               End;
             LastUpind := Upind(Poz);
             FreeEms1(PointerTomb^[Poz]);
             Inc(Poz);
           End;

           Heap_pos(Pt,PointerTomb^[Poz]);  { Fo sor }
           Alsok := DownInd(Poz);      { Also indexek szama }
           For Cik := 1 To LastUpind-1 Do
           Begin
             WritelnM(Fil,'\+');
             If IOResultM <> 0 Then
             Begin
               If Not ModemMode Then Error(18,'');
               Exital := True;
               FreeEms1(PointerTomb^[Poz]);
               Exit;
             End;
           End;

           Convert_And_WriteLine;
           FreeEms1(PointerTomb^[Poz]);
           If Exital Then
             Exit;

           Inc(Poz);

           Opoz := Poz;
           Opt  := Pt;

           LastDownind := 0;

           If OPoz < EndLine[Editnum]+1 Then  {Eloreszalad az alsoindexsorokon}
             While Downline(OPoz) Do
             Begin
               Inc(Adist);
               {Heap_pos(OPt,PointerTomb^[OPoz]);}
               For Cik := 1 To Upind(OPoz)-LastDownind-1 Do Inc(Adist);
               LastDownind := Upind(OPoz);
               Inc(OPoz);
             End;

           Fdist := 0;

           If OPoz < EndLine[Editnum]+1 Then  {Eloreszalad a kov. felsoindexsorokon}
             While Upline(OPoz) Do
             Begin
               If Fdist = 0 Then Fdist := Upind(Opoz);  { a legfelso index}
               {Heap_pos(OPt,PointerTomb^[OPoz]);}
               Inc(OPoz);
             End;

           If OPoz < EndLine[Editnum]+1 Then
             Felsok:= Upind(OPoz)-1;        { A Fo sor felso indexeinek szama }

             If Fosor[Byte(Fosor[0])] = #27 Then  {Hard CR}
             Begin
               Fosor[0] := Char(Byte(Fosor[0])-1);
               Crst     := '\,';
             End
             Else Crst := '';

             A_Korr    := Alsok - Adist;
             Also_Korr := A_Korr;

             F_Korr := Felsok - Fdist + 1;
             Felso_Korr := F_Korr;

             If Not Legelso Then
             Begin
               If A_Korr <> A_Okorr Then
               Begin

                 If A_Korr <= 4 Then
                 Begin

                   Case A_Korr Of
                      0:   Ch := '!';
                      1:   Ch := '"';
                      2:   Ch := '#';
                      3:   Ch := '$';
                      4:   Ch := '%';
                   End;

                   Fosor := Fosor + '\' + Ch;
                 End
                 Else
                 A_Korr := DefaultAlso;

                 A_Okorr := A_Korr;

               End;

               If F_Korr <> F_Okorr Then
               Begin

                 If F_Korr <= 4 Then
                 Begin

                   Case F_Korr Of

                     0:   Ch := '&';
                     1:   Ch := #39;
                     2:   Ch := '(';
                     3:   Ch := ')';
                     4:   Ch := '*';

                   End;

                   Fosor := Fosor + '\' + Ch;

                 End
                 Else F_Korr := DefaultFelso;

                 F_Okorr := F_Korr;

               End;

             End;  { If NOT Legelso }

             Fosor := Fosor + Crst;    { '' vagy '\,' }
             WritelnM(Fil,Fosor);
             If IOResultM <> 0 Then
             Begin
               If Not ModemMode Then Error(18,'');
               Exital := True;
               Exit;
             End;

           LastDownind := 0;

           If Poz <> EndLine[Editnum]+1 Then
             While Downline(Poz) Do
             Begin
               Heap_pos(Pt,PointerTomb^[Poz]);
               For Cik := 1 To Upind(Poz)-LastDownind-1 Do
               Begin
                 WritelnM(Fil,'\-');
                 If IOResultM <> 0 Then
                 Begin
                   If Not ModemMode Then Error(18,'');
                   Exital := True;
                   Exit;
                 End;
               End;
               Convert_And_WriteLine;
               FreeEms1(PointerTomb^[Poz]);
               If Exital Then Exit;

               LastDownind := Upind(Poz);
               Inc(Poz);
             End;

             If (Also_Korr > 4) Or Legelso Then
               For Ix := Adist+1 To Alsok Do
               Begin
                 WritelnM(Fil,'\-');
                 If IOResultM <> 0 Then
                 Begin
                   If Not ModemMode Then Error(18,'');
                   Exital := True;
                   Exit;
                 End;
               End;

             Adist := 0;
             Fdist := 0;

             If Legelso Then Legelso := False;

        Until LastMain(Mainp);

        WritelnM(Fil,'\=');
        If IOResultM <> 0 Then
        Begin
          If Not ModemMode Then Error(18,'');
          Exital := True;
          Exit;
        End;

     End  { If Nem ures az editor}
     Else Beepel(666);

End; {Only_Save}


Procedure SaveModem(Var Filename: FnTyp; SaveMode : SaveType; FileMode : Filetype);


Function IOError: Boolean;

Begin
If IOresultM <> 0 Then
  Begin
    If Not ModemMode Then Error(18,'');
    If SaveMode <> BackupMode Then Bool := Remove_Window;
    IOError := True;
  End
  Else IOError := False;
End;

Label Kiugrik;

Var

BakFilename : FnTyp;
OfileName   : FnTyp;
Ext     : String[4];
Poz,Res : Integer;
Cix,Cx  : Byte;
Wsx     : String[4];
Header  : String[14];
Escap   : Boolean;
BakFil  : Szoveg;
Fil     : Szoveg;
Buffer  : Array[1..10240] Of Byte;

maxstringlen : integer;

Begin

Exital    := False;
ESC       := False;
OfileName := FileName;

(*
  If SaveMode <> AllSaveMode Then
    Begin

        ESC := (StartLine[EditNum] > EndLine[EditNum]);

        Ext := '.'+DMask;

        Case FileMode Of

          Document : Header := DocuSt;
          ASCII    : Header := ASCIISt;

        End;  {Case}

    End
    Else
    Begin
      Header := InpSt4;
      Ext    := FMask;
    End;

    If Not ESC Then
    Begin

        If SaveMode <> BackupMode Then
        {$IFDEF ANGOL}

          BOOL := CREATE_WINDOW(10,5,71,9,InpSt6+Header,
                  CA[DispMode,1],CA[DispMode,2]);

        {$ELSE}

          BOOL := CREATE_WINDOW(10,5,71,9,Header+InpSt6,
                  CA[DispMode,1],CA[DispMode,2]);

        {$ENDIF}

        If SaveMode In [NormalMode,AllSaveMode] Then
        Begin
          GotoXY(2,2);
          MaxStringLen := 63;
          Input_String(Enter_fn,Filename,39);
          UpperCase(FileName);
          CurOff;
        End;

        If Not Esc Then
          CheckFileName(FileName);
        CurOff;

        If Not ESC Then CheckWrite(FileName); { Ez is az ESC - t allitja be ! }


      If NOT ESC Then
      Begin


           Poz := Pos('.',Filename);
           If Poz = 0 Then Poz := Length(Filename)+1;

           Bakfilename   := Filename;
           Bakfilename[0]:= Char(Poz-1);
           Bakfilename := Bakfilename + '.BAK';

           If (Pos('.',Filename) = 0) And (Filename <> 'XMODEM')
              Then Filename := Filename + Ext;

*)
    Begin
       Begin
           AssignM(Fil,Filename);

           If (SaveMode <> BackupMode) And (Not ModemMode) Then
           Begin

              ResetM(Fil);

              If IOresultM = 0 Then
              Begin
                CloseM(Fil);
                AssignM(BakFil,Bakfilename);
                Erase(BakFil);
                Res := IOResultM;
                AssignM(BakFil,Filename);
                Rename(BakFil,Bakfilename);
                Res := IOResultM;
              End;

           End; {If not backupmode}

           SetTextBuf(Fil,Buffer);

           AssignM(Fil,Filename);
           RewriteM(Fil);

            If (IOresultM <> 0) Then
            Begin
              If Not ModemMode Then
                  Error(3,Filename);
            End
            Else
            Begin

              If  (SaveMode <> BackupMode) Then
              Begin
                ClrScr;
                GotoXY(30-((Length(FileName)+10) DIV 2),2);
                {$IFDEF ANGOL}

                  Write(InpSt6,Filename);

                {$ELSE}

                  Write(Filename,InpSt6);

                {$ENDIF}
              End;


              If SaveMode = AllSaveMode Then
              Begin
                WritelnM(Fil,HeaderID);   { Ekszer 2.0 jelzo ! }
                For Cix := 4 To 27 Do
                Begin
                  If StartLine[Cix] <= EndLine[Cix] Then
                  Begin
                    Wsx[0] := #02;
                    If Cix >= 16 Then
                                 Begin
                                   Wsx[1] := 'O';
                                   Cx     := Cix - 12;
                                 End
                                 Else
                                 Begin
                                   Wsx[1] := 'H';
                                   Cx     := Cix;
                                 End;
                    Case Cx Of

                          4: Wsx[2] := 'A';
                          5: Wsx[2] := 'E';
                          6: Wsx[2] := 'O';
                       Else  Wsx[2] := Char(Cx+48-6);

                    End; {Case}

                    EditNum := Cix;
                    WritelnM(Fil,Wsx);
                    If IOError Then Exit;

                    Only_Save(Fil);
                    If Exital Then Goto Kiugrik;
                    WritelnM(Fil,'');
                    If IOError Then Exit;

                  End; {Ha nem ures ez az editor}
                End; {For Cix}
              End
              Else

                Case FileMode Of

                  ASCII   : ASCII_Save(Fil);
                  Document: Only_Save(Fil);

                End;

              If Exital Then Goto Kiugrik;

                CloseM(Fil);
                If IOError Then Exit;
                Valtozas[EditNum] := False;

            End; { If IORESULTM = 0 }

    End; {If NOT ESC}

   If ModemMode Then
     FileName := OfileName;

   If SaveMode <> BackupMode Then
   Begin
     Bool := Remove_Window;
     CurOff;
   End;

  End;   { If nem ures az editor }

  Exit;

Kiugrik:  If SaveMode <> BackupMode Then Bool := Remove_Window;
          Exit;

End;  { Procedure Save }

(********************* Regi Save rutinok Vege ************************)

End.
