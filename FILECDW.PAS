Unit FileCdw;

{$O+}

Interface

Uses
  {$IFDEF PROBA}
  Printer,
  {$ENDIF}
  Dos,
  Crt,

  WindowM,
  MenuErr,
  InputCdw,
  InputOvr,

{$IFNDEF CDVIEW}
  ModemCdw,
{$ENDIF CDVIEW}

{$IFDEF DEBUG}
  HexKit,
{$ENDIF}

  Video,
  HeapCdw,
{$IFNDEF DPMI}
  Overlay,
{$ENDIF}
  SpeakCdw;


{$IFNDEF CDVIEW}

Procedure Del_File;
Procedure Rename_File;
Procedure Copy_File;
Procedure Direct;

Procedure Use_Cimlista(AutoLoad : Boolean);
Procedure Load_Condition(AutoLoad : Boolean);
Procedure Save_Condition;

Procedure Load_Macros(AutoLoad : Boolean);
Procedure Load_Parameters;
Procedure Load_Nyomtatok(nyomtato:boolean);
Procedure Save_Macros;
PROCEDURE Read_Helpfile(num : byte);
Procedure Select_File(VAR Dmask,Filename:FnTyp; Size : BYTE);

{$ENDIF}

Procedure Read_Deffile(VAR Parame : Boolean);
Procedure Load(VAR Filename:FnTyp; Filetip : Filetype; LoadMode : Loadtype);
{Procedure New_Load(VAR n_File : file);}

Procedure Load_File(VAR Fil:Szoveg; VAR N_Fil:file; Filetip : Filetype; Kor : age);

PROCEDURE CD(VAR Path : St80);
PROCEDURE Read_Files;

Procedure Load_SystemFont;
Procedure Load_Font (Num:Byte; Fn : St16);

Implementation

Const MMask : String[5] = '*.MAC';
      CMask : String[5] = '*.ADB';
      JMask : String[5] = '*.FEL';
      Chi25 : boolean   = False;

VAR   header_nev    : FnTyp;

{$I CDW.CDW}


{$IFNDEF CDVIEW}
Procedure Select_File{(VAR Dmask,Filename:FnTyp; Size : BYTE)};
VAR X1,Y1,X2,Y2 : Integer;
    Dt          : nevtomb;
    Db          : Word;
    Ut          : String;

elozoovr     : boolean;

BEGIN


  Case Size Of

      1     : BEGIN
                X1 :=  6; Y1 :=  7;
                X2 := 75; Y2 := 18;
              End;
      2     : BEGIN
                X1 := 15; Y1 := 09;
                X2 := 65; Y2 := 17;
              End;
      3     : BEGIN
                X1 := 25; Y1 := 12;
                X2 := 55; Y2 := 17;
              End;

  End; {Case}

  { BOOL := CREATE_WINDOW(X1-1,Y1-1,X2+1,Y2+1,InpST2+Dmask,CA[DispMode,1],CA[DispMode,20]); }
  Set_Choose(X1,Y1,X2,Y2,12,0);

  Enged := 0;
  Dir(dmask,Dt,Db,Ut);

  If not ESC then FileName := Ut + Dt[1]
  else FileName:='';

  { Bool := Remove_Window; }

End; { Select_File }
{$ENDIF}

Procedure Load_SystemFont;
var xx: integer;
Begin
  FileMode := 0;
  CheckRead(PathSt);
  If Not Esc Then
  Begin
    Assign(Fontfile,PathSt+SystemFontname+FExt[GrMode]);
    Writeln(SystemFontname+FExt[GrMode],IneSt13);
    {$i-} Reset(Fontfile); {$i+}
    If IOresult <> 0 Then
    Begin
      Error(1,SystemFontname+FExt[GrMode]);
      Bool := Remove_Window;
      Bool := Remove_Window;
      Terminate;
    End;

    Blockread(Fontfile,Fonts^[0],02,xx);
    Blockread(Fontfile,Fonts^[0],Blocks[GrMode],xx);

    Close(Fontfile);
 End;
 FileMode := 2;
End; {Load_SystemFont}

Procedure Load_Font {(Num:Byte; Fn : St16)};

Var
Filename : FnTyp;
Poz,Tipus: Byte;
xx       : integer;
TempFont : FontTipus;
Temp1,
Temp2    : PMutat;
TempByte : Byte;

Begin
  ESC := False;

  If Fn <> '' Then
  Begin
    FileMode := 0;
    ChFont[num]:=True;
    Filename := Fn + FExt[GrMode];
    Assign(Fontfile,PathSt+Filename);
    {$i-} Reset(Fontfile); {$i+}
    If IOresult = 0 Then
    Begin
      If Num > 0 Then
      Begin
        TempFont := Fonts^[Num];
        Temp1    := UpCasePoint[Num,1];
        Temp2    := UpCasePoint[Num,2];
        TempByte := FontAttr[Num];
      End
      Else
      Begin
        UpCasePoint[0,1] := @UresString;
        UpCasePoint[0,2] := @UresString;
      End;

      Poz := Pos(':',Fn);
      If Poz > 0 Then Delete(Fn,1,Poz);
      While Pos('\',Fn) > 0 Do Delete (Fn,1,1);
      UpperCase(Fn);
      If Font_Kiiras Then Writeln(Num,IneSt14,Filename);

      Blockread(Fontfile,Fonts^[Num],02,xx);
      Blockread(Fontfile,Fonts^[Num],Blocks[GrMode],xx);

      If Num > 0 Then
      Begin
        UpCasePoint[Num,1]:=PTR(Seg(Fonts^[Num].ElejeE[3]),
                            Ofs(Fonts^[Num].ElejeE[3]));
        UpCasePoint[Num,2]:=PTR(Seg(Fonts^[Num].ElejeE[3]),
                            Ofs(Fonts^[Num].ElejeE[3])+Fonts^[Num].ElejeE[3]+1);

        FontAttr[Num]      := Fonts^[Num].ElejeE[1];

        Tipus := (Fonts^[Num].ElejeE[2]) SHR 4;

        If (Tipus = 0) OR (Tipus > 2) Then
        Begin
          {Nem EkSzer font}

          UpCasePoint[Num,1] := @UresString;
          UpCasePoint[Num,2] := @UresString;

          {Error(24,Filename); {nem jo file}
          {ESC := True;
          Fonts^[Num]         := TempFont;
          UpCasePoint[Num,1] := Temp1;
          UpCasePoint[Num,2] := Temp2;
          FontAttr[Num]      := TempByte;}
        End;

        Fontnames[Num] := Fn;

      End;

      Close(Fontfile);

      If ExtendedE(Num) Then
      Begin
        ExtSet := ExtSet + [Num];
      End
      Else
      If Num In ExtSet Then
      Begin
        ExtSet := ExtSet - [Num];
      End;
    End
    Else
    Begin
      Error(1,Filename);
      ESC := True;
      {Move(Fonts^[0],Fonts^[Num],16*(128-32)+$48);}
      { FillChar(Fonts^[Num],CLines[GrMode]*(128-32)+ECB[GrMode],0); }
    End;
    FileMode := 2;
  End; { If Fn <> '' }

End; {Load_Font}



VAR  ElsoSor         : Boolean;
     IORES           : Integer;


Procedure BlockReadPuff(Var N_Fil:File;Var Puf; Db: Word);
Var Buf : Array[1..PufferSize] Of Byte Absolute Puf;
    Res,Remain : Word;
    Vsiz,Ksiz  : Word;

Procedure ReadOneBlock;
Begin
  {$I-}
  {$IFDEF SECRET}
  If KellJelszo AND VanJelszo And KodoltFile Then
    Begin
      BlockRead(N_Fil,BufferP^,KodoltSize,Res);

      KSiz := 0;
      Vsiz := Res;
      While ((Vsiz+1023) Div 1024) > Ksiz Do
        Begin
         Dec(Vsiz,12);
         Inc(Ksiz);
        End;
      Pufferben := Vsiz;
      Kodol(BufferP,Vsiz,@BaseBytes,1); { dekodolas }
    End
  Else
  {$ENDIF}
  Begin
    BlockRead(N_Fil,BufferP^,ValodiSize,Res);
    Pufferben := Res;
  End;
  {$I+}
End;


Begin
  If BufPointer = 0 Then
    Begin { Legelso blockreadpuff }
      {$IFDEF SECRET}
      If KodoltFile Then
        Seek(N_Fil,3);
      {$ENDIF}
      ReadOneBlock;
      IORES := IOResult;
    End;

  Inc(BufPointer,Db);

  If BufPointer <= ValodiSize Then
    Move(BufferP^[BufPointer-Db+1],Buf[1],Db)  { Nem lepjuk tul a puffert }
  Else
    Begin
      Remain := BufPointer - ValodiSize;     { ennyivel lepjuk tul }
      Move(BufferP^[BufPointer-Db+1],
           Buf[1],
           Db-Remain);                       { ennyi van meg a pufferben}

      ReadOneBlock;
      IORES := IOResult;
      Move(BufferP^[1],Buf[1+Db-Remain],Remain); { atmasoljuk a fennmarado reszt}
      BufPointer := Remain;
    End;
  Inc(FilePoz,Db);
End;

Procedure Load_File{(VAR Fil:Szoveg; Filetip : Filetype; Kor : age)};


VAR Fpt,Pt          : LPoint;
    NullAttr        : Byte;
    PrevFont        : Byte;
    Gfont           : Array [0..1] Of Byte;
    FDist,Adist,Rec : Byte;
    Alsok,Felsok    : Byte;
    PluszIndex,X    : Byte;
    Soft            : Boolean;
    End_of_file     : Boolean;
    Cik             : Integer;
    Upper           : Boolean;
    elozoovr        : boolean;
    elso_fej        : boolean;
    FLefoglal       : Word;
    Buffer          : BuffT;


    EndOfHeader     : Boolean;

{$I Old_Load.CDW}


PROCEDURE New_Load;

LABEL RosszSzerk;

CONST azon : array [1..26] of string[2] =
(('CD'),('CF'), ('HA'),('HE'), ('HO'),('H1'), ('H2'),('H3'), ('H4'),('H5'),
 ('H6'),('H7'), ('H8'),('H9'), ('OA'),('OE'), ('OO'),('O1'), ('O2'),('O3'),
 ('O4'),('O5'), ('O6'),('O7'), ('O8'),('O9'));

VAR

fel_sor_darab : word;
eleje         : string[4];
fontok_szama  : byte;
puff_b        : byte;
font_nev      : st16;
cikl_v        : word;
a_ind_sor     : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
f_ind_sor     : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
nincs_also    : boolean;
rel_sorsz     : byte;
lap_vege      : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
sor_hossz     : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
attr_osszeg   : byte;
kar_osszeg    : byte;
kemeny_sorveg : byte;
darab         : byte;
TabSzam       : byte;
TabPoz        : array [1..MaxMaxChars-2] of byte;
EmsS          : Word;
Volt_hiba     : Boolean;

Hossz         : Byte;
HosszSt       : String[12];
UjHosszSt     : String[12];

Dummy         : Array[1..MaxMaxChars-2] Of Byte;


PROCEDURE Pt_tolt(KellPt : boolean);

VAR cikl_v : byte;
    mento  : longint;
    Kar    : Char;
    Pieces : Integer;
    (* belsor : array [1..160] of Char; *)
    helyy  : longint;
    pozi   : longint;

BEGIN
  attr_osszeg:=0;
  kar_osszeg:=0;
  mento:=Pt^.Attribs[0];

  { Attributumok }
  While attr_osszeg < sor_hossz do
    BEGIN
      BlockReadPuff(N_Fil,puff_b,1);
      If IORES<>0 then Exit;
      darab:=puff_b shr 4;
      puff_b:=puff_b and 15;
      If darab=0 then darab:=sor_hossz; {A sorban nincs fontvaltas}

      If Attr_Osszeg < c76 Then
      Begin
        Pieces := Darab;

        If Attr_Osszeg + Darab > c76 Then
          Pieces := c76 - Attr_Osszeg;

        If Attr_Osszeg + Pieces <= c76 Then
          FillChar(Pt^.Attribs[attr_osszeg],Pieces,puff_b);
      End;

      Inc(attr_osszeg,darab);
    End;

    {
    If Attr_Osszeg > Sor_Hossz Then
    Begin
      WriteLn('Sor_Hossz = ',Sor_Hossz,'  Attr_Osszeg = ',Attr_Osszeg,'   FilePoz = ',FilePoz);
      If ReadKey = ' ' Then Begin End;
    End;
    }

  If KellPt then Pt^.Attribs[0]:=Pt^.Attribs[0] or mento;

  { Karakterek }

  (*
  pozi  := FilePos(N_Fil);              { A beolv elotti pozicio }
  mento := 0;                           { Tenyleg beolv kar. szamlalo }
  Helyy := FileSize(N_Fil)-pozi{-1};      { Beolv hossz meghatarozasa }
  If Helyy>Sor_hossz then Helyy:=sor_hossz;
  {$I-}
  BlockReadPuff(N_Fil,BelSor[1],Helyy);
  {$I+}
  IORES := IOResult;
  If IORES<>0 then Exit;
  *)

  While kar_osszeg < sor_hossz do
    BEGIN
      BlockReadPuff(N_Fil,Kar,1);
      If Kar > #$80 then
        BEGIN
          darab:=Byte(Kar)-$80;
          BlockReadPuff(N_Fil,Kar,1);
          If IORES<>0 then Exit;

          If Kar_Osszeg < c76 Then
          Begin
            Pieces := Darab;
            If Kar_Osszeg + Darab > c76 Then
              Pieces := c76 - Kar_Osszeg;

            If Kar_Osszeg + Pieces <= c76 Then
              FillChar(Pt^.Chars[C80+Kar_osszeg],Pieces,Kar);
          End;
          Inc(kar_osszeg,darab);
        End
      else
        BEGIN
          If (Kar_Osszeg < c76) AND (KellPt) Then
            Pt^.Chars[C80+kar_osszeg] := Kar;
          Inc(kar_osszeg);
        End;
    End;

    (*
    If pozi+mento<FileSize(N_Fil) then
    BEGIN
      {$I-}
      FilePoz := Pozi+Mento;
      Seek(N_Fil,pozi+mento);
      {I+}
      IORES:=IOResult;
    End;
    *)
End;

(*
PROCEDURE RelSorszEll;

BEGIN
  While Rel_sorsz>0 do
    BEGIN
      {$I-}
      BlockReadPuff(N_Fil,Sor_hossz,2);  { lehet 0 is }
      {$I+}
      If IORES<>0 then Exit;
      {$I-}
      BlockReadPuff(N_Fil,Rel_sorsz,2);  { lehet 0 is }
      {$I+}
      If IORES<>0 then Exit;
    End;
End;
*)

Var  K   : Char;
     Boo : Boolean;

{
Procedure Test(B: Byte);
Begin
  If FilePoz > $3310 Then
    Begin
      Write('Sor (',B,') :',Dec_Hex(FilePoz,4));
      If ReadKey = ' ' Then;
    End;
End;
}

BEGIN  { New_Load }
  EmsS := $FFFF;
  Volt_Hiba := False;

  If OutMemory Then Exit;

  If NOT Header_Mode Then
  Begin
    InitLines(EditNum);
    BufPointer := 0;
  End;

  K := Azon[1][1];
  Inc(Byte(K),(C80-80) DIV 16);

  {File-fejlec beolvasasa }

  { eleje[0]:=#4; }
  eleje:=#0'CF'#0;

  While eleje=#0'CF'#0 do
    BEGIN
      BlockReadPuff(N_Fil,eleje[1],4);

      {
      If Header_Mode AND (Eleje[1] <> #00) Then
      Begin
        Insert(#00,Eleje,1);
        Dec(BufPointer);
      End;
      }

      If IORES<>0 then Exit;
    End;

   (*
  WriteLn(Byte(Eleje[1]),' ',Eleje[2],Eleje[3],' ',Byte(Eleje[4]),'    "C".."',K,'"   ');
  If ReadKey = ' ' Then;
   *)

  cikl_v := 2;

  Boo := NOT((Eleje[2] In ['C'.. 'M']) AND (Eleje[3] = 'D'));

  While Boo AND (cikl_v <= 26) do
  BEGIN
    If eleje = (#0+azon[cikl_v]+#0) then Boo := False
                                    Else Inc(cikl_v);
  End;

  (*
  WriteLn(Cikl_V);
  Terminate;
   *)

  If Boo Then
  Begin
    { WriteLn(LST,Byte(Eleje[1]),' ',Eleje[2],Eleje[3],' ',Byte(Eleje[4]),'    "C".."',K,'"   '); }
    Error(24,''); { Nem megfelelî file }
    EndOfHeader := True;
    Exit;
  End;

  BlockReadPuff(N_Fil,fel_sor_darab,2);
  If IORES<>0 then
  Begin
    EndOfHeader := True;
    Exit;
  End;

  If Fel_Sor_Darab > FreeLines Then
  Begin
    OutMemory := True;
    Exit;
  End;

  If Eleje[3] = 'D' Then { Document file }
    BEGIN

      If NOT (Eleje[2] In ['C'.. K]) Then
      Begin
        Hossz := 77 + 16*(Byte(Eleje[2])-Byte('C'));
        Str(Hossz,HosszSt);
        Str(C77,UjHosszSt);
        HosszSt := '  '+HosszSt+' -> '+UjHosszSt;
        Error(55,HosszSt);
      End;

      If EditNum <> 29 Then
      Begin
        BlockReadPuff(N_Fil,LeftMar[EditNum],1);
        If IORES<>0 then Exit;
        BlockReadPuff(N_Fil,RightMar[EditNum],1);
        If IORES<>0 then Exit;

        If RightMar[EditNum] >= C76 Then RightMar[EditNum] := C76-1;

        BlockReadPuff(N_Fil,TabSzam,1);
        If IORES<>0 then Exit;
      End
      Else
      Begin
        BlockReadPuff(N_Fil,Dummy,2);
        If IORES<>0 then Exit;
        BlockReadPuff(N_Fil,TabSzam,1);
        If IORES<>0 then Exit;

        If TabSzam > 0 Then
        Begin
          BlockReadPuff(N_Fil,Dummy,TabSzam);
          If IORES<>0 then Exit;
        End;
        TabSzam := 0;
      End;

      If EditNum=BufferNum then OszlopVolt:=((TabSzam and $80) = $80);
      TabSzam:=TabSzam and $7F;

      If TabSzam > 0 then
      BEGIN

        BlockReadPuff(N_Fil,TabPoz[1],TabSzam);              { Tab poz-ok }
        If IORES <> 0 then Exit;

        For cikl_v:=LeftMar[EditNum] to RightMar[EditNum] do
          Tabs[cikl_v]:=False; { Tab torles }

        For cikl_v:=1 to TabSzam do
        Begin
          If TabPoz[Cikl_V] < RightMar[EditNum] Then
            Tabs[TabPoz[cikl_v]]:=True; { Tab poz tolt }
        End;

      End;

      Make_Tabulators;

      BlockReadPuff(N_Fil,Fontok_szama,1);                { Aktualis fontok szama }
      If IORES<>0 then Exit;

      Font_kiiras:=False;
      For cikl_v:=1 to fontok_szama do
        BEGIN
          BlockReadPuff(N_Fil,Font_Nev[0],1);  { Betoltando fontnev hossz }

          If IORES<>0 then Exit;

          If Byte(Font_Nev[0]) > 0 Then
          Begin
            BlockReadPuff(N_Fil,Font_nev[1],Byte(Font_Nev[0])); { Betoltendo font neve }

            If IORES<>0 then Exit;

            If EditNum <> 29 Then
              If Font_nev <> FontNames[cikl_v] then Load_Font(cikl_v,font_nev);
          End;
        End;
      Font_kiiras:=True;

      BlockReadPuff(N_Fil,header_nev[0],1);             { Header nev hossz }
      If IORES<>0 then Exit;

      If Byte(header_nev[0]) > 0 then
        BEGIN
          BlockReadPuff(N_Fil,Header_nev[1],Byte(header_nev[0]));  { Header nev }
          If IORES<>0 then Exit;
        End;
      If EditNum <> 29 Then HeadFootName:=header_nev;
    End
  else { ha az azonosito nem 00 ?D 00}
    BEGIN
      cikl_v := 2;
      While (eleje<>(#0+azon[cikl_v]+#0)) do Inc(cikl_v);
      EditNum:=cikl_v+1;
      {$IFNDEF CDVIEW}
      FreeEdit(EditNum);
      {$ENDIF}
      New_Kell[EditNum]:=False;
      All_Lines[EditNum]:=0;
    End;


{File-fejlec vege}

  NewHeapLine(Endline[Editnum]+1);
  Heap_Pos(Pt,PointerTomb^[EndLine[Editnum]]);
  EmsS := PointerTomb^[EndLine[Editnum]];
  If OutMemory Then Exit;
  rel_sorsz:=1;
  nincs_also:=False;

  (*
  WriteLn('EditNum = ',EditNum,'  FelsorDb = ',Fel_Sor_Darab);
  If ReadKey = #27 Then Terminate;
  *)

  While (fel_sor_darab)>(EndLine[Editnum]-StartLine[Editnum]) do
    BEGIN
      RosszSzerk:
      If (rel_sorsz>0) or (nincs_also) then
          BlockReadPuff(N_Fil,F_ind_sor,1);    { Sorfejlec azonosito 00 }
      If IORES<>0 then Exit;

      BlockReadPuff(N_Fil,F_ind_sor,2);        { Felso es also ind. sorok szama }
      If IORES<>0 then Exit;

      If (F_ind_sor + a_ind_sor = 0) then
        BEGIN
          F_Ind_Sor := 1;
          rel_sorsz:=1;
          { GoTo RosszSzerk; }
        End;

      Nincs_Also := (A_Ind_Sor = 0);

      { If A_ind_sor=0 then nincs_also:=True else nincs_also:=False; }

  { Felso indexsorok }

      BlockReadPuff(N_Fil,Rel_sorsz,1);      { Az ind. sor soszama }
      If IORES<>0 then Exit;

      While (rel_sorsz>0) Do
        BEGIN
          
          If rel_sorsz>0 then
            BEGIN
              BlockReadPuff(N_Fil,Sor_hossz,2); { Sor hosszanak, lapvegnek betoltese }

              If IORES<>0 then Exit;

              If (Sor_Hossz + Lap_Vege) = 0 Then
                Begin
                  Dec(Fel_Sor_Darab);
                  {Writeln(lst,Filepoz);}
                End
              Else
              Begin

                Pt^.Chars  [C80+c78]:=Char(lap_vege*2);
                Pt^.Attribs[C79]:=rel_sorsz;
                Pt^.Attribs[ 0]:=(128+Lap_vege*64+32) and $E0;

                If sor_hossz>0 then Pt_tolt(Rel_sorsz<=MaxIndex);
                Inc(Lines);
                If Lines MOD 50 = 0 Then WriteLinesPercent(False);

                If Rel_sorsz<=MaxIndex then
                  BEGIN
                    NewHeapLine(Endline[Editnum]+1);
                    If EmsS <> $FFFF Then
                      FreeEms1(EmsS);
                    Heap_Pos(Pt,PointerTomb^[EndLine[Editnum]]);
                    EmsS := PointerTomb^[EndLine[Editnum]];
                  End
                else Dec(Fel_sor_darab);
                If OutMemory Then Exit;

              End; {(Sor_Hossz + Lap_Vege) > 0}

            End;

            BlockReadPuff(N_Fil,Rel_sorsz,1);
            If IORES <> 0 then Exit;

        End;

  { Fîsor }

      (*
      If rel_sorsz>0 then
      Begin
        BlockReadPuff(N_Fil,Rel_sorsz,1);  { muszaj, hogy 00 legyen }
        If IORES<>0 then Exit;
      End;

      If Rel_sorsz>0 then
        BEGIN
          RelSorszEll;
          If IORES<>0 then Exit;
        End;
      *)

      BlockReadPuff(N_Fil,Sor_hossz,2);  { lehet 0 is }

      If IORES<>0 then Exit;

      If Lap_Vege AND 128 = 128 Then
      Begin
        {$IFDEF PROTECT}
        Pt^.Attribs[c77] := Pt^.Attribs[c77] OR Protected;  { Protected }
        {$ENDIF}
        Lap_Vege := Lap_Vege and $7F;
      End;

      Kemeny_sorveg:=Byte(lap_vege and 2>0);
      lap_vege:=lap_vege and 1;

      Inc(All_Lines[EditNum],f_ind_sor);
      Inc(All_Lines[EditNum]);

      Pt^.Chars  [C80+c78]:=Char(lap_vege*2);
      If a_ind_sor <= Maxindex Then
        BEGIN
          Inc(All_Lines[EditNum],a_ind_sor);
          Pt^.Attribs[c78]:=a_ind_sor;
        End
      Else
        BEGIN
          Inc(All_Lines[EditNum],MaxIndex);
          Pt^.Attribs[c78]:= MaxIndex;
          If not Volt_Hiba Then
            Begin
              Volt_Hiba := True;
              ErrorStNum := 2;
              Error(42,'');
              ErrorStNum := 1;
            End
        End;
      If f_ind_sor <= Maxindex Then
        BEGIN
          Inc(All_Lines[EditNum],f_ind_sor);
          Pt^.Attribs[C79]:=f_ind_sor;
        End
      Else
        BEGIN
          Inc(All_Lines[EditNum],MaxIndex);
          Pt^.Attribs[C79]:= MaxIndex;
          If not Volt_Hiba Then
            Begin
              Volt_Hiba := True;
              ErrorStNum := 2;
              Error(42,'');
              ErrorStNum := 1
            End
        End;

      Pt^.Attribs[ 0]:=Kemeny_sorveg*128+Lap_vege*64+Byte(sor_hossz>0)*32+16;

      If sor_hossz>0 then Pt_tolt(True);
      Inc(Lines);
      If Lines MOD 50 = 0 Then WriteLinesPercent(False);

      If (fel_sor_darab-1)>=(EndLine[Editnum]-StartLine[EditNum]) then
        BEGIN
          NewHeapLine(Endline[Editnum]+1);
          If EmsS <> $FFFF Then
            FreeEms1(EmsS);
          Heap_Pos(Pt,PointerTomb^[EndLine[Editnum]]);
          EmsS := PointerTomb^[EndLine[Editnum]];
        End;
      If OutMemory Then Exit;

  { Also indexsorok }

      If not nincs_also then
        BEGIN

          If ((fel_sor_darab-1)>=EndLine[Editnum]-StartLine[EditNum]) then
          Begin
            BlockReadPuff(N_Fil,Rel_sorsz,1);
            If IORES <> 0 Then Exit;
          End;

          While (rel_sorsz > 0) and
                (fel_sor_darab-1 >= EndLine[Editnum]-StartLine[EditNum]) do
            BEGIN

              If rel_sorsz>0 then
                BEGIN
                  BlockReadPuff(N_Fil,Sor_hossz,2);

                  If IORES<>0 then Exit;

                  If (Sor_Hossz + Lap_Vege) = 0 Then
                    Begin
                      Dec(Fel_Sor_Darab);
                      {Writeln(lst,'Hiba :',FilePoz);}
                    End
                  Else
                  Begin

                    Pt^.Chars  [C80+c78]:=Char(lap_vege*2);
                    Pt^.Attribs[ 0]:=(Lap_vege*64+32) and $60;
                    Pt^.Attribs[c79]:=rel_sorsz;

                    If sor_hossz>0 then Pt_tolt(Rel_sorsz<=MaxIndex);
                    Inc(Lines);
                    If Lines MOD 50 = 0 Then WriteLinesPercent(False);

                    If ((fel_sor_darab-1)>=(EndLine[Editnum]-StartLine[EditNum])) then
                      If (Rel_sorsz<=MaxIndex) then
                        BEGIN
                          NewHeapLine(Endline[Editnum]+1);
                          If EmsS <> $FFFF Then
                            FreeEms1(EmsS);
                          Heap_Pos(Pt,PointerTomb^[EndLine[Editnum]]);
                          EmsS := PointerTomb^[EndLine[Editnum]];
                        End
                      else Dec(Fel_sor_darab);
                    If OutMemory Then Exit;

                  End; {(Sor_Hossz + Lap_Vege) > 0 }

                End;

                If (fel_sor_darab-1 >= EndLine[Editnum]-StartLine[EditNum])
                Then
                Begin
                  BlockReadPuff(N_Fil,Rel_sorsz,1);
                  If IORES<>0 then Exit;
                End;

            End;
        End
        else nincs_also:=True;

    End;  { While (fel_sor_darab-1)>=(EndLine.... }

  If EmsS <> $FFFF Then
    FreeEms1(EmsS);

  DelHeapLine(EndLine[Editnum]);
  {Heap_Pos(Pt,PointerTomb^[EndLine[Editnum]]);}

  End_of_File:=True;


  If eleje[3] <> 'D' then { FeljÇc file }
    BEGIN
      If StartLine[EditNum] <= EndLine[EditNum] Then
        SeekToFirstLine;

      EndOfHeader := EOF(N_Fil) And (BufPointer >= Pufferben);
                                           {(FilePoz  >= FSize)};

      (* Seek(N_Fil,FilePos(N_Fil)+1);
         If not Eof(N_Fil) then Seek(N_Fil,FilePos(N_Fil)-1); *)
    End;

  (*
  WriteLn('Fsize = ',FSize,'  FilePoz = ',FilePoz,'  ',Byte(Eleje[1]),' ',Eleje[2],Eleje[3],' ',Byte(Eleje[4]));
  If ReadKey = #27 Then Terminate;
   *)

  Kodolatlan[EditNum] := Not(KodoltFile);
  If KodoltFile Then JelszValt[EditNum] := False;

End;  { New_Load }

{
Procedure DebugWindow;
Var Ch : Char;
Begin
  bool:=Create_Window(2,8,40,13,'Memory status',CA[DispMode,4],CA[DispMode,5]);
  Writeln;
  WriteLn(' Max_Lines : ',Max_Lines);
  WriteLn(' Full_Lines: ',Full_Lines);
  WriteLn(' Free      : ',Max_Lines-Full_Lines);
  REPEAT
    ch:= ReadKey;
  UNTIL ch = #27;

  bool:=Remove_Window;

End;
}

VAR EditMem : byte;

BEGIN  { Procedure Load_File }
  BufferP    := @Buffer;
  BufPointer := 0;

  EditMem:=EditNum;
  If (Filetip=ASCII) or ((Filetip=Document) and (Kor<>uj_header)) then
    BEGIN
      {$IFNDEF CDVIEW}
      FreeEdit(Editnum);
      {$ENDIF}
      If AktBejovo_ReadOnly then ReadOnlyT[Editnum]:=True
      else ReadOnlyT[EditNum]:=False;
      New_kell[Editnum] := False;
      All_Lines[EditNum]:= 0;
      Fpt      := Nil;
      PrevFont := 1;
      Gfont[0] := 1;
      Gfont[1] := 1;
      Adist    := 0;
      Fdist    := 0;
      Alsok    := 0;  {1}
      Felsok   := 0;  {0}
      Soft     := False;
      End_of_file := False;
      ElsoSor  := True;
    End;
  EditNum:=EditMem;
  IORES := 0;

  InitLines(EditNum);

  { DebugWindow; }

  case Filetip of
    Document : case Kor of
                 regi_szerk : BEGIN
                                While (Not Outmemory) And
                                          (IORES = 0) And
                                    (Not End_of_file) And
                                        (Not(EofM(Fil)) ) Do
                                Begin
                                  Read_And_ConvertLine;
                                  If NOT(ModemMode) AND (Lines MOD 50 = 0) Then
                                    WriteLinesPercent(False);
                                End;
                              End;
                 uj_szerk : BEGIN
                              New_Load;
                            End;
                 uj_header: BEGIN
                              EndOfHeader := False;
                              InitLines(EditNum);
                              BufPointer := 0;
                              Header_Mode := True;
                              While Not(EndOfHeader) and (IORES = 0) AND
                                    Not(OutMemory) do New_Load;
                              Header_Mode := False;
                            End;
               End;
    ASCII    : While (Not Outmemory) And
                         (IORES = 0) And
                    (Not(EofM(Fil))) Do
                  Begin
                    Read_ASCII_And_Convertline;
                    If Lines MOD 50 = 0 Then WriteLinesPercent(False);
                  End;
  End;

  ASCIIVolt[EditNum] := (FileTip = ASCII);

  { DebugWindow; }

  If (Kor <> Regi_Szerk) OR (NOT ModemMode) Then WriteLinesPercent(False);

  If Outmemory Or (IORES <> 0) Then
  BEGIN
    If Outmemory Then Error(4,InpSt3)
    Else If Not ModemMode Then Error(6,'');
    {$IFNDEF ROSSZFILE}
    {$IFNDEF CDVIEW}
    FreeEdit(Editnum);
    {$ENDIF}
    {$ENDIF}
  End;

  If (not (Outmemory Or (IORES <> 0))) or
     ((Filetip=ASCII) or ((Filetip=Document) and (Kor<>uj_header))) then
      BEGIN
        If StartLine[EditNum] <= EndLine[EditNum] Then
          SeekToFirstLine;
      End;
  IORES:=0;
End; {Procedure Load_File}


Procedure Load; {(VAR Filename:FnTyp; Filetip : Filetype; LoadMode : Loadtype);}

LABEL kiszallo;

VAR Fil                   : Text;
    N_Fil                 : file;
    Age_Of_File           : age;
    Number                : Byte;
    Header,OfileName,Fnev : FnTyp;
    DM                    : String[40];
    Ext                   : String[4];
    Lin                   : String;
    Kell,Jofile,Kilep     : Boolean;
    Kilepett,Kesz,
    Mehet,
    Escap                 : Boolean;
    TempEditNum           : Byte;
    elozoovr              : boolean;
    Mem_num               : longint;
    Buffer                : Array[1..4096] Of Byte;

PROCEDURE Choice_File_Age;

VAR valaszt : string[4];
    ioe     : integer;
    M_Fil   : file;
    Buffer  : Bufft;

PROCEDURE Unknown_File_Type;

VAR ch : char;
    A,B : Byte;

BEGIN  { Unknown_File_Type }


  IF Not(KodoltFile) Then
    Begin
      bool:=Create_Window(2,10,34,13,LoadError,CA[DispMode,4],CA[DispMode,5]);
      WriteLn(IsmeretlenFile);
      Write  (Betoltsem);

      Speak(132);

      {$IFDEF OROSZ}
      Write('Ñ/ç)');
      {$ELSE}
      Write(YesChar,'/',NoChar,')');
      {$ENDIF}

      REPEAT
        ch:=UpCase(ReadKey);
      UNTIL ch in [YesChar,NoChar,#27];

      Remove_Window;

    End
  Else
    Begin
      bool:=Create_Window(2,10,34,14,LoadError,CA[DispMode,4],CA[DispMode,5]);
      WriteLn('         Hib†s jelsz¢.');
      WriteLn(' KÇrem Åssîn egy billentyñt ! ');
      {$IFNDEF CDVIEW}
      Write(  '      Uj jelsz¢ : CTRL-F10 ');
      {$ENDIF}
      GGFN := ' - '+Csak12(Fnev);
      Puffi(A,B);
      GGFN := '';
      Ch := NoChar;
      Remove_Window;
    End;

  If NOT UjraProbal Then
  Begin

    If ch <> YesChar
     then
      BEGIN
        Kilepett:=True;
        Exit;
      End;

    bool:=Create_Window(20,15,54,18,FileFormat,CA[DispMode,2],CA[DispMode,12]);
    WriteLn(ASCII_Vagy_EkSzer);
    Write  (OlvassamBe);

    Speak(133);

    Write(AsciiChar,'/',EkszerChar,')');
    REPEAT
      ch:=UpCase(ReadKey);
    UNTIL ch in [AsciiChar,EkszerChar,#27];
    If ch=#27 then
      BEGIN
        bool:=Remove_window;
        Kilepett:=True;
        Exit;
      End;
    If Ch = AsciiChar Then
      BEGIN
        WordStarMode(False);
        Filetip:= ASCII;
      End
    else Filetip:=Document;
    Age_Of_File := Regi_Szerk;
    bool:=Remove_Window;

  End; { If NOT UjraProbal }

End;

Const Azonosito : String[4] = #00'CD'#00;

BEGIN  { Choice_File_Age }
  BufferP := @Buffer;
  BufPointer := 0;
  KodoltFile := False;

  Assign(M_Fil,Fnev);
  {$I-}
  ReSet(M_Fil,1);
  {$I+}
  IORES:=IOResult;
  If IORES<>0 then Exit;

  FSize := FileSize(M_Fil);

  {$IFDEF SECRET}
  If Fsize > 3 Then
    Begin
      {$I-}
      BlockRead(M_fil,Buffer,3);
      KodoltFile := (Buffer[1] = KodAzon[1]) And
                    (Buffer[2] = KodAzon[2]) And
                    (Buffer[3] = KodAzon[3]);
      Seek(M_Fil,0);
      Dec(Fsize,3);
      {$I+}
    End;

  If Not(VanJelszo) And KellJelszo And KodoltFile Then
    InputJelszo(False,True,' - '+Csak12(Fnev));

{$ENDIF}

  valaszt[0]:=#4;

  Repeat

    UjraProbal := False;

    {$I-}
    {$IFDEF SECRET}
    If VanJelszo And KellJelszo And KodoltFile Then
      BlockReadPuff(M_Fil,valaszt[1],4)
    Else
    {$ENDIF}
      BlockRead(M_Fil,valaszt[1],4);
    {$I+}
    BufPointer := 0;

    IORES:=IOResult;
    If IORES<>0 then Exit;
    If FileTip<>ASCII then
    case valaszt[1] of
      #0 : BEGIN
             If NOT((Valaszt[2] In [Azonosito[2]..Char(Byte(Azonosito[2])+10)]) AND
                    (Valaszt[3] = azonosito[3]) AND
                    (Valaszt[4] = azonosito[4])) and
              (valaszt<>#0+'CF'+#0) then
               BEGIN
                 Unknown_File_Type;
                 If Kilepett then Exit;
                 FileTip:=Ascii;
               End
             else
               BEGIN
                 FileTip:=Document;
                 If (valaszt=#0+'CF'+#0) then Age_of_file := uj_Header
                                         else Age_of_file := uj_Szerk;
               End;
           End;
      ^Q : BEGIN
             Age_of_file := regi_szerk;
             Filetip:=Document;
           End;
      'S': If valaszt[2]='Y' then
             BEGIN
               Age_of_file := regi_szerk;
               Filetip:=Document;
             End
           else
             BEGIN
               Unknown_File_Type;
               If Kilepett then Exit;
             End;
      '\': If valaszt='\1cw' then
             BEGIN
               Age_of_file := regi_szerk;
               Filetip:=Document;
               Chi25:=True;
             End
           else
             BEGIN
               Unknown_File_Type;
               If Kilepett then Exit;
             End;
      else
        BEGIN
          Unknown_File_Type;
          If Kilepett then Exit;
        End;
      End; { CASE }

    If UjraProbal Then Seek(M_Fil,0);

  Until NOT UjraProbal;

  Close(M_Fil);
End;  { Choice_File_Age }

PROCEDURE Fejlec_elokeszites;

BEGIN
  If (Header_nev<>'') and (not(ModemMode)) then
    BEGIN
      Close(N_Fil);
      CloseM(Fil);
      Fnev:=Header_nev;
      Choice_File_Age;
      If IORES<>0 then Exit;
      Assign(N_Fil,Fnev);
      ReSet(N_Fil,1);
      AssignM(Fil,Fnev);
      SetTextBuf(Fil,Buffer);
      {$i-} ResetM(Fil); {$i+}
    End;
End;

PROCEDURE ReadOnlyE;

VAR sr    : SearchRec;

BEGIN
  FindFirst(FileName,Archive,sr);
  IORES := DosError;
  If sr.Attr and 1 = 1 then
    BEGIN
      Assign(n_fil,Fnev);
      SetFAttr(N_fil,sr.Attr and 254);
      AktBejovo_ReadOnly:=True;
    End
  else AktBejovo_ReadOnly:=False;
End;

PROCEDURE VisszaReadOnly;

VAR sr : SearchRec;
    rs : file;

BEGIN
  If AktBejovo_ReadOnly then
    BEGIN
      FindFirst(FileName,Archive,sr);
      Assign(rs,Fnev);
      SetFAttr(N_fil,sr.Attr or 1);
      AktBejovo_ReadOnly:=False;
    End;
End;


VAR o_u    : string;
    ChiNum : Byte;

BEGIN  { Load }

  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}

{$IFDEF BEMUTAT}
  If Not(ErvenyesIdoszak) Then
    FileName := PathSt+igekotok[1][2]+  { E    }
                       igekotok[8]+     { KI   }
                       igekotok[11,4]+  { N    }
                       igekotok[3,1]+   { F    }
                       '.'+
                       Dmask;           { DOC  }
{$ENDIF}

  Chi25 := False;

  IORES := 0;

  ModemMode := False;
  ESC := False;
  OfileName := FileName;

If LoadMode <> NoWriteMode Then
BEGIN

  If LoadMode = OneFileMode
  Then
  BEGIN
    Case Filetip Of

      Document : Begin
                   Header := DocuSt;
                   Ext := '.'+DMask;
                 End;
      ASCII    : Begin
                   If WsFileMode
                   Then
                     Header := WordStarSt
                   Else
                     Header := ASCIISt;

                   Ext := '.'+AsciiMask;
                 End;

    End  {Case}
  End
    Else

    If LoadMode In [AllHeaderMode,NoWriteAllHeaderMode] Then
    BEGIN
      Header := InpSt4;
      Ext    := FMask;
    End;

      {$IFDEF NORVEG}
      Header := InpSt5 + Header;
      {$ELSE}
        {$IFDEF ANGOL}
        Header := InpSt5 + Header;
        {$ELSE}
        Header := Header + InpSt5;
        {$ENDIF}
      {$ENDIF}

      If LoadMode <> NoWriteAllHeaderMode Then
        BOOL := CREATE_WINDOW(1,5,80,11,Header,CA[DispMode,1],CA[DispMode,3])
      Else WriteLn(Header);

End;

If LoadMode In [NoWriteMode,NoWriteAllHeaderMode] Then Kilepett := False;

Repeat

  {$IFNDEF CDVIEW}
  If Not (LoadMode In [NoWriteMode,NoWriteAllHeaderMode]) Then
  BEGIN
      MaxStringLen := FnSize;
      If FileName = UresName Then
        FileName := '';
      Input_FileName(Enter_fn,Filename,64,False);
      Kilepett := Esc;
      UpperCase(FileName);

{$IFDEF BEMUTAT}
  If Not(ErvenyesIdoszak) Then
    FileName := PathSt+igekotok[1][2]+  { E    }
                       igekotok[8]+     { KI   }
                       igekotok[11,4]+  { N    }
                       igekotok[3,1]+   { F    }
                       '.'+
                       Dmask;           { DOC  }
{$ENDIF}


      ModemMode := FileName = 'XMODEM';

      If FileName <> '' Then CheckFileName(FileName);
      CurOff;
      Kilepett := Kilepett Or Esc;
      Esc := Kilepett;
      Kesz := False;

      If LoadMode In [AllHeaderMode,NoWriteAllHeaderMode] Then DM := '*'+FMask
        Else DM := '*'+Ext;

      If Pos('*',Filename) Or Pos('?',Filename) <> 0 Then
      BEGIN
        If Pos('.',filename)=0 then DM:=FileName+Ext
        else DM := Filename;
        Filename := '';
      End
      Else If FileName[Length(FileName)] In [':','\'] Then
      Begin
        DM := FileName + DM;
        FileName := '';
      End;
  End;
  {$ENDIF CDVIEW}

If NOT Esc Then
  BEGIN

    If Not (LoadMode In [NoWriteMode,NoWriteAllHeaderMode]) Then
      If Filename = '' Then
        BEGIN
          {$IFNDEF CDVIEW}
          Select_File(DM,Filename,1);
          {$ENDIF}
        End
      Else
        If (Not ModemMode) And (Pos('.',Filename)=0) Then Filename:=FileName+Ext;

      Escap := Esc;
      CheckRead(FileName);
      Esc := Escap OR Esc;

      If NOT ESC Then
      BEGIN

        TempEditNum := EditNum;
        Fnev        := FileName;

        If (LoadMode = OneFileMode) And (FileName[2] = ':') Then
        BEGIN
          TempEditNum := Byte(FileName[1])-Byte('0');
          If TempEditNum In [1..3] Then
          BEGIN
            Delete(FileName,1,2);
            Fnev := FileName;
            GFileName[TempEditNum] := FileName;
            FileName  := OFileName;
            EditNum := TempEditNum;     { Ebbe tolti be }
            TempEditNum := GeditNum;    { A GeditNum elmentese  }
            GeditNum := EditNum;        { A Fresh_Info-hoz kell }
          End
          Else TempEditNum := EditNum;

        End;

        If IORES = 0 Then
          Begin
            If NOT ModemMode Then
            Begin
              ReadOnlyE;
              If IORES = 0 Then
                Begin
                  {$IFNDEF CDVIEW}
                  If (AktBejovo_ReadOnly And (EditNum <> 29)) then
                    Error(41,Fnev);
                  {$ENDIF}
                  Choice_File_Age;
                End;
            End
            else Age_of_file := regi_szerk;

            If kilepett then GoTo kiszallo;
          End;

        If IORES=0 then
          BEGIN

            If Not ModemMode then
              BEGIN
                Assign(N_Fil,Fnev);
                ReSet(N_Fil,1);
              End;

            AssignM(Fil,Fnev);
            SetTextBuf(Fil,Buffer);
            {$i-} ResetM(Fil); {$i+}
          End;

        If (IOresultM <> 0) or (IORES<>0) Then
          BEGIN
            If Not ModemMode Then Error(1,Csak12(Filename));
            Kilepett := True;
          End
        Else
        BEGIN

          Mehet := (Not(Valtozas[EditNum]));

          If LoadMode = AllHeaderMode Then
          Begin
            X:=4;
            While (X<=MaxEditor-2) and (not Valtozas[X]) Do Inc(X);
            Number:= X;
            Mehet := (X > MaxEditor-2);
          End
          Else Number := EditNum;

          If Mehet OR Are_You_Sure(Number,Single) Then
          BEGIN

            GlobalMode := LoadMode;

            If (Not (LoadMode In [NoWriteMode,NoWriteAllHeaderMode])) And
               (Not ModemMode) Then
            BEGIN
              ClrScr;
              GotoXY(40-((Length(FileName)+20) DIV 2),2);

              {$IFDEF NORVEG}
              Write(InpSt5+Csak12(Fnev));
              Write('  ',Texts[6],'  ');
              {$ELSE}
                {$IFDEF ANGOL}
                Write(InpSt5+Csak12(Fnev));
                Write('  ',Texts[6],'  ');
                {$ELSE}
                Write(Csak12(Fnev)+InpSt5);
                Write('  ',Texts[6],'  ');
                {$ENDIF}
              {$ENDIF}

              ATTRIBUTE(9,3,9,78,CA[DispMode,1]);

              {$IFNDEF CDVIEW}
              Fresh_Info;
              {$ENDIF}

            End;
{
            else
              BEGIN
                If CrtMode = 6 Then
                  BEGIN
                    Fresh_Header;
                    Fresh_Def;
                  End;
              End;
}

            Header_nev:='';
            If Not (LoadMode In [AllHeaderMode,NoWriteAllHeaderMode]) Then
              BEGIN
                If Chi25 Then
                Begin

                  FillChar(UsedFont,MaxFontNum,Byte(False));

                  REPEAT

                    ReadLn(Fil,Lin);
                    UpperCase(Lin);

                    Inc(FilePoz,Length(Lin)+2);

                    If VoltChiIn AND (Copy(Lin,1,2) = '\U') Then
                    Begin
                      ChiNum := 1;
                      Case Lin[3] Of
                        '1'..'9' : ChiNum := BYTE(Lin[3]) - 48; {01..09}
                        '0'      : ChiNum := 10;
                        '!'..'*' : ChiNum := BYTE(Lin[3]) - 22; {11..20}
                      End; {Case}

                      Delete(Lin,1,3);
                      While (Lin[Length(Lin)] = ' ') Do Dec(Byte(Lin[0]));
                      Cik := 1;

                      While (Cik <= MaxChiFont) AND
                            (Lin <> ChiFont[Cik]) Do Inc(Cik);

                      If Cik <= MaxChiFont Then Lin := EkSzFont[Cik];

                      Cik := 1;
                      While (Cik <= MaxFontNum) AND
                            (Lin <> FontNames[Cik]) Do Inc(Cik);

                      If Cik > MaxFontNum Then
                      Begin
                        LoadedChiFont := 3;

                        While (UsedFont[LoadedChiFont]) AND
                              (LoadedChiFont <= MaxFontNum) Do
                        Inc(LoadedChiFont);

                        If LoadedChiFont <= MaxFontNum Then
                        Begin
                          Font_Kiiras := False;
                          Load_Font(LoadedChiFont,Lin);
                          Font_Kiiras := True;
                          If NOT ESC Then
                          Begin
                            ChiFonts[ChiNum] := LoadedChiFont;
                            UsedFont[LoadedChiFont] := True;
                            Inc(LoadedChiFont);
                          End;
                        End;

                      End
                      Else
                      Begin
                        ChiFonts[ChiNum] := Cik;
                        UsedFont[Cik] := True;
                      End;

                    End;

                  UNTIL Lin='\=';

                  {
                  For Cik := 1 To 20 Do Write(ChiFonts[Cik]:3);
                  If ReadKey = ' ' Then;
                  }

                End;

                If EOF(Fil) Then Reset(Fil);

                Load_File(Fil,N_Fil,Filetip,Age_of_file);
              End;

{ Headerfile betoltese }
            If ((LoadMode In [AllHeaderMode,NoWriteAllHeaderMode]) or
            (Header_nev<>'')) and (not ModemMode) then
               BEGIN
                 Fejlec_elokeszites;

                 If (IORES<>0) or (Chi25) then
                   BEGIN
                   {  If IORES<>0 then Error(IORES,'')
                     else Error(31,'');  hÅlyesÇg !!! }
                   End
                 else { -1- }
                   BEGIN
                     {IORES:=0;}

                     {$IFNDEF CDVIEW}
                     For X:=4 to 27 do FreeEdit(X);
                     {$ENDIF}

                     If (ModemMode) or (Age_of_file=uj_header) then
                       BEGIN
                         Load_File(Fil,N_Fil,Filetip,Age_of_file);
                       End
                     else
                       BEGIN
                         Jofile := False;
                         Kilep  := False;
                         While (Not Outmemory) And
                               (Not EofM(Fil)) And
                               (Not Kilep)     And
                               (IORES = 0)     Do
                         BEGIN
                           ReadlnM(Fil,Lin);
                           IORES := IOResultM;

                           If IORES = 0 Then
                           BEGIN
                             If Copy(Lin,1,2) = HeaderID Then Jofile := True;
                             Kell:= False;

                             If Lin <> '' Then
                               If Lin[1] = 'H'
                               Then
                               BEGIN
                                 Kell := True;
                                 Case Lin[2] Of

                                    'A'      : EditNum := 4;
                                    'E'      : EditNum := 5;
                                    'O'      : EditNum := 6;
                                    '1'..'9' : EditNum := Byte(Lin[2])-48+6;
                                    Else       Kell := False;

                                 End;
                               End
                               Else
                               If Lin[1] = 'O'
                               Then
                               BEGIN
                                 Kell := True;
                                 Case Lin[2] Of

                                    'A'      : EditNum := 16;
                                    'E'      : EditNum := 17;
                                    'O'      : EditNum := 18;
                                    '1'..'9' : EditNum := Byte(Lin[2])-48+18;
                                    Else       Kell := False;

                                 End;  {Case}
                               End;  {If Lin[1] = 'O'}

                             If Kell Then If Jofile Then
                             BEGIN
                               Load_File(Fil,N_Fil,Document,Age_Of_File);
                               { If LoadMode = AllHeaderMode Then Fresh_Info; }
                             End
                             Else
                             BEGIN
                               Error(14,Csak12(FileName));   { Nem jo fejlec file }
                               Jofile := True;
                               Kilep  := True;
                               Filename := OfileName;
                             End;
                           End; {If IORES = 0}
                         End;  {While not (EOF) And Not(OutMemory) And Not(Kilep) }

                         If Not Jofile Then
                         BEGIN
                           Error(14,Csak12(FileName));     { Nem jo fejlec file }
                           Filename := OfileName;
                         End;
                       End;
                   End { else ag -1-}
               End;   {If AllHeaderMode Or NoWriteAllHeaderMode}

             If Not(LoadMode In[NoWriteMode,NoWriteAllHeaderMode,AllHeaderMode])

             Then
               If EditNum <> TempEditNum Then
                BEGIN
                  GeditNum := TempEditNum;
                  {$IFNDEF CDVIEW}
                  Fresh_Info;
                  {$ENDIF}
                End;

             {If (IORES <> 0) And (Not ModemMode) Then Error(6,'');}

             If IORES=0 then
               BEGIN
                 CloseM(Fil);
                 If not ModemMode then Close(N_Fil);
               End;
             Valtozas[EditNum] := False;
             Kesz := True;

          End  { If Not(Valtozas[EditNum]) Or Are_You_Sure }

          Else BEGIN
                 Kilepett := True;
                 FileName := OfileName;
               End;

        End; { If IOresult = 0}

      End; {If NOT Esc}

    End; {If NOT Esc}
Kiszallo:
  Until Kilepett Or Kesz;

  { !!!! ChangeToNoname(EditNum); !!!! }

  If ModemMode or kilepett Then FileName := OFileName;

  If Not (LoadMode In [NoWriteMode,NoWriteAllHeaderMode])
   Then BEGIN
          Bool := Remove_Window;
          {$IFNDEF CDVIEW}
          Fresh_Info;
          {$ENDIF}
        End;

  WordStarMode(True);

  VisszaReadOnly;

  GlobalMode := OneFileMode;

End;  {Procedure Load}


Procedure Read_Deffile {(VAR Parame : Boolean)};

Type FontRec = Record
                 Num  : Byte;
                 Name : String[16];
               End;

VAR  FontCount : Byte;
     ParamStringPtr : Pointer;
     FontTomb  : Array[1..16] Of FontRec;
     X,Par  : BYTE;
     Ws     : String[2];
     OldPath,
     Param  : String[64];
     Cikl   : Integer;
     Cik    : Byte;
     elozoovr     : boolean;

Function Value(St : String): Integer;

VAR S     : String[4] absolute St;
    X,RES : INTEGER;

BEGIN

   Val(S,X,RES);
   If Res = 0 Then Value := X
              Else Value := 0;
End;

Function Param_Str(N:Integer):String;
VAR Lp : Byte;
    S  : String;
BEGIN
    S := Sor;
    While N > 0 Do
    BEGIN
      While S[1] = ' ' Do Delete(S,1,1);
      Dec(N);
      If N > 0 Then Delete(S,1,Pos(' ',S)-1);
    End;
    Lp := Pos(' ',S);
    If Lp = 0 Then Lp := 255;
    Param_Str := Copy(S,1,Lp-1);
End;

Function Param_Count:Integer;
VAR Lp,N : Byte;
    S    : String;
BEGIN
    N := 255;
    S := Sor;
    While (N > 0) And (S <> '') Do
    BEGIN
      While (S[1] = ' ') And Boolean(S[0]) Do Delete(S,1,1);
      If Boolean(s[0]) Then
        Dec(N);
      Lp := Pos(' ',S);
      If Lp = 0 Then
        S := ''
      Else
        If N > 0 Then
          Delete(S,1,Lp-1);
    End;
    Param_Count := 255-N;
End;


VAR E : Integer;

BEGIN
  FontCount := 0;

  ParamStringPtr := Ptr(PrefixSeg,$80);  { Clearing parameterline }
  FillChar(ParamStringPtr^,$80,00);

  Assign(Textfile,Deffile);
  {$i-} Reset(Textfile); {$i+}

  E := 1;

  Parame := (IoResult = 0);
  If Parame Then
    BEGIN
      Readln(TextFile,Sor);
      UpperCase(Sor);
      Parame := (Copy(Sor,1,2) = 'PL');
      E := 24;
      Reset(TextFile)
    End;

  If Not Parame Then Error(E,Csak12(DefFile))
  Else
  BEGIN

      {$IFDEF NORVEG}
        Writeln(Deffile);
      {$ELSE}
        {$IFDEF ANGOL}
          Writeln(IneSt15,Deffile);
        {$ELSE}
          Writeln(Deffile,IneSt15);
        {$ENDIF}
      {$ENDIF}

    For X := 1 To MaxEditor Do Fontnum[X] := 2;

    While not EOF(Textfile) do
    BEGIN
      Readln(Textfile,Sor);
      If (Sor <> '') And (Param_Count > 1) Then
      BEGIN
        Ws    := Param_Str(1);
        Ws[1] := Upcase(Ws[1]);
        Ws[2] := Upcase(Ws[2]);
        Par   := 00;
        X     := 1;

        While (Par = 00) And (X <= MaxParameters) Do
        BEGIN
          If Ws = Param_tomb[X] then Par := X;
          Inc(X);
        End;

        If Par > 0 Then
        BEGIN

          Param := Param_Str(2);

          If Par IN [1..MaxFontNum] then
          BEGIN
            Inc(FontCount);
            FontTomb[FontCount].Num  := Par;
            FontTomb[FontCount].Name := Param_Str(2);
          End

          Else
          Case Par of

             11+6 : Pagelen     := Value(Param);

             12+6 : For X := 2 to Param_Count Do
                      If Value(Param_Str(X)) < C76 Then
                         Rightmar[X-1] := Value(Param_Str(X))
                       Else
                         RightMar[X-1] := C76;

             13+6 : Printmargin := Value(Param);
             14+6 : Inser       := Boolean(Value(Param));
             15+6 : Just        := Boolean(Value(Param));
             16+6 : Sync        := Boolean(Value(Param));
             17+6 : LineSpace   := Value(Param);
             18+6 : Linespacing := Value(Param);
             19+6 : BackupTime  := Value(Param);
             20+6 : Begin
                    OldPath := Path;
                    Path    := Param;
                    If Path <> OldPath Then
                      Begin
                        {$I-}
                        ChDir(Path);
                        {$I+}
                        If IOresult <> 0 Then
                          Begin
                            Error(2,Path);
                            Path := OldPath;
                            {$I-}
                            Chdir(OldPath);
                            {$I+}
                            If IOResult <> 0 Then;
                          End;
                      End
                  End;

             21+6 : For X := 2 to Param_Count Do
                      If Value(Param_Str(X))-1 < C76 Then
                        Tabs[Value(Param_Str(X))-1] := True;

             22+6 : For X := 2 to Param_Count Do
                      Leftmar[X-1] := Value(Param_Str(X));

             23+6 : FirstPage   := Value(Param);
             24+6 : LastPage    := Value(Param);
             25+6 : StopAfterPage:= Boolean(Value(Param));
             26+6 : FirstPageNum:= Value(Param);
             27+6 : For X := 2 to Param_Count Do Color[X-1] := Value(Param_Str(X));
             28+6 : WsMode := Boolean(Value(Param));
             29+6 : For X := 2 to Param_Count Do
                    If Not PFname[X-1] Then
                      Filename[X-1] := Param_Str(X);
             30+6 : Begin
                      FontPath := Param;
                    End;
             31+6 : DispMode := DispType(Value(Param));
             32+6 : DMask    := Param;
             33+6 : Begin
                      Paralell_Device := Value(Param);
                      Ppar := Ppar_Tomb[Paralell_Device+1];
                      PsFile[True] := Ppar_Nev[Paralell_Device+1];
                    End;
             34+6 : Serial_Device   := Value(Param);
             35+6 : IroIdo := Value(Param);
             {$IFNDEF CDVIEW}
             36+6 : BEGIN
                      HeadFootName := Param;
                      If Path <> '' Then
                      Begin
                        If Path[Length(Path)] <> '\' Then
                          HeadFootName := '\'+ HeadFootName;
                        HeadFootName := Path + HeadFootName;
                      End;
                      Load(HeadFootName,Document,NoWriteAllHeaderMode);
                    End;
             {$ENDIF}
             37+6 : For X := 2 to Param_Count Do
                    BackG[X-1] := Value(Param_Str(X));
             38+6 : For X := 2 to Param_Count Do
                    FontNum[X-1] := Value(Param_Str(X));
             39+6 : CYZ := Boolean(Value(Param));
             {$IFNDEF CDVIEW}
             40+6 : BEGIN
                      MacFile := Param;
                      If Path <> '' Then
                      Begin
                        If Path[Length(Path)] <> '\' Then
                          MacFile := '\'+ MacFile;
                        MacFile := Path + MacFile;
                      End;
                      Load_Macros(True); {AutoLoad}
                    End;
             {$ENDIF}
             41+6 : Max_Key := Value(Param);
             42+6 : For X := 2 to Param_Count Do
                      CA[Colour,X-1] := Value(Param_Str(X));
             43+6 : For X := 2 to Param_Count Do
                      CA[BW,X-1] := Value(Param_Str(X));

             {$IFNDEF CDVIEW}
             {$IFNDEF ANGOL}
             44+6 : Elvalaszt    := Boolean(Value(Param));
             {$ELSE}
             44+6 : Elvalaszt    := False;
             {$ENDIF}
             {$ENDIF}

             45+6 : KellLapdob   := Boolean(Value(Param));
             46+6 : PublPrint    := Boolean(Value(Param));
             47+6 : Lapszamoz    := Boolean(Value(Param));

             48+6 : Begin
                      If Param <> '' Then Val(Param,LabelDist,E);
                      If E <> 0 Then LabelDist := 1.00;
                    End;

            {$IFDEF LICENC}
             49+6 : Begin
                      If Param <> '' Then Val(Param,EmblemaMod,E);
                      If (E <> 0) Or NOT(EmblemaMod In [0..4])
                        Then EmblemaMod := 1;
                    End;
            {$ENDIF}

            56 : Tizedesek := Value(Param);
            57 : Format    := Value(Param);

            58 : Begin
                   GSzammal   := Copy(Sor,4,255);
                   Szammal    := GSzammal;
                   For Cik := 1 To Length(Szammal) Do
                     If Byte(Szammal[Cik]) >= 128 Then ASC_Eksz(Szammal[Cik]);
                 End;

            59 : Begin
                   GBetuvel   := Copy(Sor,4,255);
                   Betuvel    := GBetuvel;
                   For Cik := 1 To Length(Betuvel) Do
                     If Byte(Betuvel[Cik]) >= 128 Then ASC_Eksz(Betuvel[Cik]);
                 End;

            60 : Formatum  := Boolean(Value(Param));
            61 : Condensed := Boolean(Value(Param));

            62 : Gyujtes  := Boolean(Value(Param));

            63 : DateSort := Boolean(Value(Param));

          End; {Case}

        End; {If Par > 0}


      End; { If (Sor <> '') And (Param_Count > 1) }
    End;
    Close(Textfile);

    SetC8;

    If GrMode = HerMode Then DispMode := BW;

    {$IFDEF TITKAR} Sync := True; {$ENDIF}

    CheckRead(PathSt);

{    If EnabledSpeak Then InitSpeak;}

    If Not Esc Then
      For X := 1 To FontCount Do
        Begin
          Load_Font(FontTomb[X].Num,FontTomb[X].Name);
        End
    Else
      BEGIN
        Param := PathSt;
        Error(15,UpCase(Param[1]));
        Terminate;
      End;

  End;
  For Cikl := 1 To 3 Do
    If Pos('.',FileName[Cikl]) = 0 Then
      FileName[Cikl] := FileName[Cikl] + '.' + DefExt;

  Eredeti_Path := Path;

End;   {Read_Deffile}


{$IFNDEF CDVIEW}
Procedure Load_Parameters;

Const PMask : String[5] = '*.PAR';

VAR Kilepett,Kesz : Boolean;
    ParMask       : String[8];
    elozoovr     : boolean;
    o_u          : string;

BEGIN
  BOOL := CREATE_WINDOW(21,7,78,11,IneSt19,CA[DispMode,1],CA[DispMode,2]);

  Kesz := False;

  Repeat

    MaxStringLen := FnSize;
    Input_FileName(Enter_fn,DefFile,36,False);
    UpperCase(DefFile);
    CurOff;

    Kilepett := Esc;

    If NOT Esc Then
    BEGIN

      ParMask := '';

      If DefFile[2] = ':' Then
      BEGIN
        ParMask := Copy(DefFile,1,2);
        If DefFile[0] = #02 Then DefFile[0] := #00;
      End;

      ParMask := ParMask + PMask;

      If Deffile = '' Then Select_File(ParMask,Deffile,3);
      Clrscr;
      Kesz := Not Esc;
      If Kesz Then Read_Deffile(Bool);
    End;

  Until Kilepett Or Kesz;

  Make_Tabulators;
  Fresh_Strings;
  Set_Lines(LineSpace);
  Fresh_Info;

  Bool := Remove_Window;

End; { Load_parameters }

Procedure Load_Nyomtatok(Nyomtato:Boolean);

Const PMask : Array [Boolean] Of String[5] =
  ('*.SPS','*.PPS');

VAR Kilepett,Kesz : Boolean;
    elozoovr      : boolean;
    Teljesfnev    : FnTyp;
    alpps : printer_pars;
    alsps : serial_pars;
    PPName        : FnTyp;
                t : byte;

BEGIN
  PPName := PsFile[Nyomtato];

  If Nyomtato Then
    BOOL := CREATE_WINDOW(21,7,78,11,IneSt19,CA[DispMode,1],CA[DispMode,2])
  Else
    BOOL := CREATE_WINDOW(21,7,78,11,IneSt19,CA[DispMode,1],CA[DispMode,2]);


  Kesz := False;

  Repeat

    MaxStringLen := FnSize;
    Input_FileName(Enter_fn,PPName,36,False);
    UpperCase(PPName);

    If (PPname <> '') And (Pos('.',PPName) = 0) Then
      PPName := PPName + Copy(Pmask[Nyomtato],2,4);


    CurOff;
    While (Pos('\',PPName) + Pos(':',PPName)) > 0 Do
      Delete(PPName,1,1);

    Kilepett := Esc;

    Teljesfnev := PathSt+PMask[Nyomtato];
    If NOT Esc Then
    BEGIN

      If PPName = '' Then Select_File(Teljesfnev,PPName,3);
      While (Pos('\',PPName) + Pos(':',PPName)) > 0 Do
        Delete(PPName,1,1);
              Clrscr;
      Kesz := Not Esc;
      If Kesz Then
        BEGIN
          if Nyomtato then
            BEGIN
              for t := 1 to MaxFontNum do ChFont[t] := true; {laseren ujra kikuldeni}
              if PPName <> 'NOPRINT.PPS' then
               begin
                 assign (ppars,PathSt+PPName);
                 {$i-}   reset  (ppars);         {$i+}
                 If IOresult = 0 Then
                 BEGIN
                 {$i-}
                   read (ppars, alpps);    {$i+}
                   If IOresult = 0 Then
                     BEGIN
                       ppar := alpps;
                       PSFile[Nyomtato] := PPName;
                       Ppar_nev[Paralell_device+1] := PPName;
                       Ppar_Tomb[Paralell_device+1] := PPar;

                       close(ppars);
                       volt_pps := True;
                     end
                   Else
                     BEGIN
                       error(24,csak12(PPName));
                     End;
                 end
                 else error(1,Csak12(PPName));
               end
            end
          Else
            BEGIN
              assign (spars,PathSt+PPName);
              {$i-}   reset  (spars);         {$i+}
              If IOresult = 0 Then
              BEGIN
              {$i-}
                read (spars, alsps);    {$i+}
                If IOresult = 0 Then
                  BEGIN
                    spar := alsps;
                    PSFile[Nyomtato] := PPName;
                    close(spars);
                    volt_sps := True;
                  end
                Else
                  BEGIN
                    error(24,csak12(PPName));
                  End;
              end
            end;

        End;
    End;

  Until Kilepett Or Kesz;

  Bool := Remove_Window;
  Fresh_strings;
  Fresh_Info;
End; { Load_nyomtato }

Procedure Save_Macros;
VAR Cik : Integer;
    Fil : File;
    Escap : Boolean;
    elozoovr     : boolean;

BEGIN

  BOOL := CREATE_WINDOW(20,7,77,11,IneSt16,CA[DispMode,1],CA[DispMode,3]);
  MaxStringLen := FnSize;
  Input_FileName(Enter_Fn,MacFile,36,False);

  If Pos('.',MacFile) = 0 Then MacFile := MacFile + Copy(MMask,2,4);

  UpperCase(MacFile);

  If Not ESC Then CheckFileName(MacFile);
  CurOff;

  Escap := Esc;
  If Not Escap Then CheckWrite(MacFile);
  Esc := Escap OR Esc;

  If NOT Esc Then
  BEGIN

    Assign(Fil,Macfile);
    {$i-} Rewrite(Fil,3600); {$i+}

    If IOresult <> 0 Then Error(3,'  '+Csak12(MacFile))
    Else
    BEGIN
       {$I-}
       BlockWrite(Fil,LongNum,1); {3600 byte = 1 blokk }
       Close(Fil);
       {$I+}

       If Ioresult <> 0 Then
         BEGIN
           Erase(fil);
           Error(3,'  '+Csak12(MacFile));
         End

    End; {If IOresult = 0}
  End; { If NOT ESC }

  Bool := Remove_Window;
End; { Save_Macros }

{$I CIMLISTA.CDW}

Procedure Load_Macros;

VAR Cik     : Integer;
    Bc      : Byte;
    RecSize : Word;
    Fil     : File;
    Fi      : File OF LongInt;
    Lx      : LongInt;

    Asc,Scan,Kbfl : Byte;

    MacMask  : String[8];

    Escap,Kilepett,Kesz : Boolean;
    elozoovr     : boolean;

BEGIN
  FileMode := 0;

  If AutoLoad Then
  BEGIN
    Kesz := True;
    Esc  := False;
    Writeln(IneSt17,' : ',MacFile);
  End
  Else
  BEGIN

    Kesz := False;

    BOOL := CREATE_WINDOW(11,{2}7,68,{24}11,IneSt17,CA[DispMode,1],CA[DispMode,3]);

  End;

  Repeat

  If Not AutoLoad Then
  BEGIN
    MaxStringLen := FnSize;
    Input_FileName(Enter_Fn,MacFile,36,False);
    UpperCase(MacFile);
    If MacFile <> '' Then CheckFileName(MacFile);
    CurOff;

    Kilepett := Esc;

  End;

  If NOT Esc Then
  BEGIN

    MacMask := '';

    If MacFile[2] = ':' Then
    BEGIN
      MacMask := Copy(MacFile,1,2);
      If MacFile[0] = #02 Then MacFile[0] := #00;
    End;

    MacMask := MacMask + MMask;

    If MacFile <> '' Then
    BEGIN
      If Pos('.',MacFile) = 0 Then MacFile := MacFile + Copy(MMask,2,4);
    End
    Else Select_File(MacMask,Macfile,2);

    Escap := Esc;
    CheckRead(MacFile);
    Esc := Escap OR Esc;

    If Not Esc Then
    BEGIN

      Assign(Fi,Macfile);
      {$i-} Reset(Fi); {$i+}

      If IOresult <> 0 Then Error(1,Csak12(MacFile))
      Else
      BEGIN

        Kesz := True;

        Read(Fi,Lx);
        Close(Fi);

        Dec(Lx,CheckNum);

           {660421}    {660422}    {660423}
            {3.15}      {2.50}      {2.31}
        If (Lx = 0) Or (Lx = 1) Or (Lx = 2) Then   { Lx = 2 ha 2.31 verzio }
        BEGIN

          Mac3_15 := (Lx = 0);

          RecSize := 3009;

          If Lx < 2 Then RecSize := 3600   { 2.5 verziotol }
                    Else FillChar(MacEnv,SizeOf(MacEnv),255);

          Assign(Fil,Macfile);
          Reset(Fil,RecSize);
          BlockRead(Fil,LongNum,1);
          Close(Fil);

          For Cik := 1 To MacCount Do
          Begin
            If Length(MacName[Cik]) > $80 Then
            Begin
              For Bc := 0 To 3 Do
                If Byte(MacName[Cik][0]) AND $0F = (1 SHL Bc) Then
                   Byte(MacName[Cik][0]) := $80;
            End;
          End;

          (***************************************
          For Cik := 1 To MacCount Do
          Begin
            If Length(MacName[Cik]) < $80
            Then
              WriteLn(Cik:3,'  #',MacName[Cik],'#')
            Else
            Begin
              WriteLn(Cik:3,'  *',
              KeyName(Byte(MacName[Cik][2]),
                      Byte(MacName[Cik][1]),
                      Byte(MacName[Cik][0])),
                       ' => ',
                       Byte(MacName[Cik][2]):4,
                      Byte(MacName[Cik][1]):4,
                      Byte(MacName[Cik][0]):4, ' *');

            End;
          End;

          WriteLn(MacPos[1]);

          For Cik := 1 To MacCount Do
          Begin
            For Bc := 1 To MacPos[1] Do
            Begin
              Asc := Lo(MacTomb[Cik][Bc]);
              Scan:= Hi(MacTomb[Cik][Bc]);
              If Scan = 255 Then KbFl:= 12
                            Else KbFl:= 0;
              Write(KeyName(Scan,Asc,Kbfl),' ');
            End;
            WriteLn;
          End;

          If ReadKey = ' ' Then;

          ******************************)

        End
        Else Error(13,Csak12(MacFile));

      End; {If IOresult = 0}

    End; { If NOT ESC }

  End; { If NOT ESC }

  Until Kilepett Or Kesz;

  If Not AutoLoad Then Bool := Remove_Window;

  FileMode := 2;
End; { Load_Macros }


Procedure Del_File;

VAR  DM,Dm2   : FnTyp;
     Fn       : FnTyp;
     F        : File;
     Kilepett,Kesz  : Boolean;
     Cix,
     X1,Y1,X2,Y2  : Integer;
     Dszam        : Word;
     POZI         : INTEGER;
     DTOMB        : NEVTOMB;
     elozoovr     : boolean;
     Ut           : String;
     SS           : String[12];

Procedure Del;
BEGIN
  {$I-}
  Assign(F,Fn);
  Erase(F);
  If IOresult <> 0 Then Error(1,Csak12(Fn));
  {$I+}
End;

Function Biztos(Num : Integer):Boolean;
VAR   C  : Char;
      
BEGIN
  If Num > 1 Then
    Begin
      Str(Num,SS);
      Num := 2;
    End;
  Beepel(660);
  BOOL := CREATE_WINDOW(1,11,80,13,IneSt2,CA[DispMode,1],CA[DispMode,5]);
  GotoXY(6-2*Num,1);
  Write(IneSt3,TTT[Num],SS,IneSt5);
  Speak2(108,208);
  CurOn;
  Wait(C);
  CurOff;
  Bool := Remove_Window;
  Biztos := (C = YesChar);
  ESC := (C In [NoChar,Char(Escape)]);
End;


BEGIN  { Del_File }

  Fn := '';
  BOOL := CREATE_WINDOW(21,7,78,11,IneSt6,CA[DispMode,1],CA[DispMode,2]);

  Repeat

    DM := '*.'+Dmask;
    MaxStringLen := FnSize;
    Input_FileName(Enter_Fn,Fn,36,False);
    UpperCase(Fn);
    SS := Fn;

    CurOff;

    Kilepett := ESC;
    Kesz     := False;

    If Pos('*',Fn) Or Pos('?',Fn) <> 0 Then
    BEGIN
      DM := Fn;
      Fn := '';
    End;

    If (Not ESC) And (Fn <> '') Then Kilepett := Not Biztos(1);

    ESC := ESC Or Kilepett;

    If NOT Esc Then
    BEGIN

      If Fn = '' Then
        BEGIN
          X1 := 15; Y1 := 09;
          X2 := 65; Y2 := 17;
          { BOOL := CREATE_WINDOW(X1-1,Y1-1,X2+1,Y2+1,IneSt7+Dm,CA[DispMode,1],CA[DispMode,20]); }
          Set_Choose(X1,Y1,X2,Y2,12,400);

          {
          FNAME := '';
          DM2 := DM;

          WHILE POS(':',DM2) + POS('\',DM2) > 0 DO DELETE(DM2,1,1);

          IF DM2 <> DM THEN FNAME := COPY(DM,1,LENGTH(DM)-LENGTH(DM2));

          }
          Enged := 1;

          DIR(DM,Dtomb,Dszam,Ut);

          Enged := 0;

          If Not Esc Then
          BEGIN
            If Dszam = 0 Then
            BEGIN
              Error(1,Csak12(DM));
              Esc := True;
            End;
          End;

          IF NOT ESC THEN
            BEGIN
              SS := Dtomb[1];
              Kilepett := Not Biztos(DSzam);

              If Not Kilepett Then
              BEGIN
                ClrScr;
                For Cix := 1 To Dszam Do
                BEGIN
                  Fn := Ut+Dtomb[Cix];
                  Writeln(Fn,IneSt8);
                  Del;
                End;
                Kesz := True;
              End;

            END; {IF NOT ESC}

          { Bool := Remove_Window; }
        End
        Else
          Begin
            Del;
            Kesz := True
          End;

    End;

  Until Kilepett Or Kesz;

  Bool := Remove_Window;

End;  {Del_File}

Procedure Rename_File;

VAR  DM,
     Fn,NewFn : FnTyp;
     Pf,F,NewF  : File;
     Kilepett,Kesz  : Boolean;
     elozoovr     : boolean;


BEGIN
  Fn := '';
  NewFn := '';
  DM := '*.'+Dmask;
  BOOL := CREATE_WINDOW(21,7,78,12,IneSt9,CA[DispMode,1],CA[DispMode,2]);


  Repeat

    MaxStringLen := FnSize;
    Input_Filename(IneSt10+Enter_Fn,Fn,36,False);
    UpperCase(Fn);
    CurOff;

    Kilepett := ESC;
    Kesz     := False;

    If Pos('*',Fn) Or Pos('?',Fn) <> 0 Then
    BEGIN
      DM := Fn;
      Fn := '';
    End;

    If NOT Esc Then
    BEGIN

      If Fn = '' Then
      BEGIN
        Select_File(DM,Fn,2);
        If Not Esc Then
        BEGIN
          TextAttr := Attr_3[DispMode];
          GotoXY(16,2);
          Write(Fn);
          TextAttr := Attr_2[DispMode];
          Write('<');
        End;
      End;

      If NOT ESC Then
      BEGIN

        Assign(PF,Fn);
        CheckRead(Fn);

        If Not Esc Then
        BEGIN
          {$I-} Reset(Pf); {$I+}
          If IOresult <> 0 Then
          BEGIN
            Error(1,Csak12(Fn));
            Esc := True;
          End
          Else Close(Pf);

          If Not Esc Then
          Repeat
            MaxStringLen := FnSize;
            Input_FileName(IneSt11+Enter_Fn,NewFn,36,True);
            UpperCase(NewFn);
            CurOff;

            If NOT ESC Then
            BEGIN

              Assign(NewF,NewFn);
              {$i-} Reset(NewF); {$i+}
              If IOresult = 0 Then
              BEGIN
                {$i-} Close(NewF); {$i+}
                Error(12,Csak12(NewFn));
                Esc := True;
              End;

              If Not Esc Then
              BEGIN
                Assign(F,Fn);
                {$i-} Rename(F,NewFn); {$i+}
                If IOResult = 17 Then Error(21,'');
                Kesz := True;
              End         { Nem Duplicate file name }
              Else Esc := False;

            End; { New filename : <ESC> }

          Until Esc Or Kesz;

        End
        Else Kesz := True;

      End; { Select file : <ESC> }

    End;  { Filename : <ESC> }

  Until Kilepett Or Kesz;

  Bool := Remove_Window;

End;  {Rename_File}

Procedure Direct;
VAR Dummy : St40;
    DM    : St40;
    Dt          : nevtomb;
    Db          : Word;
    Ut          : String;

    elozoovr     : boolean;

BEGIN
  DM := '*.'+Dmask;
  BOOL := CREATE_WINDOW(31,7,78,11,'',CA[DispMode,1],CA[DispMode,2]);

  GotoXY(2,2);
  MaxStringLen := FnSize;
  Input_String(IniSt4,DM,26);
  UpperCase(DM);
  CurOff;

  Bool := Remove_Window;

  If Not ESC Then
  BEGIN
    Set_Choose(5,7,76,18,12,0);  {Default}

    Enged := 00;
    Dir(DM,Dt,Db,Ut);

  End;

End;

VAR

ReceiveM  : Boolean;
SendM     : Boolean;
Umeret    : Word;
Iras      : Boolean;

Procedure BlockreadM(VAR Fil:File; VAR Block : ModemTomb);

BEGIN
  Umeret := 128;
  Fillchar(Block,128,#0);
  If Not ReceiveM Then
      {$i-}
      BlockRead(Fil,Block,128,Umeret)
      {$i+}
  Else
    BreadM(Block);
  Iras := False;
End;

Procedure BlockWriteM(VAR Fil:File; Block : ModemTomb);

BEGIN
  If Not SendM Then
    {$i-}
    BlockWrite(Fil,Block,UMeret)
    {$i+}
  Else BwriteM(Block);
  Iras := True;
End;

Procedure AssignM2(VAR FF : File; ez: string);
BEGIN
  {$I-}
  ModemMode := Ez = 'XMODEM';
  If Not ModemMode Then
    Assign(FF, ez)
  {$I+}
End;


Procedure ResetM2(VAR Fil:File);
BEGIN
  Umeret := 128;
  If Not ReceiveM Then {$i-} Reset(Fil,1) {$i+}
  Else Open_modem_inp;
  Iras := False;
End;

Procedure RewriteM2(VAR Fil:File);
BEGIN
  If Not SendM Then  {$i-} ReWrite(Fil,1) {$i+}
  Else Open_modem_out;
  Iras := True;
End;

Function EofM2(VAR FF : File):Boolean;
BEGIN
  If ReceiveM Then
    EofM2 := Eof_Modem
  Else
    EofM2 := EOF(FF) or (Umeret <> 128)
End;


Function IoResultM2 : Integer;
BEGIN
  If Iras Then
    If SendM then
      IoResultM2 := ModemError
    Else
      IoresultM2 := IoResult
  Else
    If ReceiveM Then
      IoResultM2 := ModemError
    Else
      IoResultM2 := IoResult
End;


Procedure Copy_File;

VAR
elozoovr  : boolean;
DM,
Fn,NewFn  : FnTyp;
FBe,FKi   : File;
Kesz      : Boolean;
Mtomb     : ModemTomb;
Kilepett  : boolean;
c         : char;

BEGIN
  ReceiveM := False;
  SendM    := False;
  ESC      := false;
  ModemError := 0;

  Fn := '';
  NewFn := '';
  DM := '*.'+Dmask;
  BOOL := CREATE_WINDOW(21,7,78,12,IneSt20,CA[DispMode,1],CA[DispMode,2]);


  Repeat

    GotoXY(2,2);
    MaxStringLen := FnSize;
    Input_String(IneSt21,Fn,34);
    UpperCase(Fn);
    CurOff;

    Kesz     := False;
    Kilepett := Esc;

    CheckFn(Fn);

    If (NOT Esc) AND ((Pos('*',Fn) Or Pos('?',Fn)) <> 0) Then
    BEGIN
      DM := Fn;
      Fn := '';
    End;

    If NOT Esc Then
    BEGIN

      If Fn = '' Then
      BEGIN
        Select_File(DM,Fn,2);
        If Not Esc Then
        BEGIN
          TextAttr := Attr_3[DispMode];
          GotoXY(20,2);
          Write(Fn);
          TextAttr := Attr_2[DispMode];
          Write('<');
        End;
      End;

      If NOT ESC Then
      BEGIN

        AssignM2(Fbe,Fn);
        ReceiveM := ModemMode;
        If NOT ModemMode Then CheckRead(Fn);

        If Not Esc Then
        BEGIN
          If Not ModemMode Then
            BEGIN
               {$I-} Reset(Fbe,1); {$I+}
               If (IOresult <> 0) or (Filesize(Fbe) = 0) Then
                 BEGIN
                   Error(1,Csak12(Fn));
                   Esc := True;
                 End
               Else Close(Fbe);
            End;

          If Not Esc Then
          Repeat
            GotoXY(2,3);
            MaxStringLen := FnSize;
            Input_String(IneSt22,NewFn,34);
            UpperCase(NewFn);
            CurOff;

            CheckFn(NewFn);

            If NOT ESC Then
            BEGIN
              CheckFileName(NewFn);
              ModemMode := False;
              AssignM2(Fki,NewFn);
              SendM     := ModemMode;
              ModemMode := ReceiveM XOR SendM;

              If (Fn = NewFn) Then
                BEGIN
                  Error(25,'');
                  Esc := True
                End;

              If Not Esc Then
              BEGIN

                ResetM2(Fbe);
                Esc := IoResultM2 <> 0;

                If Not ESc then
                  BEGIN
                    RewriteM2(Fki);
                    If IoresultM2 <> 0 Then
                      BEGIN
                        If Not SendM Then Error(26,'');
                        Esc := True
                      End
                    Else
                      BEGIN
                        While (Not ESC) And (Not EofM2(Fbe)) Do
                          BEGIN
                            BlockReadM(Fbe,Mtomb);
                            Esc := IoResultM2 <> 0;
                            If Not Esc Then
                              BEGIN
                                BlockWriteM(Fki,MTomb);
                                Esc := IoResultM2 <> 0
                              End
                          End;

                        If ModemMode and (ModemError = 0) then
                            BEGIN
                                End_of_Transmission;
                                Close_Puffer;
                                Bool := remove_window;
                            End;

                        If Not ReceiveM then Close(Fbe);
                        If Not SendM then
                          BEGIN
                            {$i-} Close(Fki);    {$i+}
                            Esc := (IoResult <> 0) Or Esc
                          End;

                        If Esc And (ModemError = 0) Then
                          Error(26,'');
                      End
                  End;
                Kesz := Not ESC;
              End;                        { Nem Duplicate file name }
              Esc := False
            End; { New filename : <ESC> }
          Until Esc Or Kesz;    { A masodik filenev ciklus }
        End
        Else Kesz := True;
      End; { Select file : <ESC> }
    End;  { Filename : <ESC> }
  Until Kilepett Or Kesz;       { Az elso filenev ciklus}
  Bool := Remove_Window;
End;
{$ENDIF}

End.