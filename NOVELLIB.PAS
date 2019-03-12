
{ novellib.pas 								}

unit	novellib;
{$M 4096,0,0}


{$IFDEF HALO}

  {$DEFINE NOVELL_3}
  {$DEFINE NOVELL_386}
  {$DEFINE NUKU_HON}

{$ENDIF}


interface

type	sablon_tipus	=	array [0..127] of byte;

function conn_number 		: byte;
function verify_password	(objnev :string; tipus :word; passw :string) : byte;
function read_properity		(objnev :string; tipus :word; tulnev :string; szegm :byte; var adat :sablon_tipus) : byte;
function write_properity	(objnev :string; tipus :word; tulnev :string; szegm,vanmeg :byte; adat :sablon_tipus) : byte;

function create_object		(objnev :string; tipus :word; vedelem,s_d :byte) : byte;
function create_properity	(objnev :string; tipus :word; tulnev :string; vedelem,s_d : byte) : byte;
function change_password	(objnev :string; tipus :word; newpass,oldpass :string) :byte;


type	str4	=	array [0..3] of char;
type	handle_t	=	record
				cx,dx	:word;
				end;

function date_time_string	(var ev,ho,nap,ora,perc,ms,hetnapja : byte) : byte;
function get_serial_number	(var sorozat : str4) : byte;
function get_server_information (var servernev :string;var netvaltozat,netalvaltozat :byte;
					var maxkapcs,hasznkapcs,maxloglemez :word;var foglalt :string) : byte;
procedure get_shell_table	(var szamok : string) ;
function hexa			(t : string) : string;
function open_semaphore		(nev : string; ertek : byte;var handle :handle_t; var hasznaljak : byte) : byte;
function examine_semaphore	(handle :handle_t; var kezd_ertek :byte; var akt_ertek :integer ) : byte;
function wait_semaphore		(handle :handle_t; ido :word ) : byte;
function signal_semaphore	(handle :handle_t ) : byte;
function close_semaphore	(handle :handle_t ) : byte;

implementation
uses    dos ;

type
	rwprop= record
		length	:	word;
		ftype	:	byte;
		tipus	:	word;
		maradek	:	string;
		end;
	rprop = record
		length	:	word;
		adat	:	sablon_tipus;
		jelzo	:	byte;
		tul	:	byte;
		end;
	outbuf= record
		length	:	word;
		end;
	inbuf_createo = record
		length	:	word;
		ftype	:	byte;
		jelzo	:	byte;
		vedelem	:	byte;
		tipus	:	word;
		nev	:	string;
		end;
	inmin=	record
		length	:	word;
		ftype	:	byte;
		end;



function	conn_number	:	byte;

var	regs 	: 	registers;
begin
	regs.ah	:=	$dc;
	msdos(regs);
	conn_number	:=	regs.al;
end;


function verify_password(objnev :string; tipus :word; passw :string) : byte;

var	regs 	: 	registers;
	i,j	: 	integer;

	out     :       outbuf;
	inbuf   :       rwprop;
begin
inbuf.tipus:=tipus;
inbuf.ftype:=$3f;
for i:=0 to byte(objnev[0]) do
	inbuf.maradek[i]:=objnev[i];
inc(i);
for j:=0 to byte(passw[0]) do
	inbuf.maradek[i+j]:=passw[j];
inc(j);
inbuf.length:=3+i+j;
out.length:=sizeof(out)-2;

regs.ah:=$e3;
regs.ds:=seg(inbuf);
regs.si:=ofs(inbuf);
regs.es:=seg(out);
regs.di:=ofs(out);
{$ifdef novell_3							}
regs.al := 0;
{$else									}
msdos(regs);
{$endif									}
verify_password :=regs.al;
end;


function read_properity(objnev :string; tipus :word; tulnev :string; szegm :byte; var adat :sablon_tipus) : byte;

var	regs 	: 	registers;
	i,j	: 	integer;

	inbuf   :       rwprop;
	out2    :       rprop;

begin

	inbuf.tipus:=tipus;
	inbuf.ftype:=$3d;
	for i:=0 to byte(objnev[0]) do
		inbuf.maradek[i]:=objnev[i];
	inc(i);
	inbuf.maradek[i]:=char(szegm);
	inc(i);
	for j:=0 to byte(tulnev[0]) do
		inbuf.maradek[i+j]:=tulnev[j];
	inc(j);
	inbuf.length:=3+i+j;
	out2.length:=sizeof(out2)-2;

	regs.ah:=$e3;
	regs.ds:=seg(inbuf);
	regs.si:=ofs(inbuf);
	regs.es:=seg(out2);
	regs.di:=ofs(out2);
	msdos(regs);
	for i:=0 to 127 do
		adat[i]:=out2.adat[i];
	read_properity := regs.al;
end;


function write_properity(objnev :string; tipus :word; tulnev :string; szegm,vanmeg :byte; adat :sablon_tipus) : byte;

var	regs 	: 	registers;
	i,j	: 	integer;

	out     :       outbuf;
	inbuf   :       rwprop;
begin
	inbuf.tipus:=tipus;
	inbuf.ftype:=$3e;
	for i:=0 to byte(objnev[0]) do
		inbuf.maradek[i]:=objnev[i];
	inc(i);
	inbuf.maradek[i]:=char(szegm);
	inc(i);
	inbuf.maradek[i]:=char(vanmeg);
	inc(i);
	for j:=0 to byte(tulnev[0]) do
		inbuf.maradek[i+j]:=tulnev[j];
	inc(j);
	j:=j+i;
	for i:=0 to 127 do
		inbuf.maradek[j+i]:=char(adat[i]);
	inc(i);

	inbuf.length:=3+i+j;
	out.length:=sizeof(out)-2;

	regs.ah:=$e3;
	regs.ds:=seg(inbuf);
	regs.si:=ofs(inbuf);
	regs.es:=seg(out);
	regs.di:=ofs(out);
	msdos(regs);
	write_properity := regs.al;
end;


function create_object(objnev :string; tipus :word; vedelem,s_d :byte) : byte;

type
	inbuf_createo =
		record
		length	:	word;
		ftype	:	byte;
		jelzo	:	byte;
		vedelem	:	byte;
		tipus	:	word;
		nev	:	string;
		end;

var	regs	:	registers;
	i 	:	integer;
	inbuf	:	inbuf_createo;
	out	:	outbuf;
begin
	inbuf.ftype := $32;
	inbuf.jelzo := s_d;
	inbuf.vedelem := vedelem;
	inbuf.tipus := tipus;
	for i:=0 to byte(objnev[0]) do
		  inbuf.nev[i]:=objnev[i];
	inc(i);
	inbuf.length := 5+i;
	out.length := sizeof(out)-2;

	regs.ah:=$e3;
	regs.ds:=seg(inbuf);
	regs.si:=ofs(inbuf);
	regs.es:=seg(out);
	regs.di:=ofs(out);
	msdos(regs);
	create_object :=regs.al;
end;


function create_properity(objnev :string; tipus :word; tulnev :string; vedelem,s_d : byte) : byte;

var	regs	:	registers;
	i,j	:	integer;
	inbuf	:	rwprop;
	out	:	outbuf;
begin
	inbuf.ftype := $39;
	inbuf.tipus := tipus;
	for i:=0 to byte(objnev[0]) do
		  inbuf.maradek[i]:=objnev[i];
	inc(i);
	inbuf.maradek[i] := char(s_d);
	inc(i);
	inbuf.maradek[i] := char(vedelem);
	inc(i);
	for j:=0 to byte(tulnev[0]) do
		  inbuf.maradek[i+j]:=tulnev[j];
	inc(j);

	inbuf.length := 3+i+j;
	out.length := sizeof(out)-2;

	regs.ah:=$e3;
	regs.ds:=seg(inbuf);
	regs.si:=ofs(inbuf);
	regs.es:=seg(out);
	regs.di:=ofs(out);
	msdos(regs);
	create_properity := regs.al;
end;



function change_password(objnev :string; tipus :word; newpass,oldpass :string) : byte;


var	regs	:	registers;
	i,j	:	integer;
	inbuf	:	rwprop;  { tul rovid				}
	out	:	outbuf;
begin
inbuf.ftype := $40;
inbuf.tipus := tipus;
for i:=0 to byte(objnev[0]) do
	  inbuf.maradek[i]:=objnev[i];
inc(i);
for j:=0 to byte(oldPass[0]) do
	  inbuf.maradek[i+j]:=oldPass[j];
inc(j);
i := i + j;
for j:=0 to byte(newPass[0]) do
	  inbuf.maradek[i+j]:=newPass[j];
inc(j);

inbuf.length := 3+i+j;
out.length := sizeof(out)-2;

regs.ah:=$e3;
regs.ds:=seg(inbuf);
regs.si:=ofs(inbuf);
regs.es:=seg(out);
regs.di:=ofs(out);
{$ifdef novell_3							}
regs.al := 0;
{$else									}
msdos(regs);
{$endif									}
change_password := regs.al;
end;

function date_time_string(var ev,ho,nap,ora,perc,ms,hetnapja : byte) : byte;
type	outdate	=	record
			ev,ho,nap,ora,perc,ms,hetnapja : byte;
			end;

var	regs	:	registers;
	out	:	outdate;

begin
regs.ah:=$e7;
regs.ds:=seg(out);
regs.dx:=ofs(out);
msdos(regs);
ev := out.ev;
ho := out.ho;
nap := out.nap;
ora := out.ora;
perc := out.perc;
ms := out.ms;
hetnapja := out.hetnapja;
date_time_string := regs.al;
end;

function get_serial_number(var sorozat :str4) : byte;

type	outserial	=	record
				length	:	word;
				sorozat	:	str4;
				end;

var	regs 	: 	registers;
	i	:	integer;
	out     :       outserial;
	inbuf   :       inmin;
begin
inbuf.ftype:=$12;
inbuf.length := sizeof(inbuf)-2;
out.length :=	sizeof(out)-2;

regs.ah:=$e3;
regs.ds:=seg(inbuf);
regs.si:=ofs(inbuf);
regs.es:=seg(out);
regs.di:=ofs(out);
msdos(regs);
for i := 0 to 3 do
	sorozat[i] := out.sorozat[i];
get_serial_number :=regs.al;
end;


function get_server_information(var 	servernev 	:	string;
				var 	netvaltozat,
					netalvaltozat 	:	byte;
				var 	maxkapcs,
					hasznkapcs,
					maxloglemez 	:	word;
				var 	foglalt		:	string	) : byte;

type	outserial	=	record
				length	:	word;
				servernev :	array[0..47] of char;
				netvaltozat,
				netalvaltozat :	byte;
				maxkapcs,
				hasznkapcs,
				maxloglemez :	word;
				foglalt	:	array[0..71] of char;
				end;

var	regs 	: 	registers;
	i	:	integer;
	out     :       outserial;
	inbuf   :       inmin;
begin
inbuf.ftype:=$11;
inbuf.length := sizeof(inbuf)-2;
out.length :=	sizeof(out)-2;

regs.ah:=$e3;
regs.ds:=seg(inbuf);
regs.si:=ofs(inbuf);
regs.es:=seg(out);
regs.di:=ofs(out);
msdos(regs);
for i := 0 to 47 do
	servernev[i+1] := out.servernev[i];
i := 0 ;
while (out.servernev[i]<>char(0)) and (i<48) do
	inc(i);
servernev[0] := char(i);
netvaltozat := out.netvaltozat;
netalvaltozat := out.netalvaltozat;
maxkapcs := swap(out.maxkapcs);
hasznkapcs := swap(out.hasznkapcs);
maxloglemez :=swap(out.maxloglemez);
for i := 0 to 71 do
	foglalt[i+1] := out.foglalt[i];
foglalt[0] := char(72);
get_server_information :=regs.al;
end;

procedure get_shell_table(var szamok :string) ;

type	shell_t3 	=	record
			case a:byte of
			   1:   (
				slothaszn,
				serversz	:	byte;
				serverhsz	:	array [0..3] of byte;
				servercssz	:       array [0..5] of byte;
				serverssz	:	array [0..1] of byte;
				routerinf	:	array [0..11] of byte;
				);
			   2:   (
				egybe           :	array [1..25] of byte;
				)
				end;
var	regs 	: 	registers;
	i	:	integer;
	out     :       ^shell_t3;
begin
regs.al := 3;
regs.ah := $ef;
msdos(regs);
out := ptr(regs.es,regs.si);
szamok[0] := char(25);
for i:= 1 to 25 do
	szamok[i] := char(out^.egybe[i]);
end;

function hexjegy(i:byte):char;
begin
if i>9 then
	hexjegy:=char(byte('A')+i-10)
else	hexjegy:=char(byte('0')+i);
end;

function hexa(t:string):string;
var	h,i	:	byte;
	st	:	string;
	c1,c2	:	byte;
begin
h := length(t);
st[0] := char(2*h);
for i := 1 to h do
	begin
	c1 := byte(t[i]);
	c2 := byte(integer(c1) and $0f);
	c1 := c1 shr 4;
	st[2*i-1] := hexjegy(c1);
	st[2*i  ] := hexjegy(c2);
	end;
hexa := st;
end;

function open_semaphore(nev : string; ertek : byte;var handle :handle_t; var hasznaljak : byte) : byte;
var	regs 	: 	registers;
begin
regs.ah := $c5;
regs.al := 0;
regs.cl := ertek;
regs.ds := seg(nev);
regs.dx := ofs(nev);
msdos(regs);
handle.cx := regs.cx;
handle.dx := regs.dx;
hasznaljak := regs.bl;
open_semaphore := regs.al;
end;

function examine_semaphore(handle :handle_t; var kezd_ertek :byte; var akt_ertek :integer ) : byte;
var	regs 	: 	registers;
begin
regs.ah := $c5;
regs.al := 1;
regs.cx := handle.cx;
regs.dx := handle.dx;
msdos(regs);
kezd_ertek := regs.dl;
akt_ertek := regs.cx;
examine_semaphore := regs.al;
end;

function wait_semaphore(handle :handle_t; ido :word ) : byte;
var	regs 	: 	registers;
begin
regs.ah := $c5;
regs.al := 2;
regs.cx := handle.cx;
regs.dx := handle.dx;
regs.bp := ido;
msdos(regs);
wait_semaphore := regs.al;
end;

function signal_semaphore(handle :handle_t ) : byte;
var	regs 	: 	registers;
begin
regs.ah := $c5;
regs.al := 3;
regs.cx := handle.cx;
regs.dx := handle.dx;
msdos(regs);
signal_semaphore := regs.al;
end;

function close_semaphore(handle :handle_t ) : byte;
var	regs 	: 	registers;
begin
regs.ah := $c5;
regs.al := 4;
regs.cx := handle.cx;
regs.dx := handle.dx;
msdos(regs);
close_semaphore := regs.al;
end;



begin
end.

{ novellib end 								}

