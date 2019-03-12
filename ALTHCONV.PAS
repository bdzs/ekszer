Uses Dos,Crt;

var    H_name: String;
       H_name2: string;

       filebe, fileki : text;
{-----------------------------------------------------}
const
  latinst : string[4*16+5] =
  'ABVGDEXZIJKLMNOPRSTUFHCQW#|Y`*$&abvgdexzijklmnoprstufhcqw#|y`*$&:/.()';

  latinst2 : string[2*16] =  'abvgdexzijklmnoprstufhcqw#|y`*$&';

  ekszerstr: string[4*16+5] =
  'F<DULT:PBQRKVYJGHCNEA{WXIO}SM">Zf,dult;pbqrkvyjghcnea[wxio]sm''.z537\|';


   strjel : char = 'þ';    {string kezdet-veg jelolo : ' vagy " }
   ascjel : char = '[';    {kovetkezo ] -ig}

   sn : word = 000;

var fin, fout : text;
    lin : string;
    lout: string;
    finnev,foutnev : string;
    szo : string;

procedure convert;

var conv : boolean;
     p,pp,t : byte;
       c : char;
       b : word;


begin
 lout := '';
 conv := true;

 if lin = '' then exit;
 for t := 1 to length(lin) do
  begin
   c := lin[t];
   if conv then
    begin
      if c =
       strjel  then
                begin
                 conv := false;
                 lout := lout + c;
                end
      else if c =
       ascjel  then
                begin
                 inc(t);
                 lout := lout + '[';
                 repeat
                   lout := lout + lin[t];
                   inc(t);
                 until (lin[t] = ']') ;
                 LOUT := LOUT + ']';
                 {INC(T);}
                 if t>= length(lin) then exit
                end
       else
         begin
           p := pos (c,latinst);
           if p <> 0 then
            begin
             if (p < 33) and (pos (c,latinst2) > 0)
              then p := p + 32;  {kisbetu}
             lout := lout + ekszerstr[p];
            end
           else lout := lout + c;
         end;
    end              { if conv ---------------------------------}
   else
    begin
      lout := lout + c;
      if c = strjel then conv := true;
    end;
  end;
end;


{-----------------------------------------------------}



var tt,i: word;


Begin
   if paramcount <> 2 then halt(1);
   H_name  := paramstr(1);
   H_name2 := paramstr(2);


   tt := 0;

   Assign(Filebe,H_name);
   Reset(Filebe);
   Assign(Fileki,H_name2);
   Rewrite(Fileki);

   while not eof(filebe) do
    begin
     readln(filebe,lin);
     convert;
     writeln(fileki,lout);
     write(tt:4);
     inc(tt);
    end;


  close(filebe);
  close(fileki);
End.

