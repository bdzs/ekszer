Unit HexKit;

InterFace

Uses INITKIT;

function HEX_Dec(St:St5):LongInt;
function Dec_Hex(Wr     : LongInt;
                 Mennyi : Byte):St5;
Function Bin_Dec(inp : ST8) : byte;
Function Dec_Bin(inp : byte) : ST8;

Implementation

function HEX_Dec{(St:St5):LongInt};
const loc : String[20] =
'0123456789ABCDEF';
Var Res : Word;
    Cikl : Integer;
Begin
  Res := 0;
  For Cikl := 1 to Length(St) Do
    Res  := Res * 16 + Pos(Upcase(St[Cikl]),Loc)-1;
  Hex_Dec := Res
End;

function Dec_Hex{(Wr     : LongInt;
                 Mennyi : Byte):St5};

const loc : String[20] =
'0123456789ABCDEF';
Var Res      : st5;
    Kis,Nagy : Word;
    Cikl     : Integer;
Begin
  Res := '';
  For Cikl := 1 To Mennyi Do
    Begin
      nagy := Wr shr 4;
      kis  := Wr And 15;
      Res := Loc[Kis+1]+Res;
      Wr := Nagy;
    End;
  Dec_Hex := Res;
End;

Function Bin_Dec{(inp : ST8) : byte};
const
    szorzo : array[1..8] of byte =
       (1,2,4,8,16,32,64,128);
var cikl : integer;
    szam : integer;
begin
  szam := 0;
  for cikl := 1 to 8 do
    if inp[9-cikl] = '1' then Inc(szam,szorzo[cikl]);
  Bin_Dec := szam
end;


Function Dec_Bin{(inp : byte) : ST8};
var
   cikl : integer;
   ST   : ST8;
begin
  Dec_Bin := '00000000' ;
  for cikl := 0 to 7 do
    if (( inp shr cikl ) and 1 ) = 1 then
      Dec_Bin[8-cikl] := '1' ;
end;

End. { Unit HEXBIN }