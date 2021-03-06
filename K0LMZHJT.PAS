
                   { --------------------------- }
                            UNIT K0LmzHjt;
                   { --------------------------- }
                   { --------------------------- }
                              INTERFACE
                   { --------------------------- }
USES Crt,
     Dos,
     K0Adatok,
     K0RdDscT,
     K0Csere,
     K0ErrHdl,
     WindowM;

PROCEDURE PasztazoTev(var Konyvtar : PathStr);

{ Ez az elj�r�s a fastruktur�j� k�nyvt�rszerkezettel kapcsolatos VEZ�RL�SI}
{ feladatokat v�gzi el: l�ptet�s, meghajt�csere, visszat�r�s a hiv� programba}
{ k�nyvt�rkijel�l�ssel vagy an�lk�l. A k�nyvt�rbeolvas�s teend�it a K0RdDisc }
{ Unit-ban defini�lt elj�r�sok v�gzik el.}


                   { --------------------------- }
                            IMPLEMENTATION
                   { --------------------------- }


Const
   ErvBillSzam = TevIdxMax;  { Most �ppen egyenl�ek; de lehetne m�sk�nt is.}

   { Az ErvBillSzam-nak(=7) megfelel� tev�kenys�gek indexei:}
   F3Idx       = 1;
   FelNyilIdx  = 2;
   BalNyilIdx  = 3;
   JobbNyilIdx = 4;
   LeNyilIdx   = 5;
   EnterIdx    = 6;
   EscIdx      = 7;

Var
   MenuDekod : DekodoloTomb;
   Statusz   : word;

   VanArraKvt    : array[FelNyilIdx..LeNyilIdx] of function : boolean;

{ A k�perny�r�l kifut�sok kezel�s�t segit� v�ltoz�k:}
   Kiirhato  : boolean;
   HivoKvt,
   HivottKvt : KvtMut;

   ValasztottPath : PathStr;



              { **********  Elj�r�sok, f�ggv�nyek  **********}

{ ------- }

{$F+}
                             {  * * * * *  }

                { A hiv� men�szintre l�p� tev�kenys�gek: }

                             {  * * * * *  }


{ ------- }

Procedure Megjeloles(Szin:byte);
Var
   X,Y   : integer;
Begin
  TextAttr := Szin;
  IF  HivoKvt = @Gyoker
  THEN WriteXY(2,KepKezdoSor,chr(DefaultDriver)+':\')
  ELSE
  begin
    X := Lo(HivoKvt^.Osz) - ElsoIrhatoOszlop;
    X := (X shl 4 ) - X + KepKezdoOszlop + 2;
    WriteXY(X,HivoKvt^.Sor - ElsoIrhatoSor + KepKezdoSor,HivoKvt^.Name);
  end;

End;  { Megjeloles }

{ ------- }

Procedure NyitoTev;
Begin
  { �KSZER! Ide be kell tenni a munkaablak eredeti tartalm�nak elment�s�t is!}

  Vedd_TeddATeljesLemezt;
  HivoKvt := @Gyoker;          {Kiindul�helyzet.}
  HivottKvt := HivoKvt;        {Kiindul�helyzet.}
  Megjeloles(CA[DispMode,12]); { �KSZER! Aktivszin be�llit�s!}

End;  { NyitoTev }

{ ------- }

Procedure CsereTev(var Statusz : word);
Var
  Driver : byte;
Begin
  Csere(Driver);
  IF   Driver <> 0
  THEN
  begin
    DefaultDriver := Driver+64;
    NyitoTev;
  end
  ELSE MenjAMunkaAblakba;

  Statusz := $8000;

End;  { CsereTev }

{ ------- }

Procedure EscapeTev(Var Statusz: word);
Begin
  ValasztottPath := '';
  Statusz := 0;

End;  {EscapeTev}

{ ------- }

Procedure EnterKezeles(var Statusz : word);
{ Az elj�r�s m�k�d�s�nek alapelk�zel�se:
     a felhaszn�l� a kilist�zott k�nyvt�rf�n a neki tetsz� ir�nyban mozogva
     bej�rhatja annak valamennyi �g�t (ld."L�ptet�s" proc).  Ezzel fel tudja
     deriteni a lemezen tal�lhat� k�nyvt�r(ak) szerkezet�t. P�szt�zhatunk
     �ltal�noss�gban, amikor "csak �gy n�zel�d�nk", vagy kijel�lhet�nk m�sik
     k�nyvt�rat is a tov�bbi m�veletek sz�m�ra, ha a kiv�nt k�nyvt�rra pozici-
     on�l�s ut�n ENTER-t nyomunk.
}

Begin {Enterkezeles}
    ValasztottPath := HivoKvt^.Name;
    while HivoKvt^.Bal <> NIL do
       begin
           HivoKvt := HivoKvt^.Bal;
           ValasztottPath := HivoKvt^.Name + '\' + ValasztottPath;
       end;
    ValasztottPath := chr(DefaultDriver)+':' + ValasztottPath;

    { �KSZER! Szerintem ide kellene a ChDir(ValasztottPath)!!!}

    Statusz := 0;

End;  {EnterKezeles}

{ ------- }
                           {  * * * * *  }

           { A k�nyvt�rstrukt�ra felderit�s�t segit� elj�r�sok:}
                  { A kiv�nt ir�nyban van-e kvt? }

                           {  * * * * *  }

{ ------- }

Function BeleferAKepbe : boolean;
Begin
  IF    (HivottKvt^.Sor < ElsoIrhatoSor)
    OR (HivottKvt^.Sor > UtsoIrhatoSor)
    OR ((Lo(HivottKvt^.Osz) < ElsoIrhatoOszlop) AND (HivottKvt <> @Gyoker))
    OR (Lo(HivottKvt^.Osz) > UtsoIrhatoOszlop)
  THEN BeleferAKepbe := FALSE
  ELSE BeleferAKepbe := TRUE;

End;  { BeleferAKepbe }

{ ------- }

Procedure UjKezdetek;
Begin
  IF   Lo(HivottKvt^.Osz) > UtsoIrhatoOszlop
  THEN Inc(ElsoIrhatoOszlop)
  ELSE
  begin
    IF   (Lo(HivottKvt^.Osz) < ElsoIrhatoOszlop) AND (HivottKvt <> @Gyoker)
    THEN ElsoIrhatoOszlop := Lo(HivottKvt^.Osz);
  end;

  IF   HivottKvt^.Sor > UtsoIrhatoSor
  THEN ElsoIrhatoSor := HivottKvt^.Sor - KepernyoHasznosSorai + 1
  ELSE
  begin
    IF   HivottKvt^.Sor < ElsoIrhatoSor
    THEN ElsoIrhatoSor := HivottKvt^.Sor;
  end;

  UtsoIrhatoSor    := ElsoIrhatoSor + KepernyoHasznosSorai - 1;
  UtsoIrhatoOszlop := ElsoIrhatoOszlop + MaxKepenLathatoOszlop;

  {TeddKepreAFat meghiv�s�hoz Hiv�t kifuttatjuk a mez�b�l:}
  HivoKvt := HivottKvt;
  while (Lo(HivoKvt^.Osz)>=ElsoIrhatoOszlop)
    OR (HivoKvt^.Sor>ElsoIrhatoSor) do
    HivoKvt := HivoKvt^.Bal;


End;  { UjKezdetek }

{ ------- }

Procedure Leptetes(Var Statusz : word);
{Ezzel az elj�r�ssal v�gezz�k el a k�nyvt�rf�n a l�ptet�st. Jellegzetes pa-}
{ram�terei a HivottKvt �s HivKvt v�ltoz�k: ezeket glob�lisan kezelj�k, teh�t}
{nem szerepelnek a param�ter�tad�sokban, mint ahogy ElsoIrhatoSor/Oszlop sem!}
{A l�ptet�s IR�NYA param�terezett : Hi(Statusz)-ba lett belek�dolva.}

Begin
    IF VanArraKvt[Hi(Statusz)] {Ha van, be�llitja a HIVOTT k�nyvt�rat}
    THEN
    begin
      IF BeleferAKepbe
      THEN
      begin
        Megjeloles(CA[DispMode,20]);  { �KSZER! Alapszin be�llit�s!}
        HivoKvt := HivottKvt;         { HIVO-t VanArraKvt fogja vizsg�lni.}
        Megjeloles(CA[DispMode,12]);  { �KSZER! Aktivszin be�llit�s!}
      end
      ELSE
      begin
        UjKezdetek;
        TextAttr := CA[DispMode,20];  { �KSZER! Alapszin be�llit�s! }
        ClrScr;
        IF  (ElsoIrhatoOszlop = 1) AND (ElsoIrhatoSor = 1)
        THEN IrdKiAGyokeret; { �� Ezt akkor kell megtenni, ha nem a Gy�keret}
        {sz�litjuk meg, hanem egy m�s kvt-ra l�p�s miatt �llt be a kiindul�}
        {(1,1) pozici�. A Gy�k�r-megsz�lit�st a BELEFER-elj�r�s megfelel� }
        {�ga (Balr�l, Fentr�l) kezeli!}

        TeddKepreAFat(HivoKvt,ElsoIrhatoSor,ElsoIrhatoOszlop);
        HivoKvt := HivottKvt;
        Megjeloles(CA[DispMode,12]);  { �KSZER! Aktivszin be�llit�s! }
      end;
    end;

    Statusz := $8000 + Lo(Statusz);


End;  { Leptetes }

{ ------- }

Function AlattaLevo(Kvt:KvtMut) : kvtmut;
Begin
  IF   Kvt = @Gyoker {Az els� megindul�s vizsg�lata.}
  THEN
  begin
    IF   Kvt^.Lent <> NIL
    THEN AlattaLevo := Kvt^.Lent
    ELSE AlattaLevo := Kvt;
  end
  ELSE {Tov�bbi l�pked�sek kezel�se:}
  begin
    while (Kvt^.Lent = NIL) AND (Kvt <> @Gyoker) do
      Kvt := Kvt^.Bal;
    IF   Kvt = @Gyoker
    THEN AlattaLevo := Kvt   {Ezzel k�szitett�k el� a kvtfa-v�g kezel�st}
    ELSE AlattaLevo := Kvt^.Lent;
  end;

End;

{ ------- }
{ --- } Function VanHomeKvtar : boolean;
        Begin
            { Ha k�s�bb kell, akkor majd kidolgozzuk; most ne tegyen semmit: }
            VanHomeKvtar := False;

        End;  { VanHomeKvtar }

{ --- } Function VanPgUpKvtar : boolean;
        Begin
            { Ha k�s�bb kell, akkor majd kidolgozzuk; most ne tegyen semmit: }
            VanPgUpKvtar := False;

        End;  { VanPgUpKvtar }

{ --- } Function VanEndKvtar : boolean;
        Begin
           { Ha k�s�bb kell, akkor majd kidolgozzuk, most ne tegyen semmit: }
           VanEndKvtar := False;

        End;  { VanEndKvtar }
{ --- } Function VanPgDnKvtar : boolean;
        Begin
            { Ha k�s�bb kell, akkor majd kidolgozzuk, most ne tegyen semmit: }
            VanPgDnKvtar := False;

        End;  { VanPgDnKvtar }

{ --- } Function VanFentKvtar : boolean;
        Begin
            IF   Hivokvt^.Fent <> NIL
            THEN
            begin
              HivottKvt    := HivoKvt^.Fent;
              VanFentKvtar := TRUE;
            end
            ELSE VanFentKvtar := FALSE;

        End;  { VanFelKvtar }

{ --- } Function VanBalraKvtar : boolean;
        Begin
            IF   HivoKvt^.Bal <> NIL
            THEN
            begin
              HivottKvt     := Hivokvt^.Bal;
              VanBalraKvtar := TRUE;
            end
            ELSE VanBalraKvtar := FALSE;

        End;  { VanBalraKvtar }

{ --- } Function VanLentKvtar : boolean;
        Begin
          HivottKvt := AlattaLevo(HivoKvt);
          IF   HivottKvt = @Gyoker   {Ki�rt�nk a k�nyvt�rfa v�g�re!}
          THEN VanLentKvtar := FALSE
          ELSE VanLentKvtar := TRUE;
        End;  { VanLentKvt }

{ --- } Function VanJobbraKvtar : boolean;
        Begin
          IF   HivoKvt^.Jobb <> NIL
          THEN
          begin
            HivottKvt := HivoKvt^.Jobb;
            VanJobbraKvtar := TRUE
          end
          ELSE
          begin
            HivottKvt := AlattaLevo(HivoKvt);
            IF   HivottKvt = @Gyoker     {Ki�rt�nk a k�nyvt�rfa v�g�re!}
            THEN VanJobbraKvtar := FALSE
            ELSE
            begin
              Statusz := LeNyilIdx shl 8 + Lo(Statusz); { Ir�nyv�lt�s !!}
              VanJobbraKvtar := TRUE;
            end;
          end;
        End;  { VanJobbraKvtar }
{$F-}
{ --- } Procedure VanArraKvt_Toltese;
        Begin
            VanArraKvt[FelNyilIdx]  := VanFentKvtar;
            VanArraKvt[BalNyilIdx]  := VanBalraKvtar;
            VanArraKvt[JobbNyilIdx] := VanJobbraKvtar;
            VanArraKvt[LeNyilIdx]   := VanLentKvtar;

{ --- } End;  { VanArraKvtar_Toltese }

{ ------- }

Procedure DekodTombToltes;
Begin {DekodTombToltes}

  with MenuDekod[F3Idx] do
  begin  Kod := _F3;   Tedd := CsereTev;     end;

  with MenuDekod[FelNyilIdx] do
  begin  Kod := _FelNyil;   Tedd := Leptetes;     end;

  with MenuDekod[BalNyilIdx] do
  begin  Kod := _BalNyil;   Tedd := Leptetes;     end;

  with MenuDekod[JobbNyilIdx] do
  begin  Kod := _JobbNyil;  Tedd := Leptetes;     end;

  with MenuDekod[LeNyilIdx] do
  begin  Kod := _LeNyil;    Tedd := Leptetes;     end;

  with MenuDekod[EnterIdx] do
  begin  Kod := _ENTER;      Tedd := EnterKezeles; end;

  with MenuDekod[EscIdx] do
  begin  Kod := _ESC;        Tedd := EscapeTev;    end;


End;  {DekodTombToltes}

{ ------- }

Procedure Illesztes;
Begin
  { �KSZER! Ide kell betenni a k�pvissza�llit�si,stb. tev�kenys�geket! }

End;  { Illesztes }

{ ------- }

Procedure PasztazoTev{var Konyvtar : PathStr};
{ A Konyvtar string �res, ha ESC-el sz�llnak ki az elj�r�sb�l. ENTER beirja}
{ a kijel�lt �tvonalat, ami azt�n kint m�r kezelhet�.}
Var
  Gomb : string2;
  Idx  : word;
Begin

  NyitoTev;        { �KSZER! Megj. ld. az elj. leir�s�n�l.}

                   {Beavatkoz�s figyel�se,Dek�dol�s:}
  Repeat
    repeat
      Gomb := UpCase(ReadKey);
      IF Gomb = Funkcio
      THEN Gomb := Gomb + ReadKey;
      Idx := DekodoltTevIndex(1,ErvBillSzam,MenuDekod,Gomb);
    until Idx > 0;
                   {Tennival� vez�rszava:}
    Statusz :=  Idx shl 8 + Lo(Statusz);
    MenuDekod[Idx].Tedd(Statusz);

  Until Hi(Statusz) <> $80;

  Konyvtar := ValasztottPath;  { Kiadjuk a kijel�lt k�nyvt�rat.}
  Illesztes;  { �KSZER! Megj. ld. az elj. leir�s�n�l.}

End;  { PasztazoTev }


{ ------- }
{ ******* }

BEGIN
    VanArraKvt_Toltese;
    DekodTombToltes;

END.

{ ******* }
{ ------- }