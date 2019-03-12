Unit Nyom7;
{$O+}         { HP DeskJet 500 gyors nyomtatasi mod }

Interface

Uses Nyomtat,Dos,Crt,Windowm,MenuErr,
     Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

Procedure DeskJetNyom;     { csak gyors van}

Implementation

                 {ppar.pr_lf_1_216  = orator in
                  ppar.pr_lf_14_216 = orator out}

{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
Procedure DeskJetNyom;

type st2 = string[2];

const

laser_magyar : array [160 .. 177] of st2 =

( #$c4, #$e0, #$c5, #$dc, #$d5, #$c6, #$e7, #$ce, #$da,
{ aa    AA     ee     EE   ii    oo    OO    oe     OE }
#$6f#00,     #$4f#00,    #$c7, #$ed,   #$cf, #$db,
{ oeoe         OEOE        uu    UU      ue   UE }

#$75#00,  #$55#00 , #$e5);
{ ueue       UEUE     II}

laser_roman8_str : st8 = #27'(8U'  ;  {roman-8, sima courier}
pc8_str          : st8 = #27#40#49#48#85 ;  {IBM box drawing}


 Ekezetes = 29;

 Dummy : Byte = Ekezetes; {String length byte}

 m_atvalt : array [0..1,1..Ekezetes] of char =

 (('!',  '@',  '#',  '$',  '^',  '&',  '*',  '(',  ')',  '_',  '0',  '-',  '+',  '=',

   '{',  '[',  '}',  ']',  ':',  ';',  '"',  #$27, '~',  '`',  '|',  '\',  '<',  '>',  '/'),

  ('0',  '"',  '+',  '!',  '/',  '=',  '(',  ')',  #168, #174, #167, #173, #166, #165,

   #170, #169, #172, #171, #163, #162, #161, #160, #177, #164, #176, #175, ';',  ':',  '-'));


  font_8 : string[14] = '_+|uiojknm,&aA';
  ibm_kar: string[14] = 'ƒ≈≥⁄¬ø√¥¿¡Ÿ'#21'Ñé';

  nemet1 : string[27] = 'zZyY`~@#^&*()-_=+\|[{]};:''"<>/?';
  nemet2 : string[27] = 'yYzZ#^"'#21'&/()=·?''`<>Åö+*îôÑé;:-_';

  gorog1 : string[12] = 'abGpSsmtQqWd';
  gorog2 : string[12] = '‡·‚„‰ÂÊÁËÈÍÎ';

  euro1rol  : string[47*2] = '`1234567890-=\qwertyuiop[]asdfghjkl;''zxcvbnm,./'
                           + '~!@#$%^&*()_+|QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?';

  euro1re : string [47*2*2] = '◊ a^e^i^o^u^y^aouoc^h^j^s^÷ '+
                              'a`e`i`o`u`y`avevivgvoeue'    +
                              'a,e,’ o,u,y,cfsftfﬁ i ' +
                              'a:e:i:o:u:y:a~o~n~∏ ' +
                                                            {shifttel}
                              '” A^E^I^O^U^Y^AoUoC^H^J^S^“ ' +
                              'A`E`I`O`U`Y`AvEvIvGvOeUe' +
                              'A,E,I,O,U,Y,CfSfTfΩ I ' +
                              'A:E:I:O:U:Y:A~O~N~π ';

Var  Sst      : String[29] absolute Dummy;
      y       : integer;
      aktfont : byte;
      kilepett: boolean;
      i       : integer;
      c       : char;
      elsosor       : boolean;
      volt_lapdob   : boolean;
      vastag,alahuz,dalahuz,dolt,index,orator   : boolean;

      PrintMargo    : integer;
                                         { hatter arnyalat box }
      balfelso_x, balfelso_y : integer;
      jobbalso_x, jobbalso_y : integer;
      fokozat                : integer;
      volt_balfelso          : boolean;
      box_mode               : char;        {B/G/L lehet}

      lapmagassag : word;

Const

  ChrPerLine   :byte = 78;
  XPIX         :byte = 30;
  VMOV         :byte = 19;
  YPIX         :byte = 50;
  space_X      :byte = 30;
  Xbytes       :byte =  4;

  ekezet      = 168;

var balra, jobbra, dolt_balra, dolt_jobbra : byte;
    felfele, lefele : byte;

    felsorok            : word;
    Kell, EzKell,Volt, KellMeg : word;

    LapVeg : boolean;

{-----------------------------------------------------------------}
Function Volt_Esc : boolean;

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
{----------------------------------}
Procedure bill_urit;

var c : char;
begin
   while keypressed do
     Begin
       c:= readkey;
       if c = #0 then c:= readkey;
     End
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
                       cb := UpCase(readkey);
                   until cb in [#27,UjraChar,KilepChar];
                   Bool := remove_window;
                   if cb in [KilepChar,#27] then kilepett := true;
              end;

        until (pr_ok or kilepett);
end;

{----------------------------------}
Procedure lprintstr(szoveg: string);

var cikl: integer;
begin
       for cikl := 1 to length(szoveg) do
       begin
       lprint(byte(szoveg[cikl]));
       if kilepett then exit;
       end;
end;

procedure cmd (parancs: string);

var i: byte;

begin
  for i:= 1 to length(parancs) do
    begin
      lprint(byte(parancs[i]));
      if kilepett then exit;
    end;
end;

{--------------------------------------------------------------}

procedure laser_roman8;   {minden font valtas elott meghivni!!!}

begin
  cmd (laser_roman8_str);
end;

{----------------------------------}
procedure ini_ypos;

begin
      lprint(27);
      lprintstr('*p22Y');
      y := 22;
end;
{----------------------------------}
procedure cr_lf;

var ystr: st8;

begin
  lprint(13);
  Inc(y,VMOV);                        (* 19 helyett *)
  lprint(27); lprintstr('*p');
  str(y,ystr);
  while (ystr[1] = ' ')  or (ystr[1] = '0') do delete(ystr,1,1);
  lprintstr(ystr);
  lprint(byte('Y'));
end;


procedure xpos(x : integer);

var xstr : string[5];

begin
    str(x:5,xstr);
    while (xstr[1] = ' ')  or (xstr[1] = '0') do delete(xstr,1,1);
    cmd(#27'*p'+xstr+'X');
end;

{----------------------------------}
procedure vastag_be ;

begin
  laser_roman8;
  with ppar do
     cmd (pr_vastag_be);
  vastag := true;
end;

procedure vastag_ki;

begin
   laser_roman8;
   with ppar do
       cmd (pr_vastag_ki);
   vastag := false;
end;

procedure dolt_be;

begin
   laser_roman8;
   with ppar do
      cmd (pr_ala_be);
   dolt := true;
end;

procedure dolt_ki;

begin
  laser_roman8;
  with ppar do
      cmd (pr_ala_ki);
  dolt := false;
end;

procedure alahuz_be;

begin
   cmd (#27+'&dD');
   alahuz := true;
end;

procedure alahuz_ki;

begin
  cmd (#27+'&d@');
  alahuz := false;
end;


procedure index_be;

begin
   cmd (#27+'(s6V');
   index := true;
end;

procedure index_ki;

begin
  cmd (#27+'(s12V');
  index := false;
end;

procedure orator_be;

begin
   with ppar do
     cmd (pr_lf_1_216);
   orator := true;
end;

procedure orator_ki;

begin
  with ppar do
     cmd (pr_lf_14_216);
  orator := false;
end;
                  
procedure dalahuz_be;

begin
   cmd (#27+'&d2D');
   dalahuz := true;
end;

procedure dalahuz_ki;

begin
  cmd (#27+'&d@');
  dalahuz := false;
end;

{--------------------------------------------------------------}
Function Atcsinal_ha_kell(kar: char; kik : byte; attr : byte): char;

var k : byte;
    c : char;
    ala, dala : boolean;

procedure pushxy;

Begin
 cmd(#27+'&f0S');             {push xy}
End;

procedure popxy;

Begin
 cmd(#27+'&f1S');             {pop xy}
End;


Begin
    ala := alahuz;
    dala:= dalahuz;

    atcsinal_ha_kell := kar;
    if (kar in [#160..#177]) then
       begin
             k := ord(kar);
             if laser_magyar[k][0] = #1 then atcsinal_ha_kell:=
                                             laser_magyar[k][1]
             else
               begin
                   c := laser_magyar[k][1];
                   lprint(byte(c));
                   if alahuz  then alahuz_ki;
                   if dalahuz then dalahuz_ki;
               (*
                   cmd(#27'*p-34X');            {visszalep}
                   lprint(ekezet);
                   cmd(#27'*p-20X');            {visszalep}
                   lprint(ekezet);
                   cmd(#27'*p-6X');
                *)
                   pushxy;
                   xpos ((PrintMargo+kik) * XPIX - balra);
                   lprint(ekezet);
                   xpos ((PrintMargo+kik) * XPIX + jobbra);
                   lprint(ekezet);
                   popxy;
                   atcsinal_ha_kell := #00;
                   if ala  then alahuz_be;
                   if dala then dalahuz_be;

               end;
       end;
 End;
{----------------------------------------------------------}

procedure egy_kart_nyom (kik: integer);

var kar : char;
    att : byte;
      t : byte;
    ibm_lesz,  hosszu_kettos : boolean;
     eu : string[2];

Begin
   HOSSZU_KETTOS := FALSE;


   kar :=  Image[LastLine]^.chars[C80+kik];
   att :=  Image[LastLine]^.attribs[kik] and 15;


   if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
     begin
       kar := ' ';   { kemeny osszekoto space !!!}
       att := 1;
     end;

   Ibm_lesz := false;

   If kar = ' ' then
      begin
       if NOT(AlahuzottE(Att)) And alahuz then alahuz_ki;
       if dalahuz then dalahuz_ki;
       lprint(32);
       exit;
      end;

   if not DalahuzottE(att) then
    begin
      if IndexE(att) then               {duplan ala = index ala}
       begin
         if not index then index_be
       end
      else
       begin
         if index then index_ki;
       end;
    end;

   if OratorE(att) then
    begin
      if not orator then orator_be
    end
   else
    begin
      if orator then orator_ki;
    end;

   If EuroE(att) and (copy(Fontnames[att],1,4) <> 'SPEC') then
     begin
       T := Pos(kar,Euro1rol);
       if T>0 then
        begin
          eu := copy(Euro1re,t*2-1,2);
          case eu[2] of
           ' ' : begin
                  cmd(eu[1]+#8);
                  kar := ' ';
                 end;
           '`' : begin
                  cmd(eu[1]+#8);
                  kar := #169;
                 end;
           '^' : begin
                  cmd(eu[1]+#8);
                  kar := #170;
                 end;
           'o' : begin
                  cmd(eu[1]+#8);
                  kar := #179;
                 end;
           'v' : begin
                  cmd(eu[1]+#8+#168+#8);
                  kar := #169;
                 end;
           ',' : begin
                  cmd(eu[1]+#8);
                  kar := #168;
                 end;
           ':' : begin
                  cmd(eu[1]+#8);
                  kar := #171;
                 end;

           '~' : begin
                  cmd(eu[1]+#8);
                  kar := #172;
                 end;
           'f' : begin
                  cmd(eu[1]+#8);
                  kar := ',';
                 end;
           'e' : begin
                  hosszu_kettos := true;
                  case  eu[1] of
                   'o' : kar := '[';
                   'O' : kar := '{';
                   'u' : kar := '\';
                   'U' : kar := '|';
                  end;
                  T := Pos(kar,Sst);
                  If T > 0 Then Kar := m_atvalt[1,t];
                 end;
          end; {case}
        end;
     end

   Else
   If NemetE(att) then
      Begin
        T := Pos(kar,Nemet1);     {}
        If T > 0 Then
         Begin
           Kar := Nemet2[t];
           Ibm_lesz := true;
         End
      End
   Else
   If GorogE(att) then
      Begin
        T := Pos(kar,Gorog1);     {}
        If T > 0 Then
         Begin
           Kar := Gorog2[t];
           Ibm_lesz := true;
         End
        Else if kar <> ' ' then kar := ppar.pr_joker;
      End
   Else
   If MagyarE(att) then
      Begin                             { magyar }
        T := Pos(kar,Sst);
        If T > 0 Then Kar := m_atvalt[1,t];
      End
   Else
   If GrafE(att) and (FontNames[att] = 'SPEC1') then
      Begin
        T := Pos(kar,Font_8);     {dobozrajzolo,&,ae}
        If T >0 Then
         Begin
           Kar := Ibm_kar[t];
           Ibm_lesz := true;
         End
        Else if kar <> ' ' then kar := ppar.pr_joker;
      End
   Else
     Begin
      If not AngolE(att) then
       Begin
         If kar <> ' ' then kar := ppar.pr_joker;  { nem irhato }
       End;
     End;

   if DoltE(att) then                { dolt }
    begin
      if not dolt then dolt_be
    end
   else
    begin
      if dolt then dolt_ki;
    end;

   if AlahuzottE(att) then
    begin
      if not alahuz then alahuz_be
    end
   else
    begin
      if alahuz then alahuz_ki;
    end;
(*
   if not IndexE(att) then
    begin
      if AlahuzottE(att) then               {duplan ala = index ala}
       begin
         if not alahuz then alahuz_be
       end
      else
       begin
         if alahuz then alahuz_ki;
       end;
    end;
*)

   if DalahuzottE(att) then
    begin
      if not dalahuz then dalahuz_be;
      index_ki;
    end
   else
    begin
      if dalahuz then dalahuz_ki;
    end;

   if VastagE(att) then
    begin
      if not vastag then vastag_be
    end
   else
    begin
      if vastag then vastag_ki;
    end;

   AlahuzottSpaceCsere(Kar,Att);

   if MagyarE(att) or Hosszu_Kettos then
      kar := atcsinal_ha_kell(kar, kik, att);

   if ibm_lesz then cmd(pc8_str);          { font valtas }
   Lprint (byte(kar));                     { kiadja magat a karaktert is}
   if ibm_lesz then cmd(laser_roman8_str); { font vissza }

end;
{-----------------------------------------------------------}
procedure print_box;

const szurkeseg : array [1..7] of string[3] =
                  ('2', '10', '20', '35', '55', '80', '100');
var szelesseg, magassag : integer;
    xstr,ystr : string[8];

begin

   dec(balfelso_x,XPIX);
   dec(balfelso_y,YPIX);

   if balfelso_y < 0 then balfelso_y := 0;

   szelesseg := jobbalso_x - balfelso_x;
   magassag  := jobbalso_y - balfelso_y;

   cmd(#27+'&f0S');                        {push position}

   str(balfelso_x,xstr);                   {goto_xy_dots}
   str(balfelso_y,ystr);
   cmd(#27+'*p'+xstr+'X');
   cmd(#27+'*p'+ystr+'Y');

   str(szelesseg,xstr);                    {set_size}
   str(magassag ,ystr);
   cmd(#27+'*c'+xstr+'A');
   cmd(#27+'*c'+ystr+'B');

   cmd(#27+'*c'+szurkeseg[fokozat]+'G');   {select pattern}

   case box_mode of
    'G' : cmd(#27+'*c2P');                 {print block gray scale}
    'B' : cmd(#27+'*c0P');                 {print block black}
    'L' : cmd(#27+'*c3P');                 {print box lines}
   end;

   cmd(#27+'&f1S');                        {pop position}

end;


{-----------------------------------------------------------}
function kell_box(betuk_szama: word) : boolean;
                                  {itt van a .PROPON .PROPOFF nezes is}

var   ws : str160;
       t : word;
  pontok, spacek, itt : byte;
  sotet  : string[1];

begin
   kell_box := false;              {default}

   if volt_balfelso then           {jobb alsot keres}
     begin
       pontok := 0; spacek := 0;
       for t:= 0 to C77 do
          case Image[LastLine]^.chars[C80+t] of
            #0, #32 :  inc(spacek);
            '.'     :  begin
                        inc(pontok);
                        itt := t;
                       end;
          end;
       if (pontok = 1) and (spacek = C77) then      {megvan a jobb also}
        begin
          jobbalso_x := (printmargo + itt) * XPIX + XPIX div 2;  { 30 fele}
          jobbalso_y := y + VMOV div 2 ;                         { 19 fele}
          print_box;
          volt_balfelso := false;
          kell_box      := true;           {nincs irni valo}
        end;
     end
   else                                    {bal felsot keres}
     begin
        for t:= 0 to betuk_szama - 1 do ws[t+1] := Image[LastLine]^.chars[C80+t];
        ws[0]:= chr(betuk_szama);

        t :=  pos('.@',ws) ;               {van box kezdet jeloles? }
        (*
        if (t <> 0) and (ws[t+2] in ['1'..'8']) and (ws[t+3] in ['B','G','L'])
        *)
        if (t <> 0) and (ws[t+2] in ['1'..'7']) then
         begin
          balfelso_x := (printmargo + t) * XPIX + XPIX div 2;
          balfelso_y := y + VMOV div 2;
          sotet := ws[t+2];
          box_mode := 'G' ; {ws[t+3];}
          val(sotet,fokozat,t);             {fokozatot beallit}
          volt_balfelso := true;
          kell_box      := true;
         end;

     end;

end;

{-----------------------------------------------------------}
procedure egy_sort_nyom;

var kik          : integer;    {kiirando karakter sorszama}
    betuk_szama  : integer;
    hur,t        : integer;
    kar          : char;
    att          : byte;

Begin
       if alahuz then alahuz_ki;
       if dalahuz then dalahuz_ki;

       if ElsoSor then
          begin
             Ini_Ypos;
             ElsoSor := false;
          end;

       betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }

       if betuk_szama + PrintMargo > ChrPerLine - 1 then
             betuk_szama := ChrPerLine - PrintMargo - 1;   {max. 78 szeles ???}

       If betuk_szama > 0 then
          Begin
            for t:= 0 to betuk_szama-1 do
              begin
                kar := Image[LastLine]^.chars[C80+t];
                att := Image[LastLine]^.attribs[t] and 15;
                if att < 1 then att := 1;
                if (kar < ' ') or (kar > #127)
                  then Image[LastLine]^.chars[C80+t]  := ' ';
                Image[LastLine]^.attribs[t]:= att;
                if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1')
                  then Image[LastLine]^.chars[C80+t] := ' ';   { kemeny osszekoto space !!!}
              end;

           (*
            if not kell_box(betuk_szama) then         {ha nincs box-jelzes}
            *)
             begin
                for hur := 1 to PrintMargo do
                    begin
                       lprint(32);
                       if volt_esc or kilepett then exit;
                    end;

                For Kik := 0 To Betuk_Szama-1 Do
                  Begin
                    egy_kart_nyom (kik);
                    If volt_esc or  kilepett then exit;
                  End;
             end;
          end;

      if alahuz then alahuz_ki;
      if dalahuz then dalahuz_ki;

      cr_lf;        {abszolut pozicionalas felsor}
End;

{=============================================================}
                                                     { MAIN }

Begin
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}
  ChrPerLine := C78;

  If Enabled[5] Then
  Begin
    kilepett  := false;

    for i := 1 to 3 do
      Begin
        lprint(0);
        if kilepett then
         Begin
           ESC := true;
           exit;
         End;
      End;

    if not Korlevelben then
       cmd(ppar.pr_ini);                    {ini printer}

    PrintMargo   := PrintMargin;
    If PrintMargo = 0 then Inc(PrintMargo);

    BOOL := CREATE_WINDOW(40,6,75,10,pr_mess8,CA[DispMode,1],Ca[DispMode,2]);

    GotoXY(3,2);
    writeln (pr_mess9);

    if (not Korlevelben) or KellLapdob then
       ElsoSor := true; { kell ini_ypos; Y := 0, bal felso sarokba all }

    if (LabelDist >= 0.01) and (not KellLapdob) then   {cimke}
     begin
       Y  := LaserY;  { elozot atveszi globalisbol }
       if Y = 0 then ElsoSor := true       { kell Y-ini }
                else
                  begin
                   ElsoSor := false;       { nem kell   }
                   dec(Y,VMOV);
                   CR_LF;                  { inc(y,vmov) + goto(y) }
                  end;
     end;

    alahuz      := false;
    dalahuz     := false;
    dolt        := false;
    vastag      := false;
    index       := false;
    orator      := false;

    volt_balfelso := false;
{
    if ppar.pr_ini_ff_12 = '' then
}     Begin
       balra := 4;
       jobbra:= 6;
       dolt_balra := balra;
       dolt_jobbra:= jobbra;
       felfele := 0;
       lefele  := 0;
     End
 (*
    else
     Begin
       balra := byte(ppar.pr_ini_ff_12[1]);
       jobbra:= byte(ppar.pr_ini_ff_12[2]);
       dolt_balra := byte(ppar.pr_ini_ff_12[3]);
       dolt_jobbra:= byte(ppar.pr_ini_ff_12[4]);
       felfele := byte(ppar.pr_ini_ff_12[5]);  { csak nagybetuknel }
       if ppar.pr_ini_ff_12[0] = #6 then
       lefele  := byte(ppar.pr_ini_ff_12[6])   { csak kisbetuknel }
        else lefele  := 0;
      End ;
*)
    ;

    If Not(Formatum) Then                   { Portrait / landscape }
     begin
      Cmd(#27'&l1O');
      Lapmagassag := 2400;
     end
    Else
     begin
      Cmd(#27'&l0O');
      Lapmagassag := 3400;
     end;


    If Condensed then
     Begin
      XPIX         := 18;
      VMOV         := 12;
      space_X      := 18;
      balra := 3;
      jobbra:= 4;
      dolt_balra := balra;
      dolt_jobbra:= jobbra;
      felfele := 0;
      lefele  := 0;
      Cmd(#27'&k2S');
     End
    else
     Begin
      XPIX         := 30;
      VMOV         := 19;
      space_X      := 30;
      Cmd(#27'&k0S');
     End;



    {-------------------------------------------------------------------}
    dobott   := false;
    felsorok := 0;

    while  Van_Sor  do
           Begin
              LapVeg := (Image[LastLine]^.attribs[0] and LapVege) = LapVege;
              egy_sort_nyom;            { <---------- }
              inc(felsorok);

              if kilepett or volt_esc then
               Begin
                 esc := true;
                 bool := remove_window;
                 exit;
               End;

              if LapVeg then
                   begin
                     If KellLapDob then
                      begin
                       lprint(12);     {lap vege bit: FF}
                       ElsoSor := True;  {kell ini_ypos}
                       volt_balfelso := false;
                      end;
                     if StopAfterPage and KellLapDob then
                      begin
                        BOOL := CREATE_WINDOW(10,11,45,16,pr_mess10,CA[DispMode,1],Ca[DispMode,4]);
                        GotoXY(2,3);
                        writeln (pr_mess11);
                        GotoXY(2,4);
                        writeln (pr_mess12);

                        If EnabledSpeak Then Speak2(101,201)
                                        Else for i:= 3 to 5 do beepel(i*200);

                        c := readkey;  if c= #0 then c:= readkey;
                        Bool := Remove_Window;
                        if c = #27 then
                         Begin
                           esc      := true;
                           kilepett := true;
                           If Condensed then Cmd(#27'&k0S');     {normal}
                           bool     := remove_window;
                           exit;
                         End;
                      end;

                     If HanyOldalonKeresztul = 0 Then
                       Begin
                         Formatum := Not(Formatum);
                         HanyOldalonKeresztul := Maxint
                       End
                     Else
                       Dec(HanyOldalonKeresztul);

                     If Not(Formatum) Then  { Portrait / landscape }
                        Cmd(#27'&l1O')
                     Else
                        Cmd(#27'&l0O');

                   end;
           End;                                       {  Ha van sor  }

    If (LabelDist >= 0.01) and (not KellLapdob) then    { cimke tovabbitas }
     Begin
       Kell       := round(LabelDist * 300);
       EzKell     := Kell;
       Volt       := Felsorok  * VMOV;
       while Volt > Kell do inc(kell,EzKell);     {kovetkezo cimke elejere}
       KellMeg    := Kell - Volt;
       Inc(Y,KellMeg);
       {ha meg egy cimke nem ferne ki teljesen, akkor lapdobas!}
       if Y > Lapmagassag - round(LabelDist*300) then
        begin
          lprint(12);
          Dobott := true;
          Y := 0;
        end;
     End;

    Bool   := Remove_window;
    LaserY := Y;
    If Condensed then Cmd(#27'&k0S');     {normal}

  End;
End;  { Procedure LaserNyom }
End.
