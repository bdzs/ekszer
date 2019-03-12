Unit Nyom5;      { 8/24-tÅs matrix nyomtatokhoz
                   letoltott karakterrel kirajzolt ekezet
                   ASCII betuk a nyomtato sajatjai}

(*
ppar.pr_ini        = internal fontra allas
ppar.pr_lf_5_72    = dnl fontra allas
ppar.pr_set_l_m[1] = 24, akkor 24 tus, kulonben 8 tus
ppar.pr_set_l_m[2] = 1, akkor hosszu i = IBM °, kulonben sima i
ppar.pr_set_l_m[3] = ha 2, akkor 2szer nekimegy (ne hasznald!)
ppar.pr_set_l_m[4] = ha 255, akkor lehet dolt, kulonben nem
ppar.pr_set_l_m[5] = ha 255, akkor CWI es nem kell repulni
*)

{$O+}

Interface

Uses Nyomtat,Dos,Crt,Windowm,MenuErr,
     Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

Procedure RepuloEkezet;

Implementation

Procedure RepuloEkezet;

type  st2 = string[2];
      st3 = string[3];
      st4 = string[4];
      st8 = string[8];

const vesszo      = 64;    {ezekre a chr-ekre van megtervezve az ekezetek}
      felsovesszo = 65;
      pontok      = 66;
      felsopontok = 67;
      vesszok     = 68;
      felsovesszok= 69;

const

 Ekezetes = 29;

 Dummy : Byte = Ekezetes; {String length byte}

 m_atvalt : array [0..1,1..Ekezetes] of char =

 (('!',  '@',  '#',  '$',  '^',  '&',  '*',  '(',  ')',  '_',  '0',  '-',  '+',  '=',

   '{',  '[',  '}',  ']',  ':',  ';',  '"',  #$27, '~',  '`',  '|',  '\',  '<',  '>',  '/'),

  ('0',  '"',  '+',  '!',  '/',  '=',  '(',  ')',  #168, #174, #167, #173, #166, #165,

   #170, #169, #172, #171, #163, #162, #161, #160, #177, #164, #176, #175, ';',  ':',  '-'));


  font_8 : string[11] = '_+|uiojknm,';
  ibm_kar: string[11] = 'ƒ≈≥⁄¬ø√¥¿¡Ÿ';


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
    tu8          : boolean;     {true= 8 tu, false = 24 tu}
    ketszernekimegy : boolean;  {csak ott, ahol nincs NLQ}
    kishosszu_i     : boolean;  {true = kell ekezet i-re}
    lehetDolt       : boolean;  {ha false, akkor marad allo}
    cwi             : boolean;  {ha true, akkor nem kell kulon ekezet}

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

procedure Dolt_be;

begin
 if lehetDolt then
 begin
   {$ifdef STARPARAG}
   cmd (#28'4');
   {$else}
   cmd (#27'4');
   {$endif}
   dolt := true;
 end;
end;

procedure Dolt_ki;

begin
 if lehetDolt then
 begin
   {$ifdef STARPARAG}
   cmd (#28'5');
   {$else}
   cmd (#27'5');
   {$endif}
   dolt := false;
 end;
end;

Procedure  RestoreNoAttrib;          {vastag stb. kikapcsol}

Begin
  dolt_ki;
  alahuz_ki;
  vastag_ki;
End;

Procedure DownLoadON;

Var t: word;

Begin
  cmd(ppar.pr_lf_5_72)
End;

Procedure DownLoadOFF;

Var t: word;

Begin
 cmd(ppar.pr_ini);

End;

{--------------------------------------------------------------------}
Procedure Cr_Lf1_216;
Begin
   Lprint(13);               if kilepett then exit;
   cmd(#27'J'#1);
End;

Procedure Cr_Lf14_216;
Begin
   Lprint(13);               if kilepett then exit;
   cmd(#27'J'#14);
End;

Procedure Cr_Lf15_216;
Begin
   Lprint(13);               if kilepett then exit;
   cmd(#27'J'#15);
End;

Procedure Cr_Lf15_180;

Begin
   Lprint(13);               if kilepett then exit;
   cmd(#27'J'#15);
End;

{---------------------------------------------------------------------}

Procedure EkezetPrint(tol: integer);

Var kik,att : byte;

Begin
  DownLoadON;
  if kilepett then exit;
  if alahuz then alahuz_ki;
  if tu8 then                   {if 8 tu}
   Begin
    if ketszernekimegy then
     begin
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

         lprint (EkezetSor[kik]);
         if volt_esc or kilepett then exit;
       end;
      cr_lf1_216;                        {uj sor picit lejebb}
      if volt_esc or kilepett then exit;
      if Tol = 0 then balmargo;
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

         lprint (EkezetSor[kik]);
         if  volt_esc or kilepett then exit;
       end;
      cr_lf14_216;
      if kilepett then exit;
     end
    else
     begin
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

         lprint (EkezetSor[kik]);
         if  volt_esc or kilepett then exit;
       end;
      cr_lf15_216;                        {felsort le}
      if kilepett then exit;
     end
   End

  else                          {if 24 tu}
   Begin
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

       lprint (EkezetSor[kik]);
       if  volt_esc or kilepett then exit;
     end;
    cr_lf15_180;
    if kilepett then exit;
   End;

End;

{---------------------------------------------------------------------}
procedure AsciiPrint(Tol : integer);

var kik   : word;
    att,kar : byte;

Begin
  if Tol = 0 then balmargo;
  if volt_esc or kilepett then exit;
  DownLoadOFF;                      {nyomtato sajat fontot bekapcsol}
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
         if NOT(AlahuzottE(Att)) And alahuz then alahuz_ki;

      {$ifdef SZAMVEVO}
      if kar = 254 then cmd(#27+'6'+#27+'t0'+#144+#27+'t1') else
       if kar in [201..220] then
        begin
          lprint(byte(IBM_kar[kar-200]));
        end
      else
      {$endif}
      {$ifdef STARPARAG}
      if kar =254 then cmd(#27'^'#21) else
      {$endif}

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

     kar := (image[LastLine]^.chars[kik+c80]);
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
         if MagyarE(att) then
           Begin
             T := Pos(kar,Sst);
             If T > 0 Then Kar := m_atvalt[1,t];
           End
         else
         if (kar ='&') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
              begin
                kar := #254;   { download paragrafus }
                att := 1;
              end
         else
         If GrafE(att) then
            Begin
              T := Pos(kar,Font_8);     {dobozrajzolo}
              If T >0 Then
                Kar := chr(t + 200);   { 201 = Ibm_kar[1] ... }
                att := 1;
            End
         else  kar := ppar.pr_joker;       {nem irhato}
       end;

     If kar > #159 then                     {magyar ekezetes}

       begin
         VoltEkezetes := true;
         case byte(kar) of
           160 : if cwi then kar := '†'
                 else
                  begin                     {†}
                   kar := 'a';
                   EkezetSor[kik] := vesszo;
                  end;
           161 : if cwi then kar := 'è'
                 else
                  begin                     {è}
                   kar := 'A';
                   EkezetSor[kik] := felsovesszo;
                  end;
           162 : if cwi then kar := 'Ç'
                 else
                  begin                     {Ç}
                   kar := 'e';
                   EkezetSor[kik] := vesszo;
                  end;
           163 : if cwi then kar := 'ê'
                 else
                  begin                     {ê}
                   kar := 'E';
                   EkezetSor[kik] := felsovesszo;
                  end;
           164 : if cwi then kar := '°'
                 else
                  begin                     {°}
                   kar := 'i';
                   if kishosszu_i then
                       kar := '°';
                  end;
           165 : if cwi then kar := '¢'
                 else
                  begin                     {¢}
                   kar := 'o';
                   EkezetSor[kik] := vesszo;
                  end;
           166 : if cwi then kar := 'ï'
                 else
                  begin                     {ï}
                   kar := 'O';
                   EkezetSor[kik] := felsovesszo;
                  end;
           167 : if cwi then kar := 'î'
                 else
                  begin                     {î}
                   kar := 'o';
                   EkezetSor[kik] := pontok;
                  end;
           168 : if cwi then kar := 'ô'
                 else
                  begin                     {ô}
                   kar := 'O';
                   EkezetSor[kik] := felsopontok;
                  end;
           169 : if cwi then kar := 'ì'
                 else
                  begin                     {ì}
                   kar := 'o';
                   EkezetSor[kik] := vesszok;
                  end;
           170 : if cwi then kar := 'ß'
                 else
                  begin                     {ß}
                   kar := 'O';
                   EkezetSor[kik] := felsovesszok;
                  end;
           171 : if cwi then kar := '£'
                 else
                  begin                     {£}
                   kar := 'u';
                   EkezetSor[kik] := vesszo;
                  end;
           172 : if cwi then kar := 'ó'
                 else
                  begin                     {ó}
                   kar := 'U';
                   EkezetSor[kik] := felsovesszo;
                  end;
           173 : if cwi then kar := 'Å'
                 else
                  begin                     {Å}
                   kar := 'u';
                   EkezetSor[kik] := pontok;
                  end;
           174 : if cwi then kar := 'ö'
                 else
                  begin                     {ö}
                   kar := 'U';
                   EkezetSor[kik] := felsopontok;
                  end;
           175 : if cwi then kar := 'ñ'
                 else
                  begin                     {ñ}
                   kar := 'u';
                   EkezetSor[kik] := vesszok;
                  end;
           176 : if cwi then kar := 'ò'
                 else
                  begin                     {ò}
                   kar := 'U';
                   EkezetSor[kik] := felsovesszok;
                  end;
           177 : if cwi then kar := 'ç'
                 else
                  begin                     {ç}
                   kar := 'I';
                   EkezetSor[kik] := felsovesszo;
                  end;
         end;                  {case}
       end;

     AsciiSor[kik] := byte(kar);

   end;
End;

{---------------------------------------------------------------------}

Procedure EkezetnyitLe;
Begin
   If tu8 then
    cr_lf15_216
   else cr_lf15_180;
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
      If cwi then EkezetnyitLe
      else
       begin
        If VoltEkezetes then EkezetPrint(Tol) else EkezetnyitLe;
       end;
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
   cmd(ppar.pr_ini_ff_12);
   if not CWI then
    cmd(#27':'#0#0#0)           {copy ROM to RAM}
   else cmd(#27'6');            {enable 128..160}
End;


Procedure DownLoadEkezetek;

Var  f: file of byte;
     b: byte;
     hossz : word;
     fnev  : string[16];
     fsize : word;
     t, egykar, karbyte: word;

Begin
  CheckRead(PathSt);
  fnev := ppar.pr_egyeb;
  if tu8 then
   begin
    fsize   := 6 * 11;
    karbyte := 11;
   end
  else
   begin
    fsize   := 6 * 24*3;
    karbyte := 24*3;
   end;

  assign(f, PathSt+fnev);
  {$i-}
  reset(f);
  if ioresult <> 0 then
   begin
    error(1,fnev);
    esc := true;
    exit;
   end;
  if fsize <> filesize(f) then
   begin
    error(1,fnev);                {ROSSZ FILE!!!!!}
    esc := true;
    exit;
   end;

  for egykar := vesszo to felsovesszok do
   begin
     If tu8 then
        cmd(#27'&'#0+chr(egykar)+chr(egykar)+#139)   {8 tu fejlec}
     Else                                            {24 tu}
        cmd(#27'&'#0+chr(egykar)+chr(egykar)+
            #006 + #024 + #006 );                    {24 pix szeles}
     for t:= 1 to karbyte do
       begin
        read(f,b);
        if ioresult <> 0 then
         begin
          error(1,fnev);                    {OLVASASI HIBA}
          esc := true;
          exit;
         end;
        lprint(b);
        if kilepett then
         begin
          esc := true;
          exit;
         end;
       end;
   end;

  close(f);
End;

{=====================  MAIN ====================================}
{procedure RepuloEkezet}

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

  tu8             := byte(ppar.pr_set_l_m[1]) <> 24;
  kishosszu_i     := byte(ppar.pr_set_l_m[2]) = 1;
  ketszernekimegy := byte(ppar.pr_set_l_m[3]) = 2;
  lehetDolt       := byte(ppar.pr_set_l_m[4]) = 255;
  cwi             := byte(ppar.pr_set_l_m[5]) = 255;

  if not cwi then
   begin
     DownLoadEkezetek;
     If kilepett then exit;
   end;

  {$ifdef STARPARAG}
  cmd(#27'x1'); {NLQ Courier}
  {$endif}

  BOOL := CREATE_WINDOW(40,6,75,10,pr_mess8,CA[DispMode,1],Ca[DispMode,2]);
  GotoXY(3,2);
  writeln (pr_mess9);


  if Condensed
   then lprint(15)
   else lprint(18);

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
          if tu8 then Assign(f,fontpath+BackSlash+PicNames[1])
                 else Assign(f,fontpath+BackSlash+PicNames[2]);
          Reset(f);
          EmbSor := 4;
          Tol    := 4;
        end;

       If Embsor > 0 then
        begin
         BalMargo;
         if tu8 then
         begin
           cmd(#27+'Z'+chr(48*2)+chr(0));
           for cikl := 1 to 48*2 do
             begin
              read(f,byt);
              lprint(byt);
             end;
           end
         else
         begin
           cmd(#27+'*'+chr(39)+chr(72)+chr(0));
           for cikl := 1 to 72 do
             begin
              read(f,byt);
              lprint(byt);
              read(f,byt);
              lprint(byt);
              lprint(0);
             end;
         end;

         for cikl := 0 to 3 do  image[LastLine]^.chars[cikl+c80] := ' ';
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
      If tu8 then
        Begin
          Kell       := round(LabelDist * 216);
          Volt       := Felsorok  * 15;
          while Volt > Kell do inc(kell,kell);     {kovetkezo cimke elejere}
          KellMeg    := Kell - Volt;
          while (KellMeg > 216) do        {teljes inch-eket kiad}
            begin
              cmd(#27+'J'+chr(216)+ #13); {one time lf of x/216}
              dec(KellMeg,216);           {csokkent}
              if kilepett then
                  Begin
                    bool := Remove_window;
                    Esc  := True;
                    Exit;
                  End;
            end;
          if KellMeg > 0 then
           cmd(#27+'J'+chr(KellMeg)+ #13); {one time lf of x/216}
        End
      Else                                            {24 tus!!!}
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
        End
     End;

  RestoreNoAttrib;          {vastag stb. kikapcsol}
  Bool := Remove_window;

End;  { Procedure RepuloEkezet}
End.
