                         { ----------------------- }
                                UNIT K0ErrHdl;
                         { ----------------------- }
                         { ----------------------- }
                                  INTERFACE
                         { ----------------------- }

USES Crt,Dos,K0Adatok;

CONST
  TulSokKvt = -1; {DosError ezt az �rt�ket a K0RdDscT/Beolvasas-ban kaphatja.}


PROCEDURE Error(HibaKod:byte;KiegSzoveg:string);
PROCEDURE DOSErrorKezelo(var Tovabb : boolean);


                         { ----------------------- }
                                IMPLEMENTATION
                         { ----------------------- }
{ -------  }

Procedure Error{HibaKod:byte;KiegSzoveg:string};
Begin
   { �KSZER! Ezt kell kit�ltenetek a saj�t hibakezel� rutinotokkal.}
End;  { Error }

{ ------- }

Procedure DOSErrorKezelo{var Tovabb : boolean};
Begin
  IF   DOSError = 18
  THEN Tovabb := TRUE
  ELSE
  begin
         { �KSZER! Int�zkedni kell a hibak�d-sz�mit�sr�l �s a tov�bbl�p�si}
         { felt�tel (TOVABB v�ltoz�) megfelel� be�llit�s�r�l!!!! Most ez }
         { �nk�nyesen TRUE �rt�ket vesz fel!!!}

    Error(DosError,'');
    Tovabb := TRUE;

  end;
End;

{ ******* }
{ ------- }
BEGIN
END.
{ ------- }
{ ******* }

Procedure DOSErrorKezelo{var Folytathatja : boolean};
Var
   StrDosErr : string70;
Begin

   CASE DosError of

       18 : Folytathatja := True;      { Nincs t�bb file; DosError 18 marad. }

      152 : Parbeszed(Folytathatja,DOS152); { Lemezegys�g nincs k�sz. }

      154 : Parbeszed(Folytathatja,DOS154); { Lemezadat CRC hib�ja. }

      156 : Parbeszed(Folytathatja,DOS156); { Keres�si hiba: nincs meg a keresett }
                                       { s�v; pl. nincs B-floppy. }

      162 : Parbeszed(Folytathatja,DOS162); { �ltal�nos HW-hiba: pl. hib�s lemez. }

        3 : Parbeszed(Folytathatja,DOS3); { Nincs a megadott �t: pl. nincs D-Winch}

        5 : Tajekoztat(DOS5); { Az �llom�nyhozz�f�r�s tiltott }

        6 : Tajekoztat(DOS6);  { Hib�s hozz�f�r�si k�d; megs�r�lt a file.}

      101 : Parbeszed(Folytathatja,IO101); { Lemezir�si hiba }

      103 : Tajekoztat(IO103);  { Az �llom�ny nincs nyitva.}

   ELSE begin { Valamilyen m�s hiba �rkezett: }
            Str(DosError,StrDOSErr);   { DosError karakteres form�ra hoz�sa }
            StrDOSErr := ' Azonositatlan DOS-hiba ('+StrDOSErr+')!  Ism�teljek vagy Ne?  I/N ';
            Parbeszed(Folytathatja,StrDOSErr);
        end;

   END;

End;  { DOSErrorKezelo }
