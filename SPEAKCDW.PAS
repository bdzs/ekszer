Unit SpeakCdw;

{$I MEMORY.CDW}

Interface

Uses DOS,CRT,strings,WindowM,CalcCdw,Tomorito,MenuErr,HexKit,
     Magas2

{$IFDEF PROBA}
,Printer
{$ENDIF}

;
Const
      SpeakPuffSize  = 50000;
Type
      SpPufPoint     = Array[0..SpeakPuffSize-1] Of Byte;
      CardType       = (Speaker,Melis,Blaster);
Const
      SpeakPuff      : ^SpPufPoint = NIL;
      MaxSzoveg      = 240;
      VanWLib        : Boolean = False;
      OutputCard     : CardType=speaker;

  SbIOaddr  : Word = $220;
  SbIRQ     : Byte =    7;
  SbDMAchan : Byte =    1;
  SbType    : Byte =    2;


MaxNormal   : Real    =    1.3;
MinNormal   : Real    =    0.9;
MaxPont     : Real    =    1.5;
MinPont     : Real    =    1.1;
MaxVesszo   : Real    =    1.5;
MinVesszo   : Real    =    1.1;
MaxKKerd    : Real    =    1.1;
MinKKerd    : Real    =    0.9;
KKerdEleje  : Real    =    1.1;
MaxSKerd    : Real    =    1.1;
MinSKerd    : Real    =    0.9;
SKerdVege   : Real    =    1.1;
Hangsuly    : Integer =    130;
MondatEses  : Real    =    0.1;

Procedure InitSpeak;
Procedure Speak(Num:Integer);
Procedure Speak2(Num1,Num2:Integer);
Procedure Init_Felolvas(Var AzKodTomb : PofaDatType);
Procedure WflLezar;

Procedure PlayPcm(Speed : Word;
                  Length : LongInt;
                  Addr   : Pointer;
                  Mode   : Boolean);

Procedure SaySentence(Var Mondat    : MondatType;
                          Count     : Word;
                      Var AzKodTomb : PofaDatType);

Procedure SetHangero;


Implementation

Uses Inputcdw;

Function _INIT_MEM(KBytes:WORD):Integer;Far;External;
Function _INIT_LIB: Integer;Far;External;
Function _CSOMAG_FEL(BlokkMeret : Word;
                     PCim       : Pointer):Integer;Far;External;

Function _KIBONTAS(INDEX   : Word;        { Hanyas szamut }
                   TempBuf : Pointer;     { Temp.buffer   }
                   PCim    : Pointer      { Ide bontja ki }
                                    ):Integer;Far;External;

Function _LEZAR:Integer;Far;External;


Function  SB_INIT(BASEPORT,IRQNUM,DMACHAN : Word;CALLBACK:Pointer):wORD;FAR;External;
Procedure SB_REC(FREKV:WORD);FAR;External;
Procedure SB_PLAY(FREKV:WORD);FAR;External;
Procedure SB_ADDPUFFER(BLADDR:POINTER;LEN:WORD);FAR;External;
Procedure SB_CLOSE;FAR;External;
Function  SB_DMAWORK:WORD;FAR;External;


{$L WAVLIB.OBJ}
{$L SBLIB.OBJ}

Label TimeLoop;

Type TablazatType = Array[0..256] Of Word;
     PcmLibFej = Record
                   Azon      : Array[0..5] Of Char;
                   FejHossz  : Word;
                   Verzio    : Word;
                   Tipus     : Byte;
                   StartOfDir: LongInt;
                   DirHossz  : Word;
                   Comment   : String[128]
                 End;
  PcmHufFej = Record
                Azon      : Array[0..5] Of Char;
                FejHossz  : Word;
                Verzio    : Word;
                Tipus     : Byte;
                FullHossz : Longint;
                TomHossz  : Longint;
                Frekv     : Longint;
                Felbontas : Byte;
                Csatorna  : Byte
              End;

     DirItem   = Record
                   Szam   : Integer;
                   Szoveg : String[16];
                   Start  : LongInt;
                 End;

Var WW         : Word;
    TimeDiv    : Word;
    Counter    : LongInt;
    CounterW   : Word Absolute Counter;
    IntReg     : Byte;
    OldInt8    : Pointer;

    TablazatH  : TablazatType;
    StPos      : Array[0..MaxSzoveg] Of LongInt;

Const
    StiLehet   = 1111;

    TombASize  : Word = 0;

    Tablazat    : TablazatType =
(
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,
$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,$FF81,

$FF83,$FF88,$FF8D,$FF92,$FF97,$FF9C,$FFA1,$FFA6,$FFAB,$FFB0,$FFB5,$FFBA,$FFBF,
$FFC4,$FFC9,$FFCE,$FFD3,$FFD8,$FFDD,$FFE2,$FFE7,$FFEC,$FFF1,$FFF6,$FFFB,

$0000,

$0005,$000A,$000F,$0014,$0019,$001E,$0023,$0028,$002D,$0032,$0037,$003C,$0041,
$0046,$004B,$0050,$0055,$005A,$005F,$0064,$0069,$006E,$0073,$0078,$007D,

$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,
$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,
$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,
$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,
$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,
$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,
$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,
$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F,$007F);

Var T2 : Array[0..256] Of Integer Absolute Tablazat;
    T3 : Array[0..256] Of Integer Absolute TablazatH;
    Cik         : Integer;
    Code        : Integer;
    FF,
    F2          : File;
    L1,L2,Meret : Longint;
    Fname       : String;
    FMeret,TMeret:word;
    IOError     : Boolean;
    Elozo       : Byte;

Procedure InitHangSuly;
Var F : Text;
    P : String[64];
    Wi: Integer;
    Wr: Real;
    Ws: String;
Const
    Fn: String[12] = 'HANGINIT.DAT';

Procedure ReadLine;
Begin
  ReadLn(F,Ws);
  Delete(Ws,1,24);
  While Pos(' ',Ws) <> 0 Do
    Delete(Ws,Pos(' ',Ws),1);
  Val(Ws,Wi,Code);
  Val(Ws,Wr,Code);
End;

Begin
  P := FontPath;
  If P[Length(P)] <> '\' Then P := P + '\';
  Assign(F,P+Fn);
  {$I-}
  Reset(F);
  {$I+}
  If IOResult = 0 Then
  Begin
    ReadLine; MaxNormal   :=    Wr;
    ReadLine; MinNormal   :=    Wr;
    ReadLine; MaxPont     :=    Wr;
    ReadLine; MinPont     :=    Wr;
    ReadLine; MaxVesszo   :=    Wr;
    ReadLine; MinVesszo   :=    Wr;
    ReadLine; Hangsuly    :=    WI;
    ReadLine; MaxKKerd    :=    Wr;
    ReadLine; MinKKerd    :=    Wr;
    ReadLine; KKerdEleje  :=    Wr;
    ReadLine; MaxSKerd    :=    Wr;
    ReadLine; MinSKerd    :=    Wr;
    ReadLine; SKerdVege   :=    Wr;
    ReadLine; MondatEses  :=    Wr;

    Close(F);
  End
  Else Error(3,P+Fn);
End;

Procedure AnyagBetoltes(Num : Integer;Hova:Word);
Var Fej    : PcmHufFej;
    FMeret,
    TMeret : Word;
    Rossz  : Boolean;
    Betoltott : Word;
Begin
  Rossz := True;
  If StPos[Num] <> 0 Then
    Begin
      FileMode := 0;
      {$I-}
      Reset(FF,1);
      {$I+}

      If IOResult = 0 Then
      Begin
        {$I-}
        Seek(FF,StPos[Num]);
        {$I+}

        If IOResult = 0 Then
        Begin
          {$I-}
          BlockRead(FF,Fej,SizeOf(Fej));
          {$I+}

          If IoResult = 0 Then
            Begin
              Rossz      := False;
              Meret      := Fej.FullHossz;
              Frekvencia := Fej.Frekv;
              Elozo      := 128;
              Betoltott  := 0;
              Repeat
                {$I-}
                BlockRead(FF,FMeret,2);
                Rossz := Rossz Or (IoResult <> 0);
                BlockRead(FF,TMeret,2);
                Rossz := Rossz Or (IoResult <> 0);
                {$I+}

                {$I-}
                BlockRead(FF,SpeakPuff^[SpeakPuffSize-TMeret],TMeret);
                {$I+}
                Rossz := Rossz Or (IoResult <> 0);

                If Not Rossz Then
                  Kibont(Elozo,SpeakPuff^[SpeakPuffSize-TMeret],
                               SpeakPuff^[Hova+Betoltott],FMeret);
                Inc(Betoltott,FMeret);
              Until Betoltott=Fej.FullHossz;

              TombASize := Fej.FullHossz;

            End;  { Ha sikerult a BlockRead }
        End;  { Ha sikerult a Seek }
      End; { Ha sikerult megnyitni }

      {$I-}
      Close(FF);
      {$I+}
      FileMode := 2;
    End
End;

Procedure PlayPcm( Speed : Word;
                  Length : LongInt;
                  Addr   : Pointer;
                  Mode   : Boolean);

Label  X1,X2,X3,X4,X5,X6,X7,X8,X9,
       Loc_27,Loc_28,Loc_29,Loc_30,Loc_31,Loc_32,
       Tovabb,NemCli;
Begin
  Asm
     STI
     Cmp        Byte Ptr Mode,0
     Jz         NemCli
     CLI
NemCli:
     MOV        dx,StiLehet
     push	di
     push	si
     sub	word ptr [Length],1
     sbb	word ptr [Length+2],0
     cmp	word ptr [Speed],1
     jb	        loc_32			{ Jump if below                  }
     cmp	word ptr [Speed],4B0h
     ja	        loc_32			{ Jump if above                  }
     les	si,dword ptr [Addr]	{ Load 32 bit ptr                }
     mov	al,0B8h
     out	43h,al			{ port 43h, 8253 wrt timr mode   }
     jmp	X1                      { delay for I/O                  }
X1:  jmp	X2		        { delay for I/O                  }
X2:  jmp	X3		        { delay for I/O                  }
X3:  mov	al,1
     out	42h,al			{ port 42h, 8253 timer 2 spkr    }
     jmp     	X4		        { delay for I/O                  }
X4:  jmp	X5		        { delay for I/O                  }
X5:  jmp	X6		        { delay for I/O                  }
X6:  mov	al,0
     out	42h,al			{ port 42h, 8253 timer 2 spkr    }
     jmp	X7		        { delay for I/O                  }
X7:  jmp	X8		        { delay for I/O                  }
X8:  jmp	X9		        { delay for I/O                  }
X9:  in 	al,61h			{ port 61h, 8255 port B, read    }
     and	al,0FCh
     out	61h,al			{ port 61h, 8255 B - spkr, etc   }
				        { al = 0, disable parity         }
     xor	di,di			{ Zero register                  }
 loc_27:

TOVABB:
     mov	bl,es:[si]
     inc	si
     xor	bh,bh			{ Zero register                  }
     shl	bx,1			{ Shift w/zeros fill             }
     mov	bx,[Bx+Offset TablazatH]

     mov	cx,[Speed]
 loc_28:

     add	di,bx
     jge	loc_29			{ Jump if > or =                 }
     sub	di,0FF81h
     and	al,0FCh
     out	61h,al			{ port 61h, 8255 B - spkr, etc   }
				        { al = 0, disable parity         }


     loop	loc_28		        { Loop if cx > 0                 }

     jmp	loc_30

 loc_29:
     sub	di,7Fh
     or	        al,3
     out	61h,al			{ port 61h, 8255 B - spkr, etc   }

     loop	loc_28		        { Loop if cx > 0                 }

 loc_30:

     sub	word ptr [Length],1
     sbb	word ptr [Length+2],0
     jc	        loc_31			{ Jump if carry Set              }
     or	        si,si			{ Zero ?                         }
     jnz	loc_27			{ Jump if not zero               }
     mov	si,es
     add	si,01000H
     mov	es,si
     xor	si,si			{ Zero register                  }
     jmp	loc_27

 loc_31:
     in	        al,61h			{ port 61h, 8255 port B, read    }
     and	al,0FCh
     out	61h,al			{ port 61h, 8255 B - spkr, etc   }
				        {  al = 0, disable parity        }
 loc_32:
     pop	si
     pop	di
     STI
   End;
End;

Const
    BASEPort  : Word = $03E0;{ 3B0 } { A kartya alap port cime    }
    BasePort1 : Word = $03E0+1;


Procedure PlayTomb(PT    : Pointer;
                   H     : Word;
                   Speed : Byte;
                   Loop  : Word);Assembler;
ASM
  CLI
  XOR     AH,AH
  MOV     CX,[Loop]
@3:
  PUSH    CX
  LES     DI,Pt
  MOV     CX,[H]
@1:
  MOV     DX,BasePort1  { Status }
  IN      AL,DX
  AND     AL,$80
  JZ      @1

  MOV     DX,BasePort    { Data   }
  IN      AL,DX
  XOR     AH,[Speed]
  JNZ     @1

  MOV     AL,ES:[DI]
  OUT     DX,AL
  INC     DI
  LOOP    @1

  POP     CX
  LOOP    @3

  STI
End;


Procedure PlaySound(Length     : LongInt;
                    Addr       : Pointer;
                    Frekvencia : Word);
Begin
  Sebesseg := Round((15625 / Frekvencia) * Speed);
  Case OutPutCard Of
    SPEAKER : PlayPcm(Sebesseg,Length,Addr,TRUE);
    MELIS   : Case Frekvencia Of
                22050 : PlayTomb(Addr,Length,0,1);
                11025 : PlayTomb(Addr,Length,1,1)
                End;
    Blaster : Begin
                SB_PLAY(Frekvencia);
                SB_ADDPUFFER(Addr,Length);
                While SB_DMAWORK=1 Do;
              End;
    End;
End;

Procedure Int8; Assembler;
Label Next,DSW;
Asm
      JMP   NEXT

DSW:  DW    0000

NEXT: PUSH  AX
      PUSH  BX
      PUSH  DS

      PUSH  CS
      POP   DS
      MOV   BX,OFFSET DSW
      MOV   AX,[BX]
      MOV   DS,AX
      INC   WW

      MOV   AL,$20
      OUT   $20,AL

      POP   DS
      POP   BX
      POP   AX

      IRET

End;

Procedure DupDup(Ezt:Pointer;H:Word;Szor:Word);Assembler;
Asm
  PUSH  DS
  PUSH  ES
  LDS   SI,[Ezt]
  LES   DI,[Ezt]
  ADD   DI,[H]
  CLD
  MOV   CX,[Szor]
  MOV   AX,[H]
  MUL   CX
  MOV   CX,AX
  REPZ  MOVSB

  POP   ES
  POP   DS
End;


Procedure InitSpeak;
Var Fej    : PcmLibFej;
    Ws     : String[76];
    LibDir : Array[0..MaxSzoveg] Of DirItem;
    VanMeg : LongInt;
    Bejott : Word;
Var Err : Integer;

Procedure LibInit;
Begin
  IOError := False;
  FileMode := 0;
  {$I-}
  Reset(FF,1);
  {$I+}
  IOError := IoResult <> 0;
  If Not IOError Then
    Begin
      {$I-}
      BlockRead(FF,Fej,SizeOf(Fej));
      {$I+}
      IOError := (IoResult <> 0) Or (Fej.Azon <> 'PCMLIB');
      If Not IOError Then
        Begin
          {$I-}
          Seek(FF,Fej.StartOfDir);
          IOERROR := (IoResult <> 0);
          BlockRead(FF,LibDir,Fej.DirHossz*SizeOf(DirItem));
          IOERROR := (IoResult <> 0) OR (IoError);
          {$I+}
          If Not IoError Then
            For Cikl := 0 To Fej.DirHossz-1 Do
              StPos[LibDir[Cikl].Szam] := LibDir[Cikl].Start;
        End;
    End;
  {$I+}
  FileMode := 2;
End;

Procedure BlasterInit;
Var S : String[40];
    P : Integer;
Begin
  S := GetEnv('BLASTER');
  If S <> '' Then
    Begin
      P := Pos('A',S);
      If P <> 0 Then
        SBIOAddr := Hex_Dec(Copy(S,P+1,3));
      P := Pos('I',S);
      If P <> 0 Then
        SBIRQ := Byte(S[P+1])-Byte('0');
      P := Pos('D',S);
      If P <> 0 Then
        SBDmaChan := Byte(S[P+1])-Byte('0');
      If SB_INIT(SBIOAddr,SBIRQ,SBDMAChan,NIL) = 0 Then
        OutPutCard := Blaster;

    End;
End;

Begin
  If SpeakPuff <> NIL Then
  Begin
    BlasterInit;

    {$I-}
    Ws := FontPath;

    WS := Ws + 'EKSZER.WFL';
    Assign(FF,Ws);

    LibInit;

    If VanWindows AND (OutPutCard = Speaker) Then
      EnabledSpeak := False
    Else
    Begin
      If IOError Then EnabledSpeak := False
      Else
      If OutPutCard = Speaker Then
      Begin
        AnyagBetoltes(0,0);

        Sebesseg := Trunc((15625 / Frekvencia) * 40.0);

        Asm
            MOV   BX,OFFSET INT8
            MOV   AX,SEG @DATA
            MOV   CS:[BX+2],AX

            PUSH  DS
            PUSH  ES

            PUSH  DS
            POP   ES
            XOR   AX,AX
            MOV   DS,AX
            MOV   SI,4*8
            MOV   DI,OFFSET OLDINT8
            MOV   CX,02
            CLD
            REPZ  MOVSW

            PUSH  DS
            POP   ES

            CLI
            MOV   DI,4*8
            MOV   AX,OFFSET INT8
            STOSW
            MOV   AX,CS
            STOSW

            POP   ES
            POP   DS

        End;

        TimeDiv   := 1193180 Div 1725;  { Herz }

        Port[$43] := 54;

        Port[$40] := Lo(TimeDiv);    { Set timer to 1/s }
        Port[$40] := Hi(TimeDiv);

        Asm
            IN    AL,$21
            MOV   INTREG,AL
            MOV   AL,254
            OUT   $21,AL
            STI
        End;

        WW := 00;

        PlayPcm(Sebesseg,TombASize,SpeakPuff,False);
        Speed := (26800 DIV WW)+1;

        Asm
            MOV   AL,INTREG
            OUT   $21,AL
            STI
        End;


        Port[$43] := 54;

        Port[$40] := $00;    { Set timer to 18/s }
        Port[$40] := $00;

        Asm
            PUSH  DS
            PUSH  ES

            XOR   AX,AX
            MOV   ES,AX
            MOV   DI,4*8
            MOV   SI,OFFSET OLDINT8
            MOV   CX,02
            CLD
            CLI
            REPZ  MOVSW
            STI

            POP   ES
            POP   DS
        End;
        {
        Writeln(WW);
        Writeln(Speed);
        If ReadKEy = ' ' Then;
        }

      End; { If megvan a FUTTY }

    End;

    { Most jon a Pofalib }

    If (OutPutCard <> Speaker) OR (EnabledSpeak) Then
    Begin
      Ws := FontPath;
      WS := Ws + 'POFALIB.WFL';
      Assign(F2,Ws);
      FileMode := 0;
      {$I-}
      Reset(F2,1);
      {$I+}
      If IoResult = 0 Then
        Begin
          VanMeg := FileSize(F2);
          If _INIT_MEM((VanMeg+1023) Div 1024) = 0 Then
            Begin
              {
              Write('Magyar hangok betoltese...');
              }
              While VanMeg <> 0 Do
                Begin
                  BlockRead(F2,SpeakPuff^,SpeakPuffSize,Bejott);
                  _Csomag_Fel(((Bejott+1) Div 2)*2,SpeakPuff);
                  Dec(VanMeg,Bejott);
                End;
              Close(F2);
              {
              Write('OK. Inicializalas ...');
              }
              Err := _INIT_LIB;

              If Err = 0 Then
                VanWLIB := True
              Else
                Error(20,'POFALIB.WFL nem megfelelì');
            End
          Else
            Begin
              Error(20,'Nincs elÇg XMS a hang kînyvt†r betîltÇsÇhez');
              Close(F2);
            End;
        End
      Else
        Error(20,'Nincs meg a POFALIB.WFL file');

    End;

    FileMode := 2;

  End;
End;  { InitSpeak }

Procedure WflLezar;
Begin
  If VanWLiB Then
    _Lezar;
  If OutPutCard = Blaster Then
    SB_Close;
End;

Procedure SaySentence(Var Mondat    : MondatType;
                          Count     : Word;
                      Var AzKodTomb : PofaDatType);
Const MaxSzo = 300;

Var Cik : Integer;
    Bc  : Integer;
    I   : Integer;
    C   : Char;
    SzamSt,
    Ws  : String;
    CalcResultSave      : String;
    CalcAzazResultSave  : String;
    SzammalSave : String[80];
    BetuvelSave : String[128];
    R           : Real;
    Code        : Integer;
    Temp        : Array[0..8000] Of Byte;
    Temp2       : Array[0..8000] Of Byte;
    Wp,H,Dc,Lbc    : Word;
    EnnyiSzer   : Word;
    UjMondat    : MondatType;
    iaDiadok    : MondatWord;
    Poz,Maganok,
    HangzoHossz : Byte;
    UjCount     : Integer;

    Szo,SzoK    : Integer;
    SzoTomb     : Array[1..MaxSzo] Of Byte;
    ElozoSzeletke,
    Szeletke    : Integer;
    TerminateChar : Char;
    OsszesMH    : Integer;
    MHCik       : Integer;
    ElsoSzo     : String[129];
    PPP         : Integer;
    LastMagassag: Real;

Type
  KerdesTipus = (Sima,Kerdoszavas);

Const
  KerdesTip : KerdesTipus = Sima;

  Kerdoszok : Array[0..500] Of Char =
  ' MIKOR MINEK MIVEL HOVA HOV[ HONNAN HOL MERRE KIVEL KINEK KI\RT '+
  'MIT KIT HOL MIRE MIJEN MI\RT MEDDIG METT]]L H[a MEaaI H[abOR '+
  'MIHEZ KIHEZ MIBEN HOGY HOGYAN MEKKORA MERREFEL\ MERREFELE '+
  'MIKORRA MIKORTOOL KIBEN KIT]]L MEJIK MIB]]L MIR]]L '+
  'KI MI MIB]]L KIB]]L KIN\L MIN\L '+#0;


MaxMagas : Real = 1.3;
MinMagas : Real = 0.9;

MaxHangzok = 74;

MaganSet : Set Of Char = ['A','E','I','O','U','[','\',']','^'];
MaganSzeletek : Set Of Byte = [1,2,7,8,13,20,21,29,30];

Hangzok  : Array[1..MaxHangzok] Of String[4] =
(
'GYSZ','SZZS','NDNY','Z TY','DZSK','BB P',

'GYJ','TSZ','DSZ','GYS','ZSZ','CCS','SGY','GSZ','DZT','NTY','SZZ','NTJ','NDJ',
'GGY','NNY','SSZ','TTY','ZZS','LLY','TCS','LLJ','BSZ','KZS','GCS','ZSK','CSZ',
'DTS',

'CS','GY','NY','SZ','TY','ZS','LY','ZT','BS','TG','KD','SD','GF',
'TS','DS','TJ','LJ','DJ','NJ','GT','PD','DP','SB','PZ','GS','GC','ZK',

'W','X','Q','Y','è','ê','ô','ö','ï','ò','ß','ó','ç',' '
);

UjHangzok  : Array[1..MaxHangzok] Of String[2] =
(
'`b','Zd','aa','bc','_K','PP',

'``','CC','CC','__','bb','__','d`','Kb','CT','ac','ZZ','ac','a`',
'``','aa','bb','cc','dd','JJ','__','JJ','Pb','Gd','K_','SK','CC',
'__',

'_','`','a','b','c','d','J','bT','PS','DG','GD','dD','KF',
'__','TS','cc','JJ','``','aa','KT','BD','TP','dB','BZ','KS','KC','bK',

'V','Kb','KU','J','[','\',']','^','OO','^^',']]','UU','II','e'
                {,'è','ê','ô','ö','ïï','òò','ßß','óó','çç',' '}

);


Function LoopSzam(Frekv:Word;
                  LoopMSec:Word;
                  Hossz:LongInt):Longint;
Var Loop : LongInt;
Begin
  Loop := Trunc((LoopMSec/110)*Frekv/Hossz);
  If Loop = 0 Then Loop := 1;
  LoopSzam := Loop;
End;


Procedure Diadok(Var azSentence: MondatType; iSentenceLen: Word);

Var
	a,b,c,d: Integer;
	iDiadNum, i      : Integer;

Begin
	c := Byte('A');
	d := ((SPAC+1)-Byte('A'));

	for i := 0 To iSentenceLen-2 Do
	Begin
	  a := (Byte(azSentence[i]) - c) * d;
	  b := (Byte(azSentence[i+1]) - c );
	  iaDiadok[i] := a+b;
	End;

	iaDiadok[iSentenceLen-1] := $FFFF;

End; { Diadok }

Procedure AddNormalGorbe;
Begin
  LastMagassag :=
    1.0*MinNormal+1.0*((MaxNormal-MinNormal)*(Maganok/SzoTomb[SzoK]))+
    SzoK*(MondatEses/Szo);
  AddPitch(@Temp2,@Temp,H,H,LAstMagassag);
End;

Procedure AddPontGorbe;
Begin
  LastMagassag :=1.0*MinPont+1.0*((MaxPont-MinPont)*(Maganok/SzoTomb[SzoK]));
  AddPitch(@Temp2,@Temp,H,H,LastMagassag)
End;

Procedure AddVesszoGorbe;

Begin
  LastMagassag := 1.0*MaxVesszo-1.0*((MaxVesszo-MinVesszo)*(Maganok/SzoTomb[SzoK]));
  AddPitch(@Temp2,@Temp,H,H,LastMagassag)
End;


Const Pont : String[6] = ' PONT ';

Procedure ClearDoubleSpaces;
Var PPP : Pchar;
    Index : Word;
Begin
  PPP := StrPos(@Mondat,'  ');
  While PPP <> NIL Do
    Begin
      Index := Ofs(PPP^)-Ofs(Mondat);
      Move(Mondat[Index+1],Mondat[Index],Count-Index);
      Dec(Count);
      PPP := StrPos(@Mondat,'  ');
    End;
End;


Begin {SaySentence}
  If Count > 2 Then
  Begin

    TerminateChar := Mondat[Count-1];
    Mondat[Count] := ' ';
    Inc(Count);
    Mondat[Count] := #0;

    ClearDoubleSpaces;


    Cik := 0;
    UjCount := 0;
    SzamSt := '';

    CalcResultSave      := CalcResult;
    CalcAzazResultSave  := CalcAzazResult;
    SzammalSave := Szammal;
    BetuvelSave := Betuvel;

    Szammal := '';
    Betuvel := '';

    Repeat
      If Mondat[Cik] In ['0'..'9',',','.'] Then
      Begin
        If NOT(Mondat[Cik] In [',','.']) Then SzamSt := SzamSt + Mondat[Cik];

        If Mondat[Cik] <> '.' Then
        Begin
          Move(Mondat[Cik+1],Mondat[Cik],Count-Cik);
          Dec(Count);
          Dec(Cik);
        End
        Else
        If SzamSt <> '' Then
        Begin
          Move(Mondat[Cik+1],Mondat[Cik+Length(Pont)],Count-Cik);
          Inc(Count,Length(Pont)-1);
          Move(Pont[1],Mondat[Cik],Length(Pont));
          Dec(Cik);
        End;
      End
      Else
      If SzamSt <> '' Then
      Begin

        R := 0.0;
        Val(SzamSt,R,Code);
        CreateCalcResult(R);
        UpperCase(CalcAzazResult);
        For Bc := 1 To Length(CalcAzazResult) Do
        Begin
          If CalcAzazResult[Bc] = '/' Then CalcAzazResult[Bc] := ' ';
          Poz := Pos(CalcAzazResult[Bc],MagyUpcSt[0]);
          If Poz > 0 Then CalcAzazResult[Bc] := MagyUpcSt[1][Poz];
        End;
        EkSzer_To_ASCII(CalcAzazResult);
        Move(Mondat[Cik],Mondat[Cik+Length(CalcAzazResult)],Count-Cik);
        Inc(Count,Length(CalcAzazResult));
        Move(CalcAzazResult[1],Mondat[Cik],Length(CalcAzazResult));
        Inc(Cik,Length(CalcAzazResult)-1);
        SzamSt := '';
      End;

      Inc(Cik);

    Until Cik >= Count;

    CalcResult      := CalcResultSave;
    CalcAzazResult  := CalcAzazResultSave;

    Szammal := SzammalSave;
    Betuvel := BetuvelSave;

    Cik := 0;
    Repeat
      Bc := 0;

      HangzoHossz := 1;

      Move(Mondat[Cik],Ws[1],Length(Hangzok[1]));

      Repeat
        Inc(Bc);
        Ws[0] := Char(Length(Hangzok[Bc]));
      Until (Bc = MaxHangzok) OR (Ws = Hangzok[Bc]);

      If Ws = Hangzok[Bc] Then
      Begin
        Ws := UjHangzok[Bc];
        HangzoHossz := Length(Hangzok[Bc]);
      End
      Else
        Ws := Mondat[Cik];

      Move(Ws[1],UjMondat[UjCount],Length(Ws));
      Inc(UjCount,(Length(Ws)));

      {
      For I := UjCount-Length(Ws) To UjCount-1 Do
        If UjMondat[I] = ' ' Then WriteLn(LST)
                             Else Write(LST,UjMondat[I]);
      }

      If (Length(Ws) = 1) AND
         NOT (UjMondat[UjCount-1] In ['A'..'e'])
      Then
        Dec(UjCount);

      Inc(Cik,HangzoHossz);

    Until Cik >= Count;


    UjMondat[UjCount] := #0;
    Szo := 1;
    Dc := 0;

    SzoTomb[Szo] := 0;
    OsszesMH := 0;
    ElsoSzo  := '';

    While (Dc < UjCount) Do
    Begin
      C := UjMondat[Dc];
      If (Szo=1) And (C <> 'e') Then
        ElsoSzo := ElsoSzo+C;
      If C In MaganSet  Then
      Begin
        Inc(SzoTomb[Szo]);
        Inc(OsszesMH);
        While (Dc < UjCount) AND (UjMondat[Dc+1] = C) Do Inc(Dc);
      End;
      Inc(Dc);
      If UjMondat[Dc] = 'e' Then
      Begin
        If Szo = 1 Then
          Begin
            ElsoSzo := ' '+ElsoSzo+' '+#0;
            KerdesTip := KerdesTipus(StrPos(@Kerdoszok,@ElsoSzo[1]) <> NIL);
          End;
        Inc(Szo);
        SzoTomb[Szo] := 0;
      End;
    End;
    Dec(Szo);

    Diadok(UjMondat,UjCount);

    Dc := 0;

    SzoK := 1;
    Maganok := 0;
    MHCIK   := 0;
    LastMagassag := 1;
    { Most jon a kimondas }


    Repeat

      Wp := 0;
      Szeletke := 9999;
      Repeat
        BreakVolt := False;
        Lbc := 0;
        While (Lbc <= 2 ) AND (AzKodTomb[IaDiadok[Dc]][Lbc].IRepeat <> $FF) Do
        Begin
          ElozoSzeletke := Szeletke;
          Szeletke := AzKodTomb[IaDiadok[Dc]][Lbc].AzKod;
          H := _Kibontas(Szeletke,@Temp,@Temp2);
          If H > 0 Then
            Begin
              Ennyiszer := AzKodTomb[IaDiadok[Dc]][Lbc].IRepeat;
              If Ennyiszer In [0..1] Then
                Begin
                  Ennyiszer := 1;
                  Move(Temp2,Temp,H)
                End
              else
                Begin
                  If (Szeletke In MaganSzeletek) And
                     (SzoTomb[SzoK] > 0)
                    Then
                    Begin

                      If (Szeletke <> ElozoSzeletke) Then
                        Begin
                          Inc(Maganok);
                          Inc(MhCik);
                        End;
                      Case TerminateChar Of
                        '.': Begin
                               If SzoK = Szo Then
                                  AddPontGorbe
                                Else
                                  AddNormalGorbe
                             End;
                        ',': Begin
                               If SzoK = Szo Then
                                  AddVesszoGorbe
                                Else
                                  AddNormalGorbe
                             End;
                        '?': Case KerdesTip Of
                             Kerdoszavas:
                               Begin
                                 If MHCik=1 Then
                                    AddPitch(@Temp2,@Temp,H,H,KKerdEleje)
                                  Else
                                    AddPitch(@Temp2,@Temp,H,H,
                                    1.0*MaxKKerd-1.0*((MaxKKerd-MinKKerd)*(MHCik/(OsszesMH-1))));
                               End;
                             Sima:
                               If (MHCik=OsszesMh) Then
                                  AddPitch(@Temp2,@Temp,H,H,SKerdVege)
                                Else
                                  AddPitch(@Temp2,@Temp,H,H,
                                  1.0*MaxSKerd-1.0*((MaxSKerd-MinSKerd)*(MHCik/(OsszesMH-1))));
                             End  { Case Kerdestip }
                        Else  { Egyik sem }
                          AddNormalGorbe
                      End; { CASE }
                      If Maganok In [0..1] Then
                        Hangositas(@Temp,H,Hangsuly);
                    End
                  Else
                    AddPitch(@Temp2,@Temp,H,H,LastMagassag);
                  Ennyiszer := LoopSzam(PofaFrekv,
                                        Ennyiszer,
                                        H);
                End;
              If (Longint(Wp) + H*Ennyiszer) > SizeOf(SpeakPuff^) Then
                Begin
                  PlaySound(Wp,SpeakPuff,22050);
                  {Writeln(lst,'Puffer2 :',Wp);}
                  Wp := 0;
                End;

              Move(Temp,SpeakPuff^[Wp],H);
              If Ennyiszer <> 1 Then
                DupDup(@SpeakPuff^[Wp],H,Ennyiszer-1);
              Inc(Wp,H*Ennyiszer);
            End;
          Inc(Lbc);
        End;

        Inc(Dc);

        BreakVolt := Break;

        If UjMondat[Dc] = 'e' Then
        Begin
          {SOUND(300);
          DELAY(1000);
          NOSOUND;}
          Inc(SzoK);
          Maganok := 0;
          LastMagassag := 1;
        End;

      Until BreakVolt OR (UjMondat[Dc] = 'e'{space}) OR (IaDiadok[Dc] = $FFFF);

      If NOT BreakVolt Then
        Begin
          PlaySound(Wp,SpeakPuff,22050);
          {Writeln(lst,'Puffer1 :',Wp);}
        End;
    Until BreakVolt OR (IaDiadok[Dc] = $FFFF);

  End; {If Count > 1 }

End;


Procedure Speak(Num: Integer);
Var Cik : Word;
Begin
  If (SpeakPuff <> NIL) AND (EnabledSpeak) Then
  Begin
    AnyagBetoltes(Num,0);
    If NOT IOError Then
      PlaySound(TombASize,SpeakPuff,Frekvencia);
  End;
  IOError := False;
End;

Procedure Speak2(Num1,Num2: Integer);
Var Cik : Word;
    Siz1 : Word;
Begin
  If (SpeakPuff <> NIL) AND (EnabledSpeak) Then
  Begin
    AnyagBetoltes(Num1,0);
    If Not(IOError) Then
      Begin
        Siz1 := TombASize;
        AnyagBetoltes(Num2,Siz1);
        Inc(TombASize,Siz1);
      End
    Else IOError := True;
    If NOT IOError Then
      PlaySound(TombASize,SpeakPuff,Frekvencia);
  End;
  IoError := False;
End;

Procedure SetHangero;
Var Cik : Word;
Begin
  For Cik := 0 To 256 Do
    T3[Cik] := Trunc(T2[Cik] * (Volume/50));
End;

Procedure Init_Felolvas(Var AzKodTomb : PofaDatType);

Var
    F        : Text;
    SPoz,
    Poz      : Byte;
    Code     : Integer;
    BelsoCount,
    WIRepeat  : Byte;
    WAzKod,
    AzKodCount: Word;
    S        : String;
    DFn,
    Ws       : String[16];

Begin

  InitHangSuly;

  DFn := DiadFileName;
  If FontPath[Length(FontPath)] <> '\' Then DFn := '\'+DFn;
  Assign(F,FontPath+DFn);
  {$I-}
  Reset(F);
  {$I+}
  If IOResult = 0 Then
  Begin
    AzKodCount := 0;
    While (NOT Eof(F)) AND (AzKodCount <= MaxDiad) Do
    Begin

      For Cikl := 0 To 2 Do
      Begin
        AzKodTomb[AzKodCount,Cikl].IRepeat := $FF;
        AzKodTomb[AzKodCount,Cikl].AzKod   := $FFFF;
      End;

      BelsoCount := 0;
      ReadLn(F,S);
      Poz := Pos(';',S);

      If Poz > 0 Then
      Begin
        Delete(S,1,Poz);

        Poz := Pos(',',S);
        If Poz = 0 Then Poz := Length(S)+1;

        While S <> '' Do
        Begin
          Ws := Copy(S,1,Poz-1);
          Spoz := Pos('*',Ws);
          If Spoz > 0 Then
          Begin
            Val(Copy(Ws,1,SPoz-1),WIRepeat,Code);
            Val(Copy(Ws,SPoz+1,(Length(Ws)-SPoz)),WAzKod,Code);
          End
          Else
          Begin
            WIRepeat := 1;
            Val(Copy(Ws,1,Poz-1),WAzKod,Code);
          End;

          AzKodTomb[AzKodCount,BelsoCount].IRepeat := WIRepeat;
          AzKodTomb[AzKodCount,BelsoCount].AzKod   := WAzKod;

          Inc(BelsoCount);
          Delete(S,1,Poz);
          Poz := Pos(',',S);
          If Poz = 0 Then Poz := Length(S)+1;

        End;

      End; { van ';' }

      Inc(AzKodCount);

    End;
    Close(F);
    {
    For Cik := 544 To 545 Do
    Begin
      Write(LST,Cik:4,'. ');
      For BelsoCount := 0 To 2 Do
        If AzKodTomb[Cik,BelsoCount].IRepeat <> $FF Then
      Begin
        Write(LST,' ');
        If AzKodTomb[Cik,BelsoCount].IRepeat <> 1 Then
        Begin
          Write(LST,AzKodTomb[Cik,BelsoCount].IRepeat);
          Write(LST,'*');
        End;
        Write(LST,AzKodTomb[Cik,BelsoCount].AzKod);
      End;
      WriteLn(LST);
    End;
    }
  End
  Else Error(3,': '+FontPath+DFn);

End;

Begin
End.
