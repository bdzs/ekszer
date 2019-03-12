Unit Nyom10;      { 24-tus matrix nyomtatokhoz 24-tus modus , CP 852 gyorsban}
{$O+}            { 18 / 36 pont szeles karakterek }

Interface

Uses Nyomtat,Dos,Crt,Windowm,Video,InputCdw,
     {$IFDEF PROBA}
     printer,
     {$ENDIF}
     HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

procedure LQ24TU852(ny_modus: integer; Var KarTomb:KarMut;
                                    Var FontKezdet:FontPoint);


Implementation

procedure LQ24TU852 (ny_modus: integer; Var KarTomb:KarMut;
                                     Var FontKezdet:FontPoint);

type  st2 = string[2];
      st3 = string[3];

const

 Ekezetes = 29;
 Kszel    : Byte = 36;

 Dummy : Byte = Ekezetes; {String length byte}

 m_atvalt : array [0..1,1..Ekezetes] of char =
(*
 (('!',  '@',  '#',  '$',  '^',  '&',  '*',  '(',  ')',  '_',  '0',  '-',  '+',  '=',

   '{',  '[',  '}',  ']',  ':',  ';',  '"',  #$27, '~',  '`',  '|',  '\',  '<',  '>',  '/'),

  ('0',  '"',  '+',  '!',  '/',  '=',  '(',  ')',  #168, #174, #167, #173, #166, #165,

   #170, #169, #172, #171, #163, #162, #161, #160, #177, #164, #176, #175, ';',  ':',  '-'));
*)

 (('!',  '@',  '#',  '$',  '^',  '&',  '*',  '(',  ')',  '_',  '0',  '-',  '+',  '=',

   '{',  '[',  '}',  ']',  ':',  ';',  '"',  #$27, '~',  '`',  '|',  '\',  '<',  '>',  '/'),

  ('0',  '"',  '+',  '!',  '/',  '=',  '(',  ')',  #153, #154, #148, #129, #224, #162,

   #138, #139, #233, #163, #144, #130, #181, #160, #214, #161, #235, #251, ';',  ':',  '-'));

Var  Sst : String[29] absolute Dummy;

var  elozo_sor_ures      : boolean;
     i,j,k               : integer;
     c                   : char;
     lap_vege            : boolean;
     e_sor_hossza        : word;
     elozo_sor_hossza    : word;
     betuk_szama         : integer;

    alahuz, vastag : boolean;
    kilepett       : boolean; {nyomtatas kozben ESC, vagy rossz printer}
    nyomas_vege    : boolean;

    y           : integer;
    volt_lapdob : boolean;
    szo         : st2;


    Kpoint      : word;

    or_tomb     : array[0..36*MaxMaxChars] of byte;    {elozo sor lelogoja}
    semmi       : array[1..10] of word;

    abspos      : integer;                   {or_tomb mutato}
    utso_alja   : integer;
    elso_alja   : integer;
    elozo_elso_alja : integer;
    volt_gr_ini : boolean;
    nezett_elsot: boolean;

    ures_sorok : word;

    felsorok    : word;
    Kell, EzKell, Volt, KellMeg : word;

    LapVeg : boolean;

    Tol,Ig : word;

    {$IFDEF LICENC}
    EmbSor : integer;
         f : file of byte;
      cikl : word;
       byt : byte;
    Spacek : word;
    {$ENDIF}

{----------------------------}
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

{$IFDEF LICENC}
procedure lprint1 (c: byte);
{$ELSE}
procedure lprint (c: byte);       {kilepett lesz, ha nem megy ki!!!}
                                  {es [A]bort }
{$ENDIF}

var
           cb   : char;
       pr_ok    : boolean;
       rAX, rDX : word;

begin
  pr_ok := false;
  cb    := ' ';
  repeat
(*
    register.DX := paralell_device;
    register.AL := c;
    register.AH := 0;                 {print AL}
    intr($17,register);
    pr_ok := ((register.AH and $0F) = 0);
*)
    rAX := c;                   {AH = 0; AL = c}
    rDX := paralell_device;     {0,1}

    Inline ($8B/$46/<rAX/     { MOV   AX,rAX  }
            $8B/$56/<rDX/     { MOV   DX,rDX  }
            $CD/$17/          { INT   17      }
            $89/$46/<rAX);    { MOV   rAX,AX  }

    pr_ok := ((hi(rAX) and $0F) = 0);

    if not pr_ok then
      begin
        BOOL := CREATE_WINDOW(42,8,72,12,pr_mess13,CA[DispMode,1],Ca[DispMode,4]);
        GotoXY(2,2);
        write(pr_mess14);

        Speak2(102,202);

        bill_urit;
        repeat
          cb := UpCase(readkey);
          if cb = #0 then cb := UpCase(readkey);
          write(byte(cb));
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

{$IFDEF LICENC}
Procedure LPRINT(c : byte);

var cik : word;

begin
(*
    if NYmodus <> 0 then Lprint1(c)
  else
   begin
     if (random(5) <> 4) or (c <> 32) then
       begin
         For cik := 1 to Spacek do Lprint1(32);   {amit felhalmozott}
         Spacek := 0;
         Lprint1(c);
       end
     else
       begin
         inc(Spacek);
         if Spacek = 4 then
          begin
            Lprint1(27);
            Lprint1(Byte('*'));
            Lprint1(39);
            Lprint1(72);
            Lprint1(0);
            for cik := 1 to 72*3 do
               Lprint1(0);
            Spacek := 0
          end;
       end;
   end;
*)
  Lprint1(c);
end;
{$ENDIF}

{-      --------------------------------------------------}
procedure cmd (parancs: st16);

var i: byte;

begin

  for i:= 1 to length(parancs) do
   begin
    {$IFDEF LICENC}
    lprint1(byte(parancs[i]));
    {$ELSE}
    lprint(byte(parancs[i]));
    {$ENDIF}
    if kilepett then exit;
   end;
end;
{---------------------------}
procedure spaceprint;

begin
  if Condensed and (Ny_modus > 0) then
   begin
     Lprint(27);
     Lprint(Byte('*'));
     Lprint(40);
     Lprint(18);
     Lprint(0);
     for cik := 1 to 18*3 do
        Lprint(0);
   end
  else lprint(32)
end;

procedure ini_printer;

Begin
   if not Korlevelben then
   with ppar do
   begin
      cmd (pr_ini);        {altalanos ini}
      If NOT Kilepett Then
        cmd (pr_ini_ff_12);  {12 inch paper length}
      If NOT Kilepett Then
        cmd (pr_lf_5_72);    {15/180 LF lesz}
    end;
End;

{-------------------------------------------------------------}
procedure ini_gr_sor(hossz: integer);

var    k : integer;
     i,j : byte;
       t : byte;
Begin
  k := hossz * Kszel  ;  {ennyi pont lesz}
  i := k mod 256      ;  { lsb }
  j := k div 256      ;  { msb }

  cmd (ppar.pr_ini_d_gr);                  {elso ket byte a parancsbol}
  If Not Kilepett Then
   begin
    if Condensed and (Ny_modus > 0)
     then lprint(40)
    else
    lprint(byte(ppar.pr_set_l_m[ny_modus])); {39 vagy 40 = 18/36 pont }
   end;
  If Not Kilepett Then
    Lprint(I);
  If Not Kilepett Then
    Lprint(J);

End;
{-------------------------------------------------------------------}
procedure vastag_be ;

begin
  with ppar do
     cmd (pr_vastag_be);
  vastag := true;
end;

procedure vastag_ki;

begin
   with ppar do
       cmd (pr_vastag_ki);
   vastag := false;
end;

procedure alahuz_be;

begin
   with ppar do
      cmd (pr_ala_be);
   alahuz := true;
end;

procedure alahuz_ki;

begin
  with ppar do
      cmd (pr_ala_ki);
  alahuz := false;
end;
{-----------------------------------------------------------}

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

Procedure BalMargo;
VAr hur : Integer;
Begin
  if alahuz then alahuz_ki;
  for hur := 1 to PrintMargin do
    begin
      spaceprint;
      if kilepett or volt_esc then exit;
    end;
End;
	
{---------------------------}

Procedure Cr_Lf;

Begin
   Lprint(13);   if kilepett or volt_esc then exit;
   Lprint(10);
End;
{-------------------------------------------------------------------}
procedure txt_egy_kart_nyom (kik: integer);  {39. image sor kik.-ik karakteret}

var kar : char;
    karb: byte;
    att : byte;
    t   : byte;
    c   : byte;

Begin

   kar :=  Image[LastLine]^.chars[C80+kik];
   if kar < ' '   then kar := ' ';

   att :=  Image[LastLine]^.attribs[kik];
   If Att <> 16 Then
     Att := Att And 15;

   if att < 1 then att := 1;



   if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
     begin
       kar := ' ';   { kemeny osszekoto space !!!}
       att := 1;
     end;

{$IFNDEF angol}                                      {ha magyar}

   if not ppar.pr_download   {ha nem tervezheto}  then
     begin
       if  ((kar <> ' ') and not AngolE(att)) then kar := ppar.pr_joker;
       lprint (byte(kar));
     end

   else                                              {ha DownLoad}
     begin
       If kar <> ' ' then
         Begin
            if (kar ='&') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
                 begin
                   kar := '';   { ibm paragrafus }
                 end

            Else
            If MagyarE(att) then                     {magyar}
                Begin
                  T := Pos(kar,Sst);
                  If T > 0 Then Kar := m_atvalt[1,t];
                End
            Else if not AngolE(att) then kar := ppar.pr_joker;  { nem irhato}

            if (AlahuzottE(att) or DoltE(att)) then
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

         End                                     {If kar <> ' '}
       Else
         Begin
           If not(AlahuzottE(Att)) And alahuz then
             alahuz_ki;
         End;

       AlahuzottSpaceCsere(Kar,Att);

       karb := byte(kar);
       Lprint (karb)   {kiadja magat a karaktert is}

     end;

  {$ELSE}                                    {angol}

     if kar <>  ' '  then
         begin
           If not AngolE(att) then kar := ppar.pr_joker;

           if (AlahuzottE(att) or DoltE(att)) then
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

         end
     else
       if NOT(AlahuzottE(Att)) And alahuz then alahuz_ki;

     AlahuzottSpaceCsere(Kar,Att);
     lprint(byte(kar));                {karakter kimegy }

  {$ENDIF}

 End;        {text egy kar-t kinyom}


{-------------------------------------------------------------------}
procedure print_space;

var t : byte;

begin
    for t:= 1 to Kszel do    {36 oszlop 3 byte-javal}
     begin
       lprint(0);                        if kilepett then exit;
       lprint(or_tomb[abspos] shr 1);    if kilepett then exit;
       lprint(0);
       or_tomb[abspos] := 0;
       inc(abspos);
     end
end;

{-------------------------------------------------------------------}
procedure ini_grafika(hossz: integer);

var    k : integer;
     i,j : byte;
       t : byte;
Begin

  k := hossz * Kszel  ;  {ennyi pont lesz}
  i := k mod 256      ;  { lsb }
  j := k div 256      ;  { msb }

  cmd (ppar.pr_ini_d_gr);                  {elso ket byte a parancsbol}
  If Not Kilepett Then
   begin
    if Condensed and (Ny_modus > 0)
     then lprint(40)
    else
    lprint(byte(ppar.pr_set_l_m[ny_modus])); {39 vagy 40 = 18/36 pont }
   end;

  If Not Kilepett Then
    Lprint(I);
  If Not Kilepett Then
    Lprint(J);

  volt_gr_ini := true;

end;
{-------------------------------------------------------------------}

procedure gr_egy_kart_nyom (kik: integer);  {39. image sor kik.-ik karakteret}

var kar : char;
    att : byte;
    t   : byte;
    c   : byte;
    leiro:word;
    karn :byte;
    van_alja : boolean;
    kezdo_ures, cime, maradek, oszlopok : word;
    ch : char;

Begin

   kar :=  Image[LastLine]^.chars[C80+kik];
   if kar < ' '   then kar := ' ';

   att :=  Image[LastLine]^.attribs[kik];
   If Att <> 16 Then
     Att := Att And 15;

   if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
     begin
       kar := ' ';   { kemeny osszekoto space !!!}
       att := 1;
     end;

   if kar = ' ' then
     begin
      if volt_gr_ini then print_space
      else if kik < elozo_elso_alja then
        begin
         spaceprint;    {meg szoveges}
         inc(abspos,Kszel);
        end
      else
       begin
         ini_grafika(e_sor_hossza-kik);
         if kilepett then exit;
         print_space;
       end;
     end

   else
    begin

       if not volt_gr_ini then ini_grafika(e_sor_hossza-kik);
       if kilepett then exit;

       karn := byte(kar)-32;              {vagy 31!!!}
       cime := KarTomb[att,karn].cim;     {relativ cime }
       if cime = $FFFF then print_space
       else
        begin
          van_alja   :=  (kartomb[att,karn].bevezeto and $80) <> 0;
          kezdo_ures :=  kartomb[att,karn].bevezeto and $7F;
          oszlopok   :=  kartomb[att,karn].oszlopok;
          (*
              Inc(cime,Fontkezdet[att]);   {abszolut cime a tombben}
            *)
          maradek    :=  Kszel-oszlopok-kezdo_ures;

          if kezdo_ures <> 0 then
           begin
             for t:= 1 to kezdo_ures do
              begin
                lprint(0);                       if kilepett then exit;
                lprint(or_tomb[abspos] shr 1);   if kilepett then exit;
                lprint(0);                       if kilepett then exit;
                or_tomb[abspos] := 0;
                inc(abspos);
              end;
           end;

          for t:= 1 to oszlopok do
            begin
              lprint(Fontkezdet[att]^[cime]);                            inc(cime);
                     if kilepett then exit;
              lprint(Fontkezdet[att]^[cime] or (or_tomb[abspos] shr 1)); inc(cime);
                     if kilepett then exit;
              lprint(Fontkezdet[att]^[cime]);                            inc(cime);
                     if kilepett then exit;

              if van_alja then
                begin
                  or_tomb[abspos] := Fontkezdet[att]^[cime];             inc(cime);
                  utso_alja       := kik;
                  if not nezett_elsot then
                   begin
                     elso_alja    := kik;
                     nezett_elsot := true;
                   end
                end
              else or_tomb[abspos] := 0;

              inc(abspos);                     { csak a legvegen }
            end;

          if maradek <> 0 then
           begin
             for t:= 1 to maradek do
              begin
                lprint(0);                         if kilepett then exit;
                lprint(or_tomb[abspos] shr 1);     if kilepett then exit;
                lprint(0);                         if kilepett then exit;
                or_tomb[abspos] := 0;
                inc(abspos);
              end;
           end;

        end;
    end;
End;        {grafikus egy kar-t kinyom}
{-------------------------------------------------------------------}
procedure Or_tombnyom(eddig: integer);

var i,t: integer;
    darab: integer;

begin

  if Tol = 0 then BalMargo;

  if elozo_elso_alja > 0 then
   for t:= 1 to elso_alja do
     begin
       spaceprint;
       if kilepett then exit;
     end;

  darab := eddig + 1;
  ini_gr_sor(darab - elso_alja);
  if kilepett then exit;
  for t:= elso_alja*Kszel to darab*Kszel-1 do
   begin
     lprint(0);
     if kilepett then exit;
     lprint(or_tomb[t] shr 1);
     if kilepett then exit;
     lprint(0);
   end;

   fillchar(or_tomb,Kszel*C80,#0);

end;


{-------------------------------------------------------------------}
procedure egy_sort_nyom(Tol:integer);   {37. image sorban van}


var kik          : integer;    {kiirando karakter sorszama}
    van_valami   : boolean;
    ch           : char;

Begin

     betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }
     if betuk_szama + PrintMargin > C80 then
     betuk_szama := C80 - PrintMargin;     {max. 78 szeles }

     e_sor_hossza := betuk_szama;
     Van_Valami   := (E_sor_hossza <> 0);

     abspos      := 0;    { or_tomb mutato }
     volt_gr_ini := false;

     If van_valami
     {$IFDEF licenc}
     or (EmbSor > 0)
     {$ENDIF}
      Then
       begin

         If tol = 0 then BalMargo;
         If volt_esc or kilepett then exit;

         ures_sorok := 0;

         if utso_alja + 1 > e_sor_hossza          {elozo lelogoja tavolabb van}
          then e_sor_hossza := utso_alja + 1;     {?????}

         utso_alja        := -1;               {az utso lelogo szama lesz}
         elso_alja        := 99;
         nezett_elsot     := false;


         Ig := E_Sor_Hossza-1;
         {$IFDEF Licenc}
         If (Embsor > 0) and (EmblemaXPos > 0) and (NyModus = 0)
          then Ig := EmblemaXpos - 1;
         {$ENDIF}

         for kik := Tol to Ig do
          begin
            if Ny_Modus = 0 then txt_egy_kart_nyom(kik)
                            else  gr_egy_kart_nyom(kik);
            if volt_esc or kilepett then exit;
          end;

         {$IFDEF Licenc}
         If (Embsor > 0) and (EmblemaXPos > 0) and (NyModus = 0)
          then E_Sor_Hossza := EmblemaXpos - 1;
         {$ENDIF}

         elozo_sor_hossza := e_sor_hossza;
         elozo_sor_ures   := false;
         elozo_elso_alja  := elso_alja;

       end

     Else                                { nincs valami }
       begin

         inc(ures_sorok);

         if Ny_Modus > 0 then             {szovegesnel nincs alja}
          begin
            if not elozo_sor_ures then       {elozo alja, ha van}
             if utso_alja > -1 then
               or_tombnyom(utso_alja);       {eddig kell kiadni, EZT IS}
          end;

         elozo_sor_hossza  := 0;
         elozo_sor_ures    := true;
         utso_alja         := -1;
         elso_alja         := -1;
         elozo_elso_alja   := 99;

         if volt_esc or kilepett then exit;
       end;        {nincs valami}

     {$IFNDEF licenc}
     Cr_Lf;
     {$ELSE}
     if (Embsor = 0) or (NyModus > 0) or (EmblemaXPos = 0)
       then cr_lf;      {nincs kep vagy grafikus}
     {$ENDIF}

End;

{=====================  MAIN ====================================}
{procedure LQ24TU (ny_modus: integer) }
             {a ppar_pr_set_l_m 1. byte-ja: normal, 2. byteja szep nyomashoz:
              39 / 40 ,  LQ1500-nal mindketto 39 / 39,
              fontkiterjesztes 18: .18T
                               36: .24T  }
Begin
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}
  If Enabled[1] Then
  Begin
    {$IFDEF LICENC}
     EmbSor := 0;
     Spacek := 0;
    {$ENDIF}

    Kszel := (Byte(ppar.pr_set_l_m[ny_modus])-38)*18;    {karakter szelesseg }

    kilepett    := false;

    BOOL := CREATE_WINDOW(40,6,75,10,pr_mess8,CA[DispMode,1],Ca[DispMode,2]);

    GotoXY(3,2);
    writeln (pr_mess9);

    elozo_sor_ures      := true;   {nem volt elozo sor}
    elozo_sor_hossza    := 0;

    lap_vege    := false;        {nem a lap alja}
    volt_lapdob := false;

    elso_alja := 99;
    utso_alja := -1;
    elozo_elso_alja := 99;

    ini_printer;

    if ny_modus >0 then fillchar(or_tomb,36*C80,#0);

    ures_sorok := 0;


    if Condensed and (Ny_modus = 0)
     then lprint(15)
     else lprint(18);


    {-------------------- inicializalas vege: main loop ------------}

    Felsorok := 0;
    Tol      := 0;

    while  Van_Sor  do
      Begin
        LapVeg := (Image[LastLine]^.attribs[0] and LapVege) = LapVege;

        {$IFDEF LICENC}

        If Emblema and (NYmodus = 0)  then
         begin
           Emblema := false;
           Assign(f,fontpath+BackSlash+PicNames[2]);
           Reset(f);
           EmbSor := 4;
           If EmblemaXPos = 0 then
             Tol    := 4
           Else Tol := 0;
         end;

        If (Embsor > 0) and (EmblemaXPos = 0) then
         begin
          BalMargo;
          cmd(#27+'*'+chr(39)+chr(72)+chr(0));
          for cikl := 1 to 72 do
            begin
             read(f,byt);
             lprint1(byt);
             read(f,byt);
             lprint1(byt);
             lprint1(0);
            end;
          for cikl := 0 to 3 do  Image[LastLine]^.chars[C80+cikl] := #0;
          dec(EmbSor);
          If EmbSor = 0 then
              Close(f);
         end;
        {$ENDIF}

        egy_sort_nyom(Tol);

        {$IFDEF LICENC}
        If EmbSor = 0 then Tol := 0;

        If (Embsor > 0) and (EmblemaXpos > 0) then
         begin
          cmd(#27+'*'+chr(39)+chr(72)+chr(0));
          for cikl := 1 to 72 do
            begin
             read(f,byt);
             lprint1(byt);
             read(f,byt);
             lprint1(byt);
             lprint1(0);
            end;
          dec(EmbSor);
          If EmbSor = 0 then
            Close(f);
          Cr_Lf;
         end;

        {$ENDIF}



        inc(Felsorok);
        if kilepett then
            Begin
              bool := Remove_window;
              Esc  := True;
              Exit;
            End;

        if LapVeg then
          begin
            If KellLapDob then lprint(12);          {lap vege bit: FF}
            delay(ures_sorok * IroIdo);
            ures_sorok := 0;
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

                 c := readkey;
                   if c= #0 then c := readkey;
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

    {  Ha nincs sor  }
      If  ((elozo_sor_hossza <> 0) and (ny_modus > 0) and (utso_alja > -1))
       {$ifdef licenc}
       and (EmblemaMod > 2)
       {$endif}
       Then
       begin
         BalMargo;
         Or_tombnyom(utso_alja);
         CR_LF;
         inc(Felsorok);
       end;

      If (LabelDist >= 0.01) and not KellLapdob then  {cimke tovabbitas}
         Begin
           Kell       := round(LabelDist * 180);
           Volt       := Felsorok  * 15;
           EzKell     := kell;
           while Volt > Kell do inc(kell,EzKell);     {kovetkezo cimke elejere}
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
           cmd(ppar.pr_lf_5_72);    {5/72 LF}  {visszaallit}
         End;

     Bool := Remove_window;

     (* cmd(#27+'@');                 { alapallapotba vissza allit } *)
  End;
End;  { Procedure LQ24TU }


End.
