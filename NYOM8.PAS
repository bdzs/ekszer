Unit Nyom8;
{$O+}         { HP DeskJet 500 LFT-vel, normal es szep }

Interface

Uses Nyomtat,Dos,Crt,Windowm,MenuErr,
     Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

Procedure DeskJetNyomLFT;

procedure loadfont(Att:Byte);

type egy_kar_pix_sor = array[1..4] of byte;
     egy_kar_matrix  = array[1..50] of egy_kar_pix_sor;
     egy_kar_set     = array[33..127] of egy_kar_matrix;

    setp  = ^egy_kar_set;
    sorgyujto = array [0..80*4] of byte;
                {ebben gyulnek a bit-ek egy pixel sorra}
    sorgyujtotomb = array[1..50] of sorgyujto;
                {ebben egy teljes sor grafikusan}
var
    setpt : array[1..16] of setp;

Implementation
{^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}

Var
    Kezdi      : Integer;
    SzabadHely : Word;
    BentVan    : Integer;

Procedure GetAddr(Var P : SetP);

Procedure IncKezdi;
Begin
  Inc(Kezdi);
  If Kezdi > 15 Then
    Kezdi := 1;
End;

Begin
  If SzabadHely < (18800 Div 16) Then
    Begin
      While SetPt[Kezdi] = NIL Do
        IncKezdi;
      P := SetPt[Kezdi];
      SetPt[Kezdi] := NIL;
      IncKezdi;
    End
  Else
    Begin
      P := Ptr(Seg(StartPoint^)
                +BentVan*(18800 Div 16),Ofs(StartPoint^));
      Inc(BentVan);
      Dec(SzabadHely,(18800 Div 16));
    End;
  {Writeln(Seg(P^));}
End;


procedure loadfont(Att:Byte);
Var F : File;
begin
  If SetPt[Att] = NIL Then
    Begin
      GetAddr(SetPt[Att]);
      If Att <> 16 Then
        Begin
          Assign(F,PathSt+Fontnames[Att]+'.LFT');
          {$i-} Reset(F,1); {$i+}
          If IOresult <> 0 Then
            Begin
              Error(1,Fontnames[Att]+'.LFT');
              Esc := True;
              lprint(12);
              lprint(27);
              lprint(byte('E'));
              Exit;
            End;
          Seek(F,$158);
          {$I-}
          BlockRead(F,SetPt[Att]^,18800); {Laser font merete - fejlec }
          Close(F);
          {$I+}
        End
      Else
        FillChar(SetPt[Att]^,SizeOf(SetPt[Att]^),0)
    End
end;


Procedure DeskJetNyomLFT;

Var
    gyujto: sorgyujto; {ebben gyulnek egy pixel sor bitjei}
    gyujtotomb : sorgyujtotomb;

    elozo_sor_hossza    : word;
    elozoelotti_sor_hossza    : word;
    nyomnikell_pixsorok : word;

Const
    SpaceT : egy_kar_pix_sor = (00,00,00,00);


procedure ini_sets;
var
    t : word;
begin
   for t:= 1 to 16 do
     setPt[t] := NIL;   {minden set-hely szabad}
   BentVan    := 00;
   Szabadhely := PointSize;
   Kezdi      := 1;
end;


procedure insertpixek(ezt: egy_kar_pix_sor; bitpos: word);

var bytepoz, bitpoz : word;
    li : longint;
    LIX : egy_kar_pix_sor Absolute Li;
    b, t : byte;

begin
   bytepoz := bitpos div 8;
   bitpoz  := bitpos mod 8;
{
   writeln(bitpos:8,bytepoz:8, bitpoz:8);
}
   if bitpoz = 0 then
     move(ezt, gyujto[bytepoz], 4)
   else
    begin
      for T := 1 To 4 Do LiX[T] := ezt[5-T];

      b := ezt[1] shr bitpoz;
      gyujto[bytepoz] := gyujto[bytepoz] or b;

      li := li shl (8-bitpoz);
      For T := 1 To 4 Do
        gyujto[bytepoz+T]:=liX[5-T];
    end;
end;


procedure egy_sort_osszerak(ik: word); {max kar.szam a sorban}

var pixsor, karakt, t,tt : word;
    pixek  : egy_kar_pix_sor;
    att,kar: byte;

begin

 for pixsor := 1 to 50 do
  begin
    fillchar(gyujto,sizeof(gyujto),00);  {tiszta pixel-gyujto}

    for karakt := 0 to ik do
     begin
      kar := byte(Image[LastLine]^.chars[C80+Karakt]);
      if (kar > 126) or (kar < 32) then kar := 32;
      att := Image[LastLine]^.attribs[Karakt];
      if att > 16 then att := att and 15;
      if att < 1 then att := 1;

      LoadFont(Att);
      If ESC then exit;
      if kar <> 32 then
        begin
         pixek := setpt[Att]^[kar,pixsor];
         insertpixek(pixek,karakt*30);
        end;
     end;
    if pixsor < 39 then
     begin
       for tt := 0 to karakt*4-1 do
       gyujtotomb[pixsor,tt] := gyujtotomb[pixsor,tt] or gyujto[tt]
     end
    else  gyujtotomb[pixsor] := gyujto;
  end;
end;


Var
      Y       : integer;
      aktfont : byte;
      kilepett: boolean;
      i       : integer;
      c       : char;
      elsosor       : boolean;
      volt_lapdob   : boolean;

      PrintMargo    : integer;
      lapmagassag : word;

Const

  ChrPerLine   :byte = 78;
  XPIX         :byte = 30;
  VMOV         :byte = 19;
  YPIX         :byte = 50;
  space_X      :byte = 30;
  Xbytes       :byte =  4;

  var
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
                ESC      := true;
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
                   if cb in [KilepChar,#27] then
                     begin
                      kilepett := true;
                      esc := true;
                     end;
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
procedure ini_Ypos;

begin
      lprintstr(#27'*p22Y');
      Y := 22;
end;

procedure ini_Xpos;

var x: word;
    xstr: st8;

begin

  x := PrintMargo * 30;
  lprint(27); lprintstr('*p');
  if ESC then exit;
  str(x,xstr);
  while (xstr[1] = ' ')  or (xstr[1] = '0') do delete(xstr,1,1);
  lprintstr(xstr);
  if ESC then exit;
  lprint(byte('X'));
  if ESC then exit;

end;
{----------------------------------}

procedure pixdown (ig: word);

var igstr: st8;

begin
{
  lprintstr(#27'*p');
  str(ig,igstr);
  while (igstr[1] = ' ')  or (igstr[1] = '0') do delete(igstr,1,1);
  lprintstr('+'+ igstr);
  lprint(byte('Y'));
  }
 inc(Y,ig);
 lprintstr(#27'*p');
 if esc then exit;
 str(Y,igstr);
 while (igstr[1] = ' ')  or (igstr[1] = '0') do delete(igstr,1,1);
 lprintstr(igstr);
 if esc then exit;
 lprint(byte('Y'));

end;

procedure cr_lf;

var igstr : st8;
begin
            {
 LPRINTSTR(#27'*p+19Y');
             }
 inc(Y,19);
 lprintstr(#27'*p');
 if esc then exit;
 str(Y,igstr);
 while (igstr[1] = ' ')  or (igstr[1] = '0') do delete(igstr,1,1);
 lprintstr(igstr);
 if esc then exit;
 lprint(byte('Y'));

end;

           {
procedure xpos(x : integer);

var xstr : string[5];

begin
    str(x:5,xstr);
    while (xstr[1] = ' ')  or (xstr[1] = '0') do delete(xstr,1,1);
    cmd(#27'*p'+xstr+'X');
end;
          }

{-----------------------------------------------------------}
procedure pix19sort_nyom(ig: word);  {a puffer tomb elso 19 sorat
                                      grafikusan kinyomja,
                                      majd az elso 19 sor helyere
                                      a kovetkezoket bemasolja
                                      az utso 19-et pedig torli}

var t,lefele: word;
    igstr   : st8;


begin
 ini_Xpos;
 lprintstr(#27'*r1A');  {start graf}
 for lefele := 1 to 19 do
  begin
    lprintstr(#27'*b');
    if esc then exit;
    str(ig*4,igstr);
    while (igstr[1] = ' ')  or (igstr[1] = '0') do delete(igstr,1,1);
    lprintstr(igstr);
    if esc then exit;
    lprint(byte('W'));     {grafikus adatok kezdete, hossza}
    if esc then exit;
    for t:= 0 to ig*4-1 do
     begin
      lprint(gyujtotomb[lefele,t]);
      if ESC then exit;
     end;
  end;

 lprintstr(#27'*rB');  {end graf}
 if esc then exit;

 move(gyujtotomb[20],gyujtotomb[1],(50-19)*sizeof(gyujto));
 fillchar (gyujtotomb[50-18],19*sizeof(gyujto),00);

 inc(Y,19);
end;

procedure pixXsort_nyom(ig, X : word);  {a puffer tomb elso X sorat
                                      grafikusan kinyomja,
                                      tombot torli}

var t,lefele: word;
    igstr   : st8;

begin
 ini_Xpos;
 if esc then exit;
 lprintstr(#27'*r1A');  {start graf}
 if esc then exit;for lefele := 1 to X do
  begin
    lprintstr(#27'*b');
    if esc then exit;
    str(ig*4,igstr);
    while (igstr[1] = ' ')  or (igstr[1] = '0') do delete(igstr,1,1);
    lprintstr(igstr);
    if esc then exit;
    lprint(byte('W'));     {grafikus adatok kezdete, hossza}
    if esc then exit;
    for t:= 0 to ig*4-1 do
     begin
      lprint(gyujtotomb[lefele,t]);
      if ESC then exit;
     end;
  end;

 lprintstr(#27'*rB');  {end graf}
 if esc then exit;

 fillchar (gyujtotomb,sizeof(gyujtotomb),00);
 inc(Y,X);
end;

{-----------------------------------------------------------}
procedure egy_sort_nyom;

var kik          : integer;    {kiirando karakter sorszama}
    betuk_szama  : integer;
    hur,t        : integer;
    kar          : char;
    att          : byte;
    nyom_ig      : byte;

Begin

       if ElsoSor then
          begin
             Ini_Ypos;
             if esc then exit;
             Ini_Xpos;
             if esc then exit;
             ElsoSor := false;
             FillChar(Gyujtotomb,sizeof(gyujtotomb),0);
             elozo_sor_hossza       := 0;
             elozoelotti_sor_hossza := 0;
          end;

       betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }

       if betuk_szama > 79 then betuk_szama := 79;
       if betuk_szama + PrintMargo > ChrPerLine - 1 then
             betuk_szama := ChrPerLine - PrintMargo - 1;   {max. 78 szeles ???}

       If betuk_szama > 0 then
          begin
            egy_sort_osszerak(betuk_szama);
            If ESC then exit;
            nyomnikell_pixsorok := 50;
            nyom_ig := betuk_szama;         {
            if elozo_sor_hossza > betuk_szama then
               nyom_ig := elozo_sor_hossza;  }
            pix19sort_nyom(79-printmargo);
            if esc then exit;
            dec(nyomnikell_pixsorok,19);
            if ESC then exit;
           { if elozo_sor_hossza < betuk_szama then }
            elozo_sor_hossza := betuk_szama;
          {  elozoelotti_sor_hossza := elozo_sor_hossza;}
          end
       else                   {if betuk_szama = 0}
         begin
           if elozo_sor_hossza > 0 then
            begin
             pix19sort_nyom(79-printmargo);
             if esc then exit;
             dec(nyomnikell_pixsorok,19);
             if ESC then exit;
             elozoelotti_sor_hossza := elozo_sor_hossza;
             elozo_sor_hossza := 0;
            end
           else              {if elozo_sor_hossza = 0}
            begin
             if (nyomnikell_pixsorok > 0) and
                (elozoelotti_sor_hossza > 0 ) then
              begin
               pixXsort_nyom(79-printmargo,nyomnikell_pixsorok);
               if esc then exit;
               pixdown(19-nyomnikell_pixsorok);

               nyomnikell_pixsorok    := 0;
               elozoelotti_sor_hossza := 0;
              end
             else
              cr_lf;
              if esc then exit;
            end;

            elozo_sor_hossza := 0;
         end;               {if betuk_szama = 0}

End;

{=============================================================}
                                                     { MAIN }
Label Kimegy;

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
        if kilepett or ESC then
         Begin
           ESC := true;
           exit;
         End;
      End;

    if not Korlevelben then
       cmd(ppar.pr_ini);                    {ini printer}
    if esc then exit;

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

      XPIX         := 30;
      VMOV         := 19;
      space_X      := 30;
      Cmd(#27'&k0S');      {allo}
      if esc then goto Kimegy;
      cmd(#27'*t300R');    {300 pontos felbontas}
      if esc then goto Kimegy;

    {-------------------------------------------------------------------}
    dobott   := false;
    felsorok := 0;
    ini_sets;
    elozo_sor_hossza       := 0;
    elozoelotti_sor_hossza := 0;
    nyomnikell_pixsorok    := 0;


    while  Van_Sor  do
           Begin
              LapVeg := (Image[LastLine]^.attribs[0] and LapVege) = LapVege;
              egy_sort_nyom;            { <---------- }
              inc(felsorok);

              if kilepett or volt_esc or ESC then
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

    Kimegy:
    Bool   := Remove_window;
    LaserY := Y;

  End;
End;  { Procedure LaserNyom }
End.
