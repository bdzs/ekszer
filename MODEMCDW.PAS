unit ModemCDW;

{$O+}

interface

uses dos, crt, windowm,Video, SpeakCdw;


  type modemtomb = array[1..128] of byte;


            procedure open_modem_out;
            procedure open_modem_inp;
            procedure writeln_modem (ez: string;KellCr : Boolean);
            procedure readln_modem  (var ez: string);
            procedure close_modem_out;
            procedure close_modem_inp;
            Procedure End_of_Transmission;
            procedure Close_Puffer;
            Procedure Send_Modem(ezt: modemtomb);
            Procedure Get_Modem(var ezt: modemtomb);
            Function  Kilep: boolean;
            Procedure BreadM(var  ez: modemtomb);
            Procedure BwriteM(tomb : modemtomb);

Const
  ModemError : byte = 0;  {0 =OK, 1 =time-out, 2 =checksum, 3 =ujra ker,
                               4 =szemet}
  NoMore     : boolean = false;

implementation

const hiba : byte = 0;

const
      Elozonomore :boolean = false;
      Modemrekord :word    = 1;
      Absrek      :word    = 1;

Const SOH = 01;  {start of heading}
      ACK = 06;  {ok, received}
      NAK = 21;  {not acknowledged}
      EOT = 04;  {end of text}

var regs : registers;
       b : byte;
    modemfirst : boolean;

    tomb       : modemtomb;
    tmut       : word;
    elsoreadln : boolean;
    visszaad   : string;
    visszatomb : modemtomb;

{-----------------------------------}
function van_bejovo: boolean;

begin
   regs.ah := 0;
   intr($0ff,regs);
   van_bejovo := (regs.ax <> 0);
end;
{-----------------------------------}
function read_serial: byte;

begin
   regs.ah := 1;
   intr($0ff,regs);
   read_serial := regs.al;
(*   write(lst,Char(regs.al));
   If Regs.al = 13 Then
     Write(lst,#10)
  *)
end;

procedure write_serial(byt : byte);

begin
    regs.ah := 2;
    regs.al := byt;
    intr($0ff,regs);
end;
{----------------------------------}

PROCEDURE Gyors_modem(seb : byte); {110000 baud, 8 bit, 2 stop bit, no parity}


const rsport_base = $3F8;

   var ax,bx,cx,dx : word;

       elrak: word;
       adat : byte;

const indulo = 3;

   { 000   00    1      11
     seb.  par.  stop   len. =  3 }

procedure div_out(ezt: word);

begin
    port[dx] := $80; {enable divisor latch addr}

    elrak := dx;
    dec(dx);
    dec(dx);      {divisor latch msb}

    port[dx] := hi(ezt);
    dec(dx);
    port[dx] := lo(ezt);

    dx := elrak;
end;


begin
    dx := ComPoint^[1];
    inc(dx,4);

    dec(dx);     {line controll reg}

    Case seb of
      1 : div_out(6);                       {6=19000, 3=40000, 1= 110000}
      2 : div_out(3);
      3 : div_out(1);
    End;

    port[dx] := indulo;
    inc(dx);

    inc(dx);             {line status reg}
    adat := port[dx];

    inc(dx);             {modem status reg}
    adat := port[dx];

end;

procedure Set_300_baud;

Begin
  Case ModemBdr Of
    1..8 : Begin
             regs.ah := 0;
             regs.al := ((ModemBdr-1) Shl 5) Or 3;   { = }
             regs.dx := ComPort-1;     {com1:-com4:}
             intr($14,regs);
           End;
    9..11: Gyors_Modem(ModemBdr-8);

  End;

End;


procedure Open_Puffer;

begin
   SetIntVec($FF,IntFFVec);
   set_300_baud;
   regs.ah := 3;
   intr($0ff,regs);
end;

procedure Close_Puffer;

begin
   regs.ah := 4;
   intr($0ff,regs);

end;

Procedure Clear_puffer;

Begin
   close_puffer;
   open_puffer;
End;

{-----------------------------------------------------}
Function Bejott: boolean;

const eddig = 72;  {4 masodperc}
var   basis : word absolute $40:$6c;
      ido   : word;


Begin
  bejott := true;
  ido    := basis;
  repeat
   if van_bejovo then exit;
  until  basis = ido + eddig;
  bejott := false;
End;

{------------------------------------}
Procedure Modem_to_Transmit;

Var b    : byte;

Begin
  modemerror := 1;   { time out }
  modemrekord:= 1;
  absrek     := 1;
  nomore     := false;
  elozonomore:= false;


  If Bejott then
   begin
     b := read_serial;
     if b = NAK then begin
                      modemerror := 0;  {OK}
                      clear_puffer;     {ha volt mar elotte, kitorolni}
                     end
                else modemerror := 4;  {szem‚t}
   end;
End;
{------------------------------------}

Procedure Modem_to_Receive;

Var b    : byte;
    t    : integer;
    proba  : word;
    ok     : boolean;

Begin
  nomore     := false;
  elozonomore:= false;
  modemerror := 1;   { time out }
  modemrekord:= 1;
  absrek     := 1;
  modemfirst := true;

  write_serial(NAK);
  if Bejott then
    begin
      b := read_serial;
      if b = SOH then
        begin
          modemerror := 0;
          exit;
        end;
     end
End;
{------------------------------------}

Procedure Send_Modem(ezt: modemtomb);

Var t,b : byte;
    csw : word;
    csb : byte;

Begin

    clear_puffer;
    modemerror := 0;

    write_serial(SOH);
    write_serial(modemrekord);
    write_serial(modemrekord xor $ff);

    csw := 0;
    for t:= 1 to 128 do
     begin
       b := ezt[t];
       write_serial(b);
       Inc(csw,b);
     end;
    csb := lo(csw);
    write_serial(csb);

    if Bejott then
     begin
       b := read_serial;
       case b of
         ACK         : begin
                        modemerror := 0;
                        inc(modemrekord);
                        inc(absrek);
                        if modemrekord = 256 then modemrekord := 0;
                       end;
         NAK         : modemerror := 3;
         else          modemerror := 4;
       end;  {case bejovo of}
     end
    else modemerror := 1;       {if nem jott valasz}

End;
{-----------------------------------------------------}

Procedure Get_Modem (var ezt: modemtomb);

Var t,b : byte;
    csw : word;
    csb : byte;
    ok  : boolean;
    getrek    : byte;  {ezt a rekordot kuldik}
    getkomprek: byte;  {egyes komplemense}

Begin
  modemerror := 1;       {time out}

  If not modemfirst then
   Repeat
     If Bejott then
       begin
          b := read_serial;
          if b = EOT then
           begin
             nomore    := true;
             modemerror:= 0;
             write_serial(ACK);
             exit;
           end;
       end                    {if Bejott = true}
     else exit;               {else timeout}
   Until b = SOH              {if nem elso, akkor SOH-ig kiolvas}
  Else modemfirst := false;   {if elso, akkor mar olvasott SOH-ig}

  if Bejott then getrek     := read_serial else exit;
  if Bejott then getkomprek := read_serial else exit;

  csw := 0;
  for t:= 1 to 128 do
   begin
    if Bejott then
     begin
       ezt[t] := read_serial;
       Inc(csw,ezt[t]);
     end
    else exit;
   end;

  if Bejott then csb := read_serial else exit;
  (*
  gotoxy(1,24); write('getrek: ',getrek,' modemrek: ',modemrekord);
  *)
  (*
  if hiba = 2 then inc (csb);  {checksum hibat general !!!!!}
  inc(hiba);
  *)

  if (  (csb = lo(csw)) and
        (getrek = modemrekord) and
        (getkomprek = getrek xor $ff) )
  then
    begin
      inc(modemrekord);
      inc(absrek);
      if modemrekord = 256 then modemrekord := 0;
      modemerror  := 0;
    end
  else modemerror := 2;    { checksum }

End;

{-----------------------------------------------------}
Procedure Ready_for_Next;

Begin
   clear_puffer;
   write_serial(ACK);
End;

Procedure Repeat_Last;

Begin
   clear_puffer;
   write_serial(NAK);
End;

Procedure End_of_Transmission;

Begin
   write_serial(EOT);
End;


Function Kilep: boolean;

Var c: char ;

Begin
   c := #0;
   Kilep := false;
   if keypressed then
   Begin
     c := readkey;
     if c = #0 then c := readkey;
   End;
   if c = #27 then
    begin
     bool := create_window(32,11,70,15,mmsg5,CA[DispMode,1],CA[DispMode,4]);
            gotoxy(2,2); write(mmsg4);

            Speak(128);

            Repeat
              c := upcase(readkey);
              if c = #0 then
                Begin
                  c := readkey;
                  c := #0
                End;
              if c  = YesChar then
               begin
                 modemerror := 5;
                 kilep      := true;
                 close_puffer;    {ha tenyleg kilep !!!}
               end;
             Until C In [YesChar,NoChar];
     bool := remove_window;
    end;
End;


{-----------------------------------------------------}

procedure open_modem_out;

  var vege : boolean;
      proba: word;

Begin
   modemerror := 0;
   tmut:= 0;
   proba := 1;
   bool  := create_window(16,8,77,12,mmsg6,CA[DispMode,1],CA[DispMode,3]);

   open_puffer;
   repeat
     gotoxy(2,2); write(mmsg1,' ',proba:4,mmsg7,' ',mmsg8,modemerror);
     modem_to_transmit;
     inc (proba);
     vege := kilep;
   until (modemerror = 0) or vege;
   ClrScr;
   if vege then
     begin
       bool := remove_window;
       close_puffer;
     end;

End;

{-----------------------------------------------------}

procedure open_modem_inp;


  var vege : boolean;
      proba: word;

Begin
   modemerror := 0;
   tmut := 0;
   eof_modem := False;
   elsoreadln := true;
   proba := 1;
   bool  := create_window(16,8,77,12,mmsg6,CA[DispMode,1],CA[DispMode,3]);

   open_puffer;
   repeat
     gotoxy(2,2); write(mmsg1,' ',proba:4,mmsg7,' ',mmsg8,modemerror);
     modem_to_receive;
     inc (proba);
     vege := kilep;
   until (modemerror = 0) or vege;

   ClrScr;

   if vege then
     begin
       bool := remove_window;
       close_puffer;
     end;

End;

{-----------------------------------------------------}

procedure writeln_modem (ez: string; KellCr : Boolean);

  var vege : boolean;
      proba: word;
      hossz: byte;
      maradek : byte;
      bele    : byte;

Begin
  If KellCr Then
    ez := ez + #13;
  hossz := Byte(ez[0]);
  If Tmut + Hossz >= 128 Then
    Begin
      Bele    := 128-tmut;
      Maradek := Hossz-bele;
      Move(ez[1],tomb[tmut+1],Bele);

      Proba := 0;
      repeat
        gotoxy(2,2); write(absrek:5,mmsg2,' ',proba,mmsg7,' ',mmsg8,modemerror);
        send_modem(tomb);
        inc(proba);
        vege := kilep;
      until (modemerror = 0) or vege;

      if vege then
       begin
         bool := remove_window;
         close_puffer;
       end;

      move(ez[bele+1],tomb[1],maradek);
      tmut := Maradek;
    End

  Else
    Begin
      Move(ez[1],tomb[tmut+1],Hossz);
      inc(tmut,Hossz)
    End;
End;

{-----------------------------------------------------}

procedure readln_modem2 (var ez: string);

  var vege : boolean;
      proba: word;
      hur  : byte;
      b    : byte;
      vancr : Boolean;

Begin

     vancr := false;
     ez    := '';

  repeat

     if tmut <> 0 then
      repeat
         b := tomb[tmut];
         if b <> 13 then
           ez := ez + char(tomb[tmut])
         else
           vancr := true;
         inc(tmut);
         if tmut <=128 then
           begin
            if tomb[tmut] = 0
             then nomore := true;
           end
         else if vancr then tmut := 0;

      until vancr or (tmut > 128);


      if not vancr then
       begin
         Proba := 0;
         repeat
           gotoxy(2,2); write(absrek:5,mmsg3,' ',proba,mmsg7,' ',mmsg8,modemerror);
           get_modem(tomb);
           inc(proba);
           vege := kilep;

           if not vege then
             if modemerror = 0 then ready_for_next
                               else repeat_last;

         until (modemerror = 0) or vege;

         if vege then
           begin
             {bool := remove_window;  $$$$$ }
             close_puffer;
           end;

         tmut := 1;

       end;

  until vege or vancr;

End;
{-----------------------------------------------------}
Procedure Readln_Modem(var ez: string);

Begin

   If elsoreadln then
    begin
      readln_modem2(ez);
      readln_modem2(visszaad);
      elsoreadln := false;
    end
   else
    begin
     ez := visszaad;
     readln_modem2(visszaad);
     eof_modem   := elozonomore;
     elozonomore := nomore;
    end;

End;

{-----------------------------------------------------}

procedure close_modem_out;

  var proba : word;

        vege  : Boolean;
Begin

  if tmut  <> 0 then
   Begin
      fillchar(tomb[tmut+1],128-tmut,#0);

      Proba := 0;
      repeat
            gotoxy(2,2); write(absrek:5,mmsg2,' ',proba,mmsg7,' ',mmsg8,modemerror);
            send_modem(tomb);
        inc(proba);
        vege := kilep;
      until (modemerror = 0) or vege;

   End;

   end_of_transmission;
   close_puffer;
   bool := remove_window;

End;
{-----------------------------------------------------}

procedure close_modem_inp;

Begin

   close_puffer;
   bool := remove_window;

End;

Procedure BreadMM (var tomb: modemtomb);

Var vege    : boolean;
    proba   : Integer;
Begin
     Proba := 0;
     repeat
       gotoxy(2,2); write(absrek:5,mmsg3,' ',proba,mmsg7,' ',mmsg8,modemerror);
       get_modem(tomb);
       inc(proba);
       vege := kilep;
        if not vege then
         if modemerror = 0 then ready_for_next
                           else repeat_last;
      until (modemerror = 0) or vege;
      if vege then
       begin
         bool := remove_window;
         close_puffer;
       end;

End;

Procedure BreadM(var ez: modemtomb);

Begin
  If elsoreadln then
    begin
      BreadMM(ez);
      If Modemerror = 0 then
       Begin
         BreadMM(visszatomb);
         eof_modem := nomore;         {csak 1 blokk volt}
       End;
      elsoreadln := false;
    end
   else
    begin
     ez := visszatomb;
     if not elozonomore then BreadMM(visszatomb);
     eof_modem   := elozonomore;
     elozonomore := nomore;
    end;

    if eof_modem then modemerror := 0;

End;

Procedure BwriteM(tomb: modemtomb);

Var proba: integer;
    vege : boolean;

Begin
      Proba := 0;
      repeat
        gotoxy(2,2); write(absrek:5,mmsg2,' ',proba,mmsg7,' ',mmsg8,modemerror);
        send_modem(tomb);
        inc(proba);
        vege := kilep;
      until (modemerror = 0) or vege;

      if vege then
       begin
         bool := remove_window;
         close_puffer;
       end;
End;

End.

