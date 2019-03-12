Unit Nyom4;      { 8-tus matrix nyomtatokhoz 30-tus modus }
{$O+}            { 24 pont szeles karakterek }

Interface

Uses Nyomtat,Dos,Crt,Windowm,Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

procedure LQ30TU( Var KarTomb   :KarMut;
                  Var FontKezdet:FontPoint);

Implementation


procedure make6run (ebbol: pointer; ebbe: pointer; oszlopok : word; vanalja: boolean); external;
{$L make6run.obj}

procedure LQ30TU ( Var KarTomb:KarMut;
                   Var FontKezdet:FontPoint);

type  st2 = string[2];
      st3 = string[3];

      or_tomb = array[0..24*MaxMaxChars] of byte; {max grafikus szelesseg}
      or_tomb_array =  array[0..2] of or_tomb;

const

 Kszel = 24;  {egy karakter szelessege}

var  elozo_sor_ures      : boolean;
     i,j,k               : integer;
     c                   : char;
     lap_vege            : boolean;
     e_sor_hossza        : word;
     elozo_sor_hossza    : word;
     betuk_szama         : integer;

    kilepett       : boolean; {nyomtatas kozben ESC, vagy rossz printer}
    nyomas_vege    : boolean;

    y           : integer;
    volt_lapdob : boolean;
    szo         : st2;

    Kpoint      : word;

    or_tombok    : or_tomb_array;   {elozo matrixsor also 3 * 5 pix sorai}
    ez_or_tombok : or_tomb_array;    {e matrixsor also 3 * 5 pix sorai}

    fo_tombok   : array[1..2] of or_tomb;    {a felso resz 2.,3. nekifutasa}

    abspos      : integer;                   {or_tomb mutato}
    utso_alja   : integer;
    elso_alja   : integer;
    elozo_elso_alja : integer;
    volt_gr_ini : boolean;
    nezett_elsot: boolean;

    ures_sorok : word;
    ny_modus : byte;

    felsorok    : word;
    Kell,EzKell, Volt, KellMeg : word;
    LapVeg      : boolean;
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

procedure lprint (c: byte);       {kilepett lesz, ha nem megy ki!!!}
                                  {es [A]bort }
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
        if cb in [KilepChar,#27] then kilepett := true;
      end;

  until (pr_ok or kilepett);

end;

{---------------------------------------------------}
procedure cmd (parancs: st16);

var i: byte;

begin

  for i:= 1 to length(parancs) do
   begin
    lprint(byte(parancs[i]));
    if kilepett then exit;
   end;
end;
{---------------------------}

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
      cmd (pr_ini);        {altalanos ini}
      If NOT Kilepett Then
        cmd (pr_ini_ff_12);  {12 inch paper length}
      If NOT Kilepett Then
        cmd (pr_lf_5_72);    {ures felsor}
    end;
End;

Procedure Cr_picit_emel;

Begin
  cmd(#13#27'J'#1);
End;

Procedure Cr_4_72_Lf;

Begin
  cmd(#13#27'J'#12);
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

  cmd (#27'Z');          {double helyett quadruple !!!}

  If Not Kilepett Then
    Lprint(I);
  If Not Kilepett Then
    Lprint(J);

End;
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
   Lprint(13);   if kilepett then exit;
   Lprint(10);
End;

{-------------------------------------------------------------------}
procedure print_space (nekifutas : byte);

var t : byte;

begin
    for t:= 1 to Kszel do    {24 oszlop}
     begin
       lprint(or_tombok[nekifutas][abspos]);    if kilepett then exit;
       or_tombok[nekifutas][abspos] := 0;
       inc(abspos);
     end
end;

{-------------------------------------------------------------------}
procedure ini_grafika (hossz: integer);

var    k : integer;
     i,j : byte;
       t : byte;
Begin

  k := hossz * Kszel  ;  {ennyi pont lesz}
  i := k mod 256      ;  { lsb }
  j := k div 256      ;  { msb }

  cmd (#27'Z');        { quadruple density}

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
    ch   : char;
    mut  : word;
    konv_tomb : array[0..24*6] of byte; { 'make6run' gepi kodja ide kovertalja
                                        a karakter felso 3 es also 3 nekifutas-
                                        ban kikuldendo matrixat}

Begin

   kar :=  Image[LastLine]^.chars[C80+kik];
   if kar < ' '   then kar := ' ';

   att :=  Image[LastLine]^.attribs[kik];
   If Att > 16 Then Att := Att And 15;
   

   if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
     begin
       kar := ' ';   { kemeny osszekoto space !!!}
       att := 1;
     end;

   karn := byte(kar)-32;              {vagy 31!!!}
   cime := KarTomb[att,karn].cim;     {relativ cime }
   if cime = $FFFF then kar :=  ' ';

   if kar = ' ' then
     begin
      if volt_gr_ini then print_space (0)
      else if kik < elozo_elso_alja then
        begin
         lprint(32);    {meg szoveges}
         inc(abspos,Kszel);
        end
      else
       begin
         ini_grafika(e_sor_hossza-kik);
         if kilepett then exit;
         print_space (0);
       end;
     end

   else
     begin
       if not volt_gr_ini then ini_grafika(e_sor_hossza-kik);
       if kilepett then exit;

       van_alja   :=  (kartomb[att,karn].bevezeto and $80) <> 0;
       kezdo_ures :=  kartomb[att,karn].bevezeto and $7F;
       oszlopok   :=  kartomb[att,karn].oszlopok;
       maradek    :=  Kszel-oszlopok-kezdo_ures;

       if kezdo_ures <> 0 then
        begin
          for t:= 1 to kezdo_ures do
           begin
             lprint(or_tombok[0][abspos]);   if volt_esc or kilepett then exit;
             or_tombok[0][abspos] := 0;
             inc(abspos);
           end;
        end;

       make6run (@Fontkezdet[att]^[cime], @konv_tomb, oszlopok, van_alja);

{
       window(1,10,79,20); clrscr;
       writeln('oszl: ',oszlopok);
       writeln('lelog: ',van_alja);
       for t:= 0 to 6*oszlopok-1 do write(konv_tomb[t]:4);
       stop;
}
       mut := 0;

       for t:= 1 to oszlopok do
         begin
           lprint(konv_tomb[mut] or or_tombok[0][abspos]);
           if volt_esc or kilepett then exit;
           inc(mut);
           fo_tombok[1][abspos] := konv_tomb[mut];
           inc(mut);
           fo_tombok[2][abspos] := konv_tomb[mut];
           inc(mut);
           ez_or_tombok[0][abspos] := konv_tomb[mut];
           inc(mut);
           ez_or_tombok[1][abspos] := konv_tomb[mut];
           inc(mut);
           ez_or_tombok[2][abspos] := konv_tomb[mut];
           inc(mut);

           {egy oszlopbol mind elrakta az absposra}
           inc(abspos);
         end;

       utso_alja        := kik;
       if not nezett_elsot then
          begin
            elso_alja    := kik;
            nezett_elsot := true;
          end;

       if maradek <> 0 then
        begin
          for t:= 1 to maradek do
           begin
             lprint(or_tombok[0][abspos]);     if volt_esc or kilepett then exit;
             or_tombok[0][abspos] := 0;
             inc(abspos);
           end;
        end;
     end;
End;        {grafikus egy kar-t kinyom}

{-------------------------------------------------------------------}
procedure Or_tombnyom (eddig: integer);

var i,t     : integer;
    darab   : integer;
    nekifut : integer;
begin

  for nekifut := 0 to 2 do
  begin

    balmargo;

    if elozo_elso_alja > 0 then
     for t:= 1 to elso_alja do
       begin
         lprint(32);
         if kilepett then exit;
       end;

    darab := eddig + 1;
    ini_gr_sor(darab - elso_alja);
    if kilepett then exit;

    for t:= elso_alja*Kszel to darab*Kszel-1 do
     begin
       lprint(or_tombok[nekifut][t]);
       if volt_esc or kilepett then exit;
     end;

    Cr_picit_emel;
  end;                    {next nekifut}
end;

{-------------------------------------------------------------------}
procedure Egy_gr_sort_nyom (nekifut: byte);

var i,t     : integer;
    darab   : integer;
    eleje, vege : integer;

begin
  (*
    if elozo_elso_alja > 0 then         {}
     for t:= 1 to elso_alja do
       begin
         lprint(32);
         if volt_esc or kilepett then exit;
       end;

    darab := e_sor_hossza;
    ini_gr_sor(darab - elso_alja);
    if kilepett then exit;

    for t:= elso_alja*Kszel to darab*Kszel-1 do
     begin
       lprint(fo_tombok[nekifut][t] or or_tombok[nekifut][t]);
       if volt_esc or kilepett then exit;
     end;

    fillchar(fo_tombok[nekifut],sizeof(fo_tombok[nekifut]),#0);
 *)


    eleje := elso_alja;
    if elozo_elso_alja < eleje then eleje := elozo_elso_alja;

    if eleje > 0 then
     for t:= 1 to eleje do
       begin
         lprint(32);
         if volt_esc or kilepett then exit;
       end;

    darab := e_sor_hossza;

    ini_gr_sor(darab - eleje);
    if kilepett then exit;

    for t:= eleje*Kszel to darab*Kszel-1 do
     begin
       lprint(fo_tombok[nekifut][t] or or_tombok[nekifut][t]);
       if volt_esc or kilepett then exit;
     end;


end;



{-------------------------------------------------------------------}
procedure egy_sort_nyom;       {37. image sorban van}


var kik          : integer;    {kiirando karakter sorszama}
    van_valami   : boolean;
    ch           : char;
    nekifut      : byte;

Begin

     betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }
     if betuk_szama + PrintMargin > C80 then
     betuk_szama := C80 - PrintMargin;     {max. 78 szeles }

     e_sor_hossza := betuk_szama;
     Van_Valami   := (E_sor_hossza <> 0);

     abspos      := 0;    { or_tomb mutato }
     volt_gr_ini := false;

     If van_valami then
       begin

         ures_sorok := 0;

         if utso_alja + 1 > e_sor_hossza          {elozo lelogoja tavolabb van}
          then e_sor_hossza := utso_alja + 1;     {?????}

         utso_alja        := -1;               {az utso lelogo szama lesz}
         elso_alja        := 99;
         nezett_elsot     := false;

         fillchar (fo_tombok[1], sizeof(fo_tombok), #00);
         fillchar (ez_or_tombok[0], sizeof (ez_or_tombok), #0);

         for nekifut := 0 to 2 do
          case nekifut of
           0 :  begin
                 balmargo;
                 if volt_esc or kilepett then exit;
                 for kik := 0 to e_sor_hossza-1  do
                  begin
                    gr_egy_kart_nyom(kik);
                    if volt_esc or kilepett then exit;
                  end;
                 cr_picit_emel;

                end;
           1,2: begin
                 balmargo;
                 if volt_esc or kilepett then exit;
                 egy_gr_sort_nyom (nekifut);
                 if volt_esc or kilepett then exit;
                 cr_picit_emel;
                                 end;
           end;

         fillchar(fo_tombok,sizeof(fo_tombok),#0);
         or_tombok := ez_or_tombok;         {also reszek mar az ujak !!}

         elozo_sor_hossza := e_sor_hossza;
         elozo_sor_ures   := false;
         elozo_elso_alja  := elso_alja;

         Cr_4_72_lf;
       end

     Else                                { nincs valami }
       begin

         inc(ures_sorok);
         if not elozo_sor_ures then       {elozo alja, ha van}
           begin
             if utso_alja > -1 then
               begin
                or_tombnyom (utso_alja);   {eddig kell kiadni, EZT IS}
                fillchar(or_tombok,sizeof(or_tombok),#0);
                cr_4_72_lf;
               end;
           end
         else Cr_Lf;

         elozo_sor_hossza  := 0;
         elozo_sor_ures    := true;
         utso_alja         := -1;
         elso_alja         := -1;
         elozo_elso_alja   := 99;

       end;        {nincs valami}

End;

{=====================  MAIN ====================================}
{procedure LQ30TU }
Begin
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}
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
  fillchar (or_tombok[0], sizeof (or_tombok), #0);
  fillchar (ez_or_tombok[0], sizeof (ez_or_tombok), #0);
  fillchar (fo_tombok[1], sizeof (fo_tombok), #0);

  ures_sorok := 0;

  if Condensed and (Ny_modus = 0)
   then lprint(15)
   else lprint(18);

  {-------------------- inicializalas vege: main loop ------------}
  felsorok := 0;

  while  Van_Sor  do
    Begin

      LapVeg := (Image[LastLine]^.attribs[0] and LapVege) = LapVege;
      egy_sort_nyom;
      inc(felsorok);
      if kilepett then
          Begin
            bool := Remove_window;
            Esc  := True;
            Exit;
          End;

      if  LapVeg then
        begin
          If KellLapDob then lprint(12);          {lap vege bit: FF}
          delay(ures_sorok * IroIdo);
          ures_sorok  := 0;
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
    If  ((elozo_sor_hossza <> 0) and (utso_alja > -1))  Then
       Begin
         Or_tombnyom(utso_alja);
         Inc(felsorok);
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

(* cmd(#27+'@');                 { alapallapotba vissza allit } *)

End;  { Procedure LQ30TU }


End.
