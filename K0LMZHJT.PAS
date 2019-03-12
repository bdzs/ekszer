
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

{ Ez az elj†r†s a fastruktur†j£ kînyvt†rszerkezettel kapcsolatos VEZêRLêSI}
{ feladatokat vÇgzi el: lÇptetÇs, meghajt¢csere, visszatÇrÇs a hiv¢ programba}
{ kînyvt†rkijelîlÇssel vagy anÇlkÅl. A kînyvt†rbeolvas†s teendîit a K0RdDisc }
{ Unit-ban defini†lt elj†r†sok vÇgzik el.}


                   { --------------------------- }
                            IMPLEMENTATION
                   { --------------------------- }


Const
   ErvBillSzam = TevIdxMax;  { Most Çppen egyenlîek; de lehetne m†skÇnt is.}

   { Az ErvBillSzam-nak(=7) megfelelî tevÇkenysÇgek indexei:}
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

{ A kÇpernyîrîl kifut†sok kezelÇsÇt segitî v†ltoz¢k:}
   Kiirhato  : boolean;
   HivoKvt,
   HivottKvt : KvtMut;

   ValasztottPath : PathStr;



              { **********  Elj†r†sok, fÅggvÇnyek  **********}

{ ------- }

{$F+}
                             {  * * * * *  }

                { A hiv¢ menÅszintre lÇpî tevÇkenysÇgek: }

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
  { êKSZER! Ide be kell tenni a munkaablak eredeti tartalm†nak elmentÇsÇt is!}

  Vedd_TeddATeljesLemezt;
  HivoKvt := @Gyoker;          {Kiindul¢helyzet.}
  HivottKvt := HivoKvt;        {Kiindul¢helyzet.}
  Megjeloles(CA[DispMode,12]); { êKSZER! Aktivszin be†llit†s!}

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
{ Az elj†r†s mÅkîdÇsÇnek alapelkÇzelÇse:
     a felhaszn†l¢ a kilist†zott kînyvt†rf†n a neki tetszî ir†nyban mozogva
     bej†rhatja annak valamennyi †g†t (ld."LÇptetÇs" proc).  Ezzel fel tudja
     deriteni a lemezen tal†lhat¢ kînyvt†r(ak) szerkezetÇt. P†szt†zhatunk
     †ltal†noss†gban, amikor "csak £gy nÇzelîdÅnk", vagy kijelîlhetÅnk m†sik
     kînyvt†rat is a tov†bbi mÅveletek sz†m†ra, ha a kiv†nt kînyvt†rra pozici-
     on†l†s ut†n ENTER-t nyomunk.
}

Begin {Enterkezeles}
    ValasztottPath := HivoKvt^.Name;
    while HivoKvt^.Bal <> NIL do
       begin
           HivoKvt := HivoKvt^.Bal;
           ValasztottPath := HivoKvt^.Name + '\' + ValasztottPath;
       end;
    ValasztottPath := chr(DefaultDriver)+':' + ValasztottPath;

    { êKSZER! Szerintem ide kellene a ChDir(ValasztottPath)!!!}

    Statusz := 0;

End;  {EnterKezeles}

{ ------- }
                           {  * * * * *  }

           { A kînyvt†rstrukt£ra felderitÇsÇt segitî elj†r†sok:}
                  { A kiv†nt ir†nyban van-e kvt? }

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

  {TeddKepreAFat meghiv†s†hoz Hiv¢t kifuttatjuk a mezîbîl:}
  HivoKvt := HivottKvt;
  while (Lo(HivoKvt^.Osz)>=ElsoIrhatoOszlop)
    OR (HivoKvt^.Sor>ElsoIrhatoSor) do
    HivoKvt := HivoKvt^.Bal;


End;  { UjKezdetek }

{ ------- }

Procedure Leptetes(Var Statusz : word);
{Ezzel az elj†r†ssal vÇgezzÅk el a kînyvt†rf†n a lÇptetÇst. Jellegzetes pa-}
{ramÇterei a HivottKvt Çs HivKvt v†ltoz¢k: ezeket glob†lisan kezeljÅk, teh†t}
{nem szerepelnek a paramÇter†tad†sokban, mint ahogy ElsoIrhatoSor/Oszlop sem!}
{A lÇptetÇs IRèNYA paramÇterezett : Hi(Statusz)-ba lett belek¢dolva.}

Begin
    IF VanArraKvt[Hi(Statusz)] {Ha van, be†llitja a HIVOTT kînyvt†rat}
    THEN
    begin
      IF BeleferAKepbe
      THEN
      begin
        Megjeloles(CA[DispMode,20]);  { êKSZER! Alapszin be†llit†s!}
        HivoKvt := HivottKvt;         { HIVO-t VanArraKvt fogja vizsg†lni.}
        Megjeloles(CA[DispMode,12]);  { êKSZER! Aktivszin be†llit†s!}
      end
      ELSE
      begin
        UjKezdetek;
        TextAttr := CA[DispMode,20];  { êKSZER! Alapszin be†llit†s! }
        ClrScr;
        IF  (ElsoIrhatoOszlop = 1) AND (ElsoIrhatoSor = 1)
        THEN IrdKiAGyokeret; { ÆÆ Ezt akkor kell megtenni, ha nem a Gyîkeret}
        {sz¢litjuk meg, hanem egy m†s kvt-ra lÇpÇs miatt †llt be a kiindul¢}
        {(1,1) pozici¢. A GyîkÇr-megsz¢lit†st a BELEFER-elj†r†s megfelelî }
        {†ga (Balr¢l, Fentrîl) kezeli!}

        TeddKepreAFat(HivoKvt,ElsoIrhatoSor,ElsoIrhatoOszlop);
        HivoKvt := HivottKvt;
        Megjeloles(CA[DispMode,12]);  { êKSZER! Aktivszin be†llit†s! }
      end;
    end;

    Statusz := $8000 + Lo(Statusz);


End;  { Leptetes }

{ ------- }

Function AlattaLevo(Kvt:KvtMut) : kvtmut;
Begin
  IF   Kvt = @Gyoker {Az elsî megindul†s vizsg†lata.}
  THEN
  begin
    IF   Kvt^.Lent <> NIL
    THEN AlattaLevo := Kvt^.Lent
    ELSE AlattaLevo := Kvt;
  end
  ELSE {Tov†bbi lÇpkedÇsek kezelÇse:}
  begin
    while (Kvt^.Lent = NIL) AND (Kvt <> @Gyoker) do
      Kvt := Kvt^.Bal;
    IF   Kvt = @Gyoker
    THEN AlattaLevo := Kvt   {Ezzel kÇszitettÅk elî a kvtfa-vÇg kezelÇst}
    ELSE AlattaLevo := Kvt^.Lent;
  end;

End;

{ ------- }
{ --- } Function VanHomeKvtar : boolean;
        Begin
            { Ha kÇsîbb kell, akkor majd kidolgozzuk; most ne tegyen semmit: }
            VanHomeKvtar := False;

        End;  { VanHomeKvtar }

{ --- } Function VanPgUpKvtar : boolean;
        Begin
            { Ha kÇsîbb kell, akkor majd kidolgozzuk; most ne tegyen semmit: }
            VanPgUpKvtar := False;

        End;  { VanPgUpKvtar }

{ --- } Function VanEndKvtar : boolean;
        Begin
           { Ha kÇsîbb kell, akkor majd kidolgozzuk, most ne tegyen semmit: }
           VanEndKvtar := False;

        End;  { VanEndKvtar }
{ --- } Function VanPgDnKvtar : boolean;
        Begin
            { Ha kÇsîbb kell, akkor majd kidolgozzuk, most ne tegyen semmit: }
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
          IF   HivottKvt = @Gyoker   {KiÇrtÅnk a kînyvt†rfa vÇgÇre!}
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
            IF   HivottKvt = @Gyoker     {KiÇrtÅnk a kînyvt†rfa vÇgÇre!}
            THEN VanJobbraKvtar := FALSE
            ELSE
            begin
              Statusz := LeNyilIdx shl 8 + Lo(Statusz); { Ir†nyv†lt†s !!}
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
  { êKSZER! Ide kell betenni a kÇpvissza†llit†si,stb. tevÇkenysÇgeket! }

End;  { Illesztes }

{ ------- }

Procedure PasztazoTev{var Konyvtar : PathStr};
{ A Konyvtar string Åres, ha ESC-el sz†llnak ki az elj†r†sb¢l. ENTER beirja}
{ a kijelîlt £tvonalat, ami azt†n kint m†r kezelhetî.}
Var
  Gomb : string2;
  Idx  : word;
Begin

  NyitoTev;        { êKSZER! Megj. ld. az elj. leir†s†n†l.}

                   {Beavatkoz†s figyelÇse,Dek¢dol†s:}
  Repeat
    repeat
      Gomb := UpCase(ReadKey);
      IF Gomb = Funkcio
      THEN Gomb := Gomb + ReadKey;
      Idx := DekodoltTevIndex(1,ErvBillSzam,MenuDekod,Gomb);
    until Idx > 0;
                   {Tennival¢ vezÇrszava:}
    Statusz :=  Idx shl 8 + Lo(Statusz);
    MenuDekod[Idx].Tedd(Statusz);

  Until Hi(Statusz) <> $80;

  Konyvtar := ValasztottPath;  { Kiadjuk a kijelîlt kînyvt†rat.}
  Illesztes;  { êKSZER! Megj. ld. az elj. leir†s†n†l.}

End;  { PasztazoTev }


{ ------- }
{ ******* }

BEGIN
    VanArraKvt_Toltese;
    DekodTombToltes;

END.

{ ******* }
{ ------- }