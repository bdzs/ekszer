Unit ChkPack;

InterFace
Procedure ChkPck;

Implementation

Uses DOS,Crt,Windowm,inputcdw,MenuErr;

Var Dummy,
    XC1,
    XC2,
    XC3    : Word;
    MS_DOS : Boolean;


Const EmblemaNagy = $360-1;
      PbEmblema : Array[0..EmblemaNagy] Of Byte =
(
$00,$00,$00,$00,$00,$00,$07,$07,$07,$0F,$0F,$0F,$0F,$1F,$1F,$1F,
$00,$00,$00,$00,$00,$00,$FF,$FF,$C3,$C1,$C1,$C1,$81,$81,$83,$87,
$00,$00,$00,$00,$00,$00,$80,$E0,$E0,$F1,$F1,$F3,$F3,$E7,$E7,$CE,
$00,$00,$00,$00,$00,$00,$78,$F8,$F8,$FC,$FC,$FC,$FC,$7E,$7E,$3E,
$00,$00,$00,$00,$00,$00,$00,$01,$07,$0F,$1F,$1F,$3F,$3F,$7E,$7E,
$00,$00,$00,$00,$00,$00,$3F,$FF,$F8,$E0,$C0,$80,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$E0,$FC,$7C,$1D,$09,$09,$01,$03,$03,$03,
$00,$00,$00,$00,$00,$00,$FC,$FC,$F8,$F8,$F8,$F1,$F3,$F7,$FF,$FF,
$00,$00,$00,$00,$00,$00,$0F,$1F,$3C,$78,$F0,$E0,$C0,$80,$00,$00,
$00,$00,$00,$00,$00,$00,$83,$07,$07,$0F,$0F,$1F,$1F,$3B,$3B,$71,
$00,$00,$00,$00,$00,$00,$C0,$C0,$C0,$E0,$E0,$E0,$E0,$F0,$F0,$F0,
$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$1F,$1F,$1F,$1F,$3F,$3F,$3F,
$00,$00,$00,$00,$00,$00,$FF,$FF,$87,$83,$83,$03,$03,$03,$07,$0F,
$00,$00,$00,$00,$00,$00,$01,$C1,$C1,$E3,$E3,$E3,$E3,$C7,$C7,$87,
$00,$00,$00,$00,$00,$00,$FF,$FF,$F0,$F0,$F0,$E0,$E0,$E0,$E0,$C0,
$00,$00,$00,$00,$00,$00,$F0,$FC,$7E,$3F,$3F,$1F,$1F,$1F,$1F,$1F,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$80,$80,$80,$80,$80,
$00,$00,$00,$00,$00,$00,$3F,$3F,$3E,$7E,$7E,$7C,$7C,$FC,$FC,$FF,
$00,$00,$00,$00,$00,$00,$F8,$FE,$1E,$0F,$0F,$0F,$0E,$1E,$7C,$F0,
$00,$00,$00,$00,$00,$00,$0F,$0F,$0F,$1F,$1F,$1F,$1F,$3F,$3F,$3F,
$00,$00,$00,$00,$00,$00,$FE,$FC,$80,$80,$80,$00,$00,$00,$00,$F0,
$00,$00,$00,$00,$00,$00,$3F,$3E,$3E,$7E,$7C,$7C,$7C,$FC,$F8,$F8,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$03,$03,$03,
$00,$00,$00,$00,$00,$00,$FC,$F8,$F8,$F8,$F0,$F0,$F0,$F0,$E0,$E0,
$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$03,$03,$00,
$00,$00,$00,$00,$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,
$00,$00,$00,$00,$00,$00,$F0,$F0,$E0,$E0,$E0,$E0,$C0,$C0,$C0,$00,
$1F,$3F,$3F,$3F,$3E,$7E,$7E,$7E,$7C,$FC,$FC,$00,$00,$00,$00,$00,
$FF,$FE,$00,$00,$00,$00,$00,$00,$00,$01,$03,$00,$00,$00,$00,$00,
$8E,$1C,$1C,$3F,$3F,$78,$70,$E0,$E0,$C0,$C0,$00,$00,$00,$00,$00,
$3E,$3F,$1F,$FF,$FF,$1F,$1F,$1F,$0F,$0F,$0F,$00,$00,$00,$00,$00,
$7E,$7E,$7E,$7E,$7F,$BF,$BF,$9F,$8F,$C3,$C0,$00,$00,$00,$00,$00,
$00,$00,$00,$00,$00,$00,$80,$C1,$FF,$FF,$FE,$00,$00,$00,$00,$00,
$03,$07,$07,$07,$07,$2F,$6F,$EF,$CF,$9F,$1F,$00,$00,$00,$00,$00,
$FF,$FF,$FF,$EF,$CF,$C7,$C7,$C3,$83,$81,$81,$00,$00,$00,$00,$00,
$00,$80,$80,$C1,$C1,$E3,$E3,$F7,$FF,$FE,$FE,$00,$00,$00,$00,$00,
$71,$E1,$E0,$FF,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,
$F0,$F8,$F8,$F8,$F8,$FC,$FC,$FC,$7C,$7F,$7F,$00,$00,$00,$00,$00,
$3F,$7F,$7F,$7C,$7C,$FC,$FC,$F8,$F8,$F8,$F8,$00,$00,$00,$00,$00,
$FE,$F8,$F8,$FC,$FC,$7E,$7E,$3F,$3F,$1F,$1F,$00,$00,$00,$00,$00,
$07,$0F,$0F,$0F,$0F,$1F,$1F,$1F,$1F,$BF,$BF,$00,$00,$00,$00,$00,
$C0,$C0,$C0,$80,$80,$80,$81,$03,$0F,$FF,$FE,$00,$00,$00,$00,$00,
$1F,$1F,$3F,$3F,$7E,$FE,$FC,$F8,$F0,$C0,$00,$00,$00,$00,$00,$00,
$80,$81,$01,$01,$01,$03,$03,$03,$03,$07,$07,$00,$00,$00,$00,$00,
$FF,$F8,$F8,$F0,$F0,$F0,$F0,$E0,$E0,$FF,$FF,$00,$00,$00,$00,$00,
$F8,$7C,$3C,$3E,$3E,$3E,$7E,$7C,$FC,$F9,$E1,$00,$00,$00,$00,$00,
$3F,$7E,$7E,$7C,$7C,$FC,$FC,$F8,$F8,$FF,$FF,$00,$00,$00,$00,$00,
$F0,$01,$01,$01,$01,$03,$03,$03,$03,$E7,$F7,$00,$00,$00,$00,$00,
$F8,$F8,$F0,$F0,$F0,$F0,$E0,$E0,$E0,$FF,$FF,$00,$00,$00,$00,$00,
$03,$07,$07,$07,$07,$0F,$0F,$0F,$0F,$9F,$DF,$00,$00,$00,$00,$00,
$E0,$E0,$C0,$C0,$C0,$C0,$80,$80,$80,$FE,$FF,$00,$00,$00,$00,$00,
$00,$00,$03,$03,$03,$07,$07,$07,$07,$0F,$0F,$00,$00,$00,$00,$00,
$00,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00,$00,
$00,$00,$C0,$C0,$80,$80,$80,$80,$00,$00,$00,$00,$00,$00,$00,$00
);

Procedure ReadCmos;
Var Cikl : Integer;
Begin
  For Cikl := 1 To 6 Do
    Begin
      Port[$70] := CmosStartT[GepType,Cikl];
      Delay(1);
      TimePack3[Cikl] := Port[$71];
    End
End;

Procedure ReadCluster;
Type

FileRec  = Record

             Name    : String[8];
             Ext     : String[3];
             AttrByte: Byte;
             Size    : LongInt;
             RDate   : Integer;
             RTime   : LongInt;
             Attrib  : String[4];
             User    : String[12];

           End;

Var Poz,Kc,
    Counter,
    Cik       : Byte;
    Kilep     : Boolean;
    Int25Vec  : Pointer Absolute $0000:$0094;
    C,Ch      : Char;
    OnlyOne   : Boolean;
    Lin       : String[44];
    By        : Array[1..4] Of Byte;
    OP,P      : Pointer;
    Pr        : Pointer_Rec Absolute P;
    OPr       : Pointer_Rec Absolute OP;
    St,Fn,
    Fname     : String[40];
    Reg       : Registers;
    Frec      : SearchRec;


Const
    Int25 : String[4] = '    ';
    MS_DOSInt25   : String[4] = #$FA#$2E#$8C#$16;
    MS_DOS5_Int25 : String[4] = #$FA#$50#$8C#$D8;
    MS_DOS5_Int25_HiMem : String[3] = #$90#$90#$E8;

Begin

  OnlyOne := True;

  Fn := 'EKSZER.SYS';

  If OrigPath[Length(OrigPath)] <> '\' Then Fn := '\' + Fn;

  FindFirst(OrigPath+Fn,$37,Frec);

  If Frec.Name[1] <> '.' Then
  Begin
    Fname := '           ';                      { Make FCB style filename }
    Poz   := Pos('.',Frec.Name);

    If Poz = 0 Then
      Fname := Frec.Name
    Else
    Begin
      Fname    := Copy(Frec.Name,1,Poz-1);
      Fname[0] := #08;
      Fname    := Fname + Copy(Frec.Name,Poz+1,3);
    End;

    Fname[0] := #11;
    Ch       := Fname[1];

    Move(Int25Vec^,Int25[1],4);

    MS_DOS := (Int25 = MS_DOSInt25) OR              { 3.30, 4.01 }
              (Int25 = MS_DOS5_Int25) OR            { 5.00       }
              (Int25[3] = MS_DOS5_Int25_HiMem[3]);  { 5.00 HIMEM }

    If MS_DOS Then
    Begin

      With Reg Do
      Begin
        AH := $34;     { Get INDOS Flag : Segment of INT 21 }
        Intr($21,Reg);
        P := Ptr(ES,BX);
      End;

      St[0] := #11;
      Kilep  := False;
      Counter:= 0;

      Repeat
        While (Pr.Offset < $FFFF) AND (Char(P^) <> Ch) Do Inc(Pr.Offset);
        Move(P^,St[1],11);

        If Pr.Offset = $FFFF Then
        Begin
          If MS_DOS Then
            Kilep := True
          Else
          Begin
            Inc(Pr.Segment,$1000);
            Pr.Offset := $0000;
            Inc(Counter);
            If Counter = 2 Then Kilep := True;
          End;
        End
        Else Inc(Pr.Offset);

        If (OnlyOne) And (St = Fname) Then
        Begin
          St[1]  := #255;
          OnlyOne:= False;
        End;

      Until (St = Fname) OR (Kilep);

      If MS_DOS Then Inc(Pr.Offset,11+14)
                Else Inc(Pr.Offset,$19);

      Move(P^,Cluster,2);

    End;

  End;

  If NOT MS_DOS Then Cluster := $3345;
  { writeln(Cluster); }

End;


Procedure IdoDekodolas(Var B6:Byte6; Var C: Word);
Var Cik,X : Byte;
    T     : Array [1..6] Of Byte;
Begin

  C := 0000;

  For Cik := 1 DownTo 0 Do
  Begin
    C := C SHL 1;
    C := C OR ((B6[3*Cik+1] AND $80) SHR 7);   C := C SHL 1;
    C := C OR ((B6[3*Cik+1] AND $10) SHR 4);   C := C SHL 1;
    C := C OR ((B6[3*Cik+1] AND $02) SHR 1);   C := C SHL 1;
    C := C OR ((B6[3*Cik+2] AND $40) SHR 6);   C := C SHL 1;
    C := C OR ((B6[3*Cik+2] AND $08) SHR 3);   C := C SHL 1;
    C := C OR ((B6[3*Cik+2] AND $01) SHR 0);   C := C SHL 1;
    C := C OR ((B6[3*Cik+3] AND $20) SHR 5);   C := C SHL 1;
    C := C OR ((B6[3*Cik+3] AND $04) SHR 2);
  End;

  For Cik := 1 To 6 Do T[Cik] := 00;

  For Cik := 0 To 1 Do
  Begin
    T[2*Cik+1] := T[2*Cik+1] OR ((B6[3*Cik+1] AND $60) SHR 5);   T[2*Cik+1] := T[2*Cik+1] SHL 2;
    T[2*Cik+1] := T[2*Cik+1] OR ((B6[3*Cik+1] AND $0C) SHR 2);   T[2*Cik+1] := T[2*Cik+1] SHL 1;
    T[2*Cik+1] := T[2*Cik+1] OR ((B6[3*Cik+1] AND $01) SHR 0);   T[2*Cik+1] := T[2*Cik+1] SHL 1;
    T[2*Cik+1] := T[2*Cik+1] OR ((B6[3*Cik+2] AND $80) SHR 7);   T[2*Cik+1] := T[2*Cik+1] SHL 2;
    T[2*Cik+1] := T[2*Cik+1] OR ((B6[3*Cik+2] AND $30) SHR 4);
    T[2*Cik+2] := T[2*Cik+2] OR ((B6[3*Cik+2] AND $06) SHR 1);   T[2*Cik+2] := T[2*Cik+2] SHL 2;
    T[2*Cik+2] := T[2*Cik+2] OR ((B6[3*Cik+3] AND $C0) SHR 6);   T[2*Cik+2] := T[2*Cik+2] SHL 2;
    T[2*Cik+2] := T[2*Cik+2] OR ((B6[3*Cik+3] AND $18) SHR 3);   T[2*Cik+2] := T[2*Cik+2] SHL 2;
    T[2*Cik+2] := T[2*Cik+2] OR ((B6[3*Cik+3] AND $03) SHR 0);
  End;

  Move(T,B6,4);

End;

Procedure DatumDekodolas(Var B4:Byte4; Var C: Word);
Var Cik,X : Byte;
    T     : Array [1..6] Of Byte;
Begin

  (*
  C := 0000;

  For Cik := 1 DownTo 0 Do
  Begin
    C := C SHL 1;
    C := C OR ((B6[3*Cik+1] AND $80) SHR 7);   C := C SHL 1;
    C := C OR ((B6[3*Cik+1] AND $10) SHR 4);   C := C SHL 1;
    C := C OR ((B6[3*Cik+1] AND $02) SHR 1);   C := C SHL 1;
    C := C OR ((B6[3*Cik+2] AND $40) SHR 6);   C := C SHL 1;
    C := C OR ((B6[3*Cik+2] AND $08) SHR 3);   C := C SHL 1;
    C := C OR ((B6[3*Cik+2] AND $01) SHR 0);   C := C SHL 1;
    C := C OR ((B6[3*Cik+3] AND $20) SHR 5);   C := C SHL 1;
    C := C OR ((B6[3*Cik+3] AND $04) SHR 2);
  End;
  *)

  For Cik := 1 To 4 Do T[Cik] := 00;

  For Cik := 0 To 1 Do
  Begin
    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+1] AND $40) SHR 6);   T[Cik+1] := T[Cik+1] SHL 1;
    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+1] AND $10) SHR 4);   T[Cik+1] := T[Cik+1] SHL 1;
    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+1] AND $04) SHR 2);   T[Cik+1] := T[Cik+1] SHL 1;
    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+1] AND $01) SHR 0);   T[Cik+1] := T[Cik+1] SHL 1;

    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+2] AND $40) SHR 6);   T[Cik+1] := T[Cik+1] SHL 1;
    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+2] AND $10) SHR 4);   T[Cik+1] := T[Cik+1] SHL 1;
    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+2] AND $04) SHR 2);   T[Cik+1] := T[Cik+1] SHL 1;
    T[Cik+1] := T[Cik+1] OR ((B4[2*Cik+2] AND $01) SHR 0);   {T[Cik+1] := T[Cik+1] SHL 1;}
  End;

  Move(T,B4,2);

End;

(*
Procedure DeKodolas(Var X;Var Kod:Word);
Begin
  Move(Ptr(Seg(X),Ofs(X)+4)^,Kod,2);
End;
*)
(*
Procedure writep(Var X;C:Word);
Var Cikl : Word;
    TT : Array[1..6] Of Byte Absolute X;
Begin
  Write(Lst,'>>');
  For Cikl := 1 To C Do
    Write(Lst,Dec_Hex(TT[Cikl],2),' ');
  Writeln(lst)
End;
*)

Procedure TimeCoding;
Var Cikl     : Integer;
    XCluster : Word;
    S1,S2    : String;
    CmosOk,
    ClusterOk: Boolean;

Begin

{
  Writep(DatePack1,4);
  Writep(DatePack2,4);
  Writep(TimePack1,6);
  Writep(TimePack2,6);
  Writep(TimePack3,6);
}

  XCluster := Cluster Xor $29A7;

  For Cikl := 1 To 4 Do                                  { Utokodolas }
    DatePack1[Cikl] := DatePack1[Cikl] Xor XorA[1,7-Cikl];

  For Cikl := 1 To 4 Do                                  { Utokodolas }
    DatePack2[Cikl] := DatePack2[Cikl] Xor XorA[2,7-Cikl];

                                                         
  For Cikl := 1 To 6 Do                                  { Utokodolas }
    TimePack1[Cikl] := TimePack1[Cikl] Xor XorA[1,7-Cikl];
                                                         
  For Cikl := 1 To 6 Do                                  { Utokodolas }
    TimePack2[Cikl] := TimePack2[Cikl] Xor XorA[2,7-Cikl];

  For Cikl := 1 To 6 Do                                  { Utokodolas }
    TimePack3[Cikl] := TimePack3[Cikl] Xor XorA[3,7-Cikl];


  DatumDeKodolas(DatePack1,Dummy);
  IdoDeKodolas(TimePack1,Dummy);

  DatumDeKodolas(DatePack2,Dummy);
  IdoDeKodolas(TimePack2,XC2);

  IdoDeKodolas(TimePack3,XC3);


  For Cikl := 1 To 2 Do                                  { Elokodolas }
    DatePack1[Cikl] := DatePack1[Cikl] Xor XorA[1,Cikl];

  For Cikl := 1 To 2 Do                                  { Elokodolas }
    DatePack2[Cikl] := DatePack2[Cikl] Xor XorA[2,Cikl];

                                                         
  For Cikl := 1 To 4 Do                                  { Elokodolas }
    TimePack1[Cikl] := TimePack1[Cikl] Xor XorA[1,Cikl];
                                                         
  For Cikl := 1 To 4 Do                                  { Elokodolas }
    TimePack2[Cikl] := TimePack2[Cikl] Xor XorA[2,Cikl];

  For Cikl := 1 To 4 Do                                  { Elokodolas }
    TimePack3[Cikl] := TimePack3[Cikl] Xor XorA[3,Cikl];


  Move(DatePack1,DD1,2);
  Move(DatePack2,DD2,2);

  Move(TimePack1,TT1,4);
  Move(TimePack2,TT2,4);
  Move(TimePack3,TT3,4);

  JoCmos := True;


  ClusterOk :=  (((XC2=XCluster) AND ({XC2=XC3}True)) OR (Not MS_DOS));
  CmosOk    :=  {(TT1=TT2) And (TT1=TT3) And (DD1=DD2)} True;

  If NOT (ClusterOk And CmosOk) Then
    Begin
      If Not(CMOSOK) And Not(ClusterOk) Then
        Inline($EA/$F0/$FF/$00/$f0);            { JMP F000:FF00  Elszall ! }

      Error(20,'A rendszerkîrnyezet megv†ltozott, kÇrjÅk Çrtes°tse a SZINVA-NET Kft-t !');
      JoCmos := False;
    End
  Else
    Begin  { Serial number keszites }
      str(TT1:0,S1);
      Str(DD1:0,S2);
      FillChar(SerSt,64,' ');
      SerSt := S2+'-'+S1;
      Move(SerSt[1],CopyRight2[Pos('Sorsz',CopyRight2)],17);

      { Password ellenorzes }
      For Cikl := 1 To 10 Do
        Begin
          Enabled[Cikl] := CreatePassword(SerSt,Cikl) = PW1[Cikl];
        End;

      Enabled[1] := True;
    End

End;

Procedure CheckPackardBell;
Var Cikl,
    Plus : Word;
    Szar : Boolean;
Begin
  Cikl := 0;
  Repeat
    Plus := 0;
    While (Mem[$F000:Cikl+Plus] = PbEmblema[Plus]) And
          ((Cikl+Plus) < $FFFF) And
          (Plus < 500) Do Inc(Plus);
    Inc(Cikl);
  Until (Plus >= 500) Or (Cikl > $FFF0);
  Szar := Plus < 500;

  If Szar Then
    Begin
      Cikl := 0;
      Repeat
        Plus := 0;
        While (Mem[$E000:Cikl+Plus] = PbEmblema[Plus]) And
              ((Cikl+Plus) < $FFFF) And
              (Plus < 500) Do Inc(Plus);
        Inc(Cikl);
      Until (Plus >= 500) Or (Cikl > $FFF0);
      Szar := Plus < 500;
    End;
  If Szar Then
    Inline($EA/$F0/$FF/$00/$f0)                  { JMP F000:FF00  Elszall ! }
End;

Procedure Chkpck;

Begin
  CheckPackardBell;
  ReadCluster;
  ReadCmos;
  TimeCoding;
End;


Begin
End.