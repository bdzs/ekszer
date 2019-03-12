{ kulcs.pas								}

program	kulcs;

uses	novellfg,titkok;


label	vege;
var
	i	:	integer ;
	argv	:	string ;
	str	:	string ;
begin
randomize;
writeln;
{$ifdef novell_386							}
{$else									}
if Verifypassword_nh then
	begin

	if Createobject then goto vege ;
	if Createproperity('PASSWORD',$33) then goto vege;
	if Createproperity(Tulajdonsag_nev,$11) then goto vege;

	if Changepassword then goto vege;
  {$ifdef tesztverzio							}
	writeln('Letrehoztam az object-et');
  {$endif								}
	end
else    begin
	writeln('Ujraind¡t s.');
	argv := paramstr(1);
	if ((paramcount>0) and (upcase(argv[1]) = 'U')) then
		writeln('A programot ‚ppen haszn l¢k adatai elvesznek !')
	else	begin
		writeln('Csak a megfelel“ param‚terrel inditva sikeres az £jraind¡t s.');
		goto vege;
		end;
	end;
for i:= 0 to Kod_helye-Jogosultak_szama-1 do
	sablon[i] := random(256);
for i:= Kod_helye-Jogosultak_szama to Kod_helye-1 do
	sablon[i] := connect_kod(Ures);

  {$ifdef nuku_hon							}
str := '';
  {$else									}
if kodolas(str)	then	goto vege;
  {$endif								}
for i := Kod_helye to Kod_helye+length(str) do
	sablon[i] := byte(str[i-Kod_helye]);
for i := i+1 to 127 do
	sablon[i] := random(256);
if writeproperity then goto vege ;
{$endif									}

writeln('A programok futtathat¢k.');

vege :
end.

