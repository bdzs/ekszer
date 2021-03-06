

                         { ----------------------- }
                                UNIT K0RdDscT;
                         { ----------------------- }
                         { ----------------------- }
                                  INTERFACE
                         { ----------------------- }

USES Crt,
     Dos,
     WindowM,
     Video;


PROCEDURE Vedd_TeddATeljesLemezt;

                         { ----------------------- }
                                IMPLEMENTATION
                         { ----------------------- }

Uses K0Adatok,
     K0ErrHdl;



Var
   AktuDriver : byte;
   AktivDir   : PathStr;
   Szamlalo   : word;

            { ******* Az elj�r�sok �s f�ggv�nyek: ******* }

{ ------- }

Procedure VeddALemezNevet(Var Toltendo : KvtRec);
Var
   i          : byte;
   Ut         : PathStr;
   MenjTovabb : boolean;

Begin
   Ut := chr(DefaultDriver)+':\*.*';
   MenjTovabb := True;
   Toltendo.Name :='Nincs neve!'; { Ha nem tal�lunk nevet, akkor ez marad! }

   REPEAT
     FindFirst(Ut,$FF,DirInfo);
     While DosError = 0 do
     begin
       IF ((DirInfo.Attr AND VolumeId ) = VolumeId)
       THEN
       begin
         DosError := 18;             { A HIBAKEZEL� RUTINOM MIATT KELL!}
         i := Pos('.',DirInfo.Name);

         with Toltendo do
         begin
           Name := copy(DirInfo.Name,1,i-1)+
                   copy(DirInfo.Name,i+1,Length(DirInfo.Name)-i);
           Attr := DirInfo.Attr;
           { Toltendo tov�bbi mezeinek felt�lt�se �rtelmetlen! }
         end;
       end
       ELSE FindNext(DirInfo);
     end;

     DOSErrorKezelo(MenjTovabb);

   UNTIL MenjTovabb;

End;  { VeddALemezNevet }

{ ------- }

Procedure TeddKepreALemezNevet(KotetNev:string12);
Var
   Kezdet,i : byte;
Begin
   { A lemezn�v hely�nek t�rl�se a keret-karakterekkel:}
   Kezdet := Lo(WindMax-24);

   { �KSZER! Abszolut kiirat�s lesz; ha a szin is fontos,}
   { akkor az attributumot is kezel� proc-ra van sz�ks�g!}
{   for i := Kezdet to Lo(WindMax) do
     AbsWriteXY[VideoMode](i,Pred(BalFelsoY),'�');
}
   { A lemezn�v kiirat�sa FLEXIBILIS(jobbra igazitott) kezdettel;}
   { a 12 nem m�s, mint a ' Lemezn�v: ' �s a ' ' teljes hossza!}

   { �KSZER! Abszolut kiirat�s lesz; ha a szin is fontos,}
   { akkor az attributumot is kezel� proc-ra van sz�ks�g!}
   Display(LemLabel+KotetNev+' ',Pred(BalFelsoY),Kezdet+12-Length(KotetNev));
   Display(KvtHelpSor,JobbAlsoY+1,BalFelsoX+2)
End;  { TeddKepreALemezNevet }

{ ------- }

Procedure TeddKepreAzAktivDirt(AktivDir : PathStr);
Const
   MaxHossz = 50;  { A kiir�si mez� sz�less�ge }

Var
   Hossz,i : byte;
Begin
   { T�rl�s a kiirat�si helyen a keret-karakterrel:}
  { �KSZER! Abszolut kiirat�s lesz; ha a szin is fontos,}
  { akkor az attributumot is kezel� proc-ra van sz�ks�g!}
{  for i := 3 to MaxHossz+2 do
     AbsWriteXY[VideoMode](i,Pred(BalFelsoY),'�');
}
   for i := 3 to MaxHossz+2 do
     Display('�',Pred(BalFelsoY),i);

  Hossz := Length(AktivDir);

  IF   Hossz > MaxHossz
  THEN
  begin
    Delete(AktivDir,4,Hossz-MaxHossz+1);
    Insert(chr(17),AktivDir,4);
  end;

  { �KSZER! Abszolut kiirat�s lesz; ha a szin is fontos,}
  { akkor az attributumot is kezel� proc-ra van sz�ks�g!}
{  AbsWriteXY[VideoMode](BalFelsoX+2,BalFelsoY-1,' '+AktivDir+' ');}
  Display(' '+AktivDir+' ',BalFelsoY-1,BalFelsoX+2);

End;  { TeddKepreAzAktivDirt }

{ ------- }

Procedure Vedd_TeddALemezJellemzoket;
{ A tev�kenys�g :
     Lek�rdezi �s kiirja az AKTU�LIS meghajt�ban tal�lhat� lemez nev�t �s az
     ott aktu�lis k�nyvt�rat.
}

Var
   VolumeID : KvtRec;
   AktivDir : PathStr;
Begin
                           { Elv�gezz�k a bek�r�seket: }
                             { 1. Az aktiv k�nyvt�r�t: }

    GetDir(DefaultDriver-64,AktivDir);

                             { 2. A lemez nev�t : }

    VeddALemezNevet(VolumeId);
    {^^^^ �llitja DOSERROR-t: Hib�tlan beolvas�sra DosError = 18-at ad vissza!}

    IF DosError <> 18
    THEN VolumeId.Name := 'Hib�s olv.!';

    { Ha nem volt lemezn�v, akkor VolumeId.Name = 'Nincs neve!'}
    { marad, amit a VEDDALEMEZNEVET procedure �llitott be. }


                            { Majd kiirjuk a tal�ltakat: }
    TeddKepreAzAktivDirt(AktivDir);
    TeddKepreALemezNevet(VolumeID.Name);


End;  { Vedd_TeddALemezJellemzoket }

{ ------- }

                                {  * * * * *  }
                   { Lemezk�nyvt�r beolvas�s�nak rutinjai }
                                {  * * * * *  }

{ ------- }

Procedure CsomoFormaToltes;
Begin
    CsomoForma[0] := '��';
    CsomoForma[1] := '��';
    CsomoForma[2] := '��';
    CsomoForma[3] := '��';

End;  { CsomoFormaToltes }

{ ------- }
                {$I+}
{ ------- }

Procedure ListabaVesz(Aktu : KvtMut; Var ElsoKvt,Utso : KvtMut);

{ Az elj�r�s a h�l�szer� k�nyvt�rf�t �piti fel: elv�gzi a 4-ir�ny� kapcsol�d�-
  sok �s a h�l�szem-koordin�t�k felt�lt�s�t. 3 glob�lis v�ltoz�t kezel: a Sor-
  �s OszEltol�st (az �rt�keket a f�proc.-t�l kapja) �s a DirInfo �ltal�nos Kvt
  rekordot. E rekord .OSZ mezej�nek fels� byteja tartalmazza a megfelel� kap-
  csol�d�si k�p: a csom�forma k�dj�t, az also byte pedig az oszlop sorsz�m�t.
}
Var
   Uj : KvtMut;
Begin
    IF (DirInfo.Name <> '.') AND (DirInfo.Name <> '..')
    THEN
    begin
      Inc(Szamlalo);
      Uj := @KvtTomb^[Szamlalo];
      IF   ElsoKvt = NIL
      THEN
      begin
        ElsoKvt       := Uj;
        ElsoKvt^.Fent := Aktu;
        ElsoKvt^.Osz  := ElsoIrhatoOszlop;
                  { ez Hi(^.Osz)-ban a 0-�s csom�form�t adja! }
      end
      ELSE
      begin
        Utso^.Lent := Uj;
        Uj^.Fent   := Utso;
{ Az 1-es csom�form�t csak ElsoKvt kaphatja, de csak akkor, ha az a- }
{ dott kvt-nak nem egyed�li kvt-a. Ekkor a t�bbi kvt a  2. vagy a 3. }
{ form�t kapn�, de a Listabavesz valamennyit 2-re �llitja, mert nem  }
{ tudhatja, hogy van-e m�g t�bb alkvt vagy nincs. Az utols� alkvt    }
{ csom�form�j�nak 3-ra �t�llit�s�r�l VeddAKvtFat gondoskodik.        }

        IF   Uj^.Fent      = ElsoKvt
        THEN ElsoKvt^.Osz := ElsoIrhatoOszlop XOR $0100;

        Uj^.Osz := ElsoIrhatoOszlop XOR $0200;
      end;

      with Uj^ do
      begin
        Name := DirInfo.Name;
        Attr := Dirinfo.Attr;

        Bal  := Aktu;
        Jobb := NIL;
        Lent := NIL;

        Sor := ElsoIrhatoSor; { Glob. v�lt.; VeddAKvtFat is �llitja! }
      end;

      Utso := Uj;
      Inc(ElsoIrhatoSor);
    end;
End;  {ListabaVesz }

{ ------- }

Procedure Beolvasas(Honnan : PathStr; Maszk : byte; Var Aktu : KvtMut);
Var
   ElsoKvt,Utso : KvtMut;
   MenjTovabb   : boolean;
Begin
   ElsoKvt := NIL;
   Utso    := NIL;
   MenjTovabb := False;

   Repeat
     FindFirst(Honnan,$10,DirInfo);
     while (DosError = 0) AND (Szamlalo <= KvtMax) do
     begin
       IF   (DirInfo.Attr AND Maszk) = Maszk
       THEN ListabaVesz(Aktu,ElsoKvt,Utso);  {SZAMLALO-t is �llitja!}
       FindNext(DirInfo);
     end;

     IF   Szamlalo > KvtMax
     THEN DosError := TulSokKvt; { �KSZER! Ha haszn�ltok -1-et, akkor a hiba-}
                                 { kezel� rutinomat m�s �rt�kre kell �tirni!}

     DosErrorKezelo(MenjTovabb);

   Until MenjTovabb;  { DosError=18-ra DOSErrorKezelo MenjTovabb=True-t ad ! }


   Aktu^.Jobb := ElsoKvt;

End;  { Beolvasas }

{ ------- }

Procedure VeddAKvtFat{(Maszk : byte)};
{
  Az aktu�lis lemezen tal�lhat� k�nyvt�rakat fastrukt�r�ba rendezve a mem�ri-
  �ba olvassa. A strukt�ra jellegzetess�ge, hogy vizszintes(Bal,Jobb) �s f�g-
  g�leges(Fent,Lent) kapcsolatokat l�tesit az egyes kvt-ak k�zt. M�k�d�se so-
  r�n beolvas� �s rendez� ciklusokat hajt v�gre.
  Egy kiindul� (gy�k�r-)KvtRekorddal kezd�nk, ehhez beolvassuk a lemez gy�k�r-
  k�nyvt�r�t. Ha a beolvas�s sor�n t�bb kvt-at is tal�ltunk, akkor valameny-
  nyit list�ba vessz�k.
  A Beolvasas rutin kimenete az els�nek megtal�lt kvt mutat�ja. A hiv� rutin
  megvizsg�lja, �s tartalm�t�l f�gg�en a k�vetkez�ket teszi:
  HA a gy�k�r kvt�rnak van egy vagy t�bb f�k�nyvt�ra  (vagyis jobb oldali k�-
  vet�je ), AKKOR elmegy jobbra: veszi az els� f�k�nyvt�rat �s beolvassa a hoz-
  z� tartoz� alk�nyvt�r(aka)t. HA az els� alk�nyvt�rnak van egy vagy t�bb
  al-alk�nyvt�ra (teh�t mehet jobbra), akkor veszi az els�t ... stb.
  Ezt MINDADDIG megteszi, AMIG jobbra mehet.
  HA m�r nem mehet tov�bb jobbra, AKKOR megn�zi, hogy mehet-e lefel� (te-
  h�t keresi az utolj�ra olvasott alk�nyvt�r k�vetkez� al-alk�nyvt�r�t). Ezzel
  is elmegy addig jobbra, amig m�r nem tal�l t�bbet. Ekkor �jra lejjebb megy
  (ha lehet), stb. Mindezt ADDIG teszi, AMIG ki nem meritette a jobbra- �s
  lefel� l�p�si lehet�s�geket. EZUT�N elkezd balra visszal�pni, ADDIG, AMIG
  �j beolvasand� kvt-at nem tal�l; ekkor kezd�dik a cerem�nia el�lr�l,
  mindaddig, amig vissza nem �r�nk a kiindul�si (gy�k�r-)pozici�ba.

  Az elj�r�s feladata a kvth�l� koordin�t�inak kit�lt�se is. A sorok n�vel�s�t
  a ListabaVesz v�gzi (mert ez sz�ri ki a "." �s ".." kvt-akat), �m a sorok �s
  az oszlop�rt�kek pontosit�sa m�r a f�elj�r�sban t�rt�nik.
  Erre a c�lra a SOR-(OSZ)ELTOLAS glob�lis v�ltoz�kat haszn�ljuk.
}

Var
  Honnan,Mag : PathStr;
  Aktu       : KvtMut;
  MehetJobbra : boolean;

Begin
                  { V�ltoz�k felt�lt�se kiindul�si �rt�kkel: }
  with Gyoker do
  begin
    Name := '';
    Fent := NIL;
    Bal  := NIL;
    Jobb := NIL;
    Lent := NIL;
    Sor  := 1;
    Osz  := 0;
  end;

  Aktu := @Gyoker;
  Mag  := chr(DefaultDriver) + ':';

  Szamlalo   := 1;  {A Sz�ml�l� a kvtt�mb els� elem�t indexeli.}
  ElsoIrhatoSor    := 1;
  ElsoIrhatoOszlop := 1;
  { A ElsoIrhatoSor/Oszlop �rt�keket ideiglenesen ig�nybe vessz�k a beolvasott }
  { kvt-ak kiir�si koordin�t�inak t�lt�s�re. A rutin v�g�n azonban m�r a  }
  { val�di eltol�s-�rtelm� �rt�keket veszik fel! }


                     { Kezd�dik a ciklusos beolvas�s: }
  REPEAT
       Honnan :=  Mag + Aktu^.Name + '\*.*';
       Beolvasas(Honnan,Directory,Aktu);

       IF   Aktu^.Jobb <> NIL
       THEN begin                  { tev�kenys�g, ha jobbra tudunk m�lyiteni }
                ElsoIrhatoSor := Aktu^.Sor;
                Inc(ElsoIrhatoOszlop);
                Aktu := Aktu^.Jobb;
                Mag  := Copy(Honnan,1,Pos('\*',Honnan));
            end
       ELSE begin                                { �s ha nem megy jobbra?! }
                MehetJobbra := FALSE;
                Repeat
                     IF   Aktu^.Lent <> NIL      { akkor, ha lehet, lefel�; }
                     THEN begin
                              Inc(ElsoIrhatoSor);
                              Aktu       := Aktu^.Lent;
                              Aktu^.Sor  := ElsoIrhatoSor;
                              ElsoIrhatoOszlop := Succ(Aktu^.Osz AND $00FF);
                             { A helyes csom�form�hoz null�zzuk ^^ Hi(OE)-t! }
                              MehetJobbra := TRUE;
                          end
                     ELSE begin                  { ha nem: vissza kell l�pni.}
                                 { El�sz�r a csom�k�pet ellen�rizz�k:}
                              IF   Aktu^.Fent <> Aktu^.Bal
                              THEN Aktu^.Osz := Aktu^.Osz XOR $0100; {Az uts� }
                                             { kvt csom�form�j�nak rendez�se. }
                              { Visszal�p�s: }
                              Aktu := Aktu^.Bal;
                              Mag := FExpand(Mag + '..');
                              if Length(Mag)> 3 then Mag := Mag + '\';
                          end;
                Until  MehetJobbra  OR  (Aktu = NIL) ;

            end;

{ Magyar�zat : a kil�p�s felt�tele az�rt a NIL, mert ha a lemezen nincs alkvt,
              vagy egy�ltal�n semmilyen bejegyz�s, akkor a felt�telek a k�vet-
              kez� m�don �llnak:
                   Aktu       = @Gyoker;
                   Aktu^.Fent = NIL,
                   Aktu^.Bal  = NIL,
                   Aktu^.Jobb = NIL,
                   Aktu^.Lent = NIL. (igy teljes�lt Aktu^.Fent=Aktu^.Bal is...)

              Megt�rt�nik az Aktu := Aktu^.Bal, �s ekkor Aktu m�r <> @Gyoker!
              Vagyis Until nem a @Gyoker-rel, hanem a NIL-lel tal�lkozik !

              NIL figyel�se m�s norm�l esetben eggyel t�bb ciklus elv�gz�s�t
              jelenti, ami elviselhet� fut�sid�-n�veked�st okoz.}

  UNTIL Aktu = NIL;

                     { Z�r� be�llit�sok: }

  IF   Gyoker.Jobb <> NIL
  THEN Gyoker.Lent := Gyoker.Jobb;

  ElsoIrhatoSor := 1;
  ElsoIrhatoOszlop := 1;

End; {VeddAKvtFat }

{ ------- }

Procedure Vedd_TeddATeljesLemezt;
{ A k�nyvt�rfa beolvas�sa nem szivhatja le a mem�ri�t, ez�rt biztositanunk
    kell a HEAP takarit�s�nak a lehet�s�g�t.  Erre szolg�l a  KvtFaHeapInd
    v�ltoz�: a beolvas�s kezd�sekor ebben t�roljuk az els� cimet. Az elj�-
    r�st meghiv� rutin gondoskodik a HEAP takarit�s�r�l, ez�rt itt minden-
    k�pp biztositani kell, hogy megt�rt�njen a bejegyz�s (MARK)!  }

Begin
  MenjAMunkaablakba;
  ClrScr;

  AktuDriver := DefaultDriver;
  Vedd_TeddALemezJellemzoket;

  IF DosError = 18
  THEN
  begin
    Writeln;
    Write('  ',KvtFaSt1);  { L.A.}
    VeddAKvtFat; { DefaultDriver-r�l kvt beolvas�s. }
    ClrScr;  { L.A.}

    IF DosError = 18  { Ha rendben megt�rt�nt, akkor: }
    THEN
    begin
      MenjAMunkaAblakba;
      IrdKiAGyokeret;

      IF   Gyoker.Jobb <> NIL
      THEN
      begin
        ElsoIrhatoSor    := 1;
        ElsoIrhatoOszlop := 1;
        UtsoIrhatoSor    := ElsoIrhatoSor + KepernyoHasznosSorai - 1;
        UtsoIrhatoOszlop := ElsoIrhatoOszlop + 4;

        TeddKepreAFat(@Gyoker,ElsoIrhatoSor,ElsoIrhatoOszlop);
      end
      ELSE
      begin
                   { �KSZER! Gondoskodjatok a nektek megfelel� �zenetr�l.}
        TextAttr := CA[DispMode,1];
        WriteXY(KepernyoHasznosSorai,6,'A gy�k�rben nincs alk�nyvt�r!');
      end;
    end;
  end;

  IF   DosError <> 18
  THEN
  begin
    TeddKepreALemezNevet('Hib�s olv.!');
    with Gyoker do
    begin
      Name := '';
      Fent := NIL;
      Bal  := NIL;
      Jobb := NIL;
      Lent := NIL;
      Sor  := 1;
      Osz  := 0;
    end;
  end;

End;  { Vedd_TeddATeljesLemezt }


{ ******* }
{ ------- }
BEGIN
END.
{ ------- }
{ ******* }
