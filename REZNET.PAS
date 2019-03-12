{$A-,B-,D-,E-,F-,I+,L-,N-,O-,R-,S-,V-}
{$M 2048,0,0}

Program RezNet;         { Rezidens halozati vedelem }


uses dos,crt,EkNet;

const stack = 2048;
      Masodperc  = 3;

type st64     = string[64];
     st80     = string[80];

     dosokrek = record
                  dosokoff : word;
                  dosokseg : word;
                end;

     tomb     = array [0..16] of byte;
     kepernyo = Array[1..25,1..80,1..2] Of Byte;

var marbentvan        : boolean;
    dosokpoint        : ^byte;
    reg               : registers;
    valodi28          : pointer;
    valodi9           : pointer;
    valodi1C          : Pointer;
    Kep               : ^Kepernyo;

    saveSS, saveSP    : word;
    mineSS, mineSP    : word;
    Spath,
    Dpath             : String[64];
    Fmask             : Word;
    Fmasks            : Array[1..8] Of String[12];
    Cikl              : Word;
    Srec              : SearchRec;
    Fin,Fout,FoutB    : File;
    VanOut            : Boolean;
    VanMeg            : LongInt;
    Time1,Time2       : LongInt;
    IO                : Word;
    Name1,Name2,
    BakName           : String[64];
    Abort             : Boolean;
    Num               : Word;
    ElTelt            : LongInt;
    ppp               : Array[1..160] Of Byte;
    ox,oy             : Word;
    Hand              : Word;


const
    alt         : boolean = false;
    Beakarjonni : boolean = false;
    PuffSize    : Word    = 16384;
    Puffer      : Pointer = NIL;



Procedure Stop;
Begin
  If ReadKey = ' ' Then;
End;


Procedure Call_old_int(vektor: pointer);Assembler;

ASM
  PushF
  Call [Vektor]
End;

Function Installed: boolean;

Var  kuku : Boolean;
     po   : ^tomb   absolute 0:$28*4;
     popo : ^string absolute 0:$f0*4;

Begin
    kuku      :=  po^[16] = $90;
    installed :=  kuku;
    if kuku then
      Begin
      End;
End;


function dosok : boolean;

begin
  dosok := (dosokpoint^ = 0);
end;

procedure ujint1C; interrupt;
begin
   call_old_int(valodi1C);
   If (Not MarBentVan) Then
     Begin
       Inc(Eltelt);
       if Eltelt >= Masodperc*18 then
         begin
           Eltelt := 0;
           if (not marbentvan) Then
             If dosok then
               Begin
                 marbentvan := true;

                 Asm
                   MOV  [SaveSS],SS
                   MOV  [SaveSP],SP
                   MOV  SS,[MineSS]
                   MOV  SP,[MineSP]
                   PUSH BP
                   MOV  BP,SP
                   STI
                 End;

                 SwapVectors;
                 RezService;
                 SwapVectors;

                 Asm
                   CLI
                   POP  BP
                   MOV  SS,[SaveSS]
                   MOV  SP,[SaveSP]
                 End;

                 marbentvan := false;
                 beakarjonni:= false;
               End
             else
               Begin
                 {Sound(400);
                 Delay(100);
                 Nosound;}
                 beakarjonni := true;
               End;
         end;
     End
end;

procedure Ujint28;    interrupt;

begin
  inline($90);
  call_old_int(valodi28);

  if (not marbentvan) and beakarjonni then
    Begin
      marbentvan := true;

      Asm
        MOV  [SaveSS],SS
        MOV  [SaveSP],SP
        MOV  SS,[MineSS]
        MOV  SP,[MineSP]
        PUSH BP
        MOV  BP,SP
        STI
      End;

     SwapVectors;
     RezService;
     SwapVectors;

     Asm
       CLI
       POP  BP
       MOV  SS,[SaveSS]
       MOV  SP,[SaveSP]
     End;

     marbentvan := false;
     beakarjonni:= false;
    End;
  ASM
    nop
    nop
    nop
  End;

end;

{------------------------------ installation -}

begin

  if not installed then
    If RezStart Then
      begin
        ElTelt := 0;

        getintvec($08,valodi1c);
        setintvec($08,@ujint1c);        {set vector}

        getintvec($28,valodi28);
        setintvec($28,@ujint28);

        reg.AH     := $34;            {get indos flag}
        intr($21,reg);
        DosOkPoint := Ptr(Reg.ES,Reg.BX);
        marbentvan  := false;
        directvideo := false;

        mineSS := SSeg;
        mineSP := Stack;
        writeln('êkSzer rezidens h†l¢zati driver akt°v');

        keep(0);

      end                {if not installed}
    Else
     Writeln('H†l¢zati hiba !')
 Else
   writeln('A h†l¢zati driver m†r akt°v');

end.