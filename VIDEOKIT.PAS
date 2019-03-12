Unit VideoKit;

Interface

Uses INITKIT,Dos;


{********************** Text screen modules *********************}

PROCEDURE SET_STRING(VAR S {: St160 }; Y,X:INTEGER);
PROCEDURE GET_STRING(VAR S {: St160 }; Y,X:INTEGER);
PROCEDURE DISPLAY(S:ST80; Y,X:INTEGER);
PROCEDURE DISPCH(CH:CHAR; Y,X:INTEGER);
PROCEDURE ATTRIBCH(ATTRIB:BYTE; Y,X:INTEGER);
PROCEDURE ATTRIBUTE(Y1,X1,Y2,X2:INTEGER; ATTRIB:BYTE);

Procedure CurOn;
Procedure BigCur;
Procedure CurOff;

Procedure Set_Vmode(X:Boolean);
Procedure Set_StrStep(X:INTEGER);
Procedure Set_ScrStep(X:INTEGER);
Procedure Set_StrLen(X:Byte);

Implementation

{$L DISPKIT}


PROCEDURE SET_STRING;  External;
PROCEDURE GET_STRING;  External;
PROCEDURE DISPLAY;     External;
PROCEDURE DISPCH;      External;
PROCEDURE ATTRIBCH;    External;
PROCEDURE ATTRIBUTE;   External;

PROCEDURE VERT_MODE;   External;  { Boolean valtozo }
Procedure String_step; External;  { Integer valtozo }
Procedure Screen_step; External;  { Integer valtozo }
Procedure Str_Hossz;   External;  { Byte valtozo    }

Var   xx : Boolean;

Const CurEnd : Array[1..3] Of Integer = (7,7,13);

Procedure Set_Grm(Var X:Byte);
Begin
  If mem[$40:$49] = 7 Then
    x := 2
  Else
    x := 1
End;

Procedure CurOn;
Var GrMode : Byte;
Begin
  Set_Grm(GrMode);
  Register.ch := CurEnd[GrMode]-1;
  Register.cl := CurEnd[GrMode];
  Register.ah := 1;
  Intr($10,Register);
End;

Procedure BigCur;
Var GrMode : Byte;
Begin
  Set_Grm(GrMode);
  Register.ch := 0;
  Register.cl := CurEnd[GrMode];
  Register.ah := 1;
  Intr($10,Register);
End;

Procedure CurOff;
Var GrMode : Byte;
Begin
  Set_Grm(GrMode);
  Register.cl := 0;
  Register.ch := CurEnd[GrMode]+2;
  Register.ah := 1;
  Intr($10,Register);
End;

Procedure Set_Vmode;
Var PP : ^Boolean;
Begin
  PP  := @VERT_MODE;
  PP^ := X
End;

Procedure Set_ScrStep;
Var PP : ^Integer;
Begin
  PP  := @Screen_Step;
  PP^ := X
End;

Procedure Set_StrStep;
Var PP : ^Integer;
Begin
  PP  := @String_Step;
  PP^ := X
End;

Procedure Set_StrLen;
Var PP : ^Byte;
Begin
  PP  := @Str_Hossz;
  PP^ := X
End;


End.