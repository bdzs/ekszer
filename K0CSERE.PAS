

                   { --------------------------- }
                             UNIT K0CSERE;
                   { --------------------------- }

                   { --------------------------- }
                               INTERFACE
                   { --------------------------- }


USES Crt     ,
     Dos     ,
     K0Adatok,
     Windowm,
     K0ErrHdl ;


PROCEDURE Csere(var Meghajto : byte);
{Az elj�r�s feladata:
 A kor�bban m�r l�trehozott DRIVERVEKTOR t�rol�ja alapj�n a meghivhat� driverek
 k�perny�re vitele; ott l�ptet�si, ugr�si majd visszat�r�si szolg�ltat�s nyuj-
 t�sa.
 Kimenete : a kiv�lasztott meghajt� k�dja.
 Meghajt� = 0 - nem t�rt�nt meghajt�csere(DefaultDriver marad tov�bb);
          = 1 - az "A" meghajt� kiv�laszt�sa,
          = 2 - a "B"   - " -      - " -   , stb.

a./ L�ptet�s: a jobb �s bal kurzorvez�rl� nyilakra jobbra vagy balra l�p�nk.
              sor elej�n/v�g�n �tg�rd�l�ssel.
b./ Ugr�s   : a meghajt� bet�jel�nek lenyom�s�ra egy kijel�l�ses visszat�r�st
              hajt v�gre(ld.4.pont).
c./ Default visszat�r�s : ESC,F3,FelNyil hat�s�ra "itthagyjuk" az elj�r�st; a
              visszat�r�skor a 0-s k�dot adjuk ki.
d./ Kijel�lt visszat�r�s: Enter �s LeNyil hat�s�ra az �ppen megsz�litott meg-
              hajt�t megvizsg�ljuk: ha egyezik a DefaultDriverrel, akkor egy
              0 k�dos visszat�r�s t�rt�nik, ha nem, akkor a meghajt� sorsz�ma
              ker�l kiad�sra.
Az elj�r�st hiv� program default visszat�r�s eset�n ott folytatja a k�nyvt�rfa
p�szt�z�s�t, ahol abbahagyta, k�l�nben pedig beolvassa a  kijel�lt meghajt�t.}

                   { --------------------------- }
                            IMPLEMENTATION
                   { --------------------------- }

Const
  ErvBillSzam = DrvMaxMsg + TevIdxMax;
   F3Idx       = 1;
   FelNyilIdx  = 2;
   BalNyilIdx  = 3;
   JobbNyilIdx = 4;
   LeNyilIdx   = 5;
   EnterIdx    = 6;
   EscIdx      = 7;

  JoDrvkStr   = ' �rv�nyes meghajt�k: ';
  Eltolas     = Length(JoDrvkStr);

Var
  MenuDekod : DekodoloTomb;
  Statusz   : word;
  Driver    : byte;


{ ------- }

Procedure MenjACsereAblakba;
Begin
  Bool := CREATE_WINDOW(JobbAlsoX-2-Length(JoDrvkStr)-DrvMaxMsg*2-1-1,
         BalFelsoY+2-1,JobbAlsoX-2+1,BalFelsoY+2+1,'',CA[DispMode,2],CA[DispMode,2]);

End;  { MenjACsereAblakba }

{ ------- }

Procedure IrdKiAzErvenyeseket;
Var
  Maszk : DrvMaszk;
  i     : byte;
Begin
  WriteXY(2,1,JoDrvkStr);
  TextAttr := CA[DispMode,12];  { �KSZER! Csere alapszin be�llitand�!}
  Maszk := 1;
  for i := 1 to DrvMaxMsg do
  begin
    IF (Maszk AND DriverVektor) > 0
    THEN Writexy(Eltolas+i*2,1,chr(64+i))
    ELSE WriteXY(Eltolas+i*2,1,'�');
    Maszk := Maszk shl 1;
  end;

End;  { IrdKiAzErvenyeseket }

{ ------- }

Procedure Jeloles(Szin:byte);
Begin
  TextAttr := Szin;
  WriteXY(Eltolas+Driver*2,1,chr(64+Driver));

End;  { Jeloles }

{ ------- }

Procedure CsereNyitasa;
{ �KSZER! Itt kell el�k�sziteni a Csere tev�kenys�g m�k�d�si felt�teleit.}
{Mivel az EKSZER �s a DYAS90 k�pkezel�se k�l�nb�zik egym�st�l, a most al-}
{kalmaz�sra ker�l� elj�r�sokat ki kell v�ltanotok a saj�tjaitokra!}
{Fontos: �n most NEM fogom elmenteni a k�perny� felhaszn�lt ter�let�t, de}
{nektek ezt meg kell tennetek!}
Begin
  MenjACsereAblakba;
  { �kSZER! MentsdElAzAblakot}

  TextAttr := CA[DispMode,12]; { �KSZER! Csere ablak alapszin be�llitand�!}
  ClrScr;
  IrdKiAzErvenyeseket;

  Driver := DefaultDriver-64;
  Jeloles(CA[DispMode,20]); { �KSZER! Az aktivszin be�llitand�!}

End;  {CsereNyitasa}

{ ------- }
{$F+}

Procedure EscapeTev(var Statusz : word);
Begin
  Driver := 0;
  Statusz := 0;
End;  {EscapeTev}

{ ------- }

Procedure Hatra(var Statusz : word);
Var
  Maszk : DrvMaszk;
  OK    : boolean;
Begin
  Jeloles(CA[DispMode,12]);

{Az el�z� �rv�nyes keres�se:}
  OK := False;
  IF   Driver = 1
  THEN Driver := DrvMaxMsg;

  Maszk := 1 shl (Driver-1);

  Repeat
    Dec(Driver);
    Maszk := Maszk shr 1;

    IF (Maszk AND DriverVektor) > 0
    THEN Ok := True
  Until Ok;
  Jeloles(CA[DispMode,20]);
  Statusz := $8000;

End;  {Hatra}

{ ------- }

Procedure Elore(var Statusz : word);
Var
  Maszk : DrvMaszk;
  OK    : boolean;
Begin {Elore}
  Jeloles(CA[DispMode,12]);

{Az k�vetkez� �rv�nyes keres�se:}
  OK := False;
  IF   Driver = DrvMaxMsg
  THEN Driver := 1
  ELSE Inc(Driver);
  Maszk := 1 shl (Driver-1);

  Repeat
    IF (Maszk AND DriverVektor) > 0
    THEN Ok := True
    ELSE
    begin
      IF   Driver = DrvMaxMsg
      THEN
      begin
        Driver := 1;
        Maszk  := 1;
      end
      ELSE
      begin
        Inc(Driver);
        Maszk := Maszk shl 1;
      end;
    end;
  Until OK;
{Megvan; kiirjuk:}
  Jeloles(CA[DispMode,20]);
  Statusz := $8000;

End; {Elore}

{ ------- }

Procedure EnterKezeles(var Statusz : word);
Begin
  IF   Driver = DefaultDriver-64
  THEN Driver := 0;
  Statusz := 0;
End;  {EnterKezeles}

{ ------- }

Procedure Atallitas(var Statusz : word);
Var
  HibaKod : integer;
Begin
  Driver := Ord(MenuDekod[Hi(Statusz)].Kod[1]);
  IF   Driver = DefaultDriver
  THEN Driver := 0
  ELSE Driver := Driver-64;
  Statusz := 0;

End;  {Atallitas}

{$F-}
{ ------- }

Procedure DekodTombToltes;
Var
  i : byte;
Begin {DekodTombToltes}

  with MenuDekod[F3Idx] do
  begin  Kod := _F3;   Tedd := EscapeTev;     end;

  with MenuDekod[FelNyilIdx] do
  begin  Kod := _FelNyil;   Tedd := EscapeTev;     end;

  with MenuDekod[BalNyilIdx] do
  begin  Kod := _BalNyil;   Tedd := Hatra;     end;

  with MenuDekod[JobbNyilIdx] do
  begin  Kod := _JobbNyil;  Tedd := Elore;     end;

  with MenuDekod[LeNyilIdx] do
  begin  Kod := _LeNyil;    Tedd := EnterKezeles;     end;

  with MenuDekod[EnterIdx] do
  begin  Kod := _ENTER;      Tedd := EnterKezeles; end;

  with MenuDekod[EscIdx] do
  begin  Kod := _ESC;        Tedd := EscapeTev;    end;


  for i := Succ(EscIdx) to ErvBillSzam do
    with MenuDekod[i] do
    begin
      Kod := Chr(64+i-EscIdx);     Tedd := Atallitas;
    end;

End;  {DekodTombToltes}

{ ------- }

Procedure Illesztes;
Begin
{ �KSZER! Itt kell k�vetkeznie a k�perny�ter�let vissza�llit� rutinjaitoknak.}
{Most egy primitiv megold�st haszn�lok:}
  TextAttr := CA[DispMode,20];
  ClrScr;
{�s a k�nyvt�rfa munkaablak�ba csak a hiv� rutinban t�r�nk vissza.}

End;  { Illesztes }

{ ------- }

Procedure Csere{var Meghajto : byte};
Var
  Gomb : string2;
  Idx : word;

Begin
  CsereNyitasa;

  Repeat
    repeat
      Gomb := UpCase(ReadKey);
      IF Gomb = Funkcio
      THEN Gomb := Gomb + ReadKey;
      Idx := DekodoltTevIndex(1,ErvBillSzam,MenuDekod,Gomb);
    until Idx > 0;
    Statusz :=  Idx shl 8 + Lo(Statusz);
    MenuDekod[Hi(Statusz)].Tedd(Statusz);

  Until Hi(Statusz) <> $80;

  Meghajto := Driver;
  Illesztes;   { �KSZER! ld. a proc.-ban leirtakat!}
  Bool := Remove_Window

End;  { CsereTev }

{ ------- }
{ ******* }

BEGIN
  DekodTombToltes;
END.

{ ******* }
{ ------- }