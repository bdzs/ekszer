Procedure KeyConv(Var Asc,Scan:Byte);

Var
    Kilep,
    OK,Nyelv_OK,Style_OK : Boolean;
    Nyelvet,Stylet,
    Nyelvre,Stylere      : Char;
    FontValue,
    Poz,Mask,Milyenre    : Byte;
    Ws                   : String;

Const

    MaxNyelv = 7;
    MaxStyle = 6;

{$IFDEF ANGOL}
    NyelvSt  : String[MaxNyelv] = 'SHRNGEP';
    NyelvByte: Array[1..MaxNyelv] Of Byte = ($00,$10,$20,$30,$40,$E0,$F0);

    StyleSt  : String[MaxStyle] = 'NUISBO';
    StyleByte: Array[1..MaxStyle] Of Byte = ($00,$01,$02,$04,$08,$0E);

{$ELSE}
    NyelvSt  : String[MaxNyelv] = 'SMONGEP';
    NyelvByte: Array[1..MaxNyelv] Of Byte = ($00,$10,$20,$30,$40,$E0,$F0);

    StyleSt  : String[MaxStyle] = 'NAIDVO';
    StyleByte: Array[1..MaxStyle] Of Byte = ($00,$01,$02,$04,$08,$0E);
{$ENDIF}

Var P,Kp,Cik : Byte;
Begin

  ExtVolt := False;
  
  If LastFont <> 0 Then
  Begin
    FontNum[EditNum] := LastFont;
    LastFont := 0;
  End;

  If Key_In.Ezt <> '' Then
  Begin

    Ws := Key_In.Ezt;

    P := Pos(Char(Asc),Ws);

    OK       := False;

    While P <> 0 Do
    Begin

      Nyelvet := Upcase(Key_In.EztFont[2*P-1]);
      Stylet  := Upcase(Key_In.EztFont[2*P]);

      Nyelvre := Upcase(Key_In.ErreFont[2*P-1]);
      Stylere := Upcase(Key_In.ErreFont[2*P]);

      FontValue := 10*(Byte(Nyelvet)-48) + (Byte(Stylet)-48);

      If FontValue In [1..MaxFontNum] {'01' - '15'}
      Then
        Begin 
          If FontValue = FontNum[EditNum] Then OK := True;
        End
      Else { Nem Szam }
        Begin
          Nyelv_OK := (Nyelvet = '*');
          Style_OK := (Stylet  = '*');

          If NOT Nyelv_OK Then
          Begin

            Poz := Pos(Nyelvet,NyelvSt);

            If Poz = 0 Then Nyelv_OK := False
            Else
            Begin
              Nyelv_OK :=
                ((FontAttr[FontNum[EditNum]] AND $F0) = NyelvByte[Poz]);

              {
              WriteLn(LST,FontNum[EditNum]:4,FontAttr[FontNum[EditNum]]:4,Nyelv_OK);
              }

              If (Nyelvet = 'P') AND (Nyelv_OK) AND (NOT Style_OK)
              Then
                Style_OK := (FontNames[FontNum[EditNum]][5] = Stylet);

            End;

          End;

          If (NOT Style_OK) AND (Nyelvet <> 'P') Then
          Begin
            Poz := Pos(Stylet,StyleSt);

            If Poz = 0 Then Style_OK := False
            Else
            Begin
              If Poz = 1 Then Mask := $0F
                         Else Mask := StyleByte[Poz];
              Style_OK :=
                ((FontAttr[FontNum[EditNum]] AND Mask) = StyleByte[Poz]);
            End;

          End;

          OK := (Nyelv_OK AND Style_OK);

        End; { If nem szam }

      If OK Then
      Begin

        OK := False;

        FontValue := 10*(Byte(Nyelvre)-48) + (Byte(Stylere)-48);

        If FontValue In [1..MaxFontNum] {'01' - '15'}
        Then
          Begin
            OK := True;
            Cik := FontValue;
          End
        Else { Nem Szam }
          Begin
            Nyelv_OK := (Nyelvre = '*');
            Style_OK := (Stylere = '*');

            If Nyelv_OK AND Style_OK Then
            Begin
              OK  := True;
              Cik := FontNum[EditNum];
            End
            Else
            Begin { If Nem '**'-ra }

              If Nyelv_OK Then
                Milyenre := FontAttr[FontNum[EditNum]] AND $F0
              Else
              Begin
                Poz := Pos(Nyelvre,NyelvSt);

                If Poz > 0 Then
                Begin
                  Milyenre := NyelvByte[Poz];
                  Nyelv_OK := True;
                End;

              End;

              If Style_OK Then
                Milyenre := Milyenre OR (FontAttr[FontNum[EditNum]] AND $0F)
              Else
              Begin
                Poz := Pos(Stylere,StyleSt);

                If Poz > 0 Then
                Begin
                  Milyenre := Milyenre OR StyleByte[Poz];
                  Style_OK := True;
                End
                Else If Nyelvre = 'P' Then
                  If Stylere In ['1'..'3'] Then
                     Style_OK := True;

              End;

              OK := (Nyelv_OK AND Style_OK);

              If OK Then
              Begin
                Cik := 1;

                Repeat

                  Kilep := False;

                  While (Cik < MaxFontNum) AND
                        (Milyenre <> FontAttr[Cik]) Do
                          Inc(Cik);

                  If Nyelvre = 'P'
                  Then
                  Begin
                    If FontAttr[Cik] = Milyenre
                    Then
                      If FontNames[Cik][5] = Stylere
                      Then
                        Kilep := True
                      Else
                      Begin
                        Inc(Cik);
                      End;
                  End
                  Else
                    Kilep := True;

                  If Cik = MaxFontNum Then Kilep := True

                Until Kilep;

                OK := (Milyenre = FontAttr[Cik]);

                If Nyelvre = 'P' Then
                  OK := OK AND (FontNames[Cik][5] = Stylere);

              End;  { If OK }

            End;  { If Nem '**'-ra }

          End; { Nem Szam }

        If OK Then
        Begin
          LastFont := FontNum[EditNum];
          FontNum[EditNum] := Cik;

          Asc := Byte(Key_in.Erre[P]);
          Scan := $74;

        End;

        P := 00;

      End
      Else
      Begin
        Ws[P] := #01;
        P := Pos(Char(Asc),Ws);
      End;
    End;

  End;

  {$IFDEF NORVEG}

  { If (KbFlag AND 4) = 0 Then }
  Begin

    { If NorvegE(FontNum[EditNum]) OR (SamiE(FontNum[EditNum]) ) Then }

    If StandardE(FontNum[EditNum]) Then
    Begin
      If Language = Norveg Then
      Begin
        Kp := 0;
        If NOT ExtendedE(FontNum[EditNum]) Then
        Begin
          If DoltE(FontNum[EditNum])   Then Kp := MaxNorveg;
          If VastagE(FontNum[EditNum]) Then Kp := MaxNorveg*2;
        End;

        P := Pos(Char(Asc),NConv1);
        If P <> 0 Then
        Begin

          LastFont := FontNum[EditNum];
          Cik := 1;
          While NOT((NorvegE(Cik)) AND (ExtendedE(Cik))) AND
                   (Cik <= MaxFontNum) Do Inc(Cik);
          If Cik <= MaxFontNum Then
          Begin
            ExtVolt := True;
            FontNum[EditNum] := Cik;
            Asc := Byte(NConv2[P+Kp]);
            Scan := $74;
          End
          Else Error(20,'NORSKE '+ExtFontNotLoaded);
        End
        Else LastFont := 0;
      End
      Else
      If Language = Sami Then
      Begin
        Kp := 0;
        If NOT ExtendedE(FontNum[EditNum]) Then
        Begin
          If DoltE(FontNum[EditNum])   Then Kp := MaxSami;
          If VastagE(FontNum[EditNum]) Then Kp := MaxSami*2;
        End;
        P := Pos(Char(Asc),SConv1);
        If P <> 0 Then
        Begin
          LastFont := FontNum[EditNum];
          Cik := 1;
          While NOT((SamiE(Cik)) AND (ExtendedE(Cik))) AND
                   (Cik <= MaxFontNum) Do Inc(Cik);
          If Cik <= MaxFontNum Then
          Begin
            ExtVolt := True;
            FontNum[EditNum] := Cik;
            Asc := Byte(SConv2[P+Kp]);
            Scan := $74;
          End
          Else Error(20,'SAMISKE '+ExtFontNotLoaded);
        End
        Else LastFont := 0;
      End;

    End;

  End; { If  (Kbflag And 4) = 0 }

  {$ENDIF}

  {$IFDEF GOROG}

  If GorogE(FontNum[EditNum]) AND (ExtendedE(FontNum[EditNum])) Then
  Begin
    Kp := 0;
    If NOT ExtendedE(LastFontNum) Then
    Begin
      If DoltE(LastFontNum)   Then Kp := MaxGorog;
      If VastagE(LastFontNum) Then Kp := MaxGorog*2;
    End;
    P := Pos(Char(Asc),Copy(GConv1,((MaxGorog-2)*Byte(KettosPont))+1,MaxGorog));
    If P <> 0 Then
    Begin
        If KettosPont Then Inc(P,MaxGorog-2);
        Asc := Byte(GConv2[P+Kp]);
        Scan := $74;
    End
    Else
    Begin
      Beepel(400);
      Asc  := 0;
      Scan := 0;
    End;
  End;

  {$ENDIF}

End;

(*
Procedure CWIdriver(Var Asc,Scan:Byte);
Const

  CWIConvSt: Array[0..1] Of String[29] =

     (';''[]=\`0-:"{}+|~)_!@#$^&*(<>/',
      'Ç†ì£¢ñ°îÅêèßóïòçôö0"+!/=();:-');

  Var P : Integer;
Begin
  P := Pos(Char(Asc),CWIConvSt[1]);
  If P <> 0 Then
    Begin
      Asc := Byte(CWIConvSt[0][P]);
      Scan := $74
    End
End;

*)

(*
Procedure GySdriver(Var Asc,Scan:Byte);
Const

  CWIConvSt: Array[0..1] Of String[29] =

     ('\|`~0)$<#&*(!?',
      '`~\|/?!#$*()0<');

  Var P : Integer;
Begin
  if MagyarE(FontNum[editNum]) then
   begin
     P := Pos(Char(Asc),CWIConvSt[1]);
     If P <> 0 Then
       Begin
         Asc := Byte(CWIConvSt[0][P]);
         Scan := $74
       End
   end;
End;

*)