Unit GROVR;

{$O+}

Interface

Procedure LoadEga;
Procedure LoadCga;
Procedure LoadHerc;

Implementation
Uses Windowm;

Procedure Page_End;External;
Procedure EzAVege;External;
Procedure Sortab_Offs;External;


Procedure LoadEga;

{$L EGA7.OBJ}

Var Pt1,Pt2 : Pointer;
    Mennyi  : Word;
Begin
  Pt1 := @Page_End;
  Pt2 := @EzAVege;
  Mennyi := Ofs(Pt2^)-Ofs(Pt1^);
  Move(Pt1^,VideoCim^,Mennyi)
End;

Procedure LoadCga;

{$L CGA7.OBJ}

Var Pt1,Pt2 : Pointer;
    Mennyi  : Word;
Begin
  Pt1 := @Page_End;
  Pt2 := @EzAVege;
  Mennyi := Ofs(Pt2^)-Ofs(Pt1^);
  Move(Pt1^,VideoCim^,Mennyi)
End;

Procedure LoadHerc;

{$L HERC7.OBJ}

Var Pt1,Pt2 : Pointer;
    Mennyi  : Word;
Begin
  Pt1 := @Page_End;
  Pt2 := @EzAVege;
  Mennyi := Ofs(Pt2^)-Ofs(Pt1^);
  Move(Pt1^,VideoCim^,Mennyi)
End;

End.