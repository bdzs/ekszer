program desk_jet_nyomtatas_grafikusan;

type egy_kar_pix_sor = array[1..4] of byte;
     egy_kar_matrix  = array[1..50] of egy_kar_pix_sor;
     egy_kar_set     = array[31..127] of egy_kar_matrix;

    setp  = ^egy_kar_set;
    sorgyujto = array [1..80*4] of byte;
                {ebben gyulnek a bit-ek egy pixel sorra}
    sorgyujtotomb = array[1..50] of sorgyujto;
                {ebben egy teljes sor grafikusan}
    sortyp = array[1..240] of byte;

const max_set = 10;   {egyszerre ennyi fer a memoba}

var setek : array[1..max_set] of byte; {melyik set-be hanyas font van betoltve}
    utsofont : byte;  {hanyadik helyre toltottunk be utoljara}
    setpt : array[1..max_set] of setp;
    gyujto: sorgyujto; {ebben gyulnek egy pixel sor bitjei}
    gyujtotomb : sorgyujtotomb;

procedure ini_sets;
var
    t : word;
begin
   for t:= 1 to max_set do
    begin
     setek[t] := 0;   {minden set-hely szabad}
     new (setpt[t]);  {helyet csinalunk mindegyiknek}
    end;
   utsofont := 00;
end;

procedure loadfont (sorszam, tombpos: byte);

begin
end;


function getfont(att: byte): byte;

var bentvan : boolean;
    t : byte;

begin
 bentvan := false;
 t := 1;
 while (t <= max_set+1) and (not bentvan) do
  if setek[t] = att then
   begin
    getfont := setek[t];
    bentvan := true;
   end
  else inc(t);
 if bentvan then exit;

 inc(utsofont); if utsofont > max_set then utsofont := 1;
 loadfont(att,utsofont);
 getfont := utsofont;
end;

procedure insertpixek(ezt: egy_kar_pix_sor; bitpos: word);

var bytepoz, bitpoz : word;
    li : longint;
    b, t : byte;

begin
   bytepoz := bitpos div 8;
   bitpoz  := bitpos mod 8;
{
   writeln(bitpos:8,bytepoz:8, bitpoz:8);
}
   if bitpoz = 0 then move(ezt, gyujto[bytepoz], 4)
   else
    begin
      for t:= 1 to 4 do li := (li shl 8) + ezt[t];

      b := ezt[1] shr bitpoz;
      gyujto[bytepoz] := gyujto[bytepoz] or b;

      li := li shl (8-bitpoz);
      move(li, gyujto[bytepoz+1], 4);

    end;
end;


procedure bitprint(pixdb : word);

begin
end;


procedure egy_sort_osszerak(k, a: sortyp; ik: word);
                       {karakter,attributum tomb; max kar.szam a sorban}

var pixsor, karakt, t,tt : word;
    pixek : egy_kar_pix_sor;
    att,kar, fontnum: byte;

begin
 for pixsor := 1 to 50 do
  begin
    fillchar(gyujto,sizeof(gyujto),00);  {tiszta pixel-gyujto}
    for karakt := 1 to ik do
     begin
      att := a[karakt];
      kar := k[karakt];
      fontnum := getfont(att);   {ha mar bent van csak visszater
                                  kulonben betolti}

      pixek := setpt[fontnum]^[kar,pixsor];
      insertpixek(pixek,(karakt-1)*30);
     end;
    if pixsor < 20 then
     begin
       for tt := 1 to karakt*4 do
       gyujtotomb[pixsor,tt] := gyujtotomb[pixsor,tt] or gyujto[tt]
     end
    else  gyujtotomb[pixsor] := gyujto;
  end;
end;


var kartomb, attrtomb : sortyp;
    ennyibetu : word;

BEGIN
  ini_sets;
  {idejon az altalanos inicializalas a tobbi nyom-bol}
  egy_sort_osszerak(kartomb, attrtomb, 11);

END.