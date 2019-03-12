Unit Nyom0;      { 8-tÅs matrix nyomtatokhoz }
{$O+}

Interface

Uses Nyomtat,Dos,Crt,Windowm,Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

procedure Matrix(ny_modus: word; var mkm: dnloadtomb);
Procedure Tuk_Mat(nekifutas,x,y,ch,fontoff,sortaboff,imageofs : WORD);


Implementation


{$L Tuk_mat}
Procedure Tuk_Mat; External;

Procedure Matrix(ny_modus: word; var mkm: dnloadtomb);

type  st2 = string[2];
      st3 = string[3];

const

 or_tomb_max =  MaxMaxChars*24; {78 * 24}

 Ekezetes = 29;

 Dummy : Byte = Ekezetes; {String length byte}

 m_atvalt : array [0..1,1..Ekezetes] of char =

 (('!',  '@',  '#',  '$',  '^',  '&',  '*',  '(',  ')',  '_',  '0',  '-',  '+',  '=',

   '{',  '[',  '}',  ']',  ':',  ';',  '"',  #$27, '~',  '`',  '|',  '\',  '<',  '>',  '/'),

  ('0',  '"',  '+',  '!',  '/',  '=',  '(',  ')',  #168, #174, #167, #173, #166, #165,

   #170, #169, #172, #171, #163, #162, #161, #160, #177, #164, #176, #175, ';',  ':',  '-'));

Var  Sst : String[29] absolute Dummy;

var  elozo_sor_ures      : boolean;
     elozo_sor_hossza    : integer;
     nekifutas        : byte;
     or_tomb          : array [0..or_tomb_max] of byte;
     or_tomb_mutato   : integer;

     i,j,k         : integer;
     c             : char;
     lap_vege      : boolean;

    tuk : array [0..24] of byte;          {elso 12 most kell, masodik
                                           12 a kovetkezo nekifutasnal}
    tukoff, tukseg : integer;
    elozo_sor      : array [0..MaxMaxChars] of char;
    betuk_szama    : integer;
    volt_gr_ini    : boolean;

    alahuz, vastag : boolean;

    kilepett    : boolean; {nyomtatas kozben ESC, vagy rossz printer}
    nyomas_vege : boolean;

    megtervezettek : string[32];

    y           : integer;
    volt_lapdob : boolean;
    szo         : st2;

    felsorok    : word;
    Kell,EzKell, Volt, KellMeg : word;

    lapveg : boolean;

    Tol,Ig    : word;


    {$IFDEF LICENC}
    EmbSor : integer;
         f : file of byte;
       byt : byte;
      cikl : word;
    Spacek : word;
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

{$IFDEF LICENC}
procedure lprint1(c: byte);
{$ELSE}
procedure lprint (c: byte);       {kilepett lesz, ha nem megy ki!!!}
                                  {es [A]bort }
{$ENDIF}

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
           kilepett := true;
      end;

  until (pr_ok or kilepett);
end;


{$IFDEF LICENC}
Procedure LPRINT(c : byte);

var cik : word;

begin
  if NYmodus <> 0 then Lprint1(c)
  else
   begin
     if (random(5)<>4) or (c <> 32)  then
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
            Lprint1(Byte('Z'));
            Lprint1(48*2);
            Lprint1(0);
            for cik := 1 to 48*2 do
               Lprint1(00);
            Spacek := 0
          end;
       end;
   end;
end;
{$ENDIF}

{---------------------------}
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
VAr hur : Integer;
Begin
  for hur := 1 to PrintMargin do
    begin
      lprint(32);
      if kilepett then exit;
    end;
End;

{---------------------------}
procedure ini_printer;

Begin
   if not Korlevelben then
   with ppar do
   begin
      cmd (pr_ini);        {altalanos ini}           if kilepett then exit;
      cmd (pr_ini_ff_12);  {12 inch paper lemgth}    if kilepett then exit;
      cmd (pr_lf_5_72);    {5/72 LF}
    end;
End;

{-------------------------------------------------------------}
procedure ini_download;     { gyors nyomashoz ROM-> RAM
                              es choose RAM }
Begin
   with ppar do
   cmd (pr_IniDownload);
End;
{-----------------------------------------------------------}
procedure egyet_tervez (ezt, erre: byte);   {ezt + 64.-ikat attervezi
                                             erre-re a karmatrixok alapjan}
var i,j: byte;                              {erre = 0..31 nagybetu}
                                            {32..50 magyar betuk}
Begin
 with ppar do
 begin
   cmd (pr_EgyetTervez);                       if kilepett then exit;
   for i:= 1 to pr_KarNumNum do
     begin
       lprint (ezt+64);
       if kilepett then exit;
     end;
   cmd (pr_KarNumUtan);                        if kilepett then exit;
   for j:= 0 to 8 do
     begin
       lprint (mkm[erre*9 +j]);
       if kilepett then exit;
     end;
   lprint (0);                                 if kilepett then exit;
   lprint (0);
  end;
End;
{-----------------------------------------------------------}
function atcsinal_ha_kell(kar: char): char;

    var  t,k: byte;
        utso: byte;
          cc: char;

begin
    atcsinal_ha_kell:= kar;
    if ((kar in ['@'..'_']) or  (kar in [#160..#177])) then
    begin
           T := Pos(kar, megtervezettek);    {mar meg lett tervezve?}
           If T > 0
           Then
              Begin
                 atcsinal_ha_kell := chr(T + 64 - 1);         {igen}
              End
           Else
              Begin
                   utso := length(megtervezettek);
                   If utso = 32
                   Then
                    Begin
                       atcsinal_ha_kell := ppar.pr_joker;  {nincs hely tobbnek}
                    End
                   Else
                    Begin
                        megtervezettek := megtervezettek + kar;
                        k := byte(kar);
                        Dec(k,64) ;              {64  -> 0..31}
                        if k>31 then Dec(k,64);  {160 -> 32.. }
                        egyet_tervez(utso,k);
                        atcsinal_ha_kell := chr(utso + 64);
                    End;
              end;
    end;
end;
{----------------------------------}
procedure ini_gr_sor(hossz: integer);

var    k : integer;
     i,j : byte;
       t : byte;
Begin

  k := hossz * 12  ;  {ennyi pont lesz}
  i := k mod 256   ;  { lsb }
  j := k div 256   ;  { msb }

  cmd (ppar.pr_ini_d_gr);         if kilepett then exit;
  Lprint(I);                      if kilepett then exit;
  Lprint(J);

End;
{-------------------------------------------------------------------}

procedure cr_1_216_lf ;   {sor elejere visszaall es 1/216-os emelest csinal}

Begin
  Lprint(13);                      if kilepett then exit;
  with ppar do
     cmd (pr_lf_1_216);
End;

{-------------------------------------------------------------------}
procedure cr_14_216_lf ;   {sor elejere visszaall es 14/216-os emelest csinal}

Begin
  Lprint(13);                     if kilepett then exit;
  with ppar do
      cmd (pr_lf_14_216);
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

Procedure Cr_Lf;

Begin
   Lprint(13);               if kilepett then exit;
   Lprint(10);
End;
{-------------------------------------------------------------------}
Procedure TXT_nyom (kar: char; att: byte);

Var T:byte;

Begin

 {$IFNDEF angol}                         { magyar }

   if not ppar.pr_download then          {ha nem tervezheto}
     begin
       if (kar <> ' ') then
         if not AngolE(att) then
            kar := ppar.pr_joker;
       lprint (byte(kar));
     end

   else                                  {ha DownLoad}
    Begin
      If kar <> ' ' then
       Begin

         If not AngolE(att) then
           begin
              if MagyarE(att) then
                Begin
                  T := Pos(kar,Sst);
                  If T > 0 Then Kar := m_atvalt[1,t];
                End
              else  kar := ppar.pr_joker;   {nem irhato}
           end;                             {if not angol}

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

       End                               {If kar <> ' '}

      Else
        if Not(AlahuzottE(att)) And alahuz then alahuz_ki;     {if kar = ' '}

      AlahuzottSpaceCsere(Kar,Att);

      kar := atcsinal_ha_kell(kar);
      lprint (byte(kar));                {kiadja magat a karaktert is}

    End;       {else: if download}

{$ELSE}                                    {angol}

    if  ((kar <> ' ') and (not AngolE(att)))
        then kar := ppar.pr_joker
    else
     Begin
      If kar <> ' ' then
       Begin

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

       End                               {If kar <> ' '}

      Else if alahuz then alahuz_ki;     {if kar = ' '}

     End;

    AlahuzottSpaceCsere(Kar,Att);

    lprint(byte(kar));                {karakter kimegy }

  {$ENDIF}

End;

{-------------------------------------------------------------------------}
procedure egy_kart_nyom (kik: integer);  {39. image sor kik.-ik karakteret}

var kar : char;
    att : byte;
    t   : byte;
    c   : byte;
    Fele,
    Att2: Byte;

Begin

   kar :=  Image[LastLine]^.chars[C80+kik];
   if (kar < ' ') or (kar > #127) then kar := ' ';
   att :=  Image[LastLine]^.attribs[kik];
   If Att > 16 Then Att := Att And 15;
   if att < 1 then att := 1;

   if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
        begin
          kar := ' ';   { kemeny osszekoto space !!!}
          att := 1;
        end;

   case ny_modus of

   0:  txt_nyom (kar,att);

   1: Begin                               {1-es grafikus}

            if not volt_gr_ini and (kar = ' ') and (elozo_sor[kik] = ' ')
              then
                begin
                  lprint(32);
                  if kilepett then exit;
                end

            else
            begin
                 if not volt_gr_ini then
                                    begin
                                     ini_gr_sor(betuk_szama-kik);
                                     if kilepett then exit;
                                     volt_gr_ini := true;
                                    end;

                 tuk_mat (0,byte(kar),att,pfontoff[0],pfontseg[0],tukoff,tukseg);
                                            {toltse fel a matrixot}
                 for t:= 0 to 11 do
                 Begin
                     c := tuk[t] OR or_tomb [or_tomb_mutato+t];
                     or_tomb [or_tomb_mutato+t] := tuk [12+t];
                     lprint(c);
                     if kilepett then exit;
                 End;

            end; {if kar = space and elozo_sor[kik] = space}

                 Inc(or_tomb_mutato,12);
                 elozo_sor[kik] := kar;

      End;   {case 1:graf}

   2: Begin                                {2-es grafikus}
          case nekifutas of

          1: Begin                            {elso nekifutas}
              if not volt_gr_ini and (kar = ' ') and (elozo_sor[kik] = ' ')
                then
                 begin
                  lprint(32);
                  if kilepett then exit;
                 end
              else
                begin
                 if not volt_gr_ini then
                    begin
                      volt_gr_ini := true;
                      ini_gr_sor (betuk_szama - kik);
                      if kilepett then exit;
                    end;


                 Fele := att DIV (FirstNLQ+1);
                 ATT2 := att MOD (FirstNLQ+1)+Fele;

                 tuk_mat (1,byte(kar),att2,pfontoff[Fele],
                                           pfontseg[Fele],
                                           tukoff,
                                           tukseg);
                                            {toltse fel a matrixot}
                 for t:= 0 to 11 do
                   Begin
                     c := tuk[t] OR or_tomb [or_tomb_mutato+t];
                     or_tomb [or_tomb_mutato+t] := tuk [12+t];
                     lprint (c);
                     if kilepett then exit;
                   End;
                end;

              Inc(or_tomb_mutato,24);
              {elozo_sor[kik] := kar;}

             End; { 1. nekifutas}

         2:  Begin                            {masodik nekifutas}
              if not volt_gr_ini and (kar = ' ') and (elozo_sor[kik] = ' ')
                 then
                   begin
                     lprint(32);
                     if kilepett then exit;
                   end
              else
               begin
                 if not volt_gr_ini then
                    begin
                      volt_gr_ini := true;
                      ini_gr_sor (betuk_szama - kik);
                      if kilepett then exit;
                    end;

                 Fele := att DIV (FirstNLQ+1);
                 ATT2 := att MOD (FirstNLQ+1)+Fele;

                 tuk_mat (2,byte(kar),att2,pfontoff[Fele],
                                           pfontseg[Fele],
                                           tukoff,
                                           tukseg);

                                            {toltse fel a matrixot}
                 for t:= 0 to 11 do
                   Begin
                      c := tuk[t] OR or_tomb [or_tomb_mutato+t];
                      or_tomb [or_tomb_mutato+t] := tuk [12+t];
                      lprint (c);
                      if kilepett then exit;
                   End;
               end;

               Inc(or_tomb_mutato,24);
               elozo_sor[kik] := kar;

             End;  { 2. nekifutas }
          End; {case nekifutas}

         End;   {case 2:graf}

   End; {case ny_modus}


End;        {egy kar-t kinyom}

{-------------------------------------------------------------------}

procedure or_tomb_nyom (hossz : integer);  {kinyomja az OR_TOMB-ot, es
                                            nullazza azt}
var t,i                  : integer;
    kezdo_pos, kimegy_db : integer;
                      ch : char;
                       c : byte;
Begin

case ny_modus of

1: Begin
      {elozo sor space-jeit text-ben}
      i := 0;
         while ((elozo_sor[i] = ' ') and (i< hossz-1))  do
         begin
           lprint(32);
           inc (i);
           if kilepett then exit;
         end;

      kezdo_pos := i * 12;
      kimegy_db := hossz - i;

      ini_gr_sor(kimegy_db);     if kilepett then exit;

      for t:= kezdo_pos to (kezdo_pos + 12 * kimegy_db) -1  do
      begin
              c := or_tomb[t];
              lprint (c);
              if kilepett then exit;
      end;

      fillchar(or_tomb, or_tomb_max+1, #0);
      fillchar(elozo_sor, C78,#32);
      {elozo felsor ures}

      or_tomb_mutato := 0;

   End;

2:   case nekifutas of

     1:  Begin
         {elozo sor space-jeit text-ben}
         i := 0;
              while ((elozo_sor[i] = ' ') and (i< hossz-1))  do
              begin
                 lprint(32);
                 inc (i);
                 if kilepett then exit;
              end;

         kimegy_db := hossz - i;
         ini_gr_sor(kimegy_db);        if kilepett then exit;

          for t:= i to (hossz - 1)  do
           for i:= 0 to 11 do
            begin
              c := or_tomb[24*t+i];
              lprint (c);
              if kilepett then exit;
            end;

         End;

     2:  Begin
                                   {elozo sor space-jeit text-ben}
         i := 0;
              while ((elozo_sor[i] = ' ') and (i< hossz-1))  do
              begin
                lprint(32);
                inc (i);
                if kilepett then exit;
              end;

         kimegy_db := hossz - i;
         ini_gr_sor(kimegy_db);       if kilepett then exit;

          for t:= i to (hossz - 1)  do
             for i:= 0 to 11 do
              begin
                  c := or_tomb[24*t+i+12];
                  lprint (c);
                  if kilepett then exit;
              end;

          fillchar(or_tomb, or_tomb_max+1, #0);
          fillchar(elozo_sor, C78,#32);
                                             {elozo felsor ures}
          or_tomb_mutato := 0;

         End;
      End;
 End;

End;

{-------------------------------------------------------------------}
procedure egy_sort_nyom(tol : word);   {37. image sorban van}


var kik          : integer;    {kiirando karakter sorszama}
    van_valami   : boolean;
    ch           : char;

Var e_sor_hossza : integer;

Begin
       volt_gr_ini     := false;
       or_tomb_mutato  := 0;
       megtervezettek  := '';

       betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }
       if betuk_szama + PrintMargin > C80 then
          betuk_szama := C80 - PrintMargin;     {max. 77 szeles }

       e_sor_hossza := betuk_szama;
       Van_Valami   := (E_sor_hossza <> 0);

       If van_valami
       {$IFDEF licenc}
       or (EmbSor > 0)
       {$ENDIF}
       Then
          Begin

                If ny_modus > 0 Then
                  Begin
                    if elozo_sor_hossza > betuk_szama then
                       betuk_szama := elozo_sor_hossza;
                    nekifutas := 1;
                  End;

                if volt_esc then exit;
                if Tol = 0 then BalMargo;
                Ig := Betuk_Szama-1;
                {$IFDEF Licenc}
                If (Embsor > 0) and (EmblemaXPos > 0) and (NyModus = 0)
                 then Ig := EmblemaXpos - 1;
                {$ENDIF}

                if kilepett then exit;
                For Kik := Tol To Ig Do
                  begin
                    egy_kart_nyom (kik);
                    if kilepett then exit;
                  end;

                If ny_modus = 2 Then
                  Begin
                    or_tomb_mutato := 12;
                    cr_1_216_lf;        {1/216}
                    if Volt_ESC or kilepett then exit;
                    volt_gr_ini := false;
                    nekifutas   := 2;
                    BalMargo;
                    if kilepett then exit;
                    For Kik := 0 To Betuk_Szama-1 Do
                      begin
                        egy_kart_nyom (kik);
                        if kilepett then exit;
                      end;
                  End;

                {cr lf}
                if ny_modus = 2 then
                   begin
                     cr_14_216_lf;
                     if kilepett then exit;
                   end
                else
                   begin
                     {$IFNDEF licenc}
                     cr_lf;
                     {$ELSE}
                     if (Embsor = 0) or (NyModus = 1) or (EmblemaXPos = 0)
                       then cr_lf;      {nincs kep vagy grafikus}
                     {$ENDIF}
                     if Volt_ESC or kilepett then exit;
                   end;

                elozo_sor_ures    := false;
                elozo_sor_hossza  := e_sor_hossza;

          End

       else    {nincs valami}
       Begin
        If ny_modus > 0 Then  {ures sor grafikusan}
          Begin
          {grafikusnal ha az elozoben volt valami, akkor annak az aljat}

           If not elozo_sor_ures then
             Begin
                nekifutas := 1;
                if Volt_ESC  then exit;
                BalMargo;
                if kilepett then exit;
                or_tomb_nyom (elozo_sor_hossza);   {lelogo reszek}
                if kilepett then exit;

                If ny_modus = 2 Then
                  Begin
                    cr_1_216_lf;
                    nekifutas := 2;
                    if Volt_ESC  or kilepett then exit;
                    BalMargo;
                    if kilepett then exit;
                    or_tomb_nyom (elozo_sor_hossza);   {lelogo reszek}
                    if kilepett then exit;
                  End;

                {cr lf}
                if ny_modus = 2 then cr_14_216_lf
                                else cr_lf;
                if kilepett then exit;

             End            {if elozo sor not ures}
             Else           {ha az elozo ures es grasfikus akkor}
               begin
                 cr_lf;
                 if Volt_ESC or kilepett then exit;
               end;

          End     {if ny_modus > 0}
        Else      {text modus uj sor}
          begin
            cr_lf;
            if Volt_ESC or kilepett then exit;
          end;

        elozo_sor_hossza  := 0;
        elozo_sor_ures    := true;

       End;        {nincs valami}
End;

{=====================  MAIN ====================================}
{procedure matrix (ny_modus: integer) }

Begin
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}

  {$IFDEF LICENC}
  EmbSor := 0;
  Spacek := 0;
  {$ENDIF}

  kilepett    := false;

  If Ny_Modus > 0 Then
  Begin
    fillchar(or_tomb, or_tomb_max+1, #0);
    fillchar(elozo_sor, C77, #32);
    or_tomb_mutato := 0;
  End;

  BOOL := CREATE_WINDOW(40,6,75,10,pr_mess8,CA[DispMode,1],Ca[DispMode,2]);
  GotoXY(3,2);
  writeln (pr_mess9);

  elozo_sor_ures      := true;   {nem volt elozo sor}
  elozo_sor_hossza    := 0;

  lap_vege := false;        {nem a lap alja}
  volt_lapdob := false;

  ini_printer;

  If ny_modus = 0  then           { text mode printing }
    begin
      If ppar.pr_download then
        begin
            ini_download;
            megtervezettek := '';
        end;
      alahuz := false;
      vastag := false;
    end
  Else                            { grafikus nyomtatas }
    begin
      tukoff := ofs(tuk);         {tuk matrix cime}
      tukseg := seg(tuk);
    end;


  if Condensed and (Ny_modus = 0)
   then lprint(15)
   else lprint(18);

  {-------------------- inicializalas vege: main loop ------------}
  felsorok := 0;
  tol      := 0;

  while  Van_Sor  do
         Begin
            nekifutas := 0;
            lapveg    := (Image[LastLine]^.attribs[0] and LapVege)  = LapVege;

            {$IFDEF LICENC}
            If Emblema and (NYmodus = 0) then
             begin
               Emblema := false;
               Assign(f,fontpath+BackSlash+PicNames[1]);
               Reset(f);
               EmbSor := 4;
               If EmblemaXPos = 0 then
                 Tol    := 4
               Else Tol := 0;
             end;

            If (Embsor > 0) and (EmblemaXPos = 0) then
             begin
              BalMargo;
              cmd(#27+'Z'+chr(48*2)+chr(0));
              for cikl := 1 to 48*2 do
                begin
                 read(f,byt);
                 lprint1(byt);
                end;
              for cikl := 0 to 3 do image[LastLine]^.chars[C80+cikl] := ' ';

              dec(EmbSor);
              If EmbSor = 0 then Close(f);
             end;
            {$ENDIF}

            egy_sort_nyom(tol);


            {$IFDEF Licenc}
            If EmbSor = 0 then Tol := 0;

            If (Embsor > 0) and (EmblemaXPos > 0) then
             begin
              cmd(#27+'Z'+chr(48*2)+chr(0));
              for cikl := 1 to 48*2 do
                begin
                 read(f,byt);
                 lprint1(byt);
                end;

              cr_lf;
            
              dec(EmbSor);
              If EmbSor = 0 then Close(f);

             end;

            {$ENDIF}

            inc(felsorok);

            if kilepett then
              Begin
                esc := true;
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

  {  Ha nincs sor  }
     If  ((elozo_sor_hossza <> 0) and (ny_modus > 0))  Then
          Begin
            nekifutas := 1;
            balmargo;
            or_tomb_nyom (elozo_sor_hossza);   {lelogo reszek}
            if ny_modus = 2 then
              Begin
                nekifutas := 2;
                cr_1_216_lf;
                balmargo;
                or_tomb_nyom (elozo_sor_hossza);
                cr_14_216_lf;
              End
            else cr_lf;

            inc(felsorok);
          End;

     If (LabelDist >= 0.01) and not KellLapdob then  {cimke tovabbitas}
        Begin
          Kell       := round(LabelDist * 216);
          EzKell     := Kell;
          Volt       := Felsorok  * 15;
          while Volt > Kell do inc(kell,Ezkell);     {kovetkezo cimke elejere}
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
        End;

  Bool := Remove_window;

End;  { Procedure Nyomtat }
End.
