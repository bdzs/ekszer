Unit Nyom2;
{$O+}

Interface

Uses Nyomtat,Dos,Crt,Windowm,Video,InputCdw,HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     SpeakCdw;

procedure Robotron;

Implementation

{**+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*+*}
{nyomtato rutin  R O B O T R O N es HANDY-hez}

procedure robotron;
          {=======}



var
               i,j,k         : integer;
               c             : char;
               lap_vege      : boolean;
               retry         : integer;

    betuk_szama    : integer;
    alahuz, vastag : boolean;

    kilepett    : boolean;  {nyomtatas kozben ESC, vagy rossz printer}
    nyomas_vege : boolean;
    voltlapdob  : boolean;

    handy       : Boolean;
    nincsfel    : boolean;
    vkibe       : boolean;

    felsorok    : byte;
    utsoemeles  : byte;

   {$IFDEF LICENC}
    cikl   : word;
    EmbSor : word;

   {$ENDIF}

{------------------------------------------------------------------}
procedure bill_urit;
var c: char;
begin
   while keypressed do c:= readkey;

end;
{-------------------------}
procedure lprint (c: byte);       {kilepett lesz, ha nem megy ki!!!}

var        cb : char;
       pr_ok  : boolean;
       bejott : boolean;
       bechar : byte;
       count  : integer;
begin

  if not centronics then
     begin
        count  := iroido;
        pr_ok  := false;
        cb     := ' ';
        register.DX := serial_device;
        register.AH := 3;                         {get status}
        intr($14,register);
        bejott := ((register.AH and 1) = 1);
        if bejott then
         begin
           register.DX := serial_device;
           register.AH := 2;                      {receive char}
           intr($14,register);
           bechar := register.AL and $7F;

             if bechar = 19 then                  {xoff}
              repeat
                 register.DX := serial_device;
                 register.AH := 2;                {receive char}
                 intr($14,register);
                 bechar := register.AL and $7f;

                 if keypressed then
                   begin
                     cb:= readkey;  if cb = #0 then cb := readkey;
                     BOOL := CREATE_WINDOW(15,7,65,11,pr_mess1,CA[DispMode,1],Ca[DispMode,4]);
                     GotoXY(5,2);
                     write(pr_mess2);
                     Speak2(100,200);
                     cb := readkey; if cb = #0 then cb := readkey;
                     Bool := Remove_Window;
                     kilepett := (cb = #27);
                   end;

              until (bechar=17) or kilepett;
         end;

        if kilepett then exit;

        repeat
          count := retry;
          repeat
            register.DX := serial_device;
            register.AL := c;
            register.AH := 1;                 {print AL}
            intr($14,register);
            pr_ok := ((register.AH and $80) = 0);
            dec(count);

            if keypressed then
              begin
                cb:= readkey;  if cb = #0 then cb := readkey;
                BOOL := CREATE_WINDOW(15,7,65,11,pr_mess1,CA[DispMode,1],Ca[DispMode,4]);
                GotoXY(5,2);
                write(pr_mess2);
                Speak2(100,200);
                cb := readkey; if cb = #0 then cb := readkey;
                Bool := Remove_Window;
                kilepett := (cb = #27);
              end;

          until pr_ok or (count = 0) or kilepett;

          if kilepett then exit;

          if not pr_ok then
            begin
              BOOL := CREATE_WINDOW(42,8,72,12,pr_mess13,CA[DispMode,1],Ca[DispMode,4]);
              GotoXY(2,2);
              write(pr_mess14);
              Speak2(102,202);

              bill_urit;
              repeat
                cb := Upcase(readkey);
              until cb in [#27,UjraChar,KilepChar];
              Bool := remove_window;
              if cb in [KilepChar,#27] then kilepett := true;
            end;

        until (pr_ok or kilepett);
        delay(iroido);              {minden kikuldott byte utan}

     end
  else         {If centronics ---------------------------------}

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
            if cb in [KilepChar,#27] then kilepett := true;
          end;

      until (pr_ok or kilepett);
    end;

end;
{----------------------------------------------------------------}
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

{-----------------------------------------------------------}
procedure cmd (parancs: st8);

var i: byte;

begin
    for i:= 1 to length(parancs) do
      begin
        lprint(byte(parancs[i]));
        if kilepett then exit;
      end;
end;

procedure vastag_be ;
begin
     cmd(spar.s_vastag_be);
     vastag := true;
end;

procedure vastag_ki;
begin
     cmd(spar.s_vastag_ki);
     vastag := false;
end;

procedure alahuz_be;
begin
    cmd(spar.s_ala_be);
    alahuz := true;
end;

procedure alahuz_ki;
begin
   cmd(spar.s_ala_ki);
   alahuz  := false;
end;

procedure bill_off;   {billentyuzetet kikapcsol @@@}
begin
 {  cmd(spar.s_bill_off)  }
end;

procedure bill_on;   {billentyuzetet bekapcsol @@@}
begin
 {   cmd(spar.s_bill_on) }
end;

procedure s_12;
begin
     cmd(spar.s_1_12);
end;

procedure ritka_off;
begin
     cmd(spar.s_ritka_off);
end;

procedure ini_serial;
begin
     cmd(spar.s_ini);
end;

Procedure Cr_Lf;

Begin
     if nincsfel then inc(felsorok)
     else
      begin
        cmd(spar.s_cr_lf);
        delay(iroido * 10);
      end;
End;

Procedure CR;      { ahol nincs CR LF nelkul }

Begin
    lprint(13);
    delay(iroido * 10);
End;

{--------------------------}

procedure ini_printer;
var i: byte;

Begin

  ini_serial;     if kilepett then exit;
{
  s_12;           if kilepett then exit;
  ritka_off;      if kilepett then exit;

  vastag_ki;      if kilepett then exit;
  alahuz_ki;      if kilepett then exit;
}
End;
{----------------------------------------------------------}
procedure egy_kart_nyom (kik: integer);

var kar : char;
    att : byte;
    t   : byte;
    c   : byte;

Begin

   kar :=  Image[LastLine]^.chars[C80+kik];
   if kar < ' '   then kar := ' ';

   att :=  Image[LastLine]^.attribs[kik] and 15;
   if att < 1 then att := 1;

   AlahuzottSpaceCsere(Kar,Att);

   if (kar='*') and (grafE(att)) and (fontnames[att] = 'SPEC1') then
        begin
          kar := ' ';   { kemeny osszekoto space !!!}
          att := 1;
        end;

   If kar <> ' ' then
    Begin

{$ifndef angol}

        If AngolE(att)
           then kar := spar.s_atkod[1][byte(kar)]  {ascii}
        Else If MagyarE(att)
           then kar := spar.s_atkod[2][byte(kar)]  {magyar}
        Else kar := '.';                           {nem irhato}

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

{$else}                                               {if angoloknak }

        If AngolE(att)
             then kar := spar.s_atkod[1][byte(kar)]   {ascii}
             Else kar := '.';                         {nem irhato}

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

{$endif}

    End                                         {if kar <> ' '}
    Else if alahuz then alahuz_ki;

    if kilepett then exit;
    lprint (byte(kar));         {kiadja magat a karaktert is}
    if kilepett then exit;

    if handy then
      if kar in [#96,#94] then lprint(32);   {Ç betÅ miatt:
                                             idiota handy visszalep!}

End;
{-------------------------------------------------------------------}
procedure Egy_Sort_Nyom;


var kik          : integer;    {kiirando karakter sorszama}
    van_valami   : boolean;
    ch           : char;
    t,kisemeles,nagyemeles: integer;

Var e_sor_hossza : integer;

Begin

       betuk_szama := sor_hossz (0,LastLine+2,0,0,0,imageoffs); { 39 !!! }

       e_sor_hossza := betuk_szama;
       Van_Valami   := (E_sor_hossza <> 0);

       If van_valami Then
          Begin
            if nincsfel then
               begin
                case felsorok of
                1: begin
                    cr;
                    if kilepett then exit;
                    case utsoemeles of
                     2: begin
                          cmd(#27'D');    {egy fel lepes vissza}
                        end;
                     3: begin
                          cmd(#27'D');    {egy fel lepes vissza}
                          if kilepett then exit;
                          cmd(#27'D');    {egy fel lepes vissza}
                        end;
                    end;
                   end;
                2: begin
                    if utsoemeles <> 2 then cmd(#$1b#$33);
                    if kilepett then exit;
                    cr;
                    utsoemeles := 2;
                   end;
                3: begin
                    if utsoemeles <> 3 then cmd(#$1b#$34);
                    if kilepett then exit;
                    cr;
                    utsoemeles := 3;
                   end;

                else if felsorok > 3 then
                 Begin
                    nagyemeles := felsorok div utsoemeles;
                    kisemeles  := felsorok mod utsoemeles;
                    for t:= 1 to nagyemeles do
                      begin
                       cr;
                       if kilepett then exit;
                      end;
                    for t:= 1 to kisemeles do
                      begin
                       cmd(#27'U');
                       if kilepett then exit;
                      end;
                 End;

                end;     {case}

                felsorok := 0;
               end;                            {if nincs_fel}

            For kik := 1 to  PrintMargin Do
              begin
                lprint(32);
                if kilepett then exit;
              end;
            For Kik := 0 To Betuk_Szama-1 Do
              begin
                egy_kart_nyom (kik);
                if volt_esc or kilepett then exit;
              end;
            cr_lf;
          end
       else    {nincs valami}

       cr_lf;       if kilepett then exit;

       if alahuz then alahuz_ki;
       if (not vkibe) and vastag then  vastag_ki;

End;

{======================}
{procedure ROBOTRON ;  }

Begin
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}
  If Enabled[3] Then
  Begin
    centronics := (spar.s_bill_on  = 'centr');
    handy      := (spar.s_bill_off = 'handy');
    nincsfel   := (spar.s_bill_off = 'nincs');
    vkibe      := (spar.s_bill_on  = 'vkibe');

    if centronics then
         begin
           ptimeout[paralell_device] := 2;
           register.DX := paralell_device;
         end
    else register.DX := serial_device;


    kilepett    := false;
    bill_urit;

    retry := 1;
    for i:= 1 to 2 do
      begin
        lprint(0);
        if kilepett then exit;
      end;

    if not centronics then retry := iroido * 3
                      else ptimeout[paralell_device] := iroido * 2;

    ini_printer;
    BOOL := CREATE_WINDOW(40,6,75,10,pr_mess8,CA[DispMode,1],Ca[DispMode,2]);

    GotoXY(3,2);
    writeln (pr_mess9);

    lap_vege   := false;        {nem a lap alja}
    voltlapdob := false;
    alahuz := false;
    vastag := false;

    if nincsfel then
     begin
       felsorok   := 0;
       utsoemeles := 3;
       cmd(#$1b#$34);
       if kilepett then exit;
     end;

    {-------------------------------------------------------------}

   {$IFDEF LICENC}
    EmbSor := 0;
   {$ENDIF}

    while  Van_Sor  do
      Begin
        {$IFDEF LICENC}
         If Emblema then
          begin
            Emblema := false;
            Embsor  := 3;
            for cikl := 0 to 3 do
             Image[LastLine]^.chars[C80+cikl] := EmbSt[cik+1];
            for cikl := 0 to 3 do
             Image[Lastline]^.attribs[cikl] := 1;
          end
        else
         if EmbSor > 0 then
          begin
            dec (EmbSor);
            for cikl := 0 to 3 do
             if Image[LastLine]^.attribs[cikl] = kepfont then
             begin
              Image[LastLine]^.chars[C80+cikl] := ' ';
              Image[LastLine]^.attribs[cikl] := 1;
             end;
          end;
        {$ENDIF}

        egy_sort_nyom;
        voltlapdob := false;

        if kilepett or volt_esc Then
            begin
              esc := true;
              bool := remove_window;
              ini_serial;
              exit;
            end;

        if (Image[LastLine]^.attribs[0] and 64 = 64) then
           begin
             If KellLapDob then lprint(12);     {lap vege bit: FF}
             voltlapdob := true;
             if handy then cmd('   '); lprint(13);
             delay(iroido * 10);
             IF KellLapDob then
             Begin
               BOOL := CREATE_WINDOW(8,11,47,16,pr_mess10,CA[DispMode,1],Ca[DispMode,4]);
               GotoXY(3,3);
               writeln (pr_mess11);
               GotoXY(3,4);
               writeln (pr_mess12);

               If EnabledSpeak Then Speak2(101,201)
                               Else for i:= 1 to 5 do beepel(i*200);

               c := readkey; if c= #0 then c:= readkey;
               Bool := Remove_Window;
               if c = #27 then
                begin
                  esc := true;
                  bool := remove_window;
                  exit;
                end
               else bill_urit;
             End;
           end;

    End;     {  Ha van sor  }

    If not voltlapdob  then
      Begin
        lprint(12);
        if handy then
         begin
          cmd('   ');
          lprint(13);
         end
      End;

    If vkibe and vastag then  vastag_ki;

    Bool := Remove_window;
  End;

End;  { Procedure Robotron }


End.
