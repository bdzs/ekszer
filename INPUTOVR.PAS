Unit InputOvr;


{$I MEMORY.CDW}
{$O+}
Interface

Uses
     Crt,
     Dos,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     Video,
     WindowM,
     MenuErr,
     Inputcdw,
     BGI,
     {$IFDEF HALO}
     {Halozat,}
     {$ENDIF}
     {$IFDEF EKNET} EkNet, {$ENDIF}
     HeapCdw,

{$IFNDEF CDVIEW}
     ModemCDW,
     Mod_save,
{$ENDIF}

{$IFDEF PROBA}
     Printer,
{$ENDIF}

{$IFDEF EKSZINFO}
     EkszInf,
{$ENDIF}

     SpeakCdw,
     EmsCDW;

{ Innen mehetnek at }


{$IFNDEF CDVIEW}

Procedure KivetelSzotar;
Procedure Get_Pic_Name;
Procedure Main_Help(Num : Integer);
Procedure Key_Help(Num : Integer; Var Character,Scan,Font : Byte);

Procedure Input_Conditions( Check : Boolean);
Procedure View_Vars;
{$ENDIF}

{$IFNDEF CDVIEW}
Procedure Temp_Backup(Mode : SaveType);

{$IFNDEF Demo} { demo1 volt}
Procedure Save(Var Filename: FnTyp; SaveMode : SaveType; FileMode : Filetype);
Procedure New_save(VAR Fil : File;  Tip : FileTipus);
Procedure ASCII_Save(Var Fil : Szoveg; Tipus : FileType );
{$ENDIF}
{$ENDIF}


{$IFNDEF CDVIEW}
PROCEDURE DIR(valami: string; VAR valasz: nevtomb; VAR valasz_db: word; VAR utvonal : string);
Procedure Save_Configuration;
Procedure Save_Parameters;
Procedure Szotarba(St: String);
Procedure Ctrl_Alt_Help(Mode : KeyMode);
PROCEDURE Alt_Help(sorszam : word; VAR help_sz : string);
PROCEDURE Ctrl_Help(sorszam : word; VAR help_sz : string);
PROCEDURE Input_FileName(kiir : string; VAR inpu : string; hossz : byte; Ujsor : boolean);
{$ENDIF}

Procedure ScreenSave(Gr:Boolean);

{$IFDEF SECRET}
Procedure InputJelszo(GR:Boolean;Uj:Boolean;FFn:ST16);
{$ENDIF}


PROCEDURE choose(Var dir_tomb: nevtomb; var dir_attr: attrtomb; dirhossz: integer;
                 DirDb: Integer; Var DirDates,FileDates,FileSizes);


{$IFDEF LEUTES}
Procedure Leutes(EdNum : Integer);
{$ENDIF}

{$IFDEF LICENC}
Procedure SetEmblemaHely;
{$ENDIF}

{ Idaig mehetnek at }

Const

wkx1: integer =  6;
wky1: integer =  8;
wkx2: integer = 75;
wky2: integer = 20;

slength: integer =  12;
enged  : integer =   0;
bbbb   : Boolean = False;

Implementation

{$IFDEF OROSZ}
{$L ALTHELPO.OBJ}
{$ELSE}
  {$IFDEF ANGOL}
  {$L ALTHELPA.OBJ}
  {$ELSE}
    {$IFDEF NORVEG}
      {$L ALTHELPN.OBJ}
    {$ELSE}
      {$IFDEF ROMAN}
      {$L ALTHELPR.OBJ}
      {$ELSE}
      {$L ALTHELPM.OBJ}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

PROCEDURE Alt_Help(sorszam : word; VAR help_sz : string); External;

{$IFDEF OROSZ}
{$L CTRHELPO.OBJ}
{$ELSE}
  {$IFDEF ANGOL}
  {$L CTRHELPA.OBJ}
  {$ELSE}
    {$IFDEF NORVEG}
      {$L CTRHELPN.OBJ}
    {$ELSE}
      {$IFDEF ROMAN}
      {$L CTRHELPR.OBJ}
      {$ELSE}
      {$L CTRHELPM.OBJ}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF}

PROCEDURE Ctrl_Help(sorszam : word; VAR help_sz : string); External;

TYPE dirtomb  = array [1..Dir_darab] of string[12];

(*
CONST

CAttr_1: Array[DispType] Of Byte = ( 31, 07); { Normal attributum   }
CAttr_2: Array[DispType] Of Byte = ( 78, 07); { Kivalasztott attributum}
CAttr_3: Array[DispType] Of Byte = (127,127); { Aktualis attributum }
CAttr_4: Array[DispType] Of Byte = ( 47,127); { Aktualis kivalasztott }
CAttr_5: Array[DispType] Of Byte = ( 63,120); { Belso attributum }
CAttr_6: Array[DispType] Of Byte = ( 28,  1); { Dir attributum }
CAttr_7: Array[DispType] Of Byte = (124,  9); { Akttualis dir attrib }
CAttr_8: Array[dispType] Of Byte = ( 26,129); { ReadOnly file }
*)


{$IFNDEF CDVIEW}
Const

{$IFDEF VER3}
AltHelpKeys : Array[1..31] Of Byte =

(Alt_S,Alt_R,Alt_G,Alt_T,Alt_L,Alt_J,Alt_M,Alt_O,
 Alt_U,Alt_Z,Alt_Q,Alt_P,Alt_Y,Alt_K,Alt_N,Alt_B,
 Alt_I,Alt_C,Alt_D,Alt_0,Alt_1,Alt_2,Alt_3,Alt_4,
 Alt_5,Alt_6,Alt_7,Alt_8,Alt_9,Alt_V,Alt_W);
{$ELSE}
AltHelpKeys : Array[1..33] Of Byte =

(Alt_S,Alt_R,Alt_G,Alt_T,Alt_L,Alt_J,Alt_I,Alt_M,Alt_O,
 Alt_C,Alt_D,Alt_P,Alt_Y,Alt_K,Alt_N,Alt_B,Alt_U,Alt_Z,Alt_Q,
 Alt_0,Alt_1,Alt_2,Alt_3,Alt_4,Alt_5,Alt_6,Alt_7,Alt_8,
 Alt_9,Alt_Minus,Alt_Egyen,Alt_V,Alt_W);
{$ENDIF}

{$IFDEF VER3}
CtrlHelpKeys : Array[1..24] Of Byte =

(Ctrl_W,Ctrl_R,Ctrl_L,Ctrl_T,Ctrl_A,Ctrl_Z,Ctrl_S,Ctrl_J,
 Ctrl_E,Ctrl_D,Ctrl_K,Ctrl_F,Ctrl_C,Ctrl_G,Ctrl_V,Ctrl_P,
 0,0,0,0,0,0,Ctrl_B,Ctrl_U);
{$ELSE}
CtrlHelpKeys : Array[1..26] Of Byte =

(Ctrl_W,Ctrl_R,Ctrl_L,Ctrl_T,Ctrl_A,Ctrl_Z,Ctrl_S,Ctrl_J,
 Ctrl_E,Ctrl_D,Ctrl_K,Ctrl_F,Ctrl_C,Ctrl_G,Ctrl_V,Ctrl_P,
 0,0,0,0,0,0,Ctrl_B,0,0,Ctrl_U);
{$ENDIF}

{$IFDEF VER3}
CtrlHelpScans : Array[1..24] Of Byte =

(Alt_W,Alt_R,Alt_L,Alt_T,Alt_A,Alt_Z,Alt_S,Alt_J,
 Alt_E,Alt_D,Alt_K,Alt_F,Alt_C,Alt_G,Alt_V,Alt_P,
 Ctrl_Home,Ctrl_End,Ctrl_PageUp,Ctrl_PageDown,
 Ctrl_Balranyil,Ctrl_Jobbranyil,Alt_B,Alt_U);
{$ELSE}
CtrlHelpScans : Array[1..26] Of Byte =

(Alt_W,Alt_R,Alt_L,Alt_T,Alt_A,Alt_Z,Alt_S,Alt_J,
 Alt_E,Alt_D,Alt_K,Alt_F,Alt_C,Alt_G,Alt_V,Alt_P,
 Ctrl_Home,Ctrl_End,Ctrl_PageUp,Ctrl_PageDown,
 Ctrl_Balranyil,Ctrl_Jobbranyil,Alt_B,Ctrl_F7,Ctrl_F8,Alt_U);
{$ENDIF}

 CtrlAltHelpKeys : Array[1..1] Of Byte =

(Alt_A);

 CtrlShiftHelpKeys : Array[1..2] Of Byte =

(Ctrl_D,Ctrl_F);

 CtrlShiftHelpScans : Array[1..2] Of Byte =

(Alt_D,Alt_F);

Var AsciiCode,ScanCode    : Byte;
    BlokkHelpScans: Array [1..40] Of Byte;
    BlokkHelpKeys : Array [1..40] Of Byte;

{$ENDIF}

Procedure SzToDollar(Var S: String);
Begin
  If (S[1] = 's') AND (S[2] = 'z') Then
  Begin
    Delete(S,1,1);
    S[1] := '$';
  End;
End;

Procedure DollarToSz(Var S: String);
Begin
  If S[1] = '$' Then
  Begin
    S[1] := 'z';
    Insert('s',S,1);
  End;
End;


{$IFNDEF CDVIEW}

{$I SZOTARBA.CDW}
{$I CONDI.CDW}

{$ENDIF}

{$I CHOOSE.CDW}


Procedure ScreenSave(Gr:Boolean);
Var
    Scr  : ^GscTip;
    ScrT : ScTip;
    LukX,
    LukY : Word;
    IranybaKell,
    IranybaMent  : word;
    Irany,
    Eirany : Byte;
    Fil    : File Of GscTip;
    KellFile : Boolean;
    IO : Integer;
    UresSor,
    TeleSor : Array[1..80] Of Byte;
    scrs,
    inc1,
    inc2,
    ovf     : Word;
    EgySorY : Byte;
    OldJel  : String[80];
    EgaPlane: Boolean;
    BackC,
    ColC    : Byte;
    OldMsg  : String[80];

    { Vigyazat ! Grafikus modban a DATA szegmenst hasznalhatja puffernek ! }

Procedure PutOneHole(KirakMode:Byte);
Var Cikl : Integer;
    St   : String[36];
Begin
  Case KirakMode Of
    0: { Kirakas  }
       Begin
         For Cikl := 1 To SorTx Do
           Begin
             Move(ScrT[LukY+Cikl-1,
                       LukX+((MaxSzelTx-Hossz[Cikl]) Div 2),
                       1],
                  St[1],
                  Hossz[Cikl]*2);
             St[0] := Char(Hossz[Cikl]*2);
             Set_String(St,LukY+Cikl-1,LukX+((MaxSzelTx-Hossz[Cikl]) Div 2))
           End;
       End;
    1: { Leszedes }
       Begin
         Spc[0] := Char(MaxSzelTx*2);
         For Cikl := 1 To SorTx Do
           Set_String(Spc,LukY+Cikl-1,LukX)
       End;
  End;
End;

Procedure Ginit;
Begin
  FillChar(UresSor,80,0);
  FillChar(TeleSor,80,$FF);
  Case GrMode Of
    CgaMode :  begin
                scrs := $b800;
                inc1 := $2000;
                inc2 := 80;
                ovf  := $4000;
                EgySorY := 5-1; { CGA !!! }
               end;
    EgaMode,
    VgaMode :  begin
                scrs := $a000;
                inc1 := 80;
                inc2 := 0;
                ovf  := $ffff;
                EgySorY := 8-1; { EGA !!! }
                If EgaPlane Then
                  Begin
                    SetPaletta(0,0);   { 0 = Black }
                    If BackC = 0 Then { Ha fekete a hatter }
                      Begin { Ha fekete volt a hatter }
                        SetPaletta(4,56);               { Szurke }
                        If ColC = 56 Then
                          SetPaletta(4+2,15)
                        Else
                          SetPaletta(4+2,ColC);
                      End
                    Else
                      Begin
                        SetPaletta(4+2,ColC);
                        SetPaletta(4,BackC);
                      End
                  End;
               end;
    HerMode :  begin
                scrs := $b000;
                inc1 := $2000;
                inc2 := 90;
                ovf  := $8000;
                EgySorY := 8-1; { Herc !!! }
               end;
  End;
End;


Procedure PutOneHoleG(KirakMode:Byte);
Var  Cikl,Cikl2,Cikl3,AbsPos  :Word;

Begin
  Case GrMode Of
    CgaMode :  abspos := cgasortab[LukY-1];
    EgaMode,
    VgaMode :  abspos := Vgasortab[LukY-1];
    HerMode :  abspos := hersortab[LukY-1];
    End;

  For Cikl := 1 To FelGr Do
    For Cikl2 := 0 To EgySorY Do
      Begin
        If KirakMode = 0 Then
          Begin
            If EgaPlane Then
              SetPlane(2);
            move(MEM[Seg(Scr^):abspos+(LukX+((MaxSzelGr-HosszG[Cikl]) Div 2))+Ofs(Scr^)-1],
                 MEM[scrs:abspos+(LukX+((MaxSzelGr-HosszG[Cikl]) Div 2))-1],
                 HosszG[Cikl]);
            If EgaPlane Then
              Begin
                SetPlane(4);
                move(TeleSor,
                     MEM[scrs:abspos+(LukX+((MaxSzelGr-HosszG[Cikl]) Div 2))-1],
                     HosszG[Cikl]);
                SetPlane(15)
              End
            Else
              If Not(PreviewBan) Then
                For Cikl3 := 0 To HosszG[Cikl] -1 Do
                  MEM[scrs:abspos+(LukX+((MaxSzelGr-HosszG[Cikl]) Div 2))-1+Cikl3] :=
                  MEM[scrs:abspos+(LukX+((MaxSzelGr-HosszG[Cikl]) Div 2))-1+Cikl3] Xor 255;
          End
        Else
          move(UresSor,
               MEM[scrs:abspos+LukX-1],
               MaxSzelGr);

        inc(abspos,inc1);
        if abspos >= ovf then
        dec(abspos,ovf-inc2);
      End
End;

Procedure PozValt(Ir:Byte);
Begin
  Case Ir Of
    0:Inc(LukX);
    1:Inc(LukY);
    2:Dec(LukX);
    3:Dec(LukY);
    End;
End;

Function RosszIrany(Ir:Byte):Boolean;
Begin
  Case Ir Of
    0:RosszIrany := LukX = (80-MaxSzelTx+1);
    1:RosszIrany := LukY = (25-SorTx+1);
    2:RosszIrany := LukX = 1;
    3:RosszIrany := LukY = 1;
    End;
End;

Function RosszIranyG(Ir:Byte):Boolean;
Begin
  Case Ir Of
    0:RosszIranyG := LukX = (80-MaxSzelGr+1);
    1:RosszIranyG := LukY = ((LastLine+2)-FelGr+1);
    2:RosszIranyG := LukX = 1;
    3:RosszIranyG := LukY = 1;
    End;
End;

Function EnnyiKell(Ir:Byte):Byte;
Begin
  If Gr Then
    Case Ir Of
      0,2:EnnyiKell := Random(30)+20;
      1,3:EnnyiKell := Random(20)+20;
      End
  Else
    Case Ir Of
      0,2:EnnyiKell := Random(30)+20;
      1,3:EnnyiKell := Random(10)+15;
      End
End;

Procedure KeybHand;Assembler;
ASM
  POP   BP  { Kiveszi az automatikusan generalt PUSH BP - t}

  Push  AX
  Push  DS

  MOV   AX,Seg @Data
  MOV   DS,AX
  MOV   AL,1

  MOV   DS:[VANKEY],AL

  PUSHF
  Call  DS:[OldVec]

  POP   DS
  POP   AX

  IRET
End;

Procedure CheckMouse;
Var
  MoveX,MoveY : Integer;
  Gomb1,Gomb2 : Boolean;
Begin

  If Mouse Then
  Begin
    Register.AX := 11;
    Intr($33,Register);
    MoveX := Register.CX;
    MoveY := Register.DX;

    Register.AX := 5;
    Register.BX := 0;
    Intr($33,Register);
    Gomb1 := Register.BX > 0;

    Register.AX := 5;
    Register.BX := 1;
    Intr($33,Register);
    Gomb2 := Register.BX > 0;

    MouseMoved := Gomb1 OR Gomb2 OR (Abs(MoveX) + Abs(MoveY) > 0);

  End;

End;

Begin
  OldMsg := '';
  If Not MostExtVan Then
    Begin
      BackC := BackG[EditNum];
      ColC  := Color[EditNum];
      InScrSave := True;
      Repeat
        VanKey := False;
        TimeOutJ := False;

        GetIntVec(9,OldVec);
        SetIntVec(9,@KeybHand);

        ASM STI END;

        If Gr Then
          Begin
            EgaPlane := (GrMode In [EgaMode,VgaMode]) And Not(PreviewBan);
            optimalheap;
            KellFile := PointSize < ((SizeOf(Scr^)+15) Div 16);
            (* KellFile := True; *)

            (*
            If KellFile Then
              Begin
                SetIntVec(9,OldVec);
                InScrSave := False;
                Exit;
              End;
            *)

            If KellFile Then
              Begin
                Scr := @COMPORT;  { Data segment eleje !!!!!! }
                Assign(Fil,'SA'+EndOfName+'.$$$');
                {$I-}
                ReWrite(Fil);
                IO := IoResult;
                Write(Fil,Scr^);
                IO := IO Or IoResult;
                Seek(Fil,0);
                IO := IO Or IOResult;
                {$I-}
                If IO <> 0 Then
                  Begin
                    SetIntVec(9,OldVec);
                    InScrSave := False;
                    Exit;
                  End;
              End
            Else
              Scr := StartPoint;


            Randomize;
            Scr^ := ScrMem[GrMode]^;

            FillChar(ScrMem[GrMode]^,SizeOf(GscTip),0);

            LukX := 1;
            LukY := 1;
            Ginit;
            PutOneHoleG(0);   { Kirakas }
            Irany := 0;
            IranybaMent := 0;
            IranybaKell := EnnyiKell(Irany);
            Repeat

              {$IFDEF HALO}
                {$IFNDEF NEMFIGYEL}
                GetMessage;
                {$ENDIF}
              {$ENDIF}

              CheckMouse;
              Delay(20);

              PutOneHoleG(1); { Leszedes }
              PozValt(Irany);

              {$IFDEF HALO}
                {$IFNDEF NEMFIGYEL}
                GetMessage;
                {$ENDIF}
              {$ENDIF}

              PutOneHoleG(0); { Kirakas  }
              Inc(IranybaMent);

              If (IranybaMent = IranybaKell) Or
                 RosszIranyG(Irany) Then
                Begin    { mar eleget ment, vagy a szelehez ert }
                  Eirany := Irany;
                  While RosszIranyG(Irany) Or (Eirany=Irany) Do
                    Irany := Random(4);
                  IranybaMent := 0;
                  IranybaKell := EnnyiKell(Irany);
                End;
            Until VanKey OR MouseMoved
            {$IFNDEF NEMFIGYEL}
            {$IFDEF HALO}
            Or ((Message <> '') And (Not InMsg))
            {$ENDIF}
            {$ENDIF}
            ;
            SetIntVec(9,OldVec);
            If EgaPlane Then
              Begin
                Ega_Hatter(BackC);
                Set_Ega_Color(ColC);
              End;
            ScrMem[GrMode]^ := Scr^;
            If KellFile Then
              Begin
                {$I-}
                Read(Fil,Scr^);
                IO := IOResult;
                Close(Fil);
                IO := IO Or IOResult;
                Erase(Fil);
                IO := Io Or IOResult;
                {$I+}
                If IO <> 0 Then
                  Begin
                    SetIntVec(9,OldVec);
                    InScrSave := False;
                    Terminate;
                  End;
              End;
            OptimalHeapRestore;
          End  { If GR }
        Else
          Begin
            Randomize;
            ScrT := ScrMemT[GrMode]^;
            FillChar(ScrMemT[GrMode]^,SizeOf(ScTip),0);
            LukX := 1;
            LukY := 1;
            PutOneHole(0);   { Kirakas }
            Irany := 0;
            IranybaMent := 0;
            IranybaKell := EnnyiKell(Irany);
            Repeat

              {$IFDEF HALO}
                {$IFNDEF NEMFIGYEL}
                GetMessage;
                {$ENDIF}
              {$ENDIF}

              CheckMouse;
              Delay(60);

              PutOneHole(1); { Leszedes }
              PozValt(Irany);

              {$IFDEF HALO}
                {$IFNDEF NEMFIGYEL}
                GetMessage;
                {$ENDIF}
              {$ENDIF}

              PutOneHole(0); { Kirakas  }
              Inc(IranybaMent);
              If (IranybaMent = IranybaKell) Or
                 RosszIrany(Irany) Then
                Begin    { mar eleget ment, vagy a szelehez ert }
                  Eirany := Irany;
                  While RosszIrany(Irany) Or (Eirany=Irany) Do
                    Irany := Random(4);
                  IranybaMent := 0;
                  IranybaKell := EnnyiKell(Irany);
                End;
            Until VanKey OR MouseMoved
            {$IFDEF HALO}
            Or ((Message <> '') And (Not InMsg))
            {$ENDIF};
            SetIntVec(9,OldVec);
            ScrMemT[GrMode]^ := ScrT;
          End;
         LastKeyIdo := IdoAlap;

         While KeyPressed Do
           If ReadKey = ' ' Then;

         {$IFDEF SECRET}
         If VanJelszo Then
           Begin
             PuffiRekurzio := True;
             OldJel := JelszoDe;
             JelszoDe := '';
             Repeat
               TimeOutJ := False;
               InputJelszo(GR,False,'');
               If (JelszoDe <> OldJel) And
                  Not(TimeOutJ) Then
                 Error(20,'Hib†s jelsz¢megad†s');
             Until (JelszoDe = OldJel) Or TimeOutJ;
             If TimeOutJ Then
               Begin
                 JelszoDe := OldJel;
                 OldJel := '';
                 VanJelszo := True;
               End;
             PuffiRekurzio := False;
           End;
         {$ENDIF}

         {$IFNDEF NEMFIGYEL}
         {$IFDEF HALO}
         If (Message <> '') And (Not InMsg) Then
           Begin
             TimeOutJ := False;
             OldMsg := Message;
             WriteMessage;
             If Not(TimeOutJ) Then
               OldMsg := '';

           End;
         {$ENDIF}
         {$ENDIF}

      Until
            {$IFDEF SECRET}

            {$IFNDEF HALO}
            Not(VanJelszo) Or
            Not(TimeOutJ);
            {$ELSE}

            Not(TimeOutJ) Or
            (Not(VanJelszo) And (OldMsg=''));

            {$ENDIF}
            {$ELSE}

            {$IFDEF HALO}
            Not(TimeOutJ) And
            {$ENDIF}

            True;
            {$ENDIF}

      InScrSave := False;
      {$IFDEF HALO}
      If (Message = '') And (Not InMsg) Then
        Message := OldMsg;
      {$ENDIF}
    End;
End;


{$IFDEF SECRET}

Procedure InputJelszo(GR:Boolean;Uj:Boolean;FFN:St16);
Var Kesz  : Boolean;
    Jel1,
    Jel2  : St80;
    Cur   : Byte;

    OldKell,
    OldInv  : Boolean;
    OldGf,
    OldX,
    OldY    : Byte;
    ScBuf   : Array[1..12*80*8+200] Of Byte;

Procedure InputOne(ss:St80;Var ST:st80;Y:Word);
Var Asc,
    Scan:Byte;
    spac : st80;
    Kesz : Boolean;
Begin

  FillChar(spac,SizeOf(Spac),' ');
  spac[0] := #61;
  If Gr Then
    Begin
      Gotox(4,y*2);
      Writ(ss);
    End
  Else
    Display(ss,Y,4);
  Kesz := False;

  Repeat
    ST := '';
    If Gr Then
      Begin
        GotoX(4+Length(ss),Y*2);
        Writ(Spac);
        GotoX(4+Length(ss),Y*2);
      End
    Else
      Begin
        Display(spac,Y,4+Length(ss));
        Attribute(Y,4+Length(ss),Y,4+Length(SS)+60,CA[DispMode,15]);
      End;
    Inverz := True;
    TimeOutJ := False;
    Puffi(Asc,Scan);
    {Writeln(lst,'Asc :',asc,'  Scan :',Scan,'  Timeout:',TimeOutJ);}
    While  Not (ASC In[27,13]) And
           Not (TimeOutJ) Do
      Begin
        If Length(St) < 61 Then
          Begin
            St := St + Char(Asc);
            If Gr Then
              Writ('X')
            Else
              DispCh('∞',Y,4+Length(ss)+Length(St)-1);
            Sound(800);
            Delay(10);
            Nosound;
          End;
        Puffi(Asc,Scan)
      End;
    Inverz := False;
    ESC := (ASC=27);

{$IFDEF JELSZO6}
    If Not (ESC Or TimeOutJ) Then
      If (Length(St) >= 6) Or (ST='') Then
        Kesz := True
      Else
        Error(20,' A legkisebb jelsz¢hossz 6 karakter ');

    If Kesz Then St := St + St;

{$ELSE}
    If Not (ESC Or TimeOutJ) Then
      If (Length(St) >= 12) Or (ST='') Then
        Kesz := True
      Else
        Error(20,' A legkisebb jelsz¢hossz 12 karakter ');
{$ENDIF}

  Until ESC OR Kesz Or TimeOutJ
End;

Begin
  InJelszo := True;
  If Not Gr Then
    Begin
      Cur    := Gcur;
      CurOff;
      If Uj Then
        BOOL := CREATE_WINDOW(2,8,79,13,'Jelsz¢ v†lt†s'+FFN,CA[DispMode,7],CA[DispMode,2])
      Else
        BOOL := CREATE_WINDOW(2,8,79,13,'Jelsz¢ ellenìrzÇs',CA[DispMode,7],CA[DispMode,2]);
    End
  Else
    Begin
      OldKell := NemKellCursor;
      OldInv  := Inverz;
      OldGf   := GlobalFont;
      OldX    := WherX;
      OldY    := WherY;

      GlobalFont := 0;
      Inverz     := False;
      NemKellCursor := True;
                {Xpos, width, Db,  y,puff_ofs,puff_segm,sortaboff,irany}
      FelSor_IdeOdaW(1,78,12,8*2+2,Ofs(ScBuf),Seg(ScBuf),SortabOffs,0);
      If Uj Then
        GrWindow(1,8*2+2,79,13*2+2,'Jelsz¢ v†lt†s'+FFN)
      Else
        GrWindow(1,8*2+2,79,13*2+2,'Jelsz¢ ellenìrzÇs')
    End;

  ESC  := False;
  Repeat
    Kesz := False;
    If Uj Then
      InputOne('Uj jelsz¢  : ',Jel1,10)
    Else
      InputOne('RÇgi jelsz¢: ',Jel1,10);
    If Not (ESC Or TimeOutJ) Then
      Begin
        InputOne('EllenìrzÇs : ',Jel2,11);
        Kesz := Jel1 = Jel2;
        If Not(ESC Or TimeOutJ) And Not(Kesz) Then
          Begin
            Error(20,'Hib†s jelsz¢megad†s');
            If Not Gr Then
              ClrScr;
          End
      End;
  Until ESC Or Kesz Or TimeOutJ;
  If Not (ESC Or TimeOutJ) Then
    If Jel1 = '' Then
      VanJelszo := False
    Else
      Begin
        FillChar(JelszValt,SizeOf(JelszValt),True);
        JelszoDe := Jel1;
        Kodol(@JelszoDe[1],Length(Jel1),@BaseBytes,2);  { Bazis eloallitas }
        VanJelszo := True;
      End;

  InJelszo  := False;
  ESC := False;

  If Not Gr Then
    Begin
      Bool := Remove_Window;
      Case Cur Of
        1 : CurOn;
        2 : BigCur;
      End;
      {$IFNDEF CDVIEW}
      If LehetMar Then
        Fresh_Info;
      {$ENDIF}
    End
  Else
    Begin
      Gotox(OldX,OldY);
      Inverz := OldInv;
      GlobalFont := OldGf;
      NemKellCursor := OldKell;
      FelSor_IdeOdaW(1,78,12,8*2+2,Ofs(ScBuf),Seg(ScBuf),SortabOffs,1);
    End;
  InJelszo  := False;
End;
{$ENDIF}


{$IFNDEF CDVIEW}
Procedure View_Vars;
Var Ch,Sc,Cur,Cik,Max : Byte;
    Wst               : String[16];
    HoSt,NapSt        : String[2];
    Csik              : String[60];

Begin

  With CLV^ Do
    Begin
      InVars := True;

      Cur    := Gcur;
      CurOff;

      Max := 0;

      For Cik := 1 To VarNum-2 Do
        If VarLen[Cik]+Length(VarSt[Cik]) > Max Then
          Max := VarLen[Cik]+Length(VarSt[Cik]);

      Inc(Max,6);
      If Max < 24 Then Max := 24;

      BOOL := CREATE_WINDOW(40-(Max DIV 2),1,40+(Max DIV 2),8+VarNum-2,
                            CimFileStr+CimFile,CA[DispMode,7],CA[DispMode,2]);

      TextAttr := CA[DispMode,5];

      GotoXY((Max DIV 2)-10,2);

      With CimDate Do
      Begin
        Str(Honap:2,HoSt);
        HoSt[1] := Char(Byte(HoSt[1]) OR $30);
        Str(Nap:2, NapSt);
        NapSt[1] := Char(Byte(NapSt[1]) OR $30);
        Write(Keszult,Ev:4,'.',HoSt,'.',NapSt);
      End;

      GotoXY((Max DIV 2)-10,3);

      With CimDateM Do
      Begin
        Str(Honap:2,HoSt);
        HoSt[1] := Char(Byte(HoSt[1]) OR $30);
        Str(Nap:2, NapSt);
        NapSt[1] := Char(Byte(NapSt[1]) OR $30);
        Write(Modositva,Ev:4,'.',HoSt,'.',NapSt);
      End;

      Str(AktivCimRec,Wst);
      Wst := Wst + Rekord;

      {$IFDEF ANGOL} If AktivCimRec > 1 Then Wst := Wst + 's'; {$ENDIF}

      GotoXY((Max DIV 2)-(Length(Wst) DIV 2),4);
      Write(Wst);

      TextAttr := CA[DispMode,2];

      FillChar(Csik[1],60,#220);

      For Cik := 1 To VarNum-2 Do
      Begin
        GotoXY(2,Cik+5);
        Csik[0] := Char(VarLen[Cik]);
        Write(VarSt[Cik],' ',Csik);
      End;

      Repeat
          Puffi(Ch,Sc);
      Until Esc;

      Bool := Remove_Window;
      InVars := False;
      Esc := False;

      Case Cur Of
          1 : CurOn;
          2 : BigCur;
      End;
    End
End;


Procedure Main_Help; {(Num : Integer);}

Var

Help         : HelpRec;
Res,Cik      : Integer;
Act,Max,Oact : Byte;
Ch,Sc,Cur    : Byte;
Xp,Yp,Tb     : Byte;
W            : Word;
Count        : Array [1..8] Of Byte;
Cp           : Array [1..8,0..8] Of Word;

Begin
  If Kell_Help Then
  Begin
    InHelp := True;
    Cur    := Gcur;
    CurOff;
    BOOL := CREATE_WINDOW(13,7,67,18,'Help',CA[DispMode,7],CA[DispMode,8]);
    Repeat
      ClrScr; {$I-}
      Reset(Hfil);
      If IoResult <> 0 Then
        Reset(Hfil);
      Res := IoResult;
      Seek(Hfil,Num);
      Inc(Res,IoResult);
      Read(Hfil,Help); {$I+}
      If Res + IoResult > 0 Then
      Begin
        Error(1,MHelpFile);
        Esc := True;
      End
      Else
      With Help Do
      Begin
        Close(Hfil);
        For Cik := 1 To 8 Do Display(Szoveg[Cik],8+Cik,15);
        Act := Items;
        Max := Act;
        FillChar(Count,8,0);
        FillChar(Cp,2*8*9,0);

        For Cik := 1 To Act Do
          With Seealso[Cik] Do
          Begin
            Attribute(8+Ycoor,14+Xcoor,8+Ycoor,14+Xcoor+Len,CA[DispMode,11]);
            W := Xcoor + (Len DIV 2);
            Tb := 0;
            While (Tb <= Count[Ycoor]) And (Lo(Cp[Ycoor,Tb]) < W) Do
              Inc(Tb);
            If Tb <= Count[Ycoor] Then
              Move(Cp[Ycoor,Tb],Cp[Ycoor,Tb+1],2*(Count[Ycoor] - Tb + 1));

            Cp[Ycoor,Tb] := 256 * Cik + W;
            Inc(Count[Ycoor]);

            If Cik = 1 Then
            Begin
              Xp := Tb;
              Yp := YCoor;
            End;
          End;

     {  For Cik := 1 To 8 Do
        Begin
          Display('.............',8+Cik,1);
          For Tb := 1 To Count[Cik] Do
          Begin
            Str(Lo(Cp[Cik,Tb]),Ws);
            Display(Ws,8+Cik,3*(Tb-1)+1);
          End;
        End; }

        If Act > 0 Then
        Begin
          Act := 1;
          With Seealso[1] Do
            Attribute(8+Ycoor,14+Xcoor,8+Ycoor,14+Xcoor+Len,CA[DispMode,12]);
        End;
        Repeat
          Oact := Act;

          Puffi(Ch,Sc);

          If Act > 0 Then
          Case Sc Of
            FelNyil   : If Max > 1 Then
                        Begin
                          Tb := Lo(Cp[Yp,Xp]);
                          Repeat
                            Dec(Yp);
                            If Yp = 0 Then Yp := 8;
                          Until (Count[Yp] > 0);
                          Xp := Count[Yp];
                          If Xp > 1 Then
                          Begin
                            While (Lo(Cp[Yp,Xp]) >= Tb) And (Xp > 1) Do
                              Dec(Xp);
                            If Lo(Cp[Yp,Xp]) < Tb Then If
                              (Tb - Lo(Cp[Yp,Xp])) >
                              (Lo(Cp[Yp,Xp+1]) - Tb) Then
                                Inc(Xp);
                          End;
                          Act := Hi(Cp[Yp,Xp]);
                        End;
            LeNyil    : If Max > 1 Then
                        Begin
                          Tb := Lo(Cp[Yp,Xp]);
                          Repeat
                            Inc(Yp);
                            If Yp > 8 Then Yp := 1;
                          Until (Count[Yp] > 0);
                          Xp := Count[Yp];
                          If Xp > 1 Then
                          Begin
                            While (Lo(Cp[Yp,Xp]) >= Tb) And (Xp > 1) Do
                              Dec(Xp);
                            If (Lo(Cp[Yp,Xp]) < Tb) And (Lo(Cp[Yp,Xp+1]) >= Tb)
                            Then If (Tb - Lo(Cp[Yp,Xp])) >
                                    (Lo(Cp[Yp,Xp+1]) - Tb) Then Inc(Xp);
                          End;
                          Act := Hi(Cp[Yp,Xp]);
                        End;
            JobbraNyil: Begin
                          If Xp < Count[Yp] Then
                          Begin
                            Inc(Xp);
                            Act := Hi(Cp[Yp,Xp]);
                          End
                          Else
                          Begin
                            Repeat
                              Inc(Yp);
                              If Yp > 8 Then Yp := 1;
                            Until (Count[Yp] > 0);
                            Xp := 1;
                            Act := Hi(Cp[Yp,Xp]);
                          End;
                        End;
            BalraNyil : Begin
                          If Xp > 1 Then
                          Begin
                            Dec(Xp);
                            Act := Hi(Cp[Yp,Xp]);
                          End
                          Else
                          Begin
                            Repeat
                              Dec(Yp);
                              If Yp = 0 Then Yp := 8;
                            Until (Count[Yp] > 0);
                            Xp := Count[Yp];
                            Act := Hi(Cp[Yp,Xp]);
                          End;
                        End;
          End;

          If Act > Max Then Act := 1;
          If Act < 1   Then Act := Max;

          If Act <> OAct Then
          Begin

          With Seealso[OAct] Do
            Attribute(8+Ycoor,14+Xcoor,8+Ycoor,14+Xcoor+Len,CA[DispMode,11]);
          With Seealso[Act] Do
            Attribute(8+Ycoor,14+Xcoor,8+Ycoor,14+Xcoor+Len,CA[DispMode,12]);
          End;

          If Sc = F1 Then Ch := 13;

        Until Esc Or ((Max > 0) And (Ch = 13));

        If Not Esc Then Num := SeeAlso[Act].Point;

      End; {With Help Do}

    Until Esc;

    Bool := Remove_Window;
    InHelp := False;
    Esc := False;

    Case Cur Of
      1 : CurOn;
      2 : BigCur;
    End;

  End; {If Kell_Help}
End;


Procedure Key_Help{(Num : Integer; Var Character,Scan,Font : Byte)};

Const
      {$IFDEF NORVEG}
      Keys : Array [0..3] Of Byte = (13,12,12,11);
      Fpos : Array [0..3] Of Byte = (3,11,13,10);
      {$ELSE}
      Keys : Array [0..3] Of Byte = (14,12,11,10);
      Fpos : Array [0..3] Of Byte = (3,11,13,15);
      {$ENDIF}

      FunctionKeySt : String[12] = '[F1]..[F12]';

{$IFDEF NORVEG}

  Letters : Array [0..3,0..13] Of Char =

  (('','!','"','#','Ø','%','&','/','(',')','=','?','`',' '),
   ('Q','W','E','R','T','Y','U','I','O','P','è','^',' ',' '),
   ('A','S','D','F','G','H','J','K','L','ù','í','*',' ',' '),
   ('>','Z','X','C','V','B','N','M',';',':','_',' ',' ',' '));

  KLetters : Array [0..3,0..13] Of Char =

  (('|','1','2','3','4','5','6','7','8','9','0','+','\',' '),
   ('q','w','e','r','t','y','u','i','o','p','Ü','"',' ',' '),
   ('a','s','d','f','g','h','j','k','l','õ','ë','''',' ',' '),
   ('<','z','x','c','v','b','n','m',',','.','-',' ',' ',' '));

{$ELSE}
  Letters : Array [0..3,0..13] Of Char =

  (('~','!','@','#','$','%','^','&','*','(',')','_','+','|'),
   ('Q','W','E','R','T','Y','U','I','O','P','{','}',' ',' '),
   ('A','S','D','F','G','H','J','K','L',':','"',' ',' ',' '),
   ('Z','X','C','V','B','N','M','<','>','?',' ',' ',' ',' '));

  KLetters : Array [0..3,0..13] Of Char =

  (('`','1','2','3','4','5','6','7','8','9','0','-','=','\'),
   ('q','w','e','r','t','y','u','i','o','p','[',']',' ',' '),
   ('a','s','d','f','g','h','j','k','l',';','''',' ',' ',' '),
   ('z','x','c','v','b','n','m',',','.','/',' ',' ',' ',' '));
{$ENDIF}

Var Ch,Sc   : Byte;
    First   : Boolean;
    X       : Integer;
    Fc      : Word;
    TempSt  : String[3];
    Ws      : String[30];
    Pp      : Byte;
    Wst     : String[78];

    {$IFDEF NORVEG}
    EredetiFont : Byte;
    {$ENDIF}

Procedure YZ_Csere;
Begin
  If CYZ Then
    Begin
      Letters [1,5] := 'Z';
      KLetters[1,5] := 'z';
      {$IFDEF NORVEG}
      Letters [3,1] := 'Y';
      KLetters[3,1] := 'y';
      {$ELSE}
      Letters [3,0] := 'Y';
      KLetters[3,0] := 'y';
      {$ENDIF}

    End
  Else
    Begin
      Letters [1,5] := 'Y';
      KLetters[1,5] := 'y';
      {$IFDEF NORVEG}
      Letters [3,1] := 'Z';
      KLetters[3,1] := 'z';
      {$ELSE}
      Letters [3,0] := 'Z';
      KLetters[3,0] := 'z';
      {$ENDIF}
    End
End;

Procedure Put_Boxes(Num : Integer);
Var Cik,Sor,Osz : Integer;
    {$IFDEF NORVEG}
    Spec,
    VariableFont,
    OldVari,
    ExtFont     : Byte;
    W           : Word;
Type
    ExtType = Array[1..23] Of Char;
Const
    NorvNormalCh    : Set Of Char = ['!'..#127];

    NorvExtCh   : ExtType =
    (#39,#39,              '!','!',
                                             'D','D','d',
                                      'G','G','g',   'A','A','a',
     ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ');

    SamiExtCh   : ExtType =
    (#39,#39,              '!','!',
     'S','s','V','v',                        'D','D','d',
                                      'G','G','g',   'A','A','a', 'J','j',
     'M','m','P','p');

Var ExtCh    : ExtType;
    NormalCh : Set Of Char;
    {$ENDIF}

Begin

{$IFDEF NORVEG}
  Spec := 0;
  Cik := 1;
  ExtFont := 1;

  NormalCh := NorvNormalCh;

  While NOT((NorvegE(Cik)) AND (ExtendedE(Cik))) AND (Cik <= MaxFontNum) Do
    Inc(Cik);
  If Cik <= MaxFontNum Then ExtFont := Cik
    Else Error(20,'NORSKE '+ExtFontNotLoaded);

  VariableFont := ExtFont;

  If (StandardE(Num)) AND (Language = Sami) Then
  Begin

    While NOT((SamiE(Cik)) AND (ExtendedE(Cik))) AND (Cik <= MaxFontNum) Do
      Inc(Cik);
    If Cik <= MaxFontNum Then VariableFont := Cik
      Else Error(20,'SAMISKE '+ExtFontNotLoaded);

    ExtCh := SamiExtCh;
    NormalCh := NormalCh - ['Q','q','W','w','>','<','X','x','''','*'];

  End
  Else
  Begin
    ExtCh := NorvExtCh;
  End;

{$ENDIF}

For Sor:= 0 to 3 do
  For Osz:= 0 to Keys[Sor]-1 do
    Begin
      If First Then
      Begin
        Ablak(Fpos[Sor]+5*Osz,5+8*Sor,2,FontOffs,SortabOffs,3);
        {$IFDEF NORVEG}
        If Letters[Sor,Osz] In NorvNormalCh Then
          Sys_Write(Fpos[Sor]+5*Osz+1,5+8*Sor+2,Word(Letters[Sor,Osz]),Fontoffs,Sortaboffs,0)
        Else
        Begin
          Inc(Spec);
          W := Word(ExtCh[Spec]);
          Sys_Write(Fpos[Sor]+5*Osz+1,5+8*Sor+2,W,Fontoffs,Sortaboffs,ExtFont);
        End;
        If Not (Letters[Sor,Osz] In ['A'..'Z','ù','í','è']) Then
        Begin
          If KLetters[Sor,Osz] In NorvNormalCh Then
            Sys_Write(Fpos[Sor]+5*Osz+1,5+8*Sor+4,Word(KLetters[Sor,Osz]),Fontoffs,Sortaboffs,0)
          Else
          Begin
            Inc(Spec);
            W := Word(ExtCh[Spec]);
            Sys_Write(Fpos[Sor]+5*Osz+1,5+8*Sor+4,W,Fontoffs,Sortaboffs,ExtFont)
          End;
        End;
        {$ELSE}
        Sys_Write(Fpos[Sor]+5*Osz+1,5+8*Sor+2,Word(Letters[Sor,Osz]),Fontoffs,Sortaboffs,0);
        If Not (Letters[Sor,Osz] In ['A'..'Z']) Then
        Sys_Write(Fpos[Sor]+5*Osz+1,5+8*Sor+4,Word(KLetters[Sor,Osz]),Fontoffs,Sortaboffs,0);
        {$ENDIF}

      End {$IFNDEF NORVEG} ; {$ENDIF}

      {$IFDEF NORVEG}
      Else If NOT(Letters[Sor,Osz] In NorvNormalCh) Then Inc(Spec);

      If NOT ((Sor = 1) AND (Osz = Keys[Sor]-1)) Then {repÅlî billentyÅ}
      Begin
        If Letters[Sor,Osz] In NormalCh Then
          Sys_Write(Fpos[Sor]+5*Osz+3,5+8*Sor+2,Word(Letters[Sor,Osz]),Fontoffs,Sortaboffs,Num)
        Else
        Begin
          OldVari := VariableFont;
          Inc(Spec);
          W := Word(ExtCh[Spec]);
          If DoltE(Num) Then Inc(W)
            Else If Vastage(Num) Then Inc(W,2);

          If NOT StandardE(Num) Then
          Begin
            If ( (OroszE(Num)) OR (NemetE(Num)) )  Then
            Begin
              OldVari := VariableFont;
              VariableFont := Num;
              Case Letters[Sor,Osz] Of
                'è': W := Word('`');
                'ù': W := Word('>');
                'í': W := Word('*');
                Else
                Begin
                  W := 32;
                  VariableFont := OldVari;
                End;
              End;
            End
            Else
            Begin
              W := 32;
              VariableFont := OldVari;
            End;
          End;
          Sys_Write(Fpos[Sor]+5*Osz+3,5+8*Sor+2,W,Fontoffs,Sortaboffs,VariableFont);
          IF VariableFont <> OldVari Then VariableFont := OldVari;
        End;

        If KLetters[Sor,Osz] In NormalCh Then
          Sys_Write(Fpos[Sor]+5*Osz+3,5+8*Sor+4,Word(KLetters[Sor,Osz]),Fontoffs,Sortaboffs,Num)
        Else
        Begin
          OldVari := VariableFont;
          Inc(Spec);
          W := Word(ExtCh[Spec]);
          If DoltE(Num) Then Inc(W)
            Else If Vastage(Num) Then Inc(W,2);
          If NOT StandardE(Num) Then
          Begin
            If ( (OroszE(Num)) OR (NemetE(Num)) )  Then
            Begin
              VariableFont := Num;
              Case KLetters[Sor,Osz] Of
                'Ü': W := Word('\');
                'õ': W := Word('<');
                'ë': W := Word('''');
                Else
                Begin
                  W := 32;
                  VariableFont := OldVari;
                End;
              End;
            End
            Else
            Begin
              W := 32;
              VariableFont := OldVari;
            End;
          End;
          Sys_Write(Fpos[Sor]+5*Osz+3,5+8*Sor+4,W,Fontoffs,Sortaboffs,VariableFont);
          IF VariableFont <> OldVari Then VariableFont := OldVari;
        End;
      End;

      {$ELSE}
      Sys_Write(Fpos[Sor]+5*Osz+3,5+8*Sor+2,Word(Letters[Sor,Osz]),Fontoffs,Sortaboffs,Num);
      Sys_Write(Fpos[Sor]+5*Osz+3,5+8*Sor+4,Word(KLetters[Sor,Osz]),Fontoffs,Sortaboffs,Num);
      {$ENDIF}
    End;
End;


Begin

  {$IFDEF NORVEG}
  EredetiFont := LastFontNum;
  {$ENDIF}

  Set_Nem_lehet;
  YZ_Csere;

  InKeyHelp := True;

  TempSt := Tom[0];
  Tom[0] := 'rrr';  { A SYSTEM fontban a vizszintes vonal }

  NemKellCursor := True;
  First := True;
  Ablak(0,0,18,FontOffs,Sortaboffs,78);

  ConvertString(Fst);

  Wst := SzovegS;
  Pp  := Pos('@',Wst);
  Delete(Wst,Pp,1);

  If MaxFontNum > 10 Then
    Insert(',[SHIFT-F1]..['+KeyName(MaxShiftFontKey,0,0)+']',Wst,Pp);

  FunctionKeySt[10] := Char(2*Byte(GepTipus)+Byte('0'));

  Insert(FunctionKeySt,Wst,Pp);

  UpperCase(Wst);
  ConvertString(Wst);

  Pp := 40 - (Length(Wst) DIV 2);

  For X:= 1 To Length(Wst) Do
    Sys_Write(X+Pp,38,Word(Wst[X]),Fontoffs,Sortaboffs,0);

  Repeat

    For X:= 1 To Length(Fst) Do
      Sys_Write(X+25,3,Word(Fst[X]),Fontoffs,Sortaboffs,0);

    Fc := Word((Num Div 10)+48);
    If Fc = 48 Then Fc := 32;    { '0' => ' ' }

    Sys_Write(Length(Fst)+1+25,3,Fc,Fontoffs,Sortaboffs,0);
    Sys_Write(Length(Fst)+2+25,3,Word((Num Mod 10)+48),Fontoffs,Sortaboffs,0);

    Ws := Fontnames[Num];

    {$IFDEF NORVEG}
    If StandardE(Num) Then
    Case Language Of
      Norveg: Ws := Ws + ' - NORSKE';
      Sami  : Ws := Ws + ' - SAMISKE';
    End;
    {$ENDIF}

    While Length(Ws) < 19 Do Ws := Ws + ' ';

    For X:= 1 To 19 Do
      Sys_Write(Length(Fst)+X+4+30,3,Word(Ws[X]),Fontoffs,Sortaboffs,0);

    Put_Boxes(Num);

    Sc := 00;
    Ch := 00;

    {$IFDEF NORVEG} FontNum[EditNum] := Num;  {$ENDIF}

    Puffi(Ch,Sc);

    {$IFDEF NORVEG} If NOT ExtVolt Then FontNum[EditNum] := Num;  {$ENDIF}

    If Sc In [F1..MaxFontKey] Then Num := Sc - F1 + 1;

    If Sc In [F11..F12] Then Num := Sc - F11 + 11;

    If Sc In [Shift_F1..MaxShiftFontKey] Then Num := Sc - Shift_F1 + 11;

    First := False;

    If Sc = Alt_F10 Then
      Begin
        First := True;
        YZ_Csere;
      End;

  Until Ch In Normalchars+[Escape];

  If Ch <> Escape Then
  Begin
    UpKey(Sc,Ch);
    Character := Ch;
    Scan      := Sc;
    {$IFDEF NORVEG}
    If ExtVolt Then
    Begin
      LastFont := EredetiFont;  {LastFont : a KeyConv v†ltoz¢ja}
      Font := FontNum[EditNum];
    End
    Else
      Font := Num;
    {$ELSE}
    Font      := Num;
    {$ENDIF}

  End;

  NemKellCursor   := False;
  Tom[0]          := TempSt;

  InKeyHelp := False;
  If EditNum <> MaxEditor Then Set_lehet;
End;

Const Indulo : Boolean = True;

Procedure KivetelSzotar;

Var
XX      : Byte;
UjElso,
Graphic : Boolean;
Lpath   : St80;
S       : String;
OFilePoz,
FilePoz,Time1,Time2 : LongInt;
ElsoMasodik,
ElsoBetu,MasodikBetu,
I,Poz   : Byte;
OS1,OldMasodik: Char;
ONumOfWords,NumOfWords: Word;
UjBetu  : Boolean;
IORES   : Integer;
Fn      : String[80];
Elv     : Array[0..16] Of Byte;
Tomb    : Array[1..36*36] Of Byte;
SzoText : Text;

Begin
  Graphic := (CRTMode = 6);
  Lpath := DiskMemPath;
  ESC   := False;
  Fn    := SzotarFile;

  If (Indulo) AND (LPath <> '') Then
  Begin
    If Lpath[Length(Lpath)] <> '\' Then Lpath := Lpath + '\';
    SzotarFile := Lpath + SzotarFile;
    SzoFile    := Lpath + SzoFile;
    CheckRead(Lpath);
    Indulo := False;
  End;

  IORES := 0;

  If Not Esc Then
  Begin

    WordStarMode(False);

    Assign(Szotar,SzoFile);
    {$i-} Reset(Szotar,1);

    Inc(IORES,IoResult);

    If IoRes = 0 Then
    Begin
      If FileSize(Szotar) = 0 Then Inc(IoRes);
      Inc(IORES,IoResult);
    End;

    If IOres <> 0 Then
    Begin
      ReWrite(Szotar,1);
      Inc(IORES,IoResult);
      {$i+}
      Time1 := 0;
    End
    Else
    Begin
      {$i-}
      GetFTime(Szotar,Time1);
      Inc(IORES,IoResult);
      {$i+}
    End;

    IORES := IoResult;

    VanSzotarFile := False;

    Assign(SzoText,SzotarFile);
    {$i-} Reset(SzoText); {$i+}

    If IOresult <> 0 Then Error(1,SzotarFile)
    Else
    Begin

      VanSzotarFile := True;

      {$i-}
      GetFTime(SzoText,Time2);
      Inc(IORES,IoResult);
      {$i+}

      If Time1 < Time2 Then
      Begin
        {$i-} Close(Szotar); {$i+}
        Inc(IORES,IoResult);
        {$i-} ReWrite(Szotar,1); {$i+}
        Inc(IORES,IoResult);

        {$i-}
        GetFTime(Szotar,Time1);
        Inc(IORES,IoResult);
        {$i+}

        If Graphic Then Gotox(16,WherY{+6});

        {$IFDEF NORVEG}
          Writ(Fn);
        {$ELSE}
          {$IFDEF ANGOL}
          Writ(IneSt15+Fn);
          {$ELSE}
          Writ(Fn+IneSt15);
          {$ENDIF}
        {$ENDIF}

        FillChar(Tomb,36*36,00);

        Tomb[1] := $22;
        Tomb[2] := $22;

        {$i-}
        For I := 1 To 4 Do
        Begin
          BlockWrite(Szotar,Tomb,36*36);  { 35*35 }
          Tomb[1] := 0;
          Tomb[2] := 0;
          Inc(IORES,IoResult);
        End; {$i+}

        ElsoBetu := 1;

        S[1] := 'a'; S[2] := 'a';

        If NOT Graphic
          Then GotoXY(29,WhereY)
          Else Writ('  ');

        Writ('[  ]');

        XX := WherX-3;

        NumOfWords := 0;
        OFilePoz   := 0;

        UjElso := False;

        While (NOT Eof(SzoText)) AND (ElsoBetu <= 36) AND (IORES = 0) Do
        Begin

          MasodikBetu := 1;
          OldMasodik  := '@';

          If S[1] = MABC[ElsoBetu] Then
          Begin
            While S[1] = MABC[ElsoBetu] Do
            Begin

              OS1 := S[1];
              S[1]:= '@';

              ReadLn(SzoText,S);

              SzToDollar(S);

              If S[1] = MABC[ElsoBetu] Then
              Begin

                If S = '' Then S := OS1
                Else
                Begin
                  If (S[2] <> OldMasodik) Then
                  Begin
                    OldMasodik := S[2];
                    MasodikBetu := 1;
                    While OldMasodik <> MABC[MasodikBetu] Do
                      Inc(MasodikBetu);

                    UjBetu := True;
                    ONumOfWords := NumOfWords;

                    NumOfWords := 0;

                    If ONumOfWords > 0 Then
                    Begin
                      {$i-}
                      Seek(Szotar,FilePoz);
                      Inc(IORES,IoResult);
                      BlockWrite(Szotar,ONumOfWords,2);
                      Inc(IORES,IoResult);
                      Seek(Szotar,FileSize(Szotar));
                      Inc(IORES,IoResult);
                      {$i+}
                    End;
                  End;

                  Inc(NumOfWords);

                  I := 0;
                  Poz := Pos('-',S);

                  While Poz > 0 Do
                  Begin
                    Inc(I);
                    Elv[I] := Poz-1;
                    Delete(S,Poz,1);
                    Poz := Pos('-',S);
                  End;

                  Elv[0] := I;

                  If OFilePoz > 0 Then
                  Begin
                    {$i-}
                    Seek(Szotar,OFilePoz);
                    Inc(IORES,IoResult);
                    Inc(NumOfWords);
                    {$i+}
                  End;

                  If UjBetu Then { csak hely a NumOfWords-nek }
                  Begin
                    {$i-}
                    FilePoz := FileSize(Szotar);
                    Inc(IORES,IoResult);
                    BlockWrite(Szotar,NumOfWords,2);
                    Inc(IORES,IoResult);
                    {$i+}
                  End;

                  If OFilePoz > 0 Then
                  Begin
                    {$i-}
                    Seek(Szotar,FileSize(Szotar));
                    Inc(IORES,IoResult);
                    {$i+}
                    FilePoz := OFilePoz;
                  End;

                  {$i-}
                  BlockWrite(Szotar,Elv[0],I+1); {elvalasztasi Tomb}
                  Inc(IORES,IoResult);

                  BlockWrite(Szotar,S,Length(S)+1); {String}
                  Inc(IORES,IoResult);
                  {$i+}


                  If UjElso AND (MasodikBetu <> ElsoMasodik) Then
                  Begin
                    {$i-}
                    Seek(Szotar,4*(36*(ElsoBetu-1)+(ElsoMasodik-1)));
                    Inc(IORES,IoResult);
                    BlockWrite(Szotar,FilePoz,4);
                    Inc(IORES,IoResult);
                    {$i+}
                  End;

                  If UjBetu Then
                  Begin
                    {$i-}
                    Seek(Szotar,4*(36*(ElsoBetu-1)+(MasodikBetu-1)));
                    Inc(IORES,IoResult);
                    BlockWrite(Szotar,FilePoz,4);
                    Inc(IORES,IoResult);
                    UjBetu := False;
                    {$i+}
                  End;

                  {$i-}
                  Seek(Szotar,FileSize(Szotar));
                  Inc(IORES,IoResult);
                  {$i+}

                  OFilePoz := 0;

                End; {If S <> ''}

                UjElso := False;

              End
              Else
              Begin

                UjElso := True;

                ElsoMasodik := Pos(S[2],MABC_STRING);

                I := 0;
                Poz := Pos('-',S);

                While Poz > 0 Do
                Begin
                  Inc(I);
                  Elv[I] := Poz-1;
                  Delete(S,Poz,1);
                  Poz := Pos('-',S);
                End;

                Elv[0] := I;

                {$i-}
                OFilePoz:= FileSize(Szotar);
                Inc(IORES,IoResult);

                FilePoz := FileSize(Szotar);
                Inc(IORES,IoResult);

                BlockWrite(Szotar,S[1],2); {csak hely a NumOfWords-nek}
                Inc(IORES,IoResult);

                BlockWrite(Szotar,Elv[0],I+1); {elvalasztasi Tomb}
                Inc(IORES,IoResult);

                BlockWrite(Szotar,S,Length(S)+1); {String}
                Inc(IORES,IoResult);

                {$i+}

              End;

              If EOF(SzoText) Then
              Begin
                S := '@';
                If NumOfWords > 0 Then
                Begin
                  {$i-}
                  Seek(Szotar,FilePoz);
                  Inc(IORES,IoResult);
                  BlockWrite(Szotar,NumOfWords,2);
                  Inc(IORES,IoResult);
                  Seek(Szotar,FileSize(Szotar));
                  Inc(IORES,IoResult);
                  {$i+}
                End;
              End;

            End; { Elsobetu ciklus}
          End
          Else If (S <> '') AND (Pos(S[1],MABC_STRING) < ElsoBetu) Then
          Begin
            ElsoBetu := 100;
            DollarToSz(S);
            Error(20,'Nem a helyÇn van az ABC-ben : '+S);
          End;

          If ElsoBetu < 100 Then
          Begin
            If Graphic Then GotoX(XX,WherY)
              Else GotoXY(30,WhereY);

            If OS1 = '$' Then Writ('sz')
              Else Writ(OS1+' ');

            Inc(ElsoBetu);
          End;

        End; { (NOT Eof(SzoText)) AND (ElsoBetu <= 36) }
      End;

      If IORES <> 0 Then
      Begin
        Error(26,' IRASKOR');
        VanSzotarFile := False;
      End
      Else
      Begin
        {$i-}

        SetFTime(Szotar,Time1);
        Inc(IORES,IoResult);
        SetFTime(SzoText,Time1);
        Inc(IORES,IoResult);

        Close(Szotar);
        Inc(IORES,IoResult);

        Close(SzoText);
        Inc(IORES,IoResult);

        {$i+}

      End;

      If IORES <> 0 Then
      Begin
        Error(26,' LEZARASOKOR');
        VanSzotarFile := False;
      End;
      WordStarMode(True);
    End;
  End;
End; {KivetelSzotar}

Procedure Temp_Backup;  {(Mode : Savetype); Forward }


Var Scbuf : Array[1..3280] Of Byte;
    X     : Integer;
    TOUT  : Word;
    Cur   : Byte;
    OFname,
    Fname : FnTyp;
    Grph  : boolean;
    ox,oy : byte;
    Nevadas:Boolean;

BEGIN
   {$IFDEF EKSZINFO}
   MegisIze := False;
   {$ENDIF}


    (*
   {$IFNDEF DEMO1}
   If BBBB Then
     Save(Fname,BackupMode,Document);  { ez soha nem hivodik meg,
                                         csak a DEMO miatt kell }
   {$ENDIF}
   *)


   {$IFNDEF DEMO}
   Grph := CrtMode>=6;
   GlobalFont:=0;
   MezoFont:=0;

   If (Editnum In [1..3]) AND ((NOT Grph) OR (NOT InKeyHelp)) Then
   BEGIN
     If Grph then
       BEGIN
         Set_Nem_Lehet;
         TOUT := OutJel;
         FelSor_IdeOdaW(6,68,6,20,Ofs(ScBuf),Seg(ScBuf),SortabOffs,0);
         Cur := GCur;
         SaveXY;
         GotoX(26,20);
         FontNum[EditNum]:=00;
       End;

     MasNev := False;
     Nevadas:= False;
     MasNemUres := False;

     {$IFDEF EKSZINFO}
     MegisIze := False;
     {$ENDIF}

     Case Mode of

     NormalMode: BEGIN
                   If Grph then Ablak(24,20,1,Fontoffs,SortabOffs,31);
                   Fname := Filename[Editnum];
                   OFname:= Fname;
                   UpperCase(Fname);
                   While Pos(' ',Fname) <> 0 Do
                     Delete(Fname,Pos(' ',Fname),1);
                   If (FName = UresName) Or
                      (FName = ''        ) Then
                     BEGIN
                       If not Grph then
                         BEGIN
                           ox:=WhereX;
                           oy:=WhereY;
                           BOOL:= CREATE_WINDOW(40,5,76,9,DocuSt+InpSt6,
                                  CA[DispMode,1],CA[DispMode,3]);
                         End;
                       Nevadas := True;
                       MaxStringLen := FnSize;
                       GlobalFont := 0;
                       MezoFont   := 0;
                       Mentes_e:=True;

                       Input_FileName(Enter_Fn,FName,17,False);
                       
                       MasNev     := (Fname <> OFname);
                       MasNemUres := (Ofname <> UresName);

                       {$IFDEF EKSZINFO}
                       MegisIze := True;
                       {$ENDIF}

                       Mentes_e:=False;
                       UpperCase(Fname);
                       If Pos('.',Fname) = 0 Then
                         Fname := Fname + '.' + Dmask;

                       If Not ESC Then
                         BEGIN
                           If Grph then
                             BEGIN
                               GoToX(26,20);
                               Writ('                            ');
                               GoToX(30,20);
                               For X:= 1 to Length(Save_String) Do
                                 Writ(Save_String[X]+' ');
                               Inv_Line(22,26,26+28,0,sortaboffs,0);
                             End
                           else
                             BEGIN
                               ClrScr;
                               GoToXY(15-(Length(Save_String) div 2),2);
                               Write(Save_String);
                             End;
                         End;
                     End { Ha ures a nev }
                   Else
                     If Grph then
                       BEGIN
                         GoToX(30,20);
                         For X:= 1 to Length(Save_String) Do
                           Writ(Save_String[X]+' ');
                         Inv_Line(22,26,26+28,0,sortaboffs,0);
                       End
                     else
                       BEGIN
                         BOOL := CREATE_WINDOW(40,5,71,9,
                                 '',CA[DispMode,1],CA[DispMode,3]);
                         GoToXY(15-(Length(Save_String) div 2),2);
                         Write(Save_String);
                       End;
                   {Fname := Filename[Editnum];}
                 End;
     BackupMode: BEGIN
                   BackupVan := True;
                   Fname := Backupfile;
                   If EditNum > 1 Then
                     Insert(Char(EditNum+48),Fname,Pos('.',Fname));
                   If Grph then
                     BEGIN
                       Ablak(6,20,1,Fontoffs,SortabOffs,66);
                       For X:= 1 to Length(Temp_String) Do
                       Sys_Write(7+2*x,22,Word(Temp_String[X]),FontOffs,SortabOffs,0);
                       Inv_Line(22,8,8+63,0,sortaboffs,0);
                     End;
                 End;

     End;

     If Not ESC Then
     Begin
       GlobalMode := NoWriteMode;
       KellJelszo := True;
       Save(Fname,BackupMode,Document);
       KellJelszo := False;
       If (NOT ESC) AND Nevadas Then
       BEGIN
         FileName[EditNum] := Fname;
         EditorCim := Fname;
         While Pos('\',EditorCim)+Pos(':',EditorCim) > 0 Do
           Delete(Editorcim,1,1);
         EditorCim := Csak12(EditorCim);
       End;
     End;

     If Grph Then
       BEGIN
         FelSor_IdeOdaW(6,68,6,20,Ofs(ScBuf),Seg(ScBuf),SortabOffs,1);
         RestoreXY;
         RestoreCur(Cur);
         OutJel := TOUT;
       End
     else
       BEGIN
         Bool:=Remove_Window;
         GoToXY(Ox,Oy);
       End;

   End; {If Main editor}

{$ENDIF}

{$IFDEF EKSZINFO}
  MegisIze := True;
{$ENDIF}
  BackupVan := False;

End;


PROCEDURE Get_Pic_Name;

CONST
Kiter_g = '@*';
Arany : array[0..3] of integer = (125,48,40,35);
                                 { (42,48,40,35); volt }

VAR
{ Scbuf : Array[1..7000] Of Byte; }
szel,mag,wid,high: word;
dir_g : nevtomb;
db_g  : word;
ut_g  : string;
PicSt : string;
OpSt  : string;

FUNCTION File_Controll : boolean;

VAR F : file of word;
    Fb: File Of Byte Absolute F;
    c   : longint;

BEGIN
  Assign(f,PicSt);
  {$I-}
  ReSet(f);
  {$I+}
  If IOResult<>0 then
  BEGIN
    Error(3,PicSt);
    File_Controll:=False;
    Exit;
  End;
  Read(f,szel);
  Read(f,mag);
  Close(f);

  Assign(fb,PicSt);
  {$I-}
  ReSet(fb);
  {$I+}
  c:=FileSize(Fb);
  Close(Fb);

  If c <> LongInt(szel)*LongInt(Mag)+4
    then File_Controll:=False
    else File_Controll:=True;
End;

VAR ez_jo_lesz : boolean;

BEGIN
  DRpoz:=0;
  Esc := False;
  SaveXY;
  FontNum[GEditNum]:=0;
  {
  Inline($FC);
  FelSor_IdeOdaW(2,76,12,18,Ofs(ScBuf),Seg(ScBuf),SortabOffs,0);
  }
  GrWindow(02,20,78,23,PictureNev);
  Gotox(4,20);
  MaxStringLen := 60;
  MezoFont := FontNum[GEditNum];
  MezoFont:=1;
  PicSt:='';
  Input_String(Enter_fn,PicSt,60);

  If Not ESC Then
  BEGIN
    If PicSt<>'' then CheckFileName(PicSt);
    If Not ESC then
    BEGIN
      If (Pos('.',PicSt)=0) and (PicSt<>'') then PicSt:=PicSt+'.'+Kiter_g;
      If PicSt='' then PicSt:='*.'+kiter_g;
      If (Pos('?',PicSt)>0) or (Pos('*',PicSt)>0) or
         (Pos(':',PicSt)>0) or (DelSpace(PicSt)='') then   { VF }
      BEGIN
        Dir(PicSt,dir_g,db_g,ut_g);
        If not ESC then PicSt:=ut_g+dir_g[1];
      End;
      If not ESC then
      BEGIN
        ez_jo_lesz:=File_controll;
        If (ez_jo_lesz) then
        BEGIN
          GrWindow(02,20,78,23,KepSzelAbl);
          Gotox(4,20);
          MezoFont:=1;
          Wid := Szel DIV 4;
          MaxStringLen:=2;
          Input_Word(KepSzel, wid, 6);
          If Not ESC then
          BEGIN
            if Wid < 93 then
            BEGIN
              GrWindow(02,20,78,23,KepMagAbl);
              Gotox(4,20);
              MezoFont:=1;
              High := trunc(wid*{arany[Ppar.Pr_Ovr]}125/80);   {!!!!!!}
              MaxStringLen:=3;
              Input_Word(KepMag, high, 6);
              If not ESC then If high < 1000 then
              BEGIN
                Str(wid:2,OpSt);
                While OpSt[1]=' ' do Delete(OpSt,1,1);
                PicSt := '.PIC='+PicSt+','+OpSt;
                Str(high:3,OpSt);
                While OpSt[1]=' ' do Delete(OpSt,1,1);
                PicSt := PicSt + ',' + OpSt;
                OpSt := '';
                GrWindow(02,20,78,23,KepOpcAbl);
                Gotox(4,20);
                MezoFont:=1;
                MaxStringLen:=3;
                Input_String(KepOpc,OpSt,4);
                UpperCase(OpSt);

                While length(OpSt) > 0 do
                BEGIN
                  If OpSt[1] in ['W','F','I'] then PicSt:=PicSt+',' + OpSt[1];
                  Delete(OpSt,1,1);
                End
              End
              Else
              BEGIN
                Error(20,TulMagas);
              End;
            End
            else Error(20,TulSzeles);
          End;
        End
        else Error(24,PicSt);
      End;
    End;
  End;

  {
  Inline($FC);
  FelSor_IdeOdaW(2,76,12,18,Ofs(ScBuf),Seg(ScBuf),SortabOffs,1);
  }
  RestoreXY;
  If (not esc) and (ez_jo_lesz) then
    BEGIN
      DatumRes:=PicSt;
      DRpoz:=Length(PicSt);
      DatumJelzes := True;
    End;
End;


Var Exital : Boolean;

{$IFNDEF Demo} {demo1 volt}
{$I-}

Procedure ASCII_Save {(Var Fil : Szoveg; Tipus(Document,ASCII,Ventura) )};

Var FoAtt : Array[1..255] Of Byte;
    Fosor : String[255];
    MainP,IORES : Integer;
    Elval,
    UresLett,
    Leading,
    FL    : Boolean;
    PP,
    Cik   : Byte;
    OCh,
    Ch    : Char;
    Po    : Lpoint;
    F     : array [1..MaxFontNum] of boolean;
    Oxp,
    old_att : byte;
    ciklus  : byte;
    RegiAtt,
    UjAtt   : Byte;
    Mettol  : Byte;
    kije    : string[20];
    Ws      : Str160;  {NyelvEsz DEMO}

Const
    jel : array [1..5] of string[4] = ('<D>','<MS>','<B>','<MI>','<MU>');

HVP : Array[1..18] Of Char =

{   †    °    î    Å    ¢    ‹     €    £    Ç  }
  (#160,#161,#148,#129,#162,#220,#219,#163,#130,
   #199,#205,#153,#154,#209,#222,#221,#214,#144);


BEGIN

   Elval := False;

   For Cik := 1 To MaxFontNum Do F[Cik] := False;

   (*
   F[1]:=False; { Normal }
   F[2]:=False; { Index  }
   F[3]:=False; { Bold   }
   F[4]:=False; { Dolt   }
   F[5]:=False; { Alahuz }
   *)

   old_att:=2;

   { Mainp := StartLine[EditNum];
     While Not MainLine(MainP) Do Inc(MainP); }

   { Fl := True; }

   InitLines(EditNum);

   For MainP := StartLine[EditNum] To EndLine[EditNum] Do
   Begin

      { If Fl Then Fl := False Else Mainp := NextMain(MainP); }

      Heap_Pos(Po,PointerTomb^[MainP]);

      Fosor[0] := Char(LenLine(MainP));

      Move(Po^.Chars[C80],Fosor[1],Byte(Fosor[0]));
      Move(Po^.Attribs,FoAtt[1],Byte(Fosor[0]));

      FreeEms1(PointerTomb^[MainP]);

      If Tipus = ASCII Then
      Begin

        Cik := 0;

        If FoSor <> '' Then
        While (FoSor[Cik+1] In [#00,' ']) AND
              (Cik < LeftMar[EditNum])  AND
              (Cik < Length(FoSor)) Do
        Inc(Cik);

        If Cik > 0 Then
        Begin
          Delete(FoSor,1,Cik);
          Move(FoAtt[Cik+1],FoAtt[1],255-Cik);
        End;

        Cik := 1;

        Leading := True;

        While Cik <= Length(FoSor) Do
        Begin
          If NOT(FoSor[Cik] In [#00,' ']) Then Leading := False;
          If NOT Leading Then
          While (Cik < Length(FoSor)) AND
                (FoSor[Cik] = #00) AND
                (FoSor[Cik+1] In [#00,' ']) Do
          Begin
            Delete(FoSor,Cik,1);
            Move(FoAtt[Cik+1],FoAtt[Cik],255-Cik);
          End;
          Inc(Cik);
        End;

        For Cik := 1 To Length(FoSor) Do
        BEGIN
          If FoSor[Cik] = #00 Then FoSor[Cik] := ' '



          {$IFDEF NORVEG}
          Else
          If ExtendedE(FoAtt[Cik] AND 15) Then { Norveg vagy Sami }
          BEGIN
            If NorvegE(FoAtt[Cik] AND 15) Then { Norveg vagy Sami }
            BEGIN
              PP := Pos(FoSor[Cik],NConv2);
              While PP > MaxNorveg Do Dec(PP,MaxNorveg);
              If Boolean(PP) Then
                FoSor[Cik] := NConv1[PP];
            End
            Else
            If SamiE(FoAtt[Cik] AND 15) Then { Norveg vagy Sami }
            BEGIN
              PP := Pos(FoSor[Cik],SConv2);
              While PP > MaxSami Do Dec(PP,MaxSami);
              If Boolean(PP) Then
                FoSor[Cik] := SConv1[PP];
            End
          End;
          {$ELSE}

            {$IFNDEF ANGOL}

            Else

            If MagyarE(FoAtt[Cik] AND 15) Then { Magyar }
            BEGIN
              PP := Pos(FoSor[Cik],Asc_Out.ezt);
              If Boolean(PP) Then
                FoSor[Cik] := Asc_Out.erre[PP];
            End
            Else
            If Spec1E(FoAtt[Cik] AND 15) Then { Spec1 }
            BEGIN
              PP := Pos(FoSor[Cik],TablazatConvSt[0]);
              If Boolean(PP) Then FoSor[Cik] := TablazatConvSt[1][PP]
                             Else FoSor[Cik] := '.';
            End
            Else
            Begin
              If ((FoAtt[Cik] AND 15) > 0) AND
                 (NOT AngolE(FoAtt[Cik] AND 15)) Then FoSor[Cik] := '.';
            End

          {$ENDIF IFNDEF ANGOL}

          {$ENDIF NOT NORVEG}


        End; { For }

        {NyelvEsz DEMO}

        UresLett := False;

        If Elval Then
        Begin

          If FoSor = '' Then
          Begin
            WriteLn(Fil);
            Inc(Lines);
          End
          Else
          Begin
            If FoSor[1] = ' ' Then
            Begin
              Ws := FoSor;
              Mettol := 1;
              While Ws[1] = ' ' Do
              Begin
                Inc(Mettol);
                Delete(Ws,1,1);
              End;
              PP := Pos(' ',Ws);
              If PP > 0 Then Ws[0] := Char(PP-1);
              PP := Pos(Ws,FoSor) + Length(Ws) -1;
            End
            Else
            Begin
              PP := Pos(' ',FoSor)-1;
              If PP = 0 Then PP := Length(FoSor);
              Ws := Copy(FoSor,1,PP);
              Mettol := 1;
            End;

            WriteLn(Fil,Ws);
            Inc(Lines);
            Delete(FoSor,Mettol,PP+1+1-Mettol);
            UresLett := (FoSor = '');

            { FillChar(FoSor[1],PP,' '); }

          End;

          Elval := False;

        End;

        If (FoSor <> '') AND
           (((FoAtt[Cik] AND 15) = 0) AND
           (FoSor[Cik] = '-')) Then
        Begin
          Elval := True;
          Dec(Byte(FoSor[0]));
          Write(Fil,FoSor);
        End
        Else
        Begin
          If NOT UresLett Then
          Begin
            WritelnM(Fil,Fosor);
            Inc(Lines);
          End;
          Elval := False;
        End;

        {NyelvEsz DEMO}

        If IOResultM <> 0 Then
        BEGIN
          If Not ModemMode Then Error(18,'');
          Exital := True;
          Exit;
        End;

      End
      Else {Ventura}
      Begin

        IORES := 0;

        Cik := 1;

        While Cik <= Length(FoSor) Do
        Begin
          Ch := Fosor[Cik];

          If (Ch In ['@','<','>']) AND (StandardE(FoAtt[Cik] AND 15)) Then
          Begin
            If (Ch <> '@') OR (Cik > 1) Then
            Begin
              Move(FoAtt[Cik],FoAtt[Cik+1],Length(FoSor)-Cik+1);
              Insert(Ch,Fosor,Cik);
              Inc(Cik);
            End;
          End;

          Inc(Cik);
        End;

        Cik := 1;

        While Cik <= Length(FoSor) Do
        Begin

          Ch := Fosor[Cik];
          OCh:= Ch;

          If Ch = #00 Then Ch := ' ';

          If Elval AND (Cik = 1) Then
            While (Ch = ' ') AND (Cik <= Length(FoSor)) Do
            Begin
              Inc(Cik);
              Ch := Fosor[Cik];
              OCh:= Ch;

              If Ch = #00 Then Ch := ' ';
            End;

          If Cik <= Length(FoSor) Then
          Begin

            If Ch = ' ' Then
            Begin
              {$I-}
              If Elval Then
              Begin
                If OCh = ' ' Then
                Begin
                  WriteLn(Fil);
                  Inc(Lines);
                  Elval := False;
                End;
              End
              Else If Cik > 1 Then Write(Fil,Ch);
              {$I+}

              Inc(IORES,IOResult);

              Repeat
                Inc(Cik);
                If Elval AND (FoSor[Cik] = ' ') Then
                Begin
                  {$I-} WriteLn(Fil); {$I+}
                  Inc(Lines);
                  Inc(IORES,IOResult);
                  Elval := False;
                End;
                If FoSor[Cik] = #00 Then FoSor[Cik] := ' ';
              Until (Cik >= Length(FoSor)) OR (Fosor[Cik] <> ' ');

            End
            Else
            Begin
              kije:='';
              If not(F[FoAtt[cik] and 15]) then
                BEGIN
                  F[old_att]:=False;
                  RegiAtt := Byte(DoltE(Old_Att))+
                             2*Byte(AlahuzottE(Old_Att))+
                             4*Byte(IndexE(Old_Att))+
                             8*Byte(VastagE(Old_Att));
                  old_att:=FoAtt[cik] and 15;
                  UjAtt :=   Byte(DoltE(Old_Att))+
                             2*Byte(AlahuzottE(Old_Att))+
                             4*Byte(IndexE(Old_Att))+
                             8*Byte(VastagE(Old_Att));
                  F[Old_Att]:=True;
                  If (DoltE(old_att)) or (AlahuzottE(old_att)) or
                     (IndexE(old_att)) or (VastagE(old_att)) then
                    BEGIN
                      If DoltE     (Old_Att) then kije:=kije+jel[4];
                      If AlahuzottE(Old_Att) then kije:=kije+jel[5];
                      If IndexE    (Old_Att) then kije:=kije+jel[2];
                      If VastagE   (Old_Att) then kije:=Kije+jel[3];
                    End
                  else kije:=jel[1];
                  If RegiAtt <> UjAtt Then
                  Begin
                    Write(Fil,kije);
                    {$I+}
                    Inc(IORES,IOResult);
                    {$I-}
                  End;
                End;
              {$IFNDEF ANGOL}

              If (Spec1E(FoAtt[Cik] AND 15)) Then { SPEC1 }
              Begin
                If Ch = '&' Then Ch := 'π';
              End;

              If MagyarE(FoAtt[Cik] AND 15) Then { Magyar }
              BEGIN


                PP := Pos(Ch,CWIConvSt[0]);
                If PP > 0 Then
                Begin
                  {$I-}
                  If (PP >= 12) and (PP<=30)  Then Write(Fil,HVP[PP-11]){ êkezetes }
                                    Else
                                    Write(Fil,CWIConvSt[1][PP]);{ EgyÇb }
                  {$I+}
                  Inc(IORES,IOResult);
                End
                Else
                Begin
                  {$I-} Write(Fil,Ch); {$I+}
                  Inc(IORES,IOResult);
                End;
              End
              Else
              {$ENDIF}
              Begin
                If FoAtt[Cik] = 0 Then Elval := True
                Else
                Begin
                  {$I-} Write(Fil,Ch); {$I+}
                  Inc(IORES,IOResult);
                End;
              End;

              Inc(Cik);

            End; { Ha nem ' ' volt }

          End; { If Cik <= Length(FoSor) }

        End; { While }

        If FoAtt[1] and 128 = 128 then
          BEGIN
            {$I-} Writeln(Fil{,#13#10});
            If NOT ASCIIVolt[EditNum] Then Writeln(Fil);
            {$I+}
            Inc(Lines);
            Inc(IORES,IOResult);
          End
        else

        If NOT Elval Then                 {VENTURA}
          BEGIN
            {$I-}
             WriteLn(Fil);            {szokoz kiszedve}
             Inc(Lines);
            {$I+}
            Inc(IORES,IOResult);
          End;

        {$I+}
        If IORES <> 0 Then
        BEGIN
          Error(18,'');
          Exital := True;
          Exit;
        End;

      End; { Ventura }

      If Lines MOD 50 = 0 Then WriteLinesPercent(True);

   End; { For MainP := StartLine[EditNum] To EndLine[EditNum] }

   WriteLinesPercent(True);

   { Until LastMain(MainP); }

End; {ASCII_Save}



Const
  Header30      : Array[1..4] Of Char = (#0,'C','D',#0);
  Header30Header: Array[1..4] Of Char = (#0,'C','F',#0);

Procedure BlockWritePuff(Var N_Fil:File;Var Puf; Db: Word);
Var Buf : Array[1..16000] Of Byte Absolute Puf;
    Res,Remain : Word;

Procedure WriteOneBlock;
Begin
  {$I-}
  {$IFDEF SECRET}
  If KellJelszo AND VanJelszo Then
    Begin
      Randomize;
      For Cikl := 1 To KodoltSize-ValodiSize Do
        BufferP^[ValodiSize+Cikl] := Random(256);
      Kodol(BufferP,ValodiSize,@BaseBytes,0);  { Kodolas }
      BlockWrite(N_Fil,BufferP^,KodoltSize);
    End
  Else
  {$ENDIF}
    BlockWrite(N_Fil,BufferP^,ValodiSize);
  {$I+}
End;


Begin
  Inc(BufPointer,Db);
  If BufPointer <= ValodiSize Then
    Move(Buf[1],BufferP^[BufPointer-Db+1],Db)  { Nem lepjuk tul a puffert }
  Else
    Begin
      Remain := BufPointer - ValodiSize;     { ennyivel lepjuk tul }
      Move(Buf[1],
           BufferP^[BufPointer-Db+1],
           Db-Remain);                       { ennyit meg odarakunk, }

      WriteOneBlock;                         { es kiirjuk           }
      Move(Buf[1+Db-Remain],BufferP^[1],Remain); { atmasoljuk a fennmarado reszt}
      BufPointer := Remain;
    End;
  Inc(FilePoz,Db);
End;

Procedure BlockWriteMaradek(Var N_Fil:File);
Var UzenetSzam : Word;
Begin
  {$I-}
  { Writeln(lst,bufpointer); }
  {$IFDEF SECRET}
  If KellJelszo AND VanJelszo Then
    Begin
      UzenetSzam := ((BufPointer+1023) Div 1024)*12;
      Randomize;
      For Cikl := 1 To UzenetSzam Do
        BufferP^[BufPointer+Cikl] := Random(256);

      Kodol(BufferP,BufPointer,@BaseBytes,0);    { Kodolas }
      BlockWrite(N_Fil,
                 BufferP^,
                 BufPointer+UzenetSzam)
    End
  Else
  {$ENDIF}
      BlockWrite(N_Fil,
                 BufferP^,
                 BufPointer);

{$I+}
End;

Procedure New_Save;

Var

Sor    : Array[0..600] Of Byte;
SorCh  : Array[0..600] Of Char Absolute Sor;
BufTomb: Array[0..2] Of Byte;
Num,ONum : Word;
Hossz,Font,Count,Azonos,FMax,AMax  : Byte;
Poz,Opoz,Mainp : Integer;
Pt,Opt  : Lpoint;
Legelso : Boolean;
Crst    : String[2];
Ch,Kar  : Char;
SorokSzama,SoSz : word;
Azonos_attr : Boolean;
Cikl_valt,Tab_szamolo : byte;


Procedure Convert_And_WriteLine(Szam : Byte);
Var
X,P : Integer;
Ch  : Char;
ErrC: Integer;
ErrS: String[40];

Procedure Create_Sor;
Var
X,Bc: Integer;
Attr: Byte;
cch : char;
eloz: byte;
nul_start : boolean;

BEGIN
  Cik := C77;
  While (Cik >= 0) AND (Pt^.Chars[C80+Cik] = #00) Do Dec(Cik);

  Inc(Cik);

  Sor[Num] := Cik;   { Sorhossz }
  Inc(Num);

  ONum := Num;

  Inc(Num);

  If Cik > 0 Then
  BEGIN
    Azonos_attr:=True;
    X:=1;
    nul_start:=False;

    While ((X < Cik) or ((Cik=1) and (X=1))) and (Azonos_attr) DO
      BEGIN
        Attr:=Pt^.Attribs[X] And 15;
        Font:=Pt^.Attribs[X-1] And 15;
        If (Attr<>Font) then Azonos_attr := False;
        Inc(X);
      End;

    If not(Azonos_attr) then
      BEGIN
        Font  := $80;
        Count := 0;
        For X := 0 To Cik-1 Do   { Attributum ciklus }
          BEGIN
            Attr := Pt^.Attribs[X] AND 15;
            If (Attr <> Font) { and (Attr > 0) VF } Then  { font valtas }
              BEGIN
                If Count > 0 Then { Az elîzî azonos karakterek attributuma }
                  BEGIN
                    Count := (Count SHL 4);
                    Inc(Count,Font);
                    Sor[Num] := Count;
                    Inc(Num);
                  End;
                Count := 1;
                Font  := Attr;
              End
            Else  { ugyanaz a font marad }
              BEGIN
                Inc(Count);
                If Count = 15 Then
                  BEGIN
                    Sor[Num] := $F0 + Font;
                    Inc(Num);
                    Count := 0;
                  End;
              End;

          End;  {For Cik}

        If Count > 0 Then { A maradek karakterek attributuma }
          BEGIN
            Count := (Count SHL 4);
            Inc(Count,Font);
            Sor[Num] := Count;
            Inc(Num);
          End;
      End
    else
      BEGIN
        Sor[Num]:=(Font and 15);
        Inc(num);
      End;

    Azonos := 1;

    Kar:=#255;
    For X := 0 To Cik Do  { Karakter ciklus }
    BEGIN

      Ch := Pt^.Chars[C80+X];

      If Ch <> Kar Then
      BEGIN
        If X > 0 Then
        Begin
        
          Case Azonos Of

           1: BEGIN
                SorCh[Num] := Kar;
                Inc(Num);
              End;
           2: BEGIN
                SorCh[Num]   := Kar;
                SorCh[Num+1] := Kar;
                Inc(Num,2);
                Azonos := 1;
              End
            Else
            BEGIN
              If Azonos >= 128 Then
              Begin
                Dec(Azonos,127);
                Sor[Num] := $80 + 127;
                Inc(Num);
                SorCh[Num] := Kar;
                Inc(Num);
              End;
              Sor[Num] := $80 + Azonos;
              Inc(Num);
              SorCh[Num] := Kar;
              Inc(Num);
              Azonos := 1;
            End;
          End; { of Case }

        End; { If X > 0 }

        Kar := Ch;
      End
      Else Inc(Azonos);

    End;  {For Cik}

  End {If Cik >= 0}

End;   {Create_Sor}


BEGIN  {Convert_And_WriteLine}

  {Num := 3;}

  Sor[Num] := Szam;  { Fîsor = 00 ; Indexsor = sorsz†m }
  Inc(Num);

  (* Sor[Num-1] := 00; *)   { Nincs lapvÇge }

  Create_sor;

  Sor[ONum] := Byte(LapVeg(Poz));       { LapvÇge van }

  If MainLine(Poz) Then
  Begin
    If (Pt^.Attribs[0] and 128) > 0 then Inc(Sor[ONum],2);
    If (Pt^.Attribs[C77] AND Protected) = Protected Then
      Sor[ONum] := Sor[ONum] OR 128; {Protected}
  End;

  Inc(Lines);


  If NOT(Header_Mode) AND (Lines MOD 50 = 0) Then WriteLinesPercent(True);

(*  If Num >= (SizeOf(Sor)-512) Then
  Begin *)
    {$I-}
    BlockWritePuff(Fil,Sor[0],Num);
    {$I+}
    Num := 0;
(*  End; *)

  ErrC := IOResultM;

  If ErrC <> 0 Then
  BEGIN
    Case ErrC Of
      101 : ErrS := 'Betelt a lemez.';
      152 : ErrS := 'Kiny°lt a floppy egysÇg.';
      Else  ErrS := 'Form†zatlan, vagy sÇrÅlt lemez.';
    End;

    If Not ModemMode Then
    Begin
      ErrorDelay := 250;
      Error(18,':  '+ErrS);
    End;

    Exital := True;
    Exit;
  End;

End;  {Convert_And_WriteLine}

var mfn : Word;

BEGIN {New_Save}

   InitLines(EditNum);

   {
   TotalLines := EndLine[EditNum] - StartLine[EditNum];
   Lines      := 0;
   }

   Poz        := StartLine[Editnum];
   SorokSzama := EndLine[EditNum] - Poz + 1;
   SoSz       := SorokSzama;

   Byte(Header30[2]) := Byte('C') + ((C80-80) DIV 16);

   {$I-} If Tip = NormalFile Then
     BlockWritePuff(Fil,Header30,4); {$I+}
   If IOResultM <> 0 Then
   BEGIN
     If Not ModemMode Then Error(18,'');
     Exital := True;
     Exit;
   End;

   (*
   Fej_pos:=FilePos(Fil);  *)

   {$I-} BlockWritePuff(Fil,SorokSzama,2); {$I+}

  If IOResultM <> 0 Then
  BEGIN
    If Not ModemMode Then Error(18,'');
    Exital := True;
    Exit;
  End;

   If Tip = NormalFile then
     BEGIN
      {$I-} BlockWritePuff(Fil,LeftMar[EditNum],1);    {$I+}
      If IOResultM <> 0 Then
      BEGIN
        If Not ModemMode Then Error(18,'');
        Exital := True;
        Exit;
      End;

      {$I-} BlockWritePuff(Fil,RightMar[EditNum],1);   {$I+}
      If IOResultM <> 0 Then
      BEGIN
        If Not ModemMode Then Error(18,'');
        Exital := True;
        Exit;
      End;

      tab_szamolo:=0;
      For cikl_valt:=LeftMar[EditNum] to RightMar[EditNum] do
        If tabs[cikl_valt] then Inc(tab_szamolo);
      If (EditNum=BufferNum) and (OszlopVolt) then Tab_szamolo:=Tab_szamolo or $80;
      {$I-} BlockWritePuff(Fil,tab_szamolo,1);
      If IOResultM <> 0 Then
      BEGIN
        If Not ModemMode Then Error(18,'');
        Exital := True;
        Exit;
      End;

      For cikl_valt:=LeftMar[EditNum] to RightMar[EditNum] do
        If tabs[cikl_valt] then
          BEGIN
            {$I-} BlockWritePuff(Fil,cikl_valt,1);
              If IOResultM <> 0 Then
              BEGIN
                If Not ModemMode Then Error(18,'');
                Exital := True;
                Exit;
              End;
          End;

     Mfn := MaxFontNum;
     Num := MaxFontNum;

     {$IFDEF ROSSZFILE}
     If MaxFontNum > 10 Then
       Num := 10
     Else
       Num := MaxFontNum;
     Mfn := Num;
     {$ENDIF}


     {$I-} BlockWritePuff(Fil,Num,1); {$I+}
      If IOResultM <> 0 Then
      BEGIN
        If Not ModemMode Then Error(18,'');
        Exital := True;
        Exit;
      End;

     For Cik := 1 To MfN Do
       BEGIN
       {$I-} BlockWritePuff(Fil,FontNames[Cik][0],Byte(FontNames[Cik][0])+1); {$I+}
         If IOResultM <> 0 Then
         BEGIN
           If Not ModemMode Then Error(18,'');
           Exital := True;
           Exit;
         End;
       End;

     {$I-} BlockWritePuff(Fil,HeadFootName[0],Byte(HeadFootName[0])+1); {$I+}
     If IOResultM <> 0 Then
     BEGIN
       If Not ModemMode Then Error(18,'');
       Exital := True;
       Exit;
     End;

   End;

   If EndLine[EditNum] >= Poz Then
     BEGIN
        Mainp := Poz;
        Font    := 1;

        While Not(Mainline(Mainp)) Do Inc(Mainp); {Raall az elso fo sorra}
        Legelso := True;

        Num := 0;

        Repeat

           If Not Legelso Then Mainp := Nextmain(Mainp);

           FMax := Upind(Mainp);
           AMax := DownInd(MainP);

           Sor[Num]   := 00;     { 00 = Header }
           Sor[Num+1] := FMax;   { Felsok      }
           Sor[Num+2] := AMax;   { Alsok       }

           Inc(Num,3);

           (*
           BufTomb[0] := 00;     { 00 = Header }
           BufTomb[1] := FMax;   { Felsok      }
           BufTomb[2] := AMax;   { Alsok       }

           {$I-} BlockWritePuff(Fil,BufTomb,3); {$I+}
           If IOResultM <> 0 Then
           BEGIN
             If Not ModemMode Then Error(18,'');
             Exital := True;
             Exit;
           End;
           *)

           While Upline(Poz) Do
           BEGIN

             Heap_pos(Pt,PointerTomb^[Poz]);
             Convert_And_WriteLine(UpInd(Poz));
             FreeEms1(PointerTomb^[Poz]);
             If Exital Then Exit;
             Inc(Poz);
           End;

           Heap_pos(Pt,PointerTomb^[Poz]);  { Fo sor }
           Convert_And_WriteLine(00);
           FreeEms1(PointerTomb^[Poz]);
           If Exital Then Exit;
           Inc(Poz);

           If Poz <> EndLine[Editnum]+1 Then
             While Downline(Poz) Do
             BEGIN
               Heap_pos(Pt,PointerTomb^[Poz]);
               Convert_And_WriteLine(UpInd(Poz));
               FreeEms1(PointerTomb^[Poz]);
               If Exital Then Exit;
               Inc(Poz);
             End;

             If Legelso Then Legelso := False;

        Until LastMain(Mainp);

        (*
        {$I-}
        BlockWritePuff(Fil,Sor[0],Num);
        {$I+}
        *)

        If NOT(Header_Mode) Then WriteLinesPercent(True);

        If IOResultM <> 0 Then
        BEGIN
          If Not ModemMode Then Error(18,'');
          Exital := True;
          Exit;
        End;

     End  { If Nem ures az editor }
     Else Beepel(666);


End; {New_Save}

Procedure Save{(Var Filename: FnTyp; SaveMode : SaveType; FileMode : Filetype)};

Function IOError: Boolean;
BEGIN
If IOresultM <> 0 Then
  BEGIN
    If Not ModemMode Then Error(18,'');
    If SaveMode <> BackupMode Then Bool := Remove_Window;
    IOError := True;
  End
  Else IOError := False;
End;

Function NoOverWrite: Boolean;
Var C   : Char;
    Ws  : String[128];
    P   : Byte;
    Graphic : Boolean;
    Buff: Array[0..12] Of Byte;
Begin

  Graphic := (CRTMode = 6);

  {$IFDEF OROSZ}
  Ws := FileName+' '+MarLetezik+'(Ñ/ç) ? ';
  {$ELSE}
  Ws := FileName+' '+MarLetezik+'('+YesChar+'/'+NoChar+') ? ';
  {$ENDIF}
  If Length(Ws) > 78 Then Ws[0] := #78;

  P := 40-(Length(Ws) DIV 2);

  If Graphic Then
  Begin
    Move(Wkx1,Buff,12);  {Wkx1,Wky1,Wkx2,Wky2,Slength,Enged: Integer}
    Ablak(8,20,1,Fontoffs,SortabOffs,64);
    GotoX(P,20);
  End
  Else
  Begin
    BOOL := CREATE_WINDOW(1,9,80,11,InpSt8,CA[DispMode,1],CA[DispMode,4]);
    CurOn;
    GotoXY(P,1);
  End;

  Beepel(660);
  Writ(Ws);
  Speak2(130,230);

  PuffiRekurzio := True;
  Wait(C);
  PuffiRekurzio := False;

  If NOT Graphic Then
  Begin
    CurOff;
    BOOL := Remove_Window;
  End
  Else Move(Buff,Wkx1,12);  {Wkx1,Wky1,Wkx2,Wky2,Slength,Enged: Integer}

  NoOverWrite := (C <> YesChar);

  Ch := 0;
  Sc := 0;
End;

Label Kiugrik;

VAR

BakFilename : FnTyp;
OfileName   : FnTyp;
Ext    : String[4];
Poz,Res: Integer;
Cix,Cx : Byte;
Wsx    : String[4];
Header : String[14];
Escap  : Boolean;
NewFil : File;
SEXT   : String[4];
Textfil,BakFil  : Szoveg;
Fil    : File;
Buffer : Bufft;

{EstimatedFileSize : LongInt;}

Const Tomm   : Array[False..True] Of String[3] = ('','NEM');

BEGIN  { Save }

  Byte(GlobalMode) := Byte(SaveMode);

  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}

  Exital    := False;
  ESC       := False;
  OfileName := FileName;

  BufferP   := @Buffer;
  BufPointer:= 0;

  {$IFDEF HALO}
{  If Hment Then}
    Begin
  {$ENDIF}

  {$IFDEF BEMUTAT}
  If ErvenyesIdoszak Then
    Begin
  {$ENDIF}

  {$IFDEF EKNET}
  If ESave Then
    Begin
  {$ENDIF}


  If SaveMode <> AllSaveMode Then
    BEGIN

      SExt:= '';

      {EstimatedFileSize := C80 * (EndLine[EditNum] - StartLine[EditNum]);}

      ESC := (StartLine[EditNum] > EndLine[EditNum]);

      {
      If NOT ESC Then
      Begin
        BOOL:= CREATE_WINDOW(33,8,47,12,'xxx',CA[DispMode,1],CA[DispMode,2]);
        EstimatedFileSize := C80 * (EndLine[EditNum] - StartLine[EditNum]);
        GotoXY(2,2);
        Write(EstimatedFileSize);
        If ReadKey = ' ' Then;
        Bool := Remove_Window;
      End;
      }

      Case FileMode Of

      Document: Begin
                  Header := DocuSt;
                  Ext := '.'+DMask;
                End;
      ASCII   : Begin
                  Header := ASCIISt;
                  Ext := '.'+ASCIIMask;
                End;
      Ventura : Begin
                  Header := VenturaSt;
                  Ext := '.'+VENTMask;
                End;
      End;  {Case}
    End
    Else
    BEGIN
      Header := InpSt4;
      Ext    := FMask;
      ESC := (EndLine[27] < StartLine[4]);
    End;

    If Not ESC Then
    BEGIN

      If SaveMode <> BackupMode Then
      {$IFDEF NORVEG}
        BOOL:= CREATE_WINDOW(1,5,80,11,InpSt6+Header,CA[DispMode,1],CA[DispMode,2]);
      {$ELSE}
        {$IFDEF ANGOL}
          BOOL:= CREATE_WINDOW(1,5,80,11,InpSt6+Header,CA[DispMode,1],CA[DispMode,2]);
        {$ELSE}
          BOOL:= CREATE_WINDOW(1,5,80,11,Header+InpSt6,CA[DispMode,1],CA[DispMode,2]);
        {$ENDIF}
      {$ENDIF}

      If SaveMode In [NormalMode,AllSaveMode] Then
      BEGIN
        MaxStringLen := FnSize;
        Mentes_e:=True;

        Poz := Pos('.',Filename);

        If Poz = 0 Then FileName := FileName + Ext
        Else
        Begin
          SExt := Copy(FileName,Poz+1,3);
          UpperCase(SExt);
          If ((FileMode = Document) AND
             ((SExt = ASCIIMask) OR (SEXT = VentMask))) OR
             ((FileMode = ASCII) AND NOT(ASCIIVolt[EditNum])) OR
             ((FileMode = Ventura)) Then
          Begin
            FileName[0] := Char(Poz-1);
            FileName := FileName + Ext;
          End;
        End;

        Input_FileName(Enter_fn,Filename,64,False);

        UpperCase(FileName);

        MasNev := (FileName <> OFileName);
        MasNemUres := (OFileName <> UresName);
        Mentes_e:=False;

        CurOff;
      End;

      If not ESC then CheckFileName(FileName);

      CurOff;

      If Not ESC Then CheckWrite(FileName); { Ez is az ESC - t allitja be ! }

      If NOT ESC Then
      BEGIN

         Poz := Pos('.',Filename);
         If Poz = 0 Then Poz := Length(Filename)+1;

         Bakfilename   := Filename;
         Bakfilename[0]:= Char(Poz-1);
         Bakfilename := Bakfilename + '.BAK';

         ModemMode := FileName = 'XMODEM';  { VF - FI }

         If (Pos('.',Filename) = 0) And (not ModemMode)
            Then Filename := Filename + Ext;

         {$IFDEF EKSZINFO}
         If MegisIze Then UjFileNev(FileName);
         {$ENDIF}
        
         If ModemMode then                  { VF - FI }
           BEGIN
             If FileMode<>Ventura then SaveModem(Filename,NormalMode,FileMode)
             else
               BEGIN
                 Error(20,VenturaSt+', XMODEM'+NotAllowed);
                 bool:=Remove_window;
               End;
             Exit;                          { VF - FI }
           End;

         ESC := False;


         Assign(Fil,Filename);

         If {(SaveMode <> BackupMode) And}
             (Not ModemMode) Then
         BEGIN
           {$IFDEF SECRET}
           If Not(ESC) AND (MasNev) AND (KellJelszo) AND
              (VanJelszo = Kodolatlan[EditNum]) AND
              (MasNemUres) Then
           Begin
             Speak(136);
             Error(20,NemVegreHajthato+Tomm[Kodolatlan[EditNum]]+' JELSZAVAS FILE VOLT !');
             FileName := OfileName;
             Esc := True;
           End;
           {$ENDIF}

           {$I-}
           Reset(Fil);

           If IOresult = 0 Then
           BEGIN

             {$IFDEF INFOHIV}
             ESC := NoOverWrite;
             {$ELSE}
             If (SaveMode <> BackupMode) Then
               If (MasNev) OR ((FileMode = Document) AND (ASCIIVolt[EditNum]))
                 Then ESC := NoOverWrite;
             {$ENDIF}

             Close(Fil);
             Res := IOResult;
             If NOT ESC Then
             Begin
               Assign(BakFil,Bakfilename);
               Erase(BakFil);
               Res := IOResult;
               If Not( VanJelszo   And
                       KellJelszo  And
                       (Kodolatlan[EditNum] Or JelszValt[EditNum] Or BackupVan))
                  AND
                  Not( Not(Kodolatlan[EditNum]) And
                       Not(VanJelszo) And
                       KellJelszo) Then
                 Begin
                   Assign(BakFil,Filename);
                   Rename(BakFil,Bakfilename);
                   Res := IOResult;
                 End;


             End;
           End; { Ha mar van ilyen file }

           {$I+}

           {$IFDEF SECRET}
           If VanJelszo And KellJelszo And Not(BackupVan) And Not(Esc) Then
           Begin
             Kodolatlan[EditNum] := False;
             JelszValt[EditNum] := False;
           End;
           {$ENDIF}

         End; {If not ModemMode}

         If NOT Esc Then
         Begin
           If (Filemode = ASCII) OR (Filemode = Ventura) Then
           BEGIN
             Assign(TextFil,Filename);
             {$I-}
             Rewrite(TextFil);
             {$I+}
           End
           Else
           BEGIN
             Assign(Fil,Filename);
             {$I-}
             Rewrite(Fil,1);
             {$I+}
           End;

           If IOresultM <> 0 Then
           BEGIN
             If Not ModemMode Then Error(3,Filename)
           End
           Else
           BEGIN
             {$IFDEF SECRET}
             If KellJelszo And VanJelszo Then
               Begin
                 {$I-}
                 BlockWrite(Fil,kodazon,3);
                 {$I+}
                 If IORESULT <> 0 Then
                   Begin
                     Error(18,'');
                     Exital := True;
                     Exit;
                   End
               End;
             {$ENDIF}

             If (Filemode = ASCII) OR
                (Filemode = Ventura) Then SetTextBuf(TextFil,Buffer);

             If SaveMode <> BackupMode Then
             BEGIN
               ClrScr;
               GotoXY(40-((Length(FileName)+20) DIV 2),2);

               {$IFDEF NORVEG}
                 Write(InpSt6,Filename);
                 Write('  ',Texts[6],' ');
               {$ELSE}

                 {$IFDEF ANGOL}
                   Write(InpSt6,Filename);
                   Write('  ',Texts[6],' ');
                 {$ELSE}
                   Write(Filename,InpSt6);
                   Write('  ',Texts[6],' ');
                 {$ENDIF}

               {$ENDIF}

               ATTRIBUTE(9,3,9,78,CA[DispMode,1]);

             End;

             If SaveMode = AllSaveMode Then
             BEGIN

               Header30Header[2] := 'C';
               Header30Header[3] := 'F';

               {$I-} BlockWritePuff(Fil,Header30Header,4); {$I+}

               If IOResultM <> 0 Then
               BEGIN
                 If Not ModemMode Then Error(18,'');
                 Exital := True;
                 Exit;
               End;

               For Cix := 4 To 27 Do
               BEGIN
                 If StartLine[Cix] <= EndLine[Cix] Then
                 BEGIN

                   If Cix >= 16
                   Then
                   BEGIN
                     Header30Header[2] := 'O';
                     Cx     := Cix - 12;
                   End
                   Else
                   BEGIN
                     Header30Header[2] := 'H';
                     Cx := Cix;
                   End;
                   Case Cx Of

                      4: Header30Header[3] := 'A';
                      5: Header30Header[3] := 'E';
                      6: Header30Header[3] := 'O';
                      Else  Header30Header[3] := Char(Cx+48-6);

                   End; {Case}

                   EditNum := Cix;
                   {$I-} BlockWritePuff(Fil,Header30Header,4); {$I+}
                   If IOResultM <> 0 Then
                   BEGIN
                     If Not ModemMode Then Error(18,'');
                     Exital := True;
                     Exit;
                   End;

                   Header_Mode := True;
                   New_Save(Fil,HeaderFile);
                   Header_Mode := False;

                   If Exital Then Goto Kiugrik;
                   { WritelnM(Fil,''); }
                   If IOError Then Exit;

                 End; {Ha nem ures ez az editor}
               End; {For Cix}
             End
             Else
             Begin
               Exital := False;

               If FileMode = Document
                 Then New_Save(Fil,NormalFile)
                 Else ASCII_Save(TextFil,FileMode); {ASCII vagy Ventura}

                 If (GlobalErrorNum = 18) AND (ErrorDelay = 250) Then
                 Begin
                   Close(Fil);
                   Erase(Fil);
                   Error(20,FileName+' file tîrîlve !');
                   ErrorDelay := 100;
                 End;

               {$IFDEF CHEMOLIMPEX}
               If Not Exital Then
               Begin
                 SzekreterFile := FileName;
                 If Pos('\',SzekreterFile)+Pos(':',SzekreterFile) = 0 Then
                 Begin
                   If Path[Length(Path)] <> '\' Then
                     SzekreterFile := '\'+SzekreterFile;
                   SzekreterFile := Path+Szekreterfile;
                 End;
               End;
               {$ENDIF}

             End;

             If Exital Then Goto Kiugrik;

             If Filemode In [ASCII,Ventura] Then
               Close(Textfil)
             Else
               Begin
                 BlockWriteMaradek(Fil);
                 If IoResult <> 0 Then Goto Kiugrik;
                 Close(Fil);
               End;

             If IOError Then Exit;

             If FileMode = Document Then Valtozas[EditNum] := False;
           End;

         End; {If NOT ESC}

      End; {If NOT ESC}

   {Wor := EditNum;
   Writest('EditNum = ',Wor);}
   ChangeToNoname(EditNum);

   If (SaveMode <> AllSaveMode) AND (FileMode <> Document) Then
   Begin
     Poz := Pos('.',FileName);
     If Poz > 0 Then FileName[0] := Char(Poz-1);
     If SExt <> '' Then FileName := FileName + '.' + SExt;
   End;

   If ModemMode Then FileName := OfileName;

   If SaveMode <> BackupMode Then
   BEGIN
     Bool := Remove_Window;
     CurOff;
     Fresh_Info;
   End;
  End   { If nem ures az editor }
  Else Beepel(666);

  Exit;

Kiugrik:  If SaveMode <> BackupMode Then Bool := Remove_Window;
          Exit;

{$IFDEF HALO}
   End;
{$ENDIF}
{$IFDEF EKNET}
   End;
{$ENDIF}
{$IFDEF BEMUTAT}
   End;
{$ENDIF}

End;  { Procedure Save }

  {$I+}

{$ENDIF}     { Ifndef DEMO}




PROCEDURE Input_FileName(kiir : string; VAR inpu : string; hossz : byte; UjSor: Boolean);

VAR o_u : string;
    jo  : boolean;
    P,
    Poz,
    Cik: ShortInt;
    uuo : string;
    InpuX: String;
    Graphic: Boolean;
    WorkS,PathS: String[80];

BEGIN
  o_u:=inpu;

  Graphic := (CRTMode = 6);

  REPEAT

    If NOT Graphic Then
    Begin
      If UjSor Then GoToXY(2,3)
               Else GotoXY(2,2);
    End
    Else GotoX(26,20);
    CurOn;

    Jo := True;

    Input_String(kiir,inpu,hossz);
    CurOff;

    InpuX := Copy(Inpu,1,45+3*Byte(NOT(Graphic)));

    {$IFDEF WORKDIR}
    WorkS  := UpperCas(Inpu);
    PathS  := UpperCas(Eredeti_Path);
    {$ENDIF}

    If NOT ESC Then
    Begin
      If (Pos(';',inpu)>0) or (Pos(':',inpu)=1)
      {$IFDEF WORKDIR}
      OR (
          (Length(WorkS) >= 2) AND
          (WorkS[2] = ':') AND
          (WorkS[1] > 'D') AND
          (Copy(WorkS,1,Length(PathS)) <> PathS)
         )
      {$ENDIF}
      Then
        BEGIN
          Error(34,inpuX);
          jo:=False;
          inpu:=o_u;
        End;

      P := Pos('.',Inpu);
      Poz := P;
      If P = 0 Then P := Length(Inpu)+1;

      Cik := P-1;

      While (Cik > 0) AND NOT(Inpu[Cik] In ['\',':']) Do Dec(Cik);

      If P-Cik > 9 Then
      Begin
        Jo := False;
        Error(51,InpuX);
        SzoPoz := Cik+8;
      End;

      {
      If Length(Inpu)-P > 3 Then
      Begin
        Jo := False;
        Error(52,InpuX);
        SzoPoz := Poz+3;
      End;
      }

      If Jo Then
        If (Length(inpu)=2) and (Pos(':',inpu)=2) then
          BEGIN
            If Mentes_e then
              BEGIN
                jo:=False;
                Error(34,inpuX);
              End
            else
              BEGIN
                CheckRead(inpu);
                If ESC then
                  BEGIN
                    jo:=False;
                    Esc:=False;
                    CurOff;
                    Error(15,inpuX);
                  End
                else jo:=True;
              End;
          End
        else
        Begin
          jo:=Path_Check(copy(inpu,1,BackFind(inpu,'\')-1));
          If NOT Jo Then ESC := False;
        End;
    End
    Else Inpu := O_u;
  UNTIL ESC or jo;
End;

FUNCTION AddBack(duma : string): string;

BEGIN
                                                 
  If DelSpace(duma)='' then AddBack:=DelSpace(duma)            
  else                                                         
    If duma[Length(duma)]='\' then AddBack:=Duma               
    else AddBack:=duma+'\'                                     
End;                                                           

PROCEDURE Dir; {(valami : string;
                VAR valasz : nevtomb; VAR valasz_db : word;
                VAR utvonal : string);}

CONST van      : boolean = False;
      elso_kor : boolean = True;
      tovabb   : boolean = False;

Type         NevTomb14   = array[1..dir_nagysag] of string[14];
             LongIntTomb = Array [1..Dir_Nagysag] of LongInt;

VAR

nevek      : NevTomb14;
nevek12    : nevtomb Absolute Nevek;

Datumok    : Array[1..Dir_Nagysag] Of String[6{7}];

Direk      : Array[1..Dir_Darab] Of String[14];
direk12    : dirtomb Absolute Direk;

attrok     : attrtomb;

FileMeret  : LongIntTomb;
FileDatum  : LongIntTomb;

DirDatum   : Array [1..Dir_darab] of LongInt;

Datum      : LongInt;

DirInfo    : SearchRec;
cikl       : word;
puffer     : integer;
old_path   : string[64];
az_ut      : string;
a_drive    : byte;
Last_drive : byte;
osv_puff   : string;
Dir_error  : boolean;
cchh       : char;
elso_gr_dir: boolean;
Graphic    : boolean;
Kepke      : array [0..30] of GraphSor;
buff       : array [1..12] of byte;
TOUT       : word;
Cikluss    : word;
{$IFDEF EKSZINFO}
RecPosok   : IindexT;
{$ENDIF}

Procedure LastName;
Begin
  {$IFNDEF WORKDIR}
  Nevek[ossz_db] := PontPont;
  Move(Ossz_Db,Nevek[ossz_db][13],2);
  Nevek[ossz_db][0] := #14;
  {$ENDIF}
End;


PROCEDURE Akt_dir_beolv;

VAR cikl            : Integer;
    Code,Cik        : Integer;
    Szam,TempW,Hol  : Word;
    W               : Array[1..Dir_Nagysag] Of Word;
    St              : String[4];
    Temp            : String[14];
    TempLong        : LongInt;

Procedure SortArrays(Var Nev_Db: Word;
                     Var XMibol;
                         Hossz: Integer;
                     Var XFileMeret;
                     Var XFileDatum;
                     Var Nevek : NevTomb14;
                         Param: Byte);
Var Cik      :  Word;
    FileMeret:  LongIntTomb Absolute XFileMeret;
    FileDatum:  LongIntTomb Absolute XFileDatum;
    Mibol    :  Array[1..32000] Of Byte Absolute XMibol;

Begin
  For Cik := 1 To Nev_Db Do
  Begin

    Move(Mibol[((Hossz+1)*Cik)-1],Szam,2);

    If Param <> 3 Then Mibol[((Hossz+1)*Cik)-Hossz] := Hossz-2;

    TempW := 1;
    While W[TempW] <> Szam Do Inc(TempW);
    Hol   := TempW;

    TempLong := FileDatum[Cik];
    FileDatum[Cik] := FileDatum[Hol];
    FileDatum[Hol] := TempLong;

    If Param = 3 Then
    Begin
      Temp := Nevek[Cik];
      Nevek[Cik] := Nevek[Hol];
      Nevek[Hol] := Temp;
    End;

    If Param > 1 Then
    Begin
      TempLong := FileMeret[Cik];
      FileMeret[Cik] := FileMeret[Hol];
      FileMeret[Hol] := TempLong;

      FileDatum[Cik] := MaxLongInt - FileDatum[Cik];

    End;

    TempW := W[Cik];
    W[Cik] := W[Hol];
    W[Hol] := TempW;

  End;
End;

BEGIN
  FindFirst(addback(az_ut)+valami,Archive,DirInfo);
  nev_db:=1;
  FillChar(nevek,Dir_nagysag*15{13},' ');
  While (DosError=0) and (nev_db < dir_nagysag) do
    BEGIN
      With DirInfo Do
      Begin
        Nevek[nev_db] := Copy(Name+Space12,1,12);
        { Move(Nev_Db,Nevek[Nev_Db][13],2); }
        Nevek[Nev_Db][13] := Char(Lo(Nev_Db));
        Nevek[Nev_Db][14] := Char(Hi(Nev_Db));
        Nevek[Nev_Db][0] := #14;
        FileMeret[nev_db] :=  Size;
        FileDatum[nev_db] :=  MaxLongInt - Time;
        If (Attr and ReadOnly) = ReadOnly then
           nevek[nev_db][1]:=Char(Byte(nevek[nev_db][1]) or 128);
      End;
      Inc(nev_db);
      FindNext(DirInfo);
    End;
   If (nev_db>1) then
    BEGIN
      Dec(nev_db);
      Inline($FC);
      If nev_db>100 then
      Begin
        Create_Window(Wkx1,Wky1,Wkx1+15,Wky1+2,'',CA[DispMode,1],CA[DispMode,3]);
        GoToX(2,2);
        Writ(Inpst1);
      End;

      If NOT DateSort Then
      Begin

        For Cik := 1 To Nev_Db Do W[Cik] := Cik;

        Sort(Ofs(nevek[1]),Seg(nevek[1]),nev_db,{12}14);

        SortArrays(Nev_Db,Nevek,14,FileMeret,FileDatum,Nevek,2);

        (*
        For Cik := 1 To Nev_Db Do
        Begin

          Move(Nevek[Cik][13],Szam,2);
          Nevek[Cik][0] := #12;

          TempW := 1;
          While W[TempW] <> Szam Do Inc(TempW);
          Hol   := TempW;

          TempLong := FileMeret[Cik];
          FileMeret[Cik] := FileMeret[Hol];
          FileMeret[Hol] := TempLong;

          TempLong := FileDatum[Cik];
          FileDatum[Cik] := FileDatum[Hol];
          FileDatum[Hol] := TempLong;

          TempW := W[Cik];
          W[Cik] := W[Hol];
          W[Hol] := TempW;

        End;
        *)

      End
      Else
      Begin { DateSort }

        For Cik := 1 To Nev_Db Do
        Begin

          W[Cik] := Cik;

          Datum := FileDatum[Cik];
          Datumok[Cik][0] := {#04} #06;

          Datumok[Cik][1] := Char(Lo(Datum SHR 24));
          Datumok[Cik][2] := Char(Lo(Datum SHR 16));
          Datumok[Cik][3] := Char(Lo(Datum SHR 08));
          Datumok[Cik][4] := Char(Lo(Datum));

          { Move(Cik,Datumok[Cik][5],2); }

          Datumok[Cik][5] := Char(Lo(Cik));
          Datumok[Cik][6] := Char(Hi(Cik));

          { Str(Cik:3,St); Datumok[Cik] := Datumok[Cik] + St; }
        End;

        Sort(Ofs(Datumok[1]),Seg(Datumok[1]),nev_db,6{7});

        SortArrays(Nev_Db,Datumok,6,FileMeret,FileDatum,Nevek,3);

        (*
        For Cik := 1 To Nev_Db Do
        Begin

          Move(Datumok[Cik][5],Szam,2);

          {
           Szam := Integer(256*Byte(Datumok[Cik][5]) +
                                Byte(Datumok[Cik][6])); }

          TempW := 1;
          While W[TempW] <> Szam Do Inc(TempW);
          Hol   := TempW;

          Temp := Nevek[Cik];
          Nevek[Cik] := Nevek[Hol];
          Nevek[Hol] := Temp;

          TempLong := FileMeret[Cik];
          FileMeret[Cik] := FileMeret[Hol];
          FileMeret[Hol] := TempLong;

          TempLong := FileDatum[Cik];
          FileDatum[Cik] := FileDatum[Hol];
          FileDatum[Hol] := TempLong;

          TempW := W[Cik];
          W[Cik] := W[Hol];
          W[Hol] := TempW;

        End;
        *)

      End;

      If nev_db>100 then Remove_Window;

    End
  else nev_db:=0;
  {$IFDEF EKSZINFO}
  If MostKellInf Then Nev_bejelol(Nevek,Recposok,Nev_Db);
  {$ENDIF}

  {$IFNDEF WORKDIR}

  dir_db:=1;
  FindFirst(addback(az_ut)+'*.*',Directory,DirInfo);
  While (DosError=0) and (dir_db+nev_db < dir_nagysag) and (dir_db<dir_darab) do
    BEGIN
      If (DirInfo.name<>'.') and (DirInfo.name<>'..') and
         (DirInfo.Attr = Directory) then
        BEGIN
          With DirInfo Do
          Begin
            Direk[dir_db]:=Copy(Name+Space12,1,12);
            { Move(Dir_Db,Direk[Dir_Db][13],2); }
            Direk[Dir_Db][13] := Char(Lo(Dir_Db));
            Direk[Dir_Db][14] := Char(Hi(Dir_Db));
            DirDatum[Dir_db] :=  Time;
          End;
          Inc(dir_db);
        End;
      FindNext(DirInfo);
    End;
  If dir_db>1 then
    BEGIN
      Dec(dir_db);
      For Cik := 1 To Dir_Db Do W[Cik] := Cik;

      Inline($FC);
      Sort(Ofs(direk[1]),Seg(direk[1]),dir_db,14{12});

      SortArrays(Dir_Db,Direk,14,FileMeret,DirDatum,Nevek,1);

      (*
      For Cik := 1 To Dir_Db Do
      Begin

        Move(Direk[Cik][13],Szam,2);
        Direk[Cik][0] := #12;

        TempW := 1;
        While W[TempW] <> Szam Do Inc(TempW);
        Hol   := TempW;

        TempLong := DirDatum[Cik];
        DirDatum[Cik] := DirDatum[Hol];
        DirDatum[Hol] := TempLong;

        TempW := W[Cik];
        W[Cik] := W[Hol];
        W[Hol] := TempW;

      End;
      *)

    End
  else
  {$ENDIF NOT WORKDIR}
  dir_db:=0;

  ossz_db:=nev_db+dir_db {$IFNDEF WORKDIR} +1 {$ENDIF};

  If Length(az_ut)>3 then LastName
  else
    BEGIN
      case Byte(az_ut[0]) of
        1 : If az_ut='\' then Dec(ossz_db)
            else LastName;
        2 : If az_ut[2]=':' then Dec(ossz_db)
            else LastName;
        3 : If Pos(':\',az_ut)>0 then Dec(ossz_db)
            else LastName;
      End;
    End;

  If (ossz_db>1) or ((nev_db=0) and (ossz_db=1)) then

  If Dir_Db > 0 Then
  For cikl := Nev_Db+1 to Nev_Db+dir_db do
  Begin
    Nevek[Cikl]:=direk[cikl-Nev_Db];
    {
    Move(Cikl,Nevek[Cikl][13],2);
    Nevek[Cikl][0] := #14;
    }
  End;

End;

PROCEDURE Drive_Select(VAR hibajel : boolean);

VAR cikl   : byte;
    c_cikl : char;
    pff    : string;
    atm_ut : string;

BEGIN
  hibajel:=False;
  GetDir(0,pff);
  If (Pos(':',valami)>0) or (Pos('\',valami)>0) then
    BEGIN
      If Pos(':',valami)=2 then a_drive:=Byte(UpCase(valami[1]))-64
      else
        BEGIN
          GetDir(0,atm_ut);
          a_drive:=Byte(UpCase(atm_ut[1]))-64;
        End;

      If Not(Char(a_drive+64) In ['A'..'Z']) Then
        BEGIN
          Error(2,'');
          Hibajel:=True;
          Exit
        End;
      If Pos('\',valami)=0 then
        BEGIN
          GetDir(a_drive,az_ut);
          valami:=copy(valami,Pos(':',valami)+1,255);
        End
      else
        BEGIN
          If Pos(':',valami)=Length(valami) then
            BEGIN
              GetDir(a_drive,az_ut);
              valami:=copy(valami,Pos(':',valami)+1,255);
            End
          else
            BEGIN
              If BackFind(valami,'\')=1 then az_ut := '\'
              else az_ut:=copy(valami,1,BackFind(valami,'\')-1);
              valami:=copy(valami,BackFind(valami,'\')+1,255);
            End;
        End;
      {$I-}
      ChDir(az_ut);
      {$I+}
      If IOResult<>0 then
        BEGIN
          ChDir(pff);
          Error(2,'');
          Hibajel:=True;
          Exit
        End;
      ChDir(pff);
    End
  else
    BEGIN
      GetDir(0,az_ut);
      a_drive:=Byte(az_ut[1])-64;
    End;
  If valami='' then valami:='*.doc';
End;


PROCEDURE Path_select(valtoz : string; VAR uj_osv : string);

BEGIN
  While Pos('..',uj_osv)>0 do uj_osv:=copy(uj_osv,1,BackFind(uj_osv,'\')-1);
  If valtoz='' then Exit;
  If valtoz[1]<>'.' then uj_osv:=AddBack(uj_osv)+valtoz
  else uj_osv:=copy(uj_osv,1,BackFind(uj_osv,'\')-1);
  If (Pos('..',valtoz)>0) and (uj_osv='') then uj_osv:='\';
End;

VAR dumcsi : st80;
    d_x    : byte;
    vonnal : string[36];

BEGIN
  {$IFDEF EKSZINFO}
  IndexM := @Recposok;
  {$ENDIF}

  utvonal:='';
  elso_gr_dir:=True;
  Graphic    := (CrtMode = 6);
  FillChar(valasz[1],dir_nagysag*13,0);
  UpperCase(valami);
  valasz[1]:='';
  valasz_db:=0;
  Drive_Select(Dir_Error);                          
  If Dir_error then                                 
    BEGIN
      ESC:=True;
      Exit;                                         
    End;

  FreeHot := False;

  {$IFDEF EKSZINFO}
  If MostKellInf Then InfAblakKirak;
  {$ELSE}

  {$IFDEF OROSZ}
  CREATE_WINDOW(2,20,79,22,IniSt2,CA[DispMode,1],CA[DispMode,5]);
  {$ELSE}
    {$IFDEF NORVEG}
    CREATE_WINDOW(2,20,79,22,'Fil '+IniSt2,CA[DispMode,1],CA[DispMode,5]);
    {$ELSE}
    CREATE_WINDOW(2,20,79,22,'File '+IniSt2,CA[DispMode,1],CA[DispMode,5]);
    {$ENDIF}
  {$ENDIF}

  {$ENDIF}

  REPEAT   { Innen a ciklus }
    Path_Select(valasz[1],az_ut);

    If not Path_Check(az_ut) then
      BEGIN
        ESC:=True;
        {$IFDEF EKSZINFO}
        If MostKellInf Then Bool := Remove_Window;
        {$ELSE}
        Remove_Window;
        {$ENDIF}
        Exit;
      ENd;

    Akt_dir_beolv;

    If ossz_db=0 then
      BEGIN
        Error(53,'');  { 'Nincs file Çs kînyvt†r a lemezen !' }
        valasz[1]:='';
        valasz_db:=0;
        ESC:=True;
      End
    else
      BEGIN
        If not Graphic then
          BEGIN
            BOOL := CREATE_WINDOW(Wkx1-1,Wky1-1,Wkx2+1,Wky2+1,Inpst2+valami,
                                  CA[DispMode,1],CA[DispMode,20]);
            ClrScr;
          End
        else
          BEGIN
            If Elso_Gr_Dir then
              BEGIN
                TOUT:=OutJel;
                Elso_Gr_Dir:=False;
                Inline($FC);
                SaveXY;
                FelSor_IdeOdaW(Wkx1-1,Wkx2-Wkx1+4,(Wky2-Wky1)*2+4,Wky1-5,Ofs(kepke),Seg(kepke),Sortaboffs,0);
              End;
            InLine($FC);
            GrWindow(Wkx1-1,(Wky1-4),Wkx2+3,(Wky1-4+(Wky2-Wky1)*2),Inpst2+valami);
          End;
        If (Wkx2-Wkx1)>18 then Csik[0]:=#18
        else Csik[0]:=Char(Wkx2-Wkx1);

        If not Graphic then Display(Csik,Wky2+1,Wkx1+2);


        dumcsi := az_ut;
        If Length(Dumcsi)>Wkx2-Wkx1-(Length(InpSt2)+Length(valami)+4) then
          dumcsi:='..\';
        If Length(' '+InpSt2+AddBack(dumcsi)+valami+' ')>Wkx2-Wkx1 then
          dumcsi:=' '+dumcsi+valami+' '
        else dumcsi:=' '+InpSt2+AddBack(dumcsi)+valami+' ';
        d_x:=Wkx2-Wkx1-Length(Dumcsi);
        d_x:=d_x div 2;
        Csik[0]:=#18;
        Vonnal:=Csik+Csik;
        Vonnal[0]:=Char(d_x);
        Dumcsi:=Vonnal+dumcsi;
        Vonnal[0]:=#36;
        Dumcsi:=copy(Dumcsi+Vonnal,1,Wkx2-Wkx1-1-4);
        If Graphic then
          BEGIN
            Move(Wkx1,Buff,12);
            Set_Choose(7,0,72,10,12,0);
            ChooseMode := None;
          End
        else Display(Dumcsi,Wky1-1,Wkx1+4);

        For Cik := 1 To Dir_Nagysag Do
        Begin
          Nevek[Cik][0] := #12;
          Nevek12[Cik] := Nevek[Cik];
        End;

        PuffiRekurzio := True;
        InfoWindow := True;
        Choose(nevek12,attrok,ossz_db,Dir_Db,DirDatum,FileDatum,FileMeret);
        InfoWindow := False;
        PuffiRekurzio := False;

        If Graphic then Move(Buff,Wkx1,12);

        If not ESC then
          BEGIN
            van:=False;
            cikl:=0;
            While (cikl<ossz_db) and (not van) do
              BEGIN
                Inc(cikl);
                van:=(attrok[cikl] = 1);
              End;
            If van then
              BEGIN
                utvonal:=AddBack(az_ut);
                cikl:=nev_db;
                van:=False;
                While (cikl<ossz_db) and (not van) do
                  BEGIN
                    If cikl<dir_nagysag then Inc(cikl);
                    If attrok[cikl]=1 then van:=True;
                  End;
                If van then
                  BEGIN
                    tovabb:=True;
                    valasz[1]:=DelSpace(nevek12[cikl]);
                  End
                else
                  BEGIN
                    tovabb:=False;
                    cikl:=1;
                    valasz_db:=0;
                    While cikl<=nev_db do
                      BEGIN
                        If attrok[cikl]=1 then
                          BEGIN
                            Inc(valasz_db);
                            valasz[valasz_db]:=DelSpace(nevek12[cikl]);
                          End;
                        Inc(cikl)
                      End;
                  End;
              End
            else
              BEGIN
                valasz_db:=0;
                valasz[1]:='';
              End;
          End
        else
          BEGIN
            valasz[1]:='';
            valasz_db:=0;
          End;
        If not Graphic then Bool:=Remove_Window;
      End;
  UNTIL (not tovabb) or (valasz[1]='');   { Idaig a ciklus }

  {$IFDEF EKSZINFO}
  If MostKellInf Then Bool := Remove_Window;
  {$ELSE}
  Remove_Window;
  {$ENDIF}

  FreeHot := True;

  If Graphic then
    BEGIN
      InLine($FC);
      FelSor_IdeOdaW(Wkx1-1,Wkx2-Wkx1+4,(Wky2-Wky1)*2+4,Wky1-5,Ofs(kepke),Seg(kepke),Sortaboffs,1);
      RestoreXY;
      OutJel:=TOUT;
    End;

  If (valasz[1]>'') and (Pos(':',utvonal)=0) then utvonal:=Char(a_drive+64)+':'+utvonal;
  GetDir(0,osv_puff);
  If (a_drive=Byte(osv_puff[1])-64) and (az_ut=osv_puff)
    then utvonal:='';
  For Cikluss:=1 to valasz_db do
    valasz[Cikluss][1]:=Char(Byte(valasz[Cikluss][1]) and 127);

End;  { DIR }


Procedure Save_Parameters;
Var Cik : Integer;
    Escap : Boolean;
Begin

  BOOL := CREATE_WINDOW(21,7,78,11,IneSt18,CA[DispMode,1],CA[DispMode,2]);
  GotoXY(2,2);
  MaxStringLen := FnSize;
  Input_String(Enter_Fn,DefFile,36);
  UpperCase(DefFile);

  If Not Esc Then CheckFileName(DefFile);
  CurOff;

  Escap := Esc;
  CheckWrite(DefFile);
  Esc := Escap OR Esc;

  If NOT Esc Then
  Begin

    Assign(TextFile,Deffile);
    {$i-} Rewrite(TextFile); {$i+}

    If IOresult <> 0 Then Error(3,'  '+Csak12(DefFile))
    Else
    Begin
      {$I-}
      Writeln(TextFile,Param_tomb[11+6],Pagelen:6);

      Write(TextFile,Param_tomb[12+6],' ');
      For Cik := 1 To MaxEditor Do
        Write(Textfile,RightMar[Cik]:4);
      Writeln(Textfile);

      Writeln(TextFile,Param_tomb[13+6],Printmargin:6);
      Writeln(TextFile,Param_tomb[14+6],Byte(Inser):6);
      Writeln(TextFile,Param_tomb[15+6],Byte(Just):6);
      Writeln(TextFile,Param_tomb[16+6],Byte(Sync):6);
      Writeln(TextFile,Param_tomb[17+6],LineSpace:6);
      Writeln(TextFile,Param_tomb[18+6],Linespacing:6);
      Writeln(TextFile,Param_tomb[19+6],BackupTime:6);
      Writeln(TextFile,Param_tomb[41+6],Max_Key:6);
      Writeln(TextFile,Param_tomb[44+6],Byte(Elvalaszt):6);
      Writeln(TextFile,Param_tomb[45+6],Byte(KellLapDob):6);
      WriteLn(TextFile,Param_tomb[46+6],Byte(PublPrint):6);
      WriteLn(TextFile,Param_tomb[47+6],Byte(Lapszamoz):6);
      Writeln(TextFile,Param_tomb[48+6],' ',LabelDist:4:2);

      {$IFDEF LICENC}
      Writeln(TextFile,Param_tomb[49+6],' ',EmblemaMod:4);
      {$ENDIF}

      If FontPath <> '' Then Writeln(TextFile,Param_tomb[30+6],' ',FontPath);
      If Path <> '' Then Writeln(TextFile,Param_tomb[20+6],' ',Path);

      For Cik := 1 To MaxFontNum Do
        Begin
          While Pos(' ',FontNames[Cik]) <> 0 Do
            Delete(FontNames[Cik],Pos(' ',FontNames[Cik]),1);
          If FontNames[Cik] <> '' Then
            Writeln(TextFile,Param_tomb[Cik],' ',FontNames[Cik]);
        End;

      Write(TextFile,Param_tomb[21+6],' '); {Tabulatorok}
      For Cik := 0 To C77 Do
        If Tabs[Cik] Then Write(Textfile,Cik+1:4);
      Writeln(Textfile);

      Write(TextFile,Param_tomb[22+6],' ');
      For Cik := 1 To MaxEditor Do
        Write(Textfile,LeftMar[Cik]:4);
      Writeln(Textfile);

      Writeln(TextFile,Param_tomb[23+6],FirstPage:6);
      Writeln(TextFile,Param_tomb[24+6],LastPage:6);
      Writeln(TextFile,Param_tomb[25+6],Byte(StopAfterPage):6);
      Writeln(TextFile,Param_tomb[26+6],FirstPageNum:6);

      Write(TextFile,Param_tomb[27+6],' ');
      For Cik := 1 To MaxEditor Do
        Write(Textfile,Color[Cik]:3);
      Writeln(Textfile);

      Write(TextFile,Param_tomb[37+6],' ');
      For Cik := 1 To MaxEditor Do
        Write(Textfile,BackG[Cik]:3);
      Writeln(Textfile);

      Write(TextFile,Param_tomb[42+6],' ');
      For Cik := 1 To MaxColors Do
        Write(Textfile,CA[Colour,Cik]:4);
      Writeln(Textfile);

      Write(TextFile,Param_tomb[43+6],' ');
      For Cik := 1 To MaxColors Do
        Write(Textfile,Ca[BW,Cik]:4);
      Writeln(Textfile);

      Write(TextFile,Param_tomb[38+6],' ');
      For Cik := 1 To MaxEditor Do
        Write(Textfile,FontNum[Cik]:3);
      Writeln(Textfile);

      Writeln(TextFile,Param_tomb[28+6],Byte(WsMode):6);
      Writeln(TextFile,Param_tomb[31+6],Byte(NewDisp):6);
      Writeln(TextFile,Param_tomb[32+6],' ',DMask);
      Writeln(TextFile,Param_tomb[33+6],Paralell_Device:6);
      Writeln(TextFile,Param_tomb[34+6],Serial_Device:6);
      Writeln(TextFile,Param_tomb[35+6],IroIdo:6);
      Writeln(TextFile,Param_tomb[39+6],Byte(CYZ):6);

      If HeadFootName <> '' Then
        Writeln(TextFile,Param_tomb[36+6],' ',Csak12(HeadFootName));

      If MacFile <> '' Then
        Writeln(TextFile,Param_tomb[40+6],' ',Csak12(MacFile));

      Write(TextFile,Param_tomb[29+6]);
      For Cik := 1 To 4 Do
        Write(Textfile,' ',FileName[Cik]);
      Writeln(Textfile);

      Writeln(TextFile,Param_tomb[56],Tizedesek:6);
      Writeln(TextFile,Param_tomb[57],Format:6);

      If GSzammal <> '' Then
        Writeln(TextFile,Param_tomb[58],' ',GSzammal);
      If GBetuvel <> '' Then
        Writeln(TextFile,Param_tomb[59],' ',GBetuvel);

      Writeln(TextFile,Param_tomb[60],Byte(Formatum):6);
      Writeln(TextFile,Param_tomb[61],Byte(Condensed):6);
      Writeln(TextFile,Param_tomb[62],Byte(Gyujtes):6);
      Writeln(TextFile,Param_tomb[63],Byte(DateSort):6);

      Writeln(Textfile,'\=');
      Close(TextFile);
      {$I+}
      If IoResult <> 0 Then
      Begin
        Erase(TextFile);
        Error(3,'  '+Csak12(DefFile))
      End;
    End; {If IOresult = 0}
  End; { If NOT ESC }
  Bool := Remove_Window;
End; { Save_parameters }

Procedure Save_Configuration;
Var
Cik : Integer;
Escap : Boolean;
Ws    : String[64];

Begin
  BOOL := CREATE_WINDOW(21,7,78,11,IneSt27,CA[DispMode,1],CA[DispMode,2]);
  GotoXY(2,2);
  MaxStringLen := FnSize;
  Input_String(Enter_Fn,ConfigFile,36);
  UpperCase(ConfigFile);

  If Not Esc Then CheckFileName(ConfigFile);
  CurOff;

  Escap := Esc;
  CheckWrite(ConfigFile);
  Esc := Escap OR Esc;

  If NOT Esc Then
  Begin

    Assign(TextFile,ConfigFile);
    {$i-} Rewrite(TextFile); {$i+}

    If IOresult <> 0 Then Error(3,'  '+Csak12(ConfigFile))
    Else
    Begin
      Writeln(TextFile,GR_S,VideoMod[Byte(FirstGrMode)]);

      If AlapPath <> '' Then Writeln(TextFile,AP_S,AlapPath);
      If DiskMemPath <> '' Then Writeln(TextFile,DP_S,DiskMemPath);

      If PsFile[False] <> '' Then Writeln(TextFile,PsFile[False]);

      For Cik := 1 To 4 Do
        WriteLn(TextFile,PPar_Nev[Cik]);

      Writeln(TextFile,OV_S,OvrHely[EmsOvr]);

      Writeln(TextFile,KB_S,Tip[Byte(GepTipus)]);


      If ModemBdr = 11 Then Ws := HiSpeed {115200}
                       Else Str(BRS[ModemBdr],Ws);

      Writeln(TextFile,MBR_S,Ws);

      Writeln(TextFile,COM_S,Char(ComPort+48));

      If PRVS <> '' Then
        Writeln(TextFile,PV_S+PRVS);
      If ModC80 <> 80 Then
        Writeln(TextFile,SOR_S,'=',ModC80);

      Writeln(TextFile,SCR_S,'=',ScStep);
      Writeln(TextFile,SCS_S,'=',SaveScMp);
      Writeln(TextFile,LET_S,'=',Char(Byte(Mindigletolt)+48));

      If UjIndS <> 0 Then
        Writeln(TextFile,IND_S,'=',UjIndS);
      If NoXmsKb <> 0 Then
        Writeln(TextFile,XMS_S,'=',NoXmsKb);
      If NoEmsKb <> 0 Then
        Writeln(TextFile,EMS_S,'=',NoEmsKb);
      If DskLinesT <> 0 Then
        Writeln(TextFile,DSK_S,'=',DskLinesT);

      If KonvName[1] <> NincsS Then
        Writeln(TextFile,Key_S,' ',Csak12(KonvName[1]));
      If KonvName[2] <> NincsS Then
        Writeln(TextFile,ASI_S,' ',Csak12(KonvName[2]));
      If KonvName[3] <> NincsS Then
        Writeln(TextFile,ASO_S,' ',Csak12(KonvName[3]));

      Writeln(TextFile,VOL_S,'=',Volume);
      Writeln(TextFile, UZ_S,'=',HanyMasodpercenkentFigyel);

      Close(TextFile);
      {$I+}
      If IoResult <> 0 Then
      Begin
        Erase(TextFile);
        Error(3,'  '+Csak12(ConfigFile))
      End;
    End; {If IOresult = 0}
  End; { If NOT ESC }

  Bool := Remove_Window;

End; { Save_Configuration }


Procedure Ctrl_Alt_Help(Mode : KeyMode);

Var

Boo   : Boolean;
MaxHelpItem,
Cur   : Byte;
Ss    : String[8];
Buff  : Array [0..12] Of Byte;
Scbuf : Array [1..21400] Of Byte;
Ntomb : Nevtomb;
Atomb : AttrTomb;
TOUT  : Word;

Begin

  GraphicMenu := True;

  HelpJelzes := False;

  If (Not InKeyHelp) AND (Graphic) Then
  Begin

    Case Mode Of
      {$IFDEF VER3}
      CtrlMode      : MaxHelpItem := 24;
      AltMode       : MaxHelpItem := 31;
      {$ELSE}
      CtrlMode      : MaxHelpItem := 26;
      AltMode       : MaxHelpItem := 33;
      {$ENDIF}
      Blokk_Mode    : MaxHelpItem := 32;
      Ctrl_AltMode  : MaxHelpItem :=  1;
      Ctrl_ShiftMode: MaxHelpItem :=  2;
    End;

    TOUT := OutJel;
    Set_Nem_lehet;

    InKeyHelp := True;

    MouseCursor(False);

    FelSor_IdeOdaW(5,70,38,2,Ofs(ScBuf),Seg(ScBuf),SortabOffs,0);
    SaveXY;

    GlobalFont := 0;
    MezoFont   := 0;

    Boo := False;

    Move(Wkx1,Buff,12);  {Wkx1,Wky1,Wkx2,Wky2,Slength,Enged}


    {$IFDEF NORVEG}
    GrWindow(5,4,75,38,'HJELP');
    {$ELSE}
    GrWindow(5,4,75,38,'HELP');
    {$ENDIF}

    SystemWriting := True;
    Gotox(6,2);
    Writ('[a]');

    MouseCursor(True);


    For Cik := 1 To MaxHelpItem Do
    Begin
      Case Mode Of
        CtrlMode: Ntomb[Cik] := KeyName(CtrlHelpScans[Cik],
                                        CtrlHelpKeys[Cik],CtrlKey);
        AltMode : Ntomb[Cik] := KeyName(AltHelpKeys[Cik],
                                        0,AltKey);
        Ctrl_Altmode  : Ntomb[Cik] := KeyName(CtrlAltHelpKeys[Cik],
                                              0,CtrlKey+AltKey);
        Ctrl_ShiftMode: Ntomb[Cik] := 'Shift-'+
                                       KeyName(CtrlShiftHelpScans[Cik],
				       CtrlShiftHelpKeys[Cik],CtrlKey);
        Blokk_Mode: Begin
                      If Cik <= 12 Then
                      Begin
                        AsciiCode := 0;
                        ScanCode  := AltHelpKeys[Cik+12];
                      End
                      Else
                      Begin
                        If Cik <= 27 Then
                        Begin
                          AsciiCode := 0;
                          If Cik <= 22 Then ScanCode := F1+(Cik-13)
                                       Else ScanCode := Shift_F1+(Cik-23);
                        End
                        Else
                        Begin
                          AsciiCode := Byte(CalcOpKey[Cik-27]);
                          ScanCode  := 222;
                        End;
                      End;
                      BlokkHelpScans[Cik] := ScanCode;
                      BlokkHelpKeys[Cik]  := AsciiCode;

                      Ntomb[Cik] := KeyName(ScanCode,AsciiCode,0);
                    End;

      End; {Case}
    End;

    { If Mode = CtrlMode Then Ntomb[19] := 'CTRX-PGUP '; }

    If (Mode = CtrlMode) OR (Mode = AltMode) Then
    Begin
      Inc(MaxHelpItem);
      If Mode = CtrlMode Then Ss := 'Ctrl-' Else Ss := 'Alt-';
      Ntomb[MaxhelpItem] := Ss + 'Space';
    End;

    Set_Choose(7,0,72,17,30,0);

    ChooseMode := Mode;

    SystemWriting := False;

    PuffiRekurzio := True;
    Choose(Ntomb,Atomb,MaxHelpItem,0,Buff,Buff,Buff);
    PuffiRekurzio := False;

    ChooseMode := None;

    If Not ESC
    Then
    Begin
      Cik := 0;
      Repeat
        Inc(Cik);
      Until Atomb[Cik] = 1;
      Boo := True;
    End;

    Move(Buff,Wkx1,12);  { Wkx1,Wky1,Wkx2,Wky2,Slength,Enged}

    If Not Esc Then
    Begin

      If Boo Then
      Begin

	HelpJelzes := True;

        Case Mode Of
          Blokk_Mode   : Begin
                           HX := BlokkHelpKeys[Cik];
                           HY := BlokkHelpScans[Cik];
                           If Cik <= 12 Then Kbfh:= AltKey
                             Else Kbfh := 0;
                           KulsoHelpJelzes := True;
                         End;
          CtrlMode     : If Cik < MaxHelpItem Then
                         Begin
                           HX := CtrlHelpKeys[Cik];
                           HY := CtrlHelpScans[Cik];
                           Kbfh:= CtrlKey;
                         End
                         Else
                         Begin
                           HX := $20;   { Ctrl-Space}
                           HY := $39;
                           Kbfh:= CtrlKey;
                         End;
          AltMode      : If Cik < MaxHelpItem Then
                         Begin
                           HX := 0;
                           HY := AltHelpKeys[Cik];
                           Kbfh:= AltKey;
                         End
                         Else
                         Begin
                           HX := $20;   { Alt-Space}
                           HY := $39;
                           Kbfh:= AltKey;
                         End;
          Ctrl_AltMode : Begin
                           HX := 0;
                           HY := CtrlAltHelpKeys[Cik];
                           Kbfh:= CtrlKey+AltKey;
                         End;
          Ctrl_ShiftMode:Begin
                           HX := CtrlShiftHelpKeys[Cik];
                           HY := CtrlShiftHelpScans[Cik];
                           Kbfh:= CtrlKey+1;
                         End;
        End;
      End
      Else HelpJelzes := False;

    End {If Not Esc}
    Else
    Begin
      HelpJelzes := False;
      Van_Bill := False;
    End;

    ESC := False;

    MouseCursor(False);

    FelSor_IdeOdaW(5,70,38,2,Ofs(ScBuf),Seg(ScBuf),SortabOffs,1);
    RestoreXY;

    MouseCursor(True);

    OutJel := TOUT;

    InKeyHelp := False;

  End; { Ha nincs billentyÅzet-helpben }

  GraphicMenu := False;


End;

{$IFDEF LEUTES}

Procedure Leutes(EdNum:Integer);
Var Cikl    : Integer;
    Cikl2   : Byte;
    Leutott : Longint;
    Sor     : Lpoint;
Begin

  BOOL := CREATE_WINDOW(12,8,68,12,'LeÅtÇsek sz†ma',CA[DispMode,1],CA[DispMode,3]);

  GotoXY(4,2);
  Write('LeÅtÇsek sz†ma a');
  If EdNum = 1 Then Write('z');
  Write(' ',EdNum,'. szerkesztîben : ');

  Leutott  := 0;
  For Cikl := StartLine[EdNum] To EndLine[EdNum] Do
    Begin
      Heap_Pos(Sor,PointerTomb^[Cikl]);
      For Cikl2 := 0 To C77 Do
         If (Sor^.Chars[C80+Cikl2] <> #00) AND ((Sor^.Attribs[Cikl2] AND 15) > 0)
           Then Inc(Leutott);
      FreeEms1(PointerTomb^[Cikl]);
    End;

   Write(Leutott);

   If ReadKey = ' ' Then;

   Bool := Remove_Window;

End;

{$ENDIF}

{$IFDEF LICENC}
Procedure SetEmblemaHely;
Var SC,Asc : Byte;
     omode : Byte;
     exp   : Byte;
Const HelyName : Array[0..4] Of String[20]=
    ('Nincs     ',
     'Bal felsî ',
     'Jobb felsî',
     'Bal als¢  ',
     'Jobb als¢ ');

Begin
  omode := EmblemaMod;
  BOOL := CREATE_WINDOW(12,8,68,10,'EmblÇma helye',CA[DispMode,1],CA[DispMode,3]);
  GotoXy(1,1);
  Write('    EmblÇma elhelyezÇs :');
  Exp := WhereX+1;
  gotoxy(Exp,1);
  Write(HelyName[EmblemaMod]);
  Repeat
    PuffiRekurzio := True;
    Puffi(Asc,Sc);
    PuffiRekurzio := False;
    Case Sc Of
      JobbraNyil : Inc(EmblemaMod);
      BalraNyil  : Dec(EmblemaMod);
      End;

    If EmblemaMod = 5 Then
      EmblemaMod := 0;
    If EmblemaMod = 255 Then
      EmblemaMod := 4;

    If Asc = Escape Then
      EmblemaMod := Omode;

    gotoxy(Exp,1);
    Write(HelyName[EmblemaMod]);
  Until ASc In [Enter,Escape];
  Bool := Remove_Window;
End;
{$ENDIF}
{$ENDIF CDVIEW}

End.