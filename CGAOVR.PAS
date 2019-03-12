UNIT CGAOVR;

{$O+}

Interface

Procedure LoadCga;

Implementation

Uses Windowm;

procedure Page_End;          External;
Procedure EzAVege;           External;

{$L CGA7.OBJ}

Procedure LoadCga;

Var Pt1,Pt2 : ^Pointer;
    Mennyi  : Word;

Begin
  Pt1 := @Page_End;                  { Ez meg csak az Overlay ugrotabla }
  Pt1 := Ptr(Seg(Pt1^),Ofs(Pt1^)+1); { A rutin cime az ugrotablaban     }
  Pt2 := @EzAVege;                   { Ugrotabla                        }
  Pt2 := Ptr(Seg(Pt2^),Ofs(Pt2^)+1); { Rutin cime                       }
  Mennyi := Ofs(Pt2^^)-Ofs(Pt1^^);   { Ennyit mozgatunk                 }
  Move(Pt1^^,VideoCim^,Mennyi)       { Attoltjuk                        }
End;

End.