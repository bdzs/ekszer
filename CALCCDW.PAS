Unit CalcCDW;

{$O+}

Interface

Uses crt,Video,VideoKit,Dos,WindowM;

Procedure CreateCalcResult(Szam: Real);
Procedure Calc;

Implementation

Uses Inputcdw;

Const

{$IFDEF NORVEG}

Helyi : Array[1..7] Of String[8] =

('','','hundre','tusen-','','hundre','million-');

Szamjegy : Array[0..9] Of String[6] =

 ('',
  'en',
  'to',
  'tre',
  'fire',
  'fem',
  'seks',
  'syv',
  '†tte', {†}
  'ni');

Tizen : Array[1..9] Of String[9] =

 ('ellve',
  'tolv',
  'tretten',
  'fjorten',
  'femten',
  'seisen',
  's›tten',
  'atten',
  'nitten');

Tizes : Array[1..9] Of String[9] =

 ('en',
  'tyve',
  'tretti',
  'f›rti',
  'femti',
  'seksti',
  'sytti',
  '†tti',
  'nitti');

TizHusz : Array[1..2] Of String[4] =  ('en','tyve');

{$ELSE}
  {$IFDEF ANGOL}

  Helyi : Array[1..7] Of String[10] =

  ('','','hundred ','thousand ','','hundred ','million ');

  Szamjegy : Array[0..9] Of String[8] =

   ('',
    'one ',
    'two ',
    'three ',
    'four ',
    'five ',
    'six ',
    'seven ',
    'eight ',
    'nine ');

  Tizen : Array[1..9] Of String[12] =

   ('eleven ',
    'twelve ',
    'thirteen ',
    'fourteen ',
    'fifteen ',
    'sixteen ',
    'seventeen ',
    'eighteen ',
    'nineteen ');

  Tizes : Array[1..9] Of String[10] =

   ('ten ',
    'twenty-',
    'thirty-',
    'forty-',
    'fifty-',
    'sixty-',
    'seventy-',
    'eighty-',
    'ninety-');

  TizHusz : Array[1..2] Of String[7] =  ('ten','twenty');

  {$ELSE}

    {$IFDEF ROMAN}
    Helyi : Array[1..7] Of String[7] =

    ('','','suta','mie ','','suta','milion ');

    Szamjegy : Array[0..10] Of String[6] =

     ('',
      'unu',
      'doi',
      'trei',
      'patru',
      'cinci',
      'sase',
      'sapte',
      'opt',
      'noua',

      'doua');

  Tizen : Array[1..9] Of String[14] =

   ('unsprezece',
    'doisprezece',
    'treisprezece',
    'patrusprezece',
    'cincisprezece',
    'saisprezece',
    'saptesprezece',
    'optsprezece',
    'nouasprezece');

    Tizes : Array[1..9] Of String[11] =

     ('','douazecisi','treizecisi','patruzecisi','cinzecisi',
      'saizecisi','saptezecisi','optzecisi','nouazecisi');

    TizHusz : Array[1..9] Of String[11] =

   ('zece','douazeci','treizeci','patruzeci','cinzeci',
      'saizeci','saptezeci','optzeci','nouazeci');

    {$ELSE}
    Helyi : Array[1..7] Of String[7] =

    ('','','sz''z','ezer/','','sz''z','milli=/');

    Szamjegy : Array[0..9] Of String[6] =

     ('',
      'egy',
      'kett[',
      'h''rom',
      'n;gy',
      '0t',
      'hat',
      'h;t',
      'nyolc',
      'kilenc');

    Tizes : Array[1..9] Of String[9] =

     ('tizen','huszon','harminc','negyven','0tven',
      'hatvan','hetven','nyolcvan','kilencven');

    TizHusz : Array[1..2] Of String[4] =  ('t`z','h]sz');

    {$ENDIF}

  {$ENDIF}
{$ENDIF}

    UresVolt          : Boolean = False;

Var Sz,I              : LongInt;
    XX,Modulo,EzerMod : Byte;
    Poz               : Byte;
    Wstring           : String;

Function Formatted(Size:Real): String;
Var SizeSt : String[80];
    Ci     : Byte;
Begin
  Str(Size:18:Tizedesek,SizeSt);
  If Pos('.',SizeSt) = 0 Then
    Ci := Length(SizeSt)+1-3
  Else
    Ci := Pos('.',SizeSt)-3;

  While (Ci > 1) AND NOT(SizeSt[Ci-1] In [' ','-']) Do
  Begin
    Insert(',',SizeSt,Ci);
    Dec(Ci,4);
    Delete(SizeSt,1,1);
  End;
  Formatted := SizeSt;
End;

Procedure CreateCalcResult(Szam: Real);
Var Ws       : String[80];
{$IFDEF NORVEG}
    OcalcAzaz: String;
    OXX,
    OModulo  : Byte;
    TizenValahany : Boolean;
{$ELSE}
  {$IFDEF ANGOL}
      OcalcAzaz: String;
      OXX,
      OModulo  : Byte;
      TizenValahany : Boolean;
  {$ENDIF}
  {$IFDEF ROMAN}
      OcalcAzaz: String;
      OXX,
      Plussz,
      OModulo  : Byte;
      TizenValahany : Boolean;
  {$ENDIF}
{$ENDIF}

Begin

  CalcRes := Szam;

  Case Format Of
    0   : Str(szam*100:18:Tizedesek,CalcResult);
    1   : Str(szam:18:Tizedesek,CalcResult);
    2   : CalcResult := Formatted(szam);
    3   : Str(szam:Tizedesek,CalcResult);
  End;

  If Pos('+',CalcResult) > 0 Then Delete(CalcResult,Pos('+',CalcResult),1);

  While CalcResult[1] = ' ' Do Delete(CalcResult,1,1);

  If (Format <> 3) AND (Pos('.',CalcResult) > 0) Then
    While CalcResult[Length(CalcResult)] = '0' Do Dec(Byte(CalcResult[0]));

  If CalcResult[Length(CalcResult)] = '.' Then Dec(Byte(CalcResult[0]));

  If Format = 0 Then CalcResult := CalcResult + '%';


  Poz := Pos('#',Szammal);

  If Poz = 0 Then
    CalcResult := CalcResult + Szammal
  Else
  Begin
    Wstring := Szammal;
    Delete(Wstring,Poz,1);
    Insert(CalcResult,Wstring,Poz);
    CalcResult := Wstring;
  End;

  I := 10;
  XX:= 1;
  Sz:= ABS(Round(Szam));
  CalcAzazResult := '';
  EzerMod := 0;

  {$IFNDEF SZLOVAK}
  {$IFNDEF GOROG}

  {$IFDEF NORVEG}
  While Sz > 0 Do
  Begin
    TizenValahany := False;
    Ws := '';
    Modulo := (Sz MOD I) DIV (I DIV 10);
    If Modulo > 0 Then
    Begin

      If XX = 4 Then EzerMod := Modulo;
      If (XX = 6) AND (EzerMod = 0) Then
        CalcAzazResult := Helyi[4] + CalcAzazResult; {@@@}

      If XX In [2,5,8] Then
        Begin
          If (UresVolt) AND (Modulo < 3) Then
            Ws := TizHusz[Modulo]
          Else
          Begin
            Ws := Tizes[Modulo];
            If Modulo = 1 Then TizenValahany := True;
          End;
          If (UresVolt) AND (XX > 2) Then Ws := Ws + Helyi[XX-1];
        End
        Else
        Begin
          Ws := Szamjegy[Modulo] + Helyi[XX];
          OCalcAzaz := CalcAzazResult;
          OModulo   := Modulo;
          OXX       := XX;
        End;
      If NOT TizenValahany Then
        CalcAzazResult := Ws + CalcAzazResult
      Else
        CalcAzazResult := Tizen[OModulo] + Helyi[OXX] + OCalcAzaz;

      UresVolt := False;
    End
    Else
      UresVolt := True;
    Dec(Sz,(Sz MOD I));
    Inc(XX);
    I := I * 10;
  End;
  {$ELSE}
    {$IFDEF ANGOL}
    While Sz > 0 Do
    Begin
      TizenValahany := False;
      Ws := '';
      Modulo := (Sz MOD I) DIV (I DIV 10);
      If Modulo > 0 Then
      Begin

        If XX = 4 Then EzerMod := Modulo;
        If (XX = 6) AND (EzerMod = 0) Then
          CalcAzazResult := Helyi[4] + CalcAzazResult; {@@@}

        If XX In [2,5,8] Then
          Begin
            If (UresVolt) AND (Modulo < 3) Then
              Ws := TizHusz[Modulo]
            Else
            Begin
              Ws := Tizes[Modulo];
              If Modulo = 1 Then TizenValahany := True;
            End;
            If (UresVolt) AND (XX > 2) Then Ws := Ws + Helyi[XX-1];
          End
          Else
          Begin
            Ws := Szamjegy[Modulo] + Helyi[XX];
            OCalcAzaz := CalcAzazResult;
            OModulo   := Modulo;
            OXX       := XX;
          End;
        If NOT TizenValahany Then
          CalcAzazResult := Ws + CalcAzazResult
        Else
          CalcAzazResult := Tizen[OModulo] + Helyi[OXX] + OCalcAzaz;

        UresVolt := False;
      End
      Else
        UresVolt := True;
      Dec(Sz,(Sz MOD I));
      Inc(XX);
      I := I * 10;
    End;
  {$ELSE}
  {$IFDEF ROMAN}
    While Sz > 0 Do
    Begin
      TizenValahany := False;
      Ws := '';
      Modulo := (Sz MOD I) DIV (I DIV 10);
      If Modulo > 0 Then
      Begin

        If XX = 4 Then EzerMod := Modulo;
        If (XX = 6) AND (EzerMod = 0) Then
          CalcAzazResult := Helyi[4] + CalcAzazResult; {@@@}

        If XX In [2,5,8] Then
          Begin
            If (UresVolt) AND (Modulo < 10) Then
              Ws := TizHusz[Modulo]
            Else
            Begin
              Ws := Tizes[Modulo];
              If Modulo = 1 Then TizenValahany := True;
            End;
            If (UresVolt) AND (XX > 2) Then Ws := Ws + Helyi[XX-1];
          End
          Else
          Begin
            Plussz := 0;
            If XX In [3,6] Then
            Begin
              If Modulo = 2 Then Plussz := 8;
              If Modulo = 1 Then Helyi[XX] := 'suta'
                            Else Helyi[XX] := 'sute';
            End
            Else
            If XX = 4 Then
            Begin
              If Modulo = 2 Then Plussz := 8;
              If Modulo = 1 Then Helyi[4] := 'mie'
                            Else Helyi[4] := 'mii ';
            End;
            Ws := Szamjegy[Modulo+Plussz] + Helyi[XX];
            OCalcAzaz := CalcAzazResult;
            OModulo   := Modulo;
            OXX       := XX;
          End;
        If NOT TizenValahany Then
          CalcAzazResult := Ws + CalcAzazResult
        Else
          CalcAzazResult := Tizen[OModulo] + Helyi[OXX] + OCalcAzaz;

        UresVolt := False;
      End
      Else
        UresVolt := True;
      Dec(Sz,(Sz MOD I));
      Inc(XX);
      I := I * 10;
    End;
  {$ELSE}
  While Sz > 0 Do
  Begin
    Ws := '';
    Modulo := (Sz MOD I) DIV (I DIV 10);
    If Modulo > 0 Then
    Begin

      If XX = 4 Then EzerMod := Modulo;
      If (XX = 6) AND (EzerMod = 0) Then
        CalcAzazResult := Helyi[4] + CalcAzazResult; {@@@}

      If XX In [2,5,8] Then
        Begin
          If (UresVolt) AND (Modulo < 3) Then
            Ws := TizHusz[Modulo]
          Else
            Ws := Tizes[Modulo];
          If (UresVolt) AND (XX > 2) Then Ws := Ws + Helyi[XX-1];
        End
        Else
          Ws := Szamjegy[Modulo] + Helyi[XX];
      CalcAzazResult := Ws + CalcAzazResult;
      UresVolt := False;
    End
    Else
      UresVolt := True;
    Dec(Sz,(Sz MOD I));
    Inc(XX);
    I := I * 10;
  End;
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}

  If CalcAzazResult = '' Then CalcAzazResult := ' ';
  CalcAzazResult[1] := UpCase(CalcAzazResult[1]);
  If CalcAzazResult[1] = '0' Then CalcAzazResult[1] := ')';

  If CalcAzazResult[Length(CalcAzazResult)] = '/' Then
    Dec(Byte(CalcAzazResult[0]));

  {$IFDEF ANGOL}
  If CalcAzazResult[Length(CalcAzazResult)] In ['-',' ',#00] Then
    Dec(Byte(CalcAzazResult[0]));
  {$ENDIF}

  If (Szam > 1000) AND (Szam < 2000) Then
    If Pos('/',CalcAzazResult) > 0 Then
      Delete(CalcAzazResult,Pos('/',CalcAzazResult),1);

  Poz := Pos('#',Betuvel);

  If Poz = 0 Then
    CalcAzazResult := CalcAzazResult + Betuvel
  Else
  Begin
    Wstring := Betuvel;
    Delete(Wstring,Poz,1);
    Insert(CalcAzazResult,Wstring,Poz);
    CalcAzazResult := Wstring;
  End;

  {$ENDIF}
  {$ENDIF}

  CRPoz := Length(CalcResult);

End; { CreateCalcResult }

(******************************************************************)

Procedure Calc;

type   st80       = string[80];
       SorTipus   = String[56];


Var Register        : Registers;
    Ws              : String[80];
    VoltCur         : Boolean;
    LastSor         : Byte;

Type  ST=STRING[30];

const
    masolas:boolean=false;


procedure inter_10(x:char);
   begin
         register.ax  :=$0a00+ord(x);
         register.cx  :=1;
         register.bx  :=4;
         intr($10,register)
   end;

TYPE
  INDEX='E'..'S';
  x=string[11];
  hexst=string[7];
CONST
  XPOZ  : ARRAY[INDEX]  OF INTEGER=(1,0,0,0,0,0,2,0, 3,10, 2, 2,0,0, 2);
  YPOZ  : ARRAY[INDEX]  OF INTEGER=(3,0,0,0,0,0,8,0, 3, 7,10, 7,0,0, 9);
  xcoo  : integer=1;
  ycoo  : integer=1;


Var
  kep  : array[1..17] Of SorTipus;

Const
  KAR  : ARRAY[11..15] OF char=('P','K','O','S','N');
  kar2 : array[11..15] of Char=('+','-','/','*','=');

{$IFDEF NORVEG}

  gep  : array[1..17]  of string[56]=
              ('É1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1»1',
               'º1 2 2 2Õ1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¸1 2 2 2º1',
               'º1 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2º1',
               'º1 4 2 4Ô1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¾1 2 2 2º1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'Ì1Í1 3O3p3e3r3a3s3j3o3n3 3Ñ1Í1Í1Í1 3M3i3n3n3e3 3Í1Í1Í1¹1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'º1 2+4 2l4e4g4g4s4a4m4m4e4³1 2P4 2M4i4n4.4p4l4u4s4 2 2º1',
               'º1 2-4 2t4r4e4k4k4i4f4r4a4³1 2M4 2M4i4n4.4m4i4n4.4 2 2º1',
               'º1 2*4 2g4a4n4g4e4m4e4d4 2³1 2L4 2M4i4n4.4s4l4e4t4t4e4º1',
               'º1 2/4 2d4e4l4e4 2 2 2 2 2³1 2R4 2M4i4n4.4u4t4s4k4r4.4º1',
               'º1 2T4 2S4q4r4.4r4o4o4t4 2Ã1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1¶1',
               'º1 2S4 2k4v4a4d4r4a4t4 2 2³1 2C4 2S4l4e4t4t4e4 2 2 2 2º1',
               'º1 2Z4 2s4i4g4n4u4m4 2 2 2³1 2E4 2S4l4e4t4t4e4 2 2 2 2º1',
               'º1 2H4 2H4e4x4a4 2 2 2 2 2³1 2 2 2s4i4s4t4e4 4t4a4l4l4º1',
               'º1 2A4 2A4S4C4I4I4 2 2 2 2³1 2D4 2D4e4c4i4m4a4l4 2 2 2º1',
               'È1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Ï1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¼1');

{$ELSE}
  {$IFDEF ANGOL}

    gep  : array[1..17]  of string[56]=
              ('É1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1»1',
               'º1 2 2 2Õ1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¸1 2 2 2º1',
               'º1 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2º1',
               'º1 4 2 4Ô1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¾1 2 2 2º1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'Ì1Í1 3O3p3e3r3a3t3i3o3n3 3Ñ1Í1Í1Í1 3M3e3m3o3r3y3 3Í1Í1¹1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'º1 2+4 2A4d4d4i4t4i4o4n4 2³1 2P4 2M4e4m4.4p4l4u4s4 2 2º1',
               'º1 2-4 2S4u4b4s4t4r4.4 2 2³1 2M4 2M4e4m4.4m4i4n4u4s4 2º1',
               'º1 2*4 2M4u4l4t4i4p4l4y4 2³1 2L4 2C4l4e4a4r4 4m4e4m4.4º1',
               'º1 2/4 2D4i4v4i4d4e4 2 2 2³1 2R4 2D4i4s4p4.4m4e4m4.4 2º1',
               'º1 2T4 2S4q4r4.4r4o4o4t4 2Ã1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1¶1',
               'º1 2S4 2S4q4u4a4r4e4 2 2 2³1 2C4 2C4l4e4a4r4 2 2 2 2 2º1',
               'º1 2Z4 2S4i4g4n4u4m4 2 2 2³1 2E4 2C4l4e4a4r4 4l4a4s4t4º1',
               'º1 2H4 2H4e4x4.4 2 2 2 2 2³1 2 2 2 2 4n4u4m4b4e4r4 4 2º1',
               'º1 2A4 2A4S4C4I4I4 2 2 2 2³1 2D4 2D4e4c4i4m4a4l4 2 2 2º1',
               'È1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Ï1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¼1');

  {$ELSE}
   {$IFDEF OROSZ}


    gep  : array[1..17]  of string[56]=
              ('É1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1»1',
               'º1 2 2 2Õ1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¸1 2 2 2º1',
               'º1 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2º1',
               'º1 4 2 4Ô1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¾1 2 2 2º1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'Ì1Í1 3Ž3¯3¥3à3 3æ3¨3¨3 3 3Ñ1Í1Í1Í1 33 3¬3ï3â3ì3 3 3Í1¹1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'º1 2+4 24à4¨4¡4 4¢4¨4â4ì4³1 2P4 24 4¬4.4¯4«4î4á4 2 2º1',
               'º1 2-4 2Ž4â4­4ï4â4ì4 2 2 2³1 2M4 24 4¬4.4¬4¨4­4ã4á4 2º1',
               'º1 2*4 2“4¬4­4®4¦4¨4â4ì4 2³1 2L4 24 4¬4.4á4â4¥4à4.4 2º1',
               'º1 2/4 2„4¥4«4¨4â4ì4 2 2 2³1 2R4 24 4¬4.4¯4®4ª4 4§4.4º1',
               'º1 2T4 2Š4®4à4¥4­4ì4 2 2 2Ã1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1¶1',
               'º1 2S4 2Š4¢4 4¤4à4 4â4 2 2³1 2C4 2‘4â4¥4à4¥4â4ì4 2 2 2º1',
               'º1 2Z4 2‡4­4 4ª4 2 2 2 2 2³1 2E4 24®4á4«4¥4¤4­4¥4¥4 2º1',
               'º1 2H4 2H4e4x4a4 2 2 2 2 2³1 2 2 2ç4¨4á4«4®4 2á4â4¥4à4º1',
               'º1 2A4 2A4S4C4I4I4 2 2 2 2³1 2D4 2„4¥4æ4¨4¬4 4«4.4 2 2º1',
               'È1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Ï1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¼1');

    {$ELSE}

   {$IFDEF ROMAN}
    gep  : array[1..17]  of string[56]=
              ('É1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1»1',
               'º1 2 2 2Õ1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¸1 2 2 2º1',
               'º1 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2º1',
               'º1 4 2 4Ô1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¾1 2 2 2º1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'Ì1Í1 3O3p3e3r3a3t3i3i3 3 3Ñ1Í1Í1Í1 3M3e3m3o3r3i3e3 3Í1¹1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'º1 2+4 2a4d4a4u4g4a4r4e4 4³1 2P4 2M4e4m4.4p4l4u4s4 2 2º1',
               'º1 2-4 2s4c4a4d4e4r4e4 2 2³1 2M4 2M4e4m4.4m4i4n4u4s4 2º1',
               'º1 2*4 2i4n4m4u4l4t4i4r4e4³1 2L4 2M4e4m4.4a4n4u4l4a4r4º1',
               'º1 2/4 2i4m4p4a4r4t4i4r4e4³1 2R4 2M4e4m4.4a4p4a4r4i4t4º1',
               'º1 2T4 2r4a4d4i4c4a4l4 4 4Ã1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1¶1',
               'º1 2S4 2p4a4t4r4a4t4 2 2 2³1 2C4 2A4n4u4l4a4r4e4 2 2 2º1',
               'º1 2Z4 2s4i4g4n4u4m4 2 2 2³1 2E4 2A4n4u4l4a4r4e4 2 2 2º1',
               'º1 2H4 2H4e4x4a4 2 2 2 2 2³1 2 2 2u4l4t4.4n4u4m4a4r4 2º1',
               'º1 2A4 2A4S4C4I4I4 2 2 2 2³1 2D4 2D4e4c4i4m4a4l4 2 2 2º1',
               'È1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Ï1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¼1');
   {$ELSE}
    gep  : array[1..17]  of string[56]=
              ('É1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1»1',
               'º1 2 2 2Õ1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¸1 2 2 2º1',
               'º1 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2º1',
               'º1 4 2 4Ô1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¾1 2 2 2º1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'Ì1Í1 3M3–3v3e3l3e3t3e3k3 3Ñ1Í1Í1Í1 3M3e3m3¢3r3i3a3 3Í1¹1',
               'º1 2 2 2 2 2 2 2 2 2 2 2 2³1 2 2 2 2 2 2 2 2 2 2 2 2 2º1',
               'º1 2+4 2”4s4s4z4e4a4d4 4s4³1 2P4 2M4e4m4.4p4l4u4s4z4 2º1',
               'º1 2-4 2k4i4v4o4n4 4s4 2 2³1 2M4 2M4e4m4.4m4i4n4.4 2 2º1',
               'º1 2*4 2s4z4o4r4z4 4s4 2 2³1 2L4 2M4e4m4.4t4”4r4l4‚4s4º1',
               'º1 2/4 2o4s4z4t4 4s4 2 2 2³1 2R4 2M4e4m4.4k4i4¡4r4 4s4º1',
               'º1 2T4 2g4y4”4k4v4o4n4 4s4Ã1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1Ä1¶1',
               'º1 2S4 2n4‚4g4y4z4e4t4 2 2³1 2C4 2T4”4r4l4‚4s4 2 2 2 2º1',
               'º1 2Z4 2e4l4“4j4e4l4 2 2 2³1 2E4 2U4t4o4l4s4¢4 2 2 2 2º1',
               'º1 2H4 2H4e4x4a4 2 2 2 2 2³1 2 2 2s4z4 4m4 4t4”4r4l4.4º1',
               'º1 2A4 2A4S4C4I4I4 2 2 2 2³1 2D4 2D4e4c4i4m4 4l4i4s4 2º1',
               'È1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Ï1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1Í1¼1');
    {$ENDIF}
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

szinek : array[DispType,'1'..'7'] of char =
       { Keret Tobbi Cim  Kiem Eredm Err Muvelet    }
        (( #31, #55,  #15,#112, #48,#206,#14),
         (  #7,  #7, #120, #15,#120,#120,#120));


check       : byte = 0;
IR          : REAL = 0.000000;

utolso      : real = 0.000000;

glx         : integer = 0 ;
gli         : integer = 0 ;

glws        : string[7] = ' ' ;

gly         : real = 0.0 ;
glz         : real = 0.0 ;

A           : CHAR = #0;
W           : CHAR = #0;
NL          : CHAR = #0;
aktchar     : CHAR = ' ';

EL          : INTEGER = 00;
ATVI2       : INTEGER = 00;
F           : INTEGER = 00;
K           : INTEGER = 00;
ccikl       : INTEGER = 00;
CCIKL2      : INTEGER = 00;

masolas2    : boolean = false;
ottvolt     : boolean = false;

erro        : BOOLEAN = FALSE;
atvi        : BOOLEAN = FALSE;
hej         : BOOLEAN = FALSE;
Graphic     : Boolean = False;
II          : Boolean = False;

Var
  Scbuf             : Array[1..7800] Of Byte;

Procedure Visszament;
Begin
  FelSor_IdeOdaW(Xcoo-1,28,34,(Ycoo-1)*2,Ofs(ScBuf),
                                         Seg(ScBuf),
                                         SortabOffs,1);
End;
Procedure Elment;
Begin
  FelSor_IdeOdaW(Xcoo-1,28,34,(Ycoo-1)*2,Ofs(ScBuf),
                                         Seg(ScBuf),
                                         SortabOffs,0);
End;



Procedure Displa(st:String;
                 Y,X:Integer);
Begin
  If Graphic Then
    Begin
      gotox(X-1,(Y-1)*2-2);
      Writ(st);
    End
  Else
    Display(st,Y,X);
End;

Procedure DispC(st:Char;
                 Y,X:Integer);
Begin
  If Graphic Then
    Begin
      gotox(X-1,(Y-1)*2);
      Writ(st+'');
    End
  Else
    DispCh(st,Y,X);
End;

procedure attolt;
var cikl,cikl2 : integer;
begin

  if check = 0
  then
    for cikl:= 1 to 17 do
      for cikl2:=  0 to 27 do
        gep[cikl][cikl2*2 +2] := szinek[DispMode,gep[cikl][cikl2*2+2]];
  check:=1;
end;


 function HEX(wr:real):hexst;

  const loc:array [0..15] of char =
           ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

  begin
     wr:=abs(wr);
     gly:=16777216.0;
     glws[0]:=chr(7);
     for glx:=1 to 7 do begin
                        glz:=int(wr/gly);
                        gli:=trunc(glz);
                        glws[glx]:=loc[gli];
                        wr:=wr-glz*gly;
                        gly:=int(gly/16);
                      end;
  hex:=glws;

 end;        { function HEX }

Procedure ClearLine;
Begin
  If Not Graphic Then
    Attribute(2+Ycoo,5+Xcoo,2+Ycoo,22+Xcoo,Byte(Szinek[DispMode,'5']));
  Displa('                  ',2+ycoo,5+xcoo);
End;

procedure hexa(vmi:real);
          begin
            hej:=true;
            ClearLine;
            Displa('HEX  '+Hex(vmi),2+Ycoo,5+Xcoo);
          end;

procedure asc;
  var t:integer;
          begin
            if (szam[akt]>=0) and (szam[akt]<=256.0) then t:=trunc(szam[akt]);
            if (t>=0) and (t<=255) then
                begin
                  ClearLine;
                  Displa('ASC    '+Char(t),2+Ycoo,5+Xcoo);
                end
          end;

procedure decc;
  begin
          hej:=false;
          ClearLine;
          Str(szam[akt]:18:8,Ws);
          Displa(Ws,2+Ycoo,5+Xcoo);
          utolso:=szam[akt]
  end;


function inter(ss:real):boolean;
  begin
    inter:=(ss>=-99999999.99999999) and (ss<=99999999.99999999)
  end;

Procedure Tom(Var SS:String);
Var Cikl : Integer;
Begin
  For Cikl := 2 To Length(SS) Div 2 + 1 Do
    Delete(SS,Cikl,1);
End;


procedure tabla;
  var cikl : integer;
      SS : String;
 begin
   If Graphic Then
     for cikl := 1 To 17 Do
       Begin
         gotox(Xcoo-1,(Ycoo+Cikl-1-1)*2-2);
         SS := Gep[Cikl];
         Tom(SS);
         Writ(SS);
       End
   Else
     for cikl:=1 to 17 do
       Set_String(Gep[Cikl],Ycoo+Cikl-1,Xcoo);
 end; { Tabla kiiras }

procedure elmentes;
var cikl : integer;
begin
  for cikl:=1 to 17 do
    Get_String(Kep[Cikl],cikl+ycoo-1,xcoo);
end;

procedure visszamentes;
var cikl : integer;
begin
  for cikl:=1 to 17 do
    Set_String(Kep[Cikl],cikl+ycoo-1,xcoo);
end;

procedure kiiras(vmi:real);
  begin
    utolso:=vmi;
    if hej
      then
        hexa(vmi)
      else
        begin
          ClearLine;
          Str(vmi:18:8,Ws);
          Displa(Ws,2+Ycoo,5+Xcoo);
        end
  end;


procedure kigyujt(w:char;e:integer);
Var Yco : Integer;
begin
    Yco := Ycoo;
    if e<>15
      then
        Begin
          If Graphic Then
          Begin
            Dec(Yco);
            Inverz := True;
          End
          Else
            If w = 'E' Then
              AttribCh(Byte(Szinek[DispMode,'6']),YPOZ[W]+ycoo,XPOZ[W]+xcoo)
            Else
              AttribCh(Byte(Szinek[DispMode,'7']),YPOZ[W]+ycoo,XPOZ[W]+xcoo);
          if e<>0
            then
              begin
                DispC(kar2[e],YPOZ[W]+yco,XPOZ[W]+xcoo);
                aktchar:=w
              end
            else
              DispC(W,YPOZ[W]+yco,XPOZ[W]+xcoo);
          If Graphic Then Inverz := False;
        End;
    textcolor(black);
    textbackground(white);

  end;

procedure visszaallit;
  begin
    if aktchar <> ' ' then kigyujt(aktchar,muvakt);
    if erro then kigyujt('E',0);
    if memoria <> 0 then kigyujt('M',0)
  end;

procedure rea(var a:char);
  var x,y:Byte;
      xc,yc : Char;
  begin
    repeat
      KellConvert := False;
      puffi(y,x);
      KellConvert := True;

      {X  := 0;
      YC := ReadKey;
      If YC =  #0 Then
          begin
           Y  := 0;
           XC := readkey;
           X  := byte(XC);
          end
      Else Y := byte(YC);
      }

      LastSor := Byte(Graphic)*((LastLine+3) DIV 2) +
                 Byte(NOT Graphic)*25;

      If y=0
        then
         begin
          case x of
            FelNyil:  if (ycoo > 1) then
                        If Graphic Then
                          Begin
                            Visszament;
                            Dec(Ycoo);
                            Elment;
                            Tabla
                          End
                        Else
                          begin
                            Set_String(Kep[17],Ycoo+16,Xcoo);
                            Move(Kep[1],Kep[2],16*(56+1));
                            Get_String(Kep[1],Ycoo-1,Xcoo);
                            Dec(Ycoo);
                            tabla;
                          end;
           BalraNyil: if xcoo > 1 then
                        If Graphic Then
                          Begin
                            Visszament;
                            Dec(Xcoo);
                            Elment;
                            tabla
                          End
                        Else
                          Begin
                            Set_Vmode(True);
                            Set_StrStep(56+1);
                            Set_StrLen(34);

                            Set_String(Kep[1,55],Ycoo,Xcoo+27);

                            For Ccikl := 1 To 17 Do
                              Move(Kep[Ccikl,1],Kep[Ccikl,3],54);

                            Get_String(Kep[1][1],ycoo,Xcoo-1);

                            Dec(xcoo);

                            Set_Vmode(False);
                            Set_StrStep(2);

                            tabla;
                          end;
           JobbraNyil:IF xcoo+28-1 < 80 then
                        If Graphic Then
                          Begin
                            Visszament;
                            Inc(Xcoo);
                            Elment;
                            tabla
                          End
                        Else
                          begin
                            Set_Vmode(True);
                            Set_StrStep(56+1);
                            Set_StrLen(34);

                            Set_String(Kep[1,1],Ycoo,Xcoo);

                            For Ccikl := 1 To 17 Do
                              Move(Kep[Ccikl,3],Kep[Ccikl,1],54);

                            Get_String(Kep[1][55],ycoo,Xcoo+28);

                            Inc(xcoo);

                            Set_Vmode(False);
                            Set_StrStep(2);
                            tabla;
                          end;
             LeNyil:  If  (Ycoo+17-1 < LastSor) Then
                        If Graphic Then
                          Begin
                            Visszament;
                            Inc(Ycoo);
                            Elment;
                            Tabla
                          End
                        Else
                          begin
                             Set_String(Kep[1],Ycoo,Xcoo);
                             Move(Kep[2],Kep[1],16*(56+1));
                             Get_String(Kep[17],Ycoo+17,Xcoo);
                             Inc(Ycoo);
                             tabla;
                          end;
          end;
        kiiras(utolso);
        visszaallit
      end
    until y<>0;
    a:=chr(y)
  end;

procedure kiolt(w:char;e:integer);
Var Yco : Integer;
  begin
    Yco := Ycoo-1;
    if e<>15
      then
        Begin
          If Not Graphic Then
          Begin
            Inc(Yco);
            AttribCh(Byte(Szinek[DispMode,'4']),YPOZ[W]+yco,XPOZ[W]+xcoo);
          End;
          if e<>0
            then
              begin
                DispC(kar2[e],YPOZ[W]+yco,XPOZ[W]+xcoo);
                aktchar:=' '
              end
            else
              DispC(' ',YPOZ[W]+yco,XPOZ[W]+xcoo);
          If Graphic Then Inverz := False;
        End;

  end;

procedure torles(n:integer);
  begin
    KIOLT('E',0);
    if n=1 then
      begin
        szam[1]:=0;
        kiolt(kar[muvakt],muvakt);
        akt:=1;
        erro:=false
      end;
    szam[2]:=0;
    szam[akt]:=0;
    kiiras(0.0);
    jel2:=true;
    tizedes:=false;
    oszto:=1
  end;

PROCEDURE SZAMOK;
  begin
    atvi:=tizedes;
    if (muvakt=15) and (not jel2)
      then
        torles(1);
    tizedes:=atvi;
    if not jel2
      then
        akt:=2;
    if jel
      then
        begin
          jel:=false;
          szam[akt]:=0
        end;
    jel2:=true;
    if ((((szam[akt]<10000000.0) and (szam[akt]>-10000000.0))
       or (tizedes))and(oszto<100000000.0))
       and not((hej) and (not inter(szam[akt]*16+ir)))
      then
        begin
          if not  tizedes or hej
            then
              if not hej
                then
                  szam[akt]:=szam[akt]*10
                else
                  szam[akt]:=szam[akt]*16;
          if tizedes and not hej
            then
              begin
                oszto:=oszto*10;
                ir:=ir/oszto
              end;
          Szam[Akt]:=szam[akt]+ir;
          kiiras(szam[akt])
        end
  end;

procedure vissza;
  begin
    if jel2
      then
        begin
          if szam[akt]=int(szam[akt])
            then
              tizedes:=false;
          if (not tizedes) or hej
            then
              if hej
                then
                  szam[akt]:=int(szam[akt]/16)
                else
                  szam[akt]:=int(szam[akt]/10)
                else
                  begin
                    oszto:=oszto/10;
                    szam[akt]:=int(szam[akt])+int((szam[akt]-int(szam[akt]))*oszto)/oszto
                  end;
          kiiras(szam[akt])
        end
  end;

function kod(a:char):integer;
  begin
    k:=255;
    case ord(a) of
       8 : vissza;
      13 : k:=15;
       1 : k:=30;
       2 : k:=31;
       3 : k:=32;
       4 : k:=33;
       5 : k:=34;
       6 : k:=35
       end;
     case a of
          '0'..'9': val(a,k,f);
          '.'     : k:=10;
          '+'     : K:=11;
          '-'     : K:=12;
          '/'     : K:=13;
          '*'     : K:=14;
          '='     : K:=15;
          'H'     : hexa(szam[akt]);
          'D'     : decc;
          'A'     : asc;
          'R'     : K:=16;
          'L'     : K:=17;
          'P'     : K:=18;
          'M'     : K:=19;
          'C'     : K:=20;
          'S'     : K:=21;
          'T'     : k:=22;
          'Z'     : k:=23;
          'E'     : k:=24
          end;
    KOD:=K
    end;

procedure vegzes;
  begin
    erro:=false;
    if not jel2
      then
        szam[2]:=szam[1];
    case muvakt of
      11 :if inter(szam[1]+szam[2]) then szam[1]:=szam[1]+szam[2]
            else erro:=true;
      12 :if inter(szam[1]-szam[2]) then szam[1]:=szam[1]-szam[2]
            else erro:=true;
      13 :begin
            if not jel2
              then
                begin
                  szam[2]:=1
                end;
            if (szam[2]<>0)
              then
                if inter(szam[1]/szam[2])
                  then
                    szam[1]:=szam[1]/szam[2]
                  else erro:=true
              else erro:=true
          end;
      14 :if inter(szam[1]*szam[2])
            then
              szam[1]:=szam[1]*szam[2]
            else
              erro:=true;
      end;
    kiiras(szam[1]);
    KIOLT(KAR[MUVAKT],muvakt)
  end;

procedure muvelet;
  begin
    if akt=2
      then
        vegzes;
    akt:=1;
    tizedes:=false;
    jel2:=false;
    szam[2]:=0;
    oszto:=1;
    muvakt:=trunc(ir);
    kiolt(kar[atvi2],atvi2);
    KIGYUJT(KAR[MUVAKT],muvakt);
    atvi2:=muvakt
  end;

{ Fåprogram }


Var calcMent : Byte;

Procedure NumLockOn;
Var KBF : Byte Absolute $40:$17;
Begin
  CalcMent := KBF And 32;
  KBF := Kbf Or 32;
End;

Procedure NumLockOff;
Var KBF : Byte Absolute $40:$17;
Begin
  kbf := (kbf And (255-32)) Or CalcMent
End;


begin
  Graphic := CRTMode = 6;
  CalcRek := True;
  NumLockOn;
  For Ccikl := 1 To 17 Do
  Kep[Ccikl,0] := #56;
  attolt;
  If Graphic Then
    Begin
      SaveXY;
      VoltCur := NemKellCursor;
      NemKellCursor := True;
      ycoo := 1;
      II := Inverz;
      Inverz := False;
      GlobalFont := 0;
      SystemWriting := False;
      Elment
    End
  Else
    elmentes;
  masolas:=false;
  hej:=false;
  nl:=chr(13);
  a:=' ';
  atvi2:=15;
  tabla;
  {delay(900);}
  If ElsoFutas Then
    Begin
      Memoria := 0;
      torles(1);
      ElsoFutas := False;
    End
  Else
    Begin
      kiiras(Szam[akt]);
      Visszaallit
    End;

  while (a<>'Q')      and
        (ord(a)<>27) Do
    begin
      WHILE erro do
        begin
          rea(a);
          a:=upcase(a);
          ir:=kod(a);
          if ir=20
            then
              torles(1)
        end;
      rea(a);
      a:=upcase(a);
      ir:=kod(a);
      case trunc(ir) of
        10 :if not tizedes
              then
                begin
                  tizedes:=true;
                  if jel2
                    then
                      kiiras(szam[akt])
                    else
                      kiiras(0.0)
                end;
        20 :torles(1);
        24 :torles(2);
        11..15 :muvelet;
        16 :begin
              atvi:=tizedes;
              if (muvakt=15) and (not jel2)
                then
                  torles(1);
              tizedes:=atvi;
              if not jel2
                then
                  akt:=2;
              szam[akt]:=memoria;
              jel2:=true;
              jel:=true;
              tizedes:=false;
              kiiras(szam[akt])
            end;
        23 :begin
              szam[akt]:=-szam[akt];
              kiiras(szam[akt])
            end;
        17..22 :begin
                  if akt=2
                    then
                      begin
                        vegzes;
                        akt:=1
                      end;
                  case trunc(ir) of
                    17 :begin
                          memoria:=0;
                          kiolt('M',0)
                        end;
                    18 :if inter(memoria+szam[akt])
                          then
                            begin
                              memoria:=memoria+szam[akt];
                              if memoria=0
                                then
                                  kiolt('M',0)
                                else
                                  kigyujt('M',0)
                            end
                          else
                            erro:=true;
                    19 :if inter(memoria-szam[akt])
                          then
                            begin
                              memoria:=memoria-szam[akt];
                              if memoria=0
                                then
                                  kiolt('M',0)
                                else
                                  kigyujt('M',0)
                            end
                          else
                            erro:=true;
                    21 :begin
                          if inter(sqr(szam[akt]))
                            then
                              szam[akt]:=sqr(szam[akt])
                            else
                              erro:=true;
                          kiiras(szam[akt])
                        end;
                    22 :begin
                          if szam[akt]>=0
                            then
                              szam[akt]:=sqrt(szam[akt])
                               else
                              erro:=true;
                          kiiras(szam[akt])
                        end
                    end;
                  akt:=1;
                  szam[2]:=0;
                  jel:=true;
                  oszto:=1;
                  tizedes:=false
                end
        end;
      if (ir>=30) and (ir<=35) and hej
        then
          begin
            ir:=ir-20;
            szamok
          end;
      if ir<10
        THEN
          SZAMOK;
      if erro
        then
          begin
            kigyujt('E',0);
            write(chr(7))
          end
    end;

    CalcNum := Szam[Akt];

    CreateCalcResult(Szam[Akt]);

  NumLockOff;
  If Graphic Then
    Begin
      RestoreXY;
      NemKellCursor := VoltCur;
      Inverz := II;
      Visszament
    End
  Else
    visszamentes;

  CalcRek := False;
  Esc := False
end; { Procedure calc }

End. { Unit calc }