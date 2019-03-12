Unit Bemutat;

Interface
Procedure DatumCheck;
Procedure FileDatumCheck;

Implementation
Uses Dos,Windowm;

Const  {  Ettol eddig megy az EkSzer }
       SYear  = 93;
       SMonth = 04;
       SDay   = 28;

       EYear  = 93;
       EMonth = 07;
       EDay   = 31;

Function PackDate(Ev,Honap,Nap:Byte):Word;
Begin
  PackDate := Word(Ev)*31*12+Word(Honap-1)*31+(Nap-1)
End;

Procedure UnPackDate(PD:Word;Var Ev,Honap,Nap : Word);
Begin
  Ev := PD Div (31*12);
  Dec(PD,Ev*31*12);
  Honap := PD Div 31;
  Nap := PD-(Honap*31);
  Inc(Honap);
  Inc(Nap)
End;

Const MaxDirs = 100;

Function TimeOfDir(DirName:String):Longint;

Var
  Work,Work1  : Longint;
  Rec   : SearchRec;
  Names : Array[1..MaxDirs] Of String[12];
  Dirs,
  Cikl  : Integer;
  td    : DateTime;
Begin
  Work := 0;
  Dirs := 0;
  FindFirst(DirName+'\*.*',AnyFile,Rec);
  While DosError = 0 Do
    Begin
      If (Rec.Attr And Directory) = 0 Then
        Begin
          UnPackTime(Rec.Time,Td);
          If (Rec.Time > Work) And
             (Td.Year < 1995) Then
            Work := Rec.Time
        End
      Else
        If (Dirs < MaxDirs)   And
           (Rec.Name <> '.')  And
           (Rec.Name <> '..') Then
        Begin
          Inc(Dirs);
          Names[Dirs] := Rec.Name
        End;
      FindNext(Rec);
    End;
  For Cikl := 1 To Dirs Do
    Begin
      Work1 := TimeOfDir(DirName+'\'+Names[Cikl]);
      If Work1 > Work Then
        Work := Work1;  { rekurzio }
    End;
  TimeOfDir := Work;
End;

Function AGepXT:Boolean;
Var Temp : Boolean;
Begin
  Temp := True;
  Asm
    MOV  AX,SP
    DB   $60    { PUSHA }
    CMP  AX,SP
    JZ   @1
    DB   $61    { POPA  }
    MOV  [Temp],0
@1:
  End;
  AGepXT := Temp;
End;

Function ReadCmosDate:Word;
Var Nap,Honap,Ev : Byte;
Label MostMegSzabad,MostNemSzabad,
      N1,N2,N3,N4,N5;
Begin
    Asm
    CLI
(*
MostMegSzabad:
    MOV  AL,0AH
    OUT  70H,AL
    Jmp  N1
N1: IN   AL,71H
    Test AL,80H
    Jz   MostMegSzabad

MostNemSzabad:
    MOV  AL,0AH
    OUT  70H,AL
    Jmp  N2
N2: IN   AL,71H
    Test AL,80H
    Jnz  MostNemSzabad
*)

    MOV  AL,07H
    OUT  70H,AL
    JMP  N3
N3: IN   AL,71H
    MOV  [Nap],AL
    MOV  AL,08H
    OUT  70H,AL
    JMP  N4
N4: IN   AL,71H
    MOV  [Honap],AL
    MOV  AL,09H
    OUT  70H,AL
    JMP  N5
N5: IN   AL,71H
    MOV  [Ev],AL

    STI
  End;

  Nap   := (Nap   Shr 4)*10+(Nap   And 15);
  Honap := (Honap Shr 4)*10+(Honap And 15);
  Ev    := (Ev    Shr 4)*10+(Ev    And 15);

  ReadCmosDate := PackDate(Ev,Honap,Nap);
End;

Function ReadDosDate:Word;
Var Nap,Honap,Ev,DOW : Word;
Begin
  GetDate(Ev,Honap,Nap,DOW);
  ReadDosDate := PackDate(Ev-1900,Honap,Nap);
End;

Function ReadDate:Word;
Begin
  If AGepXt Then
    ReadDate := ReadDosDate
  Else
    ReadDate := ReadCmosDate;
End;


Procedure DatumCheck;
Var W : Word;
Begin
  W := ReadDate;

  ErvenyesIdoszak2 :=
    (W >= PackDate(SYear,SMonth,SDay)) And        { Ettol         }
    (W <= PackDate(EYear,EMonth,EDay));           { Eddig ervenyes az EkSzer }

End;

Procedure FileDatumCheck;
Var L : Longint;
    D : DateTime;
    W : Word;
    W2: Word;
    F : File;
Begin
  W := ReadDate;
  Assign(F,'C:\AUTOEXEC.BAT');

  GetFTime(F,L);
  UnPackTime(L,D);
  W2 := PackDate(D.Year-1900,D.Month,D.Day);

  If W2 < W Then
    Begin
      UnPackDate(W,D.Year,D.Month,D.Day);
      Inc(D.Year,1900);
      PackTime(D,L);
      {$I-}
      Reset(F);
      {$I+}
      If IoResult = 0 Then
        Begin
          SetFTime(F,L);
          {$I-}
          Close(F);
          {$I+}
          If IoResult = 0 Then;
        End;
    End;

  L := TimeOfDir('C:');
  UnPackTime(L,D);
  ErvenyesIdoszak3 :=
    PackDate(D.Year-1900,D.Month,D.Day) <= PackDate(EYear,EMonth,EDay);
End;

End.