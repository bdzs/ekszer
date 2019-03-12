{$O+}

{$I MEMORY.CDW}

Unit SetCdw;

Interface

Uses Crt,InputCdw,Heapcdw,InitCdw,MenuErr,StartCdw,WINDOWM;

Procedure Set_LabelDistance;
Procedure Set_PublPrint;
Procedure Set_FirstPage;
Procedure Set_Max_Key;
Procedure Set_LastPage;
Procedure Set_FirstPageNum;
Procedure Set_NyomSzam;
Procedure Set_PageNumbering;
Procedure Set_StopAfterPage;
Procedure Set_KellLapdobas;
Procedure Set_Serial;
Procedure Set_Paralell;
Procedure Set_Checking;
Procedure Set_Pagelen;
Procedure Set_Spacing;
Procedure Set_Auto_Backup;
Procedure Set_Print_Margin;

Procedure SetKonfig(Num : Byte);
Procedure SetKonvert(Num : Byte);

Procedure Set_Szammal;
Procedure Set_Betuvel;

Implementation
Uses InputOvr,Filecdw,Speakcdw;

PROCEDURE Set_PublPrint;

BEGIN
  PublPrint:= not PublPrint;
  Fresh_Strings;
End;

Procedure Set_Volume;
Begin
  Inc(Volume,10);
  If Volume = 110 Then Volume := 0;
  EnabledSpeak := (Volume > 0);
  SetHangero;
  Fresh_Strings;
End;

Procedure SetKonfig(Num : Byte);
Var   OPrvs,
        Ws : String[80];
    TempSt : String;
      Work : Word;
        Sc : Integer;
Begin
  If Num In [12,14] Then Change_Dir((Num+2) DIV 4) { 12 -> 3  14 -> 4 }
  Else
  Begin
    If Num In [1..6,16] Then
    Begin
      Case Num Of
        1: Begin
             Inc(Byte(FirstGrMode));
             If Byte(FirstGrMode) > 4 Then FirstGrMode := AutoMode;
           End;
        2: If ModC80 = MaxMaxChars Then
             ModC80 := 80
           Else
             Inc(ModC80,16);
        3: EMSOVR := NOT EMSOVR;
        4: Boolean(GepTipus) := NOT(Boolean(GepTipus));
        5: Begin
             ComPort := (ComPort AND 3) + 1;
             ComPoint^:= ComDat[ComPort];
           End;
        6: Begin
             Inc(ModemBDR);
             If ModemBDR > 11 Then ModemBDR := 1;
           End;
       16: Set_Volume;

      End; { Case }
    End
    Else
    Begin
      {$IFNDEF VER3}
      MenuStr(MenuRec[18].Start+Num-1,Ws,False);
      {$ELSE}
      MenuStr(MenuRec[16].Start+Num-1,Ws,False);
      {$ENDIF}
      Sc := StartCh(Ws);


      Ws := Copy(Ws,1,Pos('  ',Ws));

      CREATE_WINDOW(14,16,79,20,Ws,CA[DispMode,1],CA[DispMode,3]);
      GotoXY(3,2);

      Case Num Of
          7: Begin
               Ws := Ws + '(2-37)';
               Work := UjIndS;
             End;
        8,9: Begin
               Ws := Ws + '(0-5000) (Kb)';
               If Num = 8 Then Work := NoEMSKb
                          Else Work := NoXMSKb;
             End;

         10: Begin
               TempSt := PRVS;
               Ws := PrevStSt;
             End;

         11: Begin
               Ws := Ws + '(1-16)';
               Work := ScStep;
             End;

         13: Begin
               Ws := Ws + '(1-30000)';
               Work := DskLinesT;
             End;

         15: Begin
               Ws := Ws + '(15-60000)';
               Work := SaveScMp;
             End;

      End;

      Ws := Ws + ' : ';

      If Num = 10 Then
      Begin
        MaxStringLen := 80;
        OPRVS := PRVS;
        Input_String(Ws,TempSt,16);
        If (NOT ESC) Then
        Begin
          PRVS := TempSt;
          If PRVS <> '' Then
            Begin
              SetPrvst;
              If PrvHiba Then
                Begin
                  Beepel(660);
                  Beepel(330);
                  PRVS := OPRVS;
                End
            End
          Else
            Begin
              ExtendedGr := False;
              SetPrvRes;
            End
        End;
      End
      Else
      Begin
        Input_Word(Ws,Work,5);
        If NOT ESC Then
        Case Num Of
           7: If InWord(Work,2,37)     Then UjInds    := Work;
           8: If InWord(Work,0,5000)   Then NoEMSKb   := Work;
           9: If InWord(Work,0,5000)   Then NoXMSKb   := Work;
          11: If InWord(Work,1,16)     Then ScStep    := Work;
          13: If InWord(Work,0,30000)  Then DskLinesT := Work;
          15: If InWord(Work,15,60000) Then SaveScMp  := Work;
        End;
      End;

      CurOff;
      Remove_Window;

    End;

    Fresh_Strings;

  End;

End;

Procedure SetKonvert(Num : Byte);

Const PMask : Array [1..3] Of String[5] =
  ('*.KEY','*.IN','*.OUT');

VAR Kilepett,Kesz : Boolean;
    elozoovr      : boolean;
    Teljesfnev    : FnTyp;
    PPName        : FnTyp;
    t             : byte;
    Cikl          : Integer;
    PatSt         : String[80];

BEGIN

  PatSt := AlapPath;

  WordstarMode(False);
  PPName := KonvName[Num];

  CREATE_WINDOW(21,7,78,11,KonvertText[Num],CA[DispMode,1],CA[DispMode,2]);

  Kesz := False;

  Repeat

    MaxStringLen := FnSize;
    Input_FileName(Enter_fn,PPName,36,False);
    UpperCase(PPName);

    If (PPname <> '') And (PPname <> NincsS) AND (Pos('.',PPName) = 0) Then
      PPName := PPName + Copy(Pmask[Num],2,4);


    CurOff;
    {
    While (Pos('\',PPName) + Pos(':',PPName)) > 0 Do
      Delete(PPName,1,1);
    }
    Kilepett := Esc;

    Teljesfnev := PatSt+PMask[Num];
    If NOT Esc Then
    BEGIN

      If PPName = '' Then Select_File(Teljesfnev,PPName,2);

      {
      While (Pos('\',PPName) + Pos(':',PPName)) > 0 Do
        Delete(PPName,1,1);
      }

      If (Pos('\',PPName) + Pos(':',PPName)) > 0 Then PatSt := '';

      Clrscr;
      Kesz := Not Esc;
      If Kesz Then
        BEGIN
          KonvName[Num] := PPName;
          Case Num Of
            1:if PPName <> NincsS then
                LoadKeyIn(PatSt+PPName)
              Else
                Begin
                  For Cikl := 1 To 4 Do
                    Key_InSt[Cikl] := '';
                End;
            2:Begin
                if PPName <> NincsS then
                  LoadAscIn(PatSt+PPName)
                Else
                  Begin
                    Asc_In.Ezt  := '';
                    Asc_In.Erre := '';
                  End;
                {
                CREATE_WINDOW(23,11,80,15,'',CA[DispMode,1],CA[DispMode,2]);
                WriteLn('In.Ezt  = ',Asc_In.Ezt);
                WriteLn('In.Erre = ',Asc_In.Erre);
                If ReadKey = ' ' Then;
                Remove_Window;
                }
              End;

            3:Begin
                if PPName <> NincsS then
                  LoadAscOut(PatSt+PPName)
                Else
                  Begin
                    Asc_Out.Ezt  := '';
                    Asc_Out.Erre := '';
                  End;
                {
                CREATE_WINDOW(23,11,80,15,'',CA[DispMode,1],CA[DispMode,2]);
                WriteLn('Out.Ezt  = ',Asc_Out.Ezt);
                WriteLn('Out.Erre = ',Asc_Out.Erre);
                If ReadKey = ' ' Then;
                Remove_Window;
                }
              End;

            end  { Case num}
        End; { If Kesz }
    End;  { If Not Esc }
  Until Kilepett Or Kesz;

  Bool := Remove_Window;
  WordstarMode(True);
End; { konvert }


Procedure Set_Szammal;
Var Ws : String[80];
Begin
  BOOL := CREATE_WINDOW(30,13,77,17,ResSt+SzammalSt,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(4,2);
  MaxStringLen := 80;
  Ws := Szammal;
  GlobalStringMode := SzamMode;
  Input_String(SzovegSt,Ws,30);
  If NOT ESC Then Szammal := Ws;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_Betuvel;
Var Ws : String[80];
Begin
  BOOL := CREATE_WINDOW(30,13,77,17,ResSt+BetuvelSt,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(4,2);
  MaxStringLen := 80;
  Ws := Betuvel;
  GlobalStringMode := BetuMode;
  Input_String(SzovegSt,Ws,30);
  If NOT ESC Then Betuvel := Ws;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_LabelDistance;
Var Work : Real;
Begin
  BOOL := CREATE_WINDOW(39,16,76,20,SST15,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(4,2);
  Work := LabelDist;
  Input_Real(EnterDist,Work,04);
  If (Not Esc) And (Work > 0.00) Then LabelDist := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_FirstPage;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(39,08,71,12,SST1,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(4,2);
  Work := FirstPage;
  Input_Integer(Enterpage,Work,04);
  If (Not Esc) And InInt(Work,1,6000) And (Work <= Lastpage) Then
    FirstPage := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_Max_Key;
Var Work : Word;
Begin
  BOOL := CREATE_WINDOW(30,11,71,15,SST0,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(4,2);
  Work := Max_Key;
  Input_Word(Enter_Max_Key,Work,05);
  If (Not Esc) And InWord(Work,2,65535) Then Max_Key := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_LastPage;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(39,09,71,13,SST2,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(4,2);
  Work := LastPage;
  Input_Integer(Enterpage,Work,04);
  If (Not Esc) And InInt(Work,1,6000) And (Work >= FirstPage) Then
    LastPage := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_FirstPageNum;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(39,10,71,14,SST3,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(3,2);
  Work := FirstPageNum;
  Input_Integer(Enterpage,Work,04);
  If (Not Esc) And InInt(Work,0,9999) Then
    FirstPageNum := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;

End;

Procedure Set_NyomSzam;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(39,14,71,18,SST14,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(3,2);
  Work := NyomSzam;
  Input_Integer(Enterpld,Work,04);
  If (Not Esc) And InInt(Work,1,99) Then
    NyomSzam := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

PROCEDURE Set_PageNumbering;

BEGIN
  LapSzamoz := not LapSzamoz;
  Fresh_Strings;
End;

Procedure Set_StopAfterPage;
Begin
  StopAfterPage := NOT (StopAfterPage);
  Fresh_Strings;
End;

Procedure Set_KellLapdobas;
Begin
  KellLapdob := NOT (KellLapdob);
  Fresh_Strings;
End;

Procedure Set_Serial;
Begin
  Serial_Device := Serial_Device Xor 1;
  Fresh_Strings;
End;

Procedure Set_Paralell;
Begin
  Paralell_Device := (Paralell_Device+1) And 3;

  Ppar := Ppar_Tomb[Paralell_Device+1];
  PsFile[True] := Ppar_Nev[Paralell_Device+1];

  Fresh_Strings;
  Fresh_Info;
End;

Procedure Set_Checking;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(49,14,78,18,SST4,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(2,2);
  Work := IroIdo;
  Input_Integer(SST5,Work,04);
  If (Not Esc) And InInt(Work,1,999) And (IroIdo <> Work) Then
    IroIdo := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_Pagelen;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(29,09,61,13,SST6,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(2,2);
  Work := PageLen;
  Input_Integer(SST7,Work,04);
  If (Not Esc) And InInt(Work,2,999) And (PageLen <> Work) Then
    Begin
      PageLen := Work;
      For EditNum := 1 To MaxEditor Do
        If StartLine[EditNum] <= EndLine[EditNum] Then
          SeekToFirstLine
    End;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Set_Spacing;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(30,09,68,13,SST8,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(2,2);
  Work := LineSpacing;
  Input_Integer(SST9,Work,03);
  If (Not Esc) And InInt(Work,1,100) Then
    LineSpacing := Work;
  CurOff;
  Bool := Remove_Window;
  Set_Lines(LineSpace);
  Fresh_Strings;

End;

Procedure Set_Auto_Backup;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(30,09,61,13,SST10,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(2,2);
  Work := BackupTime;
  Input_Integer(SST11,Work,04);
  If (Not Esc) And InInt(Work,1,9999) Then BackupTime := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;

End;

Procedure Set_Print_Margin;
Var Work : Integer;
Begin
  BOOL := CREATE_WINDOW(39,13,71,17,SST12,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(2,2);
  Work := PrintMargin;
  Input_Integer(SST13,Work,04);
  If (Not Esc) And InInt(Work,0,C77) Then PrintMargin := Work;
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;

End;


{
procedure cursor;
  Var Cim : Integer;
  Begin
      Cim := (((Ypos+3)*5+8) div 2)*80 + $2000*(((Ypos+3)*5) mod 2)+Xpos;
      Mem[$B800:Cim]  := Mem[$B800:Cim] xor 255;
  End;
 }


End.  {  Unit Set }