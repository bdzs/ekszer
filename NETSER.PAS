Unit NetSer;
{$M 1024,0,0}
Interface

Uses DOS,WindowM;

Function GetNetSerNo : LongInt;
Function VanIlyen(EzAz:LongInt):Boolean;
Var      NetSerNo : LongInt;

Implementation

Const MsgBufferSize = 500;

Type  BufType =    Array[0..MsgBufferSize+2] Of Byte;

Var GlobalError,
    ModeB        : Byte;
    Cik          : Word;
    Ok           : Boolean;
    ReqBuf       : BufType; ReqBuf0  : Word Absolute ReqBuf;
    RepBuf       : BufType; RepBuf0  : Word Absolute RepBuf;

Function VanIlyen;
Var Cikl : Integer;
Begin
  VanIlyen := False;
  For Cikl := 1 To HalozatSzam Do
    If EzAz = HalozatSzamok[Cikl] Then
      VanIlyen := True
End;


Procedure GetSerialNum;
Var Cik : Byte;
Begin
  ModeB := $12;
  ReqBuf[2] := ModeB;

  Reqbuf0 := 3;
  Repbuf0 := MsgBufferSize+2;

  Asm
    PUSH  DS
    PUSH  ES
    PUSH  DI
    PUSH  SI

    MOV   SI,Offset ReqBuf
    MOV   DI,Offset RepBuf
    PUSH  DS
    POP   ES
    MOV   AH,$E3
    MOV   AL,ModeB

    {int 3}

    INT   $21

    MOV   GlobalError,AL

    POP   SI
    POP   DI
    POP   ES
    POP   DS
  End;
End;

Function GetNetSerNo: LongInt;
Var Long,Helyi : LongInt;
Begin

    GetSerialNum;

    If GlobalError = 0 Then
    Begin

      Long := 0;
      Helyi:= 1;

      For Cik := 5 DownTo 2 Do
      Begin
        Inc(Long,Helyi*((RepBuf[Cik]      ) AND 15));
        Helyi := Helyi * 10;
        Inc(Long,Helyi*((RepBuf[Cik] SHR 4) AND 15));
        Helyi := Helyi * 10;
      End;

      GetNetSerNo := Long;

    End
    Else GetNetSerNo := GlobalError; {'Nincs bejelentkezett felhaszn l¢...'}
End;  {GetNetSerNo}

Begin
End.
