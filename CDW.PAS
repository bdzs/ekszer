{$S-,I+,F-,V-,B-,N-,A-}

{$I MEMORY.CDW}

Program CDWORD;


{$IFDEF HALO}

{$DEFINE NOVELL_3}
{$DEFINE NOVELL_386}
{$DEFINE NUKU_HON}

  {$IFDEF NAGYSOLYMOSI}
    {$DEFINE test_nh}
  {$ENDIF}

{$ENDIF}


Uses

  Crt,          { Standard unitok }
  Dos,
  Graph,
  {$IFNDEF DPMI}
  Overlay,
  {$ENDIF}

  {$IFDEF PROBA}
  printer,
  {$ENDIF}

  ReadKit,      { Ki kell irtani !!! }

                { Alap ekszer unitok }

  Video,        { CGA5.OBJ + DISPLAY.OBJ Assembly rutinok }
  WindowM,      { Window manager + sok mas                }
  BGI,          { FI }
  HeapCdw,      { memoriakezeles }
  InputCdw,     { Input + sok mas }
  EmsCdw,       { Ems kezelo       }
  XmsCdw,       { Xms kezelo       }
{$IFDEF HELYESKE}
  PlusMem,
{$ENDIF}
                { Opcionalis rutinok }

{$IFDEF HALO}
{  Halozat,      { Halozati vedelem   }
{$ENDIF}

{$IFDEF NETSER}
  NetSer,       { Sajat halozati sorszam lekerdezo }
{$ENDIF}

{$IFDEF ROMCHKF}
RomChk2,        { file-os romcheck   }
{$ENDIF}

{$IFDEF VINES}
BANV,
{$ENDIF}

{$IFDEF LANSMART}
LanSmart,
{$ENDIF}

{$IFDEF PCNFS}
PcNfs,
{$ENDIF}

{$IFNDEF VER3}
Publicat,       { publikacio         }
{$ENDIF}

{$IFDEF EKSZINF}
EkszInf,
{$ENDIF}

{$IFDEF DECNET}
DECNET,      { vedelem DECNET-en (TERIMPEX)  }
{$ENDIF}

{$IFDEF PACKARD}
CHKPACK,
{$ENDIF}

{$IFDEF EKNET}
EKNET,
{$ENDIF}

{$IFDEF BEMUTAT}
Bemutat,
{$ENDIF}


               { Overlay-ezheto rutinok }
{$IFNDEF CDVIEW}
            Mod_Save,    { modem-save                 VF-FI }
{$ENDIF}
            InputOvr,    { Az Inputcdw overlayezheto fele   }

{$IFNDEF CDVIEW}
            Nyomtat,     { Nyomtatas-adogato                }
            MODEMCDW,    { modemkezelo                      }
            Nyom0,       { 8 tus nyomtatomeghajto           }
            Nyom1,       { Laser nyomtatomeghajto           }
            Nyom2,       { Robotron irogepmeghajto          }
            Nyom3,       { 24 tus nyomtatomeghajto          }
            Nyom4,       { 8 tus nyomtatomeghajto (30T)     }
            Nyom5,       { 8/24 tus repulo nyomtatomeghajto }
            Nyom6,       { BubbleJet (gyorsban repulo)      }
            Nyom7,       { DESKJET: alahuzasok, euro, stb   }
            Nyom8,       { DESKJET: grafikus nyomtatas      }
            Nyom9,       { IBM 24 tus 852                   }
            Nyom10,      { EPSON 24 tus 852                 }
            Nyom11,      { LASER CP852                      }

{$IFNDEF VER352}
            Preview,     { Preview                          }
{$ENDIF}

            StartNyo,    { nyomtatas indito                 }

{$ENDIF CDVIEW}

            FileCdw,     { File-dolgok                      }

{$IFNDEF CDVIEW}
            SetCdw,      { Beallitasok                      }
            Szotag,      { Szotagolas                       }
{$ENDIF}
            EGAOVR,       { Grafikus driverek                }
            CGAOVR,
            HEROVR,
            StartCdw,    { konfiguracio, com.line param.    }
            InitCdw,     { mem.conf., alap parameterek      }
            Editor,      { Szerkeszto                       }
            MenuErr,     { Menu szovegek, error szovegek    }
            MenuCdw,     { Menukezelo                       }
{$IFDEF HELYESKE}
            ELEMTAB,
            ELEMEZ,      { helyesiras-ellenorzo             }
{$ENDIF}
            SpeakCdw;    { Duma }

{$IFNDEF CDVIEW}

{$O Nyom0 }
{$O Nyom1 }
{$O Nyom2 }
{$O Nyom3 }
{$O Nyom4 }
{$O Nyom5 }
{$O Nyom6 }
{$O Nyom7 }
{$O Nyom8 }
{$O Nyom9 }
{$O Nyom10 }
{$O Nyom11 }


{$IFNDEF VER352}
{$O Preview}
{$ENDIF}

{$O Startnyo}
{$O Szotag}
{$O Mod_Save}  { VF-FI }
{$ENDIF CDVIEW}

{$O FileCdw }

{$O Editor  }

{$IFNDEF CDVIEW}
{$O SetCdw  }

{$O CalcCdw }      {  Calculator }
{$ENDIF CDVIEW}

{$O Initcdw }
{$O StartCdw}

{$IFNDEF CDVIEW}
{$O ModemCdw}
{$ENDIF CDVIEW}


{$O MenuCDW}
{$O INPUTOVR}

{$IFNDEF CDVIEW}
{$O NYOMTAT}
{$ENDIF}


{$O EGAOVR}
{$O CGAOVR}
{$O HEROVR}


{$IFDEF ROMCHK}
{$I ROMCHK.CDW}
{$ENDIF}


{$IFDEF NOFLOPPY}
{$I NOFLOPPY.CDW}
{$ENDIF}

{$IFDEF WINCH2}
{$I WELL2.CDW}
{$ENDIF}

{$IFDEF WINCH}
{$I WELL.CDW}
{$ENDIF}

{$IFDEF WINCHN}
{$I WELLN.CDW}
{$ENDIF}

var fp: text;

{$IFNDEF CDVIEW}

{$IFNDEF DEMO}
Function Disk_OK:Boolean;
Var P,Err,Cikl : Integer;
    Seri1,Seri2 : LongInt;
    Poin        : Pointer;
    S       : String[8];
    IntSeg  : Array[0..30] Of Char Absolute $0000:$0000;

Begin

{$IFNDEF KULCS}
  Disk_OK := True;
{$ELSE}

  {$IFNDEF PCNFS}
  {$IFNDEF LANSMART}
  {$IFNDEF VINES}
  {$IFNDEF HALO}
    {$IFNDEF EKNET}

    Seri1 := GetSorszam;

    (*
    P := Pos(CdwFSt2,Copyright2);
    If P <> 0 Then
      Begin
        {$IFDEF OROSZ}
        s := Copy(Copyright2,P+19,4);
        {$ELSE}
        s := Copy(Copyright2,P+10,4);
        {$ENDIF}
        Val(S,Seri1,Err);
        If Err <> 0 Then Seri1 := 0;
      End
    Else
      Seri1 := 0;

    *)

    If Seri1 <> 0 Then
      Begin
        { Assembler rutin meghivasa,vizsgalat }

        {$IFNDEF ELTETO6}
        S := '';

          {$IFDEF INFOMIX}
          For Cikl := 5 To 7 Do S := S + IntSeg[Cikl];
          S := S + IntSeg[$0C];
          {$ELSE}
          For Cikl := $04 To $07 Do S := S + IntSeg[Cikl];
          For Cikl := $0C To $0F Do S := S + IntSeg[Cikl];
          {$ENDIF}
        {$ELSE}
        Poin := Ptr(PrefixSeg,$78);
        Move(Poin^,S[1],8);
        S[0] := #8;
        {$ENDIF}

        For Cikl := 1 To Length(S) Do S[Cikl] := Char(Byte(S[Cikl]) OR $30);

        Val(S,Seri2,Err);
        If Seri2 <> 0 Then
          Disk_OK := Seri1 = Seri2
        Else
          Disk_OK := True
      End
    Else
      Disk_OK := True
    {$ELSE}    { Ha EkNet van }
      ElsoHVolt := NOT Estart;
      Disk_Ok   := Not ElsoHVolt
    {$ENDIF}
  {$ELSE}  { Ha HALO van }
      ElsoHVolt := NOT HIndul;
      Disk_Ok   := Not ElsoHVolt
  {$ENDIF}
  {$ELSE}  { Ha VINES van }
      Disk_Ok   := CheckSerialNumber;
  {$ENDIF}
  {$ELSE}  { Ha LANSMART van }
      Disk_Ok   := CheckLansmart;
  {$ENDIF}
  {$ELSE}  { Ha PCNFS van }
      Disk_Ok   := Check_PCNFS;
  {$ENDIF}

{$ENDIF}

End;
{$ENDIF}

Procedure Set_PassWords;
Var Ovn : String[80];
    Buf : String[20];
    Cik,Bc: Byte;
    Ver   : String[4];
    Sorsz : Word;
    Code  : Integer;
    Fs,Ft : LongInt;
    Pwr   : Array[1..10] Of Real;
    Pw    : Array[1..10] Of String[14];
    Ip    : FnTyp;
   {Ido   : DateTime;}

    F   : File;
Begin
  Ovn := OvrName;
  If OrigPath[Length(OrigPath)] <> '\' Then Ovn := '\' + Ovn;

  Ip := ExePath;

  (* WriteLn('*',Ip,'*',Ovn,'*'); Halt; *)


  If Ovn[1] = '\' Then Dec(Byte(Ip[0]));

  FileMode := 0;

  OvrPath := OrigPath;
  Assign(F,OrigPath+Ovn);

  {$I-}
  Reset(F,1);
  {$I+}

  If IORESULT <> 0 Then
  Begin
    Assign(F,Ip+Ovn);
    OvrPath := Ip;
    {$I-}
    Reset(F,1);
    {$I+}
    If IORESULT <> 0 Then
    Begin
      Writeln('Az ',Ip,Ovn,' file nem tal�lhat� !');
      Halt(1);
    End;
  End;

  FileMode := 2;

  Sorsz := GetSorszam;
  Ver   := GetVersion;

  GetFtime(F,Ft);
  { UnpackTime(Ft,Ido); }

  Fs := Filesize(F);

  BlockRead(F,Buf[1],13 {9 volt} );
  Buf[0] := #10;

  {$IFNDEF PACKARD}
  For Cik := 1 To 10 Do
  Begin
    Val(Ver,Pwr[Cik],Code);

    Pwr[Cik]:=Frac(Frac(Sqrt(Sorsz))+Frac(Sqrt(1.11111*Cik*Ft/(Pwr[Cik]*Fs))));

    Str(Pwr[Cik]:1:11,Pw[Cik]);
    Delete(Pw[Cik],1,3);


    For Bc := 1 To 10 Do
      Pw[Cik][Bc] :=
        Char( ( 25*Bc*(Byte(Pw[Cik][Bc])+13) MOD 26 )+65 );

    BlockRead(F,Buf[1],10);


    Enabled[Cik] := (Buf = Pw[Cik]);

    {
    Writeln(Cik,'.  ',Buf,'   ',Pw[Cik],'  ',Enabled[Cik]);
    If ReadKey = ' ' Then;
    }

  End;

  {$IFDEF LQ}
  Enabled[1] := True;
  {$ENDIF}

  {$IFDEF GRAFIKA}
  Enabled[2] := True;
  {$ENDIF}

  {$IFDEF IROGEP}
  Enabled[3] := True;
  {$ENDIF}

  {$IFDEF KORLEV}
  Enabled[4] := True;
  {$ENDIF}

  {$IFDEF LASER}
  Enabled[5] := True;
  {$ENDIF}

  {$ELSE}
  For Cik := 1 To 10 Do
  Begin
    BlockRead(F,PW1[Cik][1],10);
    PW1[Cik][0] := #10;
  End;
  BlockRead(F,DatePack1,20);

  {$ENDIF}

  Close(F);

  {$IFNDEF PROBA}
  {$IFNDEF HALO}
  {
  SetFAttr(F,ReadOnly+Archive);
  if doserror=0 Then;
  }
  {$ENDIF}
  {$ENDIF}

End;
{$ENDIF}

Var ORes : Integer;
    S    : String[6];

    PPP  : Pointer;

Label INT3F,MAIN,HERE,HERE1,KILEP;


{$IFDEF JOZSI}
Procedure Jelszo;
Const T : String[5] =
'Jozsi';
Var B  : Boolean;
    C  : Byte;
Begin
  B := True;
  For C := 1 To Byte(T[0]) Do
    B := B And (ReadKey = T[C]);
  If Not B Then
    Inline($EA/$F0/$FF/$00/$f0)
End;
{$ENDIF}

Procedure SetInitial;
Var SS : String[10];

Procedure AllocFromMem;
Begin
  If MaxAvail > MennyiKell Then
    GetMem(Arr,MennyiKell)
  Else
    Begin
      Str(MennyiKell-MaxAvail,SS);
      Error(4,' -'+SS+' byte');
      Terminate
    End;
End;


{$IFDEF HELYESKE}
Procedure AllocForHelyeske;
Begin

  If MaxAvail > SizeOf(NagyBitT) Then
    GetMem(NagyBit,SizeOf(NagyBitT))
  Else
    Begin
      Str(SizeOf(NagyBit^)-MaxAvail,SS);
      Error(4,' -'+SS+' byte hi�nyzik a HELYESKE bet�lt�s�hez');
      Terminate
    End;

End;
{$ENDIF}


Begin
  {$IFDEF HELYESKE}
  AllocForHelyeske;
  {$ENDIF}

  StandardHandle := 54321;
  MennyiKell := SizeOf(Arr^)+((LastLine+3)*c160 {Image} )+SizeOf(SorTab^)+
                SizeOf(Fonts^)+16;
  EmsMaradek := 0;
  If Van_Ems And (Ems_Pages_Available >= 3) Then
    Begin
      Allocate_Ems_Pages(3,StandardHandle);
      Get_Ems_PageN(StandardHandle,1,0);
      Get_Ems_PageN(StandardHandle,2,1);
      Get_Ems_PageN(StandardHandle,3,2);
      If MennyiKell > $C000 Then
        Begin
          AllocFromMem;
          EmsMaradek := $C000;
        End
      Else
        Begin
          Arr := Ptr(Get_Ems_Segment+$400,0);
          EmsMaradek := $C000-MennyiKell;
        End;
    End
  Else
    AllocFromMem;
  SetOffs;

  CimRecBuff  := Pointer(Image[-2]);
  RecDate     := Pointer(Image[-2]);
End;

Procedure ElSzall;
Begin
  ASM
    MOV  AX,$E000
    ADD  AX,$1000
    PUSH AX
    ADD  AX,$0FF0
    PUSH AX
    RETF
  END;

  { Inline($EA/$F0/$FF/$00/$f0); }   { JMP F000:FF00  Elszall ! }
  { Writeln('Filekezeles szar ',Sz,' Hibak�d: ',Regs.AX); }
End;


{$IFDEF INFOHIV}
Procedure RestInts;
Var P : Pointer;
    H : Word;
Begin
  {P := @Fproc;}
  H := Ofs(Eproc)-Ofs(Fproc);
  MOVE(@INIT_MENU^,@Fproc^,H);
  GetIntVec($B1,P);
  SetIntVec($01,P);
  GetIntVec($B3,P);
  SetIntVec($03,P);
End;
{$ENDIF}


Label Idaig;

{$IFDEF QUADERNO}
Const
QSt : String[8] = 'xxxxxxxx';
Var
QArr: Array[0..8] Of Byte Absolute $F000:$FFF5;
{$ENDIF}

Label XT_Mode,FNext,FLoop,FExit;

Begin {Main}

{$IFNDEF DPMI}

Asm
           CALL  FNEXT
FNEXT:     POP   DI
           PUSH  DS
           PUSH  ES
           MOV   AX,CS
           MOV   DS,AX
           MOV   ES,AX

           SUB   DI,$0F
           CMP   BYTE PTR [DI+08],$C8  {ENTER 0100,00 k�dja, csak 286 m�dban}
           JNZ   XT_MODE

           ADD   DI,03

XT_MODE:   MOV   SI,DI
           ADD   SI,04
FLOOP:     CMP   BYTE PTR [DI],$9A
           JNZ   FEXIT
           SUB   DI,05
           JMP   FLOOP
FEXIT:     ADD   DI,05
           MOV   CX,SI
           SUB   CX,DI
           INC   CX
           ADD   SI,08
           CLD
           REPZ  MOVSB
           POP   ES
           POP   DS
End;

{$ENDIF}

Asm
   MOV   AX,$3300
   INT   $21
   MOV   BreakStatus,DL

   MOV   AX,$3301
   MOV   DL,$00
   INT   $21
End;

{$IFDEF QUADERNO}

  Asm
    NOP
    NOP
    NOP
    NOP
    NOP
  End;

  Move(QArr,QSt[1],8);
  If (QSt <> '10/23/92') AND
     (QSt <> '06/26/92') Then Elszall;

{$ENDIF}

{$IFDEF LANCHOR}

  Tfn := ParamStr(0);

{  Tfn := 'H:\WORK\EXE\CDWL.EXE'; }

  OpenRead(Tfn); If FErr Then Elszall;

  SeekRead(Handle,$00,$16); If FErr Then Elszall;
  ReadRead(Handle,Tfb,2);   If FErr Then Elszall;

{
  Tfl := Tfb;
  ReadRead(Handle,Tfb,2);   If FErr Then Elszall;

  Tfl := LongInt(Tfb)*16 + Tfl;
  Dec(Tfl,$17B4);

}

  Tfl := LongInt(Tfb)*16;
  Inc(Tfl,$235);

  {
  Tfl := FileSizeRead(Handle);   (* Ez az �j m�dszer *)
  Dec(Tfl,$41DB);
  }

  SeekRead(Handle,Tfl SHR 16,Tfl AND $FFFF); If FErr Then Elszall;

  Tfs[0] := #36;
  ReadRead(Handle,Tfs[1],36); If FErr Then Elszall;

  CloseRead(Handle);

  { Writeln('�',TFs,'�');  Halt; }

  If Tfs <> '*** EltLANCHOR LAN Protection System' Then ElSzall;

{$ENDIF}

  SetInitp := @SetInitial;
  SetIni2  := @ElSzall;


  Win_Stack := Ptr(Sseg,0);    { A stack aljara allitom, az INITCDW   }
  INIT_WINDOW;                 { majd atallitja ! }


  EmsOvr    := False;
  SwapError := False;
  SwapError2:= False;
  WinHely[0] := '';
  WinHely[1] := '';

  VanEmsM := False;
  VanXmsM := False;
  VanDskM := False;
  VanNyelvesz := False;
  StandardHAndle := 54321;

  {$IFNDEF DPMI}

  {$I-}
  OvrInit(OvrName);
  ORes := OvrResult;
  {$I+}

  OvrSetBuf(OvrGetBuf+2000);
  Inc(ORes,OvrResult);

  { Itt volt a set_initial }

 (**
  ASM

        JMP MAIN

INT3F:

        PushF
        Push Cx
        pUSH Ax

        Xor  Cx,Cx
        Mov  Al,04H
        Out  42H,Al
        Xor  Al,Al

        DEC  Al
        Out  61H,Al
HERE:   Loop HERE
        inc  Al
        Out  61H,Al


        Xor  Cx,Cx
        Mov  Al,07H
        Out  42H,Al
        Xor  Al,Al

        dec  Al
        Out  61H,Al
HERE1:  Loop HERE1
        INC  Al
        Out  61H,Al


        POP Ax
        POP CX
        POPF

        DB 00EAH
KILEP:	DW 00
        DW 00


MAIN:

	PUSH DS

	XOR AX,AX
	MOV DS,AX
	MOV SI,4*3FH
	MOV CX,02
	CLD
	PUSH CS
	POP ES
	MOV DI,OFFSET KILEP
	REPZ MOVSW

	MOV AX,253FH
	PUSH CS
	POP DS
	MOV DX,OFFSET INT3F
	INT 21H

        POP DS
  END;

 **)

  If ORes <> 0 Then
    Begin
      Str(ORes:4,S);
      Error(23,S);
      Terminate
    End;
  {$ENDIF}

  ElsoHVolt := False;

  {$IFDEF BEMUTAT}
  DatumCheck;
  {$ENDIF}

  {$IFDEF WINCH}
  Well;
  {$ENDIF}

  {$IFDEF WINCH2}
  Well;
  {$ENDIF}

  {$IFDEF WINCHN}
  Well;
  {$ENDIF}

  {$IFDEF JOZSI}
  Jelszo;
  {$ENDIF}

  {$IFDEF ROMCHK}
  RomCheck;
  {$ENDIF}

  {$IFDEF NETSER}

  {Writeln(GetNetSerNo);}

  NetSerNo := GetNetSerNo;
  If Not(VanIlyen(NetSerNo)) Then
    Begin
      Wst := 'a program nincs install�lva ezen a Netware-en';
      If NetSerno < 256 Then Str(NetSerno,Wst);
      Error(43,': '+Wst);
      NetError := True;
      Terminate;
    End;
  {$ENDIF}

  {$IFDEF DECNET}
  CheckInterrupt;
  {$ENDIF}

  {$IFDEF NOFLOPPY}
  NoFloppy;
  {$ENDIF}


  {$IFNDEF CDVIEW}
  {$IFNDEF DEMO}
  IF Disk_OK Then
    Begin
  {$ENDIF}
  {$ENDIF}


      { !!! itt volt }

      DirectVideo := False;
      CrtMode := 3;
      DispMode := BW;
      Set_Nem_lehet;

      {Set_Int_A0;}
{ DISPLAY.ASM - ben a READLN beolvasott byte-jait maszkolta
  $7F - el. Forditashoz TURBO.TPL helyett a TURBO.NEW library-t kellett
  hasznalni. }

      GetDir(0,OrigPath);

      ExePath := ParamStr(0);
      While ExePath[Length(ExePath)] <> '\' Do Dec(Byte(ExePath[0]));

      AlapPath    := ExePath;
      If AlapPath[Length(AlapPath)] <> '\' Then AlapPath := AlapPath + '\';

      DiskMemPath := ExePath;
      If DiskMemPath[Length(DiskMemPath)] <> '\' Then DiskMemPath := DiskMemPath + '\';

      If OrigPath[Length(OrigPath)] <> '\' Then
      Begin
        DefFile    := '\' + DefFile;
        ConfigFile := '\' + ConfigFile;
      End;

      DefFile    := OrigPath + DefFile;
      ConfigFile := OrigPath + ConfigFile;
{$IFDEF BEMUTAT}
      ErvenyesIdoszak := ErvenyesIdoszak2;
{$ENDIF}

      FFF   := '0';

      Parameters;

      Read_Driver;

      {$IFDEF ROMCHKF}
      RomCheck;
      {$ENDIF}

      SetInitial;

      {$IFNDEF DPMI}
      If (Van_Ems OR SajatEMSVan) And EmsOvr Then
        Begin
          {$IFDEF ANGOL}
          Writeln('Loading overlay file ('+OVRName+') ...');
          {$ELSE}
          Writeln('Overlay file ('+OVRName+') bet�lt�se ...');
          {$ENDIF}
          OvrInitEms;         { Az overlay-t EMS-re rakja }
        End;
      {$ENDIF}

      {$IFNDEF CDVIEW}

      {$IFNDEF OROSZ}
      {$IFNDEF ANGOL}
      {$IFNDEF ROMAN}
      Set_PassWords;
      {$ENDIF}
      {$ENDIF}
      {$ENDIF}

      {$IFDEF NOPW}
      For Cik := 1 To 5 Do Enabled[Cik] := True;
      {$ENDIF}

      {$IFDEF PACKARD}
      Enabled[1] := True;
      {$ENDIF}

      {$IFDEF PROBA}
      Enabled[6] := True;
      {$ENDIF}

      {$IFDEF HELYESIR}
      Enabled[6] := True;
      {$ENDIF}

      {$ENDIF}

       Move(SetIni2^,SetInitP^,Ofs(SetIni2^)-Ofs(SetInitp^));

      {$IFDEF PACKARD}
      ChkPck;
      {$ENDIF}

      {$IFDEF HELYESKE}

        {$IFDEF SPELL}
        Err := INITAB(2057);
        Writeln('Angol Helyeske bet�lt�se ...');
        {$ELSE}
        Err := INITAB(1038);
        Writeln('Helyeske bet�lt�se ...');
        {$ENDIF}

      VanHelyeske := (Err = 0);

      Case Err Of
        2,3 : Error(1,' a Helyeske adatb�zisa');
        254 : Error(4,' a Helyeske bet�lt�s�hez');
        255 : Error(4,' (EMS/XMS) a Helyeske bet�lt�s�hez');
        End;
      {$ENDIF}

      XX := GraphResult;
        If XX >= 0 Then
          Begin
            TextMode(Co80);
            {RestoreCrtMode;}

            DirectVideo := True;

            Clrscr;

	    CurOff;

	    Init_menu;

            {$IFDEF SECRET}
            VanJelszo := False;
            {$ENDIF}

            Init;

            {$IFDEF INFOHIV}
            RestInts;
            {$ENDIF}


            Idaig:

            {$IFDEF OROSZ}
            Elvalaszt := false;
            {$ENDIF}

            Menu;

            {$I-} Chdir(OrigPath); {$I+}
            If IoResult <> 0 Then Error(2,OrigPath);
            {$IFNDEF CDVIEW}
            If Remove_Window And Remove_Window Then
            {$ENDIF}
              CurOn;
            SetIntVec($1B,Vector1B);

            {$IFNDEF CDVIEW}
            Window(1,1,80,25);
            TextAttr := 15;
            For Cik := 1 to 21 Do DelLine;
            GotoXY(1,6);
            {$ENDIF}
          End
        Else
	  Error(54,''); { Nincs grafikus k�rtya a g�pben }

      If VanEmsM Then
        Release_Ems(Ems_Handle);
      If StandardHandle <> 54321 Then
        Release_Ems(StandardHandle);
      If VanXmsM Then
        XmsDeAlloc(Xhand);
      If VanDskM Then
        DelDskFile;
      {$IFDEF HELYESKE}
      Ext_Close;
      {$ENDIF}

{$IFNDEF DEMO}
{$IFNDEF CDVIEW}
    END

{$IFNDEF VINES}
{$IFNDEF HALO}
{$IFNDEF EkNet}
{$IFNDEF LANSMART}
{$IFNDEF PCNFS}
  ELSE
  Begin
    WriteLn(CdwFSt3);
    Speak(113);
  End
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}
{$ENDIF}


{$ENDIF}
{$ENDIF}
  ;
  Set_lehet;

  {$IFDEF CHEMOLIMPEX}

  If Szekreterfile <> '' Then {Szekreter programnak}
  Begin

    HeapWord := Ptr(MemW[$0040:$00F7],MemW[$0040:$00F5]);

    If HeapRec.Offset > 2
    Then
      Dec(HeapRec.Offset,2)
    Else
    Begin
      Dec(HeapRec.Segment);
      Inc(HeapRec.Offset,14);
    End;

    If Word(HeapWord^) = $AAAA Then
    Begin
      Inc(HeapRec.Offset,2);
      FillChar(HeapWord^,64,' ');
      Move(SzekreterFile[1],HeapWord^,Length(SzekreterFile));
    End;

  End;  { If SzekerterFile <> '' }

  {$ENDIF}

  {$IFDEF HALO}
          {  If Not(ElsoHVolt) And NOT(HKilep) Then;}
  {$IFNDEF NEMFIGYEL}
  SetBroadcastMode(0);
  {$ENDIF}
  {$ENDIF}

  {$IFDEF EKNET}
          {  If Not(ElsoHVolt) Then EEnd;}
  {$ENDIF}

{$IFNDEF CDVIEW}

  NyelveszFree;

  ptimeout[paralell_device] := 2;

  {$i-}

  {$IFDEF PROBA}
  WriteLn('PROBA opci�val volt forditva !');
  {$ELSE}
  If Ppar.Pr_Ovr <> 2 Then
  Begin
    If Int17(#27) Then
      Case ppar.pr_ovr of
         0: Bool := Int17('@');
         1: Bool := Int17('E');
         3: Bool := Int17('@');
         4: Bool := Int17('@');
         5: Bool := Int17('@');
         6: Bool := Int17('@');
         7: Bool := Int17('E');
      end;  {case}
  End;
  {$ENDIF}

  {$i+}
{$ENDIF}

  If SajatEmsVan Then
    SajatFree;
  WflLezar;

  SetMouse(False);

   Asm
     MOV   AX,$3301
     MOV   DL,BreakStatus
     INT   $21
   End;
End.