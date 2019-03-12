Program Tif2Cdw;

Uses InputKit,crt;

Const PicExt = '.@@@';
Var   Fnam   : String[40];


Function ConvertTif(Name : String):Boolean;

Const PuffMeret = 5000;

Var F,F2    : File;
    Dx,Dy   : LongInt;
    RastBeg : LongInt;
    Xbyte   : LongInt;
    Puffer  : Array[0..PuffMeret-1] Of Byte;
    Blocks,
    Maradek : Word;
    ConvOk  : Boolean;
    OkTif,
    TiffTom : Boolean;

Procedure TiffHeader(Var f       : File;
                     Var Dx,Dy   : LongInt;
                     Var RastBeg : Longint);

Type
     TiffHeadT =
     Record
       Sorrend : Word;
       Verzio  : Word;
       IFDOffs : Longint
     End;

     IFDMezo =
     Record
       Tag    : Word;
       MTip   : word;
       Mhossz : Longint;
       Case Byte Of
         1:
            (Moffs  : Longint);
         2:
            (B      : Array[1..4] Of Byte);
         3:
            (W      : Array[1..2] Of Word)


     End;

Var
    W          : Word;
    ms         : word;
    Volt : Word;
    o    : Longint;
    Head : TiffHeadT;
    Mezo : IfdMezo;
    Cikl : Integer;

Const SizeTip : Array[1..5] Of Byte = (1,1,2,4,4);


Begin
  TiffTom := False;
  OkTif := True;
  BlockRead(f,head,8);
  o := Head.IFDOffs;
  Volt := 0;
  While (o <> 0) and (o < 5000) And (o > 0) Do
    Begin
      Seek(f,o);
      BlockRead(f,ms,2);
      For Cikl := 1 To Ms Do
        With Mezo Do
          Begin
            Seek(f,o+2+(Cikl-1)*12);
            BlockRead(f,Mezo,12);
            Case Tag Of
              $100 : Begin
                       DX := W[1];
                       Inc(Volt);
                     End;
              $101 : Begin
                       DY := W[1];
                       Inc(Volt);
                     End;
              $103 : If Moffs = 32773 Then
                       TiffTom := True
                     Else
                       If Moffs <> 1 Then
                         OkTif := False;
              $111 : Begin
                       If Mhossz > 1 Then
                         Begin
                           Seek(f,Moffs);
                           BlockRead(f,RastBeg,4);
                         End
                       Else
                         RastBeg := Moffs;
                       Inc(Volt)
                     End;
              End
          End;
      BlockRead(f,o,4);
    End;
  ConvOk := (Volt >= 3) And OkTif;
End; { TiffHeader }

Var Cikl,cikl2 : Integer;
    Short : ShortInt;
    Xh    : Word;

Begin
  {$i-} assign(f,name+'.TIF');
  reset(f,1); {$I+}

  ConvOk := Ioresult = 0;
  If ConvOk Then
    Begin
      TiffHeader(f,Dx,Dy,RastBeg);
      If ConvOk Then
        Begin
          Seek(f,rastbeg);
          Xbyte := (dx + 7) Div 8;
          Assign(f2,name+PicExt);
          Rewrite(f2,1);
          BlockWrite(f2,Dx,2);
          BlockWrite(f2,Dy,2);
          If TiffTom Then
            For Cikl := 0 To Dy-1 Do
              Begin
                Gotoxy(1,WhereY);
                Write(Cikl+1:4,'. linje');
                Xh := 0;
                Repeat
                  BlockRead(f,Short,1);
                  If Short >= 0 Then
                    Begin
                      Blockread(f,Puffer[Xh],Short+1);
                      Inc(Xh,Short+1)
                    End
                  Else
                    Begin
                      Blockread(f,Puffer[Xh],1);
                      FillChar(Puffer[Xh+1],Abs(Short),Puffer[Xh]);
                      Inc(Xh,Abs(Short)+1)
                    End;
                Until Xh >= Xbyte;

                For Cikl2 := 0 To Xbyte-1 Do
                  Puffer[Cikl2] := not(Puffer[Cikl2]);
                BlockWrite(F2,Puffer,Xbyte);
              End
          Else
            For Cikl := 0 To Dy-1 Do
              Begin
                Gotoxy(1,WhereY);
                Write(Cikl+1:4,'. linje');
                Blockread(f,Puffer,Xbyte);
                For Cikl2 := 0 To Xbyte-1 Do
                  Puffer[Cikl2] := not(Puffer[Cikl2]);
                BlockWrite(f2,puffer,Xbyte)
              End;
          Close(f2);
        End;

      Close(f);
    End;
  ConvertTif := ConvOk;
  writeln;

End; { ConvertTif}


Begin

{$IFDEF NORVEG}
  Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
  Writeln('³ TIFF --> PROTEX fil-konvertering versjon 1.0    ³');
  Writeln('³                                                 ³');
  Writeln('³ 32773 compressed format supported               ³');
  Writeln('³ (C) DARVAS SOFTWARE Ltd (C) EkSoft Ltd 1992     ³');
  Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
  writeln;

{$ELSE}

  {$IFDEF ANGOL}
    Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Writeln('³ TIFF --> PROTEX file convert utility ver. 1.0   ³');
    Writeln('³                                                 ³');
    Writeln('³ 32773 compressed format supported               ³');
    Writeln('³ (C) DARVAS SOFTWARE Ltd (C) EkSoft Ltd 1992     ³');
    Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    writeln;

  {$ELSE}

    Writeln('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿');
    Writeln('³ TIFF --> Ekszer  file konverter  1.0            ³');
    Writeln('³                                                 ³');
    Writeln('³ T”m”r¡tetlen, vagy 32773-as t”m”r¡tett form tum ³');
    Writeln('³    (C) kSoft Kft 1991                          ³');
    Writeln('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ');
    writeln;

  {$ENDIF}
{$ENDIF}

  Fnam := '';
  If ParamCount = 0 Then
    Input_String('Oppgi fil  (.TIF) ',Fnam,20)
  Else
    Fnam := ParamStr(1);
  writeln;

{$IFDEF NORVEG}
  If ConvertTif(Fnam) Then
    Writeln('Konvertering var vellykket ')
  Else
    Writeln('Konvertering var mislykket ')
{$ELSE}
  {$IFDEF ANGOL}
    If ConvertTif(Fnam) Then
      Writeln('Succesfull conversion')
    Else
      Writeln('Convert unsuccesfull')
  {$ELSE}
    If ConvertTif(Fnam) Then
      Writeln('A konvert l s sikeres ')
    Else
      Writeln('A konvert l s sikertelen ')
  {$ENDIF}
{$ENDIF}

End.
