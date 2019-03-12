Unit StartCdw;

{$O+}

InterFace

Uses

{$IFNDEF CGAONLY}

  Graph,crt,

  BGI,      {FI}

{$ENDIF}

     Windowm,
     MenuErr,

     Video,
     InputCdw,
     SpeakCdw;

  Procedure SetPRVSt;
  Procedure SetPrvRes;
  Procedure Parameters;
  Procedure Read_Driver;
  Procedure LoadChiIn(FName:FnTyp);
  Procedure LoadKeyIn(FName:FnTyp);
  Procedure LoadAscIn(FName:FnTyp);
  Procedure LoadAscOut(FName:FnTyp);

Var
  XX      : Integer;
  PrvHiba : Boolean;

Implementation
Uses EGAOVR,CGAOVR,HEROVR;

Procedure Parameters;
Var Cikl,
    Cikl2,
    Cikl3     : Integer;
    Wst       : String;


Procedure FullPath(Var Name:FnTyp);
Var P  : Integer;
    P2 : Integer;
    Pa,Pa2 : FnTyp;

Begin

  P  := Pos(':',Name);
  P2 := Pos('\',Name);
  If P = 2 Then
    Begin
      P := Byte(Name[1])-Byte('A')+1;
      If P2 = 0 Then
        Delete(Name,1,2);
    End;

  If P2 = 0 Then
    Begin  { nincs benne backslash }

      {$I-}
      GetDir(P,Pa);
      {$I+}

      If IoResult <> 0 Then
        Begin
          Error(15,'');
          Terminate;
        End;

      If Pa[Length(Pa)] <> '\' Then
        Pa := Pa + '\';
      Name := Pa + Name
    End
  Else
    Begin  { backslash van benne }
      GetDir(0,Pa2);
      Pa := Name;
      While Pa[Length(Pa)] <> '\' Do
        Pa[0] := Char(Byte(Pa[0])-1);

      P2 := Length(Pa);
      Delete(Name,1,P2);
      If P2 <> 1 Then
        Pa[0] := Char(Byte(Pa[0])-1);

      {$I-}
      ChDir(Pa);
      {$I+}

      If IoResult <> 0 Then
        Begin
          Error(2,Pa);
          Terminate;
        End;

      GetDir(0,Pa);
      ChDir(Pa2);

      If Pa[Length(Pa)] <> '\' Then
        Pa := Pa + '\';
      Name := Pa + Name
    End
End;


Begin
  CsakNez := False;
  For Cikl := 1 To 4 Do
    Begin
      PFname[Cikl] := False;
      Toltes[Cikl] := False
    End;
  For Cikl := 1 To ParamCount Do
    Begin
      Wst := ParamStr(Cikl);
      UpperCase(Wst);
      Case Wst[1] Of
      '/':
        Begin
          Delete(Wst,1,1);
          Deffile := Wst;
          If Pos('.',Deffile) = 0 Then
            Deffile := Deffile + '.PAR';
          FullPath(Deffile);
        End;
      '#':
        Begin
          Delete(Wst,1,1);
          Configfile := Wst;
          If Pos('.',Configfile) = 0 Then
            ConfigFile := Configfile + '.PAR';
          FullPath(ConfigFile);
        End;
      '*':
        If (Length(Wst) = 2) And (Wst[2] In ['1'..'4']) Then
          Toltes[Byte(Wst[2])-Byte('0')] := True
        Else
          For Cikl2 := 1 To 3 Do
            Toltes[Cikl2] := True;
      '-':KellHelpFile := False;
      '@':CsakNez := True;

      Else
        Begin
          Cikl2 := 1;
          While (Cikl2 < 5) And (Toltes[Cikl2]) Do
            Inc(Cikl2);
          If Cikl2 <= 4 Then
            Begin
              For Cikl3 := 1 To length(Wst) Do
                Wst[Cikl3] := UpCase(Wst[Cikl3]);
              FileName[Cikl2] := Wst;
              Toltes[Cikl2] := True;
              PFname[Cikl2] := True;
            End
        End
      End {Case}
    End;
End;

Procedure SetPRVSt;
Var SS : String[20];
    Err : Integer;
Begin
  PrvHiba := False;
  Xresolution  := 0;
  YResolution  := 0;
  ExtendedMode := 0;
  SS := '';
  For Cikl := 1 To Length(PRVS) Do
    Begin
      If PRVS[Cikl] In ['0'..'9'] Then
        SS := SS + PRVS[Cikl];
      If Not(PRVS[Cikl] In ['0'..'9']) Or
         (Cikl = Length(PRVS)) Then
        Begin
          If ExtendedMode = 0 Then
            Val(SS,ExtendedMode,err)
          Else
            If Xresolution = 0 Then
              Val(SS,Xresolution,Err)
            Else
              If Yresolution = 0 Then
                Val(SS,Yresolution,Err)
              Else
                Val(SS,NoOfColors,Err);
          SS := '';
        End;
    End;
  ExtendedGr :=
     (ExtendedMode <> 0) And
     (Xresolution  <> 0) And
     (Yresolution  <> 0);

  PrvHiba := Not(ExtendedGr);
  If NoOfColors = 0 Then
    NoOfColors := 256;
End;

Procedure SetPrvRes;
Begin
  If Not ExtendedGr Then
    Case GrMode Of
      CgaMode :  Begin
                   Xresolution := 640;
                   Yresolution := 200
                 End;
      EgaMode :  Begin
                   Xresolution := 640;
                   Yresolution := 350
                 End;
      HerMode :  Begin
                   Xresolution := 720;
                   Yresolution := 348
                 End;
      VgaMode :  Begin
                   Xresolution := 640;
                   Yresolution := 480;
                   LastLine := 57;
                 End;
    End;
End;



Procedure Read_Configfile;

var
  I        : Byte;
  x        : ShortInt;
  Cikl     : Integer;
  Err      : Integer;
  SS       : String[20];
  TempW    : Word;
  Temp,t   : Integer;
  pparszam : Integer;
  TempLong : LongInt;

Begin
  {$IFNDEF CDVIEW}
  with ppar do
  begin
   pr_ini       := #27 + #64;
   pr_lf_5_72   := #27 + 'A' + #05;
   pr_set_l_m   := #27 + 'l';
   pr_ini_ff_12 := #27 + 'C' + #00  + #12;
   pr_ini_d_gr  := #27 + 'L';
   pr_lf_1_216  := #27 + 'J' + #01;
   pr_lf_14_216 := #27 + 'J' + #14;
   pr_vastag_be := #27 + 'E';
   pr_vastag_ki := #27 + 'F';
   pr_ala_be    := #27 + '-' + #01;
   pr_ala_ki    := #27 + '-' + #00;

   pr_DownLoad  := False;
   pr_joker     := '.';
   Pr_OVR       := 0;
   pr_maxfelsor := 160;
   pr_egyeb     := '';

  end;

  PparSzam := 0;
  for t:= 1 to 4 do
    Ppar_Nev[t] := 'NOPRINT.PPS';
  For T := 1 To 3 Do
    KonvName[T] := NincsS;

  {$ENDIF}

  EmsOvr    := False;
  DskLines  := 0;

    Assign(Textfile,Configfile);
    {$i-} Reset(Textfile); {$i+}

    If IOresult <> 0 Then
      Begin
        Error(1,ConfigFile);
        Terminate;
      End
    Else
      Begin
        {$I-}
        Read(TextFile,Sor);
        UpperCase(Sor);
        {$I+}
        If (IOResult <> 0) Or ((Copy(Sor,1,3) <> GR_S)  And
                               (Copy(Sor,1,3) <> AP_S)) Then
          Begin
            Error(24,ConfigFile);
            Terminate;
          End;
        Reset(TextFile);
      End;

    While not EOF(Textfile) do
    Begin
      Readln(Textfile,Sor);
      while sor[byte(sor[0])] = ' ' do dec(byte(sor[0]));
      uppercase(sor);
      {$IFNDEF CDVIEW}
      if (pos('.PPS',sor) > 0) And (PparSzam < 4) then
      begin
        If Sor <> 'NOPRINT.PPS' then
         begin
          assign (ppars,AlapPath+sor);
          FileMode := 0;
          {$i-}   reset  (ppars);         {$i+}
          If IOresult = 0 Then
          Begin
            {$I-}
            read (ppars, ppar);
            {$I+}
            If IoResult = 0 Then
              Begin
                PsFile[True] := Sor;
                close(ppars);
                Inc(PparSzam);
                Ppar_Tomb[PparSzam] := Ppar;
                Ppar_Nev[PparSzam] := Sor;
                volt_pps := true;
              End
          end
          else error(1,sor);
          FileMode := 2;
         end
        Else Inc(PparSzam);
      end;

      if pos('.SPS',sor) > 0 then
      begin
        assign (spars,AlapPath+sor);
        FileMode := 0;
        {$i-}   reset  (spars);         {$i+}
        If IOresult = 0 Then
        Begin
          PsFile[False] := Sor;
          read (spars, spar);
          close(spars);
          volt_sps := true;
        end;
        FileMode := 2;
      end;
      {$ENDIF}
      If Pos(GR_S,Sor) = 1 Then
      Begin
        Sor := Copy(Sor,4,Length(Sor)-3);
        For Cik := 0 To 3 Do If
          Sor = VideoMod[Cik] Then GrMode := GrTip(Cik);
        FirstGrMode := GrMode;
      End;

      If Pos(KEY_S,Sor) = 1 Then
      Begin
        Sor := Copy(Sor,5,Length(Sor)-4);
        LoadKeyIn(AlapPath+Sor);
      End;

      If Pos(ASI_S,Sor) = 1 Then
      Begin
        Sor := Copy(Sor,5,Length(Sor)-4);
        LoadAscIn(AlapPath+Sor);
      End;

      If Pos(ASO_S,Sor) = 1 Then
      Begin
        Sor := Copy(Sor,5,Length(Sor)-4);
        LoadAscOut(AlapPath+Sor);
      End;

      If Pos(KB_S,Sor) = 1 Then
        GepTipus := Gti(Pos(Tip[1],Sor) <> 0);

      If Pos(SOR_S,Sor) = 1 Then
      Begin
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,C80,Eddig);

        {$IFDEF VER4}
        C80 := 80;
        {$ENDIF}

        If C80 < 80 Then C80 := 80
        Else
        Begin
          C80  :=  16*((C80+15) DIV 16);
          If C80 > MaxMaxChars Then
            C80 := MaxMaxChars;
        End;

        ModC80 := C80;    { Ezt lehet m¢dos¡tani }

        C79    :=  C80-1;
        C78    :=  C80-2;
        C77    :=  C80-3;
        C76    :=  C80-4;
        C160   :=  C80*2;
        SperLap:=  16384 Div C160;
        Cp16   :=  C160  Div 16;

      End;

      If Pos(IND_S,Sor) = 1 Then
      Begin
        Temp := 0;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,Temp,Eddig);
        If Temp In[2..MmaxE] Then
          Begin
            MaxIndexEv   := Temp;
            MaxAIndexEv  := Temp;
            UjIndS       := Temp;
          End;
      End;

      If Pos(XMS_S,Sor) = 1 Then
      Begin
        Temp := 0;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,Temp,Eddig);
        If (Temp >= 1) AND (Temp<=16000) Then
          Begin
            NoXMSKb := Temp;
          End;
      End;

      If Pos(EMS_S,Sor) = 1 Then
      Begin
        Temp := 0;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,Temp,Eddig);
        If (Temp >= 1) AND (Temp<=16000) Then
          Begin
            NoEMSKb := Temp;
          End;
      End;

      If Pos(DSK_S,Sor) = 1 Then
      Begin
        Temp := 0;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,Temp,Eddig);
        If (Temp >= 1) AND (Temp<=32000) Then
          Begin
            DskLines  := Temp;
            DskLinesT := Temp;
          End;
      End;

      If Pos(SCR_S,Sor) = 1 Then
      Begin
        Temp := 0;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,Temp,Eddig);
        If Temp In[1..16] Then ScStep := Temp;
      End;

      If Pos(SCS_S,Sor) = 1 Then
      Begin
        TempW := 0;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,TempW,Eddig);
        If TempW > 10 Then SaveScMp := TempW;
      End;

      {$IFDEF VER4}
      SaveScMp := 60*300;
      {$ENDIF}

      If Pos(LET_S,Sor) = 1 Then
      Begin
        MindigLetolt := (Sor[5] = '1');
      End;

      {$IFNDEF CDVIEW}
      If Pos(COM_S,Sor) = 1 Then
      Begin
         I := Byte(Sor[5])-48;
         If I In [1..4] Then ComPort := I;
      End;

      If Pos(MBR_S,Sor) = 1 Then
        Begin
          Sor := Copy(Sor,5,Length(Sor)-4);
          X := 0;
          If Sor = HiSpeed {115200} Then X := 11 Else
          For Cikl := 1 To MaxModem Do
          Begin
            Val(Sor,Ureske,Eddig);
            If Brs[Cikl] = Ureske Then X := Cikl;
          End;
          If X = 0 Then
            Begin
              Error(27,Sor);
              X := 3;
            End;
          ModemBdr := X
        End;

      If Pos(OV_S,Sor) = 1 Then
        Begin
          Sor := Uppercas(Copy(Sor,5,Length(Sor)-4));
          EmsOvr := Sor = 'EMS'
        End;
      If Pos(SOR_S,Sor) = 1 Then
        Begin
          Sor := Uppercas(Copy(Sor,5,Length(Sor)-4));
        End;

    {$ENDIF}

      If Pos(DP_S,Sor) = 1 Then
      Begin
        DiskMemPath := Copy(Sor,4,Length(Sor)-3);
        If (DiskMemPath <> '') And
         Not(DiskMemPath[Length(DiskMemPath)] In ['\',':']) Then
          DiskMemPath := DiskMemPath + '\'
      End;

      If Pos(VOL_S,Sor) = 1 Then
      Begin
        Temp := 0;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,Temp,Eddig);
        If Temp In [0..100] Then Volume := Temp;
        EnabledSpeak := (Volume > 0);
        SetHangero;
      End;

      If Pos(UZ_S,Sor) = 1 Then
      Begin
        TempLong := 3;
        Sor := Copy(Sor,5,Length(Sor)-4);
        Val(Sor,TempLong,Eddig);
        If TempLong > 0 Then HanyMasodpercenkentFigyel := TempLong;
      End;

      If Pos(CRD_S,Sor) = 1 Then
      Begin
        Temp := 0;
        Sor := Uppercas(Copy(Sor,5,Length(Sor)-4));
        If Sor = 'MELIS' Then
          OutputCard := melis;
        If Sor = 'BLASTER' Then
          OutPutCard := blaster;
        EnabledSpeak := (Volume > 0);
      End;

      If Pos(AP_S,Sor) = 1 Then
        Begin
          AlapPath := Copy(Sor,4,Length(Sor)-3);
          If (AlapPath <> '') And
           Not(AlapPath[Length(AlapPath)] In ['\',':']) Then
            AlapPath := AlapPath + '\'
        End;


     {$IFNDEF CDVIEW}
      If Pos(PV_S,Sor) = 1 Then
        Begin
          PRVS  := Copy(Sor,5,Length(Sor)-4);
          SetPRVST;
        End;
       {$ENDIF CDVIEW}
    End;

    Close(Textfile);
  {$IFNDEF CDVIEW}
  if not volt_pps then error (11,'');
  {$ENDIF}
  DskLinesT := DskLines;

  {$IFDEF NOSPEAK}
  EnabledSpeak := False;
  {$ELSE}
  If Volume = 200 Then
  Begin
    Volume := 50;
    EnabledSpeak := True;
    SetHangero
  End;

  FontPath := AlapPath;
  If EnabledSpeak AND (SpeakPuff = NIL)   Then
    GetMem(SpeakPuff,SpeakPuffSize);
  If EnabledSpeak  AND (SpeakPuff <> NIL) Then
    InitSpeak;
  {$ENDIF}

  LoadChiIn('CHI_IN.DAT');

End;   {Read_Configfile}

Procedure Read_Driver;
Var
     Ch       : Char;
     Err      : Boolean;

Begin

  GrMode     := AutoMode;
  ExtendedGr := False;
  Read_configfile;

  DetectGraph(Gr,Gm);
  Case GrMode Of
    CgaMode :  gr := cga;
    EgaMode :  gr := ega;
    HerMode :  gr := hercmono;
    VgaMode :  Begin
                 gr := VGA;
                 LastLine := 57;
               End;
    AutoMode : Case Gr Of
          CGA,MCGA,ATT400
                    : Begin
                        GrMode := CgaMode;
                        Gm     := CGAHi;
                        Gr     := CGA;
                      End;

          HercMono  : GrMode := HerMode;

          Ega,Ega64,
          EgaMono   : If Gm = EgaLo Then
                        Begin
                          GrMode := CgaMode;
                          Gm     := CgaHi;
                          Gr     := CGA;
                        End
                          Else
                            GrMode := EgaMode;
          VGA,IBM8514
                    : Begin
                        GrMode := VgaMode;
                        Gm     := VgaHi;
                        Gr     := VGA;
                        LastLine := 57;
                      End;
          Else
            Begin
              Error(30,'');
              Terminate;
            End;
          End; { Case Gr }
    End; { Case GrMode }

  SetPrvRes;

  Case GrMode Of
    EgaMode : LoadEga;
    CgaMode : LoadCga;
    HerMode : LoadHer;
    End;
End;

Procedure LoadChiIn(FName:FnTyp);
Var Tf : Text;
    Ws : String;
    F1,
    F2 : String[16];
    Poz: Byte;
Begin
  {$I-}
  Assign(Tf,Fname);
  Reset(Tf);
  {$I+}
  If IoResult = 0 Then
    Begin
      VoltChiIn := True;
      writeln(drv4);
      {$I-}
      Ws := '';
      While (NOT EOF(Tf)) AND (Ws = '') Do ReadLn(Tf,Ws);

      If NOT Eof(Tf) Then
      Repeat
        UpperCase(Ws);
        MaxChiFont := 1;
        While (NOT EOF(Tf)) AND (Copy(Ws,1,4) = 'FONT') Do
        Begin
          Delete(Ws,1,5);
          Poz := Pos('=',Ws);
          If Poz = 0 Then Poz := Pos(' ',Ws);
          ChiFont[MaxChiFont]  := Copy(Copy(Ws,1,Poz-1),1,8);
          While (Poz < Length(Ws)) AND (Ws[Poz] In [' ','=']) Do Inc(Poz);
          EkSzFont[MaxChiFont] := Copy(Copy(Ws,Poz,255),1,8);
          ReadLn(Tf,Ws);
          UpperCase(Ws);
          If (Ws <> '') AND (MaxChiFont < 20) Then Inc(MaxChiFont);
        End;
      Until (EOF(Tf)) OR (Ws = '');

      For Cik := 1 To MaxChiFont Do
      Begin
        Write(ChiFont[Cik],' -> ');
        GotoXY(14,WhereY);
        WriteLn(EkSzFont[Cik]);
      End;

      If NOT (EOF(Tf)) Then
      Begin
        ReadLn(Tf,Chi_In.Ezt);
        ReadLn(Tf,Chi_In.Erre);
      End
      Else VoltChiIn := False;

      {$I+}
      Close(Tf);
    End;

End;

Procedure LoadAscIn(FName:FnTyp);
Var Tf : Text;
Begin
  {$I-}
  Assign(Tf,Fname);
  Reset(Tf);
  {$I+}
  If IoResult = 0 Then
    Begin
      KonvName[2] := Fname;
      writeln(drv1);
      {$I-}
      ReadLn(Tf,Asc_In.Ezt);
      ReadLn(Tf,Asc_In.Erre);
      {$I+}
      Close(Tf);
    End
    Else Error(1,FName);

End;

Procedure LoadAscOut(FName:FnTyp);
Var Tf : Text;
    Ezt,Erre : String;
    Poz : Integer;
Begin
  {$I-}
  Assign(Tf,FName);
  Reset(Tf);
  {$I+}
  If IoResult = 0 Then
    Begin
      KonvName[3] := Fname;
      writeln(drv2);
      {$I-}
      ReadLn(Tf,Asc_Out.Ezt);
      ReadLn(Tf,Asc_Out.Erre);

      (*
      For Cik := 1 To Length(Ezt) Do
      Begin
        Poz := Pos(Ezt[Cik],Asc_Out.Ezt);
        If Poz = 0 Then
        Begin
          Asc_Out.Ezt := Asc_Out.Ezt + Ezt[Cik];
          Asc_Out.Erre := Asc_Out.Erre + Erre[Cik];
        End
        Else
        Begin
          Asc_Out.Ezt[Poz] := Ezt[Cik];
          Asc_Out.Erre[Poz] := Erre[Cik];
        End;
      End;
      *)

      {$I+}
      Close(Tf);
    End
    Else Error(1,FName);
End;

Procedure LoadKeyIn(FName:FnTyp);
Var Tf : Text;
    Ezt,Erre : String;
    WS : String;

Begin
  {$I-}
  Assign(Tf,Fname);
  Reset(Tf);
  {$I+}
  If IoResult = 0 Then
    Begin

      KonvName[1] := Fname;
      writeln(drv3);
      {$I-}

      For Cik := 1 To 4 Do Key_InSt[Cik] := '';

      Ws := '';

      Repeat

        For Cik := 1 To 4 Do
        Begin
          If NOT EOF(Tf) Then
          Begin
            If Ws = '' Then ReadLn(Tf,Ws);
            While Pos(' ',Ws) > 0 Do Delete(Ws,Pos(' ',Ws),1);
            Key_InSt[Cik] := Key_InSt[Cik] + Ws;
            Ws := '';
          End;
        End;

        While (NOT EOF(Tf)) AND (Ws = '') Do ReadLn(Tf,Ws);

      Until EOF(Tf);

      UpperCase(Fname);

      VIDEOTONKEY := (Pos('VIDEOTON.KEY',Fname) > 0);
      MAGYARKEY   := (Pos('MAGYAR.KEY',Fname) > 0);

      (*
      WriteLn(LST,Key_In.Ezt);
      WriteLn(LST,Key_In.EztFont);
      WriteLn(LST,Key_In.Erre);
      WriteLn(LST,Key_In.ErreFont);
      *)

      {$I+}
      Close(Tf);
    End
    Else Error(1,FName);

End;

End.