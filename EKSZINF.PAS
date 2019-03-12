Unit EKSZINF;

Interface
Uses crt,Windowm;

Procedure UjFileNev(UjName     : String);
Procedure Nev_Bejelol(Var Nevek:NevTomb;
                      Var Rp   :IindexT;
                          Db   :Word);
Procedure AdatKiir(P:Integer);
Procedure InfAblakKirak;


Implementation
Uses Inputcdw,Dos,Video;


Var
  SS1,SS2  : String;
  IndexFile : File Of Integer;
  ItemFile  : File Of IItemRec;

Const
  IndexName = 'EKSZINF.DT1';
  ItemName  = 'EKSZINF.DT2';

Function NoVegSpace(S:String):String;
Begin
  While (Length(S) <> 0) And
        (S[Length(S)] = ' ') Do
    S[0] := Char(Byte(s[0])-1);
  NoVegSpace := S
End;



Procedure UjFileNev(UjName     : String);

Var IO1 : Boolean;
    RecP,
    Cikl,
    ItemNum,
    IndexP : Integer;
    NemUj  : Boolean;
    RecRec,Uj : IItemRec;
    Names     : INamesT;
    Index     : IIndexT;
    Hour,Min,Sec,Sec100 : Word;
    Year, Month, Day, DayOfWeek: Word;
    Dt        : DateTime;

Procedure EnterInfName;
Begin
  BOOL:= CREATE_WINDOW(12,7,78,12,' File informaciok :'+UjName,
                        CA[DispMode,1],CA[DispMode,3]);

  MaxStringLen := 63;
  GotoX(2,2);

  input_string( 'Tartalom  :',Uj.Itext,40);

  MaxStringLen := 4;
  GotoX(2,3);

  Input_Integer('Azonos¡t¢ :',Uj.Inum,4);

  Bool := Remove_Window;
End;

Procedure EnterGrName;
Var ScBuf : Array[0..6000] Of Byte;
Begin
  FelSor_IdeOdaW(0,80,8,20,Ofs(ScBuf),Seg(ScBuf),SortabOffs,0);
  Ablak(0,20,2,Fontoffs,SortabOffs,78);

  MaxStringLen := 63;
  GotoX(2,20);

  input_string( 'Tartalom  :',Uj.Itext,40);


  MaxStringLen := 4;

  GotoX(2,22);

  Input_Integer('Azonos¡t¢ :',Uj.Inum,4);

  FelSor_IdeOdaW(0,80,8,20,Ofs(ScBuf),Seg(ScBuf),SortabOffs,1)
End;


Begin
  UpperCase(UjName);
  UjName := NoVegSpace(UjName);

  Uj.Itext := '';
  Uj.Inum  := 0;

  With Uj Do
    Begin
      GetTime(Hour,Min,Sec,Sec100);
      GetDate(Year, Month, Day, DayOfWeek);

      Dt.Year  := Year;
      Dt.Month := Month;
      Dt.Day   := Day;
      Dt.Hour  := Hour;
      Dt.Min   := Min;
      Dt.Sec   := Sec;

      {Isize    := SorokSzama;}

      PackTime(dt,IdateTime);

      Verzio    := ActVerz;
      Iname     := UjName;
      Isize     := 1122;
    End;


  Assign(IndexFile,IndexName);
  Assign(ItemFile,ItemName);
  {$I-}
  Reset(IndexFile);
  IO1 := IoResult <> 0;
  Reset(ItemFile);
  {$I+}

  If (IORESULT <> 0) Or IO1 Then
    Begin
      ReWrite(IndexFile);
      ReWrite(ItemFile);

      If Graphic Then
        EnterGrName
      Else
        EnterInfname;

      RecP := 0;
      Write(IndexFile,Recp);
      Write(ItemFile,Uj);
    End
  Else
    Begin
      NemUj := False;
      ItemNum := FileSize(IndexFile);
      For Cikl := 0 To ItemNum-1 Do
        Begin
          Read(IndexFile,Index[Cikl]);
          Read(ItemFile,RecRec);
          Names[Cikl] := RecRec.IName;
          If Names[Cikl] = Uj.Iname Then
            Begin
              NemUj := True;
              RecP  := Cikl;
            End;
        End;
      If NemUj Then
        Begin
          Seek(ItemFile,RecP);
          Read(ItemFile,Uj);
          Seek(ItemFile,RecP);
        End;

      If Graphic Then
        EnterGrName
      Else
        EnterInfName;

      If Not Nemuj Then
        Begin
          RecP := ItemNum;

          Cikl := 0;
          While (Cikl < ItemNum) And
                (Names[Index[Cikl]] < Uj.Iname) Do
            Inc(Cikl);
          IndexP := Cikl;
          Move(Index[IndexP],Index[IndexP+1],(ItemNum-IndexP)*2);
          Index[IndexP] := RecP;
          Seek(IndexFile,IndexP);

          Inc(ItemNum);

          For Cikl := IndexP To ItemNum-1 Do
            Write(IndexFile,Index[Cikl]);
        End;
      Write(ItemFile,Uj);
    End;
  Close(IndexFile);
  Close(ItemFile);
End;

Procedure FileNevTorol;
Begin
End;


Procedure Kiir;

Var Cikl      : Integer;
    RecRec    : IItemRec;
    ItemNum   : Integer;

    Names     : Array[0..MaxItem-1] Of String[12];
    Index     : Array[0..MaxItem-1] Of Integer;

Begin
  Assign(IndexFile,IndexName);
  Assign(ItemFile,ItemName);
  Reset(IndexFile);
  Reset(ItemFile);

  ItemNum := FileSize(IndexFile);
  For Cikl := 0 To ItemNum-1 Do
    Begin
      Read(IndexFile,Index[Cikl]);
      Read(ItemFile,RecRec);
      Names[Cikl] := RecRec.IName;
    End;

  For Cikl := 0 To ItemNum-1 Do
    Writeln(Names[Index[Cikl]]);

End;

Procedure Nev_Bejelol(Var Nevek:NevTomb;
                      Var Rp   :IindexT;
                          Db   :Word);

Var Cikl      : Integer;
    Names     : Array[0..MaxItem-1] Of String[12];
    Index     : Array[0..MaxItem-1] Of Integer;
    ItemNum   : Integer;
    RecRec    : IItemRec;
    Imut      : Integer;
    Io1       : Boolean;
    Nam       : String[20];

Begin

  Assign(IndexFile,IndexName);
  Assign(ItemFile,ItemName);

  {$I-}
  Reset(IndexFile);
  Io1 := (IoResult = 0);
  Reset(ItemFile);
  {$I+}

  For Cikl := 0 To MaxItem-1 Do
    Rp[Cikl] := Maxint;

  If (IoResult = 0) And
     Io1 And
     (FileSize(IndexFile) = FileSize(ItemFile)) Then
    Begin
      ItemNum := FileSize(IndexFile);


      For Cikl := 0 To ItemNum-1 Do
        Begin
          Read(IndexFile,Index[Cikl]);
          Read(ItemFile,RecRec);
          Names[Cikl] := RecRec.IName;
        End;

      Close(IndexFile);
      Close(ItemFile);

      Imut := 0;

      For Cikl := 1 To Db Do
        Begin
          Nam := NoVegSpace(Nevek[Cikl]);
          While (Imut <> (ItemNum-1)) And
                (Nam > Names[Index[Imut]]) Do
            Begin
              Inc(Imut);
            End;
          If Nam = Names[Index[Imut]] Then
            Rp[Cikl] := Index[Imut];
        End;
    End;

End;

Procedure InfAblakKirak;
Begin
  BOOL:= CREATE_WINDOW(1,20,80,25,' File inform ci¢k ',
                       CA[DispMode,1],CA[DispMode,3]);
  Display(' F2 : £j inform ci¢k ',25,30);
End;


Procedure AdatKiir(P:Integer);
Var RecRec : IItemRec;
    Hour,Min,Sec,Sec100 : Word;
    Year, Month, Day, DayOfWeek: Word;
    Ho     : String[24];
    Dt        : DateTime;
    Txt1,Txt2,Txt4,
    Txt5,Txt6,
    Txt7,TXt8      : String[6];
    Stt : String[80];

Begin
  FillChar(Stt,80,' ');
  Stt[0] := Char(63);
  Display('D tum    :   '+Stt,21,4);
  Display('Tartalom :   '+Stt,22,4);
  Display('Azonos¡t¢:   '+Stt,23,4);
  If P <> MaxInt Then
    Begin
      Assign(ItemFile,ItemName);
      Reset(ItemFile);

      Seek(ItemFile,P);
      Read(ItemFile,RecRec);

      Close(ItemFile);

      Str(RecRec.Inum:4,Txt1);
      UnPackTime(RecRec.IdateTime,Dt);

      Str(Dt.Year:4,Txt2);
      Ho := Honapok[Dt.Month];
      EkSzer_To_ASCII(Ho);
      Str(Dt.Day:2,Txt4);

      Str(Dt.Hour:2,Txt8);
      Str(Dt.Min:2,Txt5);
      Str(Dt.Sec:2,Txt6);

      Str(RecRec.Isize:5,Txt7);

      Display('D tum    :   '+Txt2+'.'+Ho+' '+Txt4+'.    '+Txt8+':'+
                           Txt5+':'+Txt6,21,4);
      Display('Tartalom :   '+RecRec.Itext,22,4);
      Display('Azonos¡t¢:   '+Txt1,23,4);
    End;
End;




{

Var Rec  : IItemRec;
    Cikl : Integer;
Begin

  Rec.Iname := 'ALAP.PAR';
  UjFileNev(Rec);

  Rec.Iname := 'BABA.PAR';
  UjFileNev(Rec);

  Rec.Iname := 'AAPS.PAR';
  UjFileNev(Rec);

  Rec.Iname := 'ABBA.PAR';
  UjFileNev(Rec);

  Rec.Iname := 'KUKAC.PAR';
  UjFileNev(Rec);

  Rec.Iname := 'DEDE.PAR';
  UjFileNev(Rec);

  Rec.Iname := 'CICAFEJ.PAR';
  UjFileNev(Rec);


  Kiir;

}

End.