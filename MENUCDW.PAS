Unit MenuCdw;
{$O+}

InterFace
  Procedure Init_Menu;
  Procedure Menu;

(*****************  Menu procedures  ***************)

VAR
     Sel_It : Array[0..15] Of Integer;
     Level         : Integer;

Implementation

Uses
  crt,
  Video,     { CGA5.OBJ + DISPLAY.OBJ Assembly rutinok }
  WindowM,
  MenuErr,
{$IFDEF HALO}
{  Halozat,}
{$ENDIF}
  BGI,
  DOS,
  {$IFDEF PROBA}
  Printer,
  {$ENDIF}
  HeapCdw,
  InputCdw,InputOVR,
  FileCdw,

  {$IFNDEF CDVIEW}
  StartNyo,
  SetCdw,
  {$ENDIF}

  CalcCdw,
  EMSCdw,

  StartCdw,
  InitCdw,
  {$IFNDEF VER3} Publicat, {$ENDIF}
  {$IFDEF DECNET}
  DECNET,
  {$ENDIF}
  SpeakCdw,
  Editor;


{$I LEGELEJE.CDW}


PROCEDURE Init_Menu;

VAR cikl,cikl2,St,Sum,Marad,Leftmarad,KozMarad : integer;
    vissz : string[40];

BEGIN
  MenuRec[1].Start := 1;
  For Cikl := 2 To MenuNum do
    Menurec[cikl].Start := Menurec[cikl-1].Start+Menurec[cikl-1].MemNum;

  For Cikl := 1 To MenuNum do
    With menurec[cikl] do
    BEGIN
      If typ = hor then
        BEGIN
          Sum := 0;
          for cikl2 := 1 to MemNum do
            BEGIN
              MenuStr(cikl2+start-1,vissz,False);
              SC := StartCh(Vissz);
              Inc(Sum,byte(vissz[0]));
            End;
          Marad := (Xp2-Xp+1)-2-Sum;
          KozMarad := Marad div (MemNum +1);
          Sum:= (Marad-MemNum*KozMarad) Div 2;
          for cikl2 := 1 to MemNum do
            BEGIN
              Inc(Sum,KozMarad);
              ShowLine[Cikl2+Start-1] := Sum;
              If NewMenu[Cikl2+Start-1] <> 0 Then
                BEGIN
                  MenuRec[NewMenu[Cikl2+Start-1]].Xp2 :=
                    MenuRec[NewMenu[Cikl2+Start-1]].Xp2-
                    MenuRec[NewMenu[Cikl2+Start-1]].Xp + Sum - 2;
                  MenuRec[NewMenu[Cikl2+Start-1]].Xp := Sum - 2;
                End;
              MenuStr(cikl2+start-1,vissz,False);
              SC := StartCh(Vissz);
              Inc(Sum,byte(vissz[0]));
            End
        End
    End; { With }
End;


PROCEDURE Menu;

Type OpTip = (Yes,No);

VAR
    Cikl,
    New_Select,
    Item_pos,
    Act_Menu    : integer;
    a,b         : Byte;
    Majd_Kesobb : Boolean;
    Sname,
    FirstSt     : String[80];
    AC          : Char;
    vissz       : string[40];

PROCEDURE Editor(Param : Integer);
VAR Ws : St40;
    EdNum : Integer;
    Cikl  : Integer;
    Kment : ScTip;

    CRT   : Byte Absolute $0040:$0049;
    SC    : Byte;

BEGIN

  (*  If VanIntA1 And (Lo(Param) In [1..3]) Then InLine($CD/$A1);  *)

  EdNum       := Param;
  ExitCode    := 00;

  Kment := ScrMemT[GrMode]^;

  Kivevo[4,4] := Kment[19,69,1] XOR $B8;

  SetGraphMod(Gr);      { FI }

  CrtMode := 6;


  { If GrMode = HerMode Then CRT := CrtMode; }

  ElsoBelep := True;

  If GIBEnabled Then GIBHotKeys(False);

  GetTime(Ora,Perc,Mp,Szdmp);
  LastIdo := 60 * Ora + Perc;
  Kivevo[1,1] := Kment[19,66,1] XOR $AB;

  Repeat
    NemVoltHelp := True;
    EditNum := EdNum;
    Case EditNum Of
        1..3 : BEGIN
                 EditorCim := Filename[Editnum];
                 While Pos('\',EditorCim)+Pos(':',EditorCim) > 0 Do
                   Delete(Editorcim,1,1);
                 EditorCim := Csak12(EditorCim);
               End;
    BufferNum: EditorCim := Menu_Duma(2,2); { BUFFER }

(*     4..27 : EditorCim := '';  {Menu_duma(12,Sel_it[3]);}
       7..15 : EditorCim := Copy(Menu_duma(12,Sel_It[3]),1,3); { HEADER }
      16..18 : EditorCim := Menu_Duma(12,Sel_it[3]);
      19..27 : EditorCim := Copy(Menu_duma(12,Sel_It[3]),1,3); { FOOTER }
*)
    End;

    Kivevo[2,2] := Kment[19,67,1] XOR $15;
    UpperCase(EditorCim);

    If EditNum In [4..27] Then
    Begin

      Ws := '';

      MenuStr((Menurec[12].Start+EditNum-4),Ws,False);
      SC := StartCh(WS);
      {$IFDEF OROSZ}
      If EditNum In [4..15] Then Ws := 'ò.'+ Ws
                            Else Ws := 'ë.'+ Ws;
      {$ELSE}
      If EditNum In [4..15] Then Ws := 'F.'+ Ws
                            Else Ws := 'L.'+ Ws;
      {$ENDIF}
      UpperCase(Ws);
      EditorCim := Ws;
    End;

    Kivevo[3,3] := Kment[19,68,1] XOR $09;
    ConvertString(EditorCim);

    Set_Lehet;

    { ASM INT 3 END; }

    SetMouse(TRUE);

    Edit;

    Case ExitCode Of
      {$IFNDEF CDVIEW}
      Alt_H : BEGIN
                NemVoltHelp := False;
                Editnum := 29;
                EditorCim := 'HELP     ';
                Set_Nem_Lehet;
                Edit;
                If ExitCode In [Ctrl_F1 .. Ctrl_F3] Then
                  BEGIN
                    GeditNum := ExitCode - Ctrl_F1 + 1;
                    EdNum  := GEditNum;
                    Fresh_Strings;
                  End;
              End;
      {$ENDIF}
      Ctrl_F1 .. Ctrl_F4 :
              BEGIN
                EdNum := ExitCode - Ctrl_F1 + 1;
                If EdNum In [1..3] Then
                  BEGIN
                    GeditNum := EdNum;
                    {$IFNDEF CDVIEW}
                    Fresh_Strings
                    {$ENDIF}
                  End
                  Else EdNum := BufferNum;
              End

    End;

  Until (Exitcode In [1{Escape Scan code},Alt_Q]) AND NemVoltHelp;

  If GIBEnabled Then GIBHotKeys(True);

  Set_Nem_lehet;

  If VanNyelvesz And NyelveszBent Then
    Begin
      ChangeToWin;
      If SwapError Then
        Error(26,' :'+SerrorSt);
    End;
  {$IFNDEF CGAONLY}
    TextMode(Co80);
    {RestoreCrtMode;}
  {$ELSE}
    Register.Ax := $0003;
    Intr($10,Register);
  {$ENDIF}
  CrtMode := 3;

  If GrMode = HerMode Then CRT := 7;

  ScrMemT[GrMode]^ := Kment;
  Fresh_Def;


  {$IFNDEF CDVIEW}
  Fresh_Info;
  {$ENDIF}


  CurOff;

  SetMouse(True);

  {$IFNDEF CDVIEW}
  {$IFNDEF Demo}

  If (ExitCode = Alt_Q) And (Ednum In [1..3,BufferNum]) Then
    Save(Filename[EdNum],AutoSaveMode,Document);

  {$ENDIF}
  {$ENDIF}


End;

Const SetLapdobVolt : Boolean = False;
Var   LevelPas      : Byte;

{$IFNDEF INFOHIV}
{$IFNDEF WORKDIR}

Procedure DOS_Shell;
Const Command     : String[12] = 'COMMAND.COM';
Var CommandSpec   : Array[1..5] Of String[76];
    ScBuf         : ScTip;
    Ox,Oy         : Integer;
    Wmin,Wmax     : Word;
    ActualDir     : String[80];
    Cik,X         : Byte;

(*
procedure WriteHexWord(w: Word; y,x: Byte);
const
  hexChars: array [0..$F] of Char =
    '0123456789ABCDEF';
begin
  Display(hexChars[Hi(w) shr 4]+
          hexChars[Hi(w) and $F]+
          hexChars[Lo(w) shr 4]+
          hexChars[Lo(w) and $F],y,x);
end;

Label NewInt28,Jump,Nem,Ok,SsReg,Oldseg,Tovabbi,OldSs,InDosFlag,
      K1,K2,K3,K4,K5,K6,K7,K8,LevelCount,NemLevel,NewInt20,NewInt21,
      Jump20,Jump21,Ok21,Dosbol;
*)

Procedure SetPath(BPath:String; Num:Byte);
Begin
  If (BPath <> '') AND (BPath[Length(BPath)] <> '\') Then BPath := BPath + '\';
  CommandSpec[Num] := BPath + Command;
End;

Begin { Dos_Shell }

  (*
  X := 0;
  Inc(X);

  If X = 0 Then
  Begin

    Asm
      NewInt28:

      Pushf
      Push Ax
      Push Bx
      Push Cx
      Push Dx
      Push Si
      Push Di
      Push Bp
      Push Ds
      Push Es

      Cld

      Push Cs
      Pop  Ds
      Push Cs
      Pop  Es

      Mov  Si,Offset OldSeg
      Lodsw
      Cmp  Ax,0001
      Jnz  Tovabbi

      Mov  Bp,Sp
      Mov  Ax,[Bp+22]

      Mov  Di,Offset OldSeg
      Stosw

      Mov  Di,Offset LevelCount
      Xor  Al,Al
      Stosb

      Jmp  Ok

      Tovabbi:

      Mov  Bx,Ax
      Mov  Bp,Sp
      Mov  Ax,[Bp+22]

      Cmp  Ax,Bx
      Jz   Nem

      Jmp  Ok

      {
      Push Cs
      Pop  Ds
      Mov  Si,Offset InDosFlag

      LDs  Si,[Si]
      Lodsw

      Cmp  Al,0
      Jnz  Nem
      Jmp  Ok
      }

      Nem:

      Push Cs
      Pop  Ds
      Mov  Si,Offset LevelCount
      Lodsb

      Cmp  Al,0
      Jz   NemLevel
      Jmp  Ok

      NemLevel:

      Push Cs
      Pop  Ds

      Push Cs
      Pop  Es

      Mov  Di,Offset OldSS
      Mov  Ax,Ss
      Stosw
      Mov  Ax,Sp
      StoSw

      Mov  Si,Offset SsReg
      Lodsw

      Cli
      Mov  Ss,Ax
      Lodsw
      Mov  Sp,Ax
      Sti

      Push Cs
      Pop  Ds
      Mov  Si,Offset LevelCount
      Lodsb
      Mov  Bl,Al

      Mov  Ax,Seg @Data
      Mov  Ds,Ax

      Mov  LevelPas,Bl

    End;

      Attribute(1,1,1,80,CA[DispMode,5]);
      Display(Space12+Space12+ExitStr+Space12+'        ',1,1);
      DispCh(Char(LevelPas+48),1,1);

    Asm

      Push Cs
      Pop  Ds

      Mov  Si,Offset OldSS
      Lodsw

      Cli
      Mov  Ss,Ax
      Lodsw
      Mov  Sp,Ax
      Sti

      Ok:
      Pop Es
      Pop Ds
      Pop Bp
      Pop Di
      Pop Si
      Pop Dx
      Pop Cx
      Pop Bx
      Pop Ax
      Popf

      DB $EA  { Jmp 0000:0000 }

      Jump:
      DB 00
      DB 00
      DB 00
      DB 00

      SsReg: { A Pascal eredeti SS-SP regisztere }

      DW 0000
      DW 0000

      OldSs: { Az eredeti SS-SP regiszter }

      DW 0000
      DW 0000

      OldSeg:

      DW 0000

      InDosFlag:

      DW 0000
      DW 0000

      LevelCount:

      DB 00

      NewInt20:

      Push Es
      Push Ds
      Push Si
      Push Di
      Push Ax

      Push Cs
      Pop  Ds
      Push Cs
      Pop  Es
      Mov  Si,Offset LevelCount
      Mov  Di,Si
      Lodsb
      Dec  Al
      StoSb

      Pop  Ax
      Pop  Di
      Pop  Si
      Pop  Ds
      Pop  Es

      DB $EA  { Jmp 0000:0000 }

      Jump20:
      DB 00
      DB 00
      DB 00
      DB 00

      NewInt21:

      Cmp  Ah,$4B
      Jnz  Ok21

      Push Es
      Push Ds
      Push Si
      Push Di
      Push Ax

      Push Cs
      Pop  Ds
      Push Cs
      Pop  Es
      Mov  Si,Offset LevelCount
      Mov  Di,Si
      Lodsb
      Inc  Al
      StoSb

      Pop  Ax
      Pop  Di
      Pop  Si
      Pop  Ds
      Pop  Es

      Ok21:
      DB $EA  { Jmp 0000:0000 }

      Jump21:
      DB 00
      DB 00
      DB 00
      DB 00

    End;
  End;

  *)

  WMin := WindMin;
  WMax := WindMax;

  Ox := WhereX;
  Oy := WhereY;

  ScBuf := ScrMemT[GrMode]^;

  CREATE_WINDOW(55,5,79,9,pr_mess21,CA[DispMode,1],CA[DispMode,2]);
  GotoXY(4,2);
  Write(EleSt5);

  OptimalHeap;

  Remove_Window;

  Register.Ah := $4A;   { Modify Block Size }
  Register.Bx := Seg(StartPoint^) - PrefixSeg + $40;
  Register.Es := PrefixSeg;
  Intr($21,Register);

  Register.Ah := $48;   { Get Max Block Size }
  Register.Bx := $FFFF;
  Intr($21,Register);

  If Register.Bx < PointSize Then
  Begin

    Window(1,1,80,25);
    TextAttr := 15;
    ClrScr;
    Writeln(ExitStr,#13#10);
    CurOn;

    Speak(135);

    GetDir(0,ActualDir);

    CommandSpec[1] := GetEnv('COMSPEC');

    SetPath('C:\',2);
    SetPath(Path,3);
    SetPath(FontPath,4);
    SetPath(AlapPath,5);

    Cik := 1;

    If VanEMSm Then Save_EMS(EMS_Handle);
    If StandardHandle <> 54321 Then
      Save_EMS(StandardHandle);

    If VanDSKM Then
    Begin
      {$I-}
      Close(DskFil);
      {$I+}
      SetFAttr(DskFil,ReadOnly+Archive+Sysfile+Hidden)
    End;

    (*
    Asm

      Push Ds
      Push Es
      Push Ax
      Push Cx
      Push Di
      Push Si

      Cld

      Xor  Ax,Ax
      Mov  Ds,Ax
      Push Cs
      Pop  Es
      Mov  Si,4*$28
      Mov  Di,Offset Jump
      Mov  Cx,2
      Repz Movsw

      Mov  Di,Offset LevelCount
      Xor  Al,Al
      Stosb

      Mov  Si,4*$20
      Mov  Di,Offset Jump20
      Mov  Cx,2
      Repz Movsw

      Mov  Si,4*$21
      Mov  Di,Offset Jump21
      Mov  Cx,2
      Repz Movsw

      Mov  Di,Offset OldSeg
      Mov  Ax,0001
      Stosw

      Mov  Di,Offset SsReg
      Mov  Ax,Ss
      Stosw
      Mov  Ax,Sp
      Sub  Ax,1024
      Stosw

      Mov  Ah,$34
      Int  $21
      Mov  Ax,Es

      Push Cs
      Pop  Es
      Mov  Di,Offset IndosFlag
      Xchg Ax,Bx
      Stosw
      Xchg Ax,Bx
      StoSw

      Push Ds
      Pop  Es

      Mov  Di,4*$28

      Cli
      Mov  Ax,Offset NewInt28  { Az eredeti INT 28 †tir†ny°t†sa }
      Stosw
      Mov  Ax,Cs
      StoSw
      Sti

      Mov  Di,4*$20

      Cli
      Mov  Ax,Offset NewInt20  { Az eredeti INT 20 †tir†ny°t†sa }
      Stosw
      Mov  Ax,Cs
      StoSw
      Sti

      Mov  Di,4*$21

      Cli
      Mov  Ax,Offset NewInt21  { Az eredeti INT 21 †tir†ny°t†sa }
      Stosw
      Mov  Ax,Cs
      StoSw
      Sti

      Pop  Si
      Pop  Di
      Pop  Cx
      Pop  Ax
      Pop  Es
      Pop  Ds
    End;

    *)

    SetMouse(False);

    Repeat
      SwapVectors;
      Exec(CommandSpec[Cik],'');
      SwapVectors;
      Inc(Cik);
    Until (DosError = 0) OR (Cik > 5);

    Asm
      Mov  Ax,0003
      Int  $10
    End;

    SetMouse(True);

    (*
    Asm

      Push Ds
      Push Es
      Push Ax
      Push Cx
      Push Di
      Push Si

      Mov  Ax,0003
      Int  $10

      Cld

      Xor  Ax,Ax
      Mov  Es,Ax
      Push Cs
      Pop  Ds


      Mov  Di,4*$28
      Mov  Si,Offset Jump
      Mov  Cx,2

      Cli
      Repz Movsw
      Sti

      Mov  Di,4*$20
      Mov  Si,Offset Jump20
      Mov  Cx,2

      Cli
      Repz Movsw
      Sti

      Mov  Di,4*$21
      Mov  Si,Offset Jump21
      Mov  Cx,2

      Cli
      Repz Movsw
      Sti

      Pop  Si
      Pop  Di
      Pop  Cx
      Pop  Ax
      Pop  Es
      Pop  Ds
    End;

    *)

    If VanDSKM Then
      Begin
        SetFAttr(DskFil,Archive);
        {$I-}
        Reset(DskFil,C160);
        {$I+}
      End;

    If StandardHandle <> 54321 Then
      Restore_EMS(StandardHandle);

    If VanEMSm Then Restore_EMS(EMS_Handle);

    {
    Register.AX := 0;
    Intr($33,Register);
    }

    (****** EMS ******)

    If DosError <> 0 Then
    Begin
      If DosError = 8 Then Error(4,'')
                      Else Error(3,Command);
    End;

    ChDir(ActualDir);
    OptimalHeapRestore;
  End
  Else Error(4,'');

  Register.Ah := $4A;
  Register.Bx := $FFFF - PrefixSeg + $20;
  Register.Es := PrefixSeg;
  Intr($21,Register);

  ScrMemT[GrMode]^ := ScBuf;
  Window(Lo(WMin)+1, Hi(WMin)+1, Lo(WMax)+1, Hi(WMax)+1);
  GotoXY(Ox,Oy);
  CurOff;

End;

{$ENDIF NOT INFOHIV}
{$ENDIF NOT WORKDIR}

Procedure EditInfo;
Var Cik : Byte;
    Ws  : String[80];
    EdSt: String[4];
    Xp  : Byte;
    A,B : Byte;

Const
      Yp: Array [1..28] Of Byte =

(04,05,06,   12,13,14,15,16,17,18,19,20,21,22,23,
             12,13,14,15,16,17,18,19,20,21,22,23,
       07);

Function Leutes(EdNum: Byte): LongInt;
Var Leutott    : LongInt;
    Cikl,Cikl2 : Integer;
    Sor        : LPoint;
Begin
  Leutott  := 0;
  For Cikl := StartLine[EdNum] To EndLine[EdNum] Do
    Begin
      Heap_Pos(Sor,PointerTomb^[Cikl]);
      For Cikl2 := 0 To C77 Do
         If (Sor^.Chars[C80+Cikl2] <> #00) AND ((Sor^.Attribs[Cikl2] AND 15) > 0)
           Then Inc(Leutott);
      FreeEms1(PointerTomb^[Cikl]);
    End;

   Leutes := Leutott;
End;

Const VizSz = False;
      Fuggo = True;

Procedure Csik(X,Y: Integer; Len: Byte; Dir: Boolean);
Var Ox,Oy : Integer;
    Cs    : String;
    Cik   : Byte;
Begin
  Ox := WhereX;
  Oy := WhereY;

  If Dir = VizSz Then
  Begin
    FillChar(Cs[1],Len,'ƒ');
    Cs[0] := Char(Len);
    GotoXY(X,Y);
    Write(Cs);
  End
  Else
  Begin
    Cs := '≥';
    For Cik := Y To Y + Len - 1 Do
    Begin
      GotoXY(X,Cik);
      Write(Cs);
    End;
  End;

  GotoXY(Ox,Oy);
End;

Begin

  FreeHot := False;

  BOOL := CREATE_WINDOW(1,1,80,25,IniSt2,CA[DispMode,1],CA[DispMode,2]);

  {$IFDEF HALO}
  GotoXY(40-(Length(UserName)+6) DIV 2,1);
  Write('User: ',UserName);
  {$ENDIF}

  {$IFDEF NORVEG}
  Ws := '   ' + LineSt + '  ' + EleSt0;
  {$ELSE}
  Ws := '   ' + LineSt + '  ' + EleSt1;
  {$ENDIF}

  GotoXY(14,2);
  Write(Ws);

  GotoXY(48,4); Write(MemSt1,Max_Lines:5);
  GotoXY(48,5); Write(MemSt6,MemLines:5);
  GotoXY(48,6); Write(MemSt4,EMSLines:5);
  GotoXY(48,7); Write(MemSt5,XMSLines:5);
  GotoXY(48,8); Write(MemSt7,DSKLines:5);

  TextAttr := CA[DispMode,3];
  GotoXY(48,2); Write(MemSt2,FreeLines:5);
  GotoXY(48,3); Write(MemSt3,Full_Lines:5);

  Csik(39,02,21,Fuggo);
  Csik(02,03,35,VizSz);
  Csik(02,09,76,VizSz);
  Csik(02,11,76,VizSz);

  TextAttr := CA[DispMode,2];

  For Cik := 0 To 1 Do
  Begin
    GotoXY(40*Cik+1,10);
    Write(PrTomb[8+Cik].Txt:13,Ws);
  End;

  For Cik := 1 To 28 Do
  Begin

    Xp := 1;

    Case Cik Of
        1..3: Begin
                Str(Cik,EdSt);
                MenuStr((Menurec[2].Start),Ws,False);
                SC := StartCh(WS);
                Ws := EdSt + '.' + Ws;
              End;
       4..15: Begin
                MenuStr((Menurec[11].Start+Cik-4),Ws,False);
                SC := StartCh(WS);
              End;
      16..27: Begin
                Xp := 41;
                MenuStr((Menurec[12].Start+Cik-16),Ws,False);
                SC := StartCh(WS);
              End;
          28: Begin
                MenuStr((Menurec[2].Start+1),Ws,False);
                SC := StartCh(WS);
              End

    End;

    Ws := Ws + ': ';

    GotoXY(Xp,Yp[Cik]);
    Write(Ws:15,(EndLine[Cik]-StartLine[Cik]+1):5,Leutes(Cik):9);
  End;

  Display(' '+IneSt1+' ',25,33);

  Repeat
    Puffirekurzio := True;
    Puffi(A,B);
    Puffirekurzio := False;
  Until ((A = Escape) OR (ClickOnCloseBox));

{  Repeat Until ReadKey = Char(Escape); }
  BOOL := Remove_Window;

  FreeHot := True;
End;

Function EzMarOtos:Boolean;
Begin
  {$IFDEF VER4}
  Error(20,'Ez a funkci¢ csak a 5.00 verzi¢t¢l †ll rendelkezÇsre');
  EzMarOtos := False;
  {$ELSE}
  EzMarOtos := True;
  {$ENDIF}
End;


PROCEDURE Runing_Routines;
VAR cikl : byte;
    UresHeadFoot : boolean;
BEGIN
  {$IFNDEF CDVIEW}
  PubStr:='';
  New_Select := 255;  {  NEM kilepes  }
  Case Sel_It[1] Of
    1: Case Sel_It[2] Of
                            
         1: Editor(GEditNum); { Fo editorok 1 .. 3 }

         2: Editor(BufferNum);        { Buffer }

         3: Editor(Sel_It[3]+3);  {4..15}

         4: Editor(Sel_It[3]+15); {16..27}

         5: EditInfo;

         {$IFDEF CHEM}
         6: BEGIN
              BOOL := CREATE_WINDOW(8,5,28,9,Pr_Mess3,CA[DispMode,1],CA[DispMode,2]);
              GotoXy(2,2);
              Write(Pr_Mess7);
              Ment_0;
              BOOL := Remove_Window;
            End;
         {$ENDIF}

       End;

    2: Case Sel_It[2] Of

         1: ClearBuffer(GEditNum);

         2: ClearBuffer(BufferNum);  { Buffer }

         3: BEGIN
              ClearBuffer(Sel_It[3]+3);  {4..15}
              UresHeadFoot := True;
              For cikl:=4 to 17 do
                UresHeadFoot := UresHeadFoot and (StartLine[cikl]>EndLine[cikl]);
              If UresHeadFoot then HeadFootName := '';
            End;

         4: BEGIN
              ClearBuffer(Sel_It[3]+15); {16..27}
              UresHeadFoot := True;
              For cikl:=4 to 17 do
                UresHeadFoot := UresHeadFoot and (StartLine[cikl]>EndLine[cikl]);
              If UresHeadFoot then HeadFootName := '';
            End;

       End;

    3: Case Sel_It[2] Of

         1: BEGIN
              Editnum := GEditNum;
	      MostKellInf := True;
	      {$IFDEF DECNET}
	      CheckInterrupt;
	      {$ENDIF}
              KellJelszo := True;
              Load(Filename[Editnum],Document,OneFileMode);
              KellJelszo := False;
              MostKellInf := False;
            End;
         2:BEGIN
             Editnum := BufferNum;
             MostKellInf   := True;
             KellJelszo := True;
             Load(Filename[4],Document,OneFileMode);
             MostKellInf   := False;
             KellJelszo := False;
           End;

         {$IFNDEF WORKDIR}
         3: Load_Parameters;
         {$ENDIF}

         4: BEGIN
              Editnum := GEditNum;
              WordStarMode(False);
              Load(Filename[Editnum],ASCII,OneFileMode);
              WordStarMode(True);
            End;

         5: BEGIN
              Editnum := GEditNum;
              Load(Filename[Editnum],ASCII,OneFileMode);
            End;

         6: Load(HeadFootName,Document,AllHeaderMode); {Load Headers & Footers}

         7: Load_Macros(False);

       End;

      {$IFNDEF Demo}

    4: {$IFDEF BEMUTAT}
       If ErvenyesIdoszak Then
       {$ENDIF}
       Case Sel_It[2] Of
         1: BEGIN
              Editnum := GEditNum;
              KellJelszo := True;
              Save(Filename[Editnum],Normalmode,Document);
              KellJelszo := False;
             End;
         2: BEGIN
              Editnum := BufferNum;
              KellJelszo := True;
              Save(Filename[4],Normalmode,Document);
              KellJelszo := False;
            End;

         3: Save_Configuration;

         4: Save_Parameters;

         5: BEGIN
              Editnum := GEditNum;
              Save(Filename[Editnum],Normalmode,ASCII);
            End;

         6: BEGIN
              Editnum := GEditNum;
              Save(Filename[Editnum],Normalmode,Ventura);
            End;

         7: Save(HeadFootName,AllSaveMode,Document);

         8: Save_Macros;

       End;

      {$ENDIF}

    {$IFNDEF VER3}
    5: Case Sel_It[2] of

         1: New_Publicat;
         2: Edit_Publicat(False);
         3: Subs_Publicat;
         4: Add_Publicat;
         5: Move_Doc_In_Publicat;
         6: Pub_nev:='';
         7: Case Sel_It[3] of
              1:  Set_PublPrint;
              2:  Set_PageNumbering;
            End;
       End;
    {$ENDIF}
    {$IFNDEF VER3}
    6:
    {$ELSE}
    5:
    {$ENDIF}
      Case Sel_It[2] Of

         1: Change_Dir(1);

         2: Change_One_Font;

         3: Case Sel_It[3] Of

             1:  Set_pagelen;
             2:  Set_Spacing;
             3:  Set_Auto_Backup;
             4:  Set_Max_Key;

             5:  Begin
                   {ASM INT 3 END;}
                   DateSort := NOT DateSort;
                   Fresh_Strings;
                 End;

           6,7:  Load_nyomtatok(Boolean(Sel_It[3]-6));

             8:  If Ezmarotos Then
                 Begin
                   Case Sel_It[4] Of
                     1: Begin
                          Tizedesek := (Tizedesek+1) AND 7;
                          Fresh_Strings;
                        End;
                     2: Begin
                          Format := (Format+1) AND 3;
                          Fresh_Strings;
                        End;

                     3: Begin
                          Gyujtes := NOT Gyujtes;
                          Fresh_Strings;
                        End;

                     4: Set_Szammal;
                     5: Set_Betuvel;
                   End; { Case }

                   CreateCalcResult(CalcRes);

                 End;

             
           End;

         4: Change_Dir(2);

         5: Change_Dmask;

         6: BEGIN
              GEditNum := ((GEditNum + 1) And 3) Or (GeditNum+1) SHR 2 ;
              Fresh_Info;
              Fresh_Strings;
            End;

         7: BEGIN
              WsMode := Not WsMode;
              BOOL := CREATE_WINDOW(32,5,72,9,Mst1,CA[DispMode,1],CA[DispMode,2]);
              GotoXy(8,2);
              Read_Helpfile(Byte(WsMode));
              BOOL := Remove_Window;
              Fresh_Strings;
            End;
         8: BEGIN
              NewDisp := DispType(Not(Boolean(NewDisp)));
              Fresh_Strings;
            End;


         9: If Ezmarotos Then SetKonfig(Sel_It[3]);

        10: If EzMarOtos Then SetKonvert(Sel_It[3]);

       End;

    {$IFNDEF VER3}
    7:
    {$ELSE}
    6:
    {$ENDIF}
    Case Sel_It[2] Of
     {$IFNDEF VER3}
     1..4 : If Pub_nev<>'' then Print_pub(Sel_It[2]-1)
            else StartPrint(Sel_It[2]-1);
     {$ELSE}


     {$IFNDEF NONYOM}

     1..4 : If EndLine[GEditNum] >= StartLine[GEditNum] Then
              StartPrint(Sel_It[2]-1);

     {$ENDIF NONYOM}

     {$ENDIF}
         5: Case Sel_It[3] Of
             1:  Set_FirstPage;
             2:  Set_LastPage;
             3:  Set_FirstPageNum;
             4:  Set_StopAfterPage;
             5:  Set_Print_Margin;
             6:  Set_NyomSzam;
             7:  Begin
                   Set_KellLapdobas;
                   SetLapdobVolt := True;
                 End;
             8:  If NOT KellLapdob Then Set_LabelDistance Else Beepel(440);

             9:  Set_Serial;
            10:  Set_paralell;
            11:  Set_checking;

            12:  Begin
                   Formatum := NOT Formatum;
                   Fresh_Strings;
                 End;

            13:  Begin
                   Condensed := NOT Condensed;
                   Fresh_Strings;
                 End;

            14:  Begin
                   MindigLetolt := NOT MindigLetolt;
                   Fresh_Strings;
                 End;

           End;

         
         6: {$IFNDEF VER352}
            If EndLine[GEditNum] >= StartLine[GEditNum] Then
              StartPrint(4);
            {$ELSE}
            Error(20,'Ez a funkci¢ csak a 4.11 verzi¢t¢l †ll rendelkezÇsre');
            {$ENDIF}

         7: If Enabled[4] Then Case Sel_It[3] Of

             1: If Enabled[4] Then Use_Cimlista(False);

             2: If (CimFile <> '') AND Enabled[4] Then View_Vars
                                                  Else Beepel(440);
             3: If (CimFile <> '') AND Enabled[4] Then Input_Conditions(True)
                                                  Else Beepel(440);
             4: If (CimFile <> '') AND Enabled[4] Then Load_Condition(False)
                                                  Else Beepel(440);
             5: If Enabled[4] Then Save_Condition;

           End;
       End;

    {$IFNDEF NOFILE}
    {$IFNDEF VER3}
    8:
    {$ELSE}
    7:
    {$ENDIF}
     Case Sel_It[2] Of
         1: Direct;
         2: Del_File;
         3: Rename_File;
         4: Copy_File;

         {$IFNDEF INFOHIV}
         {$IFNDEF WORKDIR}
         5: Dos_Shell;
         {$ENDIF}
         {$ENDIF}

       End;
   {$ENDIF NOFILE}
   {$IFNDEF VER3}
    9:
    {$ELSE}
    8:
    {$ENDIF}
    If Are_You_Sure(1,Each) Then New_Select := 0;
  End

{$ELSE}
Editor(Geditnum)
{$ENDIF}


End;


PROCEDURE New_Pos(Po : Integer;OP:OpTip);

VAR Poz   : Byte;
    SC    : Byte;
    Wst   : String[4];

BEGIN

  MouseCursor(False);

  With MenuRec[Act_Menu] do
    BEGIN
      If Po = 0 Then
        Po := MemNum;
      If Po = MemNum+1 Then
        Po := 1;

      Poz :=  1;

      Menustr(Start+Item_Pos-1,vissz,False);
      SC := StartCh(Vissz);

      While vissz[Poz] = ' ' Do Poz := Poz + 1;

      Case Typ of
        hor : BEGIN
                Menustr(Start+Item_Pos-1,vissz,False);
                SC := StartCh(Vissz);
                Attribute(Yp+1,Xp+ShowLine[Start+Item_Pos-1],Yp+1,
                 Xp   +   ShowLine[Start+Item_Pos-1] +
                          byte(vissz[0])-1,   Co);

                Attribute(Yp+1,Xp+ShowLine[Start+Item_Pos-1]+SC-1,
                          Yp+1,Xp+ShowLine[Start+Item_Pos-1]+SC-1,Co3);

                Menustr(Start+Po-1,vissz,False);
                SC := StartCh(vissz);
                Attribute(Yp+1,Xp+ShowLine[Start+Po-1],Yp+1,
                 Xp   +   ShowLine[Start+Po-1] +
                          byte(vissz[0])-1,Curcolor[DispMode]);
              End; { Horizontal }
        ver : BEGIN
                Menustr(Start+Item_Pos-1,vissz,False);
                SC := StartCh(Vissz);
                If Op = Yes Then  { A  pozicio alatt levo string kiirasa }
                  Display(vissz,Yp+ShowLine[Start+Item_Pos-1],Xp+2);
                Attribute(Yp+ShowLine[Start+Item_Pos-1],Xp+2,
                       Yp+ShowLine[Start+Item_Pos-1],
                       Xp2-2,Co);

                Attribute(Yp+ShowLine[Start+Item_Pos-1],Xp+1+SC,
                          Yp+ShowLine[Start+Item_Pos-1],Xp+1+SC,Co3);

                Attribute(Yp+ShowLine[Start+Po-1],Xp+2,
                       Yp+ShowLine[Start+Po-1],
                       Xp2-2,Curcolor[DispMode]);

              End  { Vertical }
        End; { Case }
      Item_Pos := Po;
      Glob_Pos := Start+Po-1;
      (* Str(Glob_Pos:3,Wst); Wst := Wst + ' '; Display(Wst,25,02); *)
    End;  { With }

  MouseCursor(True);

End;


PROCEDURE Count_First;
VAR cikl : integer;
    SC,PPP   : Byte;
       CCC   : Char;

BEGIN
  With MenuRec[Act_menu] do   {Runtime Error 90}
    BEGIN
      FirstSt := '';
      for cikl := 0 to MemNum - 1 do
        BEGIN
          MenuStr(Start+Cikl,vissz,False);
          SC := StartCh(Vissz);
          {$IFDEF OROSZ}
          CCC := vissz[SC];
          PPP := pos(CCC,GOST_LO);
          if PPP <> 0 then CCC := GOST_ciril[PPP];
          FirstSt := FirstSt + CCC;
          {$ELSE}
          FirstSt := FirstSt + UpCase(vissz[SC]);
          {$ENDIF}
        End;
    End;
End;


PROCEDURE Write_Menu(Num:Integer);
VAR cikl : integer;
    SC,PPP   : Byte;
       CCC   : Char;
BEGIN
  With MenuRec[Num] do
    BEGIN
      FirstSt := '';
      If Level = 2 Then
        Sname := '';
      BOOL := CREATE_WINDOW(Xp,Yp,Xp2,Yp2,Sname,Co2,Co);
      If Typ = ver Then
        For Cikl := 0 To MemNum - 1 Do
          BEGIN
            MenuStr(Start+Cikl,vissz,False);
            SC := StartCh(Vissz);
            Display(vissz,Yp+ShowLine[Start+cikl],Xp+2);
            If NewMenu[Start + Cikl] <> 0 Then
             {$IFDEF OROSZ}
              Display('>',Yp+ShowLine[Start+cikl],Xp2-1);
             {$ELSE}
              Display('Ø',Yp+ShowLine[Start+cikl],Xp2-1);
             {$ENDIF}
            Attribute(Yp+ShowLine[Start+cikl],Xp+1+SC,
                      Yp+ShowLine[Start+cikl],Xp+1+SC,Co3);
            {$IFDEF OROSZ}
            CCC := vissz[SC];
            PPP := pos(CCC,GOST_LO);
            if PPP <> 0 then CCC := GOST_ciril[PPP];
            FirstSt := FirstSt + CCC;
            {$ELSE}
            FirstSt := FirstSt + UpCase(vissz[SC]);
            {$ENDIF}
          End
      Else
        For Cikl := 0 To MemNum - 1 Do
          BEGIN
            MenuStr(Start+Cikl,vissz,False);
            SC := StartCh(Vissz);
            display(vissz,Yp+1,Xp+ShowLine[Start+cikl]);
            Attribute(Yp+1,Xp+ShowLine[Start+cikl]-1+SC,
                      Yp+1,Xp+ShowLine[Start+cikl]-1+SC,Co3);
            {$IFDEF OROSZ}
            CCC := vissz[SC];
            PPP := pos(CCC,GOST_LO);
            if PPP <> 0 then CCC := GOST_ciril[PPP];
            FirstSt := FirstSt + CCC;
            {$ELSE}
            FirstSt := FirstSt + UpCase(vissz[SC]);
            {$ENDIF}
          End
    End;
End;

PROCEDURE Probal_Bemenni;

BEGIN
  If Majd_Kesobb Then
    With MenuRec[Act_Menu] do
      If NewMenu[Start + Item_Pos-1] <> 0 Then
        BEGIN
          Sel_It[Level] := Item_pos;
          Inc(Level);
          New_Select := NewMenu[Start + Item_pos-1];
          MenuStr(Start+Item_Pos-1,vissz,False);
          SC := StartCh(Vissz);
          Sname := vissz;
          Item_Pos := 1;
          Act_Menu := New_Select;
          Write_Menu(Act_Menu);
          New_Pos(Item_Pos,No);
          Majd_Kesobb := False
        End
End;

PROCEDURE New_Old_Pos(Plus:Integer);

BEGIN
  Dec(Level);
  Item_Pos := Sel_It[Level];
  New_Select := MenuRec[Act_Menu].P;    {  Visszalep  }
  Act_Menu := New_Select;
  Bool := Remove_Window;

  New_Pos(Item_Pos+Plus,No);               {  Uj Pozicio  }

  Majd_Kesobb := True;
  Probal_Bemenni                        {  Ujra belep  }

End;

{$IFDEF OROSZ}
var Ppp : byte;
{$ENDIF}

Var  Prob    : Integer;
     Talalt  : Boolean;
     Ws      : String[80];

BEGIN  { PROCEDURE menu }

  {$IFDEF CDNYOM}
  BOOL := CREATE_WINDOW(1,1,80,3,' Nyomtat†s ',CA[DispMode,1],CA[DispMode,2]);

  Write('             Nyomtat¢ modul êkSzer t°pus£ file-ok nyomtat†s†ra  ');

  If EndLine[GeditNum] < StartLine[GeditNum] Then
    Begin
      Sel_it[1] := 3;
      Sel_it[2] := 1;
      Runing_routines
    End;

  Sel_it[1] := 6;
  Sel_it[2] := 2;
  Runing_routines;

  BOOL := Remove_WINDOW;

  {$ELSE}

  {$IFNDEF CDVIEW}
  If CsakNez Then
    Begin
  {$ENDIF}
      Sel_it[1] := 1;
      Sel_it[2] := 1;
      Runing_routines
  {$IFNDEF CDVIEW}
    End
  Else
    Begin
      For Cikl := 1 To 15 do
        Sel_It[Cikl] := 0;
      Level    := 1;
      Act_Menu := 1;
      Item_Pos := 1;
      Majd_Kesobb := False;
      Sname := Mst2;
      Write_Menu(Act_Menu);
      New_Pos(Item_Pos,No);
      Repeat
        With MenuRec[Act_Menu] do
          BEGIN
            Puffi(A,B);
            AC := upcase(Char(A));

            If ClickOnCurrentWindow Then
            Begin

              ClickOnCurrentWindow := False;

              Prob := Start;
              Talalt := False;
              While (Prob < Start+MemNum) AND NOT(Talalt) Do
              Begin
                Case Typ Of
                  Ver: Talalt := (ShowLine[Prob] = ClickYpos+1);
                  Hor: Begin
                         MenuStr(Prob,Ws,False);
                         Talalt := (ClickXpos+1
                         In [ShowLine[Prob]..ShowLine[Prob]+Length(Ws)-1]);
                       End;
                End;
                Inc(Prob);
              End;
              If Talalt Then
              Begin
                Dec(Prob,Start);
                {MenuStr(Prob-1,Ws,False);
                Display(Ws+'           ',25,1);}
                New_Pos(Prob,No);
                A := 13;

              End;
            End;

            {$IFDEF OROSZ}
            Ppp := pos(AC,Ekszer_ciril);
            If Ppp <> 0 then
              AC := Gost_ciril[Ppp];
            {$ENDIF}

            If Pos(AC,FirstSt) <> 0 Then
              BEGIN
                New_Pos(Pos(AC,FirstSt),No);
                A := 13
              End;
            Case A of
              Escape     : If Level > 1 Then
                             BEGIN
                               Majd_Kesobb := False;
                               Dec(Level);
                               If Level <> 0 Then
                                 Item_Pos := Sel_It[Level];
                               New_Select := P;
                               Act_Menu := New_Select;
                               Bool := Remove_Window;
                               If New_Select <> 0 Then
                                 Count_First;
                               New_Pos(Item_Pos,No);
                             End;
              13         : BEGIN
                             Majd_Kesobb := False;
                             Sel_It[Level] := Item_pos;
                             Inc(Level);
                             New_Select := NewMenu[Start + Item_pos-1];
                             If New_Select <> 0 Then
                               BEGIN
                                 MenuStr(Start+Item_Pos-1,vissz,False);
                                 SC := StartCh(Vissz);
                                 Sname := vissz;
                                 Item_Pos := 1;
                                 Act_Menu := New_Select;
                                 Write_Menu(Act_Menu);
                                 New_Pos(Item_Pos,No);
                               End
                             Else
                               BEGIN
                                 Runing_Routines;
                                 Dec(Level);
                                 New_Pos(Item_Pos,Yes);
                                 If SetLapdobVolt Then
                                 Begin
                                   New_Pos(Item_Pos+1,No);
                                   New_Pos(Item_Pos-1,Yes);
                                   SetLapdobVolt := False;
                                 End;
                               End
                           End;
              End;
            Case B of
              Felnyil    :   If Typ = ver then
                               BEGIN
                                 New_Pos(Item_Pos-1,No);
                                 Probal_bemenni
                               End
                             Else
                               If Level > 1 Then
                                 If MenuRec[P].Typ = ver then
                                   New_Old_Pos(-1);
              Lenyil     :   If Typ = ver then
                               BEGIN
                                 New_Pos(Item_Pos+1,No);
                                 Probal_bemenni
                               End
                             Else
                               If Level > 1 Then
                                 If MenuRec[P].Typ = ver then
                                   New_Old_Pos(+1)
                                 Else BEGIN End
                               Else
                                 BEGIN
                                   Majd_Kesobb := True;
                                   Probal_Bemenni;
                                   Majd_Kesobb := False
                                 End;
              Jobbranyil :   If Typ = hor then
                               BEGIN
                                 New_Pos(Item_Pos+1,No);
                                 Probal_Bemenni
                               End
                             Else
                               If Level > 1 Then
                                 If MenuRec[P].Typ = hor then
                                   New_Old_Pos(+1)
                                 Else BEGIN End
                               Else
                                 BEGIN
                                   Majd_Kesobb := True;
                                   Probal_Bemenni;
                                   Majd_Kesobb := False
                                 End;
              Balranyil  :   If Typ = hor then
                               BEGIN
                                 New_Pos(Item_Pos-1,No);
                                 Probal_Bemenni
                               End
                             Else
                               If Level > 1 Then
                                 If MenuRec[P].Typ = hor then
                                   New_Old_Pos(-1)
            End;  { Case }

          End

      Until New_Select = 0;
    End
  {$ENDIF CDVIEW}
  {$ENDIF CDNYOM}
End; {  Menu  }

End.