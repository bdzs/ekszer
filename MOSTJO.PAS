program	mostjo;

uses	crt,halozat;

var
	c	:char;
        f	:text;

begin
Assign(f, '');
Rewrite(f);
writeln(f,'---------------------------------------------------------------------');
writeln;
writeln(f,'indul a program (mostjo)');
if (Hindul) then
	writeln(f,'ok                     (mostjo)')
else
	writeln(f,' Elszalltam indul      (mostjo)');
{$ifndef batch								}
c:=readkey;
{$endif									}
if (Hment) then
	writeln(f,'ok                     (mostjo)')
else
	writeln(f,' Elszalltam ment       (mostjo)');
{$ifndef batch								}
c:=readkey;
{$endif									}
if (Hkilep) then
	writeln(f,'ok                     (mostjo)')
else
	writeln(f,' Elszalltam kilep      (mostjo)');
{$ifndef batch								}
c:=readkey;
{$endif									}
writeln(f,'kilepett a program     (mostjo)');
end.

