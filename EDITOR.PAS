Unit Editor;

{$O+}

Interface

Uses

  Crt,
  Dos,
  Video,     { CGA5.OBJ + DISPLAY.OBJ Assembly rutinok }
  BGI,
  WindowM,
  MenuErr,
  InputCdw,InputOVR,

{$IFNDEF CDVIEW}
  {$IFNDEF VER3}
  Publicat,
  {$ENDIF}

  StartNyo,
  Nyomtat,
  Szotag,
  SetCdw,
{$ENDIF}

  HeapCdw,
  FileCdw,
  EmsCdw,

  CalcCdw,

  {$IFDEF PROBA}
   PRINTER,
  {$ENDIF}

  {$IFNDEF DPMI}
  Overlay,
  {$ENDIF}

  {$IFDEF HELYESKE}
  Strings,
  PlusMem,
  Elemez,
  {$ENDIF}

  Speakcdw;
  { Ems kezelo }

Procedure Edit;

Implementation


Procedure Edit;

{$IFNDEF CDVIEW}
Procedure CallGib(Par : Byte; Var X1,X2: Byte); Forward;
{$ENDIF}


{$I ELEJE.CDW}

Var
  Lastpos,Fkeycount,kc,bc,Lastsc : BYTE;
  Cikl    : Integer;

Function FullOfComplex(Hp:Integer):Integer;
Begin
  FullOfComplex := UpInd(HP) + DownInd(Hp) + 1
End;

Procedure LapvegKi(Li:Integer);
Begin
  If LapVegeI(Li) Then
    Begin
      Dec(Pcount);
      Lcount := PopLapveg
    End
  Else
    If Lcount = 0 Then
      Begin
        Dec(Pcount);
        Lcount := PageLen-1;
      End
    Else
      Dec(Lcount);
End;

{$I SCROLL.CDW}

Procedure SeekToMain;
Begin
  If NOT MainLineI(Ypos) Then
    Begin
      If UpIndexI(Ypos) Then
        While NOT MainLineI(Ypos) do
          HalfLineDown
      Else
        While NOT MainLineI(Ypos) do
          HalfLineUp
    End;
End;

Procedure SeekToMain2;
Var NewY : Integer;
    Cikl : Integer;

Procedure Felfele;
Begin
  If NewY = Ypos Then
    Begin
      Cikl := Ypos -1;
      While (Cikl > FirstLine) And (NewY=Ypos) Do
        If MainLineI(Cikl) Then
          NewY := Cikl
        Else
          Dec(Cikl);
    End
End;

Procedure Lefele;
Begin
  If NewY = Ypos Then
    Begin
      Cikl := Ypos +1;
      While (Cikl < LastLine) And (Cikl <= TrueLast) And (NewY=Ypos) Do
        If MainLineI(Cikl) Then
          NewY := Cikl
        Else
          Inc(Cikl);
    End
End;

Begin
  If NOT MainLineI(Ypos) Then
    Begin
      NewY := Ypos;
      If Ypos < (TrueLast Div 2) Then
        Begin
          Felfele;
          Lefele
        End
      Else
        Begin
          Lefele;
          Felfele
        End;
      If Ypos <> NewY Then
        If Ypos < NewY Then
          While Ypos <> NewY do
            HalfLineDown
        Else
          While Ypos <> NewY do
            HalfLineUp
    End;
End;

Procedure PosOfPrevPage(Var Hp,Sor,Nemkell : Integer;Hanyat : Integer);
Var f : Integer;
Begin
  If Sor > Hanyat Then
  Begin
    Nemkell := Sor - Hanyat;
    Sor := Hanyat
  End;
  While (Sor < Hanyat) And Not(FirstMain(Hp)) Do
  Begin
    Hp := PrevMain(Hp);
    F  := FullOfComplex(Hp);
    If F + Sor > Hanyat Then
      Begin
        NemKell := F + Sor - Hanyat;
        Sor := Hanyat;
      End
    Else
      Begin
        Inc(Sor,F);
        NemKell := 0;
      End
  End
End; { PosOfPrevPage }

Procedure FreshPage;
Var Cik : Integer;
Begin
  Disp_Page(0,0,0,FontOffs,SortabOffs,ImageOffs);
  Page_Stat(0,TrueLast+2,0,FontOffs,SortabOffs,ImageOffs);
  PageEndCount;      {  Lapvegek bejelolese az image- en  }
  PageEndFresh(FirstLine);

  New_Header;
  Fresh_Header;
  Fejtab(1);

  If TrueLast = FirstLine Then
    Begin
      HalfScrollUp;
      TrueLast := FirstLine + 1;
      Ypos := TrueLast;
    End;
  {$IFNDEF CDVIEW}
  If BlockMode Then
    Begin
      Block_End;
      For Cik := Byte(LegFelso) To TrueLast Do
        InvertLine(Cik,True);
    End;
  {$ENDIF}

  SorCurBe;
End;

Procedure FreshPage2(Mettol,Meddig:Word);
Var Cik     : Integer;
    CCS     : Array[FirstLine..MLastLine] Of Char;
Begin

  Arr^.Disp78 := Meddig-Mettol+1;
  Disp_Page(Mettol,0,0,FontOffs,SortabOffs,ImageOffs);
  Arr^.Disp78 := 78;

  Fejtab(1);

  If TrueLast = FirstLine Then
    Begin
      HalfScrollUp;
      TrueLast := FirstLine + 1;
      Ypos := TrueLast;
    End;

  {$IFNDEF CDVIEW}
  If BlockMode Then
    Begin
      For Cik := Byte(LegFelso) To TrueLast Do
        Begin
          CCS[Cik] := Image[Cik]^.Chars[C80+c79];
          Image[Cik]^.Chars[C80+c79] := #0;
        End;
      For Cik := Byte(LegFelso) To TrueLast Do
        InvertLine2(Cik,True,Mettol,Meddig);
      For Cik := Byte(LegFelso) To TrueLast Do
        Image[Cik]^.Chars[C80+c79] := CCS[Cik];

    End;
  {$ENDIF}
End;

Procedure RangeCheck(Var Uj: Integer; Top: Byte);
Begin
  If Uj > (Top-1) Then Uj := Uj Mod Top;
  If Uj < 0 Then Inc(Uj,Top);
End;

Procedure Next_Color(Mennyit : Integer);
Var Uj : Integer;
Begin
  Uj := Color[EditNum];
  Inc(Uj,Mennyit);
  Case GrMode Of
     CGAMode : Begin
                 RangeCheck(Uj,16);
                 Port[$3d9] := Uj;
               End;
     EGAMode,
     VgaMode:  Begin
                 RangeCheck(Uj,64);
                 Set_EGA_Color(Uj);
               End
  End;
  Color[EditNum] := Uj
End;

Procedure Next_Background(Mennyit : Integer);
Var Uj : Integer;
Begin
  Uj := BackG[EditNum];
  Inc(Uj,Mennyit);

  RangeCheck(Uj,64);

  If (GrMode = EGAMode) Or (GrMode = VgaMode) Then EGA_Hatter(Uj);

  BackG[EditNum] := Uj
End;

Procedure CheckXpos(KellFr:Boolean);
Var OldXo : Word;
    Kul   : Word;
Begin
  OldXo := Xoffset;
  If Xpos-Xoffset > 77 Then
    Begin  { az Xoffset no }
      SetXoffset(scstep*(((Xpos-77)+(ScStep-1)) Div ScStep));
      If KellFr Then
        Begin
          Kul := Xoffset-OldXo;
          GlobLeszedes;
          If Kul > 77 Then
            Begin
              FreshPage2(0,77);
              Page_Stat(0,TrueLast+2,0,FontOffs,SortabOffs,ImageOffs);
              SorCurBe
            End
          Else
            Begin
              ScrollL(Kul);
              FreshPage2(78-Kul,77);
            End;
          GlobFelrakas;
        End;
    End
  Else
    If Xoffset > Xpos  Then
      Begin { az xoffset csokken }
        SetXoffset(Xoffset-ScStep*(((Xoffset-Xpos)+(ScStep-1)) Div ScStep));
        If KellFr Then
          Begin
            Kul := OldXo-Xoffset;
            GlobLeszedes;
            If Kul > 77 Then
              Begin
                FreshPage2(0,77);
                Page_Stat(0,TrueLast+2,0,FontOffs,SortabOffs,ImageOffs);
                SorCurBe;
              End
            Else
              Begin
                ScrollR(Kul);
                FreshPage2(0,Kul-1);
              End;
            GlobFelrakas;
          End;
      End;
End;


Procedure Top_text;
  Begin

   scount := 0; { Hanyadik felsor a file-ban }
   Lcount := 0; { Hanyadik felsor a lapon    }
   Pcount := 0; { Hanyadik lap               }
   PageHeapToImage(StartLine[EditNum],0);

   Xpos := LeftMar[EditNum];
   CheckXpos(False);

   Ypos := FirstLine +1;
   New_Header;
   Fresh_Header;
   FejTab(1);
   Disp_Page(0,0,0,FontOffs,SortabOffs,ImageOffs);
   {$IFNDEF CDVIEW}
   If BlockMode Then
     Begin
       Block_End;
       For Cik := Byte(LegFelso) To TrueLast Do
         InvertLine(Cik,True);
     End;
   {$ENDIF}
   Page_Stat(0,TrueLast+2,0,FontOffs,SortabOffs,ImageOffs);
   PageEndCount;
   PageEndFresh(FirstLine);
   SorCurBe;
   SeekToMain2;
   Fresh_Header;
  End;

Procedure End_text;
Var MainP,NemKell,Sor,D : Integer;
Begin
   MainP := EndLine[EditNum];    {  Utolso  sor      }
   While Not MainLine(Mainp) Do
     Dec(MainP);         {  Az utolso fosor  }
   NemKell := 0;
   Sor := FullOfComplex(MainP);
   PosOfPrevPage(MainP,Sor,NemKell,37);  { 37- et menjunk vissza }
   PageHeapToImage(MainP,Nemkell);
   D := 0;
   CountScount(MainP,NemKell,D,0);   {  Lap- es sorszamlalas }
   Ypos := TrueLast;
   FreshPage;
   SeekToMain2;    { Csak akkor hatasos, ha titkarnoi verzio }
   Fresh_Header
End;

Procedure SeekToLastp;
Var Mp : Integer;
    D  : Integer;
Begin

  Mp := StartLine[EditNum] + MainPs[EditNum]-1;
  Scount := Scounts[EditNum];
  PageHeapToImage(MP,Nemkells[EditNum]);
  Ypos    := Yps[EditNum];
  Xpos    := Xps[EditNum];

  SetXoffset(Xel[EditNum]);

  Pcount  := Pcounts[EditNum];
  Lcount  := Lcounts[EditNum];

  CheckXpos(False);

  D := 0;
  CountScount(Mp,NemKells[EditNum],D,0);

  FreshPage;

End;

Procedure SaveLastp;
Begin
  If LegFelso Then
    Begin
      MainPs[EditNum]   := MainOfIndex[FirstLine+1]-StartLine[EditNum]+1;
      Xps[EditNum]      := Xpos;
      Yps[EditNum]      := Ypos;
      Xel[EditNum]      := Xoffset;

      Scounts[EditNum]  := Scount + 1;
      Pcounts[EditNum]  := Pcount;
      Lcounts[EditNum]  := Lcount;
      NemKells[EditNum] := 0;
      If Ypos <> FirstLine + 1 Then
        Dec(Yps[EditNum])
    End
  Else
    Begin
      MainPs[EditNum]   := MainOfIndex[FirstLine]-StartLine[EditNum]+1;
      Xps[EditNum]      := Xpos;
      Yps[EditNum]      := Ypos;
      Scounts[EditNum]  := Scount;
      Pcounts[EditNum]  := Pcount;
      Lcounts[EditNum]  := Lcount;
      If MainLineI(FirstLine) Then
        NemKells[EditNum] := UpIndI(FirstLine)
      Else
        If UpIndexI(FirstLine) Then
          NemKells[EditNum] := UpInd(MainOfIndex[FirstLine])
                                  -UpIndI(FirstLine)
        Else
          NemKells[EditNum] := UpInd(MainOfIndex[FirstLine]) + 1
                                 +UpIndI(FirstLine)-1
    End;
End;

Procedure PosToPos(MainP,Xp   : Integer;
                   Mindenkepp : Boolean);
Var
  Sc          : Integer;
  Megvagy     : Integer;
  Sor,Nemkell : Integer;
  Teteje      : Integer;
  D           : Integer;

Procedure SeekToMegvan;
Begin
  SorCurKi;
  If Megvagy < Ypos Then
    While ImageToHeap[Ypos] <> MainP Do
      HalfLineUp;
  If Megvagy > Ypos Then
    While ImageToHeap[Ypos] <> MainP Do
      HalfLineDown;
  Xpos := Xp;
  SorCurBe;
End;

Procedure SearchMegvan;
Begin
  Megvagy := -1;
  Sc := FirstLine;
  If LegFelso Then Inc(Sc);
  Repeat
    If ImageToHeap[Sc] = MainP Then
      Megvagy := Sc;
    Inc(Sc)
  Until (Megvagy <> -1) Or (Sc= TrueLast+1);
End;

Begin {PosToPos}
  Megvagy := -1;
  If Not Mindenkepp Then
    SearchMegvan;
  If Megvagy <> - 1 Then
    Begin
      SeekToMegvan;
      CheckXpos(True);
    End
  Else
    Begin
      Sor     := 0;
      NemKell := 0;
      Teteje  := MainP;
      PosOfPrevPage(Teteje,Sor,NemKell,18);  { 18- at menjunk vissza }
      D := 0;
      CountScount(Teteje,NemKell,D,0);
      PageHeapToImage(Teteje,Nemkell);
      Ypos := 1;
      SearchMegvan;
      SeekToMegvan;
      CheckXpos(False);
      FreshPage
    End
End;

Procedure PosToPage(Pszam,Xp   : Integer);
Var
  Sc          : Integer;
  Megvagy     : Integer;
  Sor,Nemkell : Integer;
  Teteje      : Integer;
  MainP       : Integer;
  TOUT        : Word;
  Cur         : Byte;
  Scbuf       : Array [1..6*69*8] Of Byte;


Procedure SeekToMegvan;
Begin
  SorCurKi;
  If Megvagy < Ypos Then
    While ImageToHeap[Ypos] <> MainP Do
      HalfLineUp;
  If Megvagy > Ypos Then
    While ImageToHeap[Ypos] <> MainP Do
      HalfLineDown;
  Xpos := Xp;
  SorCurBe;
End;

Procedure SearchMegvan;
Begin
  Megvagy := -1;
  Sc := FirstLine;
  If LegFelso Then Inc(Sc);
  Repeat
    If ImageToHeap[Sc] = MainP Then
      Megvagy := Sc;
    Inc(Sc)
  Until (Megvagy <> -1) Or (Sc= TrueLast+1);
End;

Begin {PosToPage}

  If Pszam = 0 Then
    Begin
      TOUT := OutJel;
      Set_Nem_lehet;

      Cur := Gcur;

      FelSor_IdeOdaW(6,69,6,14,Ofs(ScBuf),Seg(ScBuf),SortabOffs,0);
      GrWindow(20,14,61,17,GoPageSt);
      SaveXY;

      GlobalFont := 2;
      MezoFont   := 1;

      MaxStringLen := 64;

      GotoX(22,14);
      PuffiRekurzio := True;

      Input_Integer(Enterpage,Pszam,24);
      PuffiRekurzio := False;
      FelSor_IdeOdaW(6,69,6,14,Ofs(ScBuf),Seg(ScBuf),SortabOffs,1);
      RestoreXY;

      RestoreCur(Cur);
      OutJel := TOUT;
    End;
  If Not ESC Then
    Begin
      Sor     := 0;
      NemKell := 0;
      MainP := 0;
      If Pszam < 1 Then
        Pszam := 1;


      CountScount(Teteje,NemKell,MainP,Pszam);

      If MainP = 0 Then
        Begin
          Beepel(660);
          Beepel(330);
          PosToPos(MainOfIndex[Ypos],Xpos,True)
        End
      Else
        Begin
          PageHeapToImage(MainP,Nemkell);
          Ypos := 1;
          SearchMegvan;
          SeekToMegvan;
          Xpos := LeftMar[EditNum];
          CheckXpos(False);
          FreshPage
        End;
    End
End;

Procedure Create_Szo(Var XX: Integer; Len: Byte);
Begin
  While NOT(NemBetuHeap(XX)) AND (XX <= Len) Do
  Begin
    Szo := Szo + Heapline^.Chars[C80+XX];
    SzoAtt := SzoAtt + Char(Heapline^.Attribs[XX] AND 15);
    Inc(XX);
  End;
End;

{$IFNDEF CDVIEW}

{$I BLOKK.CDW }

Procedure Change_Tab;
Begin
  If InInt(Xpos,LeftMar[EditNum],RightMar[EditNum]) Then
    Begin
      Tabs[Xpos] := NOT(Tabs[Xpos]);
      Make_Tabulators;
      FejTab(1);
    End
End;

Procedure HelyreTomorit;
Var OldJust : Boolean;
Begin
  OldJust := LegyenJust;
  LegyenJust := False;
  Just2(MainOfIndex[Ypos]);
  CheckXpos(True);
  ComplexToScreen(0,Ypos);
  LegyenJust := OldJust;
End;

Procedure HelyreIgazit;
Var OldJust : Boolean;
Begin
  OldJust := LegyenJust;
  LegyenJust := True;
  Just2(MainOfIndex[Ypos]);
  CheckXpos(True);
  ComplexToScreen(0,Ypos);
  LegyenJust := OldJust;
End;

Procedure InvertSorVeg;
Var MainI,MainP : Integer;
Begin
  MainI := CompMainI(Ypos);
  MainP := MainOfIndex[Ypos];
  Heap_Pos(HeapLine,PointerTomb^[MainP]);
  HeapLine^.Attribs[0] :=
    HeapLine^.Attribs[0] Xor KemenySor;
  FreeEms1(PointerTomb^[MainP]);

  If InInt(MainI,FirstLine,LastLine) Then
    Begin
      Image[MainI]^.Attribs[0] := Image[MainI]^.Attribs[0] Xor KemenySor;
      Fresh_Stat(MainI,MainI,True);
    End;

End;

{$IFDEF PROTECT}

Procedure ProtectLine(Protect: Boolean);
Var MainI,MainP : Integer;
Begin
  MainI := CompMainI(Ypos);
  MainP := MainOfIndex[Ypos];
  Heap_Pos(HeapLine,PointerTomb^[MainP]);
  If Protect Then
  Begin
    Beepel(600); Beepel(800); Beepel(1000);
    HeapLine^.Attribs[c77] := HeapLine^.Attribs[c77] OR Protected;
  End
  Else
  Begin
    Beepel(1000); Beepel(800); Beepel(600);
    HeapLine^.Attribs[c77] := HeapLine^.Attribs[c77] AND 255-Protected;
  End;

  If InInt(MainI,FirstLine,LastLine) Then
  Begin
    If Protect Then
    Image[MainI]^.Attribs[c77] := Image[MainI]^.Attribs[c77] OR Protected
    Else
    Image[MainI]^.Attribs[c77] := Image[MainI]^.Attribs[c77] AND 255-Protected;
    Line_Stat(0,MainI+2,0,FontOffs,SortabOffs,ImageOffs);
  End;
  FreeEms1(PointerTomb^[MainP]);

End;

{$ENDIF}

{$IFNDEF TITKAR}

Procedure Ins_Indexline(Yp : Integer);
Var Cikl : Integer;
    Eredeti,
    ElsoHp,
    UtolsoHp,
    ElsoIp,
    UtolsoIp,
    FoIp,
    NewInd,
    Ide,
    Typ         : Integer;

Begin
  Eredeti := MainOfIndex[Yp];
  If NOT( (UpLineI(Yp) And (UpInd(Eredeti) = MaxIndex)) Or
          ((DownLineI(Yp) Or MainLineI(Yp))
               And (DownInd(Eredeti) = MaxIndex))) Then
    Begin
      GlobLeszedes;
      Inc(All_Lines[EditNum]);
      SorCurKi;
      FirstAndLast(Eredeti,ElsoHp,UtolsoHp);
      If UpLineI(Yp) Then
        Begin  { Felso index sor }
          NewInd   := UpIndI(Yp);
          Ide      := Yp + 1;
          FoIp     := Yp + UpIndI(Yp);
          Typ      := 1;
          ElsoIp   := FoIp - UpInd(Eredeti);
          UtolsoIp := FoIp + DownInd(Eredeti);
          For Cikl := ElsoHp To Eredeti - 1 Do
            If UpInd(Cikl) >= NewInd Then     {  Atszamozas a HEAP - en }
              Set_Ind(Cikl,UpInd(Cikl) + 1);
          Set_Ind(Eredeti,UpInd(Eredeti)+1);  { Felsoindexek szama no }
          For Cikl := ElsoIp To FoIp - 1 Do
            If InInt(Cikl,FirstLine,LastLine) Then
              If UpIndI(Cikl) >= NewInd Then    {  Atszamozas az IMAGE - en }
                 Set_IndI(Cikl,UpIndI(Cikl) + 1);
          If InInt(FoIp,FirstLine,LastLine) Then
            Set_IndI(FoIp,UpIndI(FoIp)+1);  { Felsoindexek szama no }
        End
      Else
        Begin { Fosor vagy also index sor }
          If MainLineI(Yp) Then
            Begin
              NewInd := 1;
              FoIp   := Yp;
            End
          Else
            Begin
              NewInd := UpIndI(YP) + 1;
             FoIp   := Yp - UpIndI(Yp);
            End;
          Ide      := Yp + 1;
          Typ      := 0;
          ElsoIp   := FoIp - UpInd(Eredeti);
          UtolsoIp := FoIp + DownInd(Eredeti);
          For Cikl := Eredeti + 1 To UtolsoHp Do
            If UpInd(Cikl) >= NewInd Then     {  Atszamozas a HEAP - en }
              Set_Ind(Cikl,UpInd(Cikl) + 1);
          Set_Und(Eredeti,DownInd(Eredeti)+1);  { Alsoindexek szama no }
          For Cikl := FoIp + 1 To UtolsoIp Do
            If InInt(Cikl,FirstLine,LastLine) Then
              If UpIndI(Cikl) >= NewInd Then    {  Atszamozas az IMAGE - en }
                 Set_IndI(Cikl,UpIndI(Cikl) + 1);
          If InInt(FoIp,FirstLine,LastLine) Then
            Set_UndI(FoIp,DownIndI(FoIp)+1);  { Alsoindexek szama no }
        End;  {  Fosor vagy also index }
      If Ide < LastLine Then
        Begin { Ha kell scrollozas }
          For Cikl := LastLine -1 DownTo Ide Do
             Begin                          { Tombok scrollozasa }
               MainOfIndex[Cikl+1] := MainOfIndex[Cikl];
               ImageToHeap[Cikl+1] := ImageToHeap[Cikl]
             End;

          Sc_dn(LastLine+2,Ide+2,0,0,SorTabOffs,ImageOffs);

        End; { Ha kell scrollozas }

      TrueLast := GoodLast(TrueLast+1);
      LegAlso := False;

      FillImageLine(Ide);
      Set_IndI(Ide,NewInd);

      Set_BitsI(Ide,0,Typ*128+32);
      Disp_Li(Xoffset,Ide);
      Line_Stat(0,Ide+2,0,FontOffs,SortabOffs,ImageOffs);
      Set_BitsI(Ide,0,Typ*128); {  Visszaall kitoltetlenre  }
      If Ide - 1 >= FirstLine Then
        Line_Stat(0,Ide-1+2,0,FontOffs,SortabOffs,ImageOffs);
      MainOfIndex[Ide] := Eredeti;
      ImageToHeap[Ide] := 0;
      LegAlso := False;

      HalfLineDown;
      SorCurBe;
      GlobFelrakas
    End
End; { Ins_IndexLine }

Procedure Del_Indexline(Yp : Integer);
Var Nemkell,
    Fline,
    Mainp,
    ElsoInd,UtolsoInd,
    Cikl,wrk,
    ElsoP,UtolsoP,
    Inum   : Integer;
    Uheap  : Boolean;  {True =  A heap utolso sora ebben a komplexben van  }
    vbit   : Byte;
    Fp,Lp  : Integer;

Begin
  Inum := UpIndI(Yp);        {  Hanyadik indexsor amin allunk }
  MainP := MainOfIndex[Yp];

  If (Not MainLineI(Yp)) And   {}
     NOT( UplineI(Yp) And (UpInd(MainP) = 1)) Then
    Begin
      GlobLeszedes;
      Dec(All_Lines[EditNum]);
      SorCurKi;
      If UpLineI(Yp) Then
        Begin  {  Ha felso index }
          ElsoInd   := GoodLast(Yp - (Upind(MainP)-Inum)); { elso az image-en}
          UtolsoInd := GoodLast(Yp + Inum);     {  Utolso az image - en      }

          FirstAndLast(MainP,ElsoP,UtolsoP);    {  Elso es utolso a heap-en }

          For Cikl := ElsoInd To UtolsoInd Do   {  Atszamozas az Image - en }
            If UpIndI(Cikl) > Inum Then
              Set_IndI(Cikl,UpIndI(Cikl)-1);

          For Cikl := ElsoP To MainP - 1 Do     {  Atszamozas a Heap - en   }
            If UpInd(Cikl) > Inum Then
              Set_Ind(Cikl,UpInd(Cikl)-1);

          Set_Ind(MainP,UpInd(MainP) - 1);      {  Korrigalas a Heap - en   }
          If Yp + Inum <= LastLine Then
            Set_IndI(Yp+Inum,UpIndI(Yp+Inum)-1);{  Korrigalas az Image - en }
          If ImageToHeap[Yp] <> 0 Then
            Begin                               {  Ha kitoltott indexsor volt }
              DelHeapLine(ImageToHeap[Yp]);     {  Torles a heap - rol       }
              For Cikl := Yp + 1 To TrueLast Do
                If ImageToHeap[Cikl] <> 0 Then  {  Tombok korrigalasa       }
                  Dec(ImageToHeap[Cikl]);
              For Cikl := ElsoInd To TrueLast Do
                Dec(MainOfIndex[Cikl]);
            End  { Ha kitoltott }
        End   { Ha felso indexsor }
      Else
        Begin { Ha also indexsor }
          ElsoInd   := GoodLast(Yp - DownInd(MainP)-Inum);
          UtolsoInd := GoodLast(Yp + DownInd(MainP)-Inum);
          FirstAndLast(MainP,ElsoP,UtolsoP);

          For Cikl := Yp+1 To UtolsoInd Do   {  Atszamozas az Image - en }
            Set_IndI(Cikl,UpIndI(Cikl)-1);

          For Cikl := MainP + 1 To UtolsoP Do     {  Atszamozas a Heap - en   }
            If UpInd(Cikl) > Inum Then
              Set_Ind(Cikl,UpInd(Cikl)-1);
          Set_Und(MainP,DownInd(MainP) - 1);      {  Korrigalas a Heap - en   }
          If Yp - Inum >= FirstLine Then
            Set_UndI(Yp-Inum,DownIndI(Yp-Inum)-1);{  Korrigalas az Image - en }

          If ImageToHeap[Yp] <> 0 Then
            Begin                               {  Ha kitoltott indexsor volt }
              DelHeapLine(ImageToHeap[Yp]);
              For Cikl := Yp + 1 To TrueLast Do
                If ImageToHeap[Cikl] <> 0 Then  {  Tombok korrigalasa       }
                  Dec(ImageToHeap[Cikl]);
              For Cikl := UtolsoInd + 1 To TrueLast Do
                Dec(MainOfIndex[Cikl]);
            End  { Ha kitoltott }

        End; { Ha also index sor volt }


      If Yp < TrueLast Then           {    Scrollozas      }
        Begin
          Sc_up(Yp + 2,TrueLast+2,0,0,SorTabOffs,ImageOffs);
          ScrollPlusU(Yp);
          WriteImageLine(Yp,True);
        End;

      If Yp - 1 >= FirstLine Then
        Line_Stat(0,Yp-1+2,0,FontOffs,SortabOffs,ImageOffs);


{   Most kell TrueLast - ra kerulni az uj soroknak,ha vannak.
    Az Image TrueLast sora bizonytalan, ide jon az uj sor }


      MainP := MainOfIndex[TrueLast-1];   { Maradek kiirasa, regi TrueLast }

      FirstAndLast(MainP,Fp,Lp);
      Uheap := Lp = EndLine[EditNum];
      Fline := FullOfComplex(MainP); { Also sorok+Felso sorok+Fosor }

      If MainLineI(TrueLast-1) Then
        NemKell := UpInd(MainP)+1 { Felso sorok+Fosor }
      Else
        If UpIndexI(TrueLast-1) Then { Felso indexek az image-en }
          Nemkell := UpInd(MainP)-UpIndI(TrueLast-1)+1
        Else    {  Felso indexek + fosor + Alsok }
          Nemkell := UpInd(MainP)+UpIndI(TrueLast-1)+1;

      If Not((Nemkell = Fline) And Uheap) Then
        Begin
          HalfToImage(MainP,LastLine,Nemkell,2);
          WriteImageLine(LastLine,True);
          Fresh_Stat(LastLine-1,LastLine-1,True);
        End
      Else
        Begin
          FillImageLine(TrueLast);
          WriteImageLine(TrueLast,False);
          Dec(TrueLast);
          WriteImageLine(TrueLast,True);
        End;
      HalfLineUp;  {  Az indexsor torlese utan egyet felfele megyunk }
      SorCurBe;
      GlobFelrakas;
    End
End;

{$ENDIF}
{$ENDIF}




Procedure NextPos(Limes1,Limes2:Integer);
Var NewM : Integer;
Begin

  Inc(Xpos);

  If (Xpos > Limes2) Then
    If (BlockMode AND OszlopMode) OR FrameMode Then
      Dec(Xpos)
    Else
      Begin
        Xpos := Limes1;
        If Not LastMain(MainOfIndex[Ypos]) Then
          Begin
            SorCurKi;
            NewM := NextMain(MainOfIndex[Ypos]);
            While ImageToHeap[Ypos] <> NewM Do
              HalfLineDown;
            SorCurBe
          End
      End;
  CheckXpos(True);
End;

Procedure NextP2(Limes1,Limes2:Integer);
Var NewM      : Integer;
Begin
  If (Xpos >= Limes2) Then
    Begin
      Xpos := Limes1;
      If Not LastMain(MainOfIndex[Ypos]) Then
        Begin
          SorCurKi;
          NewM := NextMain(MainOfIndex[Ypos]);
          While ImageToHeap[Ypos] <> NewM Do
            HalfLineDown;
          {$IFNDEF CDVIEW}
          Block_End;
          {$ENDIF}
          MegisKell := True;
          SorCurBe
        End
    End
  Else
    Inc(Xpos);
  CheckXPos(True);
End;

Procedure PrevPos(Limes1,Limes2:Integer);
Var NewM : Integer;
Begin
  Dec(Xpos);
  If (Xpos < Limes1) Then If (BlockMode AND OszlopMode) OR FrameMode Then Inc(Xpos) Else
    Begin
      Xpos := Limes2;
      If Not FirstMain(MainOfIndex[Ypos]) Then
        Begin
          SorCurKi;
          NewM := PrevMain(MainOfIndex[Ypos]);
          While ImageToHeap[Ypos] <> NewM Do
            HalfLineUp;
          {$IFNDEF CDVIEW}
          Block_End;
          {$ENDIF}
          MegisKell := True;
          SorCurBe
        End
    End;
  CheckXpos(True);
End;

Procedure Page_Up;
Var MainP,NemKell,Sor,Cikl,Ujlap,Ujsor : Integer;
Begin
  If Not(Legfelso) And (Scount <> 0)  Then
    Begin
      MainP := MainOfIndex[FirstLine];
      Sor := CountNemkell(FirstLine);
                             { Jelenlegi poziciobol mennyi nincs a kepernyon }
      NemKell := 0;          { Ezeket mind kiirjuk majd,ha lehet             }
      PosOfPrevPage(MainP,Sor,NemKell,LastLine-3); { 34 felsort menjunk vissza (37)  }
      Dec(Scount,Sor);   {  Sor = hany felsort mentunk vissza }

      PageHeapToImage(MainP,Nemkell);
      UjLap := Pcount;
      UjSor := Lcount;
      For Cikl := Sor-1 Downto FirstLine Do
        Begin
          If LapVegeI(Cikl) Then
            Begin
              Dec(UjLap);
              UjSor := PopLapVeg;
            End
          Else
            If Ujsor = 0 Then
              Begin
                Dec(UjLap);
                Ujsor := PageLen-1
              End
            Else
              Dec(UjSor);
        End;
      PCount := UjLap;
      Lcount := UjSor;
      FreshPage;
      SeekToMain2;
      Fresh_Header
    End
    Else Top_Text;
End;


Procedure Page_Down;
Var MainP,NemKell,Minimum,Ujlap,Ujsor,Ujkezd,Cikl,Hp : Integer;
Begin
  If (TrueLast = LastLine) and (Not LegAlso) Then
    Begin
      MainP := MainOfIndex[LastLine-3];       {   -3 ! }

      NemKell := CountNemKell(LastLine-3)+1;  {   -3 ! }

      Dec(NemKell);
      Inc(Scount,LastLine-3);                 {   -3 ! }
      Minimum := FullOfComplex(MainP)-2;
      UjKezd := LastLine-3;                   {   -3 ! }
      If (NemKell > Minimum) And LastMain(MainP) Then
        Begin
          Dec(Scount,NemKell-Minimum);
          Dec(UjKezd,NemKell-Minimum);
          NemKell := Minimum;
        End;

      PageAndLine(UjKezd,Ujlap,Ujsor);
      For Cikl := Byte(LegFelso) To Ujkezd Do
        If LapVegeI(Cikl) Then
          PushLapVeg(Cikl);

      Lcount := UjSor;
      PCount := UjLap;

      PageHeapToImage(MainP,Nemkell);
      If TrueLast < Ypos Then
        Ypos := TrueLast;
      FreshPage;
      SeekToMain2;       { Csak titkarnoi valtozatnal mukodik }
      Fresh_Header
   End
 Else
   Begin
     Hp := UtolsoMain;
     While (MainOfIndex[Ypos] < Hp) Do
       HalfLineDown;
     While (MainOfIndex[Ypos] > Hp) Do
       HalfLineDown;
     If ImageToHeap[Ypos] <> Hp Then
       Begin
         While UpLineI(Ypos) Do HalfLineDown;
         While DownLineI(Ypos) Do HalfLineUp
       End;
     Fresh_Header
   End;

End;

{$IFNDEF CDVIEW}

Procedure Change_Font(Num : BYTE);
Begin
  Mozgott := TRUE;

  Inc(FkeyCount);

  If FkeyCount = 1 Then
  Begin
    Lastfontnum := Fontnum[EditNum];
    Fontnum[EditNum] := Num;
  End;

  If FkeyCount = 2 Then
  Begin
    Fkeycount := 0;
    If Lastsc <> Sc Then
    Begin
      Fontnum[EditNum] := Lastfontnum;
      Beepel(200);
    End;
  End;

End; {Change_Font}

Procedure Restore_Font;
Var Och,Font : Byte;
Begin
Och  := Ch;
Font := Lastfontnum;
If Fkeycount = 1 then
  Begin
    {$IFNDEF VT160}
    If (Sc = Alt_H) And (Ch = 0) Then
    Begin
      Key_Help(Fontnum[EditNum],Ch,Sc,Font);
      FejTab(1);
      FreshPage
    End;
    {$ENDIF}

    If Ch = Och Then
    Begin
      Fontnum[EditNum] := Lastfontnum;
      Mozgott := TRUE;
      Fkeycount := 00;
    End
    Else Fontnum[EditNum] := Font;
    If Sc = Alt_H Then Sc := 00;
  End;
End;

{$ENDIF CDVIEW}

  Procedure Change_Ins;
  Begin
    Inser := NOT(Inser);
    Mozgott:= TRUE;
 End;


  Procedure Change_Sync;
  Begin
     Sync := NOT Sync;
     Mozgott:= TRUE;
  End;

  Procedure Change_Just;
  Begin
     Just := NOT(Just);
     Mozgott:= TRUE;
  End;

Function EgySzo(MainP,X,Len : Integer) : Str160;
Var
  Ch     : Char;
  PP     : Byte;
  Cikl   : Integer;
  Hline  : Lpoint;
  St     : Str160;

Const
  SzoTerm : Set Of Char = [#00,' ','.',','];

Begin
  St := '';
  {$IFDEF NORVEG}
  GlobalSzoAtt := '';
  {$ENDIF}
  Heap_Pos(Hline,PointerTomb^[MainP]);
  For Cikl := X To X+Len-1 Do
  Begin
    Ch := Hline^.Chars[C80+Cikl];
    {$IFDEF NORVEG}
    GlobalSzoAtt := GlobalSzoAtt + Char(Hline^.Attribs[Cikl] AND 15);
    {$ENDIF}
    If MagyarE(Hline^.Attribs[Cikl] AND 15) Then { Magyar }
    Begin
      PP := Pos(Ch,CWIConvSt[0]);
      If Boolean(PP) Then
        Ch := CWIConvSt[1][PP];
    End;
    St := St + Ch;
  End;

  FreeEms1(PointerTomb^[MainP]);

  While St[Length(St)] In SzoTerm Do Dec(Byte(St[0]));

  EgySzo := St;

End;

{$IFNDEF CDVIEW}
Procedure PrevBegin(MainP,X,Hely:Integer; Var Poz,Len :Integer; AddX : Byte);
Var Ws : Str160;
    Ox : Integer;
    Fp,Lp : Integer;
    Hline,HlineC : Lpoint;
    Spn,Len2:Integer;
    Cikl : Integer;
Begin

  VisszaKellRakni := False;

  Heap_Pos(Hline,PointerTomb^[MainP]);

  FirstAndLast(MainP,Fp,Lp);

  ElvVolt := False;

  While (X >= 0) And Lukas(MainP,X,SoftSpace) Do
    Dec(X);  { Beallitjuk a vegpoziciot }
  Poz := X;
  Ox  := X;
  While (Poz >= 0) And Lukas(MainP,Poz,HardSoftSpace) Do
    Dec(Poz);  { A space - ek atugrasa }
  SPN := Poz;
  While (Poz >= 0) And Not(Lukas(MainP,Poz,HardSoftSpace)) Do
    Dec(Poz);  { A szo elejenek megkeresese }
  Inc(Poz);

  Len  := X  - Poz + 1;
  Len2 := SpN- Poz + 1;

  If ((Hline^.Attribs[Ox] AND 15) = 00) AND (Hline^.Chars[C80+Ox] = '-') Then
    Begin
      Hline^.Chars[C80+Ox] := #00;  {leszedi az elvalasztojelet}
      LeKellPoz := Ox+1;
      Dec(Ox);
      Dec(Len);
      VisszaKellRakni := True;
    End;

  If Elvalaszt Then
  Begin
    Ws := EgySzo(MainP,Poz,Len);

    Szotagok := Szotagol(Ws);

    If Szotagok > 0 Then
    Begin
      Inc(Poz,KotoJel[Szotagok]);
      Dec(Len,KotoJel[Szotagok]);

      If ((Xpos > Poz) AND (Xpos <= RightMar[EditNum])) Then
        Inc(Xpos);
      For Cikl := Fp To Lp Do
        Begin
          Heap_Pos(HlineC,PointerTomb^[Cikl]);
          Move(HlineC^.Attribs[Poz],HlineC^.Attribs[Poz+1],Ox-Poz+1);
          Move(HlineC^.Chars[C80+Poz],HlineC^.Chars[C80+Poz+1],Ox-Poz+1);
          FreeEms1(PointerTomb^[Cikl]);
        End;
      Hline^.Attribs[Poz] := 00;
      Hline^.Chars[C80+Poz] := '-';
      Inc(Poz);
      Inc(Xpos,AddX);

      CheckXpos(True);
      If (AddX = 0) OR (Not Just) Then
      Begin
        Inline($FC);
        If (Poz-1-Xoffset) In [0..77] Then
          Sys_Write(Poz-1-Xoffset,Ypos+2,Byte('-'),FontOffs,SortabOffs,0);
      End;

      FastBeep(880);
      FastBeep(660);

      ElvVolt := True;
    End
    Else Dec(LeKellPoz);
  End;

  If Len2 >= Hely Then
    Begin
      Len := 1+Len2-Len;
      Poz := X;
    End;
  FreeEms1(PointerTomb^[MainP]);

End;

{$ENDIF}

Function FP(Main,X,Limes : Integer):Boolean;
Begin
  Fp := FirstMain(Main) And (X = Limes)
End;

Function LP(Main,X,Limes : Integer):Boolean;
Begin
  Lp := LastMain(Main) And (X = Limes)
End;


Procedure Next_Word;
Var  MainP,
     Fmp       : Integer;
     JustPoint : JustArray;
     Eleje,
     Vege,
     SorHossz  : Integer;
     Kilep,
     Tovabb    : Boolean;
     UjKilep   : Boolean;

Procedure CheckAtment;
Begin
  MainP := MainOfIndex[Ypos];
  If Fmp <> MainP Then
    Begin
      Fmp := MainP;
      CompoundLines(MainP,JustPoint,Eleje,Vege);
      SorHossz := JsorH(JustPoint,eleje,vege);
      CompoundFree(MainP,JustPoint,Eleje,Vege);
      UjKilep := (SorHossz = 0)
    End;
End;

Begin
  MegisKell := False;

  MainP  := MainOfIndex[Ypos];
  Fmp := MainP;

  CompoundLines(MainP,JustPoint,Eleje,Vege);
  SorHossz := JsorH(JustPoint,eleje,vege);
  CompoundFree(MainP,JustPoint,Eleje,Vege);


  Tovabb := Xpos >= SorHossz ;

  Kilep   := False;
  UjKilep := False;

  While (NOT Kilep) AND (NOT UjKilep) And
        Not(Lukas(MainP,Xpos,LChars)) AND Not(LP(MainP,Xpos,SorHossz)) And
        (Tovabb Or (Xpos < SorHossz)) Do
    Begin { Amig szo van }
      If (BlockMode AND OszlopMode) AND (Xpos = c76) Then Kilep := True
      Else
      Begin
        NextP2(0,SorHossz);
        CheckAtment;
      End;
    End;


  While (NOT Kilep) AND (NOT UjKilep) And
        Lukas(MainP,Xpos,LChars) AND Not(LP(MainP,Xpos,SorHossz)) And
        (Tovabb Or (Xpos < SorHossz)) Do
    Begin { Megyunk jobbra, ameddig lyuk van }
      If (BlockMode AND OszlopMode) AND (Xpos = c76) Then Kilep := True
      Else
      Begin
        NextP2(0,SorHossz);
        CheckAtment;
      End;
    End;
  Mozgott := True;
  
End;

Procedure Prev_Word;
Var  MainP,
     MainPE,
     Fmp,
     ElozoVege,
     wrk    : Integer;
     Kilep,
     UjKilep : Boolean;
     JA     : JustArray;
     Jeleje,
     JVege  : Integer;
     Mendegelt  : Integer;
     MentMarFel : Boolean;
     Fazis      : Byte;
     Kxp        : Integer;

Procedure CheckAtment;
Begin
  {Writeln(lst,'Xp:',Xpos,' Yp:',Ypos);}

  MainP := MainOfIndex[Ypos];
  If Fmp <> MainP Then
    UjKilep := True;
    (*
    If MentMarFel Then
      UjKilep := True
    Else
      Begin
        MentMarFel := True;
        Fmp := MainP;
      End
      *)
End;

Begin
  MegisKell := False;
  MainP := MainOfIndex[Ypos];
  Fmp := MainP;
  Kxp := Xpos;

  If Not FirstMain(MainP) Then
    Begin
      MainPE    := PrevMain(MainP);
      CompoundLines(MainPE,Ja,Jeleje,Jvege);
      ElozoVege := JsorH(Ja,Jeleje,Jvege);
      CompoundFree(MainPE,Ja,Jeleje,Jvege);
    End;

  {Writeln(lst,Ypos,'   elozoveg:',ElozoVege);}

  Kilep := False;
  UjKilep := False;

  Mendegelt  := 0;
  MentMarFel := False; { Hany sort ment mar fel }

  While (NOT Kilep) AND (NOT UjKilep) AND
         NOT(Lukas(MainP,Xpos,LChars)) AND
         Not(FP(MainP,Xpos,0)) Do
    Begin  { Amig nem space vagy luk, addig megyunk balra }
      If (BlockMode AND OszlopMode) AND (Xpos = 0) Then Kilep := True
      Else
      Begin
        Fazis := 1;
        Inc(Mendegelt);
        PrevPos(0,ElozoVege);
        CheckAtment
      End;
    End;

  If Mendegelt <= 1 Then
    Begin
      While (NOT Kilep) AND (NOT UjKilep) AND
            Lukas(MainP,Xpos,LChars) AND
            Not(FP(MainP,Xpos,0)) Do
        Begin  { Atugorjuk a lukat }
          If (BlockMode AND OszlopMode) AND (Xpos = 0) Then Kilep := True
          Else
          Begin
            Fazis := 2;
            PrevPos(0,ElozoVege);
            CheckAtment;
          End;
        End ;

      While (NOT Kilep) AND (NOT Ujkilep) AND
            Not(Lukas(MainP,Xpos,LChars)) AND
            Not(FP(MainP,Xpos,0)) Do
        Begin  { a szo elejere ugrunk }
          If (BlockMode AND OszlopMode) AND (Xpos = 0) Then Kilep := True
          Else
          Begin
            Fazis := 1;
            Inc(Mendegelt);
            PrevPos(0,ElozoVege);
            CheckAtment;
          End;
        End;
    End; { Ha Mendegelt=1, azaz a szo elso betujen alltunk }

  If NOT Kilep Then
    If UjKilep Then
      If (Fazis = 1) And (Kxp>0) Then
        NextPos(0,ElozoVege)
      Else begin end
    Else
      If Not FP(MainP,Xpos,0) Then
        NextPos(0,C77);

  Mozgott := True
End;

{$IFNDEF CDVIEW}

Procedure DeleteCompLine(MainP,MainI:Integer);
Var NewMain,OldY,Sc2,
    ElsoI,UtolsoI,
    Elso,Utolso,Difi,FirstSc,LastSc,LastLast,
    Cikl      : Integer;
    AutoMode,Leszedte  : Boolean;
    D : Integer;
Begin
  AutoMode := MainP = 0;
  Leszedte := False;
  If AutoMode Then
    Begin
      GlobLeszedes;
      MainP := MainOfIndex[Ypos];
    End;
  If NOT(FirstMain(MainP) And LastMain(MainP)) Then
    Begin   { A szoveg utolso soranak torlese }
      If AutoMode Then
        MainI := CompMainI(Ypos);
      ElsoI := MainI - UpInd(MainP);
      UtolsoI := MainI + DownInd(MainP);
      FirstAndLast(MainP,Elso,Utolso);

      If LastMain(MainP) Then
        Begin
          NewMain := PrevMain(MainP);
          Sc2 := Scount;
          If AutoMode Then
            While ImageToHeap[Ypos] <> NewMain Do
             HalfLineUp;

          Set_Bits(NewMain,$0F+LapVege+TeleSor+Fosor,KemenySor);
          Set_BitsI(Ypos,$0F+LapVege+TeleSor+Fosor,KemenySor);
          Line_Stat(0,Ypos+2,0,FontOffs,SortabOffs,ImageOffs);

          Dec(Sc2,Scount);
          Dec(All_Lines[EditNum],FullOfComplex(MainP));
          For Cikl := Elso To Utolso Do   { Torles a Heap-en    }
            DelHeapLine(Elso);
          If ElsoI+Sc2-1 < TrueLast Then
            TrueLast := ElsoI+Sc2-1;
          For Cikl := ElsoI+Sc2 To UtolsoI+Sc2 Do
            If InInt(Cikl,FirstLine,LastLine) Then
              Begin                        { Torles az image-en }
                FillImageLine(Cikl);
                WriteImageLine(Cikl,False)
              End;
        End
      Else
        Begin  { Nem az utolso sort torlom }
          NewMain := NextMain(MainP);

          Sc2 := Scount;
          If AutoMode Then
            While ImageToHeap[Ypos] <> NewMain Do     { !!!! }
              HalfLineDown;
          Dec(Sc2,Scount);
          If ElsoI + Sc2 < FirstLine Then
            Begin
              BackCountScount(MainP);
               Leszedte := True;
            End;
          Dec(All_Lines[EditNum],FullOfComplex(MainP));
          For Cikl := Elso To Utolso Do   { Torles a Heap-en    }
            DelHeapLine(Elso);
          Dec(NewMain,Utolso-Elso+1);

          For Cikl := ElsoI + Sc2 To TrueLast Do
            If InInt(Cikl,FirstLine,LastLine) Then
              Begin
                If ImageToHeap[Cikl] <> 0 Then
                  Dec(ImageToHeap[Cikl],Utolso-Elso+1);
                Dec(MainOfIndex[Cikl],Utolso-Elso+1)
              End;

          If (UtolsoI + Sc2 < LastLine) Then
            Begin
              FirstSc := GoodLast(ElsoI + Sc2);{ a scroll elso sora }
              Difi := FirstSc - (ElsoI + Sc2);

              If Truelast = LastLine Then
                LastSc := LastLine
              Else
                LastSc := TrueLast + 1;
{
Writest('First :',FirstSc);
Writest('Last :',LastSc);
Writest('Utolsoi :',UtolsoI);
Writest('Sc2 :',Sc2);
}

        Sc_up(FirstSc+ 2,LastSc+2,UtolsoI+Sc2-FirstSc+1,0,SorTabOffs,ImageOffs);

              For Cikl := FirstSc To UtolsoI+Sc2 Do
                Begin
                  If Truelast = LastLine Then
                    LastSc := LastLine
                  Else
                    LastSc := TrueLast + 1;
                  ScrollPlusU(FirstSc);
                  {Sc_up(FirstSc+ 2,LastSc+2,0,0,SorTabOffs,ImageOffs);}
                  Dec(TrueLast)
                End;

            End
          Else  { A comp sor alja kivul van az image-en, nem kell scrollozni }
            Begin
              FirstSc := GoodLast(ElsoI + Sc2);
              Difi := FirstSc - (ElsoI + Sc2);
              TrueLast := FirstSc;
            End;
          If ElsoI + Sc2 <= LastLine Then
            Begin
              If FirstSc > FirstLine Then
                WriteImageLine(FirstSc-1,True);
              If AutoMode Then
                Ypos   := Ypos - ((UtolsoI+Sc2) - FirstSc + 1);
              LastLast := TrueLast;
              HalfToImage(NewMain,FirstSc,{Difi} 0,40);

              For Cikl := TrueLast + 1 To LastLine Do
                Begin
                  FillImageLine(Cikl);
                  {writest('Cikl :',Cikl);}
                  WriteImageLine(Cikl,False);
                End;

              For Cikl := LastLast To TrueLast Do
                WriteImageLine(Cikl,True);
            End;  { Ha a torlendo sor utolso sora meg rajta van a kepernyon }
        End;   { Ha nem az utolso sort toroljuk }
      Mozgott := True;


      If AutoMode Then
        Begin
          If Leszedte Then
            Begin
              D := CountNemKell(FirstLine);
              CountScount(MainOfIndex[FirstLine],D,NewMain,0);
            End;
          GlobFelrakas;
        End;

    End   { Ha nem csak egy sor van }
  Else
    Begin { Csak egyetlen egy sor van }

      {For Cikl := Byte(Legfelso) To TrueLast Do
      Begin
        FillImageLineAtt(Cikl);
        If ImageToHeap[Cikl] <> 0 Then
          MoveImageLine(Cikl,ImageToHeap[Cikl]);
        WriteImageLine(Cikl,True)
      End;  }

      FreeEdit(EditNum);

      New_CompLine(StartLine[EditNum],AlsoIndexek,FelsoIndexek);
      New_kell[Editnum] := False;
      SeekToFirstLine;
      SeekToLastp;
      SeekToMain;

      If AutoMode Then
        Begin
          If Leszedte Then
            Begin
              D := CountNemKell(FirstLine);
              CountScount(MainOfIndex[FirstLine],D,NewMain,0);
            End;
          GlobFelrakas;
        End;
    End;
  NoVege
End;    { DeleteCompLine }

{$ENDIF}


Procedure ElotteUtana( Var Xpos,ElsoI,UtolsoI: Integer;
                       Var KDispE,KDispU     : Boolean);
Begin
  If (Sor_Hossz(Xpos,UtolsoI+2,0,FontOffs,SortabOffs,ImageOffs) = 0) Then
    KDispU := False
  Else
    If (UtolsoI <> LastLine ) Then
      If (Sor_Hossz(Xpos,UtolsoI+1+2,0,FontOffs,SortabOffs,ImageOffs)<>0) Then
        KdispU := True
      Else
        Begin
          Inc(UtolsoI);
          KdispU := False
        End
    Else
      KDispU := False;
  If (Sor_Hossz(Xpos,ElsoI+2,0,FontOffs,SortabOffs,ImageOffs) = 0) Then
    Begin
      KDispE := False;
      Inc(ElsoI)
    End
  Else
    If (ElsoI <> FirstLine ) Then
      If (Sor_Hossz(Xpos,ElsoI-1+2,0,FontOffs,SortabOffs,ImageOffs)<>0) Then
        Begin
          KDispE := True;
          Inc(ElsoI)
        End
      Else
        KDispE := False
    Else
      Begin
        KDispE := False;
        Inc(ElsoI)
      End;
End;  { ElotteUtana }

Const Telelett : Boolean = False;

{$IFNDEF CDVIEW}

{$I NEWCHAR.CDW}

Procedure For_Tab_Ins;
Var Cik : Byte;
Begin
  Mozgott := True;
  If Xpos < LeftMar[EditNum] Then
    For Cik := Xpos To LeftMar[EditNum] Do New_Char(00)
  Else
    If Xpos < RightMar[EditNum] Then
      Begin
        If Tabs[Xpos] Then New_Char(32);
        While NOT(Telelett) AND ((Xpos <> RightMar[EditNum]) And NOT(Tabs[Xpos])) Do
          New_Char(32);
        Telelett := False;
      End
End;
{$ENDIF}

Procedure For_Tab;
Begin
  Mozgott := True;
  If Xpos < LeftMar[EditNum] Then
    Xpos := LeftMar[EditNum]
  Else
    If Xpos < RightMar[EditNum] Then
      Begin
        If Tabs[Xpos] Then
          Inc(Xpos);
        While (Xpos <> RightMar[EditNum]) And NOT(Tabs[Xpos]) Do
          Inc(Xpos);
      End;
  CheckXpos(True);
End;


Procedure Back_Tab;
Begin
  Mozgott := True;
  If Xpos > RightMar[EditNum] Then
    Xpos := RightMar[EditNum]
  Else
    If Xpos > LeftMar[EditNum] Then
      Begin
        If Tabs[Xpos] Then
          Dec(Xpos);
        While (Xpos <> LeftMar[EditNum]) And NOT(Tabs[Xpos]) Do
          Dec(Xpos);
      End;
  CheckXpos(True)
End;

Type Deltype = (Back,Forw,OneWord);

Function UChar(Mainp: Integer):Integer;
Var Cikl,Ize,uu,Fp,Lp : Integer;
Begin
  FirstAndLast(MainP,Fp,Lp);
  Uu := LeftMar[EditNum];           { !!! 0 volt }
  For Cikl := Fp To Lp Do
    Begin
      Ize := SorH(Cikl);
      If Ize > Uu Then
        Uu := Ize
    End;
  UChar := Uu-1
End;

Function ABS_UChar(Mainp: Integer):Integer;
Var Cikl,Ize,uu,Fp,Lp : Integer;
Begin
  FirstAndLast(MainP,Fp,Lp);
  Uu := 0;
  For Cikl := Fp To Lp Do
    Begin
      Ize := SorH(Cikl);
      If Ize > Uu Then
        Uu := Ize
    End;
  ABS_UChar := Uu-1
End;

{$IFNDEF CDVIEW}

Procedure Felrant(Var Pm,MainP,MainI,Utso : Integer; Var Csinalta : Boolean;
                  Mennyi,LeftPoz : Integer);

{X,}
Var Poz,Max,Ures,
Cikl,Ize,OPoz   : Integer;
Hlin            : Lpoint;
Ws              : Str160;

Procedure Leszedi_az_Elvalasztojelet;
Begin
  Heap_Pos(Hlin,PointerTomb^[Pm]);
  If ((Hlin^.Attribs[Utso-1] AND 15) = 00) AND
     (Hlin^.Chars[C80+Utso-1] = '-') Then Dec(Utso);
  FreeEms1(PointerTomb^[Pm]);
End;

Procedure Felmasol(X: Integer);
Var Fp,Lp,Fp1,Lp1,Cikl,Cikl2,Hanyadik,Ipos : Integer;
    Vanilyen                               : Boolean;
    MainI2 : Integer;
Begin
  If X < 0 Then X := 0
  Else
    Leszedi_az_Elvalasztojelet;

  FirstAndLast(MainP,Fp,Lp);
  FirstAndLast(PM,Fp1,Lp1);

  {$IFDEF PROTECT} If ProtectedLine(Pm) Then Exit; {$ENDIF}

  MainI2 := MainI - UpInd(MainP) - DownInd(Pm) - 1;
      { A bovitendo fosor az image-en }

  IndexTagitas(MainP,Pm,MainI2,EditNum,EditNum);

  MainI := MainI2 + DownInd(Pm) + UpInd(MainP) + 1;

  Cikl := Fp;

  While Cikl <= MainP-1 Do  {Ciklus az aktualis sor indexein}
    Begin
      Hanyadik  := UpInd(Cikl);
      VanIlyen := False;

      For Cikl2 := Fp1 To Pm-1 Do { Ciklus a felette levo soron }
        If Upind(Cikl2) = Hanyadik Then
          Begin  { Ha mar van ilyen szamu indexsora }
            VanIlyen := True;
            Ipos     := Cikl2
          End;

      If Not VanIlyen Then
        Begin
          CreateHeapIndex(Pm,Hanyadik,MainI2,True,Ipos);

          Inc(MainP); { Aktualis sor Valtozoi }
          Inc(Fp);
          Inc(Lp);

          Inc(Pm);    { Elozo sor valtozoi }
          Inc(Lp1);

          Inc(Cikl);
        End;

      MoveHlines(Cikl,Ipos,LeftPoz,Utso,X,Yes);
      Inc(Cikl);

    End;

  MoveHlines(MainP,Pm,LeftPoz,Utso,X,Yes);   { Fo sor masolasa }

  If ElvVolt Then
  Begin
    Heap_Pos(Hlin,PointerTomb^[Pm]);
    Hlin^.Attribs[Utso+X] := 00;
    Hlin^.Chars[C80+Utso+X]   := '-';
    FreeEms1(PointerTomb^[Pm]);
    ElvVolt := False;
  End;

  Set_Bits(Pm,$0F,TeleSor+FoSor);

  Cikl := MainP+1;

  While Cikl <= Lp Do  {Ciklus az aktualis sor indexein}
    Begin
      Hanyadik  := UpInd(Cikl);
      VanIlyen := False;

      For Cikl2 := Pm+1 To Lp1 Do { Ciklus a felette levo soron }
        If Upind(Cikl2) = Hanyadik Then
          Begin  { Ha mar van ilyen szamu indexsora }
            VanIlyen := True;
            Ipos     := Cikl2
          End;

      If Not VanIlyen Then
        Begin
          CreateHeapIndex(Pm,Hanyadik,MainI2,False,Ipos);

          Inc(MainP);   { Aktualis sor Valtozoi }
          Inc(Fp);
          Inc(Lp);

          Inc(Lp1);     { Elozo sor valtozoi }

          Inc(Cikl);
        End;

      MoveHlines(Cikl,Ipos,LeftPoz,Utso,X,Yes);

      Inc(Cikl);

    End;

  CompKiszur(Mainp,LeftPoz,X);  { !!!  0 volt }

  Csinalta := True;

End;

Var LL       : JustArray;
    El,Veg   : Integer;
    MaxDb    : Integer;
    VoltHatha: Boolean;

Function HathaTomorit(Masolando:Integer):Boolean;
Var MaxP,LenLen : Integer;
Begin

  Maxp := Utso-(LeftMar[EditNum]+1)+1;
  LenLen := TrueL(LeftMar[EditNum],Csak_nulla,LL,El,Veg);

  If Ures + (Maxp-LenLen) >= Masolando Then
    Begin
      Tomorit2(LL,El,Veg,LeftPoz);
      HathaTomorit := True;
      Utso     := LeftMar[EditNum] + LenLen;    { UChar(Pm)+1; }
      Ures     := RightMar[EditNum] + 1 - Utso;
      MaxDb := Max-LeftPoz;
    End
  Else
    HathaTomorit := False

End;

Begin  { Felrant }

  If Mennyi > -1 Then Felmasol(Mennyi)
  Else
  Begin
    Pm       := PrevMain(MainP);
    Utso     := UChar(Pm)+1;

    {$IFDEF PROTECT} If ProtectedLine(Pm) Then Exit; {$ENDIF}

    Leszedi_az_Elvalasztojelet;

    Ures     := RightMar[EditNum] + 1 - Utso;
    Max      := UChar(Mainp)+1;
    Csinalta := False;
    VoltHatha:= False;
    CompoundLines(Pm,LL,El,Veg);

    ElvVolt := False;

  { If Ures > 0 Then
    Begin }

      MaxDb := Max-LeftPoz;
      If (MaxDb <= Ures) Or HathaTomorit(MaxDb) Then
        Felmasol(Max-LeftPoz)
      Else
        Begin          {  Nem tudja az egeszet felmasolni  }
          Poz := Max;
          Repeat
            While Lukas(MainP,Poz-1,HardSoftSpace) And (Poz > LeftPoz) Do
              Dec(Poz);
            If Poz = LeftPoz Then
              Felmasol(Ures)
            Else
              Begin
                If (Poz-LeftPoz <= Ures) Or
                      HathaTomorit(Poz-LeftPoz) Then
                  Felmasol(Poz-LeftPoz+1)
                Else
                  Begin
                    OPoz := Poz;
                    While Not(Lukas(MainP,Poz-1,HardSoftSpace)) And (Poz > LeftPoz) Do
                      Dec(Poz);
                      { Elvalaszt := False; }
                    If Elvalaszt Then Csinalta := (OPoz > LeftPoz)
                                 Else Csinalta := (Poz > LeftPoz);
                    If Csinalta Then
                        If Elvalaszt Then
                        Begin
                          Ws := EgySzo(MainP,Poz,Opoz-Poz);

                          Szotagok := Szotagol(Ws);

                          If Szotagok > 0 Then ElvVolt := True; {***}

                          While (Szotagok > 0) AND (OPoz-LeftPoz > Ures) Do
                          Begin
                            Opoz := Poz + KotoJel[Szotagok];
                            Dec(Szotagok);
                            If HathaTomorit(OPoz+1-LeftPoz) Then Szotagok := 0;
                          End;

                          If (Opoz-LeftPoz < Ures) Then
                          Begin
                            Felmasol(Opoz-Leftpoz);
                            VoltHatha:= True;
                          End
                          Else ElvVolt := False;

                        End;

                        If Not VoltHatha Then
                        If (Poz-LeftPoz <= Ures) Or
                          HathaTomorit(Poz-LeftPoz) Then
                        Begin
                          Felmasol(Poz-LeftPoz);
                          VoltHatha := True;
                        End;

                        If Not VoltHatha Then Csinalta := False;
                  End
              End
          Until (Poz-LeftPoz <= Ures) Or VoltHatha Or (Poz <= LeftPoz);
        End;
    {
    End
    Else Csinalta := False; }
    CompoundFree(Pm,LL,El,Veg);
  End;
End;

Procedure Del_Char(Dmode : DelType);

Const SzoTerm : Set Of Char = ['(',')',',','.','/','?'];

Var Cikl,
    Xp,
    MainP,MainT,
    ElsoI,UtolsoI,
    ElsoIS,UtolsoIS,
    MainI,MainIT,
    Elso,Utolso,Fp,Lp,
    Difi,Sc2,Utso,Pm : Integer;
    TeleVeg,
    KDispE,KDispU    : Boolean;
    Csinalta         : Boolean;
    VoltKi           : Boolean;
    Hppp             : Word;
    Oyp              : Integer;

Procedure DelOneChar;
Var Cik : Integer;
Begin
  CompKiszur(MainP,Xp,1);  { Heap }
  Scroll_Left(Xp,ElsoI+2,UtolsoI+2,1,SorTabOffs,ImageOffs);   { Image  }
  Scroll_Left(Xp-Xoffset,ElsoIS+2,UtolsoIS+2,0,SorTabOffs,ImageOffs); { Screen }
  For Cik := ElsoI To UtolsoI Do
    Disp_Li(XOffset+77,Cik);
End;

Procedure DelC;
Begin
  If Xp = 0 Then
    Heapline^.Attribs[0] := Heapline^.Attribs[0] OR FirstAttrib;
  Heapline^.Attribs[0] := Heapline^.Attribs[0] OR 32;
  MoveHeapLine(ImageToHeap[Ypos],Ypos);
End;

Procedure PrevPos_RestoreFont;
Begin
  If Dmode = Back Then PrevPos(LeftMar[EditNum],RightMar[EditNum]);
  Restore_Font
End;

Begin  { Del_Char }

  Mozgott := True;
  GlobLeszedes;

  If (NOT MainLineI(Ypos)) Then
    If EmptyLineI(Ypos) Then
      CreateIndexLine(Ypos);

  HPPP := PointerTomb^[ImageToHeap[Ypos]];

  Heap_Pos(Heapline,HPPP);

  If Dmode = Back Then
    Xp := Xpos - 1
  Else
    Xp := Xpos;

  MainP := MainOfIndex[Ypos];

  MainI := CompMainI(Ypos);

  If Xp = 0 Then
    FirstAttrib := Heapline^.Attribs[0] AND $F0;

  If ( (DMode = Forw) OR (DMode = OneWord) ) Or (Xp >= LeftMar[EditNum]) Then
    If Sync Then
      Begin  {  Szinkron }

        ElsoI   := GoodLast(MainI - UpInd(MainP));
        UtolsoI := GoodLast(MainI + DownInd(MainP));

        ElsoIS   := ElsoI;
        UtolsoIS := UtolsoI;

        ElotteUtana(Xp,ElsoIS,UtolsoIS,KDispE,KDispU);

        If (Dmode = OneWord) AND NOT(Lukas(MainP,Xp,SzoTerm)) Then
        Begin
          If Lukas(MainP,Xp,HardSoftSpace) Then
          Begin
            While (Lukas(MainP,Xp,HardSoftSpace)) AND
                  (Xp <= ABS_Uchar(Mainp)) Do DelOneChar;
          End
          Else
          Begin
            While NOT Lukas(MainP,Xp,SzoTerm+HardSoftSpace) Do DelOneChar;
          End;
        End
        Else
        If Xp > Uchar(MainP) Then
        Begin
          If NOT LastMain(MainP) Then
          Begin
            Oyp := Ypos;
            Inc(Ypos);
            While (NOT MainLineI(Ypos)) AND (Ypos < TrueLast) Do Inc(Ypos);
            If MainOfIndex[Ypos] > MainP Then
            Begin
              Xpos := 0;
              Del_Char(Back); { Rekurzi¢ !!! }
            End
            Else Ypos := Oyp;
          End;
        End
        Else
        Begin
          DelOneChar;
        End;

        If KDispU Then
        Begin
          Disp_Li(Xp,UtolsoI);
        End;
        If KDispE Then
        Begin
          Disp_Li(Xp,ElsoI-1);
        End;

        PrevPos_RestoreFont;
      End
    Else
      Begin  { Nem szinkron  : csak egy felsor }
        Kiszur(True,HeapLine,Xp,1);
        DelC;
        Disp_Li(Xp,Ypos);
        PrevPos_RestoreFont;
      End  { Ha nem szinkron }
  Else
    Begin  { BackSpace a sor elejen }
      If Not FirstMain(MainP) Then
        Begin
          SorCurKi;
          Felrant(Pm,MainP,MainI,Utso,Csinalta,-1,Xpos); { !!! Leftmar[EditNum] }
          {       MainI = az a sor, amiben a back space-t nyomtuk }
          If Csinalta Then
          Begin
            LegyenJust := False;
            If LegFelso Then
              HalfToImage(MainOfIndex[FirstLine+1],FirstLine+1,0,40)
            Else
              HalfToImage(MainOfIndex[FirstLine],
                          FirstLine,CountNemkell(FirstLine),40);
            MainIT := MainI - UpInd(MainP)
                      -1-DownInd(Pm); { Ez az a sor,ahova felrantunk }
            CompKiiro(Pm,MainIT);
            Sc2 := Scount;
            { Az elozo fosorra megyunk  }
            Ypos := TrueLast;
            If Ypos = LastLine Then
              Dec(Ypos);
            If Ypos = FirstLine Then
              Inc(Ypos);

            If (MainOfIndex[Ypos] > Pm) Or
                   ((MainOfIndex[Ypos]) = Pm) And
                   (DownLineI(Ypos)) Then
              While (ImageToHeap[Ypos] = 0) Or (ImageToHeap[Ypos] > Pm) Do
                HalfLineUp
            Else
              While (ImageToHeap[Ypos] = 0) Or (ImageToHeap[Ypos] < Pm) Do
                HalfLineDown;

            { Raallt annak a sornak a fosoraba, ahova felrantottunk }

            Xpos := Utso;
            CheckXpos(True);
            Dec(Sc2,Scount);
            Inc(MainI,Sc2);{ Ennyivel valtozott a kovetkezo sor pozicioja }

            FirstAndLast(MainP,Fp,Lp);
            If Not VanBennuk(Fp,Lp,0) Then   { !!! LeftMar volt }
              DeleteCompLine(MainP,MainI)    { Kitorli a kovetkezo sort }
            Else
              If Ypos + DownInd(Pm)+1 <= TrueLast Then
                ComplexToScreen(0,Ypos + DownInd(Pm)+1); { Kiirja a kovetkezot}
            LegyenJust := True;
          End; { Ha csinalta }
          SorCurBe;

        End { If not FirstMain }
    End; { BackSpace a sor elejen }

  GlobFelrakas;
  FreeEms1(HPPP);

End;  { Del_Char }

Procedure SetPageEnd;
Var HeapLine : Lpoint;
Begin
  GlobLeszedes;
  If ImageToHeap[Ypos] = 0 Then
    CreateIndexLine(Ypos);
  Heap_Pos(HeapLine,PointerTomb^[ImageToHeap[Ypos]]);
  If Not LapvegeI(Ypos) Then
    Begin
      Set_BitsI(Ypos,KemenySor+TeleSor+FoSor+15,LapVege);
      Set_Bits(ImageToHeap[Ypos],KemenySor+TeleSor+FoSor+15,LapVege);
      Image[Ypos]^.Chars[C80+c78] := #2;
      HeapLine^.Chars[C80+c78] := #2;
    End
  Else
    Begin
      Set_BitsI(Ypos,KemenySor+TeleSor+FoSor+15,0);
      Set_Bits(ImageToHeap[Ypos],KemenySor+TeleSor+FoSor+15,0);
      Image[Ypos]^.Chars[C80+c78] := #0;
      HeapLine^.Chars[C80+c78] := #0;
    End;
  GlobFelrakas;
  FreeEms1(PointerTomb^[ImageToHeap[Ypos]]);

End;

{$I FORMAT.CDW   }
{$I CENTER.CDW   }

{$ENDIF}


Procedure Make_Tab;
Begin
  Make_Tabulators;
  FejTab(1);
End;

{$I REPLACE.CDW  }
{$I MainEdit.CDW }


End.
