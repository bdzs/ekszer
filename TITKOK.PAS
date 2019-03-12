unit titkok;

interface

const

Object_nev 	: string[47]	=	'PRINTDEF0';
Object_tipus 	: word		=	$0180;		{ > 8000h es swap }
Password 	: string[127]	=	'ExerJelszo1';
csali_Password  : string[127]	=	'ExerExer';
Tulajdonsag_nev : string[15] 	=	'TULAJDONSAG';
Hardware	: string[12*2]	=       '000000500000290001090451';
{Jogosultak_szama: byte		=	100; <= 100 Atkerult a cdwhun.def-be}

Semaphore_name	: string[127]	=	'hallali hallali hoooo';
Kod_helye	: byte		=	100;            { = maxcon	}
Ures				=       0;

{$i		kod.pas							}

implementation

begin
end.

end.
{ titkok.pas end							}