Unit Nyom6;      { CP 850 ekezetes betuk es chr239-cel
                 kirajzolt kettos ekezet
                 ASCII betuk a nyomtato sajatjai }

{$O+}

Interface

Uses Nyomtat,Dos,Crt,Windowm,MenuErr,
     Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

Procedure BubbleJet;

Implementation

Procedure BubbleJet;

type  st2 = string[2];
      st3 = string[3];
      st4 = string[4];
      st8 = string[8];

const
      vesszo      = 1;
      vesszok     = 2;
      magasvesszo = 3;
      magasvesszok= 4;

const

 Ekezetes = 29;

 Dummy : Byte = Ekezetes; {String length byte}

 m_atvalt : array [0..1,1..Ekezetes] of char =

 (('!',  '@',  '#',  '$',  '^',  '&',  '*',  '(',  ')',  '_',  '0',  '-',  '+',  '=',

   '{',  '[',  '}',  ']',  ':',  ';',  '"',  #$27, '~',  '`',  '|',  '\',  '<',  '>',  '/'),

  ('0',  '"',  '+',  '!',  '/',  '=',  '(',  ')',  #168, #174, #167, #173, #166, #165,

   #170, #169, #172, #171, #163, #162, #161, #160, #177, #164, #176, #175, ';',  ':',  '-'));


  font_8 : string[14] = '_+|uiojknm,&aA';
  ibm_kar: string[14] = 'ƒ≈≥⁄¬ø√¥¿¡Ÿ'#21'Ñé';

  nemet1 : string[27] = 'yYzZ`~@#^&*()-_=+\|[{]};:''"<>/?';
  nemet2 : string[27] = 'zZyY#^"'#21'&/()=·?''`<>Åö+*îôÑé;:-_';


Var  Sst : String[29] absolute Dummy;
     i,j,k         : integer;
     c             : char;
     lap_vege      : boolean;

    betuk_szama    : integer;
    dolt, alahuz, vastag : boolean;

    kilepett    : boolean; {nyomtatas kozben ESC, vagy rossz printer}
    nyomas_vege : boolean;

    volt_lapdob : boolean;

    felsorok    : word;
    Kell,EzKell, Volt, KellMeg : word;


    EkezetSor  : array[0..MaxMaxChars] of byte;
    AsciiSor   : array[0..MaxMaxChars] of byte;
    AttribSor  : array[0..MaxMaxChars] of byte;

    VoltEkezetes : boolean;

    LapVeg : boolean;

    Tol    : word;

    {$IFDEF LICENC}
    EmbSor : integer;
         f : file of byte;
      cikl : word;
       byt : byte;
    {$ENDIF}


{--------------------------------------}
procedure bill_urit;

var c : char;
begin
   while keypressed do
    begin
       c:= readkey;
       if c= #0 then c := readkey;
    end;
end;
{---------------------------------}

procedure lprint (c: byte);       {kilepett lesz, ha nem megy ki!!!}
                                  {es [A]bort }
var
           cb : char;
       pr_ok  : boolean;
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

        bill_urit;
        repeat
          cb := Upcase(readkey);
          if cb = #0 then cb := readkey;
        until cb in [#27,UjraChar,KilepChar];
        Bool := remove_window;
        if cb in [KilepChar,#27] then
         begin
           kilepett := true;
           ESC      := true;
         end;
      end;

  until (pr_ok or kilepett);
end;

{---------------------------}

function Volt_Esc : boolean;

var  c : char;
     b : byte;

begin
      Volt_ESC := false;

      if keypressed then
         begin
               c := readkey; if c = #0 then c := readkey;   { kiolvassa }
               BOOL := CREATE_WINDOW(15,7,65,11,pr_mess1,CA[DispMode,1],Ca[DispMode,4]);
               GotoXY(5,2);
               write(pr_mess2);

               Speak2(100,200);

               {bill-re var}
               c := readkey; if c = #0 then c := readkey; {kiolvassa}
               if c = #27 then
                  begin
                    Volt_ESC := true;
                    kilepett := true;
                  end;
               Bool := Remove_Window;
        end;
end;

{--------------------------------------------------------------------}

procedure cmd (parancs: st16);

var i: byte;

begin

  for i:= 1 to length(parancs) do
    begin
     lprint(byte(parancs[i]));
     if kilepett then exit;
    end;
end;
{--------------------------------}
Procedure BalMargo;
Var hur : Integer;
Begin
  lprint(13);
  for hur := 1 to PrintMargin do
    begin
      lprint(32);
      if volt_esc or kilepett then exit;
    end;
End;

{---------------------------}
procedure vastag_be ;

begin
  cmd(#27'E'#27'G');
  vastag := true;
end;

procedure vastag_ki;

begin
  cmd(#27'F'#27'H');
  vastag := false;
end;

procedure alahuz_be;

begin
   CMD(#27'-'#1);
   alahuz := true;
end;

procedure alahuz_ki;

begin
  CMD(#27'-'#0);
  alahuz := false;
end;

procedure Dolt_be;

begin
end;

procedure Dolt_ki;

begin
end;

Procedure  RestoreNoAttrib;          {vastag stb. kikapcsol}

Begin
  dolt_ki;
  alahuz_ki;
  vastag_ki;
End;

{--------------------------------------------------------------------}
Procedure Cr_Lf15_180;

Begin
   Lprint(13);               if kilepett then exit;
   cmd(#27'J'#15);
End;

Procedure Cr_Lf5_180;

Begin
   Lprint(13);               if kilepett then exit;
   cmd(#27'J'#5);
End;
Procedure Cr_Lf10_180;

Begin
   Lprint(13);               if kilepett then exit;
   cmd(#27'J'#10);
End;

Procedure Vissza_kicsit_jobbra;

var t : byte;

begin
  lprint(13);
  cmd(#27'K'#2#0#0#0);
end;

{---------------------------------------------------------------------}

Procedure EkezetPrint(tol: integer);

Var kik,att,hur : byte;

Begin
    cr_lf10_180;

{magasekezet}
    if kilepett then exit;
    if alahuz then alahuz_ki;

    if Tol = 0 then balmargo;
    if volt_esc or kilepett then exit;
    for kik:= Tol to betuk_szama-1 do
     begin
       att := AttribSor[kik];

       if VastagE(att) then
        begin
          if not vastag then vastag_be
        end
       else
        begin
          if vastag then vastag_ki;
        end;

       if DoltE(att) then
        begin
          if not Dolt then Dolt_be
        end
       else
        begin
          if Dolt then Dolt_ki;
        end;

       if (EkezetSor[kik] = magasvesszo) or (EkezetSor[kik] = magasvesszok)
         then lprint(239)
         else lprint(32);
       if  volt_esc or kilepett then exit;
     end;

    vissza_kicsit_jobbra;
{magasvesszok}

    if kilepett then exit;
    if alahuz then alahuz_ki;

    if Tol = 0 then
      for hur := 1 to PrintMargin do
        begin
          lprint(32);
          if volt_esc or kilepett then exit;
        end;
    for kik:= Tol to betuk_szama-1 do
     begin
       att := AttribSor[kik];

       if VastagE(att) then
        begin
          if not vastag then vastag_be
        end
       else
        begin
          if vastag then vastag_ki;
        end;

       if DoltE(att) then
        begin
          if not Dolt then Dolt_be
        end
       else
        begin
          if Dolt then Dolt_ki;
        end;

       if (EkezetSor[kik] = magasvesszok)
         then lprint(239)
         else lprint(32);
       if  volt_esc or kilepett then exit;
     end;

     cr_lf5_180;

{vesszo}
    if kilepett then exit;
    if alahuz then alahuz_ki;
    if Tol = 0 then balmargo;
    if volt_esc or kilepett then exit;
    for kik:= Tol to betuk_szama-1 do
     begin
       att := AttribSor[kik];

       if VastagE(att) then
        begin
          if not vastag then vastag_be
        end
       else
        begin
          if vastag then vastag_ki;
        end;

        if DoltE(att) then
        begin
          if not Dolt then Dolt_be
        end
       else
        begin
          if Dolt then Dolt_ki;
        end;

       if (EkezetSor[kik] = vesszo) or (EkezetSor[kik] = vesszok)
         then lprint(239)
         else lprint(32);
       if  volt_esc or kilepett then exit;
     end;

    vissza_kicsit_jobbra;

{vesszok}
    if kilepett then exit;
    if alahuz then alahuz_ki;

      for hur := 1 to PrintMargin do
        begin
          lprint(32);
          if volt_esc or kilepett then exit;
        end;

    for kik:= Tol to betuk_szama-1 do
     begin
       att := AttribSor[kik];

       if VastagE(att) then
        begin
          if not vastag then vastag_be
        end
       else
        begin
          if vastag then vastag_ki;
        end;

       if DoltE(att) then
        begin
          if not Dolt then Dolt_be
        end
       else
        begin
          if Dolt then Dolt_ki;
        end;

       if (EkezetSor[kik] = vesszok)
         then lprint(239)
         else lprint(32);
       if  volt_esc or kilepett then exit;
     end;

    if kilepett then exit;

End;

{---------------------------------------------------------------------}
procedure AsciiPrint(Tol : integer);

var kik   : word;
    att,kar : byte;

Begin
  if Tol = 0 then balmargo;
  if volt_esc or kilepett then exit;
  if kilepett then exit;
  for kik := Tol to betuk_szama-1 do
    Begin
      att := AttribSor[kik];
      kar := AsciiSor [kik];

      AlahuzottSpaceCsere(Char(Kar),Att);

      if AlahuzottE(att) then
       begin
         if not alahuz then alahuz_be
       end
      else
       begin
         if alahuz then alahuz_ki;
       end;

      if VastagE(att) then
       begin
         if not vastag then vastag_be
       end
      else
       begin
         if vastag then vastag_ki;
       end;

      if DoltE(att) then
       begin
         if not Dolt then Dolt_be
       end
      else
       begin
         if Dolt then Dolt_ki;
       end;

      if kar = 32 then
         if Not(AlahuzottE(Att)) And alahuz then alahuz_ki;

      lprint(kar);
      if  volt_esc or kilepett then exit;

    End;


End;

Procedure MakeSorok(Tol: integer);

Var kik : word;
    kar : char;
    att,t : byte;

Begin
  for kik:= Tol to betuk_szama-1 do
   begin
     EkezetSor[kik] := 32;

     kar := (image[LastLine]^.chars[C80+kik]);
     if (kar < ' ') or (kar > #127) then kar := ' ';
     att :=  image[LastLine]^.attribs[kik] and $0F;
     if att < 1 then att := 1;

     if (kar ='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
          begin
            kar := ' ';   { kemeny osszekoto space !!!}
            att := 1;
          end;
     AttribSor[kik] :=  att;

     If not AngolE(att) then
       begin
         If NemetE(att) then
            Begin
              T := Pos(kar,Nemet1);     {}
              If T > 0 Then
               Begin
                 Kar := Nemet2[t];
               End
            End
         Else
         if MagyarE(att) then
           Begin
             T := Pos(kar,Sst);
             If T > 0 Then Kar := m_atvalt[1,t];
           End
         else
         If GrafE(att) and (FontNames[att] = 'SPEC1') then
         Begin
           T := Pos(kar,Font_8);     {dobozrajzolo,&,ae}
           If T >0 Then
            Begin
              Kar := Ibm_kar[t];
            End
         End
         else if kar <> ' ' then kar := ppar.pr_joker;       {nem irhato}
       end;

     If kar > #159 then                     {magyar ekezetes}

       begin
         VoltEkezetes := true;
         case byte(kar) of
           160 :  begin                     {†}
                   kar := #160;
                  end;
           161 :  begin                     {è}
                   kar := 'A';
                   EkezetSor[kik] := magasvesszo;
                   VoltEkezetes := true;
                  end;
           162 :  begin                     {Ç}
                   kar := #130;
                  end;
           163 :  begin                     {ê}
                   kar := 'E';
                   EkezetSor[kik] := magasvesszo;
                   VoltEkezetes := true;
                  end;
           164 :  begin                     {°}
                   kar := #161;
                  end;
           165 :  begin                     {¢}
                   kar := #162;
                  end;
           166 :  begin                     {ï}
                   kar := 'O';
                   EkezetSor[kik] := magasvesszo;
                   VoltEkezetes := true;
                  end;
           167 :  begin                     {î}
                   kar := #148;
                  end;
           168 :  begin                     {ô}
                   kar := #153;
                  end;
           169 :  begin                     {ì}
                   kar := 'o';
                   EkezetSor[kik] := vesszok;
                   VoltEkezetes := true;
                  end;
           170 :  begin                     {ß}
                   kar := 'O';
                   EkezetSor[kik] := magasvesszok;
                   VoltEkezetes := true;
                  end;
           171 :  begin                     {£}
                   kar := #163;
                  end;
           172 :  begin                     {ó}
                   kar := 'U';
                   EkezetSor[kik] := magasvesszo;
                   VoltEkezetes := true;
                  end;
           173 :  begin                     {Å}
                   kar := #129;
                  end;
           174 :  begin                     {ö}
                   kar := #154;
                  end;
           175 :  begin                     {ñ}
                   kar := 'u';
                   EkezetSor[kik] := vesszok;
                   VoltEkezetes := true;
                  end;
           176 :  begin                     {ò}
                   kar := 'U';
                   EkezetSor[kik] := magasvesszok;
                   VoltEkezetes := true;
                  end;
           177 :  begin                     {ç}
                   kar := 'I';
                   EkezetSor[kik] := magasvesszo;
                  end;
         end;                  {case}
       end;

     AsciiSor[kik] := byte(kar);

   end;
End;

{---------------------------------------------------------------------}

Procedure EkezetnyitLe;
Begin
   cr_lf15_180;
End;

Procedure AsciitnyitLe;
Begin
End;

Procedure CR_LF;

Begin
 cmd(#13#10)
End;
{-------------------------------------------------------------------}
procedure egy_sort_nyom(tol : integer);   {37. image sorban van}


var kik          : integer;    {kiirando karakter sorszama}
    van_valami   : boolean;
    ch           : char;

Begin
  betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }
  if betuk_szama + PrintMargin > C80 then
     betuk_szama := C80 - PrintMargin;     {max. 77 szeles }

  Van_Valami   := (betuk_szama <> 0);

  VoltEkezetes := false;
  If van_valami
  Then
    Begin
      MakeSorok(Tol);
      If VoltEkezetes then EkezetPrint(Tol)
        else EkezetnyitLe;
      if  volt_esc or kilepett then exit;
      AsciiPrint(Tol);
      if  volt_esc or kilepett then exit;
      AsciitnyitLe;
    End
  Else
    Begin
      EkezetnyitLe;                 {a ketto egyutt egy fel sor}
      if volt_esc or kilepett then exit;
      AsciitnyitLe;
    End

End;


Procedure IniPrinter;

Begin
   cmd(ppar.pr_ini);
End;


{=====================  MAIN ====================================}
{procedure BubbleJet}

Begin
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}
  kilepett    := false;

  iniprinter;
  If kilepett then exit;

  lap_vege := false;        {nem a lap alja}
  volt_lapdob := false;

  alahuz      := false;
  vastag      := false;
  dolt        := false;
  voltEkezetes:= false;

  BOOL := CREATE_WINDOW(40,6,75,10,pr_mess8,CA[DispMode,1],Ca[DispMode,2]);
  GotoXY(3,2);
  writeln (pr_mess9);

  {-------------------- inicializalas vege: main loop ------------}
  felsorok := 0;
  tol      := 0;
  {$IFDEF LICENC}
  EmbSor   := 0;
  {$ENDIF}

  while  Van_Sor  do
     Begin
        LapVeg := (Image[LastLine]^.attribs[0] and LapVege) = LapVege;

       {$IFDEF LICENC}
       If Emblema and (NYmodus = 0) then
        begin
          Emblema := false;
          Assign(f,fontpath+BackSlash+PicNames[1]);
          Reset(f);
          EmbSor := 4;
          Tol    := 4;
        end;

       If Embsor > 0 then
        begin
         BalMargo;
         cmd(#27+'Z'+chr(48*2)+chr(0));
         for cikl := 1 to 48*2 do
          begin
           read(f,byt);
           lprint(byt);
          end;

         for cikl := 0 to 3 do  image[LastLine]^.chars[C80+cikl] := ' ';
         dec(EmbSor);
         If EmbSor = 0 then
           begin
             Close(f);
             tol := 0;
           end;
        end;
       {$ENDIF}

        egy_sort_nyom(Tol);
        inc(felsorok);

        if kilepett then
          Begin
            esc  := true;
            bool := remove_window;
            exit;
          End;

        if LapVeg then
          begin
            if KellLapDob then lprint(12);     {lap vege bit: FF}
            volt_lapdob := true;
            if StopAfterPage and KellLapDob then
               begin
                 BOOL := CREATE_WINDOW(10,11,45,16,pr_mess10,CA[DispMode,1],Ca[DispMode,4]);
                 GotoXY(2,3);
                 writeln (pr_mess11);
                 GotoXY(2,4);
                 writeln (pr_mess12);

                 If EnabledSpeak Then Speak2(101,201)
                                 Else for i:= 3 to 5 do beepel(i*200);

                 c := readkey; if c= #0 then c := readkey;
                 Bool := Remove_Window;
                 if c = #27 then
                   Begin
                     esc      := true;
                     kilepett := true;
                     bool     := remove_window;
                     exit;
                   End;
               end;
          end;
     End;                          {  Ha van sor  }

     If (LabelDist >= 0.01) and not KellLapdob then  {cimke tovabbitas}
     Begin
         Kell       := round(LabelDist * 180);
         EzKell     := Kell;
         Volt       := Felsorok  * 15;
         while Volt > Kell do inc(kell,Ezkell);     {kovetkezo cimke elejere}
         KellMeg    := Kell - Volt;
         while (KellMeg > 180) do        {teljes inch-eket kiad}
           begin
             cmd(#27+'3'+chr(180));      {atallit}
             cr_lf;                      {vegrehajt}
             dec(KellMeg,180);           {csokkent}
             if kilepett then
                 Begin
                   bool := Remove_window;
                   Esc  := True;
                   Exit;
                 End;
           end;
         if KellMeg > 0 then
           begin
            cmd(#27+'3'+chr(KellMeg));      {atallit}
            cr_lf;                          {vegrehajt}
           end;
         cmd(ppar.pr_lf_5_72);              {???}
     End;

  RestoreNoAttrib;          {vastag stb. kikapcsol}
  Bool := Remove_window;

End;  { Procedure BubbleJet}
End.
