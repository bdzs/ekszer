{$M 8000,8000,655360}

{$I-}

Uses Dos,Crt;

Type
    ConvStringA = record
                   ezt     : string;    {mirol..mire}
                   erre    : string;
                  end;

Const
     Abort     : Boolean    = False;

     OpenError : String[20] = 'File megnyit†si';
     CloseError: String[20] = 'File lez†r†si';
     DiskWrite : String[20] = 'Diszk olvas†si';

     SameFileName: String[80] =

     'Nem lehet azonos az ASCII Çs az êkSzer file neve';

     Tabok       = 14;

     LeftMar     : Byte = 0;
     RightMar    : Byte = 76;
     Tab_Szamolo : Byte = Tabok;
     Tabulator   : Array[1..Tabok] Of Byte =
                   (6,11,16,21,26,31,36,41,46,51,56,61,66,71);

     MaxFontNum  : Byte = 10;

     FontNames   : Array[1..15] Of String[12] =

     ('STANDARD','MAGYAR','M-DOLT','M-VASTAG','M-INDEX','OROSZ','GOROG',
      'SPEC1','SPEC2','SPEC3','','','','','');

     HeadFootName: String[12] = '';

     Asc_In : ConvstringA = (ezt : '';
                             erre: '');       {file: asc_in.dat}
                                        {ha nincs file, akkor semmi,
                                        mert a CWI a FILECDW.PAS-ban
                                        gy†rilag benne van}

     Asc_Out: ConvStringA = (ezt :'!@#$^&*(<>/'+#39+'`0-=\[];"~)_+|{}:';
                             erre:'0"+!/=();:-'+'†'+'°îÅ¢ñì£Çèçôöïòßóê');
                                        {file: asc_out.dat}
                                        {ha nincs file, akkor CWI}

   CWIConvSt: Array[0..1] Of String[39] =

     ('!@#$^&*(<>/'+#39+'`0-=\[];"~)_+|{}:'+#39+#39+#39+#39+';;;``"',
      '0"+!/=();:-'+'†'+'°îÅ¢ñì£Çèçôöïòßóê'+'É'+'Ñ'+'Ö'+'Ü'+'àâäãåé');

   TablazatConvSt: Array[0..1] Of String[11] =

     ('|uionm,_+jk',
      '≥⁄¬ø¿¡Ÿƒ≈√¥');

Type
    LINETYPE = RECORD
                 Attribs : ARRAY [0..239] OF BYTE;
                 Chars   : ARRAY [0..239] OF CHAR;
               END;

    LPoint = ^LineType;

Const  {$IFDEF EKSZ_ASC}
       Ext      : String[4]  = '.ASC';
       {$ELSE}
       Ext      : String[4]  = '.DOC';
       {$ENDIF}

       IExt     : String[4]  = '';
       OutFn    : String[12] = '';
       AscIn    : String[12] = 'Asc_In.dat';
       AscOut   : String[12] = 'Asc_Out.dat';
       Header30 : Array[1..4] Of Char = (#0,'C','D',#0);
       Oxp      : Byte       = 0;
       OverWrite: Boolean    = False;
       Files    : Word       = 0;

       Controlchars : SET of BYTE = [0..31];
       NormalChars  : SET of BYTE = [16,32..126,254];
       Nulchar      : SET of BYTE = [0];

Var    TotalSorokSzama           : LongInt;
       DirInfo                   : SearchRec;
       Fi,Fo,IPath,OPath,IFn,OFn : String;
       Cik                       : Integer;
       BackPoz,
       Cik2,Xp,Xpoz              : Byte;
       AktOutFn                  : String[12];
       IORes                     : Integer;
       Buf                       : Array[1..32768] Of Byte;
       AscF                      : Text;
       EkszF,Fb                  : File;
       Code                      : Integer;
       OpenAsc                   : Boolean;

       Hour1,Minute1,Second1,Sec1001 : Word;
       Hour2,Minute2,Second2,Sec1002 : Word;

       Time1,Time2               : LongInt;
       StayTime1,StayTime2       : LongInt;

       SorPerSec                 : Real;

       attr_osszeg               : byte;
       kar_osszeg                : byte;
       puff_b,Darab              : byte;
       Header_Nev                : String[80];

       Groups,GCount,Ox,Oy,Params: Byte;
       Over                      : Boolean;
       C                         : Char;
       Group                     : Array[1..64] Of String[12];

       Gfont                     : Array [0..1] Of Byte;


Var

FSize,FilePoz : LongInt;
Percent       : Real;

Sor          : Array[-3..255] Of Byte;
SorCh        : Array[-3..255] Of Char Absolute Sor;
Hossz,Num,
Font,Count,
Azonos,
FMax,AMax    : Byte;
Poz,Opoz,
Pt,Opt       : Lpoint;
Legelso      : Boolean;
Crst         : String[2];
Ch,Kar       : Char;
SorokSzama   : word;
Azonos_attr  : Boolean;
Cikl_valt,
Fej_pos,
Old_pos      : Longint;
P            : Lpoint;

Procedure Beep;
Begin
  Sound(660);
  Delay(80);
  NoSound;
End;

Function ZipTime(Var Hour,Minute,Second,Sec100: Word): LongInt;
Begin
  Sec100 := Sec100 DIV 10;
  ZipTime := 36000*Hour+600*Minute+10*Second+Sec100;
End;

Procedure UnZipTime(Time: LongInt; Var Hour,Minute,Second,Sec100: Word);
Begin
  Hour   := Time DIV 36000;  Dec(Time,36000*Hour);
  Minute := Time DIV 600;    Dec(Time,600*Minute);
  Second := Time DIV 10;     Dec(Time,10*Second);
  Sec100 := Time;
End;

Procedure WriteHelp;
Begin
  Writeln('H°v†sa:');
  {$IFDEF EKSZ_ASC}
  Writeln('EKSZ2ASC [£t\]êkSzerFile [êkSzer2..êkSzerx] [£t\][ASCIIFile] [/o]');
  Writeln;
  Writeln('[£t\]êkSzerFile    = az êkSzer dokumentumok csoportja. Pld. C:\EKSZER\*.DOC');
  Writeln('[êkSzer2..êkSzerx] = tetszìleges sz†m£ tov†bbi csoport. Pld. A*.LEV *.SZE *.AJN');
  Writeln('[£t\][ASCIIFile]   = a lÇtrehozand¢ ASCII file-ok helye Çs neve. Pld. C:\*.TXT');
  Writeln('                     alapÇrtelmezÇs: az êkSzer dokumentumok kînyvt†r†ban *.ASC');

  {$ELSE}
  Writeln('ASC2EKSZ [£t\]ASCIIFile [ASCII2 .. ASCIIx] [£t\][êkSzerFile] [/lXX] [/rXX] [/o]');
  Writeln;
  Writeln('[£t\]ASCIIFile     = az ASCII file-ok csoportja. Pld. C:\PE2\*.TXT');
  Writeln('[ASCII2..ASCIIx]   = tetszìleges sz†m£ tov†bbi csoport. Pld. E*.ASC *.BAT');
  Writeln('[£t\][êkSzerFile]  = a lÇtrehozand¢ êkSzer file-ok helye Çs neve. Pld. C:\*.DOK');
  Writeln('                     alapÇrtelmezÇs: az ASCII file-ok kînyvt†r†ban *.DOC');
  Writeln('[/lXX]             : XX =  a bal marg¢ ÇrtÇke (alapÇrtelmezÇs: 0)');
  Writeln('[/rXX]             : XX = a jobb marg¢ ÇrtÇke (alapÇrtelmezÇs: 76)');
  {$ENDIF}
  Writeln('[/o]               = lÇtezì file-ok automatikus felÅl°r†sa');
End;

Procedure Terminate(Fil,S : String);
Begin
  WriteLn(#13#10#13#10,' ØØØ ',S,' hiba : ',Fil,' ÆÆÆ');
  Halt(1);
End;

Procedure Term;
Begin
   Close(EkszF); 
  Terminate(Ifn,'File olvas†si');
End;

Procedure WriteSorszam;
Begin
  GotoXY(68,WhereY);
  Percent := 100*(FilePoz / FSize);
  Write(SorokSzama:5,'  ',Percent:3:0,'%');
End;

{$IFDEF EKSZ_ASC}
(*********************** êkSzer -> ASCII eleje ****************************)

Function AscII_Out(Path : String): Boolean;
Var Tf       : Text;
    Ezt,Erre : String;
    Cik,Poz  : Byte;
Begin
  
  Assign(Tf,Path + AscOut);
  Reset(Tf);
  
  If IoResult = 0 Then
  Begin
    Writeln(Path + AscOut + ' feldolgoz†sa...');
    Writeln;
    
    ReadLn(Tf,Ezt);
    ReadLn(Tf,Erre);

    For Cik := 1 To Length(Ezt) Do
    Begin
      Poz := Pos(Ezt[Cik],Asc_Out.Ezt);
      If Poz = 0 Then
      Begin
        Asc_Out.Ezt := Asc_Out.Ezt + Ezt[Cik];
        Asc_Out.Erre := Asc_Out.Erre + Erre[Cik];
      End
      Else
      Begin
        Asc_Out.Ezt[Poz] := Ezt[Cik];
        Asc_Out.Erre[Poz] := Erre[Cik];
      End;
    End;

    Close(Tf);
    AscII_Out := True;

  End
  Else AscII_Out := False;
End;

Function GrafE(Num: Byte): Boolean;
Begin
  GrafE := (Copy(FontNames[Num],1,4) = 'SPEC');
End;

Function Spec1E(Num: Byte): Boolean;
Begin
  Spec1E := (Copy(FontNames[Num],1,5) = 'SPEC1');
End;

Function MagyarE(Num: Byte): Boolean;
Begin
  MagyarE := (FontNames[Num][1] = 'M');
End;

Function DoltE(Num: Byte): Boolean;
Begin
  DoltE := (Copy(FontNames[Num],2,5) = '-DOLT');
End;

Function VastagE(Num: Byte): Boolean;
Begin
  VastagE := (Copy(FontNames[Num],2,7) = '-VASTAG');
End;

Function IndexE(Num: Byte): Boolean;
Begin
  IndexE := (Copy(FontNames[Num],2,6) = '-INDEX');
End;

Function AlahuzottE(Num: Byte): Boolean;
Begin
  AlahuzottE := (Copy(FontNames[Num],2,7) = '-ALAHUZ');
End;

Type AscType = (ASCII,Ventura);

PROCEDURE LoadEksz_SaveAscii;

LABEL RosszSzerk;

CONST azon : array [1..1] of string[2] = ('CD');

VAR

fel_sor_darab : Integer;
eleje         : string[4];
fontok_szama  : byte;
font_nev      : string[16];
cikl_v        : word;
a_ind_sor     : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
f_ind_sor     : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
nincs_also    : boolean;
rel_sorsz     : byte;
szamolo       : byte;
lap_vege      : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
sor_hossz     : byte;      (*  ez a ket sor nem mozgathato egymas mellol *)
kemeny_sorveg : byte;
TabSzam       : byte;
TabPoz        : array [1..128] of byte;
EmsS          : Word;
UresLett,
Volt_hiba     : Boolean;

{ ASCII_Save Valtozok }

Var FoAtt : Array[1..255] Of Byte;
    Fosor : String[255];
    IORES : Integer;
    Elval : Boolean;
    PP,
    Cik   : Byte;
    OCh,
    Ch    : Char;
    F     : array [1..5] of boolean;
    old_att : byte;
    kije    : string[20];
    Ws      : String[255];  {NyelvEsz DEMO}

Const
    jel : array [1..5] of string[4] = ('<D>','<MS>','<B>','<MI>','<MU>');

HVP : Array[1..18] Of Char =

{   †    °    î    Å    ¢    ‹     €    £    Ç  }
  (#160,#161,#148,#129,#162,#220,#219,#163,#130,
   #199,#205,#153,#154,#209,#222,#221,#214,#144);

Procedure ASCII_Save(Tipus: ASCType);
Var Cik : Byte;
BEGIN

   IORES := 0;
   Fosor[0] := Char(Sor_Hossz);

   Move(P^.Chars,Fosor[1],Byte(Fosor[0]));
   Move(P^.Attribs,FoAtt[1],Byte(Fosor[0]));

   If Tipus = ASCII Then
   Begin

     For Cik := 1 To Length(FoSor) Do
     BEGIN
       If FoSor[Cik] = #00 Then FoSor[Cik] := ' '
       Else
       If MagyarE(FoAtt[Cik] AND 15) Then { Magyar }
       BEGIN
         PP := Pos(FoSor[Cik],Asc_Out.ezt);
         If Boolean(PP) Then FoSor[Cik] := Asc_Out.erre[PP];
       End
       Else
       If Spec1E(FoAtt[Cik] AND 15) Then { Spec1 }
       BEGIN
         PP := Pos(FoSor[Cik],TablazatConvSt[0]);
         If Boolean(PP) Then FoSor[Cik] := TablazatConvSt[1][PP];
       End;

     End; { For }

     UresLett := False;

     If Elval Then
     Begin

       If FoSor = '' Then
       Begin
         WriteLn(AscF);
         Inc(IORES,IOResult);
       End
       Else
       Begin
         If FoSor[1] = ' ' Then
         Begin
           Ws := FoSor;
           While Ws[1] = ' ' Do Delete(Ws,1,1);
           PP := Pos(' ',Ws);
           If PP > 0 Then Ws[0] := Char(PP-1);
           PP := Pos(Ws,FoSor) + Length(Ws) -1;
         End
         Else
         Begin
           PP := Pos(' ',FoSor)-1;
           If PP = 0 Then PP := Length(FoSor);
           Ws := Copy(FoSor,1,PP);
         End;

         WriteLn(AscF,Ws);
         Inc(IORES,IOResult);

         Delete(FoSor,1,PP+1);
         UresLett := (FoSor = '');

         {FillChar(FoSor[1],PP,' ');}

       End;

       Elval := False;

     End;

     If (FoSor <> '') AND ((FoAtt[Cik] = 0) AND (FoSor[Cik] = '-')) Then
     Begin
       Elval := True;
       Dec(Byte(FoSor[0]));
       Write(AscF,FoSor);
       Inc(IORES,IOResult);
     End
     Else
     Begin
       If NOT UresLett Then
       Begin
         Writeln(AscF,Fosor);
         Inc(IORES,IOResult);
       End;
       Elval := False;
     End;

     If IORes <> 0 Then Terminate(Ofn,DiskWrite);

   End
   Else {Ventura}
   Begin

     IORES := 0;
     Cik := 1;

     While Cik <= Length(FoSor) Do
     BEGIN

       Ch := Fosor[Cik];
       OCh:= Ch;

       If Ch = #00 Then Ch := ' ';

       If Ch = ' ' Then
       Begin
         
         If Elval Then
         Begin
           If OCh = ' ' Then
           Begin
             WriteLn(AscF);
             Inc(IORES,IOResult);
             Elval := False;
           End;
         End
         Else If Cik > 1 Then
         Begin
           Write(AscF,Ch);
           Inc(IORES,IOResult);
           
         End;

         Repeat
           Inc(Cik);
           If Elval AND (FoSor[Cik] = ' ') Then
           Begin
              WriteLn(AscF); 
             Inc(IORES,IOResult);
             Elval := False;
           End;
           If FoSor[Cik] = #00 Then FoSor[Cik] := ' ';
         Until Fosor[Cik] <> ' ';

       End
       Else
       Begin
         kije:='';
         If not(F[FoAtt[cik] and 15]) then
         BEGIN
           F[old_att] := False;
           old_att    := FoAtt[cik] and 15;
           F[FoAtt[cik] and 15] := True;

           If (DoltE(old_att)) or (AlahuzottE(old_att)) or
              (IndexE(old_att)) or (VastagE(old_att)) then
           BEGIN
             If DoltE     (FoAtt[cik] and 15) then kije:=kije+jel[4];
             If AlahuzottE(FoAtt[cik] and 15) then kije:=kije+jel[5];
             If IndexE    (FoAtt[cik] and 15) then kije:=kije+jel[2];
             If VastagE   (FoAtt[cik] and 15) then kije:=Kije+jel[3];
           End
           else kije:=jel[1];

           Write(AscF,kije);
           
           Inc(IORES,IOResult);
           
         End;

         If (Spec1E(FoAtt[Cik] AND 15)) Then { SPEC1 }
         Begin
           If Ch = '&' Then Ch := 'π';
         End;

         If MagyarE(FoAtt[Cik] AND 15) Then { Magyar }
         BEGIN

           PP := Pos(Ch,CWIConvSt[0]);
           If PP > 0 Then
           Begin
             
             If (PP >= 12) and (PP<=30)  Then Write(AscF,HVP[PP-11]){ êkezetes }
                               Else
                               Write(AscF,CWIConvSt[1][PP]);{ EgyÇb }
             
             Inc(IORES,IOResult);
           End
           Else
           Begin
              Write(AscF,Ch); 
             Inc(IORES,IOResult);
           End;
         End
         Else
         Begin
           If FoAtt[Cik] = 0 Then Elval := True
           Else
           Begin
              Write(AscF,Ch); 
             Inc(IORES,IOResult);
           End;
         End;

         Inc(Cik);

       End; { Ha nem ' ' volt }

     End; { While }

     If FoAtt[1] and 128 = 128 then
     BEGIN
        Writeln(AscF,#13#10); 
       Inc(IORES,IOResult);
     End
     else

     If NOT Elval Then                 {VENTURA}
     BEGIN
       
       WriteLn(AscF);            {szokoz kiszedve}
       
       Inc(IORES,IOResult);
     End;

     

     If IORes <> 0 Then Terminate(OFn,DiskWrite);

   End; { Ventura }

End; {ASCII_Save}


PROCEDURE Pt_tolt;

VAR cikl_v : byte;
    mento  : longint;
    belsor : array [1..240] of Char;
    helyy  : longint;
    pozi   : longint;

BEGIN

  If Sor_Hossz > 0 Then
  Begin
    attr_osszeg := 0;
    kar_osszeg  := 0;
    mento       := P^.Attribs[0];

    { Attributumok }

    While attr_osszeg < sor_hossz do
    BEGIN
      
      BlockRead(EkszF,puff_b,1);
      Inc(FilePoz,1);

      
      IORES := IOResult;

      darab  := puff_b shr 4;
      puff_b := puff_b and 15;

      If darab = 0 then darab := sor_hossz; {A sorban nincs fontvaltas}

      FillChar(P^.Attribs[attr_osszeg],darab,Char(puff_b));

      Inc(attr_osszeg,darab);
    End;

    P^.Attribs[0] := P^.Attribs[0] or mento;

    { Karakterek }

    pozi  := FilePos(EkszF);              { A beolv elotti pozicio }
    mento := 0;                           { Tenyleg beolv kar. szamlalo }
    Helyy := FileSize(EkszF)-pozi;        { Beolv hossz meghatarozasa }

    If Helyy > Sor_hossz then Helyy := sor_hossz;
    
    BlockRead(EkszF,BelSor[1],Helyy);
    Inc(FilePoz,Helyy);
    
    IORES := IOResult;

    While kar_osszeg < sor_hossz do
    BEGIN
      If BelSor[mento+1]>#$80 then
      BEGIN
        darab  := Byte(BelSor[mento+1])-$80;
        puff_b := Byte(BelSor[mento+2]);
        FillChar(P^.Chars[Kar_osszeg],darab,Char(puff_b));
        Inc(kar_osszeg,darab);
        Inc(mento,2);
      End
      else
      BEGIN
        Move(Char(BelSor[mento+1]),P^.Chars[kar_osszeg],1);
        Inc(kar_osszeg);
        Inc(mento);
      End;
    End;

    If pozi+mento < FileSize(EkszF) then
    BEGIN
      
      Seek(EkszF,pozi+mento);
      {I+}
      FilePoz := Pozi+Mento;
      IORES:=IOResult;
    End;

  End; { If Sor_Hossz > 0 }

  Dec(Fel_Sor_Darab);
  ASCII_Save(ASCII);
  Inc(SorokSzama);

End;

(*
PROCEDURE RelSorszEll;
BEGIN
  While Rel_sorsz > 0 do
  BEGIN
     BlockRead(EkszF,Sor_hossz,2);  { lehet 0 is }  IORES := IOResult;
     BlockRead(EkszF,Rel_sorsz,2);  { lehet 0 is }  IORES := IOResult;
  End;
End;
*)

Procedure SAVE_ASCII_Init;

Begin
  Elval := False;

  F[1]:=False; { Normal }
  F[2]:=False; { Index  }
  F[3]:=False; { Bold   }
  F[4]:=False; { Dolt   }
  F[5]:=False; { Alahuz }
  old_att:=2;
End;

BEGIN  (*********** LoadEksz_SaveAscii ***********)

  SAVE_ASCII_Init;

  OpenAsc := False;

  Volt_Hiba := False;

  {File-fejlec beolvasasa }

  Eleje[0] := #04;

  
  BlockRead(EkszF,eleje[1],4);
  Inc(FilePoz,4);
  
  IORES := IOResult;

  
  BlockRead(EkszF,fel_sor_darab,2);
  Inc(FilePoz,2);
  
  IORES := IOResult;

  If eleje <> #0'CD'#0 then
  Begin
    Beep;
    GotoXY(Xpoz,WhereY);
    ClrEol;
    Write('Æ Nem êkSzer file Ø');
    Dec(Files);
  End
  Else
  BEGIN
    Rewrite(AscF);
    If IOResult <> 0 Then Terminate(Ofn,OpenError);

    OpenAsc := True;

    
    BlockRead(EkszF,LeftMar,2);
    Inc(FilePoz,2);
    
    IORES := IOResult;

    
    BlockRead(EkszF,TabSzam,1);
    Inc(FilePoz,1);
    
    IORES := IOResult;

    TabSzam := TabSzam and $7F;

    If TabSzam > 0 then
    BEGIN
      
      BlockRead(EkszF,TabPoz[1],TabSzam);              { Tab poz-ok }
      Inc(FilePoz,TabSzam);
      
      IORES := IOResult;
    End;

    
    BlockRead(EkszF,Fontok_szama,1);                { Aktualis fontok szama }
    Inc(FilePoz,1);
    

    IORES := IOResult;

    For cikl_v := 1 to fontok_szama do
    BEGIN
      
      BlockRead(EkszF,Font_Nev[0],1);       { Betoltando fontnev hossz }
      Inc(FilePoz,1);
      
      IORES := IOResult;

      If Byte(Font_Nev[0]) > 0 Then
      Begin
        
        BlockRead(EkszF,Font_nev[1],Byte(Font_Nev[0])); { Betoltendo font neve }
        Inc(FilePoz,Byte(Font_Nev[0]));
        
        IORES := IOResult;
        FontNames[cikl_v] := Font_Nev;
      End;

    End;

    
    BlockRead(EkszF,Header_Nev[0],1);             { Header nev hossz }
    Inc(FilePoz,1);
    
    IORES := IOResult;

    If Byte(Header_Nev[0]) > 0 then
    BEGIN
      
      BlockRead(EkszF,Header_nev[1],Byte(Header_Nev[0]));  { Header nev }
      Inc(FilePoz,Byte(Header_Nev[0]));
      
      IORES := IOResult;
    End;

    {File-fejlec vege}

    rel_sorsz:=1;
    nincs_also:=False;

    While fel_sor_darab > 0 do
    BEGIN

      If (rel_sorsz > 0) or (nincs_also) then
      BEGIN
        
        BlockRead(EkszF,F_ind_sor,1);    { Sorfejlec azonosito 00 }
        Inc(FilePoz,1);
        
        IORES := IOResult;
      End;

      
      BlockRead(EkszF,F_ind_sor,2);        { Felso es also ind. sorok szama }
      Inc(FilePoz,2);
      
      IORES := IOResult;

      If (F_ind_sor + a_ind_sor = 0) then
      BEGIN
        F_Ind_Sor := 1;
        rel_sorsz:=1;
        GotoXY(60,WhereY);
        Beep;
        WriteLn('Æ Hib†s êkSzer file Ø');
        Fel_Sor_Darab := 0;
      End
      Else
      Begin

        Nincs_Also := (A_Ind_Sor = 0);

        { Felso indexsorok }

        szamolo:=0;

        
        BlockRead(EkszF,Rel_sorsz,1);      { Az ind. sor soszama }
        Inc(FilePoz,1);
        
        IORES := IOResult;

        While (fel_sor_darab > 0) AND
              (rel_sorsz > 0) AND
              (szamolo < f_ind_sor) Do
        BEGIN

          If szamolo > 0 then
          BEGIN
                                     { Csak a masodik felso indexsor }
            BlockRead(EkszF,Rel_sorsz,1); { betoltesetol kell, mert az elso }
                                     { mar betoltodott }
            Inc(FilePoz,1);
            IORES := IOResult;
          End;

          If rel_sorsz > 0 then
          BEGIN
            
            BlockRead(EkszF,Sor_hossz,2); { Sor hosszanak, lapvegnek betoltese }
            Inc(FilePoz,2);
            
            IORES := IOResult;

            P^.Chars  [78] := Char(lap_vege*2);
            P^.Attribs[79] := rel_sorsz;
            P^.Attribs[ 0] := (128+Lap_vege*64+32) and $E0;

            Pt_tolt;
            
          End;

          Inc(szamolo);

        End;

        { Fîsor }

        If fel_sor_darab > 0 Then
        Begin
          If rel_sorsz > 0 then
          BEGIN
            
            BlockRead(EkszF,Rel_sorsz,1);  { muszaj, hogy 00 legyen }
            
            Inc(FilePoz,1);
            IORES := IOResult;
          End;

          { If Rel_sorsz > 0 then RelSorszEll; }

          
          BlockRead(EkszF,Sor_hossz,2);  { lehet 0 is }
          
          Inc(FilePoz,2);
          IORES := IOResult;

          If Lap_Vege AND 128 = 128 Then Lap_Vege := Lap_Vege and $7F;

          Kemeny_sorveg := Byte(lap_vege and 2 > 0);
          lap_vege      := lap_vege and 1;

          Pt^.Chars[78]  := Char(lap_vege*2);

          P^.Attribs[78] := a_ind_sor;
          P^.Attribs[79] := f_ind_sor;
          P^.Attribs[0]  := Kemeny_sorveg*128+Lap_vege*64+Byte(sor_hossz>0)*32+16;

          Pt_tolt;

        End; { If fel_sor_darab > 0 }

        { Also indexsorok }

        If not nincs_also then
        BEGIN

          szamolo := 0;

          
          BlockRead(EkszF,Rel_sorsz,1);
          
          Inc(FilePoz,1);
          IORES := IOResult;

          While (fel_sor_darab > 0)
                AND (szamolo < a_ind_sor) AND
                (rel_sorsz > 0) Do
          BEGIN

            If szamolo > 0 then
            BEGIN
              
              BlockRead(EkszF,Rel_sorsz,1);
              
              Inc(FilePoz,1);
              IORES := IOResult;
            End;

            If rel_sorsz > 0 then
            BEGIN
              
              BlockRead(EkszF,Sor_hossz,2);
              
              Inc(FilePoz,2);
              IORES := IOResult;

              P^.Chars  [78]:=Char(lap_vege*2);
              P^.Attribs[ 0]:=(Lap_vege*64+32) and $60;
              P^.Attribs[79]:=rel_sorsz;

              {Writeln(fel_sor_darab:5,Rel_Sorsz);}
              Pt_tolt;

            End;

            Inc(szamolo);

          End; { While Szamolo < A_Ind_Sor }

        End; { Nincs_also = False }

      End; { Ha nem 0 a felsî Çs az als¢ indexsorok sz†ma }

      If SorokSzama MOD 50 = 0 Then WriteSorszam;

    End;  { While fel_sor_darab > 0 }

  End; { If 00 CD 00 }

End;  { LoadEksz_SaveAscii }

(*********************** êkSzer -> ASCII vÇge  ****************************)
{$ELSE}
(*********************** ASCII -> êkSzer eleje ****************************)

Function AscII_In(Path : String): Boolean;
Var Tf : Text;
Begin
  
  Assign(Tf,Path + AscIn);
  Reset(Tf);
  
  If IoResult = 0 Then
  Begin
    Writeln(Path + AscIn + ' feldolgoz†sa...');
    Writeln;
    
    ReadLn(Tf,Asc_In.Ezt);
    ReadLn(Tf,Asc_In.Erre);
    
    Close(Tf);
    AscII_In := True;
  End
  Else AscII_In := False;
End;

Procedure WriteHeader(Var Fil: File);
Begin

   
   ReWrite(EkszF,1);
   If IOResult <> 0 Then Terminate(Ofn,OpenError);
   

   
   BlockWrite(Fil,Header30,4); 
   If IOResult <> 0 Then Term;

   Fej_pos:=FilePos(Fil);

    BlockWrite(Fil,SorokSzama,2); 
   If IOResult <> 0 Then Term;

    BlockWrite(Fil,LeftMar,1);    
   If IOResult <> 0 Then Term;

    BlockWrite(Fil,RightMar,1);   
   If IOResult <> 0 Then Term;

    BlockWrite(Fil,Tab_szamolo,1); 
   If IOResult <> 0 Then Term;

    BlockWrite(Fil,Tabulator,Tab_Szamolo);  
   If IOResult <> 0 Then Term;

    BlockWrite(Fil,MaxFontNum,1); 
   If IOResult <> 0 Then Term;

   For Cik := 1 To MaxFontNum Do
   BEGIN
      BlockWrite(Fil,FontNames[Cik][0],Byte(FontNames[Cik][0])+1); 
      If IOResult <> 0 Then Term;
    End;

   BlockWrite(Fil,HeadFootName[0],Byte(HeadFootName[0])+1); 
  If IOResult <> 0 Then Term;

End; { WriteHeader }

Procedure WriteSorokSzama(Var Fil: File);
Begin
  Seek(Fil,Fej_Pos);
   BlockWrite(Fil,SorokSzama,2); 
  If IOResult <> 0 Then Term;
End;

Procedure Convert_And_WriteLine;
Var
X   : Integer;
Ch  : Char;

Procedure Create_Sor;
Var
X,Bc: Integer;
Attr: Byte;
cch : char;
eloz: byte;
nul_start : boolean;

BEGIN
  Cik := 77;
  While (Cik >= 0) AND (P^.chars[Cik] = #00) Do Dec(Cik);

  Inc(Cik);

  Sor[1] := Lo(Cik);   { Sorhossz }

  If Cik > 0 Then
  BEGIN
    Azonos_attr:=True;
    X:=1;
    nul_start:=False;

    While ((X < Cik) or ((Cik=1) and (X=1))) and (Azonos_attr) DO
      BEGIN
        Attr:=P^.Attribs[X] And 15;
        Font:=P^.Attribs[X-1] And 15;
        If (Attr <> Font) then Azonos_attr := False;
        Inc(X);
      End;

    If not(Azonos_attr) then
      BEGIN
        Font  := $80;
        Count := 0;
        For X := 0 To Cik-1 Do   { Attributum ciklus }
          BEGIN
            Attr := P^.Attribs[X] AND 15;
            If (Attr <> Font) { and (Attr > 0) VF } Then  { font valtas }
              BEGIN
                If Count > 0 Then { Az elîzî azonos karakterek attributuma }
                  BEGIN
                    Count := (Count SHL 4);
                    Inc(Count,Font);
                    Sor[Num] := Count;
                    Inc(Num);
                  End;
                Count := 1;
                Font  := Attr;
              End
            Else  { ugyanaz a font marad }
              BEGIN
                Inc(Count);
                If Count = 15 Then
                  BEGIN
                    Sor[Num] := $F0 + Font;
                    Inc(Num);
                    Count := 0;
                  End;
              End;

          End;  {For Cik}

        If Count > 0 Then { A maradek karakterek attributuma }
          BEGIN
            Count := (Count SHL 4);
            Inc(Count,Font);
            Sor[Num] := Count;
            Inc(Num);
          End;
      End
    else
      BEGIN
        Sor[Num]:=(Font and 15);
        Inc(num);
      End;

    Azonos := 1;

    Kar:=#255;
    For X := 0 To Cik Do  { Karakter ciklus }
    BEGIN

      Ch := P^.Chars[X];

      If Ch <> Kar Then
      BEGIN
        If X > 0 Then
          Case Azonos Of
           1: BEGIN
                SorCh[Num] := Kar;
                Inc(Num);
              End;
           2: BEGIN
                SorCh[Num]   := Kar;
                SorCh[Num+1] := Kar;
                Inc(Num,2);
                Azonos := 1;
              End
            Else
            BEGIN
              Sor[Num] := $80 + Azonos;
              Inc(Num);
              SorCh[Num] := Kar;
              Inc(Num);
              Azonos := 1;
            End;
          End; { of Case }
        Kar := Ch;
      End
      Else Inc(Azonos);

    End;  {For X}

  End {If Cik >= 0}

End;   {Create_Sor}


BEGIN  {Convert_And_WriteLine}

  Sor[-3] := 00;     { 00 = Fîsor Header }
  Sor[-2] := 1;      { Felsok      }
  Sor[-1] := 1;      { Alsok       }
  Sor[0]  := 00;     { Fîsor = 00 ;     }
  Sor[2]  := 00;     { Nincs lapvÇge    }

  Num := 3;
  Create_sor;                {@@@}

  If (P^.Attribs[0] and 128) > 0 then Inc(Sor[2],2); { KemÇnysor }

   BlockWrite(EkszF,Sor[-3],Num+3); 

  If IOResult <> 0 Then Term;

End;  {Convert_And_WriteLine}


(************************************************************************)

Procedure Read_ASCII_And_ConvertLine;

VAR
    X,K,Ci,Cik  : Byte;
    Ch          : Char;
    Sor,Maradek : String;
    ccch        : char;
    EscVolt     : Boolean;

Const

    IBMChars : Set Of Byte = [150,163,151,147,148,129,138,130,160,134,
                              133,161,141,162,149,143,144,153,154,173,
                              139,152,167,$8C];

    Tomb : Array[1..2,1..24] Of Char = ((#150,#163,#151,#147,#148,
                                         #129,#138,#130,#160,#134,
                                         #133,#161,#141,#162,#149,
                                         #143,#144,#153,#154,#173,
                                         #139,#152,#167,#$8C),
                                        ('\',']','}','[','0',
                                        '-',';',';','''','''',
                                        '''','`','~','=','+',
                                        '"',':',')','_','~',
					'{','|','{','~'));

BEGIN
  Maradek := '';

  Repeat

    Inc(SorokSzama);

    FillChar(P^.Attribs,80,00);
    FillChar(P^.Chars,80,00);

    X := 1;
    K := 0;

    If Maradek = '' Then
    Begin
	 ReadLn(AscF,Sor); 
        If IOResult <> 0 Then Terminate(Ifn,'File olvas†si');

        Inc(FilePoz,Length(Sor)+2);
        If (Sor <> '') And (Sor[Length(Sor)] <> ' ') Then Sor := Sor + ' ';

    End
    Else
      Sor  := Maradek;

    If Byte(Sor[0]) > 77 Then
    BEGIN
      Maradek := Copy(Sor,78,Length(Sor)-77);
      Sor[0] := #77;
    End
    Else Maradek := '';

    P^.Attribs[0]  := P^.Attribs[0] OR 128+16;   {Fîsor - Hard CR}
    P^.Attribs[78] := 1;                         { 1 = Default fîsor also}
    P^.Attribs[79] := 1;                         { 1 = Default fîsor felso}

    While X <= BYTE(Sor[0]) Do
    BEGIN

      Ch := Sor[X];

      If K < 78 Then
      BEGIN

        P^.Attribs[0] := P^.Attribs[0] OR 32; {Kitoltve}

        Ci := pos(Ch,ASC_IN.EZT);

        If ((Length(ASC_IN.ERRE) >= Ci) AND (Ci > 0)) Then
          Ch := Asc_In.erre[Ci];

        Ci := Pos(Ch,Tomb[1]);

        If Ci > 0 Then
        Begin
          Ch := Tomb[2][Ci];
          GFont[0] := 2;
        End
        Else GFont[0] := 1;

        If BYTE(Ch) In NormalChars+IBMChars+Nulchar Then
        Begin

          P^.Attribs[K] := (P^.Attribs[K] AND $F0) OR GFont[0];

          P^.Chars[K] := Ch;
          Inc(K);

        End;

      End;

      Inc(X);

    End; { While X <= Length(Sor) }


     If (Maradek <> '') Then
     Begin
       P^.Attribs[0] := P^.Attribs[0] AND 127; {Lagy sorveg}
       Convert_And_WriteLine; { Plusz egy sor }
     End;

  Until Maradek = '';

End; { Read_ASCII_and_convertline }

(*********************** ASCII -> êkSzer vÇge  ****************************)
{$ENDIF}


Begin (************************* Main ***************************)

  Params := ParamCount;

  If Params > 0 Then
  Begin

   {$IFDEF EKSZ_ASC}
    Writeln('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª');
    Writeln('∫   êkSzer => ASCII filekonvert†l¢ program  1.00 verzi¢     ∫');
    Writeln('∫  Copyright (C) DARVAS Software Bt  (C) êkSoft Kft 1992    ∫');
    Writeln('»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');
   {$ELSE}
    Writeln('…ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª');
    Writeln('∫   ASCII => êkSzer filekonvert†l¢ program  1.00 verzi¢     ∫');
    Writeln('∫  Copyright (C) DARVAS Software Bt  (C) êkSoft Kft 1992    ∫');
    Writeln('»ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº');
   {$ENDIF}

    GetMem(P,SizeOf(P^));

    TotalSorokSzama := 0;

    SetTextBuf(AscF,Buf);

    Fi := ParamStr(1);

    If (Fi[1] = '/') AND (UpCase(Fi[2]) = 'H') Then
    Begin
      WriteHelp;
      Halt;
    End;

    Repeat

      Fo := ParamStr(Params);

      If (Fo[1] = '/') Then
      Begin
        Case UpCase(Fo[2]) Of
          'O': OverWrite := True;
          {$IFNDEF EKSZ_ASC}
          'R': Begin
                 Val(Copy(Fo,3,3),RightMar,Code);
                 If (Code > 0) OR (RightMar > 76) Then RightMar := 76;
               End;
          'L': Begin
                 Val(Copy(Fo,3,3),LeftMar,Code);
                 If (Code > 0) OR (LeftMar >= RightMar) Then LeftMar := 0;
               End;
          {$ENDIF}
          Else WriteLn('Hib†s paramÇter: ',Fo);
        End;
        Dec(Params);
      End;

    Until (Params = 0) OR (Fo[1] <> '/');

    If Params = 0 Then
    Begin
      WriteHelp;
      Halt;
    End;

    {$IFNDEF EKSZ_ASC}
    WriteLn(#13#10' Bal marg¢: ',LeftMar,'  Jobb marg¢: ',RightMar);
    {$ENDIF}

    WriteLn;

    Groups := Params-1;

    For Cik := 2 To Groups Do
      Group[Cik] := ParamStr(Cik);

    IPath := '';
    OPath := '';

    BackPoz := 0;

    If Pos('\',Fo) > 0 Then
    Begin
      Cik := Length(Fo);
      While Fo[Cik] <> '\' Do Dec(Cik);
      OPath := Copy(Fo,1,Cik);

      BackPoz := Cik;

      If (Cik < Length(Fo)) AND
         (Params > 1) AND
         (Pos('*',Copy(Opath,Cik+1,12)) = 0)
      Then
      Begin
        FindFirst(Fo,Directory,DirInfo);
        If DosError = 0 Then OPath := Fo + '\';
      End;
    End;

    If Pos('\',Fi) > 0 Then
    Begin
      Cik := Length(Fi);
      While Fi[Cik] <> '\' Do Dec(Cik);
      IPath := Copy(Fi,1,Cik);
    End;

    If Fi = Fo Then
    Begin
      If Params > 1 Then Terminate(SameFileName,'');
    End
    Else
    Begin

      If Pos('.',Fo) > BackPoz Then Ext := Copy(Fo,Pos('.',Fo),4);

      If Pos('*',Fo) > 0 Then
      Begin
        Ext := Copy(Fo,Pos('*',Fo)+1,4);
        If (Ext = '.*') OR (Ext = '.???') Then
        Begin
          If Pos('.',Fi) = 0 Then Ext := '.'
          Else
          Begin
            Cik := Length(Fi);
            While Fi[Cik] <> '.' Do Dec(Cik);
            Ext := Copy(Fi,Cik,4);
          End;
        End;
      End;

      If (Pos('*',Fi) = 0) AND (Pos('*',Fo) > 0)  Then
      Begin
        Cik2  := Length(Fi);
        If Pos('.',Fi) > Cik+2 Then
        Begin
          Cik2 := Pos('.',Fi)-1;
          IExt := Copy(Fi,Cik2+1,4);
        End;
        OutFn := Copy(Fi,Cik+1,Cik2-(Cik+1)+1);
      End;

    End;

    For Cik := 2 To Groups Do
    Begin
      If (Pos('.',Group[Cik]) > 0) AND
         (Copy(Group[Cik],Pos('.',Group[Cik]),4) = Ext) Then
      Begin
        Terminate(SameFileName,'');
      End;
    End;

    {$IFDEF EKSZ_ASC}
    If (AscII_Out('')) OR (AscII_Out(IPath)) OR (AscII_Out(OPath)) Then;
    {$ELSE}
    If (AscII_In('')) OR (AscII_In(IPath)) OR (AscII_In(OPath)) Then;
    {$ENDIF}

    GCount := 1;

    GetTime(Hour1, Minute1, Second1, Sec1001);
    Time1 := ZipTime(Hour1,Minute1,Second1,Sec1001);

    Repeat

      FindFirst(Fi, Archive+ReadOnly, DirInfo);

      If DosError <> 0 Then
        WriteLn('Nem tal†lhat¢: ',Fi)
      Else
      While (NOT Abort) AND (DosError = 0) do
      Begin

        Inc(Files);
        SorokSzama := 0;

        IFn := IPath+DirInfo.Name;

        If OutFn <> '' Then OFn := OPath+OutFn
                       Else
                       Begin
                         AktOutFn := DirInfo.Name;
                         If Pos('.',AktOutFn) > 0 Then
                           Byte(AktOutFn[0]) := Pos('.',AktOutFn)-1;
                         OFn := OPath+AktOutFn;
                       End;

        OFn := OFn + Ext;

        Write(Ifn);
        Xp := ((WhereX+4) DIV 5) * 5;
        If Xp > Oxp Then Oxp := Xp
                    Else Xp  := Oxp;
        If Xp + Length(Ofn) + 10 < 69 Then
          GotoXY(Xp,WhereY)
        Else
          WriteLn;

        Xpoz := WhereX;

        Write(' => ',Ofn);
        GotoXY(62,WhereY);
        Write(' Sor: ');

        Gfont[0] := 1;
        Gfont[1] := 1;

        Assign(Fb,Ifn);

        Reset(Fb,1);
        If IOResult <> 0 Then Terminate(Ifn,OpenError);

        FSize   := FileSize(Fb);
        FilePoz := 0;

        Close(Fb);
        If IOResult <> 0 Then Terminate(Ifn,CloseError);

        {$IFDEF EKSZ_ASC}
        Assign(EkszF,Ifn);
        Reset(EkszF,1);
        {$ELSE}
        Assign(AscF,Ifn);
        Reset(AscF);
        {$ENDIF}

        If IOResult <> 0 Then Terminate(Ifn,OpenError);

        Over := True;

        {$IFDEF EKSZ_ASC}
        Assign(AscF,Ofn);
        {$ELSE}
        Assign(EkszF,Ofn);
        {$ENDIF}

        If NOT OverWrite Then
        Begin

          {$IFDEF EKSZ_ASC}
          Reset(AscF);
          {$ELSE}
          Reset(EkszF,1);
          {$ENDIF}

          If IOResult = 0 Then
          Begin
            GetTime(Hour1, Minute1, Second1, Sec1001);
            StayTime1 := ZipTime(Hour1,Minute1,Second1,Sec1001);

            Ox := WhereX;
            Writeln;
            Write(Ofn,' file m†r lÇtezik, felÅl°rhat¢ (I/N) ? ');
            Beep;

            Repeat
              C := ReadKey;
            Until UpCase(C) In ['I','N'];

            Over := (UpCase(C) = 'I');
            DelLine;
            GotoXY(Ox,WhereY-1);
            {$IFDEF EKSZ_ASC}
            Close(AscF);
            {$ELSE}
            Close(EkszF);
            {$ENDIF}
            If IOResult <> 0 Then Terminate(Ofn,CloseError);

            GetTime(Hour1, Minute1, Second1, Sec1001);
            StayTime2 := ZipTime(Hour1,Minute1,Second1,Sec1001);

            StayTime2 := StayTime2-StayTime1;
            Inc(Time1,StayTime2);

          End;

        End;

        If Over Then
        Begin

          {$IFDEF EKSZ_ASC}
          LoadEksz_SaveAscii;
          {$ELSE}

          WriteHeader(EkszF);

          While NOT EOF(AscF) Do
          Begin
            Read_ASCII_And_ConvertLine;
            If SorokSzama MOD 50 = 0 Then WriteSorszam;
            Convert_And_WriteLine;
          End;

          WriteSorokSzama(EkszF);
          {$ENDIF}

          FilePoz := FSize; { 100% }

          {$IFDEF EKSZ_ASC}
          If NOT OpenAsc Then SorokSzama := 0
          Else
          {$ENDIF}
          WriteSorszam;

          Inc(TotalSorokSzama,SorokSzama);

          {$IFDEF EKSZ_ASC}
          If OpenAsc Then Close(AscF);
          {$ELSE}
          Close(EkszF);
          {$ENDIF}

          If IOResult <> 0 Then Terminate(Ofn,CloseError);
        End;

        {$IFDEF EKSZ_ASC}
        Close(EkszF);
        {$ELSE}
        Close(AscF);
        {$ENDIF}

        If IOResult <> 0 Then Terminate(Ifn,CloseError);

        FindNext(DirInfo);

        WriteLn;

        If KeyPressed Then If ReadKey = #27 Then Abort := True;

      End;  { While DosError = 0 }

      Inc(GCount);

      Fi := IPath + Group[GCount];

    Until Abort OR (GCount > Groups);

    GetTime(Hour2, Minute2, Second2, Sec1002);
    Time2 := ZipTime(Hour2,Minute2,Second2,Sec1002);

    Time1 := Time2-Time1;

    UnZipTime(Time1,Hour1,Minute1,Second1,Sec1001);

    GotoXY(1,WhereY);
    WriteLn('ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ');
    WriteLn('Feldolgozott file-ok sz†ma:',Files:4,
            '        Feldolgozott sorok sz†ma: ',TotalSorokSzama:7);

    If TotalSorokSzama > 0 Then
    Begin
      WriteLn;
      Write('Eltelt idì : ');
      If Hour1 > 0   Then Write(Hour1,' ¢ra ');
      If Minute1 > 0 Then Write(Minute1,' perc ');
      SorPerSec := TotalSorokSzama / (3600*Hour1+60*Minute1+Second1+(Sec1001/10));
      Write(Second1,'.',Sec1001,' mp   ',SorPerSec:5:2,' sor / mp');
    End;

    FreeMem(P,SizeOf(P^));

  End
  Else WriteHelp;

End.
