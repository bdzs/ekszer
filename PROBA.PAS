{$IFNDEF STANDALONE}
Unit Proba;

Interface

Procedure Valami_Init;
Procedure Valamit_csinal;

Implementation
{$ENDIF}
Uses PlusMem;

Var  H1,H2,H3,H4 : Integer;

Procedure Valami_Init;
Begin
  Writeln('Init :',Ext_Init(220000,$F000));
  Writeln('Alloc1 :',Ext_Alloc(H1,40000));
  Writeln('Alloc2 :',Ext_Alloc(H2,50000));
  Writeln('Alloc3 :',Ext_Alloc(H3,60000));
  Writeln('Alloc4 :',Ext_Alloc(H4,60000));
End;

Procedure Valamit_Csinal;
Type AA = Array[0..$FFF7] Of Byte;
Var  PP : ^AA;
Begin
  Ext_Address(H1,PP);
  FillChar(PP^,40000,65);
  Ext_Save;

  Ext_Address(H2,PP);
  FillChar(PP^,50000,66);
  Ext_Save;

  Ext_Address(H3,PP);
  FillChar(PP^,60000,67);
  Ext_Save;

  Ext_Address(H4,PP);
  FillChar(PP^,60000,68);
  Ext_Save;

  Ext_Address(H1,PP);
  Writeln((PP^[0] = 65) And (PP^[39999] = 65));

  Ext_Address(H2,PP);
  Writeln((PP^[0] = 66) And (PP^[49999] = 66));

  Ext_Address(H3,PP);
  Writeln((PP^[0] = 67) And (PP^[59999] = 67));

  Ext_Address(H4,PP);
  Writeln((PP^[0] = 68) And (PP^[59999] = 68));

End;
{$IFDEF STANDALONE}
Begin
  Valami_Init;
  Valamit_Csinal;
{$ENDIF}
End.