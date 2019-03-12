Unit BANV;
Interface

Function CheckSerialNumber:Boolean;

Implementation

Type BlockT = Record
                Akarmi : Word;
                Drive  : Word;
                Case Byte Of
                  0:(B1,B2,B3,B4 : Byte;
                     W1 : Word);
                  1:(L1:LongInt;
                     Wx : Word);
              End;

Procedure Xchg(Var B1,B2 : Byte);
Var TMP : Byte;
Begin
  TMP := B1;
  B1 := B2;
  B2 := Tmp
End;
(*
Procedure BanInt(Var AXR:WORD;DSDX:Pointer);Assembler;
Label bvlup,Kovetkezo,MegVan,Vector,Vege,Vector_Ok,Keresi,NemTalalta;
Asm
  {$I-}
  {$R-}
  PUSH  DS
  LES   DI,[AXR]
  MOV   AX,ES:[DI]
  LDS   DX,[DSDX]

  XOR   BX,BX
  MOV   CX,10
Keresi:
  cmp   cs:byte ptr [vector+BX],$CD
  JZ    Vector_Ok
  INC   BX
  LOOP  Keresi
  MOV   AX,2
  JMP   Vege

Vector_Ok:
  INC  BX
  cmp  cs:byte ptr [vector+BX],0
  jnz  vector

  push AX
  push BX
  push CX
  push DS
  push SI
  push DI
  mov  CX,7
  mov  SI,180H
bvlup:
  xor  AX,AX
  mov  DS,AX
  lds  AX,[SI]
  mov  DI,AX
  or   SI,SI
  jz   Kovetkezo
  sub  DI,4
  mov  AX,[DI]
  cmp  AX,$4142     { 'BA' }
  jnz  Kovetkezo
  mov  AX,[DI+2]
  cmp  AX,$564E     { 'NV' }
  jz   Megvan
Kovetkezo:
  add  SI,4
  loop bvlup
  pop  DI
  pop  SI
  pop  DS
  pop  CX
  pop  BX
  pop  AX
  mov  AX,1
  jmp  Vege
MegVan:
  mov  AX,SI
  shr  AX,1
  shr  AX,1
  mov  cs:byte ptr [Vector+BX],AL
  pop  DI
  pop  SI
  pop  DS
  pop  CX
  pop  BX
  pop  AX
Vector:
  DB   $CD
  DB   $00
Vege:
  LES  DI,[AXR]
  STOSW
  POP  DS
End;
*)

Procedure BanInt(Var AXR:WORD;DSDX:Pointer);Assembler;
Label bvlup,Kovetkezo,MegVan,Vege;
Asm
  {$I-}
  {$R-}
  PUSH  DS
  LES   DI,[AXR]
  MOV   AX,ES:[DI]
  LDS   DX,[DSDX]
  XOR   BX,BX

  push AX
  push CX
  push DS
  push SI
  push DI
  mov  CX,7        { 7 vector vizsgalata }
  mov  SI,180H     { 60H -tol            }
bvlup:
  xor  AX,AX
  mov  DS,AX
  lds  AX,[SI]     { A vektor DS:AX-be   }
  mov  DI,AX
  or   SI,SI       { Ha nulla,akkor nem jo }
  jz   Kovetkezo
  sub  DI,4        { a vektor cime alatt 4 byte-tal }
  mov  AX,[DI]
  cmp  AX,$4142    { 'BA' }
  jnz  Kovetkezo
  mov  AX,[DI+2]
  cmp  AX,$564E     { 'NV' }
  jz   Megvan
Kovetkezo:
  INC  BX
  add  SI,4
  loop bvlup       { jon a kovetkezo vektor }
  pop  DI
  pop  SI
  pop  DS
  pop  CX
  pop  AX
  mov  AX,1
  jmp  Vege
MegVan:
  pop  DI
  pop  SI
  pop  DS
  pop  CX
  pop  AX

  CMP  BX,0
  JNZ  @1
  INT  $60
  JMP  Vege
@1:
  CMP  BX,1
  JNZ  @2
  INT  $61
  JMP  Vege
@2:
  CMP  BX,2
  JNZ  @3
  INT  $62
  JMP  Vege
@3:
  CMP  BX,3
  JNZ  @4
  INT  $63
  JMP  Vege
@4:
  CMP  BX,4
  JNZ  @5
  INT  $64
  JMP  Vege
@5:
  CMP  BX,5
  JNZ  @6
  INT  $65
  JMP  Vege
@6:
  INT  $66

Vege:
  LES  DI,[AXR]
  STOSW
  POP  DS
End;

Function CheckSerialNumber:Boolean;
Var Block   : BlockT;
    AXR     : Word;
    NumHex  : String[8];
    Cikl    : Integer;
    EzAz    : Integer;
Const
    {$I-}
    {$R-}
    MaxServerNum = 8;
    Numbers : Array[1..MaxServerNum] Of LongInt =
             ($003746,
              $003649,
              $003736,
              $003613,
              $003711,
              $003732,
              $003654,
              $003737);
Begin
  AXR := $0004;
  EzAz := 0;
  Block.Akarmi := 8;
  Block.Drive  := 0;  { default }
  BanInt(AXR,@Block);
  If AXR = 0 Then
    With Block Do
      Begin
        Xchg(B1,B4);
        Xchg(B2,B3);
        {writeln(Block.L1);}
        For Cikl := 1 To MaxServerNum Do
          If Numbers[Cikl] = L1 Then
            EzAz := Cikl
      End;
  CheckSerialNumber := (EzAz <> 0);
End;
{$I+}
End.