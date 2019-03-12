{$S-,I+,F-,V-,B-,N-}

{$I MEMORY.CDW}

Unit EmsCdw;

InterFace

uses Dos,Crt;

Const
  EMS_INT                   = $67;
  DOS_INT                   = $21;
  GET_PAGE_SEGMENT          = $41;
  GET_PAGE_COUNT            = $42;
  ALLOCATE_PAGES            = $43;
  MAP_PAGES                 = $44;
  DEALLOCATE_PAGES          = $45;
  SAVE_EMSF                 = $47;
  RESTORE_EMSF              = $48;
  SajatEmsVan    : Boolean  = False;
  PagekSzama     : Byte     = 4;

Var
  Regs: Registers;
  EMS_Handle, EMS_Error : word;
  Free_Pages            : word;
  t                     : word;
  FreeSeg               : Word;
  SajatXmsH             : Word;
  XmsFelsz,
  FromXms               : Boolean;


Function  Van_EMS: Boolean;
Function  EMS_Pages_Available : Word;
Procedure Allocate_EMS_Pages (Pages_Needed: Word; Var EMS_Handle: Word);
Procedure Get_EMS_Page (Handle,Logical_Page: Word);
Procedure Get_EMS_PageN(Handle,Physical_Page,Logical_Page: Word);
Function  Get_EMS_Segment : word;
Procedure Release_EMS (EMS_Handle: Word);
Procedure EMSDet;
Procedure Save_EMS(EMS_Handle: Word);
Procedure Restore_EMS(EMS_Handle: Word);

Implementation

Uses Windowm,MenuErr;

Var Atallitva,RegiSS,RegiSp: Word;
    AXREG,BXREG,CXREG,DXREG : Word;

Procedure EMSInt;
Label NemEmsStack,NemEmsStack2;
Begin

  With Regs Do
  Begin
    AXREG := AX;
    BXREG := BX;
    CXREG := CX;
    DXREG := DX;
  End;

  Asm
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH DI
    PUSH SI

NemEmsStack:

    MOV AX,AXREG
    MOV BX,BXREG
    MOV CX,CXREG
    MOV DX,DXREG

    INT EMS_INT

    MOV AXREG,AX
    MOV BXREG,BX
    MOV CXREG,CX
    MOV DXREG,DX

NemEMSStack2:

    POP  SI
    POP  DI
    POP  DX
    POP  CX
    POP  BX
    POP  AX
  End;

  With Regs Do
  Begin
    AX := AXREG;
    BX := BXREG;
    CX := CXREG;
    DX := DXREG;
  End;

End;

  {--------------------------------------------------- MAIN ----------}
  Function Van_EMS: Boolean;

  Var
      INT_67_Device_Name    : string[8];
      PlusName              : String[40];
      Position              : Word;

  Begin
    Van_EMS := False;

    {$IFNDEF VER352}

    IF Not(SajatEmsVan) Then
    Begin
      INT_67_Device_Name:='';
      PlusName := '';

      with Regs do
       Begin
         AH:=$35;
         AL:=EMS_INT;
         INTR(DOS_INT,Regs);

         For Position:=0 to 7 do
           INT_67_Device_Name:=
             INT_67_Device_Name+Chr(mem[ES:Position+$0A]);

         For Position:=0 to 35 do
           PlusName := PlusName+Chr(mem[ES:Position+$0A+8]);

         SajatEmsVan := PlusName = '(C) Luk csi Attila  kSoft kft. 1992';
         If SajatEmsVan Then
           Begin
             FreeSeg    := memW[ES:$0A+8+37];
             SajatXmsH  := memW[ES:$0A+8+39];
             PagekSzama :=  Mem[ES:$0A+8+41];
             XmsFelsz   := Boolean(Mem[ES:$0A+8+42]);
             FromXms    := Boolean(Mem[ES:$0A+8+43]);
           End;

         Van_EMS := (INT_67_Device_Name = 'EMMXXXX0') AND
                    (NOT SajatEmsVan);

       end; { with Regs do }
    End;
     {$ENDIF}

  end;

{ * --------------------------------------------------------- * }
Function EMS_Pages_Available : Word;

Begin
    with Regs do
    Begin
      AH:=Get_Page_Count;
      EMSInt;
      EMS_Pages_Available := BX;
      EMS_Error := AH
    end;
end; { EMS_Pages_Available }

{ * --------------------------------------------------------- * }
Procedure Allocate_EMS_Pages (Pages_Needed: Word; Var EMS_Handle: Word);

Begin
    with Regs do
    Begin
      AH:= Allocate_Pages;
      BX:= Pages_Needed;
      EMSInt;
      EMS_Handle:= DX;
      EMS_Error := AH;
    end;
  end; { Function Allocate_EMS_Pages }

{ * --------------------------------------------------------- * }

Procedure Get_EMS_Page (Handle,Logical_Page: Word);

Begin
    with Regs do
    Begin
      AH:=Map_Pages;
      AL:=0;
      BX:=Logical_Page;
      DX:=Handle;
      EMSInt;
      EMS_Error := AH;
    end; { with Regs do }
end; { Function Get_EMS_Pages }


Procedure Get_EMS_PageN(Handle,Physical_Page,Logical_Page: Word);

Begin
    with Regs do
    Begin
      AH:=Map_Pages;
      AL:=Physical_Page;
      BX:=Logical_Page;
      DX:=Handle;
      EMSInt;
      EMS_Error := AH;
    end; { with Regs do }
end; { Function Get_EMS_Pages }

{ * --------------------------------------------------------- * }

Function Get_EMS_Segment : word;

Begin
    with Regs do
    Begin
      AH:=Get_Page_Segment;
      EMSInt;
      Get_EMS_Segment := BX;
      EMS_Error := AH;
     end; { Regs }
end; { Function Get_EMS_Segment }

{ * --------------------------------------------------------- * }

Procedure Release_EMS (EMS_Handle: Word);

Begin
    with Regs do
    Begin
      AH:=DEALLOCATE_PAGES;
      DX:=EMS_Handle;
      EMSInt;
      EMS_Error := AH;
    end; { with Regs do }
end;

Procedure EMSDet;
Var EMS_Segmens : Word;
Begin
  Free_Pages :=  EMS_Pages_Available;
  If Free_Pages > 0 Then
    Begin
      Allocate_EMS_Pages (Free_Pages, EMS_Handle);
      EMS_Segmens := Get_EMS_Segment;
      For t := 0 to Free_Pages - 1 do
       Begin
          Get_EMS_Page(EMS_Handle,t);
          MemW[EMS_Segmens : 0000] := t;
       End;

      For t := 0 to Free_Pages - 1 do
       Begin
          Get_EMS_Page(EMS_Handle,t);
          If MemW[EMS_Segmens : 0000] <> t then
            Begin
              Error(20,'EMS RAM olvas si hiba');
            end
       End;
      Release_EMS(EMS_Handle);
    End
End;

Procedure Save_EMS (EMS_Handle: Word);

Begin
    with Regs do
    Begin
      AH:=Save_EmsF;
      DX:=EMS_Handle;
      INTR(EMS_INT,Regs);
      EMS_Error := AH;
    end; { with Regs do }
end;

Procedure Restore_EMS (EMS_Handle: Word);

Begin
    with Regs do
    Begin
      AH:=Restore_EmsF;
      DX:=EMS_Handle;
      INTR(EMS_INT,Regs);
      EMS_Error := AH;
    end; { with Regs do }
end;

Begin
end.