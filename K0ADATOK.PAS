
                         { ----------------------- }
                                UNIT K0Adatok;
                         { ----------------------- }
                         { ----------------------- }
                                  INTERFACE
                         { ----------------------- }
USES Crt,
     Dos,
     Windowm;

CONST
    MaxColor = 4; { �KSZER! Ez n�latok 22. }

{ Billenty�k�dok: }
   Funkcio  = #0;
   _Enter   = #13;
   _Esc     = #27;

   _F3      = Funkcio + #61;
   _FelNyil = Funkcio + #72;
   _BalNyil = Funkcio + #75;
   _JobbNyil= Funkcio + #77;
   _Lenyil  = Funkcio + #80;

{ A tev�kenys�gi form�k sz�ma:}
   TevIdxMax = 7;  { A 4 nyil, F3, Esc �s Enter}

{ A fastrukt�ra munkaablak�nak koordin�t�i:}
    BalFelsoX = 2;
    BalFelsoY = 5;
    JobbAlsoX = 79;
    JobbAlsoY = 21;

    KepernyoHasznosSorai = JobbAlsoY-BalFelsoY-1; { 10 hasznos +2 a nyilaknak.}

{ A fa kiirat�s ABLAKRELATIV kezd� koordin�t�i: }
    KepKezdoSor    = 2;
    KepKezdoOszlop = 5;

{ A fa kiiratasakor lathato oszlpok szama LA-VF }
    MaxKepenLathatoOszlop = ((JobbAlsoX-BalFelsoX-KepKezdoOszlop) div 14) - 1;

{ Az egyszerre l�that� meghajt�k sz�ma:}
    DrvMaxMsg = 8; {Annyi, ah�ny bites a DRVMASZK tipus.}


TYPE

{ az ABSWRITE unitban defini�ltam! Oka: a direkt ir�shoz is kellett.}
{ �KSZER! A DYAS'90-ben ez az �zenetek tipusa, de n�latok meg is sz�ntethet�:}
{   String70 = String[70];}

{ A vez�rl� gomb �s a csom�forma tipusa:}
   String2 = string[2];

{ A Kvt-beolvas�skor a nevet t�rol� v�ltoz� tipusa: }
{   String12 = string[12];}

{ A tev�kenys�g-elj�r�sok t�mb�s el�r�s�nek tipusai: }
   DekProc = Procedure(var Parameter : word);
   VezDek  = record
               Kod   : String2;
               Tedd  : DekProc;
             end;
   DekodoloTomb = array[1..TevIdxMax+DrvMaxMsg] of VezDek;

   DrvMaszk = byte;

VAR
   DefaultDriver: byte;
   DriverVektor : DrvMaszk; { A DrvMaxMsg darab driver-azonosit� t�rol�ja.}

                         { A bitek kioszt�sa: }
{    DriverVektor  7.  6.  5.  4.  3.  2.  1.  0. bit  = 1, ha  a      }
{                  H   G   F   E   D   C   B   A  meghajt� jelen van;  }
{                                                      = 0, ha nincs.  }

   DirInfo    : SearchRec;
   Gyoker     :  KvtRec;

 {  CA : array[Color..BW,1..MaxColor] of byte;  �KSZER! Ez a ti szint�mb�t�k.}

{ A fa kiir�s�t segit� v�ltoz�k: }
   ElsoIrhatoSor,
   ElsoIrhatoOszlop,
   UtsoIrhatoSor,
   UtsoIrhatoOszlop : word; { Igazodunk a KvtRec .Sor �s .Osz mezeihez! }
   {Ebbe a csoportba tartozna a KepKezdoSor/Oszlop is, de azok KONSTANSok! }

{ A kvth�l� kapcsolatok t�rol�ja:}
   CsomoForma    : array[0..3] of string2;


PROCEDURE WriteXY(X,Y:byte; Szoveg:string);

PROCEDURE MenjAMunkaAblakba;

PROCEDURE IrdKiAGyokeret;
PROCEDURE TeddKepreAFat(Aktu : KvtMut; ElsoIrhatoSor,ElsoIrhatoOszlop : word);
FUNCTION DekodoltTevIndex(Bal,Jobb:byte; Miben:DekodoloTomb; Mit:String2) : byte;


                         { ----------------------- }
                                IMPLEMENTATION
                         { ----------------------- }

{ ------- }

Procedure WriteXY{X,Y:byte; Szoveg:string};
Begin
  GotoXY(X,Y);
  Write(Szoveg);
End;  { WriteXY }

{ ------- }

Procedure MenjAMunkaablakba;
Begin
  TextAttr := CA[DispMode,20];  { �KSZER! Szinbe�llit�st elv�gezni!}
End;  { MenjAMunkaablakba }

{ ------- }

Function DekodoltTevIndex;
                    { (Bal,Jobb:byte; Miben:DekodoloTomb; Mit:String2) : byte }
Var
   Kozep : word;
Begin
   repeat
      Kozep := (Bal+Jobb) div 2;
      if Mit < Miben[Kozep].Kod
        then Jobb := Kozep-1
        else if Mit > Miben[Kozep].Kod
               then Bal := Kozep + 1
               else begin
                       DekodoltTevIndex := Kozep;
                       exit;
                    end;
   until Jobb < Bal;
   DekodoltTevIndex := 0;

End;  {DekodoltTevIndex}

{ ------- }

Procedure IrdKiAGyokeret;
Begin
    WriteXY(2,KepKezdoSor,chr(DefaultDriver)+':\');
End;  { IrdKiAGyokeret }

{ ------- }

Procedure TeddKepreAFat{Aktu : KvtMut;
                        ElsoIrhatoSor,ElsoIrhatoOszlop : word};
Var
   MehetJobbra,
   BentVolt         : boolean;
   Hatarolo         : KvtRec;



{ --- } Procedure VizszintesVonal_Csomo_NevKiiras(Aktu : KvtMut);
        Var
           i,X,Y : byte;
        Begin
            X := Lo(Aktu^.Osz) - ElsoIrhatoOszlop;
            X := X * 15+KepKezdoOszlop-1;
                      { ez X*15+3, mert 1-gyel el�bb fejezz�k be! }

            Y := Aktu^.Sor - ElsoIrhatoSor + KepKezdoSor;
            for i := WhereX to X do
               WriteXY(i,Y,'�');

            write(CsomoForma[Hi(Aktu^.Osz)]+Aktu^.Name);

        End;   { VizszintesVonal_Csomo_NevKiiras }



{ --- } Procedure Csomo_NevKiiras(Aktu : KvtMut);
        Var
           i,X,Y : byte;
        Begin
            X := Lo(Aktu^.Osz) - ElsoIrhatoOszlop;
            X := X * 15 + KepKezdoOszlop;
            Y := Aktu^.Sor - ElsoIrhatoSor + KepKezdoSor;

            WriteXY(X,Y,CsomoForma[Hi(Aktu^.Osz)]+Aktu^.Name);

        End;  { Csomo_NevKiiras }



{ --- } Procedure JobbKifutasKez(Var Aktu : KvtMut);
        Var
          i : byte;
        { Ha t�lfut�s lenne, akkor a felesleges l�p�sek elker�l�s�re lez�rjuk }
        { a l�ncot a HATAROLO v�ltoz� segits�g�vel.}
        Begin
          IF   Lo(Aktu^.Osz) > UtsoIrhatoOszlop
          THEN
          begin                            { Kifutott a jobb sz�len! }
            Hatarolo      := Aktu^.Bal^;         { Hat�rolni kell. }
            Hatarolo.Jobb := NIL;
            Aktu          := @Hatarolo;
            IF   BentVolt                      
            THEN    {Bentr�l ment ki, ez�rt a nyilir�s. }
            begin
              for i := WhereX to Lo(WindMax)-Lo(WindMin)-1 do
                WriteXY(i,Aktu^.Sor-ElsoIrhatoSor+KepKezdoSor,'�');
              Write(chr(16));
            end;
          end
          ELSE
          begin
            IF   (Aktu^.Sor>=ElsoIrhatoSor) AND (Lo(Aktu^.Osz)>=ElsoIrhatoOszlop)
            THEN
            begin           { A hasznos k�z�pharmadban vagyunk. }
              IF   NOT BentVolt
              THEN
              begin {Ah���, bej�tt�nk!!! Ennek �r�m�re megjel�lj�k a sor elej�t: }
                IF   Aktu^.Bal <> @Gyoker
                THEN WriteXY(KepKezdoOszlop-3,Aktu^.Sor-ElsoIrhatoSor+KepKezdoSor,chr(17))
                ELSE GotoXY(KepKezdoOszlop,Aktu^.Sor-ElsoIrhatoSor+KepKezdoSor);

                 { �s sz�lunk, hogy m�r j� helyen vagyunk: }
                BentVolt := TRUE;
              end;
              VizSzintesVonal_Csomo_NevKiiras(Aktu);
            end;
          end;

        End;  { JobbKifutasKez }



{ --- } Procedure AlsoKifutasKez(Var Aktu : KvtMut);
        Var
          i,X,Elso,Utso : byte;
        Begin
            X := Lo(Aktu^.Osz) - ElsoIrhatoOszlop;
            X := X * 15 + KepKezdoOszlop;

            IF   BentVolt
            THEN begin
                         { F�gg�leges vonalat h�zunk ELSOt�l UTSOig majd al� }
                         { tessz�k a nev�t, vagy ha kifutott, egy Le-nyilat. }

                     Elso := Aktu^.Fent^.Sor - ElsoIrhatoSor + KepKezdoSor + 1;
                     IF   Aktu^.Sor > UtsoIrhatoSor
                      { Ha al�futna, akkor az utols� el�tti sorig dolgozunk. }
                     THEN begin               { Le-nyilat irunk, hat�rolunk. }
                              for i := Elso to KepernyoHasznosSorai+1 do
                                 WriteXY(X,i,'�');
                              WriteXY(X,KepernyoHasznosSorai+2,chr(31));
                              Hatarolo      := Aktu^;
                              Hatarolo.Lent := NIL;
                              Aktu          := @Hatarolo;
                              BentVolt      := False;
                          end
                     ELSE begin    { Nem futott ki! K�pre tessz�k a kvt-at. }
                              for i:=ELso to Aktu^.Sor-ElsoIrhatoSor+KepKezdoSor-1 do
                                 WriteXY(X,i,'�');
                              Csomo_NevKiiras(Aktu);
                              MehetJobbra := TRUE;
                          end;
                 end
            ELSE begin
                           { Sajna, nem volt bent. Megn�zz�k: be j�n-e? }

                     IF   Lo(Aktu^.Osz) < ElsoIrhatoOszlop
                     THEN begin  {Tov�bbra is kint maradt. Megn�zz�k: kifut-e?}
                              IF   AKtu^.Sor > UtsoIrhatoSor
                              THEN Aktu := @Gyoker
                                   { Teljesen kifutott; a kiir�snak v�ge! }
                              ELSE MehetJobbra := TRUE; { A l�ncnak lehet m�g }
                                             { jobbfel� men�, visszat�r� �ga! }
                          end
                     ELSE begin       { A hasznos ter�let F�L�TT vagyunk. }
                              IF   AKtu^.Sor >= ElsoIrhatoSor
                              THEN begin { Bej�tt! K�rd�s, hogy bent marad-e, }
                                         { vagy t�lfut? Addig is: Felso nyil; }
                                       WriteXY(X,1,chr(30));
                                       Elso := KepKezdoSor;

                                       IF   Aktu^.Sor > UtsoIrhatoSor
                                       THEN begin { Alulfutott. Le-nyil, hat�rol�s. }
                                                for i := Elso to KepernyoHasznosSorai+1 do
                                                   WriteXY(X,i,'�');
                                                WriteXY(X,KepernyoHasznosSorai+2,chr(31));
                                                Hatarolo      := Aktu^;
                                                Hatarolo.Lent := NIL;
                                                Aktu          := @Hatarolo;
                                            end
                                       ELSE begin    { Nem futott ki! K�pre tessz�k a kvt-at. }
                                                for i := Elso to Aktu^.Sor-ElsoIrhatoSor+KepKezdoSor-1 do
                                                   WriteXY(X,i,'�');
                                                Csomo_NevKiiras(Aktu);
                                                MehetJobbra := TRUE;
                                                BentVolt    := TRUE;
                                            end;
                                   end
                              ELSE MehetJobbra := True;
                              {Az igaz, hogy kint maradt, de jobbra m�g mehet!}
                          end;
                 end;

        End;  { AlsoKifutasKez }



{ --- } Procedure BalKifutasKez(Aktu : KvtMut);
        Var
          X : byte;
        Begin
            IF   Aktu^.Sor < ElsoIrhatoSor
            THEN begin         { Fent kifutottunk, �s m�r eggyel BALRA vagyunk! }
                     X := Lo(Aktu^.Jobb^.Osz) - ElsoIrhatoOszlop;
                     X := X * 15 + KepKezdoOszlop;
                     WriteXY(X,1,chr(30));
                     BentVolt := FALSE;
                 end
            ELSE begin
                     IF  (Lo(Aktu^.Osz) < ElsoIrhatoOszlop)
                       AND
                         (Aktu^.Name <> Gyoker.Name)
                     THEN begin           { Baloldalt kifutottunk! }
                              WriteXY(2,  { Kiirjuk a BalNyilat. }
                                      Aktu^.Sor-ElsoIrhatoSor+KepKezdoSor,
                                      chr(17));
                              BentVolt := FALSE;
                          end
                     ELSE BentVolt := TRUE;
                 end;

        End;  { BalKifutasKez }



                { Itt kezd�dik TeddKepreAFat t�rzse: }
Begin
   BentVolt := False;

   Repeat
        IF Aktu^.Jobb <> NIL                        { Van-e JOBBRA k�nyvt�r? }
        THEN begin
                 Aktu := Aktu^.Jobb;
                 JobbKifutasKez(Aktu);
             end
        ELSE begin { Jobbra nem mehetett, teh�t lefel� vagy balra kell menni,}
                   { amig jobbra nem mehet�nk vagy a kiir�s a v�g�hez nem �r.}
                 MehetJobbra := FALSE;
                 Repeat
                      IF   Aktu^.Lent <> NIL        { Van-e LEFELE k�nyvt�r? }
                      THEN begin
                               Aktu := Aktu^.Lent;
                               AlsoKifutasKez(Aktu); { MehetJobbra itt v�ltozhat! }
                           end
                      ELSE begin    { Lefel� nincs l�nc: Balra kell menn�nk! }
                               Aktu := Aktu^.Bal;
                               IF (Aktu^.Sor <= UtsoIrhatoSor) { Benne lett�nk-e? }
                                 AND
                                  (Aktu^.Sor >= ElsoIrhatoSor)
                                 AND
                                  (Lo(Aktu^.Osz) >= ElsoIrhatoOszlop)
                               THEN BentVolt := TRUE
                               ELSE begin
                                        IF   BentVolt
                                        THEN BalKifutasKez(Aktu);
                                    end;
                           end;
                 Until MehetJobbra OR (Aktu = @Gyoker);
             end;

   Until Aktu = @Gyoker;

End;  { TeddKepreAFat }

{ ------- }

Procedure CsomoFormaToltes;
Begin
    CsomoForma[0] := '��';
    CsomoForma[1] := '��';
    CsomoForma[2] := '��';
    CsomoForma[3] := '��';

End;  { CsomoFormaToltes }



{ ******* }
{ ------- }
BEGIN
  New(KvtTomb);
{ �KSZER! CA[...]  t�lt�s�t vegy�tek ki, Csom�forma t�lt�se maradjon!! }
{
  CA[Color,1] := Cyan*16+Black;
  CA[Color,2] := Black*16+White;
  CA[Color,3] := LightGray*16+Black;
  CA[Color,4] := LightGray*16+Red;
}
  CsomoFormaToltes;
END.
{ ******* }
{ ------- }
