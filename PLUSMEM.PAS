Unit PLUSMEM;

Interface

Type
     PufferT   = Array[0..$FFF7] Of Byte;
     PufferP   = ^PufferT;

Function  Ext_Init(       Size   : LongInt;
                      MaxBufSize : Word):Integer;
          { Ezt a fuggvenyt kell a legelejen meghivni,
            a teljes memoriaszukseglet ertekevel, es a
            legnagyobb tomb meretevel. }

Function  Ext_Alloc(  Var Handle : Integer;
                          Size   : Word):Integer;
          { Ez a fuggveny allokalja a tombunk reszere a memoriat.
            A Handle nevu valtozoban visszaadott szammal hivatkozhatunk
            kesobb a tombre. }

Function  Ext_Address(    Handle : Integer;
                      Var P      : Pointer):Integer;
          { Mielott egy tombot hasznalunk, ezt a fuggvenyt hivjuk meg.
            A P nevu valtozoban a Handle-ben megjelolt tombre mutato
            pointert kapjuk meg.}

Procedure Ext_Save;
          { Ezt a eljarast a tombok feltoltesenel hasznaljuk. Ha az
            Ext_Alloc-kal lefoglalt, es az Ext_Address-szel megjelolt
            tombbe betoltottuk az adatokat, hivjuk meg ezt a fuggvenyt,
            es a tomb tartalma az XMS memoriaba masolodik. EMS eseten ez
            az eljaras nem csinal semmit, mivel ilyenkor a tombbe irt
            adatok kozvetlenul az EMS memoriaba kerulnek. }

Procedure Ext_Close;
          { Ez az eljaras felszabaditja a lefoglalt memoriat    }

Procedure Ext_Enter;
          { Most mi jovunk }

Procedure Ext_Leave;
          { Visszaallitjuk az eredetit }
{
Procedure Ext_Test;
}
Implementation

Uses XMSCDW,EMSCDW{,Printer,crt};

Const
     MaxBlocks    = 20;
     MaxPages     = MaxBlocks*4;
     MaxSzelet    = 5;
     TartalekPage = 2;

Type
     TypeOfMem = (Semmi,TXMS,TEMS);
     ERec      = Record
                   Cim    : LongInt;
                   Hossz  : Word;
                   PagesC : Word;
                   Pages  : Array[1..4] Of Byte;
                   {CHS    : Word;}
                 End;
     PRec      = Array[0..MaxSzelet] Of Word;

Var
     EHandle    : Word;
     XPuffer    : PufferP;
     ERecs      : Array[0..MaxBlocks] Of ERec;
     PRecs      : Array[0..MaxPages]  Of PRec;
     NoOfRec    : Word;
     LastHandle : Word;
     EmsSeg     : Word;
     SzabadSize : LongInt;
     OsszesPage : Integer;

Const
     MemType    : TypeOfMem = Semmi;

Function Ext_Init;
Begin
  NoOfRec    := 0;
  OsszesPage := 0;
  FillChar(ERecs,SizeOf(ERecs),0);
  FillChar(PRecs,SizeOf(PRecs),0);

  Ext_Init := 0;

  If Van_Ems And
     (Ems_Pages_Available >= ((Size Div $4000)+TartalekPage)) Then
    Begin
      MemType := TEMS;
      OsszesPage := Size Div $4000 + TartalekPage;
      Allocate_EMS_Pages(OsszesPage,EHandle);
      EmsSeg := Get_Ems_Segment;
    End
  Else
    If VanXms And (XmsMaxBlock >= ((Size+2047) Div 1024)) Then
      Begin
        If MaxAvail >= MaxBufSize Then
          Begin
            MemType := TXMS;
            GetMem(XPuffer,MaxBufSize);
            XmsAlloc((Size+2047) Div 1024,EHandle);
            SzabadSize := ((Size+2047) Div 1024)*1024;
          End
        Else
          Ext_Init := -2;  { Nincs eleg konvencionalis memoria }
      End
    Else
      Ext_Init := -1;   { Nincs eleg XMS vagy EMS }
End;

Function SzeletCim(PageSzam,SzeletSzam:Integer):Word;
Var Cikl : Integer;
    Cim  : Word;
Begin
  Cim  := 0;
  For Cikl := 0 To SzeletSzam-1 Do
    Inc(Cim,PRecs[PageSzam,Cikl]);
  SzeletCim := Cim;
End;

Function VanSzabad(                    { megnezi van-e eleg hely a page-en }
                   PageSzam   : Integer;
                   Minimum    : Word;
               Var UresSzelet : Word;
               Var SzeletSzam : Integer):Boolean;
Begin
  SzeletSzam := 0;
  UresSzelet := $4000;
  While (SzeletSzam <= MaxSzelet) And
        (PRecs[PageSzam,SzeletSzam] <> 0) Do
    Begin
      Dec(UresSzelet,PRecs[PageSzam,SzeletSzam]);
      Inc(SzeletSzam);
    End;
  VanSzabad :=  (SzeletSzam <= MaxSzelet) And
                (UresSzelet >= Minimum);
End;



Procedure SzKeres(                         { Keres egy ures szeletet   }
                  Minimum    : Word;
                  Maximum    : LongInt;
              Var PageSzam   : Integer;    { A logikai page szam       }
              Var SzeletSzam : Integer;    { Page-en beluli szeletszam }
              Var SzeletMeret: Word);      { A szelet merete           }

Var Cikl : Integer;

Begin
  PageSzam := -1;
  Cikl := 0;
  While (PageSzam=-1) And
        (Cikl < OsszesPage) Do
    If VanSzabad(Cikl,Minimum,SzeletMeret,SzeletSzam) Then
      Begin
        PageSzam := Cikl;
        If (Minimum > Maximum) Or
           (SzeletMeret > Maximum) Then
          SzeletMeret := Maximum;
        PRecs[PageSzam,SzeletSzam] := SzeletMeret;
      End
    Else
      Inc(Cikl);
End;


Function Ext_Alloc;
Var Cikl     : Integer;
    MostKell : Word;
    OsszKell : LongInt;
    PageSz   : Integer;
    SzeletSz : Integer;
    SzMeret  : Word;
Begin
  Ext_Alloc := 0;
  If NoOfRec < MaxBlocks Then
    Begin
      INC(NoOfRec);
      Handle := NoOfRec;
      If Odd(Size) Then
        Inc(Size);
      With ERecS[Handle] Do
        Case MemType Of
          TXMS : If SzabadSize >= Size Then
                   Begin
                     Cim := ERecs[NoOfRec-1].Cim +
                            ERecs[NoOfRec-1].Hossz;
                     Hossz := Size;
                   End
                 Else
                   Ext_Alloc := -3; { nincs elegendo XMS }
          TEMS : Begin
                   If Size > $C000 Then
                     Begin
                       MostKell := Size Mod $4000;
                       If MostKell = 0 Then
                         MostKell := $4000;
                     End
                   Else
                     MostKell := 1;
                   OsszKell := Size;
                   Cikl := 0;
                   Repeat
                     SzKeres(MostKell,OsszKell,PageSz,SzeletSz,SzMeret);
                     Inc(Cikl);
                     If PageSz <> -1 Then
                       Begin
                         If Cikl = 1 Then
                           Begin
                             Cim   := SzeletCim(PageSz,SzeletSz);
                             Hossz := Size;
                           End;
                         Pages[Cikl] := PageSz;
                         Dec(OsszKell,SzMeret);
                         MostKell := $4000
                       End;
                   Until (PageSz = -1) Or (OsszKell=0);

                   PagesC := Cikl;
                   If PageSz = -1 Then
                     Ext_Alloc := -2;  { Nem talalt megfelelo page-et ! }
                 End
        End { Case }
    End { ha van meg szabad blokk }
  Else
    Ext_Alloc := -1;   { Tul sok tomb ! }
End;

Function Ext_Address;
Var Cikl : Integer;
Begin
  LastHandle := Handle;
  Case MemType Of
    TXMS : Begin
             P := XPuffer;
             Xms_Down(EHandle,ERecs[Handle].Cim,P,ERecs[Handle].Hossz);
           End;
    TEMS : With ERecs[Handle] Do
             Begin
               For Cikl := 1 To PagesC Do
                 Get_Ems_PageN(EHandle,Cikl-1,Pages[Cikl]);
               P := Ptr(EmsSeg,Cim);
             End;
  End { Case }
End;

Procedure Ext_Save;
Var P    : PufferP;
    Cikl : Word;
Begin
  If MemType = TXMS Then
    Xms_Up(EHandle,XPuffer,ERecs[LastHandle].Cim,ERecs[LastHandle].Hossz);
{
  With ERecs[LastHandle] Do
    Begin
      CHS := 0;
      If MemType = TXMS Then
        P := XPuffer
      Else
        P := Ptr(EmsSeg,Cim);
      For Cikl := 0 To Hossz-1 Do
        INC(CHS,P^[Cikl])
    End;   }
End;

Procedure Ext_Close;
Begin
  Case MemType Of
    TXMS : XmsDealloc(EHandle);
    TEMS : Release_Ems(EHandle)
    End;
  MemType := Semmi
End;

Procedure Ext_Enter;
Begin
  If MemType = TEMS Then
    Save_EMS(EHandle);
End;

Procedure Ext_Leave;
Begin
  If MemType = TEMS Then
    Restore_EMS(EHandle);
End;
{
Procedure Ext_Test;
Var Cikl,Cikl2 : Integer;
    Cikl3      : Word;
    CCC : Word;
    P   : PufferP;
Begin
  For Cikl := 1 To NoOfRec Do
    With ERecs[Cikl] Do
      Begin
        Write(lst,Cikl:2,'. <',Cim,'> ',Hossz,' Pages :');
        For Cikl2 := 1 To PagesC Do
          Write(Lst,Pages[Cikl2],',');

        Ext_Enter;
        Ext_Address(Cikl,Pointer(P));
        CCC := 0;
        For Cikl3 := 0 To Hossz-1 Do
          Inc(CCC,P^[Cikl3]);
        Ext_Leave;
        Write(Lst,'  ',CHS=CCC,' CHS:',CHS,' CCC:',CCC);
        Writeln(Lst);
      End;
  For Cikl := 0 To OsszesPage-1 Do
    Begin
      Write(Lst,Cikl:2,'. ');
      For Cikl2 := 0 To MaxSzelet Do
        Write(Lst,PRecs[Cikl,Cikl2],',');
      Writeln(Lst);
    End;

End;
}
End.