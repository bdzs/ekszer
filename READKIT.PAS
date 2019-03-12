Unit ReadKit;

Interface

Uses DOS;

Var FErr   : Boolean;
    Handle : Word;
    IOError: Word;

Procedure OpenRead(Fn:String);
Procedure CloseRead(Hand:Word);
Procedure SeekRead(Hand:Word; C:Word; D: Word);
Procedure ReadRead(Hand:Word; Var Buf; Db:Word);
Function  FileSizeRead(Hand:Word): LongInt;

Var Tfn   : String[76];
    Tfb   : Word;
    Tfl   : LongInt;
    Tfs   : String[40];

Implementation
Var
    Regs  : Registers;

Procedure OpenRead(Fn:String);
Begin
  Fn[Length(Fn)+1] := #0;

  Regs.AH := $3D;
  Regs.DS := Seg(Fn);
  Regs.DX := Ofs(Fn)+1;
  Regs.AL := 32; { 00100000 Deny Write, Read Only Access }
  MsDos(Regs);
  FErr := ((Regs.Flags AND Fcarry) <> 0);
  If NOT FErr Then Handle := Regs.AX;
  IOError := Byte(FErr) * Regs.AX;
End;

Procedure CloseRead(Hand:Word);
Begin
  Regs.BX := Hand;
  Regs.AH := $3E;
  MsDos(Regs);
  FErr := ((Regs.Flags AND Fcarry) <> 0);
  IOError := Byte(FErr) * Regs.AX;
End;


Procedure SeekRead(Hand:Word; C:Word; D: Word);
Begin
  Regs.BX := Hand;
  Regs.AX := $4200;
  Regs.CX := C;
  Regs.DX := D;
  MsDos(Regs);
  FErr := ((Regs.Flags AND Fcarry) <> 0);
  IOError := Byte(FErr) * Regs.AX;
End;

Function  FileSizeRead(Hand:Word): LongInt;
Var ActPoz : LongInt;
    EndPoz : LongInt;
Begin

  EndPoz := -1;

  Regs.BX := Hand;
  Regs.AX := $4201; { Relativ seek az aktu lis pozici¢hoz k‚pest }
  Regs.CX := 0;
  Regs.DX := 0;
  MsDos(Regs);
  FErr := ((Regs.Flags AND Fcarry) <> 0);

  If NOT FErr Then
  Begin

    ActPoz := LongInt(Regs.DX) SHL 16 + Regs.AX;

    Regs.BX := Hand;
    Regs.AX := $4202; { Relativ seek a file v‚ge pozici¢hoz k‚pest }
    Regs.CX := 0;
    Regs.DX := 0;
    MsDos(Regs);
    FErr := ((Regs.Flags AND Fcarry) <> 0);

    If NOT FErr Then
    Begin
      EndPoz := LongInt(Regs.DX) SHL 16 + Regs.AX;
      Regs.CX := Word(ActPoz) SHR 16;
      Regs.DX := Word(ActPoz) AND $FFFF;
      SeekRead(Handle,Regs.CX,Regs.DX);
    End;

  End;

  IOError := Byte(FErr) * Regs.AX;

  FileSizeRead := EndPoz;

End;

Procedure ReadRead(Hand:Word; Var Buf; Db:Word);
Begin
  Regs.BX := Hand;
  Regs.AH := $3F;
  Regs.CX := Db;
  Regs.DS := Seg(Buf);
  Regs.DX := Ofs(Buf);
  MsDos(Regs);
  FErr := ((Regs.Flags AND Fcarry) <> 0);
  IOError := Byte(FErr) * Regs.AX;
End;

Begin
End.
