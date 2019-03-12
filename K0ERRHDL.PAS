                         { ----------------------- }
                                UNIT K0ErrHdl;
                         { ----------------------- }
                         { ----------------------- }
                                  INTERFACE
                         { ----------------------- }

USES Crt,Dos,K0Adatok;

CONST
  TulSokKvt = -1; {DosError ezt az ÇrtÇket a K0RdDscT/Beolvasas-ban kaphatja.}


PROCEDURE Error(HibaKod:byte;KiegSzoveg:string);
PROCEDURE DOSErrorKezelo(var Tovabb : boolean);


                         { ----------------------- }
                                IMPLEMENTATION
                         { ----------------------- }
{ -------  }

Procedure Error{HibaKod:byte;KiegSzoveg:string};
Begin
   { êKSZER! Ezt kell kitîltenetek a saj†t hibakezelî rutinotokkal.}
End;  { Error }

{ ------- }

Procedure DOSErrorKezelo{var Tovabb : boolean};
Begin
  IF   DOSError = 18
  THEN Tovabb := TRUE
  ELSE
  begin
         { êKSZER! IntÇzkedni kell a hibak¢d-sz†mit†sr¢l Çs a tov†bblÇpÇsi}
         { feltÇtel (TOVABB v†ltoz¢) megfelelî be†llit†s†r¢l!!!! Most ez }
         { înkÇnyesen TRUE ÇrtÇket vesz fel!!!}

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

       18 : Folytathatja := True;      { Nincs tîbb file; DosError 18 marad. }

      152 : Parbeszed(Folytathatja,DOS152); { LemezegysÇg nincs kÇsz. }

      154 : Parbeszed(Folytathatja,DOS154); { Lemezadat CRC hib†ja. }

      156 : Parbeszed(Folytathatja,DOS156); { KeresÇsi hiba: nincs meg a keresett }
                                       { s†v; pl. nincs B-floppy. }

      162 : Parbeszed(Folytathatja,DOS162); { èltal†nos HW-hiba: pl. hib†s lemez. }

        3 : Parbeszed(Folytathatja,DOS3); { Nincs a megadott £t: pl. nincs D-Winch}

        5 : Tajekoztat(DOS5); { Az †llom†nyhozz†fÇrÇs tiltott }

        6 : Tajekoztat(DOS6);  { Hib†s hozz†fÇrÇsi k¢d; megsÇrÅlt a file.}

      101 : Parbeszed(Folytathatja,IO101); { Lemezir†si hiba }

      103 : Tajekoztat(IO103);  { Az †llom†ny nincs nyitva.}

   ELSE begin { Valamilyen m†s hiba Çrkezett: }
            Str(DosError,StrDOSErr);   { DosError karakteres form†ra hoz†sa }
            StrDOSErr := ' Azonositatlan DOS-hiba ('+StrDOSErr+')!  IsmÇteljek vagy Ne?  I/N ';
            Parbeszed(Folytathatja,StrDOSErr);
        end;

   END;

End;  { DOSErrorKezelo }
