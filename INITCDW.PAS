UNIT InitCdw;

{$O+}

INTERFACE

USES Crt,Dos,WindowM,MenuErr,

  {$IFNDEF CDVIEW}
  {$IFNDEF VER3}
  CalcCdw,
  {$ENDIF}
  {$ENDIF}

  {$IFNDEF DPMI}
  Overlay,
  {$ENDIF}

  InputCdw,InputOVR,FileCdw,Video,HeapCdw,

  {$IFNDEF CDVIEW}
  ModemCdw,
  {$ENDIF CDVIEW}

  {$IFDEF BEMUTAT}
  Bemutat,
  {$ENDIF}


  {$IFDEF DEBUG}
  HexKit,
  {$ENDIF}

  {$IFNDEF CDVIEW}
  {$IFNDEF VER3}
  KvtFa,
  {$ENDIF}
  {$ENDIF}

{$IFDEF PROBA}
  Printer,
{$ENDIF}

{$IFDEF HELYESKE}
  Elemez,
{$ENDIF}

  EmsCdw,
  XmsCdw;

{$IFNDEF CDVIEW}

Function EkSzer(Num : Byte):St80;
Procedure WriteFirstWindow;
Procedure Change_Dmask;
Procedure Change_Dir(Tip : Byte);
Procedure Nyelvesz;

{$ENDIF}

Procedure Init;         (******** Init Javitva !!! ********)


IMPLEMENTATION


{$IFNDEF CDVIEW}
{$I CIMDAT.CDW}

{*********************************************************************}


Function EkSzer(Num : Byte):St80;

Var Db,C,Cik,X : Integer;
    Ws         : St80;
    Wsc        : Array[0..80] Of Char Absolute Ws;
Begin

  Dec(Num,6);
  FillChar(Wsc[1],80,' ');
  Ws[0] := #80;

  C := 1;

  While Num > 0 Do     { Seek to Nth. record }
  Begin
    Db := CimDat[C];
    For Cik := 1 To Db Do Inc(C,2);  { Skip  Poz,Len   }
    Inc(C);                          { Next Count byte }
    Dec(Num);
  End;

  Cik := 1;

  For X := 1 To CimDat[C] Do
  Begin
    FillChar(Wsc[CimDat[C+Cik]],CimDat[C+Cik+1]-1,$B0);
    Ws[CimDat[C+Cik]+CimDat[C+Cik+1]-1] := #$B2;
    Inc(Cik,2);
  End;

  Ekszer := Ws;

End;
{$ENDIF}


{Procedure CheckMachine;
Begin
  InLine($89/$E0/
         $60/
         $39/$E0/
         $74/$07/
         $C6/$06/GepTipus/0/
         $EB/$05/
         $C6/$06/GepTipus/1/
         $89/$C4);
End;
}

Const ElsoWin : Boolean = True;


{$IFNDEF CDVIEW}
Procedure WriteFirstWindow;
Var Yc : Integer;
Begin
  If ElsoWin Then Yc := 1
             Else Yc := 23-5;
  ElsoWin := False;

  {$IFDEF DEMO}
     If Eloszar Then ExName := ExName + ' DEMO';
  {$ENDIF}

  {$IFDEF BEMUTAT}
   If Eloszar Then ExName := ExName + ' - bemutat¢';
  {$ENDIF}

  {$IFDEF HALO}
    UserName := GetUserName(GetConnectionNumber);
    If Eloszar Then
    Begin
      Str(Jogosultak_Szama,Wst);
      ExName := ExName + ' - h l¢zati ' + '('+Wst+' user)';
    End;

  {$ENDIF}

  {$IFDEF CGAONLY}
     If Eloszar Then ExName := ExName + ' CGA';
  {$ENDIF}

  BOOL := CREATE_WINDOW(1,Yc,80,Yc+2,ExName,CA[DispMode,1],CA[DispMode,3]);

  Gotoxy(7,1); Write(Copyright2);

  Eloszar := False;

End;

{$ENDIF}

Procedure hiba;
Begin
  DirectVideo := False;
  Writeln('Saj ts gos bels” hiba. Kil‚pek.');
  DirectVideo := True;
  Halt;
End;

Procedure NyelvEsz;
Var Axr,Bxr,Cxr,Dxr,Dir,Sir : Word;
Begin

  Asm
    XOR AX,AX

    INT NYELVESZINT1

    MOV AXR,AX
    MOV BXR,BX
    MOV DIR,DI
    MOV SIR,SI

  END;

  Mutato_1 := Ptr(BXR,DIR);
  Mutato   := Ptr(BXR,Mutato_1^[12]); { A tomb 12.-ik eleme }

  Register.Ax := Axr;
  Register.Bx := Bxr;

  Register.Cx := Mutato_1^[6];
  Register.Dx := Mutato_1^[7];

  Register.Si := SIR;

End;

Function InitGIB: Boolean;
Var Axr,DSr,SIr,AMHotKey,MAHotKey : Word;
    Ws        : String[80];
    Hot1,Hot2 : String[40];
    ReservedCh,
    ReservedSc: Set Of Byte;
Begin

  Asm
    MOV AX,$F81C { Get GIB's status }
    PUSH BP
    INT  $16
    POP  BP
    MOV  AXR,AX
  End;

  If AXR = $CEBA Then
  Begin
    Asm
      PUSH DS
      MOV  AX,$F81F { Get Address of string }
      PUSH BP
      INT  $16
      POP  BP
      MOV  AX,DS
      MOV  DSr,AX
      MOV  SIr,SI
      MOV  AMHotKey,BX
      MOV  MAHotKey,DX
      POP  DS
    End;

    GIBWord := Ptr(DSr,SIr);

    ReservedCh := TilosChars + CommandChars;
    ReservedSc := TilosScans + CommandScans;

    ErrorStNum := 2;


    If (Hi(AMHotKey) In ReservedSc) OR (Lo(AMHotKey) In ReservedCh) Then
    Begin
      Ws := CharOver;
      {$IFNDEF ANGOL}
      If Lo(AMHotKey) = 0 Then Ws := Ws + 'z';
      {$ENDIF}
      Ws := Ws + ' ' + KeyName(Hi(AMHotKey),Lo(AMHotKey),0) + Billentyut;
      Error(20,Ws);
    End;

    If (Hi(MAHotKey) In ReservedSc) OR (Lo(MAHotKey) In ReservedCh) Then
    Begin
      Ws := CharOver;
      {$IFNDEF ANGOL}
      If Lo(MAHotKey) = 0 Then Ws := Ws + 'z';
      {$ENDIF}
      Ws := Ws + ' ' + KeyName(Hi(MAHotKey),Lo(MAHotKey),0) + Billentyut;
      Error(20,Ws);
    End;

    ErrorStNum := 1;

    InitGIB := True;
  End
  Else InitGIB := False;
End;

Procedure Init;         (******** Init Javitva !!! ********)
Var Offset,
    Cik,
    Cikl  : INTEGER;
    ch,sc : byte;
    Booli : Boolean;
    Poz   : Byte;
    Ezt,Erre  : String;
    Ws    : String[255];
    Tf    : Text;

Procedure MemoryConfig;

Var EMSMemory,
    XMSMemory,
    DSKMemory,
    OpMemory,
    RMemory,
    MegKell     : LongInt;

    ETEMS,
    ETMEM     : Word;
    EMSLKELL  : Word;
    SS        : String[10];

    PointSize : Longint;
    Lsize,
    Psize     : word;
    Cik       : Word;
    One,All   : Word;
    OsszElines: LongInt;
    Dummy     : LineType;
    IO        : Integer;
    XXX,YYY   : Integer;
    EnnyiKell,
    EnnyiBlock,
    EnnyiMarad,
    EgyBlock  : LongInt;
    GIBHand   : Word;

Begin
  NullTKi := 1;
  NullTBe := 1;

  EmsLKell  := (NoEmsKb+15) Div 16;
  VanEmsM   := Van_Ems And (Ems_Pages_Available > EmsLKell);

  VanXmsM   := False;
  XMSLines  := 0;
  XMSMemory := 0;

  EMSLines  := 0;
  EMSMemory := 0;

  DSKMemory := 0;
  VanDskM   := False;

  EmsTombC  := 0;

  GibHand   := $ABCD;

  If VanXms Then
    Begin
      XmsAvail(One,All);

      If GibEnabled Then
        Begin
          If One > 600 Then
            One := 300
          Else
            One := One Div 2;

          XmsAlloc(One,GibHand);
        End;
    End;


  If VanEmsM Then
    Begin
      Free_Pages := Ems_Pages_Available-EmsLKell;
      Allocate_Ems_Pages(Free_Pages,Ems_Handle);
      EmsSeg    := Get_Ems_Segment;
      EmsLines  := Free_Pages*SperLap;
      ActEmsLap := 0;
      VanALapon   := False;
      ActLaponVan := 0;
      ActEmsLap := 0;
      Get_Ems_Page(Ems_Handle,ActEmsLap);
    End;

  If VanXms Then
    Begin
      XmsAvail(One,All);

      If Oke And (One>NoXmsKb+5) Then
        Begin
          XmsAlloc(One,XHand);
          If Oke Then
            Begin
              VanXmsM  := True;
              XmsLines := (LongInt(One-NoXmsKb)*1024) Div C160;
            End;
        End;
    End;

  If (DiskMemPath <> '') AND (DiskMemPath[Length(DiskMemPath)] <> '\')
    Then DiskMemPath := DiskMemPath + '\';

  If DskLines > 0 Then
    Begin
      FillChar(Dummy,C80,'a');
      FillChar(Dummy.Chars[C80],C80,'b');
      Write(MemSt,' : ');
      XXX := WhereX;
      YYY := WhereY;

      Assign(DskFil,DiskMemPath+'EK'+EndOfName+'.$$$');
      {$I-}
      ReWrite(DskFil,C160);
      {$I+}
      Cikl := 0;
      Io := IoResult;

      EnnyiKell  := LongInt(DskLines)*C160;
      EgyBlock   := $C000 Div C160;       { egy blokk hany sor }
      EnnyiBlock := EnnyiKell Div (EgyBlock*C160);
      EnnyiMarad := (EnnyiKell-EgyBlock*C160*EnnyiBlock) Div C160;

      While (Io=0) And (Cikl<EnnyiBlock) Do
        Begin
          {$I-}
          BlockWrite(DskFil,Dummy,EgyBlock);
          {$I+}
          Io := IoResult;
          If IO = 0 Then Inc(Cikl);
          GotoXy(XXX,YYY);
          Write(EgyBlock*Cikl:5,LineSt);
        End;
      Cikl := Cikl*EgyBlock;
      If (IO = 0) And (EnnyiMarad <> 0) Then
        Begin
          {$I-}
          BlockWrite(DskFil,Dummy,EnnyiMarad);
          {$I+}
          If IoResult = 0 Then
            Inc(Cikl,EnnyiMarad);
          GotoXy(XXX,YYY);
          Write(Cikl:5,LineSt);
        End;
      Writeln;
      DskLines  := Cikl;
      DskMemory := LongInt(DskLines)*C160;
      VanDskM   := DskLines > 0;
      If Not(VanDskM) Then
        DelDskFile
    End;

  If VanEmsM Or VanXmsM Or VanDskM Then
    Begin
      MaxIndex  := MaxIndexEv;
      MaxAIndex := MaxAIndexEv;

      EmsTombM  := (MaxIndex*2+1)*2+2;

      ETEMS := 0;
      If EmsMaradek <> 0 Then
        Begin
          ETEMS := EmsMaradek Div C160;
          If ETEMS > EmsTombM Then
            ETEMS := EmsTombM;
          If EmsMaradek = $C000 Then
            For Cik := 1 To ETEMS Do
              EmsTomb[Cik].Sor := Ptr(EmsSeg+$400+(Cik-1)*Cp16,0)
          Else
            For Cik := 1 To ETEMS Do
              EmsTomb[Cik].Sor := Ptr(Seg(Arr^)+Cp16*(Cik-1),
                                      Ofs(Arr^)+MennyiKell)
        End;
      If ETEMS < EmsTombM Then
        Begin
          ETMEM   := EmsTombM-ETEMS;
          MegKell := (longint(ETMEM)*C160);

          If MaxAvail < MegKell Then
            Begin
              Str(MegKell-MaxAvail,SS);
              Error(4,' -'+SS+' byte');
              Terminate;
            End;

          GetMem(EmsTomb[ETEMS+1].Sor,MegKell);
          For Cik := ETEMS+2 To EmsTombM Do
            EmsTomb[Cik].Sor := Ptr(Seg(EmsTomb[ETEMS+1].Sor^)+(Cik-ETEMS-1)*Cp16,
                                    Ofs(EmsTomb[ETEMS+1].Sor^));

        End;
      For Cik := 1 To EmsTombM Do
        With EmsTomb[Cik] Do
          Begin
            FillChar(Sor^,C160,0);
            Cou    := 0;
            Sorsz  := 0;
          End
    End;

  OpMemory  := MaxAvail-16;


  If VanEmsM Or VanXmsM Or VanDskM Then
    Begin
      If EmsLines+MaxMemLine > MaxLine Then
        Begin
          EmsLines := MaxLine-MaxMemLine;
          XmsLines := 0;
          DskLines := 0;
        End
      Else
        If EmsLines+XmsLines+MaxMemLine > MaxLine Then
          Begin
            XmsLines := MaxLine-MaxMemLine-EmsLines;
            DskLines := 0
          End
        Else
          If EmsLines+XmsLines+MaxMemLine+DskLines > MaxLine Then
            Begin
              DskLines := MaxLine-MaxMemLine-EmsLines-XmsLines;
            End;

      EmsMemory := longint(EmsLines)*C160;
      XmsMemory := longint(XmsLines)*C160;
      DskMemory := longint(DskLines)*C160;
    End;

  If (EmsLines+XmsLines+DskLines)*3 > OpMemory Then
    Begin
      PointSize := (OpMemory Div 3)*3;
      OsszELines:= PointSize Div 3;
      If OsszElines >= (EmsLines+XmsLines) Then
        DskLines := OsszELines-EmsLines-XmsLines
      Else
        If OsszELines >= EmsLines Then
          Begin
            XmsLines := OsszELines-EmsLines;
            DskLines := 0;
          End
        Else
          Begin
            EmsLines := OsszELines;
            XmsLines := 0;
            DskLines := 0;
          End;

      EmsMemory := Longint(EmsLines)*C160;
      XmsMemory := Longint(XmsLines)*C160;
      DskMemory := longint(DskLines)*C160;

      OpMemory  := PointSize;
    End
  Else
    PointSize := ( (OpMemory+EmsMemory+XmsMemory+DskMemory) Div (C160+3))*3;

  Lsize     := PointSize Div 3;
  Psize     := Lsize*2;

  Rmemory   := OpMemory-PointSize;
  MemLines  := (Rmemory Div C160);
  Max_Lines := EmsLines + MemLines + XmsLines + DskLines;

  If VanDskM And (DskLines=0) Then
    Begin
      DelDskFile;
      VanDskM := False;
    End;

  If GIBHand <> $ABCD Then
    XmsDeAlloc(GIBHand);

  {$IFNDEF CDVIEW}
  ComPoint^:= ComDat[ComPort];
  {$ENDIF}

  GetMem(PointerTomb,PSize);
  GetMem(LapVegTomb,LSize);

  Mark(Heap);

  If (HeapRec.Offset > 0) AND (MemLines > 0) Then
  Begin
    Dec(RMemory,16-HeapRec.Offset);
    Dec(OpMemory,16-HeapRec.Offset);
    HeapRec.Offset := 00;
    Inc(HeapRec.Segment);
    Dec(MemLines);
    Dec(Max_Lines);
  End;

  (*
  Dec(Max_Lines,MemLines);
  MemLines := 0;
  *)

  SegHeap := Seg(Heap^);

  HeapLine := Heap;

  HeapError := @Hiba;
  ErrorAddr := @Hiba;

  For Cik := 1 To Max_Lines Do
    PointerTomb^[Cik] := Cik;

End;

Begin
  {CheckMachine;}
  FillChar(Kodolatlan,SizeOf(Kodolatlan),True);
  FillChar(JelszValt,SizeOf(JelszValt),False);

  GIBEnabled := InitGIB;
  ElSzarr := @ElSz1;


  GetIntVec(NyelvEszInt1,NyelvEszPoint);
  Cik := 0;
  Repeat
    VanNyelvEsz := (NyelvEszPoint1^[Cik] = Cik+$50);
    Inc(Cik);
  Until (Cik > 7) OR (NOT VanNyelvEsz);

  If VanNyelvEsz Then
  Begin
    NyelvEsz;     { Elso hivas : init }

    VanNyelvEsz := (Register.AX = $AAAA) OR (Register.AX = $AAAB);

    If VanNyelvEsz Then
    Begin

      SpellerNum := Register.AL - $AA;

      VanNyelveszEMS    := (Register.SI = 0);

      SzavakP.Segment   := Register.BX;

      SzoPointP.Segment := Register.BX;

      SzoPointP.Offset  := Register.DX;
      SzoDbPoint        := ptr(Seg(SzoPoint^),Register.Cx);

      GetIntVec(NyelvEszInt2,OldNyelvEszInt2);
      SetIntVec(NyelvEszInt2,@NyelvReturn);

    End;

  End;


  DoglottNyelvEsz := False;

  If VanNyelvEsz Then
    Begin
      If (SpellerNum = 0) Or (VanNyelveszEms) Then
        Begin
          Win_Stack := Ptr(Seg(SzoPoint^)+10,Ofs(SzoPoint^));
          VanFontSwap := (SpellerNum=0);
        End
      Else
        Begin
          Win_Stack := Ptr(Mutato_1^[17]+10,0);
          VanFontSwap := True;
        End;

      NyelvWinAz:= Ptr(Seg(Win_Stack^)-1,Ofs(Win_Stack^)+14);

      CLV       := Ptr(Seg(Win_Stack^)+Win_Stack_Size Div 16 + 1,
	               Ofs(Win_Stack^));

      FontHely  := Ptr(Seg(CLV^)+SizeOf(CLV^) Div 16 + 1,
	               Ofs(CLV^));
      FontHely2 := Ptr(Seg(CLV^)+SizeOf(CLV^) Div 16 + 1+$F00,
	               Ofs(CLV^));

      If NyelvWinAz^ = $ABCD Then
	Begin
	  VanNyelvEsz     := False;
	  DoglottNyelvEsz := True;
	End
      Else
	WinSKi(0); { A nyelvesz ki lemezre }

      NyelveszBent := False;
    End
  Else
    If MaxAvail >= Win_Stack_Size+SizeOf(CLV^) Then
      Begin
        GetMem(Win_Stack,Win_Stack_Size);
        GetMem(CLV,SizeOf(CLV^));
      End
    Else
      Begin
        Error(4,', tul sok rezidens program'); { De miert ? }
        Terminate;
      End;

  {$IFDEF HELYESKE}
  SpellerNum := 2;
  SzavakP.Segment   := DSeg;
  SzoPointP.Segment := DSeg;
  SzoPointP.Offset  := OFS(SzoPointTomb[0]);
  SzoDbPoint        := ptr(DSeg,OFS(SzoDarab));

  For Cik := 0 To 50 Do
    SzoPoint^[Cik] := OFS(SzoTomb[Cik]);

  VanNyelvEsz := VanHelyeske;
  {$ENDIF}

  Init_Window;

  With CLV^ Do
    Begin
      VarNum  := 0;
      HibaKod := 0;
      HibaPoz := 0;

      Condi        := '';
      GCondi       := '';
      CondiFile    := '';
    End;


  GetIntVec($1B,Vector1B);
  SetIntVec($1B,@Ctrl_Break);

  LeszBlokk := True;
  LongNum    := CheckNum;

  CrtMode := 3;    {  Mar nem absolute }
  ScrMem[CgaMode]  := Ptr($B800,$0000);
  ScrMem[HerMode]  := Ptr($B000,$0000);
  ScrMem[EgaMode]  := Ptr($A000,$0000);
  ScrMem[VgaMode]  := Ptr($A000,$0000);

  ScrMemT[CgaMode] := Ptr($B800,$0000);
  ScrMemT[HerMode] := Ptr($B000,$0000);
  ScrMemT[EgaMode] := Ptr($B800,$0000);
  ScrMemT[VgaMode] := Ptr($B800,$0000);


  FillChar(MacEnv,MaxMac*SizeOf(MacroRecord),255);

  DefKeyNum  := 0;
  PActMacnum := 1;
  RActMacnum := 1;
  MacCount   := 0;
  MacLevel   := 1;
  ActMacName := '';
  Recording  := False;

  For Cik := 1 To MaxMac Do
  Begin
    Macro[Cik]  := False;
    MacPos[Cik] := 0;
    MacName[Cik] := '';
  End;

  For Cik := 1 to MaxFontNum Do
  Begin
    Fontnames[Cik] := '';
    ChFont[Cik] := True;
  End;


  For Cik:= 1 To 4 Do
    If Not PfName[Cik] Then Filename[Cik] := UresName;

  NemVoltHelp   := True;
  Legfelso      := False;
  Legalso       := False;
  NemKellCursor := False;

  Linenum       := 00;
  Uplinenum     := 00;
  Dlinenum      := 00;
  MaxKey        := 00;

  For Cik := 1 To MaxEditor Do
  Begin
    LeftMar[Cik]       := 00;      (** !!! **)
    RightMar[Cik]      := c76-1;
  End;

  FirstPage     := 01;
  LastPage      := 9999;
  FirstPageNum  := 1;
  StopAfterPage := False;
  NyomSzam      := 1;
  LineSpace     := 0;

  LabelDist     := 1.00;
  PrevHely := NIL;


  FontOffs      := ofs(fonts^);
  ImageOffs     := ofs(image[-2]^);
  SorTabOffs    := ofs(SorTab^);


  Case GrMode Of
    CgaMode  : SorTab^ := CgaSorTab;
    EgaMode  : SorTab^ := VGASorTab;
    HerMode  : SorTab^ := HerSorTab;
    VgaMode  : SorTab^ := VGASorTab;

    End;

  {$IFNDEF CDVIEW}
  WriteFirstWindow;
  {$ENDIF}

  BOOL := CREATE_WINDOW(19,8,61,18,IniSt1,CA[DispMode,1],CA[DispMode,3]);
  MemoryConfig;
  SetWideP;


  For Cik := 1 To MaxEditor Do
  Begin
    Valtozas[Cik]  := False;
    StartLine[Cik] := 1;
    EndLine[Cik]   := 0;
    All_Lines[Cik] := 0;
    New_Kell[Cik]  := True;
    NemKells[Cik]  := 0;
  End;

  FillChar(Fonts^,SizeOf(Fonts^),$42);

  Full_Lines := 0;

  FillChar(Tabs,c78,00);


  Writeln(Max_Lines:5,LineSt);

  {$IFNDEF VER352}
  writeln('MEM :',MemLines,'   EMS :',EmsLines,'   XMS :',XmsLines);
  {$ENDIF}

  {$IFDEF BEMUTAT}
  FileDatumCheck;
  {$ENDIF}

  If Path = '' Then GetDir(0,Path);

  Read_deffile(Booli);   If Not Booli Then Terminate;
  Load_systemfont;



  {$IFNDEF CDVIEW}
  If KellHelpFile Then Read_Helpfile(Byte(WsMode));
  {$ENDIF}
  Read_Files;
  If FontPath = '' Then GetDir(0,FontPath);
  If Path = '' Then GetDir(0,Path);

  {$IFNDEF OROSZ}
  {$IFNDEF CDVIEW}
  KivetelSzotar;
  {$ENDIF}
  {$ENDIF}

  NewDisp := DispMode;
  For Cikl := 1 To MenuNum do
    With menurec[cikl] do
      Begin
        Co3 := CA[DispMode,21];
        Co2 := CA[DispMode,1];
        Co  := CA[DispMode,3];
      End;
  CurColor[Colour] := CA[Colour,22];
  CurColor[BW]     := CA[BW,22];



 {$IFNDEF CDVIEW}
  CheckRead(PathSt);
 If Not Esc Then
  Begin
    Assign(Hfil,PathSt+MHelpfile);
    {$i-} Reset(Hfil); {$i+}
    If IOresult <> 0 Then
      Begin
        Error(1,Mhelpfile);
        Kell_Help := False;
      End
    Else
      Begin
        Kell_Help := True;
        Close(Hfil)
      End;
  End
  Else Kell_Help := False;
{$ENDIF}

  BOOL := Remove_Window;
  Window(1,1,80,25);

{$IFNDEF CDVIEW}
  TextAttr := 7;
  (* TextAttr := CA[DispMode,1]; *)
  GotoXy(1,1);
  For Cikl := 23 Downto 2 Do
  Begin
    InsLine;
    IF Cikl In [6..17] Then
      Display(Ekszer(Cikl),1,1);
  End;

  If VanNyelvEsz Then
  Begin
    Keret(44,5,63,7,CA[DispMode,1]);
    {$IFDEF ANGOL}
    Display(Speller[SpellerNum]+' is active',6,45);
    {$ELSE}
    Display('A '+Speller[SpellerNum]+' akt¡v',6,46);
    {$ENDIF}
    Attribute(6,45,6,62,CA[DispMode,3]);
  End;

  If GIBEnabled Then
  Begin
    Keret(64,5,79,7,CA[DispMode,1]);
    {$IFDEF ANGOL}
    Display('GIB is active',6,65);
    {$ELSE}
    Display('A GIB akt¡v',6,66);
    {$ENDIF}
    Attribute(6,65,6,78,CA[DispMode,3]);
  End;
  EEN := 4;

  (*
  {$IFDEF ORFK}

  TextAttr := 15;
  GotoXY(20,5);
  Write(' Kiz r¢lag a Magyar Rend“rs‚g g‚pein haszn lhat¢ ');
  GotoXY(1,1);

  {$ENDIF}
  *)

  TextAttr := 31;
  {$ENDIF}


  FillImage;

  Xpos    := LeftMar[1];
  SetXoffset(0);

  Ypos := 1;
  Make_Tabulators;
  Set_Lines(LineSpace);


  {$IFNDEF CDVIEW}
  Fresh_Strings;
  {$ENDIF}

  If Path <> '' Then CD(Path);
  GetDir(0,Path);

  {$IFNDEF CDVIEW}
  (* If DispMode <> StartColor Then *)
  Begin
    BOOL := Remove_Window;   (* Attribute(4,1,4,80,CA[DispMode,1]); *)
    WriteFirstWindow;
  End;

  BOOL := CREATE_WINDOW(1,21{18},80,25{22},IniSt2,CA[DispMode,1],CA[DispMode,3]);

  KellCloseBox := True;

  LehetMar := True;
  Fresh_Info;

  {$ENDIF}

  { Mouse Init }

  Register.AX := 0;
  Intr($33,Register);
  Mouse := (Register.AX = $FFFF);

  SetMouse(True);

End; {Init}

{$IFNDEF CDVIEW}
Procedure Change_Dmask;
Begin
  BOOL := CREATE_WINDOW(25,5,55,9,IniSt3,CA[DispMode,1],CA[DispMode,3]);
  GotoXY(3,2);
  MAxStringLen := 3;
  Input_String(IniSt4,Dmask,3);
  UpperCase(Dmask);
  CurOff;
  Bool := Remove_Window;
  Fresh_Strings;
End;

Procedure Change_Dir(Tip : Byte);
Var   Ws         : FnTyp;
Procedure SetWs;
Begin
  Case Tip Of
    1: Ws := Path;
    2: Ws := FontPath;
    3: Ws := AlapPath;
    4: Ws := DiskMemPath;
  End;
  If (Ws <> '') AND (Ws <> '\') AND
     ((Length(Ws) > 3) AND (Ws[Length(Ws)] = '\'))
  Then
    Dec(Byte(Ws[0]));
End;

Begin
  BOOL := CREATE_WINDOW(10,5,71,9,Szov[Tip]+IniSt5,CA[DispMode,1],CA[DispMode,2]);
  GotoXY(2,2);

  SetWs;

  MaxStringLen := FnSize;
  Input_String(IniSt6,Ws,39);
  UpperCase(Ws);

  {$IFNDEF VER3}
  If (Ws='') and (not Esc) then
    Begin
      CurOff;
      Ws:=A_Fa;
      CurOn;
    End;
  {$ENDIF}

  If Ws='' then
    BEGIN
      SetWs;
      Esc:=True;
    End;
  CurOff;
  If NOT ESC Then
  Begin
    UpperCase(Path);
    Case Tip Of

      1: Begin
           CheckFn(Ws);
           If NOT Esc Then
           Begin
             Path := Ws;
             CD(Path);
             GetDir(0,Path);
             Fresh_Info;
           End;
         End;
      2: Begin
           FontPath := Ws;
           CD(Fontpath);   { Error vizsgalat }
           GetDir(0,FontPath);
           CD(Path);
         End;
      3: Begin
           AlapPath := Ws;
           CD(AlapPath);   { Error vizsgalat }
           GetDir(0,AlapPath);
           CD(Path);
         End;
      4: Begin
           DiskMemPath := Ws;
           CD(DiskMemPath);   { Error vizsgalat }
           GetDir(0,DiskMemPath);
           CD(Path);
         End;

    End; {Case}

  End;
  Bool := Remove_Window;
End;
{$ENDIF}

End.
