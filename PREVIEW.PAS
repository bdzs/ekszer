Unit Preview;      { Preview }
{$O+}

Interface

Uses
     Dos,Crt,
     Nyomtat,
     MenuErr,
     Windowm,
     Video,
     InputCdw,
     HeapCdw,
     {$IFNDEF DPMI}
     Overlay,
     {$ENDIF}
     {$IFDEF PROBA}
     Printer,
     {$ENDIF}
     BGI,
     Graph;

Procedure Previe;
Procedure PrevInit;

Implementation

Type
    FontKT = Array[0..27000] Of Byte;

Const
    MaxNewX   = 7;
    MaxNewY   = 15;

    A4_Arany      : Real    = 2/3;
    StandardArany : Real    = 640/480;
    XSzelArany    : Integer = 40;
    YSzelArany    : Integer = 40;

Var LineCount : Integer;
    Regs      : Registers;
    FontK     : ^FontKT;

    KepVga    : Array[0..479,0..79] Of Byte Absolute $A000:$0000;
    KepEga    : Array[0..349,0..79] Of Byte Absolute $A000:$0000;
    KepCga    : Array[0..$3FFF] Of Byte Absolute $B800:$0000;
    KepHerc   : Array[0..4*90*90] Of Byte Absolute $B000:$0000;

    Ebbol     : Array[0..7,0..15] Of Boolean;
    Ebbe      : Array[0..MaxNewX,0..MaxNewY] Of Boolean;
    MaxXp,
    MaxYp,
    NewX,
    NewY      : Integer;
    DistX,
    DistY,
    PixelWidth,
    PixelLen,
    PhysicLen : Integer;
    TorzitArany : Real;
    WrX,WrY     : Integer;
    BalfX,
    BalfY      : Integer;
    VoltFelso  : Boolean;
    Erosseg    : Integer;

    Ws         : String[160];
    WrColor    : Byte;

    Szele,Alja : Integer;
    PrevYFel,
    PrevXC     : Integer;


Const Arnyek_X = 6;
      Arnyek_Y = 4;

Const MaxMaxXp = 7;
      MaxMaxYp = 15;

Procedure Hercplot(x,y: word;dot : byte);Assembler;
Asm
      mov ax,0B000H
      mov es,ax        { scr segment }
      mov ax,Y
      mov bx,X

      mov cl,bl

      shr ax,1
      rcr bx,1
      shr ax,1
      rcr bx,1
      shr bx,1
      mov ah,90  {bytes / line}
      mul ah
      add bx,ax
      and cl,7
      xor cl,7
      mov ah,1

      mov al,dot   { 0,1 }
      shl ax,cl

      not ah
      and es:[bx],ah
      or  es:[bx],al
end;

Procedure SetLastSor(Var LastSor: Integer);
Begin
  If ExtendedGr  Then
    LastSor := (YResolution - (MaxYp+1)) Else
  If XResolution = 720 Then
    LastSor := (YResolution - (MaxYp+1)) Else
  Begin
    LastSor := (LastLine+3) DIV 2;
    If YResolution = 350 Then Inc(LastSor,2);
  End;
End;

Procedure Plot(X,Y,Color:Integer);

Begin
  If GrMode = HerMode Then
    HercPlot(X,Y,0)
  Else
    Begin
      Regs.Ah := 12;
      Regs.Cx := X;
      Regs.Dx := Y;
      Regs.Bx := 0;
      Regs.Al := Color;
      Intr($10,Regs)
    End
End;


Procedure Ext_Write(X,Y,Ch :Integer);

Const AndT : Array[0..7] Of Byte=(128,64,32,16,8,4,2,1);
Var   Cikl,Cikl2 : Integer;

Begin
  X := X*8;
  If GrMode = CgaMode Then
    Begin
      For Cikl := 0 To 7 Do
        For Cikl2 := 0 To MaxYp Do
          If (Fonts^[0].FontC[Ch,Cikl2] And Andt[Cikl]) <> 0 Then
             Plot(Cikl+X,Cikl2+Y,WrColor)
    End
  Else
    For Cikl := 0 To 7 Do
      For Cikl2 := 0 To MaxYp Do
        If (Fonts^[0].FontE[Ch,Cikl2] And Andt[Cikl]) <> 0 Then
           Plot(Cikl+X,Cikl2+Y,WrColor)


End;

Procedure WriteStr(Y,X: Integer; St: String; L: Byte);
Var Cik : Byte;
Begin
  St := Copy(St+'              ',1,L);
  UpperCase(St);
  ConvertString(St);
  If ExtendedGr OR (XResolution = 720) Then
    Begin
      For Cik := 1 To Length(St) Do
        Ext_Write(X+Cik,(Y-1),Word(St[Cik]));
    End
  Else
    Begin
      For Cik := 1 To Length(St) Do
        Sys_Write(X+Cik,(Y-1)*2,Word(St[Cik]),Fontoffs,Sortaboffs,0);
      Inv_Line((Y-1)*2,X+1,X+Length(St),Fontoffs,Sortaboffs,0);
    End

End;

Procedure WriteNum(Y,X: Integer; N: Integer);
Var St : String[16];
    L  : Byte;
Begin
  If N < 10 Then L := 1
            Else If N < 100 Then L := 2
                            Else If N < 1000 Then L := 3
                                             Else If N < 10000 Then L := 4
                                                               Else If N < 100000 Then L:= 5;

  Str(N:L,St);
  WriteStr(Y,X,St,L);
End;

Function Lnko(a,b:Word):Word;
Var C : Word;
Begin
  If B > A Then
    Begin
      C := A;
      A := B;
      B := C
    End;
  Repeat
    C := A Mod B;
    A := B;
    B := C
  Until C = 0;
  Lnko := a
End;

Function Lkkt(A,B:Word):Word;
Begin
  Lkkt := A*B Div LNKO(A,B)
End;


Procedure TablaKicsi2;


Var Cikl,Cikl2,Cikl3,Cikl4,
    EgyUjP,
    X1Egys,
    Y1Egys,
    X2Egys,
    Y2Egys        : Integer;
    Hatar         : Word;
    Xleg,Yleg     : Word;
    ByteP,BitP    : Byte;
    Sor           : Array[0..MaxMaxChars-1] Of Byte;
    Xarany,YArany : Real;

    NagyKoc,Poz : Byte;
    Szaz        : Real;


    XEloszt : Array[0..MaxMaxXp] Of
                Record
                  Szam     : Byte;
                  Melyikbe : Array[1..2] Of Byte;
                  Mennyit  : Array[1..2] Of Byte;
                End;
    YEloszt : Array[0..MaxMaxYp] Of
                Record
                  Szam     : Byte;
                  Melyikbe : Array[1..2] Of Byte;
                  Mennyit  : Array[1..2] Of Byte;
                End;


Const AndT : Array[0..7] Of Byte=(128,64,32,16,8,4,2,1);

{ X1,Y1  :  Nagyfelbontas meret
  X2,Y2  :  Kisfelbontas  meret }

Begin
  Szaz := 50;
  Xarany := (NewX+1)/(MaxXp+1);
  Yarany := (NewY+1)/(MaxYp+1);

  FillChar(Ebbe,SizeOf(Ebbe),0);

  Xleg := Lkkt(NewX+1,MaxXp+1);
  Yleg := Lkkt(NewY+1,MaxYp+1);

  X1Egys := Xleg Div (MaxXp+1);
  Y1Egys := Yleg Div (MaxYp+1);
  X2Egys := Xleg Div (NewX+1);
  Y2Egys := Yleg Div (NewY+1);

  EgyUjP := X2Egys*Y2Egys;
  Hatar  := Trunc(EgyUjP*((100.0-Szaz)*0.01));
  If Hatar = 0 Then
    Hatar := 1;
  NagyKoc  := 0;
  Poz := 0;
  For Cikl := 0 To MaxXp Do
    With XEloszt[Cikl] Do
      If Poz+X1Egys > X2Egys Then
        Begin
          Szam := 2;
          Melyikbe[1] := NagyKoc;
          Mennyit[1]  := X2Egys-Poz;
          Inc(NagyKoc);
          Melyikbe[2] := NagyKoc;
          Mennyit[2]  := X1Egys-Mennyit[1];
          Poz := Mennyit[2]
        End
      Else
        Begin
          Szam := 1;
          Melyikbe[1] := NagyKoc;
          Mennyit[1]  := X1Egys;
          Inc(Poz,X1Egys);
          If Poz = X2Egys Then
            Begin
              Inc(NagyKoc);
              Poz := 0;
            End
        End;

  NagyKoc  := 0;
  Poz := 0;
  For Cikl := 0 To MaxYp Do
    With YEloszt[Cikl] Do
      If Poz+Y1Egys > Y2Egys Then
        Begin
          Szam := 2;
          Melyikbe[1] := NagyKoc;
          Mennyit[1]  := Y2Egys-Poz;
          Inc(NagyKoc);
          Melyikbe[2] := NagyKoc;
          Mennyit[2]  := Y1Egys-Mennyit[1];
          Poz := Mennyit[2]
        End
      Else
        Begin
          Szam := 1;
          Melyikbe[1] := NagyKoc;
          Mennyit[1]  := Y1Egys;
          Inc(Poz,Y1Egys);
          If Poz = Y2Egys Then
            Begin
              Inc(NagyKoc);
              Poz := 0;
            End
        End;

  For Cikl := 0 To MaxYp Do
    For Cikl2 := 0 To MaxXp Do
      If Ebbol[Cikl2,Cikl] Then
        For Cikl3 := 1 To YEloszt[Cikl].Szam Do
          For Cikl4 := 1 To XEloszt[Cikl2].Szam Do
            Inc(Ebbe[XEloszt[Cikl2].Melyikbe[Cikl4]]
                    [YEloszt[Cikl].Melyikbe[Cikl3]],
                      Integer(XEloszt[Cikl2].Mennyit[Cikl4])*
                      Integer(YEloszt[Cikl].Mennyit[Cikl3]));


End;


Procedure SetVga;

Begin
  Regs.Ax := 18;
  Intr($10,Regs)
End;

Procedure SetExt;

Begin
  Regs.Ax := ExtendedMode;
  Intr($10,Regs);
  MostExtVan := True;
  If WrColor > (NoOfColors-1) Then
    WrColor := NoOfColors-1;
  If NoOfColors = 16 Then
    Begin
      SetPaletta(0,EgaWhite);
      SetPaletta(WrColor,0)
    End
  Else
    Begin
      Set256Pal(0,63,63,63);
      Set256Pal(WrColor,0,0,0);
    End;
End;


Procedure SetGraph;
Begin
  If ExtendedGr Then
    SetExt
  Else
    If Yresolution <> 480 Then
      SetGraphMod(Gr)      { FI }
    Else
      SetVga;
End;

Procedure LineX(Y,X1,X2:Integer);
Var Cikl : Integer;

Begin
  For Cikl := X1 To X2 Do
    Plot(Cikl,Y,WrColor);
End;


Procedure LineY(X,Y1,Y2:Integer);
Var Cikl : Integer;
Begin
  For Cikl := Y1 To Y2 Do
    Plot(X,Cikl,WrColor);
End;


Function Yppp(CharY:Integer):Integer;
Begin
  Yppp := (CharY*((NewY+1) Div 2 ))+DistY;
  {Yppp := (CharY*(NewY+1) Div 2)+DistY;}
End;

Procedure VSzaggatott(Y:Integer);
Var Cikl : Integer;
    Y4   : Integer;
Begin
  Y4 := Yppp(Y)-1;
  For Cikl := DistX To DistX+PixelWidth-1 Do
    If Odd(Cikl) Then
      Plot(Cikl,Y4,WrColor);
End;

Procedure FSzaggatott(X:Integer);
Var Cikl : Integer;
    Oszto: Integer;
Begin
  If YResolution < 500 Then Oszto := 100
                       Else Oszto := 150;
  For Cikl := DistY To Alja+DistY Do
    If Cikl MOD (YResolution DIV Oszto) = 0 Then
      Plot(X,Cikl,WrColor);
End;

Procedure LaserHosszSzel(Var X,Y:Integer);
Begin
  If (Ppar.Pr_ovr in [1,11]) Then
    If Not(Formatum) Then    { Fekvo  }
      If Condensed Then      { Suru   }
        Begin
          Y := 188*PrevYFel;
          X := Trunc(112*1.6)*PrevXC;
        End
      Else                   { Normal }
        Begin
          Y := 118*PrevYFel;
          X := 112*PrevXC
        End
    Else                     { Allo   }
      If Condensed Then      { Suru   }
        Begin
          Y := 272*PrevYFel;
          X := 129*PrevXC
        End
      Else                   { Normal }
        Begin
          Y := 170*PrevYFel;
          X := 80*PrevXC;
        End
  Else
    Begin
      X := C78*(NewX+1);
      Y := PhysicLen*(NewY+1) Div 2;
    End
End;

Procedure ClearScr;
Var LastSor : Integer;
    Cik     : Integer;
    Ypoz    : Integer;

    ArnyekAlja : Integer;

Begin
  LaserHosszSzel(Szele,Alja);

  If ExtendedGr Then
    Begin
      SetExt;
    End
  Else
    Case GrMode Of
      CGAMode   : FillChar(KepCga,SizeOf(KepCga),$FF);
      HerMode   : FillChar(KepHerc,SizeOf(KepHerc),$FF);
      EgaMode   : FillChar(KepEga,SizeOf(KepEga),$FF);
      VgaMode   : FillChar(KepVga,SizeOf(KepVga),$FF);
      End;

(*
  linex(3,3,180);
  liney(3,3,12*(10+(Byte((GrMode <> CgaMode))*6))+2);
  linex(12*(10+(Byte((GrMode <> CgaMode))*6))+2,3,180);
  liney(180,3,12*(10+(Byte((GrMode <> CgaMode))*6))+2);
 *)

  SetLastSor(LastSor);

  WriteStr(LastSor,40,IneSt1,18);
  WriteStr(LastSor,60,InpSt9,18);

  For Cik := 1 To 7 Do
    WriteStr(1,PrTomb[Cik].Poz,PrTomb[Cik].Txt+':',Length(PrTomb[Cik].Txt)+2);

  For Cik := 8 To 9 Do
    WriteStr(LastSor,PrTomb[Cik].Poz,PrTomb[Cik].Txt+':',Length(PrTomb[Cik].Txt)+2);

  WriteNum(1,PrTomb[1].Poz+Length(PrTomb[1].Txt)+1,PageCount);
  WriteNum(1,PrTomb[2].Poz+Length(PrTomb[2].Txt)+1,PageCount+FirstPageNum-1);
  WriteNum(1,PrTomb[3].Poz+Length(PrTomb[3].Txt)+1,PageLen);
  WriteStr(1,PrTomb[4].Poz+Length(PrTomb[4].Txt)+1,Copy(PsFile[True],1,Pos('.',PsFile[True])-1),8);

  WriteNum(1,PrTomb[5].Poz+Length(PrTomb[5].Txt)+4,Paralell_Device+1);
  WriteStr(1,PrTomb[5].Poz+Length(PrTomb[5].Txt)+1,'LPT',3);
  WriteNum(1,PrTomb[6].Poz+Length(PrTomb[6].Txt)+1,Laser_NyomSzam);
  WriteNum(1,PrTomb[7].Poz+Length(PrTomb[7].Txt)+1,PrintMargin);

  If PrevHeadNum = 0
  Then
    Ws := Nincs
  Else
    MenuStr(MenuRec[11].Start+PrevHeadNum-4,Ws,False);

  WriteStr(LastSor,PrTomb[8].Poz+Length(PrTomb[8].Txt)+2,Ws,9);

  Ypoz := 6*Byte(GrMode <> CGAMode)+9;
  If Ypoz < DistY Then LineX(YPoz,0,Xresolution); { Felso vizszintes vonal }

  Ypoz := YResolution-(10+6*Byte(GrMode <> CGAMode))-2;
  If YPoz > Alja+DistY Then LineX(YPoz,0,Xresolution); { Also vizszintes vonal }

  linex(0+DistY,0+DistX,Szele+DistX);
  liney(0+DistX,0+DistY,Alja+DistY);

  linex(Alja+DistY,0+DistX,Szele+DistX);

  ArnyekAlja := Alja+DistY+Arnyek_Y;

  If ArnyekAlja > (YResolution-(10+6*Byte(GrMode <> CGAMode))-1)
    Then ArnyekAlja := YResolution-(10+6*Byte(GrMode <> CGAMode))-1;

  For Cik := Alja+DistY+1 To ArnyekAlja Do
    linex(Cik,DistX+Arnyek_X,Szele+DistX+1);

  liney(Szele+DistX,0+DistY,Alja+DistY);

  For Cik := Szele+DistX+1 To Szele+DistX+Arnyek_X Do
    liney(Cik,Arnyek_Y+DistY,ArnyekAlja);

  If (C80 > 80) And (not Ppar.Pr_ovr in [1,11]) Then
    FSzaggatott(DistX+(80*(NewX+1)));

End;

Procedure FooterKiir;
Var LastSor : Integer;
Begin
  If PrevFootNum = 0
  Then
    Ws := Nincs
  Else
    MenuStr(MenuRec[11].Start+PrevFootNum-4,Ws,False);

  SetLastSor(LastSor);

  WriteStr(LastSor,PrTomb[9].Poz+Length(PrTomb[9].Txt)+2,Ws,9);

End;



Procedure PlotCh(X,Y  : Integer;
                 Chr  : Char;
                 Attr : Byte);

Var
   Cikl,Cikl2,
   X4,Y4        : Integer;
   ChKezd       : Integer;

Const Andol : Array[0..7] Of Byte = (128,64,32,16,8,4,2,1);

Begin
  X4 := X*(NewX+1)+DistX;

  Y4 := Yppp(Y);

  If Attr <> 16 Then
    Attr := Attr And 15;

  ChKezd := (Attr-1)*(NewY+1)*97 + (NewY+1)*(Byte(Chr)-32);

  { If (X4+NewX <= Xresolution) AND (Y4 + NewY <= YResolution) Then }
    For Cikl := 0 To NewX Do
      For Cikl2 := 0 To NewY Do
        If (FontK^[ChKezd+Cikl2] And Andol[Cikl]) <> 0 Then
          Plot(X4+Cikl,Y4+Cikl2,WrColor);
End;


Procedure EgySorKi;
Var Cikl : Integer;
Begin
  For Cikl := 0 To C77-PrintMargin Do
    If Not(Image[LastLine]^.Chars[C80+Cikl] In [#0,#32]) Then
      PlotCh(Cikl+PrintMargin,LineCount,Image[LastLine]^.Chars[C80+Cikl],
                              Image[LastLine]^.Attribs[Cikl]);
  {If LapReszV Then
    VSzaggatott(LineCount);}
End;

Procedure MakeKicsiF;
Var Cikl,
    Cikl2,Cikl3,Cikl4,
    ChKezd  :Integer;

Const Andol : Array[0..7] Of Byte = (128,64,32,16,8,4,2,1);

Begin
  FillChar(FontK^,SizeOf(FontK^),00);

  For Cikl := 1 To 15 Do
    If Van_Font[Cikl] Or (CimFile <> '') Then
      Begin
        GotoXy(WrX,WrY);
        Write(Cikl:3);
        For Cikl2 := 32 To 128 Do
          Begin
            If GrMode = CgaMode Then
              For Cikl3 := 0 To MaxYp Do
                For Cikl4 := 0 To 7 Do
                  Ebbol[Cikl4,Cikl3] :=
                    (Fonts^[Cikl].FontC[Byte(Cikl2),Cikl3+1] And Andol[Cikl4]) <> 0
            Else
              For Cikl3 := 0 To MaxYp Do
                For Cikl4 := 0 To 7 Do
                  Ebbol[Cikl4,Cikl3] :=
                    (Fonts^[Cikl].FontE[Byte(Cikl2),Cikl3+1] And Andol[Cikl4]) <> 0;

            TablaKicsi2;
            ChKezd := (Cikl-1)*(NewY+1)*97 + (NewY+1)*(Cikl2-32);

            For Cikl3 := 0 To NewX Do
              For Cikl4 := 0 To NewY Do
                If Ebbe[Cikl3,Cikl4] Then
                  FontK^[Cikl4+ChKezd] :=
                        FontK^[Cikl4+ChKezd] Or Andol[Cikl3];

          End
      End
End;


Procedure PrevInit;
Var LapArany,
    KepernyoArany  : Real;
    MaxXRes,MaxYRes: Integer;
    RealPixelLen,
    RealPixelWidth : Integer;
    CPI            : Real;
    C80C,
    C79C,
    C78C,
    C77C           : Integer;

Begin
  C80C := C80;
  C79C := C79;
  C78C := C78;
  C77C := C77;
  PhysicLen := Ppar.Pr_MaxFelsor;  { nem laser }

  If (Ppar.Pr_ovr in [1,11]) Then
    If Condensed Then      { Suru   }
      Begin
        PhysicLen := 272;
        If Formatum Then
          C80C := 129
        Else
          C80C := 186;
        C79C := C80C-1;
        C78C := C79C-1;
        C77C := C78C-1;
      End
    Else                   { Normal }
      PhysicLen := 170;

  If YResolution = 348 Then YResolution := 350;

  LapArany      := A4_Arany * (C80C/80);
  KepernyoArany := Xresolution/Yresolution;
  TorzitArany   := KepernyoArany / StandardArany;

  MaxXp :=  7;
  If GrMode = CgaMode Then
    MaxYp := 9
  Else
    MaxYp := 15;

    (*
    WriteLn(LST,#13#10,'PhysicLen = ',PhysicLen);
    WriteLn(LST,'YResolution   = ',YResolution:8    ,' XResolution = ',XResolution:8  );
    WriteLn(LST,'YSzelArany    = ',YSzelArany:8     ,' XSzelArany  = ',XSzelArany:8   );
    WriteLn(LST,'KepernyoArany = ',KepernyoArany:2:6,' TorzitArany = ',TorzitArany:2:6);
    WriteLn(LST,'StandardArany = ',StandardArany:2:6,'    LapArany = ',LapArany:2:6);
    *)

  MaxXRes := Xresolution-(Xresolution Div XSzelArany);
  MaxYRes := Yresolution-(20+(10*Byte(GrMode <> CGAMode)));

  If StandardArany / LapArany > 1.01 Then
  Begin
    NewY := ((MaxYRes Div PhysicLen)*2)-1;
    If NewY > MaxYp Then
      NewY := MaxYp;
    PixelLen   := (((NewY+1) Div 2)*PhysicLen);

    PixelWidth := Trunc((PixelLen*A4_Arany)*TorzitArany*(C80C/80));
    RealPixelWidth := PixelWidth;
    (*
    WriteLn(LST,'PixelLen      = ',PixelLen:6,' PixelWidth (1) = ',PixelWidth:6);
    *)
    NewX := ((PixelWidth+C77C) Div C78C)-1;
    If NewX > MaxXp Then
      NewX := MaxXp;

    PixelWidth := (NewX+1)*C78C;

  End
  Else
  Begin
    NewX := ((MaxXRes Div C80C))-1;
    If NewX > MaxXp Then
       NewX := MaxXp;

    PixelWidth := ((NewX+1)*C80C);

    PixelLen := Trunc((PixelWidth/A4_Arany)/(TorzitArany*(C80C/80)));
    RealPixelLen := PixelLen;
    (*
    WriteLn(LST,'PixelLen  (1) = ',PixelLen:6,' PixelWidth = ',PixelWidth:6);
    *)
    NewY := (PixelLen Div PhysicLen)*2-1;
    If NewY > MaxYp Then
      NewY := MaxYp;

    PixelLen := (NewY+1)*PhysicLen DIV 2;

    If ((RealPixelLen-PixelLen) > (PixelLen+PhysicLen-RealPixelLen)) AND
       ((PixelLen+PhysicLen) <= MaxYRes) Then
    Begin
      Inc(PixelLen,PhysicLen);
      Inc(NewY,2);
      If NewY > MaxYp Then
        NewY := MaxYp;
      { Beepel(333); Beepel(444); Beepel(555); }
    End;

  End;

  If ((PixelWidth/PixelLen) > KepernyoArany) AND
     (PixelWidth/PixelLen - KepernyoArany > 1.51 * ABS((PixelWidth-C80C)/PixelLen - KepernyoArany)) AND
     (PixelWidth > 2*C80C) Then
  Begin
    Dec(PixelWidth,C80C);
    Dec(NewX);
    { Beepel(555); Beepel(444); Beepel(333); }
  End;

  (*
  WriteLn(LST,'PixelLen (uj) = ',PixelLen:6,' PixelWidth (uj) = ',PixelWidth:6);
  *)

  DistY := ((Yresolution-PixelLen) Div 2);
  DistX := (Xresolution-PixelWidth) Div 2;

  { Inc(DistX,DistX Div 3); }

  PrevXs := NewX+1;
  PrevYs := NewY+1;

  PrevYfel := (NewY+1) Div 2;
  PrevXc   := NewX+1;

End;

Procedure DobozRajzolas(X1,Y1,X2,Y2:Integer);
Var Cikl,Cikl2 : Integer;
Begin
  If X2 + PrintMargin > C77 Then
    X2 := C77-PrintMargin;
  X1 := (X1+PrintMargin)*(NewX+1)+DistX;
  Y1 := Yppp(Y1);
  X2 := (X2+PrintMargin)*(NewX+1)+DistX+NewX;
  Y2 := Yppp(Y2)+NewY;
  For Cikl := X1 To X2 Do
    For Cikl2 := Y1 To Y2 Do
      If ((Cikl+Cikl2*2) Mod Erosseg) = 0 Then
        Plot(Cikl,Cikl2,WrColor)

End;

Procedure Doboz_Figyel;
Var SS   : String;
    Cikl : Integer;
    PPP  : Integer;
    Spacek : Integer;
Begin
  For Cikl := 0 To C77 Do
    SS[Cikl+1] := Image[LastLine]^.Chars[C80+Cikl];
  SS[0] := Char(C78);
  If VoltFelso Then
    Begin
      Spacek := 0;
      For Cikl := 1 To C78 Do
        If SS[Cikl] In [' ',#0] Then
          Inc(Spacek);
      PPP := Pos('.',SS);
      If (PPP <> 0) And (Spacek=C77) Then
        Begin
          Image[LastLine]^.Chars[C80+PPP-1] := ' ';
          VoltFelso := False;
          DobozRajzolas(Balfx,Balfy,PPP-1,LineCount);
        End
    End
  Else
    Begin
      PPP := Pos('.@',SS);
      If (PPP <> 0) And (SS[PPP+2] In ['1'..'7']) Then
        Begin
          VoltFelso := True;
          BalfX := PPP-1;
          BalfY := LineCount;
          Erosseg := 8-(Byte(SS[PPP+2])-Byte('0'));

          Image[LastLine]^.Chars[C80+PPP-1] := ' ';
          Image[LastLine]^.Chars[C80+PPP]   := ' ';
          Image[LastLine]^.Chars[C80+PPP+1] := ' ';
        End;
    End
End;

Procedure Previe;
Var Kment : ScTip;
    UjPage: Boolean;
    FF    : Array[0..27000] Of Byte;

Begin
  Previewban := True;
  {$IFNDEF DPMI}
  OvrClearBuf;
  {$ENDIF}

  If ExtendedGr Then
    WrColor := 15
  Else
    WrColor := 0;

  FontK     := @FF;
  LineCount := 0;
  VoltFelso := False;

  PrevHely := Ptr(Seg(FontK^),Ofs(FontK^)+(KepFont-1)*(NewY+1)*97+(NewY+1));

  BOOL := CREATE_WINDOW(46,5,70,9,pr_mess21,CA[DispMode,1],CA[DispMode,2]);
  GotoXY(4,2);
  Write(PrevSt1);
  WRX := Wherex;
  WRY := Wherey;

  MakeKicsiF;

  Bool := Remove_Window;


  Kment := ScrMemT[GrMode]^;

  If Not(ExtendedGr) Then
    SetGraph;
  CrtMode := 6;
  NemKellCursor := True;

  Ch := 0;
  UjPage := True;

  While Van_Sor And (Ch <> 27)  do
    Begin

      If UjPage Then
      Begin
        UjPage := False;
        ClearScr;
      End;

      If Ppar.Pr_ovr in [1,11] Then
        Doboz_Figyel;
      EgySorKi;

      Inc(LineCount);

      If LapVegeI(LastLine) Then
        Begin
          FooterKiir;
          Repeat
            Puffi(Ch,Sc);
          Until (Ch In [27,13,32]) Or (Sc = PageDown);
          Esc := (Ch = 27);
          UjPage := True;

          If HanyOldalonKeresztul = 0 Then
            Begin
              Formatum := Not(Formatum);
              HanyOldalonKeresztul := Maxint
            End
          Else
            Dec(HanyOldalonKeresztul);

          LineCount := 0;
        End
    End;

  Regs.Ax := $0003;
  Intr($10,Regs);

  ScrMemT[GrMode]^ := Kment;
  PrevHely := NIL;
  CrtMode := 3;
  NemKellCursor := False;
  MostExtVan := False;
  Previewban := False;
  curoff;
End;  { Procedure Previe }

End.
