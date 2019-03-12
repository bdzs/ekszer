Uses Dos,Crt;

var    H_name: String;
       H_name2: string;

Type

    St50 = String[50];
    St80 = String[80];

    ItemRec = Record

      Xcoor : Byte;
      YCoor : Byte;
      Len   : Byte;
      Point : Byte;

    End;

    HelpRec = Record

      Szoveg : Array[1..8] Of St50;
      Items  : Byte;
      SeeAlso: Array[1..8] Of ItemRec;

    End;

Var
   Ch,Sc              : Byte;
   Ws,Wsx,Wsy,Wsp     : St50;
   Bool,Fmode         : Boolean;
   Num,Pointi         : Integer;
   Ox,Oy,Onum         : integer;
   xpos,ypos,Kpos     : byte;
   xx,yy              : byte;
   xxx                : integer;
   Help,Buf           : Helprec;
   Tfil               : Text;
   Filebe, Fileki     : File Of HelpRec;
   X,Bc,Kc            : Integer;
   Act,Max,Cik        : Byte;
   ESC                : Boolean;
   Sor                : String[255];
   register           : registers;
   Inser              : Boolean;
   FSize              : LongInt;
   H_Tomb             : Array [1..300] of ^HelpRec;

{-----------------------------------------------------}
const
  latinst : string[4*16] =
  'ABVGDEXZIJKLMNOPRSTUFHCQW#|Y`*$&abvgdexzijklmnoprstufhcqw#|y`*$&';

  latinst2 : string[2*16] =  'abvgdexzijklmnoprstufhcqw#|y`*$&';



   strjel : char = 'þ';   {string kezdet-veg jelolo : ' vagy " }
   ascjel : char = '~';    {kovetkezo spaceig nem kell konvertalni}

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
                 lout := lout + ' ';
                 repeat
                   lout := lout + lin[t];
                   inc(t);
                 until (lin[t] = ' ') or (lin[t] = strjel) or (t > length(lin)) ;
                 if (t > length(lin)) then exit;
                 dec(t);
                end
       else
         begin
           p := pos (c,latinst);
           if p <> 0 then
            begin
             {hatha csak kisbetu!}
             pp := pos (c, latinst2);
             if pp <> 0 then
              begin
               b := $A0 + pp - 1;
               if b >= $B0 then b := b + 3*16;
               c := chr(b);
               lout := lout + c;
              end
             else
              begin
               b := $80 + p - 1;
               if b >= $B0 then b := b + 3*16;
               c := chr(b);
               lout := lout + c;
              end;
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
     read(filebe,help);
     for i := 1 to 8 do
      begin
        lin := help.szoveg[i];
        convert;
        help.szoveg[i] := lout;
      end;
     write(fileki,help);
     write(tt:4);
     inc(tt);
    end;


  close(filebe);
  close(fileki);
End.

