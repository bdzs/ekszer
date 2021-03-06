Unit StartNyo;

{$O+}

{$I MEMORY.CDW}

InterFace

Uses Crt,Windowm,MenuErr,heapcdw,emscdw,video,inputcdw,nyomtat,

  {$IFDEF PROBA}
  printer,
  {$ENDIF}

  Nyom0,
  Nyom1,
  Nyom2,
  Nyom3,
  Nyom4,
  Nyom5,
  Nyom6,
  Nyom7,
  Nyom8,
  Nyom9,
  Nyom10,
  Nyom11
  {$IFNDEF VER352}
  ,Preview
  {$ENDIF}
  ,SpeakCdw
  ,Dos
  ;

Procedure StartPrint(Option : Integer);

Implementation


Procedure StartPrint(Option : Integer);

var
    kartomb       :  karmut;

    PrintN1       : ^PrintNLQ1;
    PrintN2       : ^PrintNLQ2;
    PrintD        : ^PrintDraft;       {8 -tus karakterek}

    mkm : dnloadtomb;

Const TulSok = 200;

Var
    StopEnd            : Boolean;
    BegPage,EndPage    : Integer;
    PC,Cikl            : Integer;
    SokSor             : Integer;
    SorSzam            : Longint;

    NyomtatoFile       : text;
    Fbyte              : text; {file of byte;}
    S                  : string;
    B                  : byte;
    OldMaxFel          : Integer;
    OldFormatum        : Boolean;
{---------------------------}

Function LQ_Load_Print(Option: integer):Boolean;      {.30T-t is ez tolt be!}
                                                      { 8-tus 30 magas 24 szeles }
                                                      {Option = 3-mmal hivva}
Var
    Cikl,Cikl2 : Integer;
    FileName   : St16;
    xx         : integer;
    ffile      : File;
    Fsiz       : Word;

    KpSeg      : Word;  { ^ }
    Ureske     : Word;  { | }

    Kpoint     : Pointer Absolute Ureske;             {stack-en forditva!!!}
    FreeSpace  : Word;
    TripleHex  : Byte;

Const
    Ext : Array[1..3] Of String[4] = ('.18T','.24T','.30T');

Begin
  LQ_Load_Print := True;
  Kpoint := StartPoint;
  FreeSpace := PointSize;
  Bool := CREATE_WINDOW(39,5,79,16,pr_mess3,CA[DispMode,1],Ca[DispMode,2]);
  If ppar.pr_ovr = 9 then
    TripleHex := Byte(ppar.pr_set_l_m[option]) - 10
  Else  TripleHex := Byte(ppar.pr_set_l_m[option]) - 38;

  CheckRead(PathSt);
  If Not Esc Then
  Begin
    For Cikl := 1 To MaxFontNum Do
     If Van_Font[Cikl] OR (CimFile <> '') Then
      Begin
        If Option in [1..2] then
          FileName := Fontnames[Cikl]+Ext[TripleHex]
        else  FileName := Fontnames[Cikl]+Ext[Option];

        Assign(Ffile,PathSt+FileName);
        {$i-} Reset(Ffile,1); {$i+}
        If IOresult <> 0 Then
        Begin
          Writeln(pr_mess4,Filename); {Error_msg[1]}
          Beepel(660);
          For Cikl2 := 1 To 94 Do
            KarTomb[Cikl,Cikl2].Cim := $FFFF
        End
        Else
          Begin
            {$IFDEF NORVEG}
            Writeln(Cikl,'. : ',FileName);
            {$ELSE}
            Writeln(Cikl,'. : ',FileName,pr_mess5);
            {$ENDIF}
            BlockRead(Ffile,Kartomb[Cikl],94*4);
            Fsiz := FileSize(ffile)-94*4;
                                                 { Ide jon a figyeles }
            If ((Fsiz+15) Div 16) <= FreeSpace Then
              Begin
                FontKezdet[Cikl] := Kpoint;
                BlockRead(Ffile,Kpoint^,Fsiz);
                Inc(KpSeg,(Fsiz+15) Div 16);
                Dec(FreeSpace,(Fsiz+15) Div 16);
              End
            Else
              Begin
                Error(4,pr_mess20);
                LQ_Load_Print := False;
                Close(Ffile);
                Bool := Remove_Window;
                Exit
              End;

            Close(Ffile);
          End;
      End;

    If Boolean(PluszFont) Then
      Begin                        {-------- Kepfont letrehozas  -------}
        KepFont := MaxFontNum + 1;
        For Cikl := 1 To 94 Do
          With KarTomb[KepFont,Cikl] Do
            Begin
              Bevezeto := 0;
              If Option in [1..2] then
               begin
                 Oszlopok := TripleHex *18;
                 Cim := (Cikl-1)*TripleHex*18*3;
               end
              else
               begin
                 Oszlopok := 24;
                 Cim := (Cikl-1)*24*3;
               end

            End;

        If Option in [1..2] then
             Fsiz := 3*TripleHex*18*94
        Else Fsiz := 3*24*94 ;

        If ((Fsiz+15) Div 16) <= FreeSpace Then
          Begin
            FontKezdet[KepFont] := Kpoint;
            FillChar(Kpoint^,Fsiz,0);
            Inc(KpSeg,(Fsiz+15) Div 16);
            Dec(FreeSpace,(Fsiz+15) Div 16);
          End
        Else
          Begin
            Error(4,pr_mess20);
            LQ_Load_Print := False;
            Bool := Remove_Window;
            Exit
          End;
      End;
  End;

  Bool := Remove_Window;

End; {LQ_Load_Print}

{===========================================================}
procedure LQ_load_download;

var
    FileName   : St16;
    xx         : integer;
    ffile      : File;
    b          : byte;
    Puffer     : Array[1..3000] Of Byte;
    Cikl       : Integer;

begin
   Bool := CREATE_WINDOW(39,5,79,9,pr_mess3,CA[DispMode,1],Ca[DispMode,2]);
   gotoxy(5,2); write(pr_mess7);
   CheckRead(PathSt);
   If Not Esc Then
    Begin
       Filename := ppar.pr_egyeb;
       Assign(Ffile,PathSt+FileName);
       {$i-} Reset(Ffile,1); {$i+}
       If IOresult <> 0 Then
         Begin
           Beepel(660);
           ppar.pr_download := false;
           error(1,csak12(filename));
         End
       Else
         begin
           blockread(ffile,Puffer,FileSize(ffile),XX);
           close(ffile);
           Cikl := 1;
           Repeat
              Lprint(Puffer[cikl]);
              Inc(Cikl);
           Until ESC or (Cikl > XX);
         end;
    End;
   bool := remove_window;
end;

Procedure LQLoadFont(Option: byte);

var cikl : byte;

Begin

  Esc := false;

  Case Option Of
    1,2 : Esc := Not LQ_Load_Print(Option);
    0   : If ppar.pr_download and (ppar.pr_egyeb <> '') then
            LQ_Load_Download;
    End;
End;
{================================}

Function Load_Print(Num:Integer): Boolean;

Var
    Cikl      : Integer;
    FileName  : St16;
    xx        : integer;
    SizeOfF   : Word;
    VanHely   : Boolean;
    MaxTalal  : WORD;

Const
    Ext :  Array[1..2] Of St16 =('.DFT','.PFT');

Begin
  Load_Print := True;

  PrintN1 := StartPoint;
  PrintN2 := Ptr(Seg(PrintN1^)+SizeOf(PrintN1^) Div 16,
                 Ofs(PrintN1^)+SizeOf(PrintN1^) Mod 16);

  PrintD  := StartPoint;

  If CimFile <> '' Then MaxTalal := MaxFontNum
    Else
  For Cikl := 1 To MaxFontNum Do
    If Van_Font[Cikl] Then
      MaxTalal := Cikl;

  If Num = 1 Then
    SizeOfF := (Longint(MaxTalal+PluszFont)*OneFontDraft+15) Div 16
  Else
    SizeOfF := (Longint(MaxTalal+PluszFont)*OneFontNLQ+15) Div 16;

  If SizeOfF <= PointSize Then
    Begin
      Bool := CREATE_WINDOW(39,5,79,16,pr_mess3,CA[DispMode,1],Ca[DispMode,2]);
      CheckRead(PathSt);
      If Not Esc Then
      Begin
        For Cikl := 1 To MaxFontNum Do
          If Van_Font[Cikl] OR (CimFile <> '') Then
            Begin

              FileName := Fontnames[Cikl] + Ext[Num];
              Assign(Fontfile,PathSt+FileName);
              {$i-} Reset(Fontfile); {$i+}
              If IOresult <> 0 Then
              Begin
                Beepel(660);
                Writeln(pr_mess4,Filename); {Error_msg[1]}
                If Num = 2 Then
                  If Cikl > FirstNLQ Then
                    Fillchar(PrintN2^[Cikl-FirstNLQ],OneFontNLQ,0)
                  Else
                    Fillchar(PrintN1^[Cikl],OneFontNLQ,0)
                Else
                  Fillchar(PrintD^[Cikl],OneFontDraft,0);
              End
              Else
                Begin
                  {$IFDEF NORVEG}
                  Writeln(Cikl,'. : ',FileName);
                  {$ELSE}
                  Writeln(Cikl,'. : ',FileName,pr_mess5);
                  {$ENDIF}
                  If Num = 2 Then
                    If Cikl > FirstNLQ Then
                      BlockRead(FontFile,PrintN2^[Cikl-FirstNLQ],33,xx)
                    Else
                      BlockRead(FontFile,PrintN1^[Cikl],33,xx)
                  Else
                    BlockRead(FontFile,PrintD^[Cikl],18,xx);
                  Close(Fontfile);
                End;
            End;

        KepFont := MaxTalal+1;
        If Boolean(PluszFont) Then
          If Num = 2 Then
            Begin
              If KepFont > FirstNLQ Then
                Begin
                  Fillchar(PrintN2^[KepFont-FirstNLQ],OneFontNLQ,00);
                  PkepOffs := Ofs(PrintN2^[KepFont-FirstNLQ]);
                  PkepSeg  := Seg(PrintN2^[KepFont-FirstNLQ]);
                End
              Else
                Begin
                  Fillchar(PrintN1^[KepFont],OneFontNLQ,00);
                  PkepOffs := Ofs(PrintN1^[KepFont]);
                  PkepSeg  := Seg(PrintN1^[KepFont]);
                End
            End
          Else
            Begin
              Fillchar(PrintD^[KepFont],OneFontDraft,00);
              PkepOffs := Ofs(PrintD^[KepFont]);
              PkepSeg  := Seg(PrintD^[KepFont]);
            End;
      End; { If Not ESC }

      Bool := Remove_Window;

      Pfontoff[0] := Ofs(PrintN1^);
      Pfontseg[0] := Seg(PrintN1^);

      Pfontoff[1] := Ofs(PrintN2^);
      Pfontseg[1] := Seg(PrintN2^);

     End

  Else
     Begin
       Error(4,pr_mess20);
       Load_Print := False;
     End;

End; {Load_Print}
{----------------------------------------}
Procedure Load_Download;

var
    FileName   : St16;
    xx         : integer;
    ffile      : File;
    b          : byte;

begin
   CheckRead(PathSt);
   If Not Esc Then
    Begin
       Filename := ppar.pr_egyeb;
       Assign(Ffile,PathSt+FileName);
       {$i-} Reset(Ffile,9); {$i+}               {egy kar = 9 byte}
       If IOresult <> 0 Then
         Begin
           Beepel(660);
           ppar.pr_download := false;
         End
       Else
         begin
            blockread(ffile,mkm,50,xx);
            close(ffile);
         end;
    End;
end;

Procedure LoadMatrixFont(Option: byte);

Begin
  Esc := false;
  If option > 0 Then Esc := Not(Load_Print(option))
  Else
     If ppar.pr_download and (ppar.pr_egyeb <> '')
     then Load_Download;
End;


Procedure PrIniRes(S: string);

var p,code,b : word;
      ws : string[3];

Begin
  Esc := False;
  P := 1;
  While NOT(S[P] in [' ',#0]) AND (P < length(S)) And not(ESC) Do
  Begin
    If S[P] = '\' Then
    Begin
      Inc(P);
      Ws := Copy(S,P,3);
      Val(Ws,B,Code);
      If Code = 0 Then
        Lprint(B)
      Else
        Begin
          P := length(S);
          Beepel(660);
        End;
      Inc(P,3);
    End
    Else
    Begin
      Lprint(Byte(S[P]));
      Inc(P);
    End;
  End;

End;
{-----------------------------------------------------------------------}

Procedure Atallit(Mire : Integer);
Var C : Char;
Begin
  BOOL := CREATE_WINDOW(10,11,45,18,pr_mess15,CA[DispMode,1],Ca[DispMode,4]);
  gotoxy(3,2);
  write(pr_mess17,PageLen:3,pr_mess18,Mire:3);
  gotoxy(2,3);
  write(pr_mess19);
  gotoxy(2,5);
  write(pr_mess16);

  Speak2(103,203);

  C := ' ';
  Repeat
    C := Upcase(ReadKey);
  Until C In [AktChar,MaxiChar,KilepChar,#27];
  Case C Of
    MaxiChar  : Begin
                  PageLen := Mire;
                  Fresh_Strings
                End;
    KilepChar : Esc := True;
          #27 : Esc := True
    End;
  MaxHeader := Mire - PageLen;
  If MaxHeader < 0 Then
    MaxHeader := 999;

  BOOL := Remove_Window
End;

Var
    KorLevelCikl: LongInt;
    Fil         : File;
    XXX         : Word;

{------------------------------- startnyom -------------------------}

    X,Level,Rel,          { Kiertekeles valtozoi }
    Oper,OLevel : Byte;
    ccc         : Char;
    Code        : Integer;
    TempRes,Vege,
    Uj,VoltPlusz,
    Res,Result  : Boolean;
    Results     : Array[1..8] Of Boolean;
    Operators   : Array[1..8] Of Byte;
    Ws,Ws2      : string[60];
    CimVege     : boolean;

Function Logop(Op: Byte; A,B : Boolean):Boolean;
Begin
  Case Op Of
    1: Logop := A AND B;
    2: Logop := A OR  B;
    3: Logop := A XOR B;
  End
End;

Function RelOp(Op:Byte; A,B : String):Boolean;
Var NotOp,Temp : Boolean;
    P          : Byte;
    X,Y,Y1,Y2  : LongInt;
Begin

  NotOp := False;

  If Op > 3 Then
  Begin
    Op := Op XOR 7;
    NotOp := True;
  End;

  Y1 := 0;
  Y2 := 0;

  Val(A,X,Code);

  If Code = 0 Then
  Begin
    P := Pos('..',B);
    If (Op = 3) AND (P > 0) Then
    Begin
      Val(Copy(B,1,P-1),Y1,Code);
      If Code = 0 Then
        Val(Copy(B,P+2,Length(B)-P-1),Y2,Code);
    End
    Else Val(B,Y,Code);

    If Code = 0 Then Numeric := True;

  End
  Else Numeric := False;


  If Numeric Then
  Begin
    If Code = 0 Then
    Begin
      Case Op Of
        0 : Temp := (X =  Y);
        1 : Temp := (X <  Y);
        2 : Temp := (X <= Y);
        3 : Temp := ((X >= Y1) AND (X <= Y2));
      End;
    End
    Else Numeric := False;
  End;

  If Not Numeric Then
  Begin

    If (Op = 0) AND (B[1]+B[Length(B)] = '**') Then
    Begin
      Delete(B,1,1);
      Dec(Byte(B[0]));
      Op := 10;
    End
    Else
    Begin
      P := Pos('*',B);

      If P > 1 Then
      Begin
        A[0] := Char(P-1);
        B[0] := Char(P-1);
      End;
    End;

    Case Op Of
      0 : Temp := (A =  B);
      1 : Temp := (A <  B);
      2 : Temp := (A <= B);
      3 : Begin
          P := Pos('..',B);
          If P > 1 Then
            Temp := ((A >= Copy(B,1,P-1)) AND (A <= Copy(B,P+2,Length(B)-P-1)));
          End;
      10: Temp := (Pos(B,A) > 0);
    End;

  End;

  If NotOp Then Temp := Not(Temp);

  RelOp := Temp;

End;  {Function RelOp}

var f : string;


{$IFDEF LICENC}

Function ChkSumOk:Boolean;

Var F : File Of Byte;
    W : Boolean;
    B : Byte;
    Cikl,Cikl2 : Integer;
    Csum : Word;

Procedure PlusChk(B : Byte);
Var W : Byte;
Begin
  Csum := Csum Xor B;
  W := Lo(Csum);
  Csum := Hi(Csum)+Integer(W)*$100+B;
End; { PlusChk }

Begin { ChkSumOk }
  W := True;
  For Cikl2 := 1 To 3 Do
    If W Then
      Begin
        Assign(F,FontPath+'\'+PicNames[Cikl2]);
        {$I-}
        Reset(F);
        {$I+}
        W := W And (IoResult = 0);
        If W Then
          Begin
            Csum := 0;
            For Cikl := 1 To FileSize(F) Do
              Begin
                Read(F,B);
                PlusChk(B);
              End;
            W := W And (Csum = Check[Cikl2]);
            Close(F)
          End;
      End;
  ChkSumOk := W;
  ChkSumOk := True;


End; { ChkSumOk }

{$ENDIF}

{$IFDEF HALO}
{$IFDEF NAGYSOLYMOSI}

Procedure DateTime;
var h, mi, s, hund : Word;
    y, mo, d, dow  : Word;
    S1,S2,S3       : String[12];

function St2(w : Word) : String;
var s : String;
begin
  Str(w:2,s);
  S[1] := Char(Byte(S[1]) OR $30);
  St2 := s;
end;

Begin
  GetTime(h,mi,s,hund);
  TimeSt := St2(h)+':'+St2(mi)+':'+St2(s);
  GetDate(y,mo,d,dow);
  Str(Y,S1);
  Str(Mo,S2);
  Str(D,S3);
  DateSt := S1+'.'+S2+'.'+S3;
End;

Procedure Semicolon;
Const Pv : Char = ';';
Begin
  BlockWrite(PrintF,Pv,1);
End;

Procedure CrLf;
Const Cr : String[2] = #13#10;
Begin
  BlockWrite(PrintF,Cr[1],2);
End;

{$ENDIF}
{$ENDIF}


Var VoltNyFont : Boolean;
NyomottOldalak : Integer;
Label nyom_vege;

Begin  { Startprint }
 If Condensed and (Ppar.Pr_Ovr = 3) and (Option = 2)
    then Option := 1;

 If Condensed AND ((Ppar.Pr_Ovr In [1,11]) or (Ppar.Pr_Ovr = 0))
    AND (Option In [1,2])
    Then
  {$IFDEF OROSZ}
    Begin
      BOOL := CREATE_WINDOW(10,11,45,18,'�訡�筠� ���������!',CA[DispMode,1],Ca[DispMode,4]);
      gotoxy(3,2);
      write('   ���㠫�� ��� ���� ��  ');
      gotoxy(2,3);
      write('  ࠧ�蠥� ���⮥ ���⠭�� !');
      gotoxy(2,5);
      write('  <�>��. <�>���� F1 <�>४�.');

      C := ' ';
      Repeat
        C := Upcase(ReadKey);
      Until C In ['F','Y','G',#27];
      Case C Of
        'F'       : Begin

                     End;
        'Y'       : Option := 0;
        'G',#27   : Esc := true;
        End;

      BOOL := Remove_Window;
      If Esc then goto nyom_vege;
    End;

  {$ELSE}

    Begin


      BOOL := CREATE_WINDOW(10,11,45,18,Pr_Mess22,CA[DispMode,1],Ca[DispMode,4]);
      gotoxy(3,2);
      write(Pr_Mess23);
      gotoxy(2,3);
      write(Pr_Mess24);
      gotoxy(2,5);
      write(Pr_Mess25);

      Speak2(115,215);

      C := ' ';
      Repeat
        C := Upcase(ReadKey);
      Until C In [AktChar,GyorsChar,KilepChar,Char(Escape)];

      Case C Of
        'M'       : Begin

                    End;
        GyorsChar : Option := 0;
        KilepChar,Char(Escape)   : Esc := true;
        End;

      BOOL := Remove_Window;
      If Esc then goto nyom_vege;
    End;

  {$ENDIF}

 {$IFDEF BEMUTAT}
 If Not ErvenyesIdoszak Then
   Exit;
 {$ENDIF}

 SokSor := (EndLine[GEditNum] - StartLine[GEditNum]) +
           (EndLine[27] - StartLine[4]) + Full_Lines div 3;

 If (SokSor > TulSok)
  {$IFDEF LICENC}
  Or True
  {$ENDIF}
 then
   Begin
     BOOL := CREATE_WINDOW(46,5,70,9,pr_mess21,CA[DispMode,1],CA[DispMode,2]);
     GotoXY(4,2);
     Write(EleSt5);
   End;

 {$IFDEF LICENC}
  If Not(ChkSumOk) Then
   Begin
     Bool := Remove_Window;
     Exit;
   End;

  FelulIrta := False;
  SzoltMar  := False;
{$ENDIF}
        
 NYModus := Option;

      {$IFDEF INFOHIV}
      Register.Ds := Seg(FileName[GEditNum]);
      Register.Dx := Ofs(FileName[GEditNum]);
      Register.Cx := NyomSzam;
      Register.Ax := $ECEC;
      Intr($5,Register);
      {$ENDIF}

 VoltNyFont := False;
 If (Option In [1,2]) And (ppar.pr_ovr In [0,3,4,6,7,9,10]) Then
   If (VanNyelvEsz Or DoglottNyelvesz) And VanFontSwap Then
     Begin
       NyomtatHely;
       SwapError2 := False;
       If SwapError2 Then
	 Error(26,'TEMPX.$$2');
       VoltNyFont := True;
     End
   Else
     OptimalHeap;                        {csak 8,24,30 tus matrix normal/szep}

 {$IFDEF BEMUTAT}
 If Not ErvenyesIdoszak Then
   Exit;
 {$ENDIF}



 If ((Option <> 3) Or (volt_SPS = True)) And (Not SwapError) Then
 Begin
  For Cikl := 0 To MaxFontNum Do
    Van_Font[Cikl] := False;
  If StartLine[GEditNum] <= EndLine[GEditNum] Then
  Begin
    Fontok(Seg(PointerTomb^),
           0,                       { A nyomtatando editor atnezese   }
            Ofs(Van_Font),
             Ofs(PointerTomb^),
              StartLine[GeditNum],
               EndLine[GeditNum],
                HeapRec.Segment,
                 0,
                  0);

    If StartLine[4] <= EndLine[27] Then
      Fontok(Seg(PointerTomb^),
             0,                     { A headerek es footerek atnezese }
              Ofs(Van_Font),
               Ofs(PointerTomb^),
                StartLine[4],
                 EndLine[27],
                  HeapRec.Segment,
                   0,
                    0);

    If Van_Font[0] Then Van_Font[1] := True;

    Fs := '.PIC=';             { Kepfilenev kereses }
    Sorszam := 0;
     Sorszam := Search(Seg(PointerTomb^),
                       0,
                        Ofs(Fs),
                         Ofs(PointerTomb^),
                          StartLine[GEditNum],
                           EndLine[GEditNum],
                            HeapRec.Segment,
                             0,
                              0);
    PluszFont := Byte(Sorszam <> 0);

    If (Not Boolean(PluszFont)) And (StartLine[4] <= EndLine[27]) Then
      Begin
        Sorszam   := 0;
        Sorszam   := Search(Seg(PointerTomb^),
                       0,
                        Ofs(Fs),
                         Ofs(PointerTomb^),
                          StartLine[4],
                           EndLine[27],
                            HeapRec.Segment,
                             0,
                              0);
        PluszFont := Byte(Sorszam <> 0);
      End;

    {$IFDEF LICENC}
    PluszFont := 1;
    {$ENDIF}

    KepFont := 12;

    EditNum     := GEditnum;
   { HeaderCount := 0; }
   { InitVan;  }
    Esc := False;


    {$IFNDEF LICENC}
    If SokSor > TulSok then
    {$ENDIF}
      bool := Remove_Window;

    OldMaxFel   := Ppar.Pr_MaxFelsor;
    OldFormatum := Formatum;

    If (Ppar.Pr_ovr In [1,11]) or ((Ppar.Pr_ovr = 7) And NOT(Option In [1,2])) Then
      If Not(Formatum) Then    { Fekvo  }
        If Condensed Then      { Suru   }
          Ppar.Pr_MaxFelsor := 188
        Else                   { Normal }
          Ppar.Pr_MaxFelsor := 118
      Else                     { Allo   }
        If Condensed Then      { Suru   }
          Ppar.Pr_MaxFelsor := 272;

    case option of

         0..2,4,5,7:If PageLen > Ppar.Pr_MaxFelsor Then
                     Atallit(Ppar.Pr_MaxFelsor)
                    Else
                     MaxHeader := Ppar.Pr_MaxFelsor-PageLen;
         3:
                  if PageLen > Spar.S_MaxFelsor then
		    Atallit(Spar.S_MaxFelsor)
		    Else
                      MaxHeader := Spar.S_MaxFelsor-PageLen

         end;           {case}


    If Option <> 4 Then
    Begin
      {$I-}
      assign(NyomtatoFile,'LPT'+chr(49+paralell_device));  {HALOZATHOZ}
      rewrite(NyomtatoFile);
      {$I+}

      If (option in [0..2,4,5]) or ((option = 3) and (spar.s_bill_on = 'centr')) then
        Begin
          Centronics := True;
          ptimeout[paralell_device] := 1;
          Lprint(0);                           { indulo CHECK csak CENTRONICS }
          If not ESC then
            Begin
              Lprint(0);
              ptimeout[paralell_device] := iroido * 2;
            End;
        End;

      If ESC then goto NYOM_VEGE;
      {inicializalo stringet file-bol kikuld, ha van}

      if option = 3 then
        Assign(FByte,PathSt+'PrIni2.DAT')
      else
        Assign(FByte,PathSt+'PrIni'+chr(ppar.pr_ovr+48)+'.DAT');

      {$I-}
      Reset(FByte);
      {$I+}

      if ioresult = 0 then
       begin
         readln(Fbyte,S);
         PrIniRes(S);
         close(Fbyte);
       end;
    End { ha nem preview }
  {$IFNDEF VER352}
  Else
    Begin
      KepFont := 16;
      PrevInit;
    End
  {$ENDIF}
    ;

    If (NOT ESC) and (Option in [0..2]) Then
      Case Ppar.Pr_Ovr of
         0:   LoadMatrixFont(option);       {8- tus}
         3:   LQLoadFont(option);           {24 -tus}
         4:   Begin                         {8- tus, de Option 2 = 30 * 24}
                if Option in [0..1] then
                  LoadMatrixFont(option)    {gyors/normal = sima}
                else LQLoadFont(3)          {szep = LQ toltes}
              End;
         6:   if Option in [1..2] then
                LQLoadFont(option);        {BubbleJet mint 24 -tus}
         7:   KepFont := 16;
     9,10 :   If Option In [1,2] Then
                LQLoadFont(option);        { 852 grafikus }
      End;

    Korlevelben  := false;   {kell printer ini}

    KorlevelCikl := 0;
    CLV^.CountRec     := 0;
    If Not ESC and (Cimfile<>'') and (not AkosMarKikuldte) then {font kikuldes}
      For X := 1 To MaxFontNum Do
       begin
         ChFont[X]   := True;
         Van_Font[X] := true;
         AkosMarKikuldte := true;
       end;

    If not ESC then               {!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
    With CLV^ Do
    Repeat
       CimVege  := false;
       {$I-}
       If CimFile <> '' Then
       Begin
         Assign(Fil,Cimfile);
         Reset(Fil,1);

         If Ioresult = 0 then
          Begin


            Seek(Fil,(KorLevelCikl * CimRecLen)
                      + CimFejlecLen + Byte(ADB40)*CimRecLen);
            Repeat
              BlockRead(Fil, CimRecBuff^, CimRecLen, XXX);
              ESC := (CimRecLen <> XXX);

              Inc(KorLevelCikl);

              If (Not Esc) AND (RecDate^.Ev > 0) Then Inc(CountRec);

              If Condi <> '' Then
              Begin

                { BOOL := CREATE_WINDOW(15,3,69,21,'',CA[DispMode,3],CA[DispMode,1]); }
                X := 0;

                Uj := True;
                VoltPlusz := False;
                OLevel := 99;

                Repeat

                  Inc(X);
                  Ws := GetVar(CondiResult[x]);
                   UpperCase(Ws);
                  { Write('    VarSt[',CondiResult[X],'] = "',Ws,'"'); }
                  Inc(X);
                  Ws2 := Variables[CondiResult[x]];
                  { Writeln(' Variables[',CondiResult[X],'] = "',Ws2,'"'); }
                  Inc(X);

                  Rel  := (CondiResult[X] SHR 2) AND 7;
                  Level:= CondiResult[X] SHR 5;

                  If Uj Then
                  Begin
                    Res := RelOp(Rel,Ws,Ws2);
                  End
                  Else
                  Begin
                    TempRes := RelOp(Rel,Ws,Ws2);
                    If Oper > 0 Then Res := LogOp(Oper,Res,TempRes)
                                Else Res := TempRes;
                  End;

                  Uj := False;

                  Oper := CondiResult[X] AND 3;

                  { Writeln('  Level = ',Level,
                            '  Rel�ci�: ',Rel,
                            '  Oper.: ',Oper); }

                 { Ha az 1. szinten az elozo feltetel TRUE volt, es
                   az operator "OR", illetve ha az elozo feltetel FALSE
                   volt, es az operator "AND" akkor vege; az eredmeny = az
                   elozo feltetel eredmenye (TRUE vagy FALSE).

                   (Boolean evaluation = Short Circuit) }

                 If (Level = 1) And
                     ((Oper = 1) Or (Oper = 2)) And
                     (((Oper+Byte(Res)) And 1) = 1 ) Then
                    { OR (2)+True (1) = 3   3 And 1 = 1
                      AND(1)+False(0) = 1   1 And 1 = 1 }
                 Begin
                   Vege := True;
                   Results[1] := Res;
                 End
                 Else
                 Begin
                   Vege := False;

                   If Oper <> 0 Then Operators[Level] := Oper
                   Else
                   Begin     { Plusz byte }
                     Inc(X);
                     Level := CondiResult[X] SHR 4;
                     Oper  := CondiResult[X] AND 3;

                     If (Level = 0) And (Oper = 0) Then
                     Begin
                       Vege := True;
                       Level := 1;
                       If VoltPlusz Then
                         Res:= LogOp(Operators[1],Results[1],Res);
                     End
                     Else
                     Begin
                       VoltPlusz := True;
                       Uj := True;
                       If Olevel <> 99 Then
                         Res := LogOp(Operators[Olevel],Results[Olevel],Res);
                     End;

                     Olevel := Level;

                     Results[Level]   := Res;
                     If Oper <> 0 Then Operators[Level] := Oper;

                     { Writeln('��� Level = ',Level,'  Op.: ',Oper,'  ���'); }
                   End;

                   { Writeln; }

                 End; { Ha nem kellett rovidre zarni a feltetelt }

                Until Vege;

                Result := Results[Level];

                { ccc := Readkey;
                  Bool := Remove_Window; }

              End { If Condi <> '' }
              Else Result := True;

            Until Esc    Or                       { Hibas rekord }
                  (KorLevelCikl >= MaxCimRec)  Or { Utolso Rekord }
                  ((Result) And                   { Feltetel teljesult }
                  (RecDate^.Ev > 0));              { Aktiv ? }

            If ESC Then Error(6,'')
                   Else If Condi <> '' Then ESC := Not(Result)
                                       Else ESC := (KorLevelCikl > MaxCimRec);

            Close(Fil);
          End
         Else
         Begin
           Error(6,'');
           Esc := True;
         End;

         {$I+}

      End;

             {ha LASER, akkor annak csak egyszer kuldeni ki !!!}

       if (ppar.pr_ovr In [1,11]) Or (Option=4) then
         begin
           LASER_nyomszam := NyomSzam;
           NyomSzam := 1;
         end;


       {$IFDEF DEMO}
       demo_nyom_sorok := 0;
       {$ENDIF}

       Cikl := 1;

       If NOT ESC Then
         Repeat
           KepNyomas  := False;
           VoltKepNev := False;
           HanyOldalonKeresztul := MaxInt;


           EditNum     := GEditnum;
           HeaderCount := 0;
           InitVan;

           Pc := 0;
           KovFalse  := False;
           VegeLesz  := False;
           KellMeg   := 0;
           LinecPr   := 0;


           PageCount := 0;
           PageC2 := 0;

           {$IFDEF LICENC}
           LicencElsoLesz := False;
           FirstLineVan   := False;
           LicencKep      := False;
           Emblema := False;
           {$ENDIF}

           SaveMain;
           NewPage;

           Pc := 1;

           If FirstPage > 20 Then
             Begin
               BOOL := CREATE_WINDOW(46,5,70,9,Pr_mess7,CA[DispMode,1],CA[DispMode,2]);
               GotoXY(4,2);
               Write(EnterPage,Pc:4);
             End;


           TrueNyomas := False;
           If LastPage >= FirstPage Then
             While Pc < FirstPage Do
               If Not(Van_Sor) Then
                 Pc := MaxInt
               Else
                 If LapVegeI(LastLine) Then
                   Begin
                     Inc(Pc);
                     If FirstPage > 20 Then
                       Begin
                         GotoXY(4,2);
                         Write(EnterPage,Pc:4);
                       End
                   End;

           If FirstPage > 20 Then
             BOOL := Remove_WINDOW;

           {$IFDEF BEMUTAT}
           If Not ErvenyesIdoszak Then
             Exit;
           {$ENDIF}


           TrueNyomas := True;
           Centronics := True;

           PageC2 := FirstPageNum - (FirstPage-PageCount);

           If Pc <> MaxInt Then
             Case Option Of
               3 : Robotron;
               {$IFNDEF VER352}
               4 : Previe
               {$ENDIF}
               Else
                 Case Ppar.Pr_Ovr Of
                   0 : Matrix(Option,mkm);
                   1 : LaserNyom(Option);
                   3 : Lq24tu(Option,KarTomb,FontKezdet);
                   4 : Begin
                        If Option in [0..1] then Matrix(Option, mkm)
                        else LQ30tu(KarTomb,Fontkezdet);              {ez az uj}
                       End;
                   5:  RepuloEkezet;
                   6:  Case Option of
                         0  : BubbleJet;
                         1,2: Lq24tu(Option,KarTomb,FontKezdet);
                        End;
                   7:  Case Option Of
                         0 : DeskJetNyom;
                       1,2 : DeskJetNyomLFT;
                       End;
                   9:  IBM24tu852(Option,KarTomb,FontKezdet);
                  10:  LQ24tu852(Option,KarTomb,FontKezdet);
                  11:  Laser852(Option);
                 End;   { Case Ppar.Pr_Ovr }
             End; { Case Option }
           Korlevelben := true; {nem kell ujra printer ini}
           Inc(Cikl);
           Formatum := OldFormatum;
         Until Esc Or (Cikl > NyomSzam);           { Ha folytatja }

       If CimFile = '' Then CimVege := True;

    Until Esc Or CimVege Or (KorlevelCikl >= (MaxCimRec));

    if (ppar.pr_ovr In [1,11]) Or (Option=4) then
      begin
        NyomSzam := LASER_nyomszam; {mert 1-re allitotta}
        LaserY   := 0;
        if (LabelDist >= 0.01) and
           (not KellLapdob) and
           (not Dobott) And
           (Not ESC) then
          If Option <> 4 Then
            lprint(12)     {kidobni a papirt, ha cimkenyomas volt!!}
          Else
            Begin
              Beepel(440);
              Beepel(880)
            End;
      end;

    Ppar.Pr_MaxFelsor := OldMaxFel;
    Formatum          := OldFormatum;

    {$IFDEF INFOHIV}
      Register.Ds := Seg(FileName[GEditNum]);
      Register.Dx := Ofs(FileName[GEditNum]);
      Register.Cx := NyomSzam;
      Register.Ax := $FEFE;
      Intr($5,Register);
    {$ENDIF}

  End { Ha van az editorban }
Else
  Begin
   If (SokSor > TulSok) {$IFDEF LICENC} Or True {$ENDIF} then
     BOOL := Remove_WINDOW;
  End;

  If Option <> 4 Then
    Begin
      IF NOT ESC then       {nyomtato reseteles }
        begin
          if option = 3 then
            Assign(FByte,PathSt+'PrRes2.DAT')
          else
            Assign(FByte,PathSt+'PrRes'+chr(ppar.pr_ovr+48)+'.DAT');

          {$I-}
          Reset(FByte);
          {$I+}
          if ioresult = 0 then
           begin
             readln(Fbyte,S);
             PrIniRes(S);
             close(Fbyte);
           end;
        End; { If not ESC }


      {$I-}
      close(NyomtatoFile);     { HALOZATHOZ }
      {$I+}
      if ioresult  <> 0 then;
      LaserY := 0;

    End; { Ha nem preview }

 End;


 If VoltNyFont Then
   NyomtatVissza
 Else
   OptimalHeapRestore;

 nyom_vege:

 {$IFDEF HALO}
 {$IFDEF NAGYSOLYMOSI}
 Assign(PrintF,FontPath+'\HPRINT\HPRINT.TXT');

 BOOL := CREATE_WINDOW(23,14,58,17,'HPRINT.TXT',CA[DispMode,1],CA[DispMode,2]);

 Write(' K�rem v�rjon. ESC: kil�p');
 Ch := 00;

 FileMode := 1;

 Repeat
   {$I-}
   Reset(PrintF,1);
   {$I+}
   X := IoResult;
   If KeyPressed Then Ch := Byte(Readkey);
   {GotoXY(1,1); Write('�',X:3,'�');}
 Until (X <> 163) OR (Ch = 27); {File sharing violation}

 If X = 0 Then
 Begin
   DateTime;

   Seek(PrintF,FileSize(PrintF));
   BlockWrite(PrintF,UserName[1],Length(UserName));
   SemiColon;
   BlockWrite(PrintF,Path[1],Length(Path));
   SemiColon;
   BlockWrite(PrintF,FileName[GEditNum][1],Length(FileName[GEditNum]));
   SemiColon;
   BlockWrite(PrintF,DateSt[1],Length(DateSt));
   SemiColon;
   BlockWrite(PrintF,TimeSt[1],Length(TimeSt));
   SemiColon;
   NyomottOldalak := PageCount-FirstPage;
   If NyomottOldalak < 0 Then NyomottOldalak := 0;
   Str(NyomottOldalak,Wst);
   BlockWrite(PrintF,WSt[1],Length(WSt));
   SemiColon;
   Str(NyomSzam,Wst);
   BlockWrite(PrintF,WSt[1],Length(WSt));
   SemiColon;

   CrLf;

   Close(PrintF);
 End;

 FileMode := 2;
 BOOL := Remove_Window;

 If Ppar.Pr_Ovr <> 2 Then
 Begin
   If Int17(#27) Then
     Case ppar.pr_ovr of
        0: Bool := Int17('@');
        1: Bool := Int17('E');
        3: Bool := Int17('@');
        4: Bool := Int17('@');
        5: Bool := Int17('@');
        6: Bool := Int17('@');
        7: Bool := Int17('E');
     end;  {case}
 End;

 {$ENDIF}
 {$ENDIF}

End;

End.