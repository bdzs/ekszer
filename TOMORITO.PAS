Unit Tomorito;

Interface

Procedure Tomorit(Var Elozo;            { Az elozo byte tartalma }
                  Var InputBuf;         { Tomoritetlen puffer    }
                  Var OutputBuf;        { Tomoritett puffer      }
                  InputHossz : Word;    { Tomoritetlen hossz     }
                  Var OutputHossz       { Tomoritett hossz       }
                  );

Procedure Kibont(Var Elozo;           { Az elozo byte tartalma }
                 Var InputBuf;        { Tomoritett puffer      }
                 Var OutputBuf;       { Tomoritetlen puffer    }
                 OutputHossz:Word     { Tomoritetlen hossz     }
                 );


Implementation

Var TomoritoTabla : Array[Byte] Of
      Record
        BitSzam  : Byte;    { Ez a byte hany biten kodolt }
        BitMinta : Word;    { A bitminta }
      End;

Const KibontT : Array[0..255] Of Shortint =
(0,
   1,  -1,   2,  -2,   3,  -3,   4,  -4,   5,  -5,
   6,  -6,   7,  -7,   8,  -8,   9,  -9,  10, -10,
  11, -11,  12, -12,  13, -13,  14, -14,  15, -15,
  16, -16,  17, -17,  18, -18,  19, -19,  20, -20,
  21, -21,  22, -22,  23, -23,  24, -24,  25, -25,
  26, -26,  27, -27,  28, -28,  29, -29,  30, -30,
  31, -31,  32, -32,  33, -33,  34, -34,  35, -35,
  36, -36,  37, -37,  38, -38,  39, -39,  40, -40,
  41, -41,  42, -42,  43, -43,  44, -44,  45, -45,
  46, -46,  47, -47,  48, -48,  49, -49,  50, -50,
  51, -51,  52, -52,  53, -53,  54, -54,  55, -55,
  56, -56,  57, -57,  58, -58,  59, -59,  60, -60,
  61, -61,  62, -62,  63, -63,  64, -64,  65, -65,
  66, -66,  67, -67,  68, -68,  69, -69,  70, -70,
  71, -71,  72, -72,  73, -73,  74, -74,  75, -75,
  76, -76,  77, -77,  78, -78,  79, -79,  80, -80,
  81, -81,  82, -82,  83, -83,  84, -84,  85, -85,
  86, -86,  87, -87,  88, -88,  89, -89,  90, -90,
  91, -91,  92, -92,  93, -93,  94, -94,  95, -95,
  96, -96,  97, -97,  98, -98,  99, -99, 100,-100,
 101,-101, 102,-102, 103,-103, 104,-104, 105,-105,
 106,-106, 107,-107, 108,-108, 109,-109, 110,-110,
 111,-111, 112,-112, 113,-113, 114,-114, 115,-115,
 116,-116, 117,-117, 118,-118, 119,-119, 120,-120,
 121,-121, 122,-122, 123,-123, 124,-124, 125,-125,
 126,-126, 127,-127,-128);




Procedure Tomorit(Var Elozo;            { Az elozo byte tartalma }
                  Var InputBuf;         { Tomoritetlen puffer    }
                  Var OutputBuf;        { Tomoritett puffer      }
                  InputHossz : Word;    { Tomoritetlen hossz     }
                  Var OutputHossz       { Tomoritett hossz       }
                  );Assembler;
Var InputSeg,
    StartOff : Word;
    ElozoB   : Byte;
Label EgyByteJon,
      ByteCik,
      BitCik,
      VanMegBit,
      VegeUres;
Asm
  LES   DI,[Elozo]
  MOV   AL,ES:[DI]
  MOV   [ElozoB],AL

  MOV   CX,[InputHossz]
  LES   DI,[InputBuf]
  MOV   [InputSeg],ES
  MOV   SI,DI
  LES   DI,[OutputBuf]
  MOV   [StartOff],DI

  MOV   DX,8   { DH:=0 DL:=8 bit ures}
  CLD
ByteCik:

  PUSH  DS
  MOV   DS,[InputSeg]
  LODSB
  MOV   AH,AL
  SUB   AL,[ElozoB]                     { A byte-ot kulonbsegge alakitjuk }
  MOV   [ElozoB],AH
  XOR   AH,AH
  POP   DS

  PUSH  CX

  MOV   BX,AX    { BX := AX * 3 }
  ADD   BX,BX
  ADD   BX,AX

  XOR   CH,CH
  MOV   CL,[BX+Offset TomoritoTabla]    {  Kivesszuk a bitszamot  }
  INC   BX
  MOV   AX,[BX+Offset TomoritoTabla]    {  AX-be a bitminta kerul }
BitCik:
  RCL   AX,1
  RCL   DH,1
  DEC   DL
  JNZ   VanMegBit

  XCHG  DH,AL         { Betelt a byte, kiirjuk }
  STOSB               { Elrakjuk               }
  XCHG  DH,AL         { visszacsereljuk        }
  MOV   DX,8          { DH=0 DL=8 bit ures     }
VanMegBit:
  LOOP  BitCik

  POP   CX
  LOOP  ByteCik
  OR    DL,DL
  JZ    VegeUres

  MOV   CL,DL         {  Ennyit kell meg forgatni rajta,  }
  RCL   DH,CL         {  hogy a bal szelre keruljon       }
  MOV   AL,DH         {  AL-be atrakjuk                   }
  STOSB               {  es eltaroljuk                    }
VegeUres:
  SUB   DI,[StartOff]
  MOV   AX,DI
  LES   DI,[OutPutHossz]
  STOSW
  LES   DI,[Elozo]
  MOV   AL,[ElozoB]
  STOSB
End;


Procedure Kibont(Var Elozo;           { Az elozo byte tartalma }
                 Var InputBuf;        { Tomoritett puffer      }
                 Var OutputBuf;       { Tomoritetlen puffer    }
                 OutputHossz:Word     { Tomoritetlen hossz     }
                 );Assembler;
Var
    EredetiDs : Word;
    ElozoB    : Byte;

Label
    UjOutByte,
    Elagazas,
    NeTovabb,
    EnnyiBit,
    BitCik1,
    VanMegBit,
    VanMegBit2;
Asm
  CLD
  MOV   [EredetiDs],DS
  MOV   CX,[OutputHossz]
  LDS   SI,[Elozo]
  LODSB
  MOV   [ElozoB],AL
  LES   DI,[OutputBuf]
  LDS   SI,[InputBuf]
  MOV   AH,8                { Ennyi feldolgozatlan bit van benne }
  LODSB

UjOutByte:
  PUSH  CX
  XOR   CX,CX
  MOV   BX,Offset KibontT   { Kiindulasi cim             }
  MOV   DX,1                { Ennyivel kell majd eltolni }
Elagazas:

  RCL   AL,1
  PUSHF
  DEC   AH
  JNZ   VanMegBit
  LODSB
  MOV   AH,8                { Ennyi feldolgozatlan bit van benne }
VanMegBit:
  POPF
  JNC   NeTovabb

  ADD   BX,DX
  ADD   DX,DX
  INC   CX
  JMP   Elagazas

NeTovabb:
                            { A baziscim BX-ben}
  XOR   DX,DX               { DX-be a hasznos biteket gyujtom ossze }
  JCXZ  EnnyiBit
BitCik1:
  RCL   AL,1
  PUSHF
  DEC   AH
  JNZ   VanMegBit2
  LODSB
  MOV   AH,8                { Ennyi feldolgozatlan bit van benne }
VanMegBit2:
  POPF

  RCL   DL,1
  LOOP  BitCik1
EnnyiBit:
  POP   CX

  PUSH  AX
  PUSH  DS
  MOV   DS,[EredetiDs]      { Ez a valodi DS }
  ADD   BX,DX               { A bazishoz hozzaadom a hasznos bitek erteket }
  MOV   AL,[BX]
  ADD   AL,[ElozoB]         { A kulonbseget visszaalakitjuk byte-ra }
  MOV   [ElozoB],AL
  STOSB

  POP   DS
  POP   AX

  LOOP  UjOutByte
  MOV   DS,[EredetiDs]
  LES   DI,[Elozo]
  MOV   AL,[ElozoB]
  STOSB
End;

Procedure TableInit;
Var Cikl,
    Cikl2  : integer;
    Hanyszor,
    Bsz   : Byte;
    Vege  : Byte;
    Minta,
    Eleje : Word;
    Darab : Byte;
Begin
  Cikl  := 0;
  Minta := 0;
  Darab := 1;
  Vege  := 1;
  Bsz   := 3;
  Eleje := $8000;

  For Cikl := 1 To 127 Do
   For Cikl2 := 0 To 1 Do
    Begin
      With TomoritoTabla[Byte(Cikl+(Cikl2*((-2)*Cikl)))] Do
        Begin
          BitSzam  := Bsz;
          BitMinta := Eleje Or (Minta Shl (16-Bsz));
        End;
      Inc(Minta);

      If (Cikl = Vege) And (Cikl2=1) Then
        Begin
          Inc(Darab,Darab);
          Inc(Bsz,2);
          Minta := 0;
          Inc(Vege,Darab);
          Eleje := (Eleje Shr 1) Or $8000;
        End;
    End;
  With TomoritoTabla[0] Do
    Begin
      BitSzam  := 1;
      BitMinta := 0;
    End;
  With TomoritoTabla[Byte(-128)] Do
    Begin
      BitSzam  := 17;
      BitMinta := $FF00
    End;
End;

Begin
  TableInit
End.