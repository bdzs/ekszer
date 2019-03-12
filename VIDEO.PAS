Unit Video;

Interface

(*********************** Graphic modules *************************)

procedure Sys_write    (X,Y,CH,fontoff,sortaboff,Imageofs : WORD);
procedure Sys_writeO   (X,Y,CH,fontoff,sortaboff,Imageofs : WORD);
procedure sc_up        (y1,y2,CH,fontoff,sortabof,Imageofs: WORD);
procedure sc_dn        (y1,y2,CH,fontoff,sortabof,Imageofs: WORD);
procedure disp_kar     (X,Y,CH,fontoff,sortaboff,Imageofsf: WORD);
procedure inv_kar      (X,Y,CH,fontoff,sortaboff,Imageofsf: WORD);
procedure inv_line     (y,x1,x2,fontoff,sortaboff,Imageofs: WORD);
procedure disp_line    (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure fej_tab      (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure disp_page    (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure Page_Stat    (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure Line_Stat    (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure Line_Ptr     (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
Function  Ures_e       (x,y,ch,fontoff,sortaboff,Imageofs : WORD): Boolean;
procedure Scroll_Left  (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure Scroll_Right (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
Function  Sor_Hossz    (x,y,ch,fontoff,sortaboff,Imageofs : WORD): Integer;
procedure Page_End     (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure Ablak        (x,y,ch,fontoff,sortaboff,Imageofs : WORD);
procedure FelSor_IdeOda(Db,y,PuffOff,Puffseg,SotabOffs,Irany : WORD);
procedure FelSor_IdeOdaW(Xpos,szeles,Db,y,PuffOff,Puffseg,SotabOffs,Irany : WORD);
Procedure ScrollR(X:Word);
Procedure ScrollL(X:Word);

{************************ Kereso rutin *************************}

Function  Search(Ptomb_Seg,Xpos,StrOfs,TombOfs,Tol,Ig,HeapSeg,Upc,Mode:WORD):Longint;
Function  BSearch(Ptomb_seg,Xpos,StrOfs,TombOfs,Tol,Ig,HeapSeg,Upc,Mode:WORD):Longint;
Procedure Fontok(Ptomb_Seg,Cica,TombOfs,Tol,Ig,HeapSeg,cica1,cica2,cica3:WORD);
Procedure Sort(TombOffs,TombSeg,Darab,Hossz : Word);
Function  UpperP(C:Char):Char;

Procedure SetOffs;
Procedure SetWideP;
Procedure SetXoffset(X:Byte);

Procedure Image_seg;
Procedure Image_Offs;
Procedure Font_Offs;
Procedure Sortab_Offs;

{$IFDEF DEBUG}
Procedure WriTest(St:String;Var Inte:Word);
{$ENDIF}
{
Procedure EScrLeft(X:Word);
Procedure EScrRight(X:Word);
}

{********************** Text screen modules *********************}

TYPE ST80  = STRING[80];
     ST160 = STRING[160];
     ST255 = STRING[255];

PROCEDURE SET_STRING(VAR S:ST160; Y,X:INTEGER);
PROCEDURE GET_STRING(VAR S:ST160; Y,X:INTEGER);
PROCEDURE DISPLAY(S:ST80; Y,X:INTEGER);
PROCEDURE DISPCH(CH:CHAR; Y,X:INTEGER);
PROCEDURE ATTRIBCH(ATTRIB:BYTE; Y,X:INTEGER);
PROCEDURE ATTRIBUTE(Y1,X1,Y2,X2:INTEGER; ATTRIB:BYTE);
Procedure ChangeLineFont(Var Cim; Kezd,Vege,OldFont,Font : Word);
procedure inv_lineI(y,x1,x2,fontoff,sortaboff,Imageofs: WORD);

{$IFDEF SECRET}
Procedure kodol(Pcim   : Pointer;
                Phossz : Word;
                Bcim   : Pointer;
                Func   : Word);
{$ENDIF}


{Procedure Set_Int_A0;}

{Procedure Int9_KiFuz;}


Procedure Kiertekel(VarNum : Byte; Var Condi,VarSt,Variables,Result;
                    Var HibaKod: Byte; Var HibaPoz: Byte);

Var
  XImage_seg  : ^Word;
  XImage_Offs : ^Word;
  XFont_Offs  : ^Word;
  XSortab_Offs: ^Word;


Type AsmTomb =
Record
  WBetuk       : Word; { dw 80 ; sor szelessege karakterekben }
  WBetukXketto : Word; { dw 160 ; 2-szeres sorszelesseg       }
  WKezdoPos    : Word; { dw 000 ; kiiras kezdopozicioja (nem ketszeres) }
  W75          : Word; { dw 75  ; konstansok helyett }
  W76          : Word; { dw 76  ; }
  W77          : Word; { dw 77  ; }
  W78          : Word; { dw 78  ; }
  W79          : Word; { dw 79  ; }
  W80          : Word; { dw 80  ; }
  Disp78       : Word; { Dw 78    }
End;

Var Arr : ^AsmTomb;

Implementation

Uses Windowm,
{$IFDEF DEBUG}
inputcdw,
printer,
{$ENDIF}
Heapcdw;

{$L VGA7} { Sz‚les sorok ! }

{$IFDEF CHEM}
{$L MENT_CDW}
{$ENDIF}

{$L KIERT}
{$L MODEMBUF.OBJ}

{$IFDEF SECRET}
  {$IFDEF PVOP}
  {$L KOD_PVOP.OBJ}
  {$ELSE}
  {$L KODOL.OBJ}
  {$ENDIF}
{$ENDIF}

procedure int_0ffh;     external;
procedure Comm_Data;    external;

Procedure Kiertekel;    External;

procedure Sys_writeO;   External;
procedure sc_up;        External;
procedure sc_dn;        External;
procedure disp_kar;     External;
procedure inv_kar;      External;
procedure inv_line;     External;
procedure disp_line;    External;
procedure fej_tab;      External;
procedure disp_page;    External;
procedure Page_Stat;    External;
procedure Line_Stat;    External;
procedure Line_Ptr;     External;
Function  Ures_e;       External;
procedure Scroll_Left;  External;
procedure Scroll_Right; External;
Function  Sor_Hossz;    External;
procedure Page_End;     External;
procedure Ablak;        External;
procedure FelSor_IdeOda;External;
procedure FelSor_IdeOdaW;External;
Procedure ScrollR(X:Word);External;
Procedure ScrollL(X:Word);External;

Procedure Image_seg;    External;
Procedure Image_Offs;   External;
Procedure Font_Offs;    External;
Procedure Sortab_Offs;  External;
Procedure EzAVege;      External;

Procedure Fontok;       External;
Function Search;        External;
Function BSearch;       External;
procedure sort;         External;

{$L Search}

{$L DISPLAY}

PROCEDURE SET_STRING;     External;
PROCEDURE GET_STRING;     External;
PROCEDURE DISPLAY;        External;
PROCEDURE DISPCH;         External;
PROCEDURE ATTRIBCH;       External;
PROCEDURE ATTRIBUTE;      External;
Procedure ChangeLineFont; External;


{Procedure Set_Int_A0;     External;}
{Procedure Int9_kifuz;     External;}

{$IFDEF SECRET}

(*
Procedure Kodol(
                Pcim   : Pointer;
                Phossz : Word;
                Bcim   : Pointer;
                Func   : Word);

Var
    Cikl,
    Cikl2 : Integer;
    pc,
    bc   : ^Bufft;
    sc   : St80;
    NK   : Word;

Begin
  pc := Pcim;
  bc := bcim;

  Case Func Of
    0,1 : Begin  { Kodolas, Dekodolas }
            NK := ((Phossz+1023) Div 1024)*12;

            If Func = 0 Then
              For Cikl := 1 To Nk Do
                pc^[Phossz+Cikl] := Random(256);

            For Cikl := 1 To Phossz Do
              pc^[Cikl] := pc^[Cikl] Xor
                           pc^[Phossz+(Cikl Mod Nk)+1] Xor
                           bc^[(Cikl Mod 23)+1];
          End;
    2   : Begin  { baziskulcs eloallitas }
            Move(Pcim^,Sc[1],Phossz);
            sc[0] := Char(Phossz);

            For Cikl := 1 To 23 Do
              Bc^[Cikl] := Byte(sc[(Cikl Mod Phossz)+1]) Xor
                           Byte(sc[Phossz-(Cikl Mod Phossz)]) Xor 34 Xor Cikl;
            For Cikl := 1 To Phossz Do
              For Cikl2 := 1 To 23 Do
                BC^[Cikl2] := BC^[Cikl2] Xor Byte(SC[Cikl]) Xor $55;
          End;
    End { CASE }
End;
*)

Procedure Kodol;External;

{$ENDIF}

Var UpperChar : Char;

procedure inv_lineI(y,x1,x2,fontoff,sortaboff,Imageofs: WORD);
Var Xp1 : Integer Absolute X1;
    Xp2 : Integer Absolute X2;
Begin
  Dec(Xp1,Xoffset);
  Dec(Xp2,Xoffset);
  If Xp1 < 0  Then Xp1 := 0;
  If Xp2 > 77 Then Xp2 := 77;
  If (Xp1 <= 77) And
     (Xp2 >= 0)  Then
    inv_line(y,x1,x2,fontoff,sortaboff,Imageofs);
End;

Procedure Heap_posX;
Var XX : Word;
    Cikl : Integer;
Begin
  Hpvolt := PointerTomb^[HeapP2+1];
  XX := HeapP2+1;
  Heap_pos(Hptr,PointerTomb^[HeapP2+1]);
End;

Procedure  FreeEms1X;
Begin
  FreeEms1(HpVolt);
End;

Function UpperP(C:Char):Char;
var PP : Byte;
Begin
  If C In Kis_A_Kis_Z Then
    UpperP := Char(Byte(C)-$20)
  Else
    Begin
      PP := Pos(C,UpCasePoint[FontNum[EditNum],1]^);
      If PP > 0 Then
        UpperP := UpCasePoint[FontNum[EditNum],2]^[PP]
      Else
        UpperP := C
    End;
End;

Procedure Upper;
var PP : Byte;
Begin
  If UpperChar In Kis_A_Kis_Z Then
    UpperChar := Char(Byte(UpperChar)-$20)
  Else
    Begin
      PP := Pos(UpperChar,UpCasePoint[FontNum[EditNum],1]^);
      If PP > 0 Then
        UpperChar := UpCasePoint[FontNum[EditNum],2]^[PP]
    End;
End;


{$IFDEF DEBUG}

Procedure WriTest(St:String;Var Inte:Word);
Var Scr   : GSctip Absolute $B800:0000;
    Scbuf : GSctip;
    XMent,YMent,Num : Integer;

Begin
  Num := Inte;

  Scbuf := Scr;
  Ablak(24,20,1,Fontoffs,SortabOffs,31);
  XMent := Xpos;
  YMent := YPos;
  GotoX(26,20);

  Input_Integer(St,Num,8);

  Scr := Scbuf;
  Xpos := XMent;
  YPos := YMent;

  Inte := Num
End;

{$ENDIF}


Procedure SetOffs;
Var Cik : Integer;
Begin

  XImage_seg   := @Image_Seg;  { A pointert raallitja az assembler-re}
  XImage_Offs  := @Image_Offs;
  XFont_Offs   := @Font_Offs;
  XSortab_Offs := @Sortab_Offs;

  If Ofs(Arr^) <> 0 Then
    Arr := Ptr(Seg(Arr^)+1,0);

  For Cik := -2 To LastLine Do
    Image[Cik] := Ptr(Seg(Arr^),SizeOf(Arr^)+C160*(Cik+2));

  XImage_seg^   := Seg(Image[-2]^);
  XImage_Offs^  := Ofs(Image[-2]^);
  XFont_Offs^   := XImage_Offs^+(LastLine+3)*C160;

  Fonts         := Ptr(XImage_Seg^,XFont_Offs^);
  XSortab_Offs^ := XFont_Offs^+SizeOf(Fonts^);
  SorTab        := Ptr(XImage_Seg^,XSortab_Offs^);

End;

Procedure SetWideP;
Begin
  With Arr^ Do
  Begin
    WBetuk       := C80;         { sor szelessege karakterekben }
    WBetukXketto := C160;        { 2-szeres sorszelesseg }
    WKezdoPos    := 000;         { kiiras kezdopozicioja (nem ketszeres) }
    W75          := C76-1;       { konstansok helyett }
    W76          := C76;
    W77          := C77;
    W78          := C78;
    W79          := C79;
    W80          := C80;
    Disp78       := 78;
  End;
End;

Procedure SetXoffset(X:Byte);
Begin
  Arr^.WKezdoPos := X;   { kiiras kezdopozicioja (nem ketszeres) }
  Xoffset := X;
End;

Procedure ChangeChar(Char1,Font1,Font2:Byte);
Var Puff : Array[1..Clin2] Of Byte;

Begin
  If GrMode = CgaMode Then
    Begin
      Move(Fonts^[Font1].FontC[Char1,1],Puff,Clin1);
      Move(Fonts^[Font2].FontC[Char1,1],Fonts^[Font1].FontC[Char1,1],Clin1);
      Move(Puff,Fonts^[Font2].FontC[Char1,1],Clin1);
    End
  Else
    Begin
      Move(Fonts^[Font1].FontE[Char1,1],Puff,Clin2);
      Move(Fonts^[Font2].FontE[Char1,1],
           Fonts^[Font1].FontE[Char1,1],Clin2);
      Move(Puff,Fonts^[Font2].FontE[Char1,1],Clin2);
    End
End;

procedure Sys_write (X,Y,CH,fontoff,sortaboff,Imageofs : WORD);
Var CirillBetu : Boolean;
    P : Byte;
    CCh : Char;
Begin
  CCh := Char(Ch);
  {$IFDEF OROSZ}
  CirillBetu := False;
  If Cch > #127 Then
    Begin
      P := POS(Cch,GOST_ciril);
      if P <> 0 then
        Begin
          Cch   := Ekszer_ciril[P];
          Cirillbetu := True;
          ChangeChar(Byte(Cch),0,2);
        End;
    End;
  {$ENDIF}

  Sys_writeO(X,Y,Word(CcH),fontoff,sortaboff,Imageofs);

  {$IFDEF OROSZ}
  If CirillBetu Then
    ChangeChar(Byte(Cch),0,2);
  {$ENDIF}
End;


Begin
  VideoCim := @Page_End;
  IntFFVec := @Int_0FFH;
  ComPoint := @Comm_Data;
End.