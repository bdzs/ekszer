
Uses Dos,Crt;

Const  Ver : String[4] = '5.22';

Var F     : File;
    V     : String[4];
    Cik,Bc,
    Sorsz : Word;
    Code  : Integer;
    Total,
    Fs,Ft : LongInt;
    Ido   : DateTime;
    Pwr   : Array[1..6] Of Real;
    Pw    : Array[1..6] Of String[13];
    ABC   : Array['A'..'Z'] Of Word;
    Ch    : Char;


Begin

   Assign(F,'CDW.OVR');
   Reset(F,1);

   Write('Ver = ',Ver,'  ');
   Readln(V);
   If V <> '' Then Ver := V;

   Write('Sorszam = ');
   ReadLn(Sorsz);

   GetFtime(F,Ft);
   UnpackTime(Ft,Ido);

   Write('Ver = ',Ver,'  ');
   With Ido Do Writeln(Year,'.',Month,'.',Day,'   ',Hour,':',Min,':',Sec);

   Fs := Filesize(F);

   FillChar(ABC,SizeOf(ABC),0);
   Total := 0;

   Ch := #00;

   While Ch <> #27 Do
   Begin
     For Cik := 1 To 6 Do
     Begin
       Val(Ver,Pwr[Cik],Code);

       Pwr[Cik] := Frac (Frac(Sqrt(Sorsz)) + Frac(Sqrt(1.11111*Cik*Ft/(Pwr[Cik]*Fs))));

       Str(Pwr[Cik]:1:11,Pw[Cik]);
       Delete(Pw[Cik],1,3);

       For Bc := 1 To 10 Do
         Pw[Cik][Bc] :=
           Char( ( 25*Bc*(Byte(Pw[Cik][Bc])+13) MOD 26 )+65 );

     End;

     Write(Sorsz,' - ');

     For Cik := 1 To 6 Do
     Begin
       Inc(Total,10);
       For Bc := 1 To 10 Do Inc(ABC[Pw[Cik][Bc]]);
       Write(Pw[Cik],'  ');
     End;
     Writeln;

     Inc(Sorsz);
     Ch := Readkey;
   End;

   {
   GotoXY(1,23); Delline; Delline; Delline;

   For Ch := 'A' To 'Z' Do
   Begin
     Write('  ',Ch);
     GotoXY(WhereX-3,24);
     Write('---');
     GotoXY(WhereX-3,25);
     Write(100*(1.0*ABC[Ch]/Total):3:0);
     GotoXY(WhereX,23);
   End;
   }
   Close(F);

   { GotoXY(1,WhereY-5); }

End.
