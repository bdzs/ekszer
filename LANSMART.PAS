Unit LanSmart;

Interface

Function CheckLanSmart:Boolean;

Implementation
{
Type
  CHTomb = Array[1..15] Of Char;
Const
  LanSmartAzon : CHTomb = #$2E#$83#$3E#$0C#$00+
                          #$FF#$74#$03#$E9#$7F+
                          #$00#$2E#$80#$3E#$18;

Function CheckLanSmart:Boolean;
Var LanSmartPoint : ^ChTomb;
Begin
  LanSmartPoint := Ptr(MemW[$0000:08*4+2],MemW[$0000:08*4]);
  CheckLanSmart := (LanSmartPoint^ = LanSmartAzon)
End;
 }
Function CheckLanSmart : Boolean;
Type  DWord =
      Record
        Offset : Word;
        Segment: Word;
      End;
      PType = ^DWord;
Var P,Fp     : PType;
    Block_Size,
    OSegment,
    Segment  : Word;
    ProgName : String[8];
    ProgCount,
    MCB_ID   : Byte;
    RezLen   : LongInt;
    JoVolt   : Boolean;

Procedure UpperCase(Var X:String);
Var Cik : Byte;
Begin
  For Cik := 1 To Length(X) Do X[Cik] := UpCase(X[Cik]);
End;

Procedure Create_Fn;
Var Poz : Byte;
Begin
    Fp := Ptr(Segment,8);
    ProgName[0] := #8;
    Move(Fp^,ProgName[1],8);
    Poz := Pos(#00,ProgName);
    If Poz = 00 Then Poz := 9;
    ProgName := Copy(ProgName,1,Poz-1);
    UpperCase(ProgName);
    If (ProgName = 'LANSMA10') OR
       (ProgName = 'LANSMA11') Then
    Begin
      Inc(ProgCount);
      JoVolt := True;
    End;
End;

Begin
  RezLen    := 0;
  ProgCount := 0;
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
    If JoVolt Then Inc(RezLen,Block_Size*16);
    JoVolt := False;
    Inc(Segment,Block_Size+1);
    Create_Fn;
  Until (MCB_ID = $5A);

  CheckLanSmart := (ProgCount >= 2) AND
                    ( (RezLen > 20000) AND (RezLen < 23000) );
End;

End.