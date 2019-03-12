UNIT KVTFA;

INTERFACE

USES Crt,
     Dos,
     K0Adatok, {Onnan j”n: DefaultDriver, DirInfo}
     K0LmzHjt,
     WindowM;
VAR
  UjUt : PathStr;
  Reg  : Registers;
  i    : byte;
  FloppykSzama,
  WinchekSzama : byte;


FUNCTION A_Fa : string;

IMPLEMENTATION


{ ------- }

   { KSZER! VideoMode itt kap ‚rt‚ket!}
   Procedure ChkFlppy(VAR DrversNum : byte);
{ KSZER! Ha hib t ‚szlel, akkor kil‚p a PROGRAMB¢L!!!}
{ Nektek m sk‚pp kell kezelni!}
VAR i   : byte;

BEGIN
  Intr($11,Reg);             { REndszerkonfigur ci¢ lek‚rdez‚se }
  If (Reg.AL AND $1) = $1 then
    drversNum := (Reg.Al And 192) shr 6+1
  else
    BEGIN
      ClrScr;
      WriteLn('Hi nyzik a rEndszerb”l a floppy-meghajt¢, ez‚rt a program le ll !');
      HALT(1);
    End;


End;  { ChkFlppy }

   { ------- }

   Procedure ChkWinch(VAR DrversNum : byte);
{ KSZER! Ha hib t ‚szlel, akkor kil‚p a PROGRAMB¢L!!!}
{ Nektek m sk‚pp kell kezelni!}

 VAR dir     : string[6];
     Eltolas : byte;

BEGIN

{ Ha csak egy floppy van, az els” winchester jele a C lesz; Eltol s = 2      }
{ Ha t”bb floppy van, ezek rEndre: A B (C D ..),ekkor Eltol s = FloppykSzama }

  If FloppykSzama = 1
  then Eltolas := 2
  else Eltolas := FloppykSzama;

  DrversNum:= 0;
  Repeat
    dir := chr(65+Eltolas+DrversNum)+':\*.*';
    FindFirst(dir,$FF,DirInfo);
    Inc(DrversNum);
  Until DosError <> 0;

  { Az el”z”ekben a DosError csak szond zott, igazi hiba nincs -> null zzuk. }
  DosError := 0;

  Dec(DrversNum);  { Az el”z” Until el”tt volt egy INC...}
  If DrversNum < 1  { teh t, ha nem tal lt winchestert; }
  then
  BEGIN
    WriteLn('Nincs install lt winchester! Nyomjon egy gombot!');
    Sound(850);
    Delay(1000);
    NoSound;
    Repeat Until keypressed;
    HALT;
  End
  else
  BEGIN
    If (DrversNum + FloppykSzama) > DrvMaxMsg then { KSZER! K0Adatokb¢l j”n!}
    BEGIN  { Ha t£l sok winchester partici¢t kezeln‚nk: }
      WriteLn('T”bb lemezmeghajt¢ van, mint amennyit kezelni tudok!');
      WriteLn('K‚rem, ‚rtesitse a program forgalmaz¢j t! Eln‚z‚st a k‚nyelmetlens‚g‚rt!');
      sound(400);delay(300);nosound;delay(10);
      sound(400);delay(300);nosound;delay(10);
      sound(400);delay(300);nosound;delay(10);
      sound(200);delay(600);nosound;
      HALT;
    End;
  End;

End;  { ChkWinch }

   { ------- }

   Function GetDisk : byte;
   BEGIN
     Reg.AH := $19;
     MSDos(Reg);
     GetDisk := Reg.AL+65;

   End; { GetDisk }

{ ------- }
{ ******* }

FUNCTION A_Fa : string;

BEGIN
{  New(KvtTomb);}
{ KSZER! A DriverVektor v ltoz¢ra a meghajt¢cser‚t v‚gz” elj r snak szks‚ge
          van.  A felt”lt‚s‚hez haszn lhatj tok a saj t konfigur ci¢ felismer”
          rutinjaitokat is, ha az al bbi logik t k”vetitek(ld. m‚g: K0Adatok):

                  ³                 FloppykSzama
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
WinchekSzama      ³     1          2          3          4
                  ³         v         vv        vvv       vvvv
                  ³  HGFEDCBA   HGFEDCBA   HGFEDCBA   HGFEDCBA    - bitkioszt s
                  ³                                                 (Drv.K¢dok)
     1            ³  00000101   00000111   00001111   00011111  ¿
     2            ³  00001101   00001111   00011111   00111111  > - bit‚rt‚kek
     3            ³  00011101   00011111   00111111   01111111  ³
     4            ³  00111101   00111111   01111111   11111111  Ù
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                     7.<--- 0. bit
}

{ KSZER! VIDEOMODE itt lesz be llitva:}
   Bool := CREATE_WINDOW(BalFelsoX-1,BalFelsoY-1,JobbAlsoX+1,JobbAlsoY+1,'',CA[DispMode,1],CA[DispMode,20]);

   ChkFlppy(FloppykSzama); { KSZER! ld. az elj r sn l leirtakat!}
   ChkWinch(WinchekSzama); { KSZER! ld. az elj r sn l leirtakat!}

{ Ha a meghajt¢k sz ma megfelel”, akkor FOLYAMATOSAN t”ltjk fel DriverVektort: }

   DriverVektor := 1;
   for i := 2 to FloppykSzama + WinchekSzama do
      DriverVektor :=  (DriverVektor shl 1)+1;

{ Egyfloppys rEndszerekn‚l egyet balra l‚pnk,
  az 1. bitet 0-ba, a 0.-at 1-be visszk:}
   If FloppykSzama = 1 then DriverVektor := (DriverVektor shl 1) XOR $03;

{ KSZER! Az aktu lis meghajt¢t a DEFAULTDRIVER-ben t roljuk;}
{ ha n latok m s n‚ven futna, akkor az illeszt‚sr”l gondoskodni kell!}
   DefaultDriver := GetDisk;


{  textattr := red*16+yellow;
  ClrScr;
}
  PasztazoTev(UjUt);
  A_Fa:=UjUt;
  Bool := Remove_Window
End;

BEGIN
{  New(KvtTomb);}
End.
{ ******* }
{ ------- }