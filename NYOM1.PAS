Unit Nyom1;
{$O+}         { 90/08/31 08:52 /FI/ proporcion†l†s !!!!!!!!!!!!}

Interface

Uses Nyomtat,Dos,Crt,Windowm,MenuErr,Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

Procedure LaserNyom(mode: byte);     {0= gyors, 1,2= tervezett}

Implementation


{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}
Procedure LaserNyom(mode: byte);    (* gyors nyomas vagy *)
                                    (* 50/30 pont download characters *)

type st2 = string[2];
     st4 = string[4];


const FontSzam : array [1..MaxFontNum] of st4 =

  ('1001','1002','1003','1004','1005','1006','1007','1008','1009','1010'
  {$IFNDEF VER352}
  ,'1011','1012','1013','1014','1015'
  {$ENDIF}
  );


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

 const FontFejStr  : st40 =
        #27')s26W'#0#$1A#0#0#0#0#0#0#0#30#0#50#0#0#0#0#0#120#0#200#0#0#0#0#0#0;

       FontID      : st8 = #27'*c';
       PermanentStr: st8 = #27'*c5F';

  var  HeaderData  : array[-7..26] of byte absolute FontFejStr;


 const KarFejStr : st40 =
                   #27'(s0216W'#04#0#14#01#0#0#0#0#0#0#0#30#0#50#0#30;
       KarPosStr : st8 = #27'*c';

   var KarHeaderData : array [-9..16] of byte absolute KarFejStr;
       KarByteNumber : array [-3..4]  of char absolute KarfejStr;

 const Phossz = 4000;   {egy kikuldendo karakter szamamra fenntartott hely}

Var  Sst      : String[29] absolute Dummy;
      y       : integer;
      aktfont : byte;
      Puffer  : array [1..Phossz] of byte;  { = csak egy betunek !!! }
      kilepett: boolean;
      i       : integer;
      c       : char;
      elsosor       : boolean;
      volt_lapdob   : boolean;
      vastag,alahuz,                    {alahuz = dolt}
      igaz_alahuz   : boolean;

      PrintMargo    : integer;
                                         { hatter arnyalat box }
      balfelso_x, balfelso_y : integer;
      jobbalso_x, jobbalso_y : integer;
      fokozat                : integer;
      volt_balfelso          : boolean;
      box_mode               : char;        {B/G/L lehet}

     fsize                     : word;   { file helyesseg ellenorzeshez }
     charsize                  : word;   { hany byte egy chr }
     nyomohiba : boolean;
Const

  ChrPerLine   :byte = 78;
  XPIX         :byte = 30;
  VMOV         :byte = 19;
  YPIX         :byte = 50;
  space_X      :byte = 30;
  Xbytes       :byte =  4;

  XPIX_st      :string[2] = '30';
  YPIX_st      :string[2] = '50';
  VMOV_st      :string[2] = '19';

  ekezet      = 168;

var balra, jobbra, dolt_balra, dolt_jobbra : byte;
    felfele, lefele : byte;
    Lapmagassag : word;

    lehet_prop  : Boolean;
    prop_on     : Boolean;

type leiro = record
              kezdet : byte; {atveszi}
              szeles : byte; {atvenni + parna}
             end;

type leirotomb = array ['!'..'~'] of leiro;

var prop_data : array [1..MaxFontNum] of leirotomb;

const parna = 4;  {hany elemi pont lesz ket karakter kozott,
                   ennel kevesebb lehet, ha szeles a karakter}

var
    felsorok            : word;
    Kell, EzKell,Volt, KellMeg : word;

    LapVeg : boolean;

    const sz : word = 0;

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


Procedure Laser_Copies(x: integer);

Var xst: string[5];
      t: byte;
  kistr: string[9];

const ncopies = #27'&l';

Begin
   ESC := false;
   str(x:0,xst);
   t     := 1;
   kistr := ncopies+xst+'X';

   cmd(kistr);
End;


{--------------------------------------------------------------}

procedure laser_roman8;   {minden font valtas elott meghivni!!!}

begin
  cmd (laser_roman8_str);
end;



{----------------------------------}
procedure ini_ypos;

begin
      lprint(27);
      if nymodus = 0 then
       Begin
         lprintstr('*p22Y');
         y := 22;
       End
      else
       Begin
         lprintstr('*p0Y');
         y := 0;
       End;
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

procedure alahuz_be;

begin
   laser_roman8;
   with ppar do
      cmd (pr_ala_be);
   alahuz := true;
end;

procedure alahuz_ki;

begin
  laser_roman8;
  with ppar do
      cmd (pr_ala_ki);
  alahuz := false;
end;

procedure igaz_alahuz_be;

begin
   cmd (#27+'&dD');
   igaz_alahuz := true;
end;

procedure igaz_alahuz_ki;

begin
  cmd (#27+'&d@');
  igaz_alahuz := false;
end;


{--------------------------------------------------------------}
Function Atcsinal_ha_kell(kar: char; kik : byte; attr : byte): char;

var k : byte;
    c : char;

procedure pushxy;

Begin
 cmd(#27+'&f0S');             {push xy}
End;

procedure popxy;

Begin
 cmd(#27+'&f1S');             {pop xy}
End;

Procedure yfel(yrel: byte);

Var s: st2;

Begin
 if yrel <> 0 then
  begin
   str(yrel:0,s);
   cmd(#27+'*p-'+s+'Y');  {feljebb}
  end;
End;

Procedure yle(yrel: byte);

Var s: st2;

Begin
 if yrel <> 0 then
  begin
   str(yrel:0,s);
   cmd(#27+'*p+'+s+'Y');  {feljebb}
  end;
End;

Begin
    atcsinal_ha_kell:= kar;
    if (kar in [#160..#177]) then
       begin
             k := ord(kar);
             if laser_magyar[k][0] = #1 then atcsinal_ha_kell:=
                                            laser_magyar[k][1]
             else
               begin
                   c := laser_magyar[k][1];
                   lprint(byte(c));
                   pushxy;
                   if c in ['O','U'] then
                     begin
                      igaz_alahuz_ki;
                      yfel (felfele);
                     end;
                   if c in ['o','u'] then
                     begin
                      igaz_alahuz_ki;
                      yle  (lefele);
                     end;
                   if doltE(attr) then
                     xpos ((PrintMargo+kik) * XPIX - dolt_balra)
                   else  xpos ((PrintMargo+kik) * XPIX - balra);
                   lprint(ekezet);
                   if doltE(attr) then
                     xpos ((PrintMargo+kik) * XPIX + dolt_jobbra)
                   else xpos ((PrintMargo+kik) * XPIX + jobbra);
                   lprint(ekezet);
                   popxy;
                   atcsinal_ha_kell := #00;
               end;
       end;
 End;
{----------------------------------------------------------}
Procedure ChooseFont(szam: st4);  {szam: '1001' .. '1010'}

begin
      lprint(27);
      lprint(byte('('));
      lprintstr(szam);
      lprint(byte('X'));
end;

{-------------------------------------------------------------------}
Function  LoadLaserFonts: boolean;  {meghivja a SendFont-ot !!!}

Var
    Cikl      : Integer;
    FileName  : St16;
    xx        : integer;
    PropFile  : file;

Const
    Ext     = '.LFT';
    Propext = '.PRL';

{----------------------------------}
Function SendFont(Num: integer): boolean;
                 {assign font ID, font fejlec, karakterek}

var cikl,cikl1: word;
    szam: st8;
      xx: word;

begin
     nyomohiba := true;

     SendFont := false;
     szam := FontSzam[Num];

{assign_font_id}
     lprintstr(FontID); if kilepett or Volt_esc then exit;
     lprintstr(szam);   if kilepett or Volt_esc then exit;
     lprint(byte('D'));
{font fejlec}
     lprintstr(FontFejstr);   if kilepett or Volt_esc then exit;

{karakterek}

      for cikl:= 33 to 126 do
        begin
            {$i-}
          blockread(FontFile,Puffer,CharSize,xx);
            {$i+}
          if (ioresult <> 0) or (xx <> CharSize) then exit;
            {karakter pos}
          lprintstr(KarPosStr); if kilepett or Volt_esc then exit;
          str(cikl,szam);
          lprintstr(szam);      if kilepett or Volt_esc then exit;
          lprint(byte('E'));    if kilepett or Volt_esc then exit;
            {karakter fejlec}
          lprintstr(KarFejStr); if kilepett or Volt_esc then exit;
            {karakter data}
          for cikl1 := 1 to CharSize do
            begin
              lprint (Puffer[cikl1]);
              if kilepett or Volt_esc then exit;
            end;
        end;

{make it permanent}
        lprintstr(PermanentStr);  if kilepett or Volt_esc then exit;

     SendFont := true;
     nyomohiba := false;
end;

{ --------------------------- Load Laser Fonts ------------------}

Begin

  LoadLaserFonts := false;

  FillChar(Puffer,Phossz,#0);

  Bool := CREATE_WINDOW(39,5,79,16,pr_mess3,CA[DispMode,1],Ca[DispMode,2]);

  CheckRead(PathSt);
  If Not Esc Then

  Begin
    For Cikl := 1 To MaxFontNum Do
     If Van_Font[Cikl] AND (MindigLetolt OR ChFont[Cikl]) Then
      Begin
        FileName := Fontnames[Cikl] + Ext;
        Assign(Fontfile,PathSt+FileName);
        {$i-} Reset(Fontfile,1); {$i+}
        If IOresult <> 0 Then
        Begin
          Error(1,Filename);      {Error_msg[1]}
        End
        Else
          Begin
            {$IFDEF NORVEG}
            Writeln(Cikl,'. ',FileName);
            {$ELSE}
            Writeln(Cikl,'. ',FileName,pr_mess5);
            {$ENDIF}
            Seek(FontFile,$158);                     {fejlecet atugrik}
            if SendFont(Cikl) OR Kilepett then Close(Fontfile)   {sikerult}
               else if remove_window then exit;
            ChFont[Cikl] := False;
          End;
      End;
    LoadLaserFonts := true;

{-- proporcinalis data --}

    (*
    For Cikl := 1 To MaxFontNum Do
     If Van_Font[Cikl] then
      Begin
        FileName := Fontnames[Cikl] + Propext;
        Assign(PropFile,PathSt+FileName);
        {$i-}
        Reset(Propfile,4 * (byte('~')-byte('!')+1));
        {$i+}
        If IOresult <> 0 Then
        Begin
          Writeln(pr_mess4,Filename);      {Error_msg[1]***}
          Beepel(660);
          lehet_prop := false;
          Bool := remove_window;
          exit;
        End
        Else
          Begin
            {$IFDEF NORVEG}
            Writeln(Cikl,'. ',FileName);
            {$ELSE}
            Writeln(Cikl,'. ',FileName,pr_mess5);
            {$ENDIF}

            BlockRead(PropFile,Prop_Data[cikl], 4 * (byte('~')-byte('!')+1),xx);
            Close(PropFile);
          End;
      End;
      lehet_prop := true;


  *)
  End;

  Bool := Remove_Window;
End;
{---------------------------------------}
procedure egy_kart_nyom (kik: integer);

var kar : char;
    att : byte;
      t : byte;
    ibm_lesz : boolean;

Begin

   kar :=  Image[LastLine]^.chars[C80+kik];
   att :=  Image[LastLine]^.attribs[kik] and 15;

   if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
     begin
       kar := ' ';   { kemeny osszekoto space !!!}
       att := 1;
     end;

   Ibm_lesz := false;

   case mode of

{$IFNDEF angol}                               {magyar}

   0:   Begin                                 { magyar vagy joker }
             If kar = ' ' then
                begin
                 if Not(AlahuzottE(Att)) And
                    igaz_alahuz then igaz_alahuz_ki;
                 lprint(32);
                 exit;
                end;

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
             If GrafE(att) then
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

             if DoltE(att) then                {nem alahuzott, dolt}
              begin
                if not alahuz then alahuz_be
              end
             else
              begin
                if alahuz then alahuz_ki;
              end;

             if AlahuzottE(att) then
              begin
                if not igaz_alahuz then igaz_alahuz_be
              end
             else
              begin
                if igaz_alahuz then igaz_alahuz_ki;
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

             kar := atcsinal_ha_kell(kar, kik, att);

             if ibm_lesz then cmd(pc8_str);         { font valtas }
             Lprint (byte(kar));               { kiadja magat a karaktert is}
             if ibm_lesz then cmd(laser_roman8_str); { font vissza }

        End;

  {$ELSE}                                    {angol}

   0: Begin                                  {text modus: ASC normal / bold}
        if kar = ' ' then
         begin
          if igaz_alahuz then igaz_alahuz_ki;
          lprint(32)
         end
        else
         Begin
           If not AngolE(att) then kar := ppar.pr_joker
           Else
            Begin
             if DoltE(att) then                {nem alahuzott, dolt}
              begin
                if not alahuz then alahuz_be
              end
             else
              begin
                if alahuz then alahuz_ki;
              end;

             if AlahuzottE(att) then
              begin
                if not igaz_alahuz then igaz_alahuz_be
              end
             else
              begin
                if igaz_alahuz then igaz_alahuz_ki;
              end;

             if VastagE(att) then
              begin
                if not vastag then vastag_be
              end
             else
              begin
                if vastag then vastag_ki;
              end;

            End;
           AlahuzottSpaceCsere(Kar,Att);

           lprint(byte(kar));                {karakter kimegy }
         End;
      End;

  {$ENDIF}

   1,2: begin
          if ((kar > ' ') and (att <> aktfont)) then
           begin
	     ChooseFont(fontszam[att]);
	     if kilepett then exit;
	     aktfont := att;
           end;

          lprint(byte(kar));
        end;

   end; { case mode of }

end;
{-----------------------------------------------------------}
procedure print_box;

const szurkeseg : array [1..7] of string[3] =
                  ('2', '10', '20', '35', '55', '80', '100');
var szelesseg, magassag : integer;
    xstr,ystr : string[8];

begin

  if mode = 0 then
   begin
     dec(balfelso_x,XPIX);
     dec(balfelso_y,YPIX);
   end
  else
   begin
     dec(balfelso_x,XPIX);              {beloni mas meretre is!!!}
     dec(balfelso_y,VMOV div 2);
     inc(jobbalso_y,YPIX);
   end;

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
        if (t <> 0) and (ws[t+2] in ['1'..'7']) and StandardE(Image[LastLine]^.attribs[t+1-1]) then
         begin
          balfelso_x := (printmargo + t) * XPIX + XPIX div 2;
          balfelso_y := y + VMOV div 2;
          sotet := ws[t+2];
          box_mode := 'G' ; {ws[t+3];}
          val(sotet,fokozat,t);             {fokozatot beallit}
          volt_balfelso := true;
          kell_box      := true;
         end;

        {.PROPON es .PROPOFF}
        for t:= 1 to C78 do ws[t] := upcase(ws[t]);

        t := pos('.PROPON',ws);
        if t <> 0 then
         begin
          prop_on := true;
          kell_box:= true;    {nincs irni valo}
         end;
        t := pos('.PROPOFF',ws);
        if t <> 0 then
         begin
          prop_on := false;
          kell_box:= true;
         end;

     end;

end;
{-----------------------------------------------------------}
Procedure Prop_Sort_Nyom(Betuk_Szama: word);

Procedure Visszalep(x: word);

var xstr : string[5];

begin
    str(x:5,xstr);
    while (xstr[1] = ' ')  or (xstr[1] = '0') do delete(xstr,1,1);
    cmd(#27'*p-'+xstr+'X');
end;

Procedure Elorelep(x: word);

var xstr : string[5];

begin
    str(x:5,xstr);
    while (xstr[1] = ' ')  or (xstr[1] = '0') do delete(xstr,1,1);
    cmd(#27'*p+'+xstr+'X');
end;


Var t,i  : word;
    wchr : st80;
    wattr: st80;
    utsochr : word;
    kar : char;
    att : byte;

    vissza,teljes : byte;
    relvissza     : integer;
    szoszel, nempropszel   : integer;
    elsoszo       : boolean;

Begin
  Utsochr     := Betuk_Szama - 1;
  t           := 0;
  ElsoSzo     := true;                      {mindenkeppen balra igazit}

  While t <= Utsochr do
   Begin
    While (Image[LastLine]^.chars[C80+t] = ' ') and (t <= Utsochr) do
       inc(t);                                 {spacek-et atlep}

    If t = Utsochr then                        {utolso maganyos}
     begin
       Xpos((PrintMargo + t) * XPIX);
       Egy_Kart_Nyom(t);
       exit;
     end;

    If t > Utsochr then exit;

    wchr    := '';                              {uj szo}
    wattr   := '';

    Xpos((PrintMargo + t) * XPIX);              {beall a szo elejere}

    If kilepett then exit;

    While (Image[LastLine]^.chars[C80+t] <> ' ') and (t <= Utsochr) do
      begin
        wchr := wchr + Image[LastLine]^.chars[C80+t];
        wattr:= wattr+ chr(Image[LastLine]^.attribs[t] and 15);
          if wattr[t] = #0 then wattr[t] := #1;
        inc(t);
      end;                                      {szo osszarakva}

    If (t >= Utsochr) and (not ElsoSzo) then
                                                {utolso szo: jobbra igazit}
      Begin
        szoszel := 0;

        for i:= 1 to length(wchr) do
         begin
          kar := wchr[i];
          att := byte(wattr[i]);
          if grafE(att) then
           begin
            vissza := 0;
            teljes := XPIX;
           end
          else
           begin
            vissza := prop_data[att][kar].kezdet;
            if vissza = 99 then vissza := 0;       {nincs chr = space}
            teljes := prop_data[att][kar].szeles;
            if teljes = 99 then teljes := XPIX;    {nincs chr}
           end;

          inc(szoszel,teljes);
          if not grafE(att) then
           inc(szoszel,parna);
         end;

        if not grafE(att) then
         dec(szoszel,parna);
        nempropszel := length(wchr) * XPIX;
        relvissza   := nempropszel - szoszel;
        if relvissza > 0 then
          elorelep(relvissza);                 {akkor elorelep}
        if relvissza < 0 then
          visszalep(abs(relvissza));           {kulonben vissza}
      End;

    For i := 1 to length(wchr) do               {feldolgozni}
      begin
       kar := wchr[i];
       att := byte(wattr[i]);

       if grafE(att) then                     {ha grafikus, nem prop!}
        begin
         vissza := 0;
         teljes := XPIX;
        end
       else
        begin
         vissza := prop_data[att][kar].kezdet;
         if vissza = 99 then vissza := 0;
         teljes := prop_data[att][kar].szeles;
         if teljes = 99 then teljes := XPIX;
        end;

       If vissza > 0 then
           visszalep(vissza);                  {akkor visszalep}
       if kilepett then exit;
                                                {kar megy ki}
       if att <> aktfont then
         Begin
           ChooseFont(fontszam[att]);
           if kilepett then exit;
           aktfont := att;
         End;
       lprint(byte(kar));
       if kilepett then exit;

       if not grafE(att) then                 {csak ha nem grafikus!!!}
       begin
         relvissza := XPIX - teljes - vissza - parna;
         if relvissza > 0 then
              visszalep(relvissza);           {akkor visszalep}
         if relvissza < 0 then
              elorelep (abs(relvissza));      {kulonben elore}
       end;
       if kilepett then exit;

      end;                                {egy szo vege}

    ElsoSzo := false;
   End;
End;

{-----------------------------------------------------------}
procedure egy_sort_nyom;

var kik          : integer;    {kiirando karakter sorszama}
    betuk_szama  : integer;
    hur,t        : integer;
    kar          : char;
    att          : byte;

Begin
       if igaz_alahuz then igaz_alahuz_ki;

       if ElsoSor then
          begin
             Ini_Ypos;
             ElsoSor := false;
          end;

       betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }

       (*
       if betuk_szama + PrintMargo > ChrPerLine - 1 then
             betuk_szama := ChrPerLine - PrintMargo - 1;   {max. 78 szeles ???}
       *)

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

            if not kell_box(betuk_szama) then         {ha nincs box-jelzes}
             begin
                for hur := 1 to PrintMargo do
                    begin
                       lprint(32);
                       if volt_esc or kilepett then exit;
                    end;

                If (Lehet_prop and Prop_on and (mode > 0)) then
                  Begin
                    Prop_Sort_Nyom (Betuk_Szama);
                    If volt_esc or  kilepett then Exit;
                  End
                Else
                For Kik := 0 To Betuk_Szama-1 Do
                  Begin
                    egy_kart_nyom (kik);
                    If volt_esc or  kilepett then exit;
                  End;
             end;
          end;

      if igaz_alahuz then igaz_alahuz_ki;
      cr_lf;        {abszolut pozicionalas felsor}
End;

{=============================================================}
{ procedure lasernyom(mode) }

Begin
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}
  ChrPerLine   := C78;
  If Enabled[5] Then
  Begin
    kilepett  := false;
    nyomohiba := false;
    prop_on   := false;
    lehet_prop:= false;

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



    fsize    := $158 + ((byte('~')-byte(' ')) * (Xbytes * YPIX));
    CharSize := Xbytes * YPIX;

    if (mode > 0) and (ppar.pr_ini_d_gr <> #255#255) then
       if ((not LoadLaserFonts) and nyomohiba) then
          Begin
            error(40,'');                 {kapcsolja ki !!!}
            for i:= 1 to MaxFontNum do ChFont[i] := true;
            ESC  := true;
            exit;
          End;

    PrintMargo   := PrintMargin;
    If PrintMargo = 0 then Inc(PrintMargo);

    BOOL := CREATE_WINDOW(40,6,75,10,pr_mess8,CA[DispMode,1],Ca[DispMode,2]);

    laser_copies(LASER_nyomszam);

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

    aktfont     := 0;       {1..10 = string 1001 .. 1010}
    alahuz      := false;
    igaz_alahuz := false;
    vastag      := false;

    volt_balfelso := false;

    if ppar.pr_ini_ff_12 = '' then
     Begin
       balra := 4;
       jobbra:= 6;
       dolt_balra := balra;
       dolt_jobbra:= jobbra;
       felfele := 0;
       lefele  := 0;
     End
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
      End;

    If Condensed and (mode = 0) then
     Begin
      XPIX         := 18;
      VMOV         := 12;
      space_X      := 18;
      XPIX_st      := '18';
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
      XPIX_st      := '30';
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
                           bool     := remove_window;
                           laser_copies(1);
                           If Condensed then Cmd(#27'&k0S');     {normal}
                           exit;
                         End;
                      end; {Stopafterpage}

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

                    If Mode In [1..2] Then
                      ChooseFont(fontszam[AktFont]);


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
    laser_copies(1);
    LaserY := Y;
    If Condensed then Cmd(#27'&k0S');     {normal}

  End;
End;  { Procedure LaserNyom }
End.
