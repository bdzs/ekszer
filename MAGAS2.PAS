Unit Magas2;

Interface

Procedure Hangositas(PtrS  : Pointer;
                     Hossz : Word;
                     Arany : Word);

Procedure AddPitch(PtrS:Pointer;
                   PtrD:Pointer;
                   SHossz : Word;
               Var DHossz : Word;
                   XArany : Real);

Implementation

Procedure FrekvCsokk(PtrS,
                     PtrD    : Pointer;
                     Hossz,
                     Szamlalo,
                     Egesz,
                     Maradek : Word);Assembler;
Asm
  PUSH  DS
  CLD
  LDS   SI,[PtrS]
  LES   DI,[PtrD]
  MOV   CX,[Hossz]
@1:
  PUSH  CX

  MOV   CX,[Egesz]
  MOV   AX,[Maradek]
  MOV   BX,[Szamlalo]
  ADD   BX,AX
  CMP   BX,[Hossz]
  JC    @3
  SUB   BX,[Hossz]
  INC   CX

@3:
  MOV   [Szamlalo],BX

  LODSB
  REPZ  STOSB
  INC   BX
  POP   CX
  Loop  @1
  POP   DS
End;

Procedure FrekvNov(PtrS,
                   PtrD    : Pointer;
                   Hossz,
                   Szamlalo,
                   Egesz,
                   Maradek : Word);Assembler;
Asm
  PUSH  DS
  CLD
  LDS   SI,[PTRS]
  LES   DI,[PTRD]
  MOV   CX,[Hossz]
@1:
  PUSH  CX

  MOV   CX,[Egesz]
  MOV   AX,[Maradek]
  MOV   BX,[Szamlalo]
  ADD   BX,AX
  CMP   BX,[Hossz]
  JC    @3
  SUB   BX,[Hossz]
  INC   CX

@3:
  MOV   [Szamlalo],BX
  XOR   DX,DX
  PUSH  CX
@2:
  LODSB
  ADD   DL,AL
  ADC   DH,0
  LOOP  @2
  MOV   AX,DX
  POP   CX
  DIV   CL
  STOSB

  POP   CX
  Loop  @1
  POP   DS
End;

Procedure AddPitch(PtrS:Pointer;
                   PtrD:Pointer;
                   SHossz : Word;
               Var DHossz : Word;
                   XArany : Real);

Begin
  DHossz := Round(SHossz*XArany);
  If XArany >= 1 Then
    FrekvCsokk(PtrS,                   { Forras        }
               PtrD,                   { Cel           }
               SHossz,                 { Forras Hossza }
               0,                      { Mindig nulla  }
               DHossz Div SHossz,      { Nagyitas egeszresze }
               DHossz Mod SHossz)      { Nagyitasi maradek   }
  Else
    FrekvNov(PtrS,                   { Forras       }
             PtrD,                   { Cel          }
             DHossz,                 { Cel Hossza   }
             0,                      { Mindig nulla }
             SHossz Div DHossz,      { Kicsinyites egeszresze }
             SHossz Mod DHossz)      { Kicsinyitesi maradek   }
End;

Procedure Hangositas(PtrS  : Pointer;
                     Hossz : Word;
                     Arany : Word);Assembler;
Asm
  CLD
  MOV   CX,[Arany]
  MOV   AX,128
  MUL   CX
  MOV   CX,100
  DIV   CX
  MOV   BX,128
  SUB   BX,AX
  LES   DI,[PtrS]
  MOV   CX,[Hossz]
@1:
  PUSH  CX
  XOR   AH,AH
  MOV   AL,ES:[DI]
  MOV   CX,[Arany]
  MUL   CX
  MOV   CX,100
  DIV   CX
  ADD   AX,BX
  MOV   ES:[DI],AL
  INC   DI

  POP   CX
  LOOP  @1
End;

End.
