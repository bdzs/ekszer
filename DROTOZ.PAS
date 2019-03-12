program drotozas;
uses	novellib,titkok,windowm;
label	rossz,jo,vege;
var
	hiba	:	boolean;
        i	:	byte;
        p	:	Longint;
	c	:	byte;
	filename :	string;
	f	:	file of byte;
	servernev,szamok,szamstring	:	string;
	netvaltozat,netalvaltozat 	:	byte;
	maxkapcs,hasznkapcs,maxloglemez :	word;
	foglalt 			:	string;
	eleg_mar			:	boolean;
	sablon				:	sablon_tipus;


begin
assign(f,paramstr(1));
reset(f);
i := 1;
while i< length(Hardware) do
        begin
	read(f,c);
        if Eof(f) then goto rossz;
        if c = byte(Hardware[i]) then
        	inc(i)
        else	i := 1;
        end;
p := Filepos(f);
seek(f,p - (length(Hardware)-1));

hiba := get_server_information(servernev,netvaltozat,netalvaltozat,maxkapcs,hasznkapcs,maxloglemez,foglalt)<>0;
writeln(servernev);
hiba := hiba or (read_properity(servernev,$0400,'NET_ADDRESS',1,sablon)<>0);
if hiba then
        begin
	error(43,'');					{ halozati hiba	}
        goto	vege;
        end;
for i := 0 to 127 do
	szamok[i+1] := char(sablon[i]);
szamok[0]:=char(127);
szamstring:=hexa(szamok);
szamstring[0] := char(length(Hardware));
for i := 1 to length(szamstring) do
	write(f,byte(szamstring[i]));

jo:
goto	vege;

rossz:
writeln('  Nem ismertem fel a file-t ');

vege:
end.