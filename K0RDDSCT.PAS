

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

            { ******* Az elj†r†sok Çs fÅggvÇnyek: ******* }

{ ------- }

Procedure VeddALemezNevet(Var Toltendo : KvtRec);
Var
   i          : byte;
   Ut         : PathStr;
   MenjTovabb : boolean;

Begin
   Ut := chr(DefaultDriver)+':\*.*';
   MenjTovabb := True;
   Toltendo.Name :='Nincs neve!'; { Ha nem tal†lunk nevet, akkor ez marad! }

   REPEAT
     FindFirst(Ut,$FF,DirInfo);
     While DosError = 0 do
     begin
       IF ((DirInfo.Attr AND VolumeId ) = VolumeId)
       THEN
       begin
         DosError := 18;             { A HIBAKEZELô RUTINOM MIATT KELL!}
         i := Pos('.',DirInfo.Name);

         with Toltendo do
         begin
           Name := copy(DirInfo.Name,1,i-1)+
                   copy(DirInfo.Name,i+1,Length(DirInfo.Name)-i);
           Attr := DirInfo.Attr;
           { Toltendo tov†bbi mezeinek feltîltÇse Çrtelmetlen! }
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
   { A lemeznÇv helyÇnek tîrlÇse a keret-karakterekkel:}
   Kezdet := Lo(WindMax-24);

   { êKSZER! Abszolut kiirat†s lesz; ha a szin is fontos,}
   { akkor az attributumot is kezelî proc-ra van szÅksÇg!}
{   for i := Kezdet to Lo(WindMax) do
     AbsWriteXY[VideoMode](i,Pred(BalFelsoY),'ƒ');
}
   { A lemeznÇv kiirat†sa FLEXIBILIS(jobbra igazitott) kezdettel;}
   { a 12 nem m†s, mint a ' LemeznÇv: ' Çs a ' ' teljes hossza!}

   { êKSZER! Abszolut kiirat†s lesz; ha a szin is fontos,}
   { akkor az attributumot is kezelî proc-ra van szÅksÇg!}
   Display(LemLabel+KotetNev+' ',Pred(BalFelsoY),Kezdet+12-Length(KotetNev));
   Display(KvtHelpSor,JobbAlsoY+1,BalFelsoX+2)
End;  { TeddKepreALemezNevet }

{ ------- }

Procedure TeddKepreAzAktivDirt(AktivDir : PathStr);
Const
   MaxHossz = 50;  { A kiir†si mezî szÇlessÇge }

Var
   Hossz,i : byte;
Begin
   { TîrlÇs a kiirat†si helyen a keret-karakterrel:}
  { êKSZER! Abszolut kiirat†s lesz; ha a szin is fontos,}
  { akkor az attributumot is kezelî proc-ra van szÅksÇg!}
{  for i := 3 to MaxHossz+2 do
     AbsWriteXY[VideoMode](i,Pred(BalFelsoY),'ƒ');
}
   for i := 3 to MaxHossz+2 do
     Display('ƒ',Pred(BalFelsoY),i);

  Hossz := Length(AktivDir);

  IF   Hossz > MaxHossz
  THEN
  begin
    Delete(AktivDir,4,Hossz-MaxHossz+1);
    Insert(chr(17),AktivDir,4);
  end;

  { êKSZER! Abszolut kiirat†s lesz; ha a szin is fontos,}
  { akkor az attributumot is kezelî proc-ra van szÅksÇg!}
{  AbsWriteXY[VideoMode](BalFelsoX+2,BalFelsoY-1,' '+AktivDir+' ');}
  Display(' '+AktivDir+' ',BalFelsoY-1,BalFelsoX+2);

End;  { TeddKepreAzAktivDirt }

{ ------- }

Procedure Vedd_TeddALemezJellemzoket;
{ A tevÇkenysÇg :
     LekÇrdezi Çs kiirja az AKTUèLIS meghajt¢ban tal†lhat¢ lemez nevÇt Çs az
     ott aktu†lis kînyvt†rat.
}

Var
   VolumeID : KvtRec;
   AktivDir : PathStr;
Begin
                           { ElvÇgezzÅk a bekÇrÇseket: }
                             { 1. Az aktiv kînyvt†rÇt: }

    GetDir(DefaultDriver-64,AktivDir);

                             { 2. A lemez nevÇt : }

    VeddALemezNevet(VolumeId);
    {^^^^ †llitja DOSERROR-t: Hib†tlan beolvas†sra DosError = 18-at ad vissza!}

    IF DosError <> 18
    THEN VolumeId.Name := 'Hib†s olv.!';

    { Ha nem volt lemeznÇv, akkor VolumeId.Name = 'Nincs neve!'}
    { marad, amit a VEDDALEMEZNEVET procedure †llitott be. }


                            { Majd kiirjuk a tal†ltakat: }
    TeddKepreAzAktivDirt(AktivDir);
    TeddKepreALemezNevet(VolumeID.Name);


End;  { Vedd_TeddALemezJellemzoket }

{ ------- }

                                {  * * * * *  }
                   { Lemezkînyvt†r beolvas†s†nak rutinjai }
                                {  * * * * *  }

{ ------- }

Procedure CsomoFormaToltes;
Begin
    CsomoForma[0] := 'ƒƒ';
    CsomoForma[1] := '¬ƒ';
    CsomoForma[2] := '√ƒ';
    CsomoForma[3] := '¿ƒ';

End;  { CsomoFormaToltes }

{ ------- }
                {$I+}
{ ------- }

Procedure ListabaVesz(Aktu : KvtMut; Var ElsoKvt,Utso : KvtMut);

{ Az elj†r†s a h†l¢szerÅ kînyvt†rf†t Çpiti fel: elvÇgzi a 4-ir†ny£ kapcsol¢d†-
  sok Çs a h†l¢szem-koordin†t†k feltîltÇsÇt. 3 glob†lis v†ltoz¢t kezel: a Sor-
  Çs OszEltol†st (az ÇrtÇkeket a fîproc.-t¢l kapja) Çs a DirInfo †ltal†nos Kvt
  rekordot. E rekord .OSZ mezejÇnek felsî byteja tartalmazza a megfelelî kap-
  csol¢d†si kÇp: a csom¢forma k¢dj†t, az also byte pedig az oszlop sorsz†m†t.
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
                  { ez Hi(^.Osz)-ban a 0-†s csom¢form†t adja! }
      end
      ELSE
      begin
        Utso^.Lent := Uj;
        Uj^.Fent   := Utso;
{ Az 1-es csom¢form†t csak ElsoKvt kaphatja, de csak akkor, ha az a- }
{ dott kvt-nak nem egyedÅli kvt-a. Ekkor a tîbbi kvt a  2. vagy a 3. }
{ form†t kapn†, de a Listabavesz valamennyit 2-re †llitja, mert nem  }
{ tudhatja, hogy van-e mÇg tîbb alkvt vagy nincs. Az utols¢ alkvt    }
{ csom¢form†j†nak 3-ra †t†llit†s†r¢l VeddAKvtFat gondoskodik.        }

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

        Sor := ElsoIrhatoSor; { Glob. v†lt.; VeddAKvtFat is †llitja! }
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
       THEN ListabaVesz(Aktu,ElsoKvt,Utso);  {SZAMLALO-t is †llitja!}
       FindNext(DirInfo);
     end;

     IF   Szamlalo > KvtMax
     THEN DosError := TulSokKvt; { êKSZER! Ha haszn†ltok -1-et, akkor a hiba-}
                                 { kezelî rutinomat m†s ÇrtÇkre kell †tirni!}

     DosErrorKezelo(MenjTovabb);

   Until MenjTovabb;  { DosError=18-ra DOSErrorKezelo MenjTovabb=True-t ad ! }


   Aktu^.Jobb := ElsoKvt;

End;  { Beolvasas }

{ ------- }

Procedure VeddAKvtFat{(Maszk : byte)};
{
  Az aktu†lis lemezen tal†lhat¢ kînyvt†rakat fastrukt£r†ba rendezve a mem¢ri-
  †ba olvassa. A strukt£ra jellegzetessÇge, hogy vizszintes(Bal,Jobb) Çs fÅg-
  gîleges(Fent,Lent) kapcsolatokat lÇtesit az egyes kvt-ak kîzt. MÅkîdÇse so-
  r†n beolvas¢ Çs rendezî ciklusokat hajt vÇgre.
  Egy kiindul¢ (gyîkÇr-)KvtRekorddal kezdÅnk, ehhez beolvassuk a lemez gyîkÇr-
  kînyvt†r†t. Ha a beolvas†s sor†n tîbb kvt-at is tal†ltunk, akkor valameny-
  nyit list†ba vesszÅk.
  A Beolvasas rutin kimenete az elsînek megtal†lt kvt mutat¢ja. A hiv¢ rutin
  megvizsg†lja, Çs tartalm†t¢l fÅggîen a kîvetkezîket teszi:
  HA a gyîkÇr kvt†rnak van egy vagy tîbb fîkînyvt†ra  (vagyis jobb oldali kî-
  vetîje ), AKKOR elmegy jobbra: veszi az elsî fîkînyvt†rat Çs beolvassa a hoz-
  z† tartoz¢ alkînyvt†r(aka)t. HA az elsî alkînyvt†rnak van egy vagy tîbb
  al-alkînyvt†ra (teh†t mehet jobbra), akkor veszi az elsît ... stb.
  Ezt MINDADDIG megteszi, AMIG jobbra mehet.
  HA m†r nem mehet tov†bb jobbra, AKKOR megnÇzi, hogy mehet-e lefelÇ (te-
  h†t keresi az utolj†ra olvasott alkînyvt†r kîvetkezî al-alkînyvt†r†t). Ezzel
  is elmegy addig jobbra, amig m†r nem tal†l tîbbet. Ekkor £jra lejjebb megy
  (ha lehet), stb. Mindezt ADDIG teszi, AMIG ki nem meritette a jobbra- Çs
  lefelÇ lÇpÇsi lehetîsÇgeket. EZUTèN elkezd balra visszalÇpni, ADDIG, AMIG
  £j beolvasand¢ kvt-at nem tal†l; ekkor kezdîdik a cerem¢nia elîlrîl,
  mindaddig, amig vissza nem ÇrÅnk a kiindul†si (gyîkÇr-)pozici¢ba.

  Az elj†r†s feladata a kvth†l¢ koordin†t†inak kitîltÇse is. A sorok nîvelÇsÇt
  a ListabaVesz vÇgzi (mert ez szÅri ki a "." Çs ".." kvt-akat), †m a sorok Çs
  az oszlopÇrtÇkek pontosit†sa m†r a fîelj†r†sban tîrtÇnik.
  Erre a cÇlra a SOR-(OSZ)ELTOLAS glob†lis v†ltoz¢kat haszn†ljuk.
}

Var
  Honnan,Mag : PathStr;
  Aktu       : KvtMut;
  MehetJobbra : boolean;

Begin
                  { V†ltoz¢k feltîltÇse kiindul†si ÇrtÇkkel: }
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

  Szamlalo   := 1;  {A Sz†ml†l¢ a kvttîmb elsî elemÇt indexeli.}
  ElsoIrhatoSor    := 1;
  ElsoIrhatoOszlop := 1;
  { A ElsoIrhatoSor/Oszlop ÇrtÇkeket ideiglenesen igÇnybe vesszÅk a beolvasott }
  { kvt-ak kiir†si koordin†t†inak tîltÇsÇre. A rutin vÇgÇn azonban m†r a  }
  { val¢di eltol†s-ÇrtelmÅ ÇrtÇkeket veszik fel! }


                     { Kezdîdik a ciklusos beolvas†s: }
  REPEAT
       Honnan :=  Mag + Aktu^.Name + '\*.*';
       Beolvasas(Honnan,Directory,Aktu);

       IF   Aktu^.Jobb <> NIL
       THEN begin                  { tevÇkenysÇg, ha jobbra tudunk mÇlyiteni }
                ElsoIrhatoSor := Aktu^.Sor;
                Inc(ElsoIrhatoOszlop);
                Aktu := Aktu^.Jobb;
                Mag  := Copy(Honnan,1,Pos('\*',Honnan));
            end
       ELSE begin                                { Çs ha nem megy jobbra?! }
                MehetJobbra := FALSE;
                Repeat
                     IF   Aktu^.Lent <> NIL      { akkor, ha lehet, lefelÇ; }
                     THEN begin
                              Inc(ElsoIrhatoSor);
                              Aktu       := Aktu^.Lent;
                              Aktu^.Sor  := ElsoIrhatoSor;
                              ElsoIrhatoOszlop := Succ(Aktu^.Osz AND $00FF);
                             { A helyes csom¢form†hoz null†zzuk ^^ Hi(OE)-t! }
                              MehetJobbra := TRUE;
                          end
                     ELSE begin                  { ha nem: vissza kell lÇpni.}
                                 { Elîszîr a csom¢kÇpet ellenîrizzÅk:}
                              IF   Aktu^.Fent <> Aktu^.Bal
                              THEN Aktu^.Osz := Aktu^.Osz XOR $0100; {Az uts¢ }
                                             { kvt csom¢form†j†nak rendezÇse. }
                              { VisszalÇpÇs: }
                              Aktu := Aktu^.Bal;
                              Mag := FExpand(Mag + '..');
                              if Length(Mag)> 3 then Mag := Mag + '\';
                          end;
                Until  MehetJobbra  OR  (Aktu = NIL) ;

            end;

{ Magyar†zat : a kilÇpÇs feltÇtele azÇrt a NIL, mert ha a lemezen nincs alkvt,
              vagy egy†ltal†n semmilyen bejegyzÇs, akkor a feltÇtelek a kîvet-
              kezî m¢don †llnak:
                   Aktu       = @Gyoker;
                   Aktu^.Fent = NIL,
                   Aktu^.Bal  = NIL,
                   Aktu^.Jobb = NIL,
                   Aktu^.Lent = NIL. (igy teljesÅlt Aktu^.Fent=Aktu^.Bal is...)

              MegtîrtÇnik az Aktu := Aktu^.Bal, Çs ekkor Aktu m†r <> @Gyoker!
              Vagyis Until nem a @Gyoker-rel, hanem a NIL-lel tal†lkozik !

              NIL figyelÇse m†s norm†l esetben eggyel tîbb ciklus elvÇgzÇsÇt
              jelenti, ami elviselhetî fut†sidî-nîvekedÇst okoz.}

  UNTIL Aktu = NIL;

                     { Z†r¢ be†llit†sok: }

  IF   Gyoker.Jobb <> NIL
  THEN Gyoker.Lent := Gyoker.Jobb;

  ElsoIrhatoSor := 1;
  ElsoIrhatoOszlop := 1;

End; {VeddAKvtFat }

{ ------- }

Procedure Vedd_TeddATeljesLemezt;
{ A kînyvt†rfa beolvas†sa nem szivhatja le a mem¢ri†t, ezÇrt biztositanunk
    kell a HEAP takarit†s†nak a lehetîsÇgÇt.  Erre szolg†l a  KvtFaHeapInd
    v†ltoz¢: a beolvas†s kezdÇsekor ebben t†roljuk az elsî cimet. Az elj†-
    r†st meghiv¢ rutin gondoskodik a HEAP takarit†s†r¢l, ezÇrt itt minden-
    kÇpp biztositani kell, hogy megtîrtÇnjen a bejegyzÇs (MARK)!  }

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
    VeddAKvtFat; { DefaultDriver-rîl kvt beolvas†s. }
    ClrScr;  { L.A.}

    IF DosError = 18  { Ha rendben megtîrtÇnt, akkor: }
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
                   { êKSZER! Gondoskodjatok a nektek megfelelî Åzenetrîl.}
        TextAttr := CA[DispMode,1];
        WriteXY(KepernyoHasznosSorai,6,'A gyîkÇrben nincs alkînyvt†r!');
      end;
    end;
  end;

  IF   DosError <> 18
  THEN
  begin
    TeddKepreALemezNevet('Hib†s olv.!');
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