{$S-,I+,F-,V-,B-,N-}

{$I MEMORY.CDW}

Unit HeapCdw;

Interface

Uses
     crt,
     WINDOWM,
     {$IFDEF DEBUG}
     video,
     HexKit,
     {$ENDIF}
     {$IFDEF PROBA}
     Printer,
     {$ENDIF}
     EmsCdw,
     XmsCdw;

Const  {  A 0. attributum bitkiosztasa    }
      KemenySor = 128;      { Ha fosor    }
      FelsoSor  = 128;      { Ha Indexsor }
      LapVege   =  64;
      TeleSor   =  32;
      FoSor     =  16;

      Protected =   128;

PROCEDURE HEAP_POS (VAR POINTER1 :Lpoint; REC_NUM:INTEGER);

Procedure FillImageLine(N:Integer);

Procedure FillImageLineAtt(N:Integer);

Procedure FillHeapLine(N:Integer);

Procedure MoveHeapLine(Hp,Ypos: Integer);

Procedure MoveImageLine(Ypos,Hp: Integer);

procedure DelHeapLine(N:Integer);

Procedure NewHeapLine(N:Integer);

Procedure FreeEdit(Edi : Integer);

Procedure OptimalHeap;
Procedure OptimalHeapRestore;

Function ProtectedLine(Hp : Integer): Boolean;
Function ProtectedLineI(Yp : Integer):Boolean;

Function MainLine(Hp : Integer):Boolean;

Function HardCr(Hp : Integer):Boolean;

Function MainLineI(Yp : Integer):Boolean;

Function UpIndexI(Yp : Integer):Boolean;

Function LapVegeI(Yp : Integer):Boolean;

Function LapVeg(Hp : Integer):Boolean;

Function UpIndex(Hp : Integer):Boolean;

Function UpIndI(Yp : Integer):Byte;

Function UpInd(Hp : Integer):Byte;

Function DownIndI(Yp : Integer):Byte;

Function DownInd(Hp : Integer):Byte;

Function EmptyLine(Hp : Integer):Boolean;

Function EmptyLineI(Yp : Integer):Boolean;

Function UpLine(X:Integer):Boolean;

Function DownLine(X:Integer):Boolean;

Function UpLineI(X:Integer):Boolean;

Function DownLineI(X:Integer):Boolean;

Function FirstMain(Hp : Integer):Boolean;
Function FirstMainLine: Integer;

Function LastMain(Hp : Integer):Boolean;

Function NextMain(Hp : Integer):Integer;

Function PrevMain(Hp : Integer):Integer;

Function LenLine(Hp : Integer):Integer;

Function InInt(Szam,Hat1,Hat2 : Integer):Boolean;
Function InWord(Szam,Hat1,Hat2 : Word):Boolean;

Function FreeLines:Integer;

Procedure FirstAndLast(Eredeti : Integer; Var ElsoHp,UtolsoHp : Integer);

Procedure Set_Bits(Var Hp : integer; Andol,Bin : Integer);

Procedure Set_BitsI(Yp : Integer; Andol,Bin : Integer);

Procedure Set_Ind(Hp : Integer; Bin : Byte);

Procedure Set_IndI(Yp : Integer; Bin : Byte);

Procedure Set_Und(Hp : Integer; Bin : Byte);

Procedure Set_UndI(Yp : Integer; Bin : Byte);
{
Function B(egy,ketto,harom,negy : Byte):Byte;
}
Function Lukas(MainP,X : Integer;SS : SetCh):Boolean;

Function TrueLen(MainP:Integer):Integer;

Function VanBenne(HP,XP : Integer):Boolean;

Function SorH(HP: Integer):Integer;

Function SorE(HP: Integer):Integer;

Function VanBennuk(Hp1,Hp2,Xp : Integer):Boolean;

Function InnenUres(Hp1,Hp2,Xp : Integer):Boolean;

Function GoodLast(Ennyi : Integer):Integer;

Function UtolsoMain:Integer;


Procedure SeekToFirstLine;

Procedure CountScount(HeapVeg:Integer;Var NemKell,Hp : Integer;Lapra:Integer);
Procedure BackCountScount(HeapVeg:Integer);

Procedure FreeEms1(Rec_Num:Word);
Procedure DelDskFile;


{$IFDEF Debug}
Procedure fifip;
{$ENDIF}

Procedure PushLapveg(Sor : Integer);
Function  PopLapveg:Integer;
Procedure PageAndLine(Yp : Integer; Var Lap, Sor : Integer);
Function CountNemkell(Honnan:Integer):Integer;

Procedure FillImage;
Procedure FillSImage;

                                  { Fontos rutinok }

Procedure ComplexHeapToImage(HP,NemKell,HanyKell:Integer;Var KY : Integer);
Procedure PageHeapToImage(Hp,Nemkell : Integer);
Procedure OneComplexToImage(Hp,Yp : Integer);
Procedure HalfToImage(Hp,Yp,Nemkell,Hanyat : Integer);


{ ****** idaig ****** }

Implementation

Procedure PageAndLine{(Yp : Integer; Var Lap, Sor : Integer)};
Var Cikl : Integer;
Begin
  Lap := PCount;
  Sor := Lcount;
  Cikl := Byte(LegFelso);
  While Cikl < Yp Do
    Begin
      If Image[Cikl]^.Chars[C80+c78] <> #0 Then
        Begin { Lap vege van }
          Inc(Lap);
          Sor := 0;
        End
      Else
        Inc(Sor);
      Inc(Cikl)
    End;
End;

Procedure PushLapveg{(Sor : Integer)};
Var UjLap,UjSor : Integer;
Begin
  PageAndLine(Sor,UjLap,UjSor);
  Inc(LapVegSzam);
  LapVegTomb^[LapVegSzam] := UjSor;
End;

Function PopLapveg{:Integer};
Begin
  PopLapVeg := LapVegTomb^[LapVegSzam];
  Dec(LapVegSzam);
End;


Procedure DelDskFile;
VAr IO : Integer;
Begin
  {$I-}
  Close(DskFil);
  IO := IoResult;
  Erase(DskFil);
  IO := IoResult;
  {$I+}
End;

Procedure EmsHalt(X:st80);
Var Tf:Text;
    Cikl : Integer;
Begin                      { Remelem ide soha sem jut ... }
  DirectVideo := False;
  Writeln;
  Writeln;
  writeln('Tul sok ',X,' sor !');

  If VanEmsM Then
    Release_Ems(Ems_Handle);
  If VanXmsM Then
    XmsDeAlloc(Xhand);
  If StandardHandle <> 54321 Then
    Release_Ems(StandardHandle);


  If VanDskM Then
    DelDskFile;
  Assign(tf,'EMSXMS.ERR');
  Rewrite(tf);
  For Cikl := 1 To Max_Lines Do
    Writeln(Tf,Cikl:6,' ',PointerTomb^[Cikl]);
  Writeln(Tf,'$$$$$$$$$$$$$$$$');
  Writeln(Tf,Full_Lines);
  Close(Tf);


  DirectVideo := True;
  Halt
End;

Procedure EmsBajVan(B:Word);
Begin { Ide sem juthat el soha.Ha megis, akkor valami nem stimmel }
  {$IFDEF PROBA}
  {Write(Lst,'>',B,'<');}
  For Cik := 400 To 800 Do
    Begin
      Sound(Cik);
      Delay(1);
    End;
  Nosound;
  {$ENDIF}
End;

{
Procedure Puffpos(Rec:Integer; Var P:Integer);
Var Cik : Integer;
Begin
  Cik := 1;
  P := 0;
  While (Cik<=EmsTombC) And (P=0) Do
    If (EmsTomb[Cik].Sorsz = Rec) Then
      P := Cik
    Else
      Inc(Cik);
End;
 }

Procedure PuffPos(Rec:Integer;Var PP:Integer);Assembler;
Label Kovetkezo,Megvan;
ASM
  Xor   Ax,AX
  Mov   BX,[Rec]
  Mov   Si,Offset EmsTomb+4
  Mov   CX,DS:[EmsTombC]
  Or    CX,CX
  JZ    MegVan
  Inc   Ax
Kovetkezo:
  Cmp   [Si],Bx
  Jz    MegVan
  Add   Si,SizeOfEmsTombR
  Inc   Ax
  Loop  KovetKezo
  Xor   Ax,Ax
MegVan:
  Les   DI,[PP]
  StosW
End;

Procedure PuffNul(Var PP:Integer);Assembler;
Label Kovetkezo,Megvan;
ASM
  Xor   Ax,AX
  Xor   Bx,Bx
  Mov   Si,Offset EmsTomb+6
  Mov   CX,DS:[EmsTombC]
  Or    CX,CX
  JZ    MegVan
  Inc   Ax
Kovetkezo:
  Cmp   [Si],BX
  Jz    MegVan
  Add   Si,SizeOfEmsTombR
  Inc   Ax
  Loop  KovetKezo
  Xor   Ax,Ax
MegVan:
  Les   DI,[PP]
  StosW
End;


Procedure EmsVissza(Cik:Word);
Var EmsLap,EmsSor : Word;
    p2            : Pointer;
Begin                        { Visszamasoljuk az EMS-re    }
  EmsLap := (EmsTomb[Cik].Sorsz-1) div SperLap;
  EmsSor := (EmsTomb[Cik].Sorsz-1) - EmsLap*SperLap;

  Get_Ems_Page(Ems_Handle,EmsLap);
  P2 := Ptr(EmsSeg+EmsSor*Cp16,0);
  Move(EmsTomb[Cik].Sor^,P2^,C160);

  Get_Ems_Page(Ems_Handle,ActEmsLap);
End;

Procedure XMSVissza(Cik:Word);
Begin                         { Visszamasoljuk az XMS-re    }
  XmsFel(EmsTomb[Cik].Sor,
    LongInt(EmsTomb[Cik].Sorsz-EmsLines-1)*C160,C160);
  {Write(lst,'<<',EmsTomb[Cik].Sorsz,'>>');}

End;

Procedure DSKVissza(Cik:Word);
Var IO : Integer;
Begin                         { Visszamasoljuk az DSK-ra    }
  {$I-}
  Seek(DskFil,EmsTomb[Cik].Sorsz-EmsLines-XmsLines-MemLines-1);
  Io := IoResult;
  BlockWrite(DskFil,EmsTomb[Cik].Sor^,1);
  Inc(Io,IoResult);
  {$I+}

  If IO <> 0 Then
    EmsHalt('DskF');
End;


(*
Function FreeEpos:Integer;
Var Talalt     : Integer;
Begin
  If EmsTombC < EmsTombM Then
    Begin
      Inc(EmsTombC);
      FreeEPos := EmsTombC
    End
  Else
    Begin

      If NullTBe = NullTKi Then
        FreeEpos := 0
      Else
        Begin
          Talalt   := NullTomb[NullTKi];
          {Write(lst,'<',NulltKi,'->',Talalt,'>');}
          Inc(NullTKi);
          If NullTKi > MaxEmsC+1 Then
            NullTKi := 1;
          FreeEpos := Talalt;

          If EmsTomb[Talalt].Sorsz <= EmsLines Then
            EmsVissza(Talalt)
          Else
            If EmsTomb[Talalt].Sorsz > (EmsLines+XmsLines) Then
              DskVissza(Talalt)
            Else
              XmsVissza(Talalt)
        End;
    End;
End; *)

Function FreeEpos:Integer;
Var Talalt     : Integer;
Begin
  If EmsTombC < EmsTombM Then
    Begin
      Inc(EmsTombC);
      FreeEPos := EmsTombC
    End
  Else
    Begin
      PuffNul(Talalt);
      If Talalt=0 Then
        FreeEpos := 0
      Else
        Begin
          FreeEpos := Talalt;

          If EmsTomb[Talalt].Sorsz <= EmsLines Then
            EmsVissza(Talalt)
          Else
            If EmsTomb[Talalt].Sorsz > (EmsLines+XmsLines) Then
              DskVissza(Talalt)
            Else
              XmsVissza(Talalt)
        End;
    End;
End;

Procedure DecCou(Cik:Integer);
Begin
  If EmsTomb[Cik].Cou <> 0 Then
    Begin
      Dec(EmsTomb[Cik].Cou);
      (*If EmsTomb[Cik].Cou = 0 Then
        Begin
          NullTomb[NullTBe] := Cik;
          EmsTomb[Cik].NullTBen := NullTBe;
          Inc(NullTBe);
          If NullTBe > MaxEmsC+1 Then
            NullTBe := 1;
        End  *)
    End
  Else { Tul sokszor akarjak felszabaditani }
    EmsBajVan(2);
End;

Procedure IncCou(Cik:Integer);
Begin
  (*
  If EmsTomb[Cik].Cou = 0 Then
    Begin
      NullTomb[EmsTomb[Cik].NullTBen] := NullTomb[NullTKi];
      Inc(NullTKi);
      If NullTKi > MaxEmsC + 1 Then
        NullTKi := 1;
    End;
  *)
  Inc(EmsTomb[Cik].Cou);
End;

Procedure Heap_Pos(Var Pointer1 :Lpoint; Rec_Num:Integer);
Var EmsLap,
    EmsSor  : Word;
    PP,
    IO,
    EmsTPos : Integer;
    Ch      : Char;
Begin
  {Write(lst,'<',Rec_Num);}
  If Rec_Num > (EmsLines+XmsLines) Then
    If Rec_Num <= (EmsLines+XmsLines+MemLines) Then
      Pointer1 := Ptr(SegHeap+Cp16*((Rec_Num-1)-(EmsLines+XmsLines)),0)
    Else
      Begin { DSK sort kernek }
        PuffPos(Rec_Num,PP);
        If PP <> 0 Then                      { Benne van a pufferben }
          Begin
            {$IFNDEF CDVIEW}
            Inc(PP,Elszarr^[EEN]);
            {$ENDIF}
            Pointer1 := EmsTomb[PP].Sor;
            IncCou(PP);
          End
        Else                                 { Nincs a pufferben     }
          Begin                     { Kimasoljuk az DSK-rol a pufferbe }
            EmsTPos := FreeEPos;

            If EmsTPos = 0 Then   { Betelt a puffer ? }
              EmsHalt('DSK');

            {
            Write(lst,'<',EmsTpos,' ',LongInt(Rec_Num),' ');
            Write(lst,LongInt(Rec_Num-EmsLines-XmsLines-MemLines-1),' >');
            }

            {$I-}
            Seek(DskFil,Rec_Num-EmsLines-XmsLines-MemLines-1);
            Io := IoResult;
            BlockRead(DskFil,EmsTomb[EmsTPos].Sor^,1);
            Inc(Io,IoResult);
            {$I+}

            If IO <> 0 Then
              EmsHalt('DSKF');

            EmsTomb[EmsTPos].Sorsz  := Rec_Num;
            EmsTomb[EmsTPos].Cou    := 1;

            Pointer1 := EmsTomb[EmsTPos].Sor
          End
      End
  Else
    If Rec_Num > EmsLines Then
      Begin { XMS sort kernek }
        PuffPos(Rec_Num,PP);
        If PP <> 0 Then                      { Benne van a pufferben }
          Begin
            {$IFNDEF CDVIEW}
            Inc(PP,Elszarr^[EEN]);
            {$ENDIF}
            Pointer1 := EmsTomb[PP].Sor;
            IncCou(PP);
          End
        Else                                 { Nincs a pufferben     }
          Begin                     { Kimasoljuk az XMS-rol a pufferbe }
            EmsTPos := FreeEPos;

            If EmsTPos = 0 Then   { Betelt a puffer ? }
              EmsHalt('XMS');

            XmsLe(LongInt(Rec_Num-EmsLines-1)*C160,EmsTomb[EmsTPos].Sor,C160);
            {Write(lst,'<',Rec_Num,'>');}

            EmsTomb[EmsTPos].Sorsz  := Rec_Num;
            EmsTomb[EmsTPos].Cou    := 1;

            Pointer1 := EmsTomb[EmsTPos].Sor
          End
      End
    Else
      Begin                                      { EMS sort kernek }
        EmsLap := (Rec_Num-1) div SperLap;
        EmsSor := (Rec_Num-1) - EmsLap*SperLap;
        PuffPos(Rec_Num,PP);
        If PP <> 0 Then                      { Benne van a pufferben }
          Begin
            {$IFNDEF CDVIEW}
            Inc(PP,Elszarr^[EEN]);
            {$ENDIF}
            Pointer1 := EmsTomb[PP].Sor;
            IncCou(PP);
            {Write(lst,' VP:',PP,',',EmsTomb[PP].Cou,'>')}
          End
        Else    { Nincs a pufferben }
          If EmsLap = ActEmsLap Then               { A sor az aktualis lapon van? }
            Begin                                  { Igen }
              VanALapon := True;
              Inc(ActLaponVan);
              Pointer1 := Ptr(EmsSeg+EmsSor*Cp16,0);
              {Write(lst,' VL:',ActLaponVan,'>')}
            End
          Else
            If VanALapon Then           { Hivatkoznak az aktualis lapra ?     }
              Begin                     { Kimasoljuk az EMS laprol a pufferbe }
                EmsTpos := FreeEPos;

                If EmsTPos = 0 Then     { Betelt a puffer ? }
                  EmsHalt('EMS');

                Get_Ems_Page(Ems_Handle,EmsLap);

                Pointer1 := Ptr(EmsSeg+EmsSor*Cp16,0);
                Move(Pointer1^,EmsTomb[EmsTPos].Sor^,C160); { masolas pufferbe}

                EmsTomb[EmsTPos].Sorsz  := Rec_Num;
                EmsTomb[EmsTPos].Cou    := 1;

                Get_Ems_Page(Ems_Handle,ActEmsLap);
                Pointer1 := EmsTomb[EmsTPos].Sor;
                {Write(lst,' NP:',EmsTPos,'>')}
              End
            Else
              Begin                            { atlapozunk masik EMS lapra }
                Get_Ems_Page(Ems_Handle,EmsLap);
                ActEmsLap := EmsLap;
                Pointer1  := Ptr(EmsSeg+EmsSor*Cp16,0);
                VanALapon := True;
                ActLaponVan := 1;
                {Write(lst,' lapoz >');}
              End
      End;  { EMS sor}
END;


Procedure FreeEms1(Rec_Num:Word);
Var Cik : Integer;
    EmsLap,
    EmsSor : Word;
    Ch : Char;
Begin
  {Write(lst,'!',Rec_Num);}
  If Rec_Num > EmsLines Then
    Begin
      If (Rec_Num <= (EmsLines+XmsLines)) Or
         (Rec_Num > (EmsLines+XmsLines+MemLines)) Then
        Begin                            { A sor az XMS-en,vagy a DSK-n van }
          PuffPos(Rec_Num,Cik);
          If Cik <> 0 Then { Megvan a pufferben              }
            DecCou(Cik)
          Else { Nincs ilyen sor eltarolva }
            EmsBajVan(Rec_Num)
        End
    End
  Else
    Begin  { A sor az EMS-en van }
      EmsLap := (Rec_Num-1) div SperLap;
      EmsSor := (Rec_Num-1) - EmsLap*SperLap;
      PuffPos(Rec_Num,Cik);
      If Cik <> 0 Then  { Megvan a pufferben              }
        Begin
          {Write(lst,' P:',Cik,'!');}
          DecCou(Cik)
        End
      Else
        If EmsLap <> ActEmsLap Then
          EmsBajVan(5)
        Else
          Begin       { A sor az aktualis lapon volt }
            Dec(ActLaponVan);
            VanALapon := ActLaponVan <> 0;
            {Write(lst,' L:',ActLaponVan,'!');}
          End;
    End { A sor az EMS-en van }
End;

(*
Procedure Heap_Pos2{(Var Pointer1:Pointer; Rec_Num:Integer)};
Begin
  Inline($8B/$46/<Rec_Num/  { MOV   AX,[BP+04]      ;              }
         $D1/$E0/           { SHL   AX,1            ; *2           }
         $89/$C3/           { MOV   BX,AX           ;              }
         $D1/$E0/           { SHL   AX,1            ;              }
         $D1/$E0/           { SHL   AX,1            ; *8           }
         $01/$D8/           { ADD   AX,BX           ; 2+8= *10     }
         $03/$06/Heap+02/   { ADD   AX,[SEG(HEAP^)] ; + Heap       }
         $C4/$7E/<Pointer1/ { LES   DI,[BP+06]      ; pointer1     }
         $26/               { ES:                   ;              }
         $89/$45/$02/       { MOV   [DI+02],AX      ; szegmens     }
         $31/$C0/           { XOR   AX,AX           ;              }
         $26/               { ES:                   ;              }
         $89/$05);          { MOV   [DI],AX         ; offset       }
End;


Procedure Heap_Pos2(Var Pointer1:Lpoint; Rec_Num:Integer);
Begin
  Pointer1 := Ptr(SegHeap+Cp16*Rec_Num,0);
End;

*)
Procedure FillImageLine{(N:Integer)};
Begin
  FillChar(Image[N]^,C160,0);
End;

Procedure FillImageLineAtt{(N:Integer)};
Var A0,A78,A79 : Byte;
Begin

  A0  := Image[N]^.Attribs[0] AND 240;
  A78 := Image[N]^.Attribs[c78];
  A79 := Image[N]^.Attribs[c79];

  FillChar(Image[N]^,C160,0);

  Image[N]^.Attribs[0]  := A0;
  Image[N]^.Attribs[c78] := A78;
  Image[N]^.Attribs[c79] := A79;
End;

Procedure FillHeapLine{(N:Integer)};
Var Sor : Lpoint;
Begin
  Heap_Pos(Sor,PointerTomb^[N]);
  FillChar(Sor^,C160,#0);
  FreeEms1(PointerTomb^[N])
End;

{$IFDEF DEBUG}
Procedure ize1;
Var Sor : Lpoint;
    Cik,
    Cik2 : Word;
    CCC : Word;
    Lett : Word;
    St  : String[12];
Begin
  For Cik := Full_Lines+1 To Max_Lines Do
  Begin
    Heap_Pos(Sor,PointerTomb^[Cik]);

    { FillHeapLine(Cik); }

    If Cik > EmsLines-1 Then
    Begin
      St := Dec_Hex(LongInt(Seg(Sor^)),4);
      St := St + ':' + Dec_Hex(LongInt(Ofs(Sor^)),4) + ' ';
      CCC := PointerTomb^[Cik];
      Writest(St,CCC);
      If CCC=0 Then
       Begin
          writeln(lst,' Pointertomb cime1 :',dec_hex(seg(PointerTomb^),4),':',
                                    dec_hex(ofs(PointerTomb^),4));

          Cik2 := EmsLines-1;
          Lett := 0;
          Repeat
            If Cik2 <> PointerTomb^[Cik2] Then
              Begin
                Inc(Lett);
                Write(lst,'Cik2: ',Cik2:6,' Pointer: ',PointerTomb^[Cik2]:6,' | ');
                If Cik2 MOD 3 = 0 Then Writeln(LST);
              End;
            Inc(Cik2)
          Until (Cik2 > Max_Lines) Or (Lett > 30);
          Writeln(lst);
       End
    End;

    FillChar(Sor^,C160,1);

    FreeEms1(PointerTomb^[Cik]);

  End;

End;

{$ENDIF}

Procedure MoveHeapLine{(Hp,Ypos: Integer)};
Var HeapLine : Lpoint;
Begin
  Heap_Pos(HeapLine,PointerTomb^[Hp]);
  Move(HeapLine^,Image[Ypos]^,C160);
  FreeEms1(PointerTomb^[Hp])
End;

Procedure MoveImageLine{(Ypos,Hp: Integer)};
Var HeapLine : Lpoint;
Begin
  Heap_Pos(HeapLine,PointerTomb^[Hp]);
  Move(Image[Ypos]^,Heapline^,C160);
  FreeEms1(PointerTomb^[Hp])
End;

procedure DelHeapLine{(N:Integer)};
var Cikl,Lyuk : Integer;
Begin
   Lyuk := PointerTomb^[N];

   Move(PointerTomb^[N+1],PointerTomb^[N],(Word(Full_Lines)-N)*2);

   PointerTomb^[Full_Lines] := Lyuk;

   Dec(Full_Lines);
   Dec(Endline[EditNum]);

   For Cikl := EditNum+1 To MaxEditor Do
   Begin
     Dec(Endline[Cikl]);
     Dec(Startline[Cikl]);
   End;
End;

Function FreeLines{:Integer};
Begin
  FreeLines := Max_Lines-Full_Lines;
End;


Procedure NewHeapLine{(N:Integer)};
var Cikl,Lyuk : Integer;
Begin
   Outmemory := FreeLines < 9;
   Lyuk := PointerTomb^[Full_Lines+1];

   Move(PointerTomb^[N],PointerTomb^[N+1],(Word(Full_Lines)-N+1)*2);

   PointerTomb^[N] := Lyuk;

   Inc(Full_Lines);
   Inc(Endline[EditNum]);

   For Cikl := EditNum+1 To MaxEditor Do
   Begin
     Inc(Endline[Cikl]);
     Inc(Startline[Cikl]);
   End;
   FillHeapLine(N);
End;

Procedure FreeEdit{(Edi : Integer)};
Begin
  EditNum := Edi;
  All_Lines[EditNum] := 0;
  While Endline[EditNum] >= Startline[EditNum] Do
    DelHeapline(Endline[EditNum]);
  New_Kell[EditNum] := True;
  Kodolatlan[EditNum] := True;
  JelszValt[EditNum] := False;
  Outmemory := (Full_Lines > Max_Lines-9);
  Valtozas[Editnum] := False;
End;

(*
Procedure OptimalHeap;

Var
    Cikl,Cikl2  : Integer;
    MasikSor    : Integer;
    HelyesP,
    MasikP      : Lpoint;
    Puffer      : LineType;

Begin
  For Cikl := 1 To Full_Lines Do
    If PointerTomb^[Cikl] <> Cikl Then
      Begin
        Cikl2 := Cikl+1;
        MasikSor := 0;
        While (Cikl2 <= Full_Lines) And (MasikSor = 0) Do
          If PointerTomb^[Cikl2] = Cikl Then
            MasikSor := Cikl2
          Else
            Inc(Cikl2);
        If MasikSor = 0 Then
          Begin  { Lyuk a memoriaban }
            Heap_Pos(HelyesP,Cikl);
            Heap_Pos(MasikP,PointerTomb^[Cikl]);
            HelyesP^ := MasikP^;
            PointerTomb^[Cikl] := Cikl;
            FreeEms1(PointerTomb^[Cikl]);
            FreeEms1(Cikl);
          End
        Else
          Begin  { Atszervezes kell  }
            Heap_Pos(HelyesP,Cikl);
            Heap_Pos(MasikP,PointerTomb^[Cikl]);

            Puffer   := MasikP^;
            MasikP^  := HelyesP^;
            HelyesP^ := Puffer;

            FreeEms1(Cikl);
            FreeEms1(PointerTomb^[Cikl]);

            PointerTomb^[MasikSor] := PointerTomb^[Cikl];
            PointerTomb^[Cikl]     := Cikl;
          End
      End;

  StartPoint := Heap;
  Inc(StartPseg,(Full_Lines+1)*10);

  PointSize := FreeLines*Cp16        { *160 /16 }
End;

Procedure OptimalHeap;

Var
    Cikl        : Integer;
    LukP,
    FelsoP      : Lpoint;
    LastP,LastT,
    LukT        : Word;

Procedure SearchLast;
Var Cikl,Work : Word;
Begin
  LastP := 0;
  For Cikl := 1 To Full_Lines Do
    If PointerTomb^[Cikl] > LastP Then
      Begin
        LastP := PointerTomb^[Cikl];
        LastT := Cikl
      End
End;

Function Lukas(N:Word):Boolean;
Var Cikl : Integer;
    Wrk  : Boolean;
Begin
  Wrk := True;
  Cikl := 1;
  While (Cikl <= Max_Lines) And Wrk Do
    If PointerTomb^[Cikl] = N Then
      Wrk := False
    Else
      Inc(Cikl);
  Lukas := Cikl > Full_Lines;
  LukT  := Cikl
End;

Begin
  Cikl := 1;
  SearchLast;
  While (Cikl <= LastP) Do
    If Lukas(Cikl) Then
      Begin
        Heap_Pos(LukP,Cikl);
        Heap_Pos(FelsoP,LastP);

        Move(FelsoP^,LukP^,C160);

        FreeEms1(Cikl);
        FreeEms1(LastP);

        PointerTomb^[LastT] := Cikl;
        PointerTomb^[LukT]  := LastP;

        SearchLast;
        Inc(Cikl)
      End
    Else
      Inc(Cikl);

  StartPoint := Heap;

  If Full_Lines > (EmsLines+XmsLines) Then
    Begin
      Inc(StartPseg,(Full_Lines-(EmsLines+XmsLines)+1)*10);
      PointSize := FreeLines*Cp16        { *160 /16 }
    End
  Else
    Begin
      PointSize := MemLines*Cp16        { *160 /16 }
    End;
End;    *)

Procedure SorCsere(Egyik,Masik:Integer);
{ Megcserel ket sort. Az "Egyik" legyen a tele. }
Var P1,P2  : Integer;
    EgyikP,
    MasikP : LPoint;
Begin
  P1 := PointerTomb^[Egyik];
  P2 := PointerTomb^[Masik];

  Heap_pos(EgyikP,P1);
  Heap_Pos(MasikP,P2);

  Move(EgyikP^,MasikP^,C160);

  FreeEms1(P2);
  FreeEms1(P1);

  PointerTomb^[Egyik]  := P2;
  PointerTomb^[Masik]  := P1;
End;

Procedure OptimalHeap;
Var
    Cikl,Cikl2,
    AlsoHatar,
    AllMemLines : Integer;
    DiskIs      : Boolean;
Begin
  Cikl2  := Full_Lines+1;   { Kezdoertek az elso ures sor }
  DiskIs := False;   { Elso menetben csak az EMS,XMS es MEM sorokra pakol }
  If Full_Lines > DskLines Then
    AlsoHatar := Full_Lines-DskLines
  Else
    AlsoHatar := EmsLines+XmsLines;

  AllMemLines := EmsLines+XmsLines+MemLines;
  For Cikl := 1 To Full_Lines Do   { Ciklus a tele sorokon }
    If (PointerTomb^[Cikl] >  AlsoHatar) And
       (PointerTomb^[Cikl] <= AllMemLines)  Then
      Begin
        While NOT( (PointerTomb^[Cikl2] <= AlsoHatar) Or { also hatar alatti }
                   (DiskIs And                 { Vagy mar lemezre is teheti }
                     (PointerTomb^[Cikl2] > AllMemLines))) Do { es ott is van }
          Begin
            Inc(Cikl2);
            If Cikl2 > Max_Lines Then
              Begin
                DiskIs := True;
                Cikl2 := Full_Lines+1;
              End;
          End;
        SorCsere(Cikl,Cikl2);
        Inc(Cikl2);
        If Cikl2 > Max_Lines Then
          Begin { A lemezre csak akkor engedunk, ha a tobbi elfogyott }
            DiskIs := True;
            Cikl2 := Full_Lines+1;
          End;
      End;
  StartPoint := Heap;
  If Full_Lines > (EmsLines+XmsLines+DskLines) Then
    Begin
      Inc(StartPseg,(Full_Lines-(EmsLines+XmsLines+DskLines))*Cp16);
      PointSize := FreeLines*Cp16        { *160 /16 }
    End
  Else
    PointSize := MemLines*Cp16        { *160 /16 }
End;

Procedure OptimalHeapRestore;
Var Cikl,Cikl2 : Integer;
Begin
  Cikl2 := Full_Lines + 1; { Kezdoertek az elso ures sor }
  For Cikl := 1 To Full_Lines Do
    If PointerTomb^[Cikl] > Full_Lines Then
      Begin
        While PointerTomb^[Cikl2] > Full_Lines Do
          Inc(Cikl2);
        SorCsere(Cikl,Cikl2);
        Inc(Cikl2);
      End;
End;

Function ProtectedLine{(Hp : Integer): Boolean};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  ProtectedLine := (Hline^.Attribs[c77] AND Protected) = Protected;
  FreeEms1(PointerTomb^[Hp]);
End;

Function ProtectedLineI{(Yp : Integer):Boolean)};
Begin
  ProtectedLineI := (Image[Yp]^.Attribs[c77] AND Protected) = Protected
End;

Function MainLine{(Hp : Integer):Boolean)};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  MainLine := (Hline^.Attribs[0] AND Fosor) = Fosor;
  FreeEms1(PointerTomb^[Hp]);
End;

Function HardCr{(Hp : Integer):Boolean)};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  HardCr := (Hline^.Attribs[0] AND KemenySor) = KemenySor;
  FreeEms1(PointerTomb^[Hp]);
End;

Function MainLineI{(Yp : Integer):Boolean)};
Begin
  MainLineI := (Image[Yp]^.Attribs[0] AND Fosor) = Fosor;
End;

Function MainLineP(Var PP : Lpoint):Boolean;
Begin
  MainLineP := (PP^.Attribs[0] AND Fosor) = Fosor;
End;

Function UpIndexI{(Yp : Integer):Boolean)};
Begin
  UpIndexI := (Image[Yp]^.Attribs[0] AND FelsoSor) = FelsoSor
End;

Function LapVegeI{(Yp : Integer):Boolean)};
Begin
  LapVegeI := (Image[Yp]^.Attribs[0] AND LapVege) = LapVege
End;

Function LapVeg{(Hp : Integer):Boolean)};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  LapVeg := (Hline^.Attribs[0] AND LapVege) = LapVege;
  FreeEms1(PointerTomb^[Hp]);
End;

Function LapVegP(Hline : Lpoint):Boolean;
Begin
  LapVegP := (Hline^.Attribs[0] AND LapVege) = LapVege;
End;

Function UpIndex{(Hp : Integer):Boolean)};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  UpIndex := (Hline^.Attribs[0] AND FelsoSor) = FelsoSor;
  FreeEms1(PointerTomb^[Hp]);
End;

Function UpIndexP(Var HLine : Lpoint):Boolean;
Begin
  UpIndexP := (Hline^.Attribs[0] AND FelsoSor) = FelsoSor;
End;

Function UpIndI{(Yp : Integer):Byte};
Begin
  UpIndI := Image[Yp]^.attribs[c79]
End;

Function UpInd{(Hp : Integer):Byte};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  UpInd := Hline^.attribs[c79];
  FreeEms1(PointerTomb^[Hp]);
End;

Function UpIndP(Var HLine : Lpoint):Byte;
Begin
  UpIndP := Hline^.attribs[c79];
End;

Function DownIndI{(Yp : Integer):Byte};
Begin
  DownIndI := Image[Yp]^.attribs[c78]
End;

Function DownInd{(Hp : Integer):Byte};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  DownInd := Hline^.attribs[c78];
  FreeEms1(PointerTomb^[Hp]);
End;

Function DownIndP(Var HLine : Lpoint):Byte;
Begin
  DownIndP := Hline^.attribs[c78];
End;

Function EmptyLine{(Hp : Integer):Boolean)};
Var HLine : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  EmptyLine := (Hline^.Attribs[0] AND TeleSor) = 0;
  FreeEms1(PointerTomb^[Hp]);
End;

Function EmptyLineI{(Yp : Integer):Boolean)};
Begin
  EmptyLineI := (Image[Yp]^.Attribs[0] AND TeleSor) = 0
End;

Function UpLine{(X:Integer):Boolean)};
Begin
  UpLine := (NOT MainLine(X)) AND UpIndex(X)
End;

Function UpLineP(Var PP:Lpoint):Boolean;
Begin
  UpLineP := (NOT MainLineP(PP)) AND UpIndexP(PP)
End;

Function DownLine{(X:Integer):Boolean)};
Begin
  DownLine := (NOT MainLine(X)) AND (Not UpIndex(X))
End;

Function UpLineI{(X:Integer):Boolean)};
Begin
  UpLineI := (NOT MainLineI(X)) AND UpIndexI(X)
End;

Function DownLineI{(X:Integer):Boolean)};
Begin
  DownLineI := (NOT MainLineI(X)) AND (Not UpIndexI(X))
End;


Function FirstMain{(Hp : Integer):Boolean)};
Var WRK : Boolean;
Begin
  WRK := True;
  Dec(Hp);
  While (Hp <> StartLine[EditNum]-1) And WRK Do
    Begin
      If MainLine(Hp) Then Wrk := False;
      Dec(Hp);
    End;
  FirstMain := Wrk
End;

Function LastMain{(Hp : Integer):Boolean)};
Var WRK : Boolean;
Begin
  WRK := True;
  Inc(Hp);
  While (Hp <> Endline[Editnum]+1) And WRK Do
    Begin
      If MainLine(Hp) Then Wrk := False;
      Inc(Hp);
    End;
  LastMain := Wrk;
End;

Function NextMain{(Hp : Integer):Integer};
Var WRK : Boolean;
Begin
  WRK := True;
  Inc(Hp);
  While (Hp <> Endline[Editnum]+1) And WRK Do
    Begin
      If MainLine(Hp) Then Wrk := False;
      Inc(Hp);
    End;
  NextMain := Hp - 1;
End;

Function PrevMain{(Hp : Integer):Integer};
Var WRK : Boolean;
Begin
  WRK := True;
  Dec(Hp);
  While (Hp <> Startline[Editnum]-1) And WRK Do
    Begin
      If MainLine(Hp) Then Wrk := False;
      Dec(Hp);
    End;
  PrevMain := Hp + 1;
End;

Function UtolsoMain:Integer;
Var Hp : Integer;
Begin
  Hp := EndLine[EditNum];
  If MainLine(Hp) Then
    UtolsoMain := Hp
  Else
    UtolsoMain := PrevMain(Hp)
End;

Function LenLine{(Hp : Integer):Integer};
Var WRK   : Integer;
    Hline : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  Wrk := c77;
  While (Wrk >= 0) And (Hline^.Chars[C80+Wrk] = #0) Do
    Dec(Wrk);
  LenLine := Wrk + 1;
  FreeEms1(PointerTomb^[Hp]);
End;

Function InInt{(Szam,Hat1,Hat2):Integer};
Begin
  InInt := (Szam >= Hat1) And (Szam <= Hat2)
End;

Function InWord{(Szam,Hat1,Hat2):Word};
Begin
  InWord := (Szam >= Hat1) And (Szam <= Hat2)
End;

Procedure FirstAndLast{(Eredeti : Integer; Var ElsoHp,UtolsoHp : Integer)};
Begin
  ElsoHp := Eredeti-1;
  UtolsoHp := Eredeti+1;
  While (ElsoHp <> StartLine[EditNum]-1) AND UpLine(ElsoHp) Do
    Dec(ElsoHp);
  Inc(ElsoHp);
  While (UtolsoHp <> Endline[Editnum]+1) AND DownLine(UtolsoHp) Do
    Inc(UtolsoHp);
  Dec(UtolsoHp);
End;


Procedure Set_Bits{(Var Hp : integer; Andol,Bin : Integer)};
Var Hline : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  Hline^.attribs[0] := (Hline^.attribs[0] AND Andol) Or Bin;
  FreeEms1(PointerTomb^[Hp]);
End;

Procedure Set_BitsI{(Yp : ImageTip; Andol,Bin : Integer)};
Begin
  Image[Yp]^.attribs[0] := (Image[Yp]^.attribs[0] AND Andol) Or Bin
End;

Procedure Set_Ind{(Hp : Integer; Bin : Byte)};
Var Hline : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  Hline^.attribs[c79] := Bin;
  FreeEms1(PointerTomb^[Hp]);
End;

Procedure Set_IndI{(Yp : Integer; Bin : Byte)};
Begin
  Image[yp]^.attribs[c79] := Bin
End;

Procedure Set_Und{(Hp : Integer; Bin : Byte)};
Var Hline : Lpoint;
Begin
  Heap_Pos(Hline,PointerTomb^[Hp]);
  Hline^.attribs[c78] := Bin;
  FreeEms1(PointerTomb^[Hp]);
End;

Procedure Set_UndI{(Yp : Integer; Bin : Byte)};
Begin
  Image[yp]^.attribs[c78] := Bin
End;

{ Function B(egy,ketto,harom,negy : Byte):Byte;}
{
var ossz,c : byte;
    Bt     : Array[1..4,1..2] Of Boolean Absolute negy;

const tab : array[1..4] of byte = (128,64,32,16);

Begin
  Ossz := 0;
  For C := 1 To 4 Do
    If Bt[C,1] Then Inc(Ossz,Tab[C]);
  B := Ossz
End;
}

Function Lukas{(MainP,X : Integer;SS : SetCh):Boolean)};
Var
  FirstP,LastP,Cikl : Integer;
  Hline             : Lpoint;
  Kotojel           : Boolean;

Begin
  Kotojel := ('-' IN SS);
  FirstAndLast(MainP,FirstP,LastP);
  Lukas := True;
  For Cikl := FirstP To LastP Do
    Begin
      Heap_Pos(Hline,PointerTomb^[Cikl]);
      If Not(Hline^.Chars[C80+X] In SS) Then
        Lukas := False;
      If Kotojel AND (Hline^.Chars[C80+X] = '-') Then
        If (Hline^.Attribs[X] AND 15) > 00 Then Lukas := False;
      FreeEms1(PointerTomb^[Cikl]);
    End;
End;

Function TrueLen{(MainP:Integer):Integer};
Var Cikl,Work : Integer;
Begin
  Work := 0;
  For Cikl := 0 To c77 Do
    If NOT(Lukas(MainP,Cikl,[#0])) Then
      Inc(Work);
  TrueLen := Work
End;

Function VanBenne{(HP,XP : Integer):Boolean)};
Var Hline : Lpoint;
    Cikl  : Integer;
Begin
  Heap_Pos(Hline,PointerTomb^[HP]);
  VanBenne := False;
  For Cikl := Xp To c77 Do
    If Hline^.Chars[C80+Cikl] <> #0 Then
      VanBenne := True;
  FreeEms1(PointerTomb^[HP]);
End;

Function SorH{(HP: Integer):Integer};
Var Hline : Lpoint;
    Cikl  : Integer;
Begin
  Heap_Pos(Hline,PointerTomb^[HP]);
  Cikl := c77;
  While (Cikl > 0) And (Hline^.Chars[C80+Cikl] = #0) Do
    Dec(Cikl);
  If Hline^.Chars[C80+Cikl] <> #0 Then
    Inc(Cikl);
  SorH := Cikl;
  FreeEms1(PointerTomb^[HP]);
End;

Function SorE{(HP: Integer):Integer};
Var Hline : Lpoint;
    Cikl  : Integer;
Begin
  Heap_Pos(Hline,PointerTomb^[HP]);
  Cikl := 0;
  While (Cikl < c77) And (Hline^.Chars[C80+Cikl] = #0) Do
    Inc(Cikl);
  SorE := Cikl;
  FreeEms1(PointerTomb^[HP]);
End;

Function VanBennuk{(Hp1,Hp2,Xp : Integer):Boolean)};
Var Cikl : Integer;
Begin
  VanBennuk := False;
  For Cikl := Hp1 To Hp2 Do
    If VanBenne(Cikl,Xp) Then
      VanBennuk := True;
End;

Function InnenUres{(Hp1,Hp2,Xp : Integer):Boolean)};
Var Work : Boolean;
Begin
  Work := True;
    If VanBennuk(Hp1,Hp2,Xp) Then
End;

Function GoodLast{(Ennyi : Integer):Integer};
Begin
  If Ennyi > LastLine Then
    GoodLast := LastLine
  Else
    If Ennyi < FirstLine Then
      GoodLast := FirstLine
    Else
      GoodLast := Ennyi
End;


Function FirstMainLine;
Var Hp : Integer;
Begin
  Hp := StartLine[EditNum];
  While Not MainLine(Hp) Do
    Inc(Hp);
  FirstMainLine := Hp
End;

Function MainOfLine(HP:Integer):Integer;
Begin
  If MainLine(HP) Then
    MainOfLine := Hp
  Else
    If Upindex(HP) Then
      While Not(MainLine(HP)) Do
        Inc(HP)
    Else
      While Not(MainLine(HP)) Do
        Dec(HP)
End;


Procedure SeekToFirstLine;
Var Hp : Integer;
    d  : Integer;
Begin
  Hp := StartLine[EditNum];
  While Not MainLine(Hp) Do
    Inc(Hp);
  MainPs[EditNum]   := Hp-StartLine[EditNum]+1;
  NemKellS[Editnum] := UpInd(Hp)-1;
  Xps[EditNum]      := LeftMar[EditNum];
  Yps[EditNum]      := 1;
  Xel[EditNum]      := 0;
  D := 0;
  CountScount(Hp,NemKells[EditNum],D,0);
  Lcounts[EditNum] := Lcount;
  Pcounts[EditNum] := Pcount;
  Scounts[EditNum] := Scount;
End;

Procedure CountScount(HeapVeg:Integer;Var NemKell,HP : Integer;Lapra:Integer);

{ Elszamol a megadott heap - pozicioig. Visszaadja hogy hanyadik
  lapon vagyunk, a lap hanyadik soraban, es a file hanyadik soraban.
  Beallitja a lapveg stack-et.             }

Var Alsok,AlsokI,Felsok,Fop,SorCount : Integer;
    ContCount : Boolean;

    FoPP,HPP  : Lpoint;
    OldFp,
    OldHp     : Integer;
    HpE       : Integer;
    PP        : Boolean;


Procedure KiKelleLepni1;
Begin
  If (HP > EndLine[EditNum]) Then
    Begin
      PP := True;
      HP := 0
    End
End;

Procedure KiKellELepni2;
Begin
  PP := (Pcount >= (Lapra-1));
  If PP Then
    If Not(MainLineP(Hpp)) Then
      PP := False;
End;

Procedure SetFoP(Erre : Integer);
Begin
  If FoPP <> Nil Then
    FreeEms1(OldFp);
  FoP := Erre;
  OldFp := PointerTomb^[FoP];
  Heap_pos(FoPP,OldFp);
End;

Procedure SetHP(Erre : Integer);
Begin
  If HPP <> Nil Then
    FreeEms1(OldHp);
  HP := Erre;
  If Lapra <> 0 Then KikelleLepni1;
  If Not PP Then
    Begin
      OldHp := PointerTomb^[HP];
      Heap_pos(HPP,OldHp);
    End
  Else
    HPP := NIL
End;

Procedure IncKi;
Begin
  Inc(Scount);
  Inc(Lcount);
  If Lcount > PageLen-1 Then
    Begin
      Lcount := 0;
      Inc(Pcount)
    End;
  Inc(SorCount);
End;

Procedure CheckLapveg;
Begin
  If LapVegP(HpP) Then
    Begin
      Inc(Scount);

      Inc(LapVegSzam);
      LapVegTomb^[LapVegSzam] := Lcount;
      Inc(Pcount);
      Lcount := 0;
      Inc(SorCount);
    End
  Else
    IncKi
End;



Function KeresVege: Boolean;
Begin
  If Lapra = 0 Then
    KeresVege := (Fop >= HeapVeg) And (NemKell <= SorCount)
  Else
    KeresVege := PP
End;

Procedure UresFelsok(Idaig : Integer);
Begin
  While (Felsok > Idaig) And Not(KeresVege) do
    Begin
      IncKi;
      Dec(Felsok)
    End
End;

Procedure UresAlsok(Idaig : Integer);
Begin
  While (Alsok < Idaig) And Not(KeresVege) do
    Begin
      IncKi;
      Inc(Alsok)
    End
End;


Procedure CheckNewComplex;
Begin
  If Hp = Endline[Editnum] + 1 Then
    UresAlsok(Alsoki+1)
  Else
    If (MainLineP(HpP) Or UpIndexP(HpP)) And (Not KeresVege) Then
      Begin  { Fosor vagy felsoindex, tehat uj komplex sor }
        UresAlsok(AlsokI+1);
        If Not KeresVege Then
          Begin
            SetFop(HP);
            While NOT MainLineP(FopP) Do
              SetFoP(Fop+1);        {  Raall  a fosorra  }
            AlsokI := DownIndP(FopP); {  Osszes also  index, nem csak a heap - en }
            Felsok := UpIndP(FopP);   {  Osszes felso index, nem csak a heap - en }
            Alsok  := 1;            {  Az elso also index lesz                  }
            SorCount := 0
          End
      End;
End;


Begin  {  CountScount  }
  FoPP := NIL;
  Hpp  := NIL;
  HpE  := 0;
  PP   := False;

  ContCount := Hp <> 0;
  If Not ContCount Then
    Begin
      Hp := StartLine[EditNum];
    End;

  SetHp(Hp);
  SetFop(Hp);

  While NOT MainLineP(FopP) Do
    SetFoP(Fop+1); {  Ha az elejen hivtak meg, a fosorra all }

  {  A sor pointer most a komplex sor elso soran all. }
  If Not ContCount Then
    Begin
      Pcount := 0;            {  Nulla lap }
      Lcount := 0;            {  Hanyadik felsor a lapon                  }
      LapVegSzam := 0;        {  Nulla lapveg                             }
      Scount := 0  ;          {  Nulla sor kitoltve                       }
    End;
  AlsokI := DownIndP(FopP); {  Osszes also  index, nem csak a heap - en }
  Felsok := UpIndP(FopP);   {  Osszes felso index, nem csak a heap - en }
  Alsok  := 1;              {  Az elso also index lesz                  }
  SorCount := 0;            {  Meg 0 sorat dolgozta fel a comp. sornak  }
  Repeat  {  Ez a fo ciklus, a vegeig kitolti a lapot, vagy a Heap vegeig }
    If MainLineP(HpP) Then
      If Not KeresVege Then
        Begin { Ha fosor }
          UresFelsok(0);
          If Lapra <> 0 Then
            KiKellELepni2;
          If Not KeresVege Then
          Begin
            CheckLapveg;
            SetHp(Hp+1);
            CheckNewComplex
          End
        End  { Ha fosor }
      Else Begin end
    Else
      If UpIndexP(HpP) Then {  Ha felso index sor, }
        If Not KeresVege Then
          Begin
            UresFelsok(UpIndP(HpP));
            If Not KeresVege Then
            Begin
              CheckLapveg;
              Dec(Felsok);
              SetHp(Hp+1)
            End
          End { Ha felso index sor }
        Else Begin end
      Else
        If Not KeresVege Then
          Begin  {  Also index sor a heapen }
            UresAlsok(UpIndP(HpP));   {  !  }
            If Not KeresVege Then
              Begin
                CheckLapveg;
                Inc(Alsok);
                SetHp(Hp+1);
                CheckNewComplex  {  Megnezi, hogy uj komplex sor - e }
              End;
          End;  {  Ha also indexsor }

  Until KeresVege;


  If FoPP <> Nil Then
    FreeEms1(OldFp);
  If HPP <> Nil Then
    FreeEms1(OldHp);

  NemKell := SorCount;

End;  { CountScount }

Function CountNemkell{(Honnan : Integer):Integer};
Var MainP : Integer;
Begin
  MainP := MainOfIndex[Honnan];
  If MainLineI(Honnan) Then
    CountNemkell := UpInd(MainP)    { Felso sorok}
  Else
    If UpIndexI(Honnan) Then { Felso indexek az image-en }
      CountNemkell := UpInd(MainP)-UpIndI(Honnan)
    Else    {  Felso indexek + Alsok + Fosor }
      CountNemkell := UpInd(MainP) + UpIndI(Honnan)-1 + 1;

End;



Procedure BackCountScount{(HeapVeg : Integer)};

{ Visszaszamol a megadott heap - pozicioig. Visszaadja hogy hanyadik
  lapon vagyunk, a lap hanyadik soraban, es a file hanyadik soraban.
  Beallitja a lapveg stack-et.             }

Var Alsok,Felsok,FelsokI,Fop,SorCount,Elso,Utolso,Hp : Integer;
    ContCount : Boolean;

Procedure IncKi;
Begin
  Dec(Scount);
  Dec(Lcount);
  If Lcount < 0 Then
    Begin
      Lcount := PageLen;
      Dec(Pcount)
    End;
  Dec(SorCount);
End;

Procedure CheckLapveg;
Begin
  If LapVeg(Hp) Then
    Begin
      Dec(Scount);
      Lcount := PopLapveg;
      Dec(Pcount);
      Dec(SorCount);
    End
  Else
    IncKi
End;

Function KeresVege: Boolean;
Begin
  KeresVege := (Fop = HeapVeg) And (SorCount = 0)    { ?? }
End;

Procedure UresFelsok(Idaig : Integer);
Begin
  While (Felsok < Idaig) And Not(KeresVege) do
    Begin
      IncKi;
      Inc(Felsok)
    End
End;

Procedure UresAlsok(Idaig : Integer);
Begin
  While (Alsok > Idaig) And Not(KeresVege) do
    Begin
      IncKi;
      Dec(Alsok)
    End
End;

Procedure CheckNewComplex;
Begin
  If Hp = Startline[Editnum] - 1 Then
    UresFelsok(FelsokI+1)
  Else
    If (MainLine(Hp) Or Not(UpLine(Hp))) And (Not KeresVege) Then
      Begin  { Fosor vagy felsoindex, tehat uj komplex sor }
        UresFelsok(FelsokI+1);
        If Not KeresVege Then
          Begin
            Fop := HP;
            While NOT MainLine(Fop) Do
              Dec(Fop);            { Raall  a fosorra  }
            Alsok := DownInd(Fop);{ Osszes also  index, nem csak a heap - en }
            FelsokI := UpInd(Fop); { Osszes felso index, nem csak a heap - en }
            Felsok  := 1;          { Az elso felso index lesz                }
            SorCount := Alsok+Felsoki+1;
          End
      End;
End;

Begin  {  BackCountScount  }

  Fop := MainOfIndex[FirstLine];

  {  A sor pointer most a komplex sor elso soran all. }

  FelsokI := UpInd(Fop);   {  Osszes felso index, nem csak a heap - en }

  Hp := Fop;
  FirstAndLast(Fop,Elso,Utolso);
  SorCount := CountNemKell(FirstLine);
  If MainLineI(FirstLine) Then
    Begin
      Dec(Hp);
      Felsok := 1;
      CheckNewComplex
    End
  Else
    If UpIndexI(FirstLine) Then
       Begin
         Dec(Hp);
         Felsok := UpIndI(FirstLine)+1;
         While (Hp >= Elso) And (UpInd(Hp) <= UpIndI(FirstLine) )  Do
           Dec(Hp);
         CheckNewComplex
       End
     Else
       Begin
         Hp := Utolso;
         Alsok  := UpIndI(FirstLine)-1;
         Felsok := 1;
         While (Hp > Fop) And ( UpInd(Hp) >= UpIndI(FirstLine)) Do
           Dec(Hp);
       End;

  While Not KeresVege Do
    If MainLine(Hp) Then
      If Not KeresVege Then
        Begin { Ha fosor }
          UresAlsok(0);
          If Not KeresVege Then
          Begin
            CheckLapveg;
            Dec(Hp);
            CheckNewComplex
          End
        End  { Ha fosor }
      Else Begin end
    Else
      If UpLine(Hp) Then {  Ha felso index sor, }
        If Not KeresVege Then
         Begin
            UresFelsok(UpInd(Hp));
            If Not KeresVege Then
            Begin
              CheckLapveg;
              Inc(Felsok);
              Dec(Hp);
              CheckNewComplex  {  Megnezi, hogy uj komplex sor - e }
            End
          End { Ha felso index sor }
        Else Begin end
      Else
        If Not KeresVege Then
          Begin  {  Also index sor a heapen }
            UresAlsok(UpInd(Hp));   {  !  }
            If Not KeresVege Then
              Begin
                CheckLapveg;
                Dec(Alsok);
                Dec(Hp);
              End;
          End;  {  Ha also indexsor }
End;  {  BackCountScount  }

{$IFDEF Debug}

Procedure fifip;
Var Cik,Cik2 : Integer;
Begin
  {ize1;}
  Sound(1000);


  Assign(fifi,'FIFI'+FFF+'.PAS');
  rewrite(fifi);
  writeln(fifi,'AlsoIndexek :',AlsoIndexek);
  writeln(fifi,'FelsoIndexek :',FelsoIndexek);
  Writeln(fifi,'TrueLast :',TrueLast);
  For cik := 0 To LastLine do
    Begin
      Write(fifi,Char(Byte(Image[cik]^.Chars[C80+c78])+65),' ');
      write(fifi,cik:2,', MaO: ',MainOfIndex[cik]:3);
      write(fifi,#0);
      write(fifi,'ImTo :',ImageToHeap[cik]:3);
      If MainLineI(cik) Then
        write(fifi,' Main (',upindi(cik):3,',',
               downindi(cik):3,')(',
               Image[Cik]^.Attribs[0] And $F0 :3,')'#0#0)
      Else
        If UpindexI(cik) Then
          write(fifi,' Up '#0#0'(',upindi(cik):3,')(',
                 Image[Cik]^.Attribs[0] And $F0 :3,')'#0#0)
        Else
          write(fifi,' Down (',upindi(cik):3,')(',
               Image[Cik]^.Attribs[0] And $F0 :3,')'#0#0);
      Write(fifi,'|');
      For Cik2 := 0 to 26 Do
        Write(fifi,Image[cik]^.Chars[C80+cik2]);
      writeln(fifi,'|')
    End;
  writeln(fifi);
  writeln(fifi,'Full_Lines :',full_lines);
  for cik := 1 to full_lines do
    Begin
      Write(fifi,Cik:5,' ',PointerTomb^[Cik]:5,' ');
      If MainLine(cik) Then
        write(fifi,' Main (',upind(cik):3,',',
              downind(cik):3,')|')
      Else
        If Upindex(cik) Then
          write(fifi,'     Up   (',upind(cik):3,')')
        Else
          write(fifi,'     Down (',upind(cik):3,')');
      For Cik2 := 1 to 8 Do
        Write(fifi,#0);
      Write(fifi,'|');
      Heap_Pos(HeapLine,PointerTomb^[Cik]);
      For Cik2 := 0 to 36 Do
        Write(Fifi,HeapLine^.Chars[C80+Cik2]);
      FreeEms1(PointerTomb^[Cik]);
      Writeln(fifi,'|')
    End;
  For Cik := 1 to MaxEditor Do
    Begin
      Writeln(fifi,Cik:3,'- Start :',StartLine[cik]:3,
             '  End :',EndLine[Cik]:3)
    End;
  close(fifi);
  FFF := char(byte(FFF)+1);
  nosound;
End; { fifip }

{$ENDIF}

Procedure FillImage;
Begin
  Fillchar(Image[-2]^,((LastLine+3)*c160),0);  { [-2..LastLine] }
End;

Procedure FillSImage;
Begin
  Fillchar(Image[0]^,c160*(LastLine+1),0);  { [0..LastLine] }
End;

Procedure ComplexHeapToImage(HP,NemKell,HanyKell:Integer;Var KY : Integer);

{************************** Ez egy fontos rutin ! **********************
 **
 **   A heap-rol complex sorokat rak at az image-be.
 **   Fosorral erdemes meghivni, ha nem azzal hivjuk, a kovetkezo fosorra all.
 **   A NEMKELL parameter az, hogy a kerdeses fosorbol es indexsoraibol hany
 **   van mar kiirva (vagyis hanyat nem kell az uj lapra kiirnunk )
 **   A Ky parametertol kezdi az egeszet az Image-re rakni
 **   Hanykell szamu komplex sort csinal.
 **   KY - ba visszaadja hogy melyik az utolso sor amit kitoltott.
 **
 ***********************************************************************}

Var Kitoltve,Alsok,AlsokI,Felsok,Fop,SorCount : Integer;

Procedure UresFelsok(Idaig : Integer);
Begin
  While (Felsok > Idaig) And (Kitoltve <> LastLine) do
    If NemKell = 0 Then
      Begin  {  Ures felso index sor az Image -be }
        Inc(Kitoltve);
        FillImageLine(Kitoltve);
        Set_BitsI(Kitoltve,$0F,128);
        Set_IndI(Kitoltve,Felsok);
        MainOfIndex[Kitoltve] := Fop;
        ImageToHeap[Kitoltve] := 0;
        Dec(Felsok)
      End
    Else  { NemKell <> 0 }
      Begin
        Dec(Nemkell);
        Dec(Felsok);
      End;
End;


Procedure UresAlsok(Idaig : Integer);
Begin
  While (Alsok < Idaig) And (Kitoltve <> LastLine) do
    If NemKell = 0 Then
      Begin  {  Ures also index sor az Image -be }
        Inc(Kitoltve);
        FillImageLine(Kitoltve);
        Set_BitsI(Kitoltve,$0F,0);
        Set_IndI(Kitoltve,Alsok);
        MainOfIndex[Kitoltve] := Fop;
        ImageToHeap[Kitoltve] := 0;
        Inc(Alsok)
      End
    Else  { NemKell <> 0 }
      Begin
        Dec(Nemkell);
        Inc(Alsok);
      End;
End;

Procedure CheckNewComplex;
Begin
  If Hp = Endline[Editnum] + 1 Then
    UresAlsok(Alsoki+1)
  Else
    If MainLine(Hp) Or UpLine(Hp) Then
      Begin  { Fosor vagy felsoindex, tehat uj komplex sor }
        UresAlsok(AlsokI+1);
        Fop := HP;
        While NOT MainLine(Fop) Do
          Inc(Fop);             {  Raall  a fosorra  }
        AlsokI := DownInd(Fop); {  Osszes also  index, nem csak a heap - en }
        Felsok := UpInd(Fop);   {  Osszes felso index, nem csak a heap - en }
        Alsok  := 1;            {  Az elso also index lesz                  }
        Inc(SorCount);
      End;
End;


Begin  {  ComplexHeapToImage  }
  While NOT MainLine(HP) Do    {  Ha az elejen hivtak meg, a fosorra all }
    Inc(Hp);

  Fop := Hp;

  If Hp <> StartLine[EditNum] Then       {**** Ha nem a legelso sor a HEAP - en }
    If UpLine(HP-1) Then
      Begin             {**** Ha van felso indexe a Heap - en,  }
        While (Hp <> StartLine[EditNum]) And UpLine(Hp-1) Do
          Dec(Hp);      {**** megkeresi a sor elso felso indexet a Heap - en }
      End;

  {  A sor pointer most a komplex sor elso soran all. }

  Kitoltve := Ky-1;       {  Kesobb rogton noveljuk }
  AlsokI := DownInd(Fop); {  Osszes also  index, nem csak a heap - en }
  Felsok := UpInd(Fop);   {  Osszes felso index, nem csak a heap - en }
  Alsok  := 1;            {  Az elso also index lesz                  }
  SorCount := 0;          {  Meg 0 complex sort dolgozott fel         }

  Repeat  {  Ez a fo ciklus, a vegeig kitolti a lapot, vagy a Heap vegeig }
    If MainLine(Hp) Then
      Begin { Ha fosor }
        If Felsok <> 0 Then
          UresFelsok(0);
        If Kitoltve <> LastLine Then
          If Nemkell = 0 Then { megnezi rajta van - e a lapon }
            Begin  {  Ha igen,berakja az image-be }
              Inc(Kitoltve);
              MoveHeapLine(Hp,Kitoltve);
              MainOfIndex[Kitoltve] := Fop;
              ImageToHeap[Kitoltve] := Hp;
            End
          Else
            Dec(Nemkell);
        Inc(Hp);
        CheckNewComplex
      End  { Ha fosor }
    Else
      If UpLine(Hp) Then {  Ha felso index sor, }
        Begin
          UresFelsok(UpInd(Hp));
          If Kitoltve <> LastLine Then
            If Nemkell = 0 Then
              Begin
                Inc(Kitoltve);
                MoveHeapLine(Hp,Kitoltve);
                MainOfIndex[Kitoltve] := Fop;
                ImageToHeap[Kitoltve] := Hp;
                Dec(Felsok)
              End
            Else
              Begin
                Dec(Nemkell);
                Dec(Felsok)
              End;
          Inc(Hp)
        End { Ha felso index sor }
      Else
        Begin  {  Also index sor  }
          UresAlsok(UpInd(Hp));   {  !  }
          If Kitoltve <> LastLine Then
            If Nemkell = 0 Then
              Begin
                Inc(Kitoltve);
                MoveHeapLine(Hp,Kitoltve);
                MainOfIndex[Kitoltve] := Fop;
                ImageToHeap[Kitoltve] := Hp;
                Inc(Alsok)
              End
            Else
              Begin
                Dec(Nemkell);
                Inc(Alsok)
              End;
          Inc(Hp);
          CheckNewComplex  {  Megnezi, hogy uj komplex sor - e }
        End;  {  Ha also indexsor }

  Until (Kitoltve = LastLine) OR
        (Hp = Endline[Editnum] + 1) OR
        (SorCount = HanyKell);

  Ky := Kitoltve;
End;  {ComplexHeapToImage}


Procedure PageHeapToImage(Hp,Nemkell : Integer);
Var Kitoltve : Integer;
Begin
  {$IFNDEF CDVIEW}
  {$IFNDEF PACKARD}
  Inc(ElSzar,(Kivevo[1,1] Xor $AB)-(Kivevo2[1,1] XOR $CB)+
             (Kivevo[2,2] Xor $15)-(Kivevo2[2,2] XOR $ED));
  {$ENDIF}
  {$ENDIF}
{
  Writeln(lst,(Kivevo[1,1] Xor $AB):5,(Kivevo2[1,1] XOR $CB):5,
             (Kivevo[2,2] Xor $15):5,(Kivevo2[2,2] XOR $ED):5);
  writeln(lst,elszar);}

  FillSImage;
  Kitoltve := 0;
  Legfelso := False;
  ComplexHeapToImage(Hp,Nemkell,38,Kitoltve);
  TrueLast := Kitoltve;
  If Kitoltve = LastLine Then LegAlso := False
End;

Procedure OneComplexToImage(Hp,Yp : Integer);
Var Kitoltve : Integer;
Begin
  {$IFNDEF CDVIEW}
  {$IFNDEF PACKARD}
  Inc(ElSzar,(Kivevo[3,3] XOR $09)-(Kivevo2[3,3] XOR $13)+
             (Kivevo[4,4] XOR $B8)-(Kivevo2[4,4] XOR $25));
  {$ENDIF}
  {$ENDIF}
{  Writeln(lst,elszar);}
  Kitoltve := Yp;
  If Kitoltve = FirstLine Then
    LegFelso := False;
  ComplexHeapToImage(Hp,0,1,Kitoltve);

  If Kitoltve > TrueLast Then
    TrueLast := Kitoltve;
  If Kitoltve = LastLine Then LegAlso := False
End;

Procedure HalfToImage(Hp,Yp,Nemkell,Hanyat : Integer);
Var Kitoltve : Integer;
Begin
  Kitoltve := Yp;
  If Kitoltve = FirstLine Then
    LegFelso := False;
  ComplexHeapToImage(Hp,Nemkell,Hanyat,Kitoltve);

  If Kitoltve > TrueLast Then
    TrueLast := Kitoltve;
  If Kitoltve = LastLine Then LegAlso := False
End;


End.  {  Unit  Heap  }
