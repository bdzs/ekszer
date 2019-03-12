{ halozat.pas 								}

unit halozat;

{$IFDEF HALO}

{$DEFINE NOVELL_3}
{$DEFINE NOVELL_386}
{$DEFINE NUKU_HON}

{$ENDIF}


interface

function Hindul : boolean ;
function Hment  : boolean ;
function Hkilep : boolean ;

implementation

uses	crt,windowm,menuerr,novellfg,titkok;




{-----------------------------------------------------------------------}

function        helyetszabadit : boolean ;

label	jo,rossz,vege,rossz1;

begin
if readproperity then	goto	rossz;
if (sablon[sablon_index]=connectkod) then
	begin
        if waitszemafor then	goto	rossz;
	if readproperity then	goto	rossz1;
	if (sablon[sablon_index] <> connectkod)
		then		goto 	rossz1;
	sablon[sablon_index] := connect_kod(Ures);
	if writeproperity then	goto	rossz1;
        if szignalszemafor then	goto	rossz;
{$ifdef tesztverzio							}
	writeln(f,'     Szabalyos kilepes (kilep)');
{$endif									}
	end
else	goto	rossz;

jo:
helyetszabadit := false;
goto	vege;

rossz1:
if szignalszemafor	then	{goto	rossz} ;

rossz:
helyetszabadit := true;
goto	vege;

vege:
end;


function        szabadhely : boolean ;

label	jo,rossz,vege,tovabb,rossz1;
var
	i	: integer;
	conn	: byte;

begin
if connectnumber(conn)	then    goto	rossz;
if verifypassword 	then 	goto	rossz;
if readproperity 	then 	goto	rossz;
if ujrabejelentkezes(conn) then	goto	jo;
{						lefoglalas		}
if waitszemafor then	goto	rossz;
if readproperity then 	goto 	rossz1;
i := Kod_helye-Jogosultak_szama;
while i<Kod_helye do
	begin
	if (kod_connect[sablon[i]]=Ures) then
		begin
		sablon_index:=i;
{$ifdef tesztverzio							}
		writeln(f,'     Megprobalom az i-diket ',i,' (indul)');
{$endif									}
		sablon[sablon_index] := connectkod;
		if writeproperity	then 	goto	rossz1;
		goto	tovabb;
		end;
	inc(i);
	end;
tovabb:
if szignalszemafor then	goto	rossz;
if (i = Kod_helye) then
	begin
	error(45,'');		{ minden hely foglalt	}
{$ifdef tesztverzio							}
	writeln(f,'     Minden hely foglalt (indul)');
{$endif									}
	goto	rossz;
	end;
{$ifdef tesztverzio							}
writeln(f,'     Lefoglaltam az i-diket ',sablon_index,' (indul)');
{$endif									}

jo:
szabadhely := false;
goto       vege;

rossz1:
if szignalszemafor	then	{goto	rossz} ;
if closeszemafor	then	{goto	rossz} ;

rossz:
szabadhely := true ;

vege:
end;
{-----------------------------------------------------------------------}




function	Hindul: boolean;

label	jo,rossz,vege;
var
	i	: integer;
	conn	: byte;

begin
get_ekszer_dir;
goto_ekszer_dir;
if openszemafor		then	goto	rossz;

{$ifdef novell_386							}
{$else									}
if szabadhely           then    goto    rossz;
{$endif									}

{$ifdef nuku_hon							}
{$else									}
if statikuskod		then	goto	rossz;
{$endif									}

jo:
Hindul := true;
goto	vege;

rossz:
Hindul := false;
goto	vege;

vege:
goto_work_dir;
end;


function	Hment : boolean;        { ez a megszabadahely?          }

label	jo,rossz,vege;

begin
goto_ekszer_dir;
{$ifdef novell_386							}
{$else									}
if readproperity then	goto	rossz;
  {$ifdef test_nh}
sablon[sablon_index] := connectkod;
  {$endif								}
if (sablon[sablon_index]=connectkod) then
	begin
  {$ifdef tesztverzio							}
	writeln(f,'     Mentek (ment)');
  {$endif								}
	goto	jo;
	end;

rossz:
error(47,'');  						{ nem mentek	}
Hment := false;
goto	vege;
{$endif									}

jo:
Hment := true;

vege:
goto_work_dir;
end;


function	Hkilep : boolean;

label	jo,rossz,vege;

begin
goto_ekszer_dir;
{$ifdef novell_386							}
{$else									}
if helyetszabadit then  goto    rossz;
{$endif									}

if closeszemafor  then	goto	rossz;

jo:
Hkilep := true;
goto   vege;

rossz:
if closeszemafor	then	{goto	rossz} ;
ErrorStNum := 2;	error(48,'');	ErrorStNum := 1;
Hkilep := false;
goto	vege;

vege:
goto_work_dir;
end;

begin
end.

{ end halozat.pas							}
