UNIT XMSCDW;


Interface
Uses dos;
Type
    Vari   = Record
               Case Byte Of
                  1 : (L:Longint);
                  2 : (P:Pointer);
               End;

    pbtype = Record
               Count : Longint;
               Shand : Word;
               Spoi  : Vari;
               Dhand : Word;
               Dpoi  : Vari
             End;


Var Reg    : Registers;
    XmsCim : Pointer;
    Oke    : Boolean;
    Err    : Byte;
    PB     : PBType;
{    Puffer : Array[0..16383] Of Byte;  Hogy ez minek volt itt ????}
    Xhand  : Word;
    PP     : Pointer;


Function VanXms:Boolean;

Procedure XmsAvail(Var One,All: Word);
Procedure XmsAlloc(Size : Word; Var Handle : Word);
Procedure XmsDeAlloc(Handle : Word);

Procedure XmsFel(Honnan:Pointer;Hova:LongInt;Mennyit:Word);
Procedure XmsLe(Honnan:Longint;Hova:Pointer;Mennyit:Word);
Procedure Xms_Up(Handle:Word;Honnan:Pointer;Hova:LongInt;Mennyit:Word);
Procedure Xms_Down(Handle:Word;Honnan:Longint;Hova:Pointer;Mennyit:Word);
Function XmsMaxBlock:Word;



Procedure HH;



Implementation


Function VanXms:Boolean;
Begin
  VanXms := False;
  {$IFNDEF VER352}
  Reg.Ax := $4300;
  Intr($2F,Reg);
  If Reg.Al = $80 Then
    Begin
      VanXms := True;
      Reg.Ax := $4310;
      Intr($2F,Reg);
      XmsCim := Ptr(Reg.ES,Reg.BX);
      {SetIntVec(XmsInt,@CallXms);}
    End;
  {$ENDIF}
End;

Procedure XmsAvail(Var One,All: Word);Assembler;
Asm
  MOV   AH,08
  Call  DS:[XmsCim]
  LES   DI,[One]
  Stosw
  MOV   AX,DX
  LES   DI,[All]
  Stosw
  Mov  [Oke],AL
  Or   [Oke],AH
  Mov  [Err],Bl
End;

Procedure XmsAlloc(Size : Word; Var Handle : Word);Assembler;
Asm
  MOV   AH,09
  MOV   DX,Size
  Call  DS:[XmsCim]
  LES   DI,[Handle]
  MOV   AX,DX
  Stosw
  Mov  [Oke],AL
  Or   [Oke],AH
  Mov  [Err],Bl
End;

Procedure XmsDeAlloc(Handle : Word);Assembler;
Asm
  MOV   AH,$0A
  MOV   DX,Handle
  Call  DS:[XmsCim]
  Mov  [Oke],AL
  Or   [Oke],AH
  Mov  [Err],Bl
End;

Procedure XmsMove;Assembler;
Asm
  MOV   AH,$0B
  MOV   SI,Offset PB
  Call  DS:[XmsCim]
  Mov  [Oke],AL
  Or   [Oke],AH
  Mov  [Err],Bl
End;

Procedure XmsFel(Honnan:Pointer;Hova:LongInt;Mennyit:Word);
Begin
  PB.Count  := Mennyit;
  PB.Shand  := 0;
  PB.Dhand  := XHand;
  PB.SPoi.P := Honnan;
  PB.Dpoi.L := Hova;
  XmsMove
End;

Procedure XmsLe(Honnan:Longint;Hova:Pointer;Mennyit:Word);
Begin
  PB.Count  := Mennyit;
  PB.Shand  := Xhand;
  PB.Dhand  := 0;
  PB.SPoi.L := Honnan;
  PB.Dpoi.P := Hova;
  XmsMove
End;

Procedure Xms_Up(Handle:Word;Honnan:Pointer;Hova:LongInt;Mennyit:Word);
Begin
  PB.Count  := Mennyit;
  PB.Shand  := 0;
  PB.Dhand  := Handle;
  PB.SPoi.P := Honnan;
  PB.Dpoi.L := Hova;
  XmsMove
End;

Procedure Xms_Down(Handle:Word;Honnan:Longint;Hova:Pointer;Mennyit:Word);
Begin
  PB.Count  := Mennyit;
  PB.Shand  := Handle;
  PB.Dhand  := 0;
  PB.SPoi.L := Honnan;
  PB.Dpoi.P := Hova;
  XmsMove
End;

Function XmsMaxBlock:Word;
Var One,All : Word;
Begin
  XmsAvail(One,All);
  XmsMaxBlock := One;
End;


Procedure HH;
Begin
  If Not Oke Then
    Writeln('Hiba :',Err);
End;

End.

