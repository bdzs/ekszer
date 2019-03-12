Uses crt,InputKit;

Type S40 = String[40];

Const
    Ver   : String[8]  = '4.20';
    Modul : Array[2..6] Of String[20]=
    ('Grafika  :',
     'Irogep   :',
     'Korlevel :',
     'Laser    :',
     'Nyelvesz :');


Var
    N1    : Word;
    N2    : Longint;


Function CreatePassword(St:s40;melyik:Byte):S40;
VAR PW : S40;
    S1,S2 : String[20];
    Cikl  : Integer;
    PWR   : Real;
    Code  : Integer;
    P     : Integer;

Begin
  P := Pos('-',St);

  S1 := Copy(St,  1,P-1);
  S2 := Copy(St,P+1,Length(St)-P);

  Val(S1,N1,CODE);
  Val(S2,N2,CODE);

  Val(Ver,Pwr,Code);

  Pwr:=Frac(Frac(Sqrt(N1))+Frac(Sqrt(1.11111*melyik*N2/(Pwr*N1*4))));

  Str(Pwr:1:11,Pw);
  Delete(Pw,1,3);

  For Cikl := 1 To 10 Do
    Pw[Cikl] :=
      Char( ( 25*Cikl*(Byte(Pw[Cikl])+13) MOD 26 )+65 );

  CreatePassword := PW;
End;

Var
       Thour,
       Tmin,
       TSec,
       T100,

       TDay,
       TMon,
       TYear,
       Dummy     : Word;



Procedure CTime;
Begin
   Tday  := N1 Mod 31;
   TMon  := ((N1-Tday) Div 31) Mod 12;
   TYear := (N1-Tday-TMon*31) Div (12*31);

   T100  := N2 Mod 100;
   TSec  := ((N2-T100) Div 100) Mod 60;
   TMin  := ((N2-T100-100*TSec) Div (100*60)) Mod 60;
   THour := (N2-T100-100*TSec-100*60*LongInt(TMin)) Div (100*60*60);
End;

Var S    : S40;
    M    : Integer;
    Cikl : Integer;
Begin
  ClrScr;
  S := '';
  Input_String('Sorszam :',S,30);
  Gotoxy(1,2);
  Input_String('Verzio :',Ver,8);
  Writeln;
  For Cikl := 2 To 6 Do
    Writeln(Cikl:1,'. ',Modul[Cikl],'  ',CreatePassword(S,Cikl));
  Writeln;
  CTime;
  Writeln('A gyartas datuma :',TYear:3,'.',TMon:3,'.',TDay:3,'.       ',
          THour:2,':',TMin:2,':',TSec:2,'   ',T100,' szmd');

End.