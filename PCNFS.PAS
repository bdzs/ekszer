{$IFDEF STANDALONE}

Program PCNFS;

{$ELSE}
Unit PCNFS;

Interface

Function Check_PCNFS:Boolean;

Implementation

{$ENDIF}


Function Check_PCNFS : Boolean;

Type  DWord =
      Record
        Offset : Word;
        Segment: Word;
      End;
      PType = ^DWord;

Var P,Fp,P2  : PType;
    Block_Size,
    OSegment,
    Segment,Offset  : Word;
    ProgName : String[8];
    ProgCount: Byte;
    Count5A  : Byte;
    MCB_ID   : Byte;
    TotalLen,
    RezLen   : LongInt;
    JoVolt   : Boolean;
    ProgN    : Array[1..12] Of String[8];
    ProgS    : Array[1..12] Of LongInt;
    Jo       : Boolean;
    Kc,Tc    : Byte;
    Cikl     : Integer;

Const

    ProgDb   : Byte = 2;
    Pr       : Array[1..12] Of String[8] =

    ('NET','ENETCPSH','','','','','','','','','','');

    PSize    : Array[1..12] Of LongInt   =

    (50640,4208,0,0,0,0,0,0,0,0,0,0);

Procedure UpperCase(Var X:String);
Var Cik : Byte;
Begin
  For Cik := 1 To Length(X) Do X[Cik] := UpCase(X[Cik]);
End;

Procedure Set_Programs;
Const Ekf = 'EKSZER.000';
Var   Fn  : String[76];
      Poz : Word;
      Cik,
      I,
      Bc  : Byte;
      F   : File;
      St  : String[8];
      IOR,IO : Integer;
Begin
  Fn := ParamStr(0);
  While (Length(Fn) > 0) AND (Fn[Length(Fn)] <> '\') Do Dec(Byte(Fn[0]));
  Fn := Fn + Ekf;

  TotalLen := 0;

  Cik := 0;
  Repeat
    Fn[Length(Fn)] := Char(Cik+Byte('0'));  {'.000'  '.001' '.002' stb.}
    Assign(F,Fn);
    {$I-}
    Reset(F,1);
    IOR := IOResult;
    If IOR = 0 Then
    Begin
      Inc(Cik);
      PSize[Cik] := FileSize(F);
      Seek(F,PSize[Cik]-2);
      IO  := IOResult;
      BlockRead(F,Poz,2);
      IO  := IOResult;
      Seek(F,Poz);
      IO  := IOResult;
      BlockRead(F,St[0],1);
      IO  := IOResult;
      Byte(St[0]) := Byte(St[0]) XOR $11;
      If (Byte(St[0]) > 8) OR (Byte(St[0]) < 1) Then St[0] := #8;
      BlockRead(F,St[1],Byte(St[0]));
      IO  := IOResult;
      For Bc := 1 To Length(St) Do
        St[Bc] := UpCase(Char(Byte(St[Bc]) XOR $11*(Bc+1)));
      Pr[Cik] := St;
      Close(F);
      IO := IOResult;
      {$I+}
    End;
  Until IOR <> 0;

  If Cik > 0 Then ProgDb := Cik;

  For I := 1 To ProgDb Do Inc(TotalLen,PSize[I]);

End;

Procedure Create_Fn;
Var Poz,X : Byte;
Begin
    Fp := Ptr(Segment,8);
    ProgName[0] := #8;
    Move(Fp^,ProgName[1],8);
    Poz := Pos(#00,ProgName);
    If Poz = 00 Then Poz := 9;
    If Poz > 1 Then ProgName := Copy(ProgName,1,Poz-1);
    UpperCase(ProgName);

    X := 1;
    While (X <= ProgDb) AND (ProgName <> Pr[X]) Do Inc(X);

    If X <= ProgDb Then {megvan a filen‚v}
      If ProgCount < 12 Then
    Begin
      Inc(ProgCount);
      ProgN[ProgCount] := ProgName;
      JoVolt := True;
    End;
End;

Begin

  Set_Programs;

  RezLen    := 0;
  ProgCount := 0;
  Count5A   := 0;
  P := Ptr(PrefixSeg,$10);

  Repeat
    Segment := P^.Offset - 1;
    Create_Fn;
    Osegment := Segment + 1;
    P := Ptr(Segment+1,$10);
  Until (Seg(P^) = OSegment);

  Segment := OSegment - 1;

  Block_Size := 00;
  JoVolt := False;

  Repeat
    P := Ptr(Segment,0);
    MCB_ID := Lo(P^.Offset);
    P := Ptr(Segment,3);
    Block_Size := P^.Offset;
    P2 := Ptr(Segment,1);
    Offset := P2^.Offset;

    If ProgCount <= 12 Then
      If JoVolt Then
      Begin
        Inc(RezLen,Block_Size*16);
        ProgS[ProgCount] := Block_Size*16;
      End;

    JoVolt := False;
    Inc(Segment,Block_Size+1);
    Create_Fn;
    If MCB_ID=$5A Then INC(Count5A);
  Until (ProgCount >= 12) OR
        ((MCB_ID  = {00}$5A) AND (Count5A > 1)) OR
        ((MCB_ID <> $5A) AND (MCB_ID <> $4D));

{$IFDEF STANDALONE}
  WriteLn('Keresek ',ProgDb,' darabot');
  For Cikl := 1 To ProgDb Do
    WriteLn(Cikl:4,'  ',Pr[Cikl]:8,'  ',PSize[Cikl]:5);

  WriteLn('Tal ltam ',ProgCount,' darabot');
  For Cikl := 1 To ProgCount Do
    WriteLn(Cikl:4,'  ',ProgN[Cikl]:8,'  ',ProgS[Cikl]:5);

{$ENDIF}

  Jo := False;

  If ProgCount > 0 Then
  Begin
    For Kc := 1 To ProgDb Do
      For Tc := 1 To ProgCount Do
      Begin
        If (Pr[Kc] = ProgN[Tc]) Then
          If ((ProgS[Tc] > 0.9*PSize[Kc]) AND (ProgS[Tc] < 1.2*PSize[Kc])) Then
            Jo := True;
      End;
  End;

  Check_PCNFS := Jo;

End;


{$IFDEF STANDALONE}
Begin
   WriteLn(Check_PCNFS);
{$ENDIF}

End.