
{ novellfg.pas 								}

unit	novellfg;

{$IFDEF HALO}

{$DEFINE NOVELL_3}
{$DEFINE NOVELL_386}
{$DEFINE NUKU_HON}

{$ENDIF}

interface
uses	novellib,menuerr;
{type	sablon_tipus	=	array [0..127] of byte;			}

function	connectnumber	(var connection_number : byte) : boolean;
function	verifypassword 		: boolean;
function	verifypassword_nh 	: boolean;
function	readproperity 		: boolean;
function	writeproperity 		: boolean;
function	statikuskod		: boolean;
function 	kodolas		(var str : string) : boolean;

var
   connectkod,
   sablon_index		:	byte;

var		sablon		: sablon_tipus;

function	createobject		: boolean;
function	changepassword		: boolean;
function 	createproperity	(tulnev : string; vedelem : byte) : boolean;

function 	connect_kod	(connumb : byte) : byte;
function 	ujrabejelentkezes(conn : byte) : boolean;

function 	openszemafor 	: boolean;
function 	waitszemafor 	: boolean;
function 	szignalszemafor : boolean;
function 	closeszemafor 	: boolean;

procedure       get_ekszer_dir;
procedure       goto_ekszer_dir;
procedure       goto_work_dir;

procedure proba;

{$ifdef tesztverzio							}
var	f	:	text;
{$endif									}

implementation
uses
{	,novellib							}
	windowm,titkok,Dos;

var		hiba	:	boolean;
		handle 	:	handle_t;
                Ekszerdir,
                Workingdir :    string;

function	verifypassword 	: 	boolean;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
  {$ifdef novell_3							}
	false
  {$else									}
	(verify_password(Object_nev,Object_tipus,csali_Password) = 0)
  {$endif								}
	or verifypassword_nh ;
{$endif									}
if hiba then error(44,''); 				{  nincs_kulcs	}
verifypassword := hiba;
end;

function	verifypassword_nh : boolean;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	verify_password(Object_nev,Object_tipus,Password) <> 0 ;
{$endif									}
verifypassword_nh := hiba;
end;


function	readproperity 	: 	boolean;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	read_properity(Object_nev,Object_tipus,Tulajdonsag_nev,1,sablon) <> 0 ;
{$endif									}
if hiba then error(43,'a'); 				{ halozati_hiba }
readproperity := hiba;
end;


function	writeproperity	: 	boolean;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	write_properity(Object_nev,Object_tipus,Tulajdonsag_nev,1,0,sablon) <> 0 ;
{$endif									}
if hiba then error(43,'b');	   			{ Halozati hiba }
writeproperity := hiba;
end;


function	createobject	:	boolean;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	create_object(Object_nev,Object_tipus,$33,0) <> 0;
{$endif									}
if hiba then error(49,'');	   			{ Tragikus hiba }
createobject := hiba;
end;

function	createproperity(tulnev : string; vedelem : byte) : boolean;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	create_properity(Object_nev,Object_tipus,tulnev,vedelem,0) <> 0;
{$endif									}
if hiba then error(49,'');	   			{ Tragikus hiba }
createproperity := hiba;
end;


function	changepassword	:	boolean;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	change_password(Object_nev,Object_tipus,Password,'') <> 0;
{$endif									}
if hiba then error(49,'');	   			{ Tragikus hiba }
changepassword := hiba;
end;

function	connectnumber	(var connection_number : byte) : boolean;

begin
connection_number :=
{$ifdef test_nh							}
	1;
{$else									}
	conn_number;
{$endif									}
hiba := (connection_number = 0);
if hiba then error(43,'c');				{ halozati hiba	}
connectnumber := hiba;
end;

function ujrabejelentkezes(conn : byte) : boolean;
label	vege;
var	i	: byte ;
begin
ujrabejelentkezes := false;
i := Kod_helye-Jogosultak_szama;
while (i<Kod_helye) do
       begin
       if (kod_connect[sablon[i]] = conn) then
	       begin
	       sablon_index:=i;
	       ErrorStNum := 2;
	       error(46,'');		{ ujrabejelentkezes warning	}
	       ErrorStNum := 1;
{$ifdef tesztverzio							}
	       writeln(f,'     Ujrabejelentkezes (indul)');
{$endif									}
	       ujrabejelentkezes := true;
	       connectkod := sablon[i];
	       goto	vege;
	       end;
       inc(i);
       end;
connectkod := connect_kod(conn);
vege:
end;

procedure proba;
var	i	:	integer;
var     szamok,
	szamstring	:       string;
var 	servernev 	:	string;
 	netvaltozat,
	netalvaltozat 	:	byte;
 	maxkapcs,
	hasznkapcs,
	maxloglemez 	:	word;
 	foglalt		:	string;
var ev,ho,nap,ora,perc,ms,hetnapja : byte;
var	sorozat	:	str4;


begin
{$ifdef tesztverzio							}
hiba := 0 <> date_time_string(ev,ho,nap,ora,perc,ms,hetnapja);
writeln(f,'date time :',hiba);
writeln(f,'19',ev,', ',ho,'.',nap,' ',ora,':',perc,':',ms,' ',hetnapja);
hiba := 0 <> get_server_information(servernev,netvaltozat,netalvaltozat,maxkapcs,hasznkapcs,maxloglemez,foglalt);
writeln(f,'server information :',hiba);
writeln(f,servernev,' V',netvaltozat,'.',netalvaltozat,' max connect ',maxkapcs,
				' haszn connect ',hasznkapcs,' max log lemez ',maxloglemez);
get_shell_table(szamok);
writeln(f,'shell table :');
szamstring:=hexa(szamok);
writeln(f,szamstring);
hiba := 0 <> read_properity(servernev,$0400,'NET_ADDRESS',1,sablon);
writeln(f,'net address :',hiba);
for i := 0 to 127 do
	szamok[i+1] := char(sablon[i]);
szamok[0]:=char(127);
szamstring:=hexa(szamok);
writeln(f,szamstring);

{
writeln(f,'serial number ');
hiba := 0 <> get_serial_number(sorozat);
writeln(f,'serial number :',hiba);
for i:= 0 to 3 do
	write(f,byte(sorozat[i]),' ');					}
{$endif									}
end;

function connect_kod(connumb : byte) : byte;

const
	range0	=	75;
	maxcon	=	100;
	range1	=	5;
	limit1	=	1;
	limit2	=	20;
var	a 	:	byte;
begin
case connumb of
	0 :
		a := random(range0);
	limit1..limit2 :
		a := random(range1)+range0+range1*(connumb-limit1);
	limit2+1..maxcon :
		a := range0+range1*limit2+connumb-limit2;
	else 	begin
		a := 100;
		error(43,'d');				{ halozati hiba	}
		end;			    { tul nagy a kapcsolatszam	}
end;
connect_kod := kod[a];
end;


procedure	drotozas;

var	i	:       byte;
        str	:	string;

begin
str[0] := char(length(Hardware) div 2);
for i:=1 to length(str) do
	str[i] := char(
		((integer(Hardware[(i) * 2-1])-integer('0')) shl 4)
		or (integer(Hardware[(i) * 2])-integer('0'))
		);
sablon[Kod_helye] := byte(length(str));
for i := Kod_helye+1 to Kod_helye+length(str) do
	sablon[i] := byte(kod[(byte(str[i-Kod_helye])+i-Kod_helye) mod 255]);
end;


function kodolas(var str : string) : boolean;
var     i       :	byte;
	str1	:	string;
	servernev,szamok,szamstring	:	string;
	netvaltozat,netalvaltozat 	:	byte;
	maxkapcs,hasznkapcs,maxloglemez :	word;
	foglalt 			:	string;

begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	(get_server_information(servernev,netvaltozat,netalvaltozat,maxkapcs,hasznkapcs,maxloglemez,foglalt) <> 0);
hiba := hiba or
	(read_properity(servernev,$0400,'NET_ADDRESS',1,sablon) <> 0);
{$endif									}
for i := 0 to 15 do
	str1[i+1] := char(sablon[i]);
str1[0] := char(12);
str[0] := str1[0];
for i := 1 to length(str) do
	str[i] := char(kod[(byte(str1[i])+i) mod 255]);
if hiba then error(43,'e');				{ halozati hiba	}
kodolas := hiba;
end;

function statikuskod : boolean;
label	vege;
var	i	:	byte;
	str1	:	string;
	str2 	:	string;
begin
if kodolas(str1) then	goto	vege;
{$ifdef novell_386							}
	drotozas;
{$else									}
hiba :=	readproperity;
{$endif									}
for i := Kod_helye to	Kod_helye+length(str1) do
	str2[i-Kod_helye] := char(sablon[i]);
hiba := hiba or
{$ifdef test_nh							}
	false;
{$else									}
	not (str1 = str2);
{$endif									}
if hiba then error(44,''); 				{  nincs_kulcs	}
vege :
statikuskod := hiba;
end;

function openszemafor : boolean;
var	hanyan_hasznaljak,i	:	byte;
begin
hanyan_hasznaljak := 1;
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	open_semaphore(Semaphore_name,1,handle,hanyan_hasznaljak) <>0 ;
if hiba then error(43,'f');				{ halozati hiba	}
{$endif									}

{$ifdef novell_386							}
{$else									}
if hanyan_hasznaljak = 1 then
	begin
	hiba := hiba or readproperity;
	for i:= Kod_helye-Jogosultak_szama to Kod_helye-1 do
		sablon[i] := connect_kod(Ures);
	hiba := hiba or writeproperity;
	end;
{$endif									}
if hanyan_hasznaljak > Jogosultak_szama then
	begin
	hiba := TRUE;
	error(45,'');				{ minden hely foglalt	}
	end;
openszemafor := hiba;
end;

function waitszemafor : boolean;
begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	wait_semaphore(handle,18) <> 0;
{$endif									}
if hiba then error(43,'g');				{ halozati hiba	}
waitszemafor := hiba;
end;

function szignalszemafor : boolean;
begin
hiba :=
{$ifdef test_nh							}
	false;
{$else									}
	signal_semaphore(handle) <> 0;
{$endif									}
if hiba then error(43,'h');				{ halozati hiba	}
szignalszemafor := hiba;
end;

function closeszemafor : boolean;
begin
hiba :=
{$ifdef test_nh}
	false;
{$else}
	close_semaphore(handle) <> 0;
{$endif}
if hiba then error(43,'i');				{ halozati hiba	}
  closeszemafor := hiba;
end;

procedure get_ekszer_dir;
var
  P: PathStr;
  D: DirStr;
  N: NameStr;
  E: ExtStr;
  c: char;
  l:integer;
begin
FSplit(ParamStr(0),D,N,E);
l := length(D);
c := d[l];
Ekszerdir := D;
if (c='\') or (c='/') then
        if d[l-1]<>':' then      Ekszerdir[0] := char(integer(d[0])-1);
end;

procedure goto_ekszer_dir;
begin
getdir(0,Workingdir);
chdir(Ekszerdir);
end;

procedure goto_work_dir;
begin
chdir(Workingdir);
end;

var	i	:	integer;
begin
{$ifdef test_nh							}
   for i:=0 to 127 do
	sablon[i] := connect_kod(Ures);
{$else									}
   for i:=0 to 127 do
	sablon[i] := connect_kod(3);
{$endif									}
{$ifdef tesztverzio							}
assign(f,'');
Rewrite(f);
{$endif									}

end.

{ novellfg end 								}

