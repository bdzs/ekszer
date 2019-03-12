Unit nyomtat;

{$O+}

Interface

Uses Crt,Dos,
    {$IFDEF PROBA}
    PRINTER,
    {$ENDIF}
     WindowM,
     MenuErr,
     HeapCdw,
     InputCdw,
     ReadKit,
     SpeakCdw,
     video;

Type NyomasType = (Header,Footer,MainPage);

Var
  NemKellPr,
  FullPr,
  HeapPr,
  MNemKellPr,
  MFullPr,
  MHeapPr,
  LinecPr,FoPr,PageCount,PageC2,KellMeg,Pc : Integer;
  ActEdit,MaxHeader,HeaderCount,Kell_Meg : Integer;
  VegeLesz,KovFalse : Boolean;
  Chh : Char;
  LQ : boolean;
  centronics  : boolean;

  {$IFDEF LICENC}
  LicencKep,FirstLineVan,
  LicencElsoLesz,
  Emblema      : Boolean;
  FelulIrta    : Boolean;
  SzoltMar     : Boolean;
  {$ENDIF}

  Nyomas,
  OldNyomas     : NyomasType;

  sz : integer;
   c : char;

      PkepOffs,
      PkepSeg       : Word;
      KepFont       : Byte;
      NYModus       : Byte;
      VoltKepNev,
      Inverzkep,
      FrameKep,
      WhitePrior,
      KepNyomas,
      TrueNyomas    : Boolean;
      HanyOldalonKeresztul : Integer;

Procedure SaveMain;
Procedure NewPage;
Procedure InitVan;
Function  Van_Sor : Boolean;
Procedure Lprint (c: byte);
Procedure View_pic;
Procedure AlahuzottSpaceCsere(Var CHR : Char;
                                  ATT : Byte);

{$IFDEF LICENC}
Const
     LicencP1 = '.PIC=';
     LicencP2 = '\EMBLEMA.PIC,4,4';

     EmbSt    : String[4]  = 'OKHB';
     PicNames : Array[1..3] Of String[12] =
       ('EMBLEMA.9','EMBLEMA.24','EMBLEMA.PIC');

      Check : Array[1..3] Of Word =
       (42197,12214,14422);

{$ENDIF}


Implementation


Uses Nyom8;

{------------------------------------------------------------------}
procedure Lprint (c: byte);       {kilepett lesz, ha nem megy ki!!!}
                                  {es [A]bort }
var        cb : char;
       pr_ok  : boolean;
       bejott : boolean;
       bechar : byte;
       count  : integer;
       kilepett: boolean;
const
       retry   = 30;

begin

  if not centronics then
     begin
        count  := iroido;
        pr_ok  := false;
        cb     := ' ';
        kilepett := false;

        register.DX := serial_device;
        register.AH := 3;                         {get status}
        intr($14,register);
        bejott := ((register.AH and 1) = 1);
        if bejott then
         begin
           register.DX := serial_device;
           register.AH := 2;                      {receive char}
           intr($14,register);
           bechar := register.AL and $7F;

             if bechar = 19 then                  {xoff}
              repeat
                 register.DX := serial_device;
                 register.AH := 2;                {receive char}
                 intr($14,register);
                 bechar := register.AL and $7f;

                 if keypressed then
                   begin
                     cb:= readkey;  if cb = #0 then cb := readkey;
                     BOOL := CREATE_WINDOW(15,7,65,11,pr_mess1,CA[DispMode,1],Ca[DispMode,4]);
                     GotoXY(5,2);
                     write(pr_mess2);
                     Speak2(100,200);
                     cb := readkey; if cb = #0 then cb := readkey;
                     Bool := Remove_Window;
                     kilepett := (cb = #27);
                   end;

              until (bechar=17) or kilepett;
         end;

        ESC := Kilepett;

        if kilepett then exit;
        repeat
          count := retry;
          repeat
            register.DX := serial_device;
            register.AL := c;
            register.AH := 1;                 {print AL}
            intr($14,register);
            pr_ok := ((register.AH and $80) = 0);
            dec(count);
            if (keypressed And (ReadKey=#27)) then
              begin
                BOOL := CREATE_WINDOW(15,7,65,11,pr_mess1,CA[DispMode,1],Ca[DispMode,4]);
                GotoXY(5,2);
                write(pr_mess2);
                Speak2(100,200);
                Repeat
                  cb := readkey; if cb = #0 then cb := readkey;
                Until Cb In [#27,#13];
                Bool := Remove_Window;
                kilepett := (cb = #27);
              end;

          until pr_ok or (count = 0) or kilepett;

          ESC := Kilepett;
          if kilepett then exit;

          if not pr_ok then
            begin
              BOOL := CREATE_WINDOW(42,8,72,12,pr_mess13,CA[DispMode,1],Ca[DispMode,4]);
              GotoXY(2,2);
              write(pr_mess14);
              Speak2(102,202);

              while keypressed do cb := readkey;
              repeat
                cb := Upcase(readkey);
              until cb in [#27,UjraChar,KilepChar];
              Bool := remove_window;
              if cb in [KilepChar,#27] then
               begin
                kilepett := true;
                ESC := true;
               end;
            end;

        until (pr_ok or kilepett);
        delay(iroido);              {minden kikuldott byte utan}

     end
  else         {If centronics ---------------------------------}

    begin
      pr_ok := false;
      cb    := ' ';
      repeat
        register.DX := paralell_device;
        register.AL := c;
        register.AH := 0;                 {print AL}
        intr($17,register);
        pr_ok := ((register.AH and $0F) = 0);

        if not pr_ok then
          begin
            BOOL := CREATE_WINDOW(42,8,72,12,pr_mess13,CA[DispMode,1],Ca[DispMode,4]);
            GotoXY(2,2);
            write(pr_mess14);
            Speak2(102,202);

            while keypressed do cb := readkey;
            repeat
              cb := Upcase(readkey);
              if cb = #0 then cb := readkey;
            until cb in [#27,UjraChar,KilepChar];
            Bool := remove_window;
            if cb in [KilepChar,#27] then
              begin
               kilepett := true;
               ESC := true;
              end;
          end;

      until (pr_ok or kilepett);
    end;
end;

{---------------------------------------------------------------}

Function PrintEdit(Start:Integer) : Integer;

Var  EdPos : Integer;
     PrE   : Integer;
Begin
  PrE := 0;
  EdPos := Start+3+PageC2-1;
  If PageC2 < 10 Then
    If StartLine[EdPos] <= EndLine[EdPos] Then
      PrE := EdPos;
  If PrE = 0 Then
    If Odd(PageC2) Then
      If StartLine[Start+2] <= EndLine[Start+2] Then
        PrE := Start + 2
      Else Begin End
    Else
      If StartLine[Start+1] <= EndLine[Start+1] Then
        PrE := Start + 1;
  If PrE = 0 Then
    If StartLine[Start] <= EndLine[Start] Then
      PrE := Start;
  PrintEdit := PrE
End;

Procedure InitVan;
Begin
  HeapPr := StartLine[EditNum];
  While NOT MainLine(HeapPr) Do Inc(HeapPr);
  NemKellPr := 0;
  FullPr := UpInd(HeapPr)+DownInd(HeapPr)+1;
  FoPr := 0;
End;


Function Van_Belole : Boolean;
Begin
  If NemKellPr = FullPr Then
    If LastMain(HeapPr) Then
      Van_Belole := False
    Else
      Begin { Utolso sora a komplexnek, de nem file vege }
        HeapPr := NextMain(HeapPr);
        NemKellPr := 0;
        FullPr := UpInd(HeapPr)+DownInd(HeapPr)+1;
        HalfToImage(HeapPr,LastLine,NemKellPr,1);
        Inc(LinecPr);
        Inc(NemKellPr);
        Set_BitsI(LastLine,$FF,LapVege*Byte(FoPr = PageLen));
      Van_Belole := True;
      End
  Else
    Begin  { Nem utolso sora a komplexnek }
      HalfToImage(HeapPr,LastLine,NemKellPr,1);
      Inc(LinecPr);
      Set_BitsI(LastLine,$FF,LapVege*Byte(FoPr = PageLen));
      Van_Belole := True;
      Inc(NemKellPr);
    End;
End;

Procedure SaveMain;
Begin
  MHeapPr := HeapPr;
  MNemkellPr := NemKellPr;
  MFullPr := FullPr;
End;

Procedure RestoreMain;
Begin
  HeapPr    := MHeapPr;
  NemkellPr := MNemKellPr;
  FullPr    := MFullPr;

  EditNum   := GEditNum;
  Nyomas    := MainPage;
  FoPr      := 0;
End;

Procedure JonAHeader;
Begin
  sz := 0;

  EditNum := PrintEdit(4);     {5 VOLT !!!}
  PrevHeadNum := EditNum;
  Nyomas  := Header;
  If (EditNum = 0) Or (MaxHeader = 0) Then
    RestoreMain
  Else
    InitVan
End;


Procedure NewPage;
Begin
  Inc(PageCount);
  Inc(PageC2);

  {$IFDEF LICENC}
  If EmblemaMod In[1..2] Then
    Begin
      LicencElsoLesz := True;
      If EmblemaMod = 1 Then
        EmblemaXpos := 0
      Else
        EmblemaXpos := c78-PrintMargin-EmbXLen;
    End;
  {$ENDIF}

  If VegeLesz Or (PageCount > LastPage) Then
    Begin
      KovFalse := True
    End
  Else
    Begin
      HeaderCount := 0;
      LinecPr := 0;
      FoPr := 0;
      JonAHeader;
    End;

 {FillImageLine(LastLine); }

  Set_BitsI(LastLine,$FF,LapVege);
End;

{$IFDEF LICENC}

Procedure JonAFooter;
var c : char;
Begin
  SaveMain;
  EditNum := PrintEdit(16);            {17 VOLT !!!!}
  PrevFootNum := EditNum;
  If (HeaderCount = MaxHeader) Then
    NewPage
  Else
    Begin
      Nyomas := Footer;
      If EditNum <> 0 Then
        InitVan
      Else
        KellMeg := (MaxHeader+PageLen) - LinecPr;
    End;
End;

{$ELSE}

Procedure JonAFooter;
var c : char;
Begin
  SaveMain;
  EditNum := PrintEdit(16);            {17 VOLT !!!!}
  PrevFootNum := EditNum;
  If (EditNum = 0) Or (HeaderCount = MaxHeader) Then
    NewPage
  Else
    Begin
      Nyomas := Footer;
      InitVan;
    End;
End;
{$ENDIF}

Procedure ChangeElvalasztojel;

Var    Cikl,Cik : Byte;
       NyomtatChar, NyomtatAttr : PMutat;

Begin

  NyomtatChar   := @Image[LastLine]^.Attribs[c79];
  NyomtatAttr   := @Image[LastLine-1]^.Chars[C80+c79];

  NyomtatAttr^[0] := Char(C78);
  NyomtatChar^[0] := Char(C78);

  Cikl := C77;

  While (Byte(NyomtatAttr^[Cikl]) And 15) = 0 Do Dec(Cikl);

  Inc(Cikl);

  If NyomtatChar^[Cikl] =  '-' Then
     NyomtatAttr^[Cikl] := #1; { 0-as helyett 1-es font }

  Dec(Cikl);

  For Cik := Cikl Downto 1 Do
    If (Byte(NyomtatAttr^[Cik]) And 15 = 0) AND
       (NyomtatChar^[Cik] =  '-') Then
         NyomtatAttr^[Cik] := #1; { 0-as helyett 1-es font }

End;

Function ConvMagyUp(Var S:String):String;
Var Cikl,P : Integer;
    Wrk    : String;
    S1,S2  : String[10];
Begin
  S1 := MagyUpcSt[0]+'&';
  S2 := MagyUpcSt[1]+'+';

  Wrk[0] := S[0];
  For Cikl := 1 To Length(S) Do
    Begin
      P := Pos(S[Cikl],S1);
      If P = 0 Then
        Wrk[Cikl] := UpCase(S[Cikl])
      Else
        Wrk[Cikl] := S2[P]
    End;
  ConvMagyUp := Wrk;

End;

Const MaxPc = 6;
      Pcommand : Array[1..MaxPc] Of String[7] =
        ('.REM',
         '.PRINT+',
         '.FEKV{',
         '."LL+',
         '.S|R|',
         '.NORM"L');


Procedure SeekRemPrint;
Var St   : St16;
    P    : Integer;
    B,T  : Byte;
    Code : Integer;
    Cikl : Integer;
    Ws   : String[3];
    NyomtatChar : PMutat;
    Wst  : String;

Function SzamParam(Poz:Integer):Integer;
Var Wst : St80;
    Res,
    Err : Integer;
Begin
  Wst := '';
  While (NyomtatChar^[Poz] in ['0'..'9','!']) AND (Poz < c78) Do
    Begin
      C :=NyomtatChar^[Poz];
      If C = '!' Then
        Wst := Wst+'0'
      Else
        Wst := Wst+C;
      Inc(Poz);
    End;
  Val(Wst,Res,Err);
  If (Wst = '') Or (Err <> 0) Then
    SzamParam := MaxInt
  Else
    SzamParam := Res
End;


Begin

  NyomtatChar   := @Image[LastLine]^.Attribs[c79];
  NyomtatChar^[0] := Char(C78);

  Wst := ConvMagyUp(NyomtatChar^);

  Cikl := 1;
  P := 0;
  Repeat
    P := Pos(Pcommand[Cikl],Wst);
    Inc(Cikl)
  Until (P<>0) Or (Cikl > MaxPc);

  T := P;

  Dec(Cikl);
  If T <> 0 Then
    Begin
      Case Cikl Of
        2: Begin  { Ha .PRINT }
             Inc(P,7);
             While NOT(NyomtatChar^[P] in [' ',#0]) AND (P < c78) Do
             Begin
               If NyomtatChar^[P] = '\' Then
               Begin
                 Inc(P);
                 Ws := Copy(NyomtatChar^,P,3);
                 Val(Ws,B,Code);
                 If Code = 0 Then
                   Begin
                     If TrueNyomas AND (Nymodus <> 4) Then
                       Lprint(B)
                   End
                 Else
                   Begin
                     P := c78;
                     Beepel(660);
                   End;
                 Inc(P,3);
               End
               Else
               Begin
                 If TrueNyomas AND (Nymodus <> 4) Then
                   Lprint(Byte(NyomtatChar^[P]));
                 Inc(P);
               End;
             End;
           End; { Ha .PRINT= }
        3: Begin { Ha .FEKVO }
             HanyOldalonKeresztul := Szamparam(P+7);
             Formatum := False;
           End;
        4: Begin { Ha .ALLO  }
             HanyOldalonKeresztul := SzamParam(P+6);
             Formatum := True;
           End;
        5: Begin { Ha .SURU }
             Condensed := True
           End;
        6: Begin { Ha .NORMAL }
             Condensed := False
           End;

        End; { Case }
      For Cikl := T to c78 do
        NyomtatChar^[Cikl] := ' ';
    End; { Ha van valamilyen parancs }
End;


Procedure ChangeCtp;

Var St   : St16;
    P    : Integer;
    Cikl,
    Eltol,
    Veg  : Integer;
    NyomtatChar,
    NyomtatAttr : PMutat;

Begin

  NyomtatChar   := @Image[LastLine]^.Attribs[c79];
  NyomtatAttr   := @Image[LastLine-1]^.Chars[C80+c79];

  STR(PageC2:0,St);
  St:=PubStr+St;

  NyomtatAttr^[0] := Char(C78);
  NyomtatChar^[0] := Char(C78);
  P := Pos('h',NyomtatChar^);

  While P <> 0 Do
  If (Byte(NyomtatAttr^[P]) And 15) = 0 Then
    Begin
      Veg := P + Byte(St[0])-1;
      If Veg > C77 Then
        Veg := C77;      { c78 volt !!! }

      Eltol := Veg-P;

      For Cikl := C77 DownTo Veg Do
        Begin
          NyomtatChar^[Cikl] := NyomtatChar^[Cikl-Eltol];
          NyomtatAttr^[Cikl] := NyomtatAttr^[Cikl-Eltol];
        End;

      For Cikl := P To Veg Do
        Begin
          NyomtatChar^[Cikl] := St[Cikl-P+1];
          NyomtatAttr^[Cikl] := #1;
        End;

      P := Pos('h',NyomtatChar^);
    End
    Else
    Begin
      NyomtatChar^[P] := #255;
      P := Pos('h',NyomtatChar^);
    End;

    P := Pos(#255,NyomtatChar^);
    While P <> 0 Do
    Begin
      NyomtatChar^[P] := 'h';
      P := Pos(#255,NyomtatChar^);
    End;
End;


Procedure KorLevel;                       {^^^^^^^^}

Var Num,
    Attr_Osszeg,
    Darab,Font,
    X,Meg       : Byte;
    Tcikl,P,PP  : Integer;
    Cikl,Eltol,
    Veg         : Integer;
    NyomtatChar,
    NyomtatAttr : PMutat;
    Ws          : String[60];
    Blank,
    Megvan      : Boolean;
    NyomSt,
    NyomAt      : String[255];
    BB          : Byte;

Type BeType = (Beir,BeSzur);

Procedure Beilleszt(T: BeType);
Const LeadCh : Array[Betype] Of Char = ('#','@');

Begin

  With CLV^ Do
    Begin
      P := Pos(LeadCh[T],NyomSt);

      While P <> 0 Do
        Begin

          {Writeln(p:2,Length(NyomSt):3,' ',Copy(NyomSt,1,71));
          If Readkey = ' ' Then;}

          If (Byte(NyomAt[P]) And 15) = 1 Then
            Begin
              Meg    := 0;
              Tcikl  := 1;
              Megvan := false;

              While (Tcikl <= VarNum) do
                Begin
                  Ws[0]  := VarSt[Tcikl][0];
                  If Ws <> '' Then
                    Begin
                      Move (NyomSt[P+1], Ws[1], byte(Ws[0]));
                      UpperCase(Ws);
                      Megvan := (WS = VarSt[Tcikl]);
                    End;
                    If Megvan Then
                      Begin
                        Meg := Tcikl;
                        X := Length(Ws)+1;
                      End;
                  Inc(Tcikl);
                End;

              Megvan := (Meg > 0);

              If Megvan then
                Begin
                  Tcikl := Meg;
                  If T = BeSzur Then
                    Begin
                      Delete(NyomSt,P,X);
                      Delete(NyomAt,P,X);
                    End
                  Else
                    Begin
                      FillChar(NyomSt[P],X,' ');
                      FillChar(NyomAt[P],X,1);
                    End;

                  Ws := GetVar(Tcikl);

                  Blank := False;

                  If Ws = '' Then
                    Begin
                      If ADB40 Then
                        Begin
                          Ws := BlankVar[Tcikl];
                          Blank := True;
                        End
                      Else
                        Begin
                          Fillchar(Ws[1],X,' ');
                          Ws[0] := Char(X);
                        End;
                    End; { If Ws = '' }

                    { If P + Length(Ws) > C77 Then
                    Dec(Byte(Ws[0]),P+Length(Ws)-C77); }

                  If T = BeSzur Then
                    Insert(Ws,NyomSt,P)
                  Else
                  Begin
                    Move(Ws[1],NyomSt[P],Length(Ws));
                    If (P + Length(Ws) -1) > (Length(NyomSt)) Then
                      NyomSt[0] := Char(P+Length(Ws)-1);
                  End;

                  If Tcikl < VarNum-1 Then
                    Begin
                      If Blank Then
                        Begin
                          attr_osszeg:=0;
                          Num := 1;

                          While attr_osszeg < Length(Ws) do
                            BEGIN
                              darab := Byte(BlankVarAttr[Tcikl][Num]) SHR 4;
                              Font  := Byte(BlankVarAttr[Tcikl][Num]) AND 15;

                              FillChar(Ws[attr_osszeg+1],darab,Char(Font));

                              Inc(attr_osszeg,darab);
                              Inc(Num);
                            End;
                        End { If Blank }
                      Else
                        Move(CimRecBuff^[VarPos[Tcikl]+VarLen[Tcikl]],Ws[1],VarLen[TCikl]);
                    End { If Tcikl < VarNum-1 }
                  Else
                    FillChar(Ws[1],Length(Ws),1);

                  If T = BeSzur Then
                    Insert(Ws,NyomAt,P)
                  Else
                  Begin
                    Move(Ws[1],NyomAt[P],Length(Ws));
                    If (P + Length(Ws) -1) > (Length(NyomAt)) Then
                    NyomAt[0] := Char(P+Length(Ws)-1);
                  End;

                End { If Megvan }
              Else
                Begin
                  NyomSt[P] := #255;
                  NyomAt[P] := #01;
                End;

              P := Pos(LeadCh[T],NyomSt);

            End { If (Byte(NyomAt[P]) And 15) = 1 }
          Else
            Begin
              NyomSt[P] := #255;
              P := Pos(LeadCh[T],NyomSt);
            End;

        End; { While P <> 0  }

      P := Pos(#255,NyomSt);
      While P <> 0 Do
        Begin
          NyomSt[P] := LeadCh[T];
          P := Pos(#255,NyomSt);
        End;

      {Beepel(666);
      Beepel(888);
      If ReadKey = ' '  Then;}
    End;
End; { Procedure Beilleszt }

Begin
    NyomtatChar   := @Image[LastLine]^.Attribs[c79];
    NyomtatAttr   := @Image[LastLine-1]^.Chars[C80+c79];

    BB := Byte(NyomtatAttr^[1]) And $F0;

    X := c78;

    While (NyomtatChar^[X] = #00) AND (X > 0) Do Dec(X);

    NyomtatAttr^[0] := Char(X);
    NyomtatChar^[0] := Char(X);

    NyomSt := NyomtatChar^;
    NyomAt := NyomtatAttr^;

    For Cik := 0 To 1 Do Beilleszt(BeType(Cik));

    If Length(NyomSt) > C77 Then NyomSt[0] := Char(C77);
    If Length(NyomAt) > C77 Then NyomAt[0] := Char(C77);

    FillChar(NyomtatChar^[1],C77,#00);
    FillChar(NyomtatAttr^[1],C77,01);


    NyomtatChar^ := NyomSt;
    NyomtatAttr^ := NyomAt;

    NyomtatAttr^[1] := Char(Byte(NyomtatAttr^[1]) Or BB);


End;


{-------------------------- Kepfeldolgozas -----------------------}

Const            { Ide majd 158 kell }
      MaxNyomSzel  = 78*36 Div 8-1;  { Ebbe  ( Printer  tomb ) Max:24TU    }
      MaxKepSzel   = 78*36 Div 8-1;  { Ebbol ( Kepernyo t”mb ) Max:Hercules}
      MaxPYSor     = 25-1;           { A maximalis fel karakterkeszlet     }
      MaxYLine     = 2400-1;         { A betoltendo kep ymax : VGA         }

Type  MaxNyomSor  = Array[0..MaxNyomSzel] Of Byte;
      MaxKepSor   = Array[0..MaxKepSzel]  Of Byte;
      SorKepType  = Array[0..MaxPYSor]    Of MaxNyomSor;
      SorKepMut   = ^SorKepType;

      BitSor = Array [0..7] of byte;

{$L TAGIT.OBJ}
{$L SZUKIT.OBJ}
{$L ATPAKOL8.OBJ}
{$L BITFORG.OBJ}

Var   Xarany,Yarany : Real;

      AranyTomb     : Array[0..(MaxNyomSzel+1)*8-1] Of Byte;
      AranyTombY    : Array[0..MaxYLine] Of Byte;

      OutputB       : MaxNyomSor;
      InputB        : MaxKepSor;

      Xbyte,      { A kepernyon hany byte szeles              }
      PXByte,     { A printeren hany byte szeles              }
      Xpont,      { A kepernyon hany pont szeles              }
      PxPont,     { A printeren hany pont szeles              }
      Ysor,       { A kepernyon hany sor                      }
      PySor,      { A printeren hany sor                      }
      EgysorY,    { Egy felsor hany y sor                     }
      EgyChrX,    { Egy karakter a printeren hany pont szeles }

      Felsorok,   { Hany felsorbol all az ablak               }
      Karakterek  { Hany karakter szeles az ablak             }

                    : WORD {Integer} ;

      SorKep        : SorKepMut;
      SorCount,
      SorCountI     : Integer;
      Xnagyitas,
      Ynagyitas     : Boolean;
      Ymaradek      : Integer;

      KepFileName   : FnTyp;
      KepXKezd,
      KepYKezd,
      KepXCh,
      KepYFel,
      KepXKezdet    : Integer;
      KepYKezdet    : Integer;
      Font11        : Pointer;

      (*
      Sfil          : File Of WORD {Integer} ;
      IFile         : File;
      *)

      Csik          : Byte;

procedure tagit(ebbol:pointer; ebbe: pointer; ennyit: word; mennyit: pointer);
          external;
procedure szukit(ebbol:pointer; ebbe: pointer; ennyit: word; mennyit: pointer);
          external;

Procedure ATPAKOL8(tombcim:Pointer;fontCim : Pointer;
          xnovel: word; xmennyit: word; ymagas: word; ymennyit: word );
          external;
Procedure BuffNegal  (tombcim: pointer; hossza:word); external;   {byte-osan}
Procedure BuffNegalW (tombcim: pointer; hossza:word); external;   {word-osen}

Procedure Bitforgat(var ezt, erre: bitsor; irany: boolean); external;


Procedure ATPAKOL24(tombcim:SorKepMut; xmennyit: word);
Var Ezt,Erre   : BitSor;
    Cikl, Cikl1: word;
    Ide        : word;

Begin
   Ide     := 0;

   For Cikl := 0 to Xmennyit-1 Do
    Begin
     For Cikl1:= 0 to 7 Do
       Ezt[Cikl1] := TombCim^[Cikl1,Cikl];

     Bitforgat(ezt,erre,true);
     For Cikl1:= 0 to 7 Do
      Begin
        FontKezdet[KepFont]^[ide] := Erre[Cikl1];
        Inc(ide,3);
      End;
    End;

   Fillchar(SorKep^[EgySorY+1],PxByte,0);

   Ide := 1;

   For Cikl := 0 to Xmennyit-1 Do
    Begin
     For Cikl1:= 0 to 7 Do
       Ezt[Cikl1] := TombCim^[Cikl1+7,Cikl];


     Bitforgat(ezt,erre,true);
     For Cikl1:= 0 to 7 Do
      Begin
        FontKezdet[KepFont]^[ide] := Erre[Cikl1];
        Inc(ide,3);
      End;
    End;
End;

Procedure AtpakolX;
Var BitP,
    ByteP,
    Cikl,Cikl2,
    Cikl3 : Integer;
    MaradX     : Integer;
    ORB : Byte;
Const
   AndT : Array[0..7] Of Byte = (128,64,32,16,8,4,2,1);

Begin
  For Cikl := 0 To EgySorY Do
    Begin
      BitP  := 0;
      ByteP := 0;
      For Cikl2 := 0 To Karakterek-1 Do
        Begin
          ORB := 0;
          For Cikl3 := 0 To EgyChrX - 1 Do
            Begin
              ORB := ORB Or
                     (((SorKep^[Cikl,ByteP] And AndT[BitP]) Shr (7-BitP))
                       Shl (7-Cikl3));
              Inc(BitP);
              If BitP = 8 Then
                Begin
                  BitP := 0;
                  Inc(ByteP)
                End;
            End;
          PrevHely^[Cikl2*(PrevYs)+Cikl] := ORB;
        End
    End;
End;

Procedure AtpakolDesk;
var byte4 : egy_kar_pix_sor;
    Cikl, Cikl2 : Integer;

Procedure Get4Byte(Sor,Bitpos:Word);

var bytepoz, bitpoz : word;
    li : longint;
    LIX : egy_kar_pix_sor Absolute Li;
    b, t : byte;

begin
   bytepoz := bitpos div 8;
   bitpoz  := bitpos mod 8;

   if bitpoz = 0 then
     move(SorKep^[Sor,bytepoz], byte4, 4)
   else
    begin
      for T := 1 To 4 Do LiX[T] := Sorkep^[Sor,bytepoz+5-T];

      b := Sorkep^[Sor,bytepoz] shl bitpoz;

      li := li shr (8-bitpoz);

      For T := 1 To 4 Do
        byte4[T]:=liX[5-T];

      byte4[1] := byte4[1] or b;

    end;
end;


Begin
  LoadFont(Kepfont);
  For Cikl := 0 To EgysorY Do
    Begin
      For Cikl2 := 0 To Karakterek-1 Do
        Begin
          Get4Byte(Cikl,Cikl2*30);  { byte4-be be a Sorkep^-bol 4 byte}
          setpt[KepFont]^[Cikl2+33,Cikl+1] := Byte4;
        End;
    End;
End;


Procedure EgySorOrol(Sor:Integer);
Var Cikl : Integer;
Begin
  For Cikl := 0 To PxByte-1 Do
    SorKep^[Sor,Cikl] := SorKep^[Sor,Cikl] Or OutputB[Cikl];
End;

Procedure PufferTorol;
Begin
  FillChar(SorKep^,Sizeof(SorKep^),0)
End;

Procedure XNagyit;
Var Cikl : Integer;
Begin
  FillChar(AranyTomb,Sizeof(AranyTomb),0);
  If Xnagyitas Then
    For Cikl := 0 To Xpont-1  Do
      AranyTomb[Cikl] := (Round((Cikl+1)*Xarany)-1) - Round(Cikl*Xarany) + 1
  Else
    For Cikl := 0 To PxPont-1 Do
      AranyTomb[Cikl] := (Round((Cikl+1)*(1/Xarany))-1) -
                          Round(Cikl*(1/Xarany)) + 1
End;

Procedure YNagyit;
Var Cikl   : Integer;
Begin
  If Ynagyitas Then
    For Cikl := 0 To YSor-1 Do
      AranyTombY[Cikl] := (Round((Cikl+1)*Yarany)-1) -
                           Round(Cikl*Yarany) + 1
  Else
    For Cikl :=0 To PySor-1 Do
      AranyTombY[Cikl] := (Round((Cikl+1)*(1/Yarany))-1) -
                           Round((Cikl)*(1/Yarany)) + 1
End;


Procedure PicInit;
Var Cikl         : Integer;
    Fmeret,
    Fmeret1,
    Fmeret2      : Longint;
    Xlong, Ylong : longint;

Begin

  OpenRead(KepFileName);

  KepNyomas := (IoError = 0);

  Esc := Not KepNyomas;
  If KepNyomas Then
    Begin

      ReadRead(Handle,Xbyte,2);
      ReadRead(Handle,Ysor,2);

      Xlong := Xbyte;
      Ylong := Ysor;

      Fmeret1 := Xlong*Ylong+4;       {egyezik a meret = en csinaltam?}
      Fmeret2 := ((Xlong+7) Div 8)*Ylong+4;
      Fmeret  := FileSizeRead(Handle);

      Kepnyomas := (Fmeret = Fmeret1) Or (Fmeret = Fmeret2);
      If Kepnyomas then
       Begin

         If Fmeret=Fmeret2 Then
           Begin
             Xpont := Xbyte;
             Xbyte := (Xpont+7) Div 8
           End
         Else
           Xpont := XByte * 8;

         PxPont     := EgyChrX*Karakterek;
         PxByte     := (PxPont+7) Div 8;

         Csik  := $FF shr (PxPont Mod 8);
         Csik  := Csik xor $FF;

         Xarany    := PxPont/Xpont;
         Xnagyitas := Xarany >= 1;

         PySor     := Felsorok*(EgySorY+1);

         Yarany    := PySor/Ysor;
         Ynagyitas := Yarany >= 1;

         Xnagyit;
         Ynagyit;

         Ymaradek  := 0;
         SorCount  := 0;
         SorCountI := 0;
       End
      Else
        If Not(Previewban) Then
          Error(24,KepFileName);
    End
  Else
    If Not(Previewban) Then
      Error(1,KepFileName);

End;
{----------------------------------------------------------}
Procedure EgyFelsortAd;

Var Cikl,Cikl2    : Integer;
         tolto    : byte;
         Tologat,
         VegeOr,
         TetejeOr : Byte;

Begin

  PufferTorol;

  Cikl := 0;
  If YNagyitas Then
    Repeat

      While (Ymaradek <> 0) And (Cikl<=EgySorY) Do
        Begin
          Sorkep^[Cikl] := OutputB;            {ha tagit, akkor nem kell OR !}
          Inc(Cikl);
          Dec(Ymaradek)
        End;

      If (Cikl<=EgySorY) Then
        Begin
          ReadRead(Handle,InputB,Xbyte);
          Esc := ioresult <> 0;
          If Esc then exit;
          Tolto := $00;

          If Not(InverzKep Xor WhitePrior) Then
            Tolto := $FF;

          if WhitePrior then
            BuffNegal(@InputB,sizeof(InputB));  {@@@}

          fillchar(outputB,sizeof(outputB),tolto);

          If Xnagyitas Then
            Tagit(@InputB,@OutputB,Xbyte,@AranyTomb)
          Else
            Szukit(@InputB,@OutputB,PxByte,@AranyTomb);

          Ymaradek := AranyTombY[SorCountI];
          Inc(SorCountI);
        End;
    Until Cikl = EgySorY+1
  Else
    For Cikl := 0 To EgySorY Do
      For Cikl2 := 1 To AranyTombY[SorCount*(EgySorY+1)+Cikl] Do
        Begin
          {$i-}
          ReadRead(Handle,InputB,Xbyte);
          {$i+}
          Esc := ioresult <> 0;
          If Esc then exit;

          Tolto := $00;
          If Not(Inverzkep XOR whiteprior) Then
            Tolto := $FF;

          if WhitePrior then
            BuffNegal(@InputB,sizeof(InputB));  {@@@}

          fillchar(outputB,sizeof(outputB),tolto);

          If Xnagyitas Then
            Tagit(@InputB,@OutputB,Xbyte,@AranyTomb)
          Else
            Szukit(@InputB,@OutputB,PxByte,@AranyTomb);

          EgySorOrol(Cikl);
          Inc(SorCountI);
        End;

  Inc(SorCount);
  If SorCount = Felsorok Then CloseRead(Handle);

  If Not(InverzKep Xor WhitePrior) then
    BuffNegal(SorKep,sizeof(SorKep^));

  If Csik <> 0 Then
    For Cikl := 0 To EgySorY Do
      SorKep^[Cikl,PxByte-1] :=
        SorKep^[Cikl,PxByte-1] And Csik;

  If FrameKep Then
    Begin
      Tologat := (Pxbyte*8-PxPont);
      VegeOr   := 1 Shl Tologat;
      TetejeOr := ($FF shr Tologat) shl Tologat;
      For Cikl := 0 To EgySorY Do
        Begin
          SorKep^[Cikl,0]        := SorKep^[Cikl,0]        Or $80;
          Sorkep^[Cikl,PxByte-1] := Sorkep^[Cikl,PxByte-1] Or VegeOr
        End;
      If SorCount = 1 Then
        Begin
          For Cikl := 0 To PxByte-2 Do
            SorKep^[0,Cikl] := $FF;
          SorKep^[0,PxByte-1] := TetejeOr;
        End;
      If SorCount = Felsorok Then
        Begin
          For Cikl := 0 To PxByte-2 Do
            SorKep^[EgySorY,Cikl] := $FF;
          SorKep^[EgySorY,PxByte-1] := TetejeOr;
        End;
    End;

End;

{-------------------------------------------------------}
Procedure KepfileNez(ScrMod : Boolean;Ize : Pointer);

Var
    Ws          : St16;

    P,E         : Integer;
    Cikl,
    Cikl1       : Integer;

    NyomtatChar,
    NyomtatAttr : PMutat;
    SorKepLoc   : SorKepType;

Const                {ovr   nymodus}
      Yfelek    : Array[0..11,0..3] Of Byte =
      (
       (11,5,10,11),    { 8 tus }
       (19,19,19,11),   { LASER }
       (11,11,11,11),   { Robotron }
       (11,15,15,11),   { 24 tus }
       (11,5,15,11),    { 30 tus }
       (11,11,11,11),   { Repulo }
       (11,15,15,11),   { BubbleJet }
       (11,19,19,11),   { DeskJet }
       (11,19,19,11),   { DeskJet grafikus }
       (11,15,15,11),   { 24 tus }
       (11,15,15,11),   { 24 tus }
       (19,19,19,11)    { LASER }
       );
            {11 =  lparam‚ter, ha abban a modban nincs grafika}

      Xpszeles : Array[0..11,0..3] Of Byte =
      ((11,12,12,11),  { 8 tus }
       (30,30,30,11),  { Laser }
       (11,11,11,11),  { Robotron }
       (11,18,36,11),  { 24 tus }
       (11,12,24,11),  { 30 tus }
       (11,11,11,11),  { Repulo }
       (11,18,36,11),  { Bubblejet }
       (11,30,30,11),  { DeskJet }
       (11,30,30,11),  { DeskJet grafikus}
       (11,18,36,11),  { 24 tus }
       (11,18,36,11),  { 24 tus }
       (30,30,30,11)   { Laser }


       );

Procedure FelSorAtad;                {----------------}

Var Cikl, Cikl1 : Integer;

Begin

    {$IFDEF LICENC}
    FelulIrta := False;
    {$ENDIF}
    Cikl := KepXKezdet+1;     { Ez egy string ! }
    Cikl1:= 33;
    Repeat
      {$IFDEF LICENC}
      If Not (NyomtatChar^[Cikl] In [' ',#00]) Then
        FelulIrta := True;
      {$ENDIF}
      NyomtatChar^[Cikl] := Char(Cikl1);
      NyomtatAttr^[Cikl] := Char(KepFont);
      Inc(Cikl);
      Inc(Cikl1);
    Until (Cikl = c79) Or (Cikl > KepXKezdet+Karakterek);

    EgyFelsortAd;

    If Esc then
      Begin
        Kepnyomas := false;
        Error(26,'');
        Exit;
      End;

    If SorCount = Felsorok then
      Kepnyomas := false;

    {$IFNDEF VER352}
    If NyModus = 4 Then
      Begin { Preview }
        If PrevHely <> Nil Then
          AtpakolX;
      End
    Else
    {$ENDIF}
      Case Ppar.pr_ovr of
        0:  Begin
             Font11 := Ptr(PKepSeg,PKepOffs);
             ATPAKOL8(SorKep,Font11,
               MaxNyomSzel+1,PxByte,(EgySorY+1)*4,EgySorY+1);
            End;
 3,6,9,10:  ATPAKOL24(SorKep,PxByte);
        4:  Begin
              Case Nymodus of
              1: Begin
                  Font11 := Ptr(PKepSeg,PKepOffs);
                  ATPAKOL8(SorKep,Font11,
                    MaxNyomSzel+1,PxByte,(EgySorY+1)*4,EgySorY+1);
                 End;
              2: ATPAKOL24(SorKep,PxByte);
              End {Case}
            End;
        7:  If NyModus In [1,2] Then
              AtpakolDesk
      End; { Case Ppar.pr_ovr }

End;

Procedure Cmd(St: string);

Var t: byte;

Begin
  For t:= 1 to length(St) do
    Begin
      Lprint(byte(St[t]));
      If Esc then exit;
    End;
End;

Procedure LaserKepNyom;

Var Sorok,Byteok  : Integer;
    SzelesStr,
    XposStr,
    ystr,
    YposStr       : string[8];
    x : word;
    Cikl,Cikl2,
    Cikl3      : Integer;
    Ezt,Erre   : Array[0..2] Of BitSor;

Begin

  x:= (kepXkezdet + PrintMargin)*30;   {vizszintes korrekcio = 30}

  if nymodus = 0 then                       {fuggoleses korrekcio}
    begin
      ystr := '-16'
    end
  else
    begin
      ystr := '+8';
      dec(x,4);                                {picit balra}
    end;

  Str(X:0, XposStr);
  Str(PXbyte:0, SzelesStr);

  Cmd(#27'&f0S');              {push xy}
  Cmd(#27'*p'+ XposStr +'X');  {goto kep-pos X}
  Cmd(#27'*p'+ ystr    +'Y');  {y korrekcio}


  Cmd(#27'*t300R');            {resolution 300 dot/inch}
  If Formatum Then
    Begin
      Cmd(#27'*r1A');              {start graf at cur}

      Repeat

        EgyFelSortAd;                            {tombot feltolt}

        If Esc then
          Begin
            Kepnyomas := false;
            Error(26,'');
            Cmd(#27'*rB');  {end grafik}
            Cmd(#27'&f1S'); {pop xy}
            Exit;
          End;

        For Sorok := 0 to EgySorY do
         Begin
           Cmd(#27'*b'+ SzelesStr +'W');        {send graf data}
           For Byteok := 0 to PXByte-1 do
             Begin
               Lprint(SorKep^[Sorok,Byteok]);
               If ESC then
                 Begin
                   Kepnyomas := false;
                   Exit;
                 End;
             End;
         End;
      Until SorCount = Felsorok;
      Cmd(#27'*rB');  {end grafik}

    End
  Else      { Landscape kepnyomtatas }
    Repeat

      EgyFelSortAd;                            {tombot feltolt}

      If Esc then
        Begin
          Kepnyomas := false;
          Error(26,'');
          Cmd(#27'*rB');  {end grafik}
          Cmd(#27'&f1S'); {pop xy}
          Exit;
        End;

      Str((X + PXbyte*8-1):0, XposStr);

      Cmd(#27'*p'+ XposStr +'X');  {goto kep-pos X}

      Cmd(#27'*r1A');              {start graf at cur}

      For Cikl3 := (PXByte - 1) DownTo 0 Do
        Begin
          For Cikl := 0 To 2 Do
            Begin
              For Cikl2 := 0 To 7 Do
                Ezt[Cikl][Cikl2] := SorKep^[Cikl2+Cikl*8,Cikl3];
              Fillchar(Ezt[2,3],5,0);
              Bitforgat(ezt[Cikl],erre[Cikl],True);
            End;

          For Sorok := 0 To 7 Do
            Begin
              Cmd(#27'*b3W');        {send 3 byte graf data}
              For Byteok := 0 To 2 Do
                Begin
                  Lprint(Erre[Byteok,7-Sorok]);
                  If ESC then
                    Begin
                      Kepnyomas := false;
                      Exit;
                    End;
                End;
            End;
        End;  {  0 - PxByte }
      Cmd(#27'*rB');  {end grafik}
      Cmd(#27'*p+19Y');  { 19-cel lejjebb megyunk }

    Until SorCount = Felsorok;

  Cmd(#27'&f1S'); {pop xy}

  KepNyomas := false;
End;


 var t: byte;

Begin                      {kep file-t nez}


  ESC := False;
  SorKep := @SorKepLoc;
  If (Not ScrMod)   {$IFDEF LICENC}               {!!!!! F.I.}
     And (Not LicencKep)
                  {$ENDIF} Then
    Begin
      NyomtatChar   := @Image[LastLine]^.Attribs[c79];
      NyomtatAttr   := @Image[LastLine-1]^.Chars[C80+c79];

      NyomtatAttr^[0] := Char(C78);
      NyomtatChar^[0] := Char(C78);

    End
  Else
    NyomtatChar := Ize;

  If (KepNyomas And Not(ScrMod)) Then FelSorAtad
  Else                                               {.PIC, .! figyeles}
  Begin

    P := Pos('.REM',NyomtatChar^);
    If P <> 0 Then
    For Cikl1 := P to c78 do
      NyomtatChar^[Cikl1] := ' ';

    P := Pos('.PIC=',NyomtatChar^);

    If (Enabled[2]) AND (P <> 0) Then
      Begin
        Cikl := P+5;
        KepFileName:='';
        While (Cikl <= c78) And (NyomtatChar^[Cikl] <> ',') Do
          Begin
            KepFileName := KepFileName+NyomtatChar^[Cikl];
            Inc(Cikl)
          End;
        Inc(Cikl);
        CheckFileName(KepFileName);
        Esc := Esc Or (Cikl > c78);
        If Not ESC Then
          Begin
            Ws := '';
            While (Cikl <= c78) And (NyomtatChar^[Cikl] <> ',') Do
              Begin
                Ws := Ws+NyomtatChar^[Cikl];
                Inc(Cikl)
              End;
            Val(Ws,Karakterek,E);

            If Karakterek < 1 Then
              e := 4;
            If Karakterek > 78 Then
              e := 78;

            Inc(Cikl);
            Esc := (E <> 0) Or (Cikl>78);

            If Not ESC Then
              Begin
                Ws := '';
                While (Cikl <= c78) And (NyomtatChar^[Cikl] In ['0'..'9']) Do
                  Begin
                    Ws := Ws+NyomtatChar^[Cikl];
                    Inc(Cikl)
                  End;
                Val(Ws,Felsorok,E);
                If  Felsorok < 1 Then
                  e := 4;
                If Felsorok > 999 Then
                  e := 999;
                ESC := E <> 0;
                If E = 0 Then
                  Begin
                    Inverzkep  := False;
                    FrameKep   := False;
                    WhitePrior := True;
                    While (Cikl <= C77) And (NyomtatChar^[Cikl] = ',') Do
                      Begin
                        Inc(Cikl);
                        Case UpCase(NyomtatChar^[Cikl]) Of
                          'I': Inverzkep  := True;
                          'F': FrameKep   := True;
                          'W': WhitePrior := False;
                        End;
                        Inc(Cikl)
                      End;
                    Dec(Cikl);

                    If Not ScrMod Then
                      Begin
                         VoltKepNev  := True;                 { figyelni .!  -t }
                         {$IFNDEF VER352}
                         If Nymodus = 4 Then
                           Begin  { Preview }
                             EgyChrX := PrevXs;
                             EgySorY := (PrevYs Div 2)-1;
                           End
                         Else
                         {$ENDIF}
                           Begin
                             EgyChrX := XpSzeles[ppar.pr_ovr,Nymodus];
                             EgySorY := Yfelek[ppar.pr_ovr,Nymodus]-1;

                             If ppar.pr_set_l_m[2] = #39 then
                               EgyChrX := 18;                     { LQ 1500!! }
                           End;
                         For Cikl1 := P to Cikl do
                            NyomtatChar^[Cikl1] := ' ';
                       End
                  End
              End
          End
      End;
      If Enabled[2] AND VoltKepNev Then
        Begin
          P := Pos('.!',NyomtatChar^);

          If P <> 0 then                          {csak ha attributum = 1}
            for t:= 0 to 1 do
            if (byte(NyomtatAttr^[p+t]) and 15) <> 1 then P := 0;

          If (P <> 0) And (TrueNyomas) Then
            Begin
              KepXKezdet := P-1;
              Picinit;
              If Not Esc then
               Begin
                 If KepNyomas Then
                   Begin
                    NyomtatChar^[P]   := ' ';    { .! -et torol }
                    NyomtatChar^[P+1] := ' ';
                    If (ppar.pr_ovr In [1,11]) And (NyModus < 3) then
                      LaserKepNyom                 {teljes kepet kinyom!}
                    Else
                      FelSorAtad;
                   End
               End
            End
        End
  End
End;


Procedure ScrNegal;

var t: word;

Begin

(*
  case grmode of


  CgaMode :  BuffNegalW(ptr($b800,0),$4000);
  EgaMOde :  BuffNegalW(ptr($a000,0),$8000);
  HerMode :  BuffNegalW(ptr($b000,0),$8000);

 end;
   *)


  t := 3;
  repeat
    inv_line(t,0,77,0,sortaboffs,0);
    inc(t,2);
  until t > (LastLine+1);
  inv_line(LastLine+2,0,77,0,sortaboffs,1);



End;



Procedure View_pic;

Var SC          : Str160;
    abspos, scrs, inc1,inc2, ovf : word;
    t,kepkix    : Word;
    SorKepLoc   : SorKepType;
    NyomtatChar : PMutat;
    XpKep       : Integer;
    Cikl        : Integer;
    HEAPP       : Lpoint;
    KsorC       : Integer;
    Sorszam     : Longint;
    Ennyiediksor: word;

Begin
  If Enabled[2] Then
  Begin
    Fs := '.PIC=';
    KSorC := FirstLine;

    ScrNegal;

    Repeat
      {.! = -t keres az IMAGE-n}
      Cikl := 0;
      XpKep := -1;

      While (Cikl<=C76) And (XpKep = -1) Do
        If (Image[KSorc]^.Chars[C80+Cikl+XOffset] = '.') And
           (Image[KSorc]^.Chars[C80+Cikl+1+XOffset] = '!') And
           ((Image[KSorc]^.Attribs[Cikl+XOffset] and 15) = 1) And
           ((Image[KSorc]^.Attribs[Cikl+1+XOffset] and 15) = 1) Then
          XpKep := Cikl
        Else
          Inc(Cikl);

      Inline($FC); {CLD}

      IF XpKep <> -1 then
        Begin
          Ennyiediksor := 0;
          Sorszam   := BSearch(Seg(PointerTomb^),
                          0,
                          Ofs(Fs),
                           Ofs(PointerTomb^),
                            ImageToHeap[KSorC],
                             StartLine[EditNum],
                              HeapRec.Segment,
                               0,
                                0);

          EnnyiedikSor := Sorszam SHR 16;

          If EnnyiedikSor <> 0 Then
            Begin

              SorKep := @SorKepLoc;

              Heap_Pos(Heapp,PointerTomb^[EnnyiedikSor]);
              Move(Heapp^.Chars[C80],Sc[1],c79);
              FreeEms1(PointerTomb^[EnnyiedikSor]);
              Sc[0] := Char(C79);

              NyomtatChar := @Sc;
              VoltKepNev := False;
              KepFileNez(True,NyomtatChar);

              If Not ESC Then
                Begin
                  KepXKezdet := XpKep;
                  KepYKezdet := KsorC+2;

                  Case GrMode Of
                    CgaMode :  begin
                                abspos := cgasortab[kepYkezdet];
                                scrs := $b800;
                                inc1 := $2000;
                                inc2 := 80;
                                ovf  := $4000;
                                EgySorY := 5-1; { CGA !!! }
                               end;
                    EgaMode,
                    VgaMode :  begin
                                abspos := Vgasortab[kepYkezdet];
                                scrs := $a000;
                                inc1 := 80;
                                inc2 := 0;
                                ovf  := $ffff;
                                EgySorY := 8-1; { EGA !!! }
                               end;
                    HerMode :  begin
                                abspos := hersortab[kepYkezdet];
                                scrs := $b000;
                                inc1 := $2000;
                                inc2 := 90;
                                ovf  := $8000;
                                EgySorY := 8-1; { Herc !!! }
                               end;
                  End;

                  EgyChrX := 8;
                  PicInit;

                  If KepNyomas Then                {csak ha van es jo a file}
                    Begin
                      kepkiX := PxByte;
                      If kepXkezdet + KepKiX > c78 Then
                        KepKiX := c78-KepXkezdet;

                      Repeat
                        EgyFelSortAd;

                        If Esc then
                         Begin
                           Kepnyomas := false;
                           Error(26,'');
                           Exit;
                         End;

                        BuffNegal(SorKep,Sizeof(SorKep^));  {@@@@@}

                        For t:= 0 to EgySorY do
                           Begin
                             If kepYkezdet <> 2 Then    { tabulatort felul irna }
                               move(sorkep^[t],MEM[scrs:abspos+kepXkezdet],kepkiX);
                             inc(abspos,inc1);
                             if abspos >= ovf then
                               dec(abspos,ovf-inc2);
                           End;
                        Inc(kepYkezdet);
                      Until (SorCount = Felsorok) or (kepYkezdet > LastLine+2);

                      If sorcount <> felsorok then
                       Begin
                         CloseRead(Handle);
                         kepnyomas := false;
                       End;
                      Inc(KSorC,Felsorok-1);
                      Kepnyomas := False;
                    End;  { if kepnyomas }
                End; { If NOT ESC }
            End;   { If van .PIC }
        End; { If van .! }

      Inc(KSorc);
    Until (KSorC > TrueLast);

    Stop;
  End;
End;



{--------------------- Kepfeldolgozas vege --------------------}

Function Van_Sor2 : Boolean;
Begin

  If KovFalse Then
    Van_Sor2 := False
  Else
    Case Nyomas Of
      Header: Begin
                If (HeaderCount <> MaxHeader) And Van_Belole Then
                  Begin
                    Van_Sor2 := True;
                    Inc(HeaderCount);
                    ChangeElvalasztojel;
                    ChangeCtp;
                    SeekRemPrint;
                  End
                Else
                  Begin
                    RestoreMain;
                    Nyomas := MainPage;
                    Van_Sor2 := Van_Sor2
                  End
              End;
     MainPage:Begin
                Inc(FoPr);
                If KellMeg = 0 Then
                  Begin
                    If Van_Belole Then
                    Begin
                      Van_Sor2 := True;
                      ChangeElvalasztojel;
                      SeekRemPrint;
                    End
                    Else
                      Begin
                        VegeLesz := True;
                        FillImageLine(LastLine);
                        Set_BitsI(LastLine,$FF,LapVege);
                      End;
                    If LapVegeI(LastLine) Then
                      Begin   { Ha barmi miatt vege a lapnak }
                        Set_BitsI(LastLine,$FF-LapVege,0);
                        KellMeg := PageLen - FoPr; { Ennyi van meg }
                        If KellMeg = 0 Then
                          JonAFooter             { Ha nincs, footer jon }
                        Else
                          Van_Sor2 := True
                      End
                  End { Egy sor toltogetese }
                Else
                  Begin  { Ures sorokat adogat }
                    FillImageLine(LastLine);
                    Van_Sor2 := True;
                    Inc(LinecPr);
                    Dec(KellMeg);
                    If KellMeg = 0 Then
                      JonAFooter;  { Elfogyott, jon a footer }
                  End; { Kihagyando sorok toltogetese }
              End; {  Fo szoveg }
{$IFDEF LICENC}
      Footer :If KellMeg = 0 Then
                Begin
                  If (HeaderCount <> MaxHeader) Then
                    If Van_Belole Then
                      Begin   { meg van belole }
                        Set_BitsI(LastLine,$FF-LapVege,0);
                        Van_Sor2 := True;
                        Inc(HeaderCount);
                        ChangeElvalasztojel;
                        ChangeCtp;
                        SeekRemPrint;
                        If (HeaderCount = MaxHeader) Then
                          NewPage;
                      End
                    Else
                      Begin { meg lehetne, de mar nincs belole }
                        Set_BitsI(LastLine,$FF-LapVege,0);
                        KellMeg := (MaxHeader+PageLen) - LinecPr;
                        If KellMeg = 0 Then
                          Begin
                            NewPage;
                            Van_Sor2 := Van_Sor2;
                          End
                        Else
                          Van_Sor2 := Van_Sor2
                      End
                  Else
                    Begin  { Mar nem lehet tobb sor }
                      FillImageLine(LastLine);
                      NewPage;
                      Van_Sor2 := Van_Sor2;
                    End;
                End  { ha KellMeg = 0 }
              Else
                Begin { ha KellMeg <> 0 }
                  FillImageLine(LastLine);
                  Van_Sor2 := True;
                  Inc(LinecPr);
                  Inc(HeaderCount);
                  Dec(KellMeg);
                  If (KellMeg = 0) Or (HeaderCount = MaxHeader) Then
                    NewPage;

                End; { Kihagyando sorok toltogetese }
{$ELSE}
      Footer :Begin
                If (HeaderCount <> MaxHeader) And Van_Belole Then
                  Begin
                    Van_Sor2 := True;
                    Inc(HeaderCount);
                    ChangeElvalasztojel;
                    ChangeCtp;
                    SeekRemPrint;
                    If (HeaderCount = MaxHeader) Or ((NemKellPr = FullPr) AND
                                                       LastMain(HeapPr)) Then
                      Set_BitsI(LastLine,$FF,LapVege) { Vege a lapnak }
                  End
                Else
                  Begin
                    NewPage;
                    Van_Sor2 := Van_Sor2  { Rekurzio }
                  End
              End { Footer }

{$ENDIF}

      End;  {  Case }

  {$IFDEF DEMO}
  If NyModus <> 4 Then
    INC(demo_nyom_sorok);
  If demo_nyom_sorok > 200 Then
    Begin
      KovFalse := True;
      Set_BitsI(LastLine,$FF,LapVege);
    End;

  {$ENDIF}

  {$IFDEF LICENC}
  If( EmblemaMod In[3..4]) And
     (LinecPr = ((PageLen+MaxHeader)-EmbYLen)-1)  Then
     Begin
       FirstLineVan := True;
       If EmblemaMod = 3 Then
         EmblemaXpos := 0
       Else
         EmblemaXpos := c78-PrintMargin-EmbXLen
     End;
  {$ENDIF}

End; { Van_Sor2 }

Function Van_Sor : Boolean;
Var KepSt        : String[128];
    LapDobVolt   : Boolean;
Begin
  OldNyomas := Nyomas;
  Van_Sor := False;
  If Van_Sor2 Then
    Begin
      Van_Sor := True;
      Set_BitsI(LastLine,$FF-Fosor,0);
      If Boolean(PluszFont) Then
        Begin
          {$IFDEF LICENC}
          If FirstLineVan Then
            Begin
              FillChar(KepSt,SizeOf(KepSt),' ');
              KepSt := LicencP1+FontPath+LicencP2;
              LicencKep := True;
              KepFileNez(False,@KepSt);
              LicencKep := False;
              If Not((Image[LastLine]^.Chars[C80+EmblemaXPos+00] In[' ',#0]) And
                     (Image[LastLine]^.Chars[C80+EmblemaXPos+01] In[' ',#0])) Then
                FelulIrta := True;
              Image[LastLine]^.Chars[C80+EmblemaXPos+00] := '.';
              Image[LastLine]^.Chars[C80+EmblemaXPos+01] := '!';


              Image[LastLine]^.Attribs[EmblemaXPos+00] :=
                (Image[LastLine]^.Attribs[EmblemaXPos+00] And $F0) Or 1;

              Image[LastLine]^.Attribs[EmblemaXPos+01] :=
                (Image[LastLine]^.Attribs[EmblemaXPos+01] And $F0) Or 1;

              FirstLineVan := False;
              Emblema := True;
            End;
          {$ENDIF}
          LapDobVolt := LapVegeI(LastLine);
          KepFileNez(False,nil);
          If LapDobVolt Then
            Set_BitsI(LastLine,$FF,LapVege);
          {$IFDEF LICENC}
          If FelulIrta And Not(SzoltMar) Then
            Begin
              SzoltMar := True;
              ErrorStNum := 2;
              If Not MostExtVan Then
                Error(20,ElveszettSt);
              ErrorStNum := 1;
            End;
          {$ENDIF}
        End;

      With CLV^ Do
        If (CimFile <> '') and (VarNum > 0) then Korlevel;

      If LapVegeI(LastLine) And
         (CimFile <> '')    and
         (CLV^.VarNum > 0)  And
         (not KellLapdob)   Then
       KovFalse := True;

    End;
  {$IFDEF LICENC}
  If LicencElsoLesz Then
    Begin
      FirstLineVan := True;
      LicencElsoLesz := False;
    End;
  {$ENDIF}

  LapReszV := ((OldNyomas = Header)   And (Nyomas In [MainPage,Footer])) Or
              ((OldNyomas = MainPage) And (Nyomas = Footer));

End;

Procedure AlahuzottSpaceCsere(Var CHR : Char;
                                  ATT : Byte);
Begin
  If AlahuzottE(ATT) AND
      ((MagyarE(ATT)   AND (CHR='%')) Or
       (OroszE(ATT)    AND (CHR='+')) Or
       (StandardE(ATT) AND (CHR='_'))) Then
    CHR := ' ';
End;


End.

