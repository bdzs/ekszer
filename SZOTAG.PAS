{$S-,I+,F-,V-,B-,N-}

{ $S+}
{ $R+}

{$O+}
{$I MEMORY.CDW}

Unit Szotag;

Interface

Uses WINDOWM;

{ Var Ora,Perc,Mp,SzdMp : Word;
    Ora1,Perc1,Mp1,SzdMp1 : Word; }

Procedure M_UpCase(cime: pointer; hossza:word);
Procedure M_LoCase(cime: pointer; hossza:word);

{$IFDEF ROMAN}
Procedure R_UpCase(cime: pointer; hossza:word);
Procedure R_LoCase(cime: pointer; hossza:word);
{$ENDIF}

Function Szotagol(ezt: string): byte;

Implementation

{$IFDEF PROBA}
Uses printer;
{$ENDIF}


Var  Kilep : Boolean;
Const HalozatProba = 15;

{$L upcase.obj}
{$IFDEF ROMAN}
{$L upcaser.obj}
{$ENDIF}

Procedure M_UpCase; external;
Procedure M_LoCase; external;

{$IFDEF ROMAN}
Procedure R_UpCase; external;
Procedure R_LoCase; external;
{$ENDIF}

Function Szotagol;

var szo: string;
    pat: string;
    hossz: byte;
    Cik  : Word;
    IORES: Integer;
    Poz,BPoz  : Longint;
    LeadingSpaces,
    KotokSzama : Byte;
    Kotok : Array[1..16] Of Byte;
    Ws    : String[80];
    SzBetu: Boolean;

    Proba      : Integer; { L.A }
    IoR        : Integer;

    SzotarVerzio: Word;
    BetukSzama : Byte;

    T          : Byte;

    NezoSzo,
    elrakszo      : String;
    kotjelpos     : Byte;
    kotjelekszama : Byte;
    szotagok      : Byte;
    osszotagok    : Byte;
    eltolas       : Byte;
    eddigszotag   : Byte;

    osszkotojel   : KotoJelType;

{-----------------------------------------------}
Procedure UpCstr(var s: string);

Begin
   M_UpCase(@s,Byte(S[0]));
End;

Procedure LoCstr(var s: string);

Begin
   M_LoCase(@s,Byte(S[0]));
End;
{$IFDEF ROMAN}
Procedure R_UpCstr(var s: string);

Begin
   R_UpCase(@s,Byte(S[0]));
End;

Procedure R_LoCstr(var s: string);

Begin
   R_LoCase(@s,Byte(S[0]));
End;

{$ENDIF}
Function Voltmaganhangzo(eddig: word): boolean;

var t:byte;

begin
  Voltmaganhangzo := false;
  for t:= 1 to eddig do
   if pat[t] = 'V' then Voltmaganhangzo := true;
end;



Function make_pattern(Szo: String): byte;

var t,i : word;
    elozocik_hossz : word;
    bmut: byte;
    szdb: byte;
    ezzel: string[5];
    cikis_hossz: byte;


Function Elv: boolean;      {elvalasztast bejegyez, true, ha tovabb nem mehet}

Begin
   i := bmut;
   repeat
     inc(i);
   until (pat[i] = 'V')  or (i > hossz);
   if i <= hossz then
    begin
     inc(szdb);
     kotojel[szdb] := bmut;
     inc(bmut);
     Elv := (szdb = 16);
    end;
End;


Begin

  bmut := 0;
  szdb := 0;
  make_pattern := 0;

  (***)
  fillchar(pat,sizeof(Pat),'*');
                             {Consonant-Vocal-* egyeb}
  pat[0] := char(hossz);
  for t:= 1 to hossz do
   begin
     if szo[t] <> '*' then  {nem betu volt}
       Begin
         i := 0;
         repeat
          inc(i);
         until (i = 15) or (szo[t] = maganhangzok[i]);

         {$IFDEF NORVEG}
         If i = 15 Then
           If ((NorvegE(Byte(GlobalSzoAtt[T]))) AND
               (Szo[T] In ['A'..'I'])) OR
              ((SamiE(Byte(GlobalSzoAtt[T]))) AND
               (Szo[T] In ['A'..'C','S'..'U']))
           Then I := 1;
         {$ENDIF}

         if i < 15 then pat[t] := 'V'
                   else pat[t] := 'C';
       End
     { else pat[t] := '*'; }
   end;

  i := 0;                                 {igekotoket megnez}
  repeat
   inc(i);
   szo[0] := igekotok[i][0];
  until (i = igekotok_szama)  or (szo = igekotok[i]) ;
  szo[0] := chr(hossz);

  if (i < igekotok_szama) and (copy(szo,1,4) <> 'MEGY') then

    Begin
      bmut := byte(igekotok[i][0]);
      if bmut < hossz-1 then     {@@@}
       begin
        i := 0;
        repeat
          inc(i);
          ezzel := copy(szo,bmut+1,byte(cikisek[i][0]));
        until (i = cikisek_szama) or (cikisek[i] = ezzel);
        if i = cikisek_szama then    {nincs meg}
          begin
           if not ((pat[bmut+1] = 'C') and (pat[bmut+2] = 'C')) then
                                                   {pl. lenni}
           if elv then exit;
          end
        else                            {igekoto utan cikis van}
          begin
            elozocik_hossz := length(cikisek[i]);
            i := 0;
            repeat
              inc(i);
              ezzel := copy(szo,bmut,byte(cikisek[i][0]));
            until (i = cikisek_szama) or (cikisek[i] = ezzel);   {cikis resze?}
            if i < cikisek_szama then inc(bmut,length(cikisek[i])-1)
            else
               begin
                 if ((pat[bmut+elozocik_hossz + 1] = 'C') and
                     (pat[bmut+elozocik_hossz + 2] = 'V')) then   {lesz-bikus}
                    begin
                     inc(bmut,elozocik_hossz);
                     if elv then exit;
                    end
                 else dec(bmut);
               end;
          end;
      end;
    End;

  if bmut = 0 then inc(bmut);                         {megy elore}

  while bmut < hossz-2 do
   begin
     inc(bmut);
     if pat[bmut] = '*' then exit;

     if (pat[bmut]='V') and (pat[bmut+1]='V') then
      begin
       inc(szdb);
       (*
       if bmut < hossz-2 then                {pl. nia-gara}
        begin
          kotojel[szdb] := bmut+1;
          inc(bmut,2);
        end
       else
       *)
        Begin
          kotojel[szdb] := bmut;              {pl. miniszteri-um}
          inc(bmut);                          {inc(bmut,2) volt }
          if szdb = 16 then exit;
        End;
      end;

     if (pat[bmut]='V') and (pat[bmut+1]='C') and (pat[bmut+2]='V')
        and ((hossz - 1) > bmut) then if elv then exit;
                                                  {pl. ci-ca}

     if (pat[bmut]='V') and (pat[bmut+1]='C') and (pat[bmut+1]='C') then
                                                    {pl. pecse-nye}
                                                    {pl. be-sz‚l}
      Begin
        i := 0;
        repeat
          inc(i);
        until (i = ypsilonosok_szama) or (ypsilonosok[i] = copy(szo,bmut+1,byte(cikisek[i][0])));
        if (i < ypsilonosok_szama) and                       {megvan}
           (bmut+length(ypsilonosok[i]) < hossz) and         {nem kor-ma-ny}
           (pat[bmut+1+length(ypsilonosok[i])] = 'V') then   {mgh koveti}
         Begin
          if length(ypsilonosok[i]) = 2 then    {nny -vel nem kezdodhet}
           begin
            inc(szdb);
            kotojel[szdb] := bmut;
            if szdb = 16 then exit;
           end;
          inc(bmut,length(ypsilonosok[i]));
         End;
      End;

     cikis_hossz := 0;
     if (pat[bmut]='C') and (pat[bmut+1]='C') then    {pl. h r-man}
      Begin
        i := 0;
        repeat                                        {pl. taccsol }
          inc(i);
        until (i = cikisek_szama) or (cikisek[i] = copy(szo,bmut,byte(cikisek[i][0])));
        if i = cikisek_szama then    {nincs meg}      {pl. tarcsany }
         Begin
          if pat[bmut+2]='C' then
            begin
             inc(bmut);
             i := 0;
             repeat
               inc(i);
             until (i = cikisek_szama) or (cikisek[i] = copy(szo,bmut,byte(cikisek[i][0])));
             if i < cikisek_szama then
              begin
                dec(bmut);
                cikis_hossz := byte(cikisek[i][0])
              end;
            end;
          if (bmut < hossz-cikis_hossz) and (cikis_hossz <> 3) and
             (bmut < hossz-1) and Voltmaganhangzo(bmut) then
               begin
                if elv then Exit;
                            {Begin
                              WriteLn(LST,'Cikisek_Szama = ',Cikisek_Szama);
                              WriteLn(LST,'Ypsilonosok_szama = ',Ypsilonosok_szama);
                              WriteLn(LST,'Elozocik_hossz = ',Elozocik_hossz);
                              WriteLn(LST,'Cikis_hossz = ',Cikis_hossz);
                              exit;
                            End;}
                dec(bmut);                    {pl. narancs, naranccsal }
               end;
          inc(bmut);
         End;
      End;
   end;

   (****)
  KotokSzama   := szdb;
  make_pattern := szdb;

End;


{$IFDEF ROMAN}
Function make_patternR(Szo: String): byte;

var t,i : word;
    elozocik_hossz : word;
    bmut: byte;
    szdb: byte;
    ezzel: string[5];
    cikis_hossz: byte;


Function Elv: boolean;      {elvalasztast bejegyez, true, ha tovabb nem mehet}

Begin
   i := bmut;
   repeat
     inc(i);
   until (pat[i] = 'V')  or (i > hossz);
   if i <= hossz then
    begin
     inc(szdb);
     kotojel[szdb] := bmut;
     inc(bmut);
     Elv := (szdb = 16);
    end;
End;


Begin

  bmut := 0;
  szdb := 0;
  make_patternR := 0;

  (***)
  fillchar(pat,sizeof(Pat),'*');
                             {Consonant-Vocal-* egyeb}
  pat[0] := char(hossz);
  for t:= 1 to hossz do
   begin
     if szo[t] <> '*' then  {nem betu volt}
       Begin
         i := 0;
         repeat
          inc(i);
         until (i = 9) or (szo[t] = maganhangzokR[i]);


         if i < 9  then pat[t] := 'V'
                   else pat[t] := 'C';
         if (szo[t] = 'I') and (pat[t-1] = 'V') then pat[t] := 'C'; {hai-te}
         if (szo[t] = 'A') and (szo[t-1] = 'O') then pat[t] := 'C'; {floa-re}
         if (szo[t-1] = 'I') and (pat[t] = 'V') then pat[t-1] := 'C'; {ploa-ie}
       End
     { else pat[t] := '*'; }
   end;

  i := 0;                                 {igekotoket megnez}
  repeat
   inc(i);
   szo[0] := igekotokR[i][0];
  until (i = igekotok_szamaR)  or (szo = igekotokR[i]) ;
  szo[0] := chr(hossz);

  if (i < igekotok_szamaR) and (copy(szo,1,4) <> 'MEGY') then

    Begin
      bmut := byte(igekotokR[i][0]);
      if bmut < hossz-1 then     {@@@}
       begin
        i := 0;
        repeat
          inc(i);
          ezzel := copy(szo,bmut+1,byte(cikisekR[i][0]));
        until (i = cikisek_szamaR) or (cikisekR[i] = ezzel);
        if i = cikisek_szamaR then    {nincs meg}
          begin
           if not ((pat[bmut+1] = 'C') and (pat[bmut+2] = 'C')) then
                                                   {pl. lenni}
           if elv then exit;
          end
        else                            {igekoto utan cikis van}
          begin
            elozocik_hossz := length(cikisekR[i]);
            i := 0;
            repeat
              inc(i);
              ezzel := copy(szo,bmut,byte(cikisekR[i][0]));
            until (i = cikisek_szamaR) or (cikisekR[i] = ezzel);   {cikis resze?}
            if i < cikisek_szamaR then inc(bmut,length(cikisekR[i])-1)
            else
               begin
                 if ((pat[bmut+elozocik_hossz + 1] = 'C') and
                     (pat[bmut+elozocik_hossz + 2] = 'V')) then   {lesz-bikus}
                    begin
                     inc(bmut,elozocik_hossz);
                     if elv then exit;
                    end
                 else dec(bmut);
               end;
          end;
      end;
    End;

  if bmut = 0 then inc(bmut);                         {megy elore}

  while bmut < hossz-2 do
   begin
     inc(bmut);
     if pat[bmut] = '*' then exit;

     if (pat[bmut]='V') and (pat[bmut+1]='V') then
      begin
       inc(szdb);
       (*
       if bmut < hossz-2 then                {pl. nia-gara}
        begin
          kotojel[szdb] := bmut+1;
          inc(bmut,2);
        end
       else
       *)
        Begin
          kotojel[szdb] := bmut;              {pl. miniszteri-um}
          inc(bmut);                          {inc(bmut,2) volt }
          if szdb = 16 then exit;
        End;
      end;

     if (pat[bmut]='V') and (pat[bmut+1]='C') and (pat[bmut+2]='V')
        and ((hossz - 1) > bmut) then if elv then exit;
                                                  {pl. ci-ca}

     if (pat[bmut]='V') and (pat[bmut+1]='C') and (pat[bmut+1]='C') then
                                                    {pl. pecse-nye}
                                                    {pl. be-sz‚l}
      Begin
        i := 0;
        repeat
          inc(i);
        until (i = ypsilonosok_szamaR) or (ypsilonosokR[i] = copy(szo,bmut+1,byte(cikisek[i][0])));
        if (i < ypsilonosok_szamaR) and                       {megvan}
           (bmut+length(ypsilonosokR[i]) < hossz) and         {nem kor-ma-ny}
           (pat[bmut+1+length(ypsilonosokR[i])] = 'V') then   {mgh koveti}
         Begin
          if length(ypsilonosokR[i]) = 2 then    {nny -vel nem kezdodhet}
           begin
            inc(szdb);
            kotojel[szdb] := bmut;
            if szdb = 16 then exit;
           end;
          inc(bmut,length(ypsilonosokR[i]));
         End;
      End;

     cikis_hossz := 0;
     if (pat[bmut]='C') and (pat[bmut+1]='C') then    {pl. h r-man}
      Begin
        i := 0;
        repeat                                        {pl. taccsol }
          inc(i);
        until (i = cikisek_szamaR) or (cikisekR[i] = copy(szo,bmut,byte(cikisekR[i][0])));
        if i = cikisek_szamaR then    {nincs meg}      {pl. tarcsany }
         Begin
          if pat[bmut+2]='C' then
            begin
             inc(bmut);
             i := 0;
             repeat
               inc(i);
             until (i = cikisek_szamaR) or (cikisekR[i] = copy(szo,bmut,byte(cikisekR[i][0])));
             if i < cikisek_szamaR then
              begin
                dec(bmut);
                cikis_hossz := byte(cikisekR[i][0])
              end;
            end;
          if (bmut < hossz-cikis_hossz) and (cikis_hossz <> 3) and
             (bmut < hossz-1) and Voltmaganhangzo(bmut) then
               begin
                if elv then Exit;
                            {Begin
                              WriteLn(LST,'Cikisek_Szama = ',Cikisek_Szama);
                              WriteLn(LST,'Ypsilonosok_szama = ',Ypsilonosok_szama);
                              WriteLn(LST,'Elozocik_hossz = ',Elozocik_hossz);
                              WriteLn(LST,'Cikis_hossz = ',Cikis_hossz);
                              exit;
                            End;}
                dec(bmut);                    {pl. narancs, naranccsal }
               end;
          inc(bmut);
         End;
      End;
   end;

   (****)
  KotokSzama   := szdb;
  make_patternR:= szdb;

End;

{$ENDIF}       {ROMAN ELVALSZTAS}

Begin
  szo      := ezt;

  LeadingSpaces := 0;

  While (Szo[Length(Szo)] = ' ') AND (Szo <> ' ') Do Dec(Byte(Szo[0]));
  If Szo <> ' ' Then
  While Szo[1] = ' ' Do
  Begin
    Delete(Szo,1,1);
    Inc(LeadingSpaces);
  End;

  KivetelVolt := False;

  If VanSzotarFile AND (Length(Szo) >= 2) Then
  Begin

    IORES := 0;

    {$IFDEF ROMAN}
    If Kell_Roman Then R_LoCstr(szo)
                  Else LoCstr(szo);
    {$ELSE}
    LoCstr(szo);
    {$ENDIF}

    If (Szo[1] = 's') AND (Szo[2] = 'z') Then
    Begin
      SzBetu := True;
      Delete(Szo,1,1);
      Szo[1] := '$';
    End
    Else
      SzBetu := False;

    { WriteLn(LST,Szo);
      WriteLn(LST,'----------');
      WriteLn(LST); }


    Assign(Szotar,SzoFile);
    Proba := HalozatProba;
    Repeat    { L.A.}
      {$i-} Reset(Szotar,1); {$i+}
      IoR := IoResult;
      Dec(Proba)
    Until (IoR = 0) Or (Proba=0);

    Inc(IORES,IOR);

    If IoRes = 0 Then If FileSize(Szotar) = 0 Then Inc(IoRes);

    { Innen kellene }
    If Iores = 0 Then
    Begin {L.A.}

    BetukSzama := 35;
    BlockRead(Szotar,SzotarVerzio,2);
    If SzotarVerzio = $2222 Then Inc(BetukSzama);

    Cik := 1;
    While (Szo[1] <> MABC[Cik]) AND (Cik <= BetukSzama) Do Inc(Cik);
    Poz := BetukSzama*(Cik-1);

    If Cik <= BetukSzama Then
    Begin
      Cik := 1;
      While (Szo[2] <> MABC[Cik]) AND (Cik <= BetukSzama) Do Inc(Cik);
    End;

    If Cik <= BetukSzama Then
    Begin
      Inc(Poz,Cik-1);

      Poz := Poz * 4;

      BPoz := Poz;

      Seek(Szotar,Poz);
      BlockRead(Szotar,Poz,4);

      If (SzotarVerzio = $2222) And (BPoz = 0) Then Poz := 0;

    End
    Else Poz := 0;

    If Poz > 0 Then
    Begin
      Seek(Szotar,Poz);
      BlockRead(Szotar,Cik,2);

      Ws := '';

      { GetTime(Ora,Perc,Mp,SzdMp); }

      Kilep := False;

      { WriteLn(LST,'Cik = ',Cik); }

      While (Cik > 0) AND NOT(Kilep)  Do
      Begin
        BlockRead(Szotar,KotokSzama,1);
        BlockRead(Szotar,Kotok,KotokSzama);
        BlockRead(Szotar,Ws[0],1);
        BlockRead(Szotar,Ws[1],Byte(Ws[0]));
        Dec(Cik);
        If Byte(Ws[0]) > Byte(Szo[0]) Then Ws[0] := Szo[0];
        If (Ws[3] = Szo[3]) AND (Ws = Szo) Then Kilep := True;
        { WriteLn(LST,Cik:3,'.  ',Szo,' <-> ',Ws); }
      End;

      { WriteLn(LST); }

      If Ws = Szo Then
      Begin

        If KotokSzama <> 0 Then
        Begin
          While (KotokSzama > 0) AND (Kotok[KotokSzama] >= Length(Ws)) Do
            Dec(KotokSzama);
          If KotokSzama > 0 Then
          Begin
            If SzBetu Then
            Begin
              For Cik := 1 To KotokSzama Do Inc(Kotok[Cik]);
              Szo[1] := 'z';
              Insert('s',Szo,1);
            End;
            If Kotok[KotokSzama] = Length(Szo)-1 Then Dec(KotokSzama);
            If KotokSzama > 0 Then Move(Kotok,KotoJel,KotokSzama);
          End;
        End;

        { GetTime(Ora1,Perc1,Mp1,SzdMp1); }
        { WriteLn(LST,Ora,':',Perc,':',Mp,'.',SzdMp);
          WriteLn(LST,Ora1,':',Perc1,':',Mp1,'.',SzdMp1);
          WriteLn(LST,Szo);
          WriteLn(LST); }

        Szotagol := KotokSzama;
        KivetelVolt := True;
      End;

    End; { Ha van ilyen betukkel kezdodo }

    {$i-} Close(Szotar); {$i+}

    Inc(IORES,IOResult);

    {  Idaig kellene }

    End  {L.A.}


  End;  { VanSzotarFile }

  If NOT KivetelVolt Then
  Begin
    If Szo[1] = '$' Then
    Begin
      Szo[1] := 'Z';
      Insert('S',Szo,1);
    End;
    {$IFDEF ROMAN}
    If Kell_Roman Then R_UpCstr(szo)
                  Else UpCstr(szo);
    {$ELSE}
    UpCstr(szo);
    {$ENDIF}

    { Szotagol := Make_Pattern; }

    elrakszo      := szo;
    kotjelpos     := 0;
    kotjelekszama := 0;
    szotagok      := 0;
    osszotagok    := 0;
    eltolas       := 0;
    eddigszotag   := 0;

    if szo <> '' then
     begin
       repeat
        begin
         kotjelpos := pos('-',szo);
         if kotjelpos = 0 then
          nezoszo := szo
         else
          begin
           nezoszo   := copy(szo,1,kotjelpos-1);
           delete(szo,1,kotjelpos);
          end;

         hossz    := byte(nezoszo[0]);
         {$IFDEF ROMAN}
         If Kell_Roman Then
           szotagok := Make_PatternR(nezoszo)
         Else
           szotagok := Make_Pattern(nezoszo);
         {$ELSE}
         szotagok := Make_Pattern(nezoszo);
         {$ENDIF}
         if szotagok > 0 then
          begin
           inc(osszotagok, szotagok);
           for t:= 1 to szotagok do
            osszkotojel[t+eddigszotag] :=
             kotojel[t]+eltolas+kotjelekszama;
          end;
         inc(kotjelekszama);
         inc(eltolas,length(nezoszo));
         inc(eddigszotag,szotagok);
        end;
       until kotjelpos = 0;
     end;

    szo := elrakszo;
    kotojel   := osszkotojel;
    szotagok  := osszotagok;

    Szotagol := Szotagok;
  End;

  If (KotokSzama > 0) AND (LeadingSpaces > 0) Then
    For Cik := 1 To KotokSzama Do Inc(KotoJel[Cik],LeadingSpaces);

End;

{ Szotagok := Szotagol(Szo);

  =>  Szotagok              = k”t“jelek sz ma,
      Kotojel[1..Szotagok]  = a k”t“jelek poz¡ci¢i  }


End.  {  Unit Szotag }
