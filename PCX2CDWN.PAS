{$A-,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 64384,0,0}

Program PCX_to_CDW_PIC;

uses DOS, CRT;

const maxXbytes = 78*36 div 8;  {ennyit bir el a CDW}

{$IFDEF NORVEG}
const errorWriting = #13+#10+'Feil ved skriving';
      errorReading = #13+#10+'Feil ved lesing';
      fileNOTfound = #13+#10+'Finner ikke fil : ';
      help         = #13+#10+'PCX fil-navn mÜ oppgis.';
      nemPCXfile   = #13+#10+'Ikke PCX fil-format ';
      canNOTopen   = #13+#10+'Kan ikke Üpne ';
      notBWpicture = #13+#10+'Bildet er ikke et sort/hvitt bilde.';
      tooBIGpicture= #13+#10+'Bildet er for stort for Protex, hõyre side kuttes ut.';
      processed    = 'Bearbeidet linjer: ';
      converting   = 'Konverterer fil ';
      title        = '.PCX -> .@@@ Fil konvertering for Protex +';
      shortFile    = #13+#10+'Fil-stõrrelse mindre enn forventet !!! ';

{$else}

  {$ifdef angol}
  const errorWriting = #13+#10+'Error Writing ';
        errorReading = #13+#10+'Error Reading ';
        fileNOTfound = #13+#10+'File not found: ';
        help         = #13+#10+'A PCX file name must specified.';
        nemPCXfile   = #13+#10+'No PCX file format ';
        canNOTopen   = #13+#10+'Cannot open ';
        notBWpicture = #13+#10+'The picture contains more then 1 color planes.';
        tooBIGpicture= #13+#10+'The picture is too wide for CdWord, rigth side will be cut off.';
        processed    = 'Processed lines: ';
        converting   = 'Converting ';
        title        = '.PCX -> .@@@ File Converter for ProTex';
        shortFile    = #13+#10+'File size shorter then expected !!! ';

  {$else}
  const errorWriting = #13+#10+'File °r†si hiba ';
        errorReading = #13+#10+'File olvas†si hiba ';
        fileNOTfound = #13+#10+'A file nem tal†lhat¢: ';
        help         = #13+#10+'Egy PCX file nevÇt kell megadni.';
        nemPCXfile   = #13+#10+'Nem PCX file form†tum ';
        canNOTopen   = #13+#10+'Nem tudom megnyitni ';
        notBWpicture = #13+#10+'A kÇp tîbb sz°n s°kot tartalmaz.';
        tooBIGpicture= #13+#10+'A kÇp t£l szÇles az êkSzer+ sz†m†ra, jobb szÇle le lesz v†gva.';
        processed    = 'Feldolgozott sor: ';
        converting   = 'Konvert†land¢ file: ';
        title        = '.PCX -> .@@@ File Konvert†l¢ Program êkSzer-hez';
        shortFile    = #13+#10+'A file mÇrete kisebb az elv†rtn†l !!! ';

  {$endif}
{$endif}

Var fin,fout : file;
    Header: record
             id     : byte;
             ver    : byte;
             coding : byte;
             bitppix: byte;
             upleftx: word;
             uplefty: word;
             lorightx:word;
             lorighty:word;
             dispxres:word;
             dispyres:word;
             palette : array[1..48] of byte;
             semmi1  : byte;
             nplanes : byte;
             bytespline: word;
             palinfo   : word;
             semmi2    : array[1..58] of byte;
            end;

    by,p : byte;
    line : array[0..$4000] of byte;
    memofs: word;
    regs  : registers;
    lefele: word;
    ysor  : word;
    fnevbe, fnevki : string[64];
    ennyi_mehet_ki : word;
    c : char;
    Xpont,
    Xbyte   : Word;

Const qq : array[1..50] of string=
('','','','','','','','','','',
'','','','','','','','','','',
'','','','','','','','','','',
'','','','','','','','','','',
'','','','','','','','','',''
);


Procedure WriteLine;

var kiment: word;

Begin

  {$i-}
  blockwrite(fout,Line[0],Xbyte,kiment);
  {$i+}
  if (ioresult <> 0) or (kiment <> Xbyte)  then
    Begin
      writeln(errorWriting, fnevki);
      close(fin);
      close(fout);
      halt(1);
    End;
End;



Procedure ReadLine;

var pufpoint, len, i, bejott: word;
    elso : boolean;

Begin
  qq[1] := '';
  elso := true;
  pufpoint := 0;
         i := 0;

  while i < header.bytespline * header.nplanes do
    Begin
       {$i-}
       blockread(fin,by,1,bejott);
       {$i+}
       if (ioresult <> 0) or (bejott <> 1) then
         Begin
          if elso then
           begin
            gotoxy(1,wherey);  write(processed, lefele+1);
            writeln;
            writeln(shortFile);
            close(fin);
            close(fout);
            reset(fout,1);
            line[0] := lo(Xpont);
            line[1] := hi(Xpont);
            line[2] := lo(lefele);
            line[3] := hi(lefele);
            blockwrite(fout,line[0],4);
            close(fout);
            halt(1);
           end;
          writeln(errorReading, fnevbe);
          close(fin);
          close(fout);
          halt(1);
         End;

       elso := false;
       if (by and $c0) = $c0  then
         begin
           len := by and $3f;
           {$i-}
           blockread(fin,by,1,bejott);
           {$i+}
           if (ioresult <> 0) or (bejott <> 1) then
             Begin
              writeln(errorReading, fnevbe);
              close(fin);
              close(fout);
              halt(1);
             End;
           fillchar(line[pufpoint],len,by);
           inc(pufpoint,len);
           inc(i,len)
         end
       else
         Begin
           line[pufpoint] := by;
           inc(pufpoint);
           inc(i);
         End;
    End;
End;


Begin

  writeln(title);
  writeln;

  if (paramcount <> 1) or (paramstr(1) = '?') then
    begin
     writeln(help);
     halt(1);
    end;

  fnevbe := paramstr(1);
  p := pos('.',fnevbe);
  if p > 0 then fnevbe[0] := chr(p-1);

  fnevki := fnevbe + '.@@@';
  fnevbe := fnevbe + '.PCX';

  assign(fin, fnevbe);
  {$i-}
  reset(fin,1);
  if ioresult <> 0 then
         Begin
          writeln(fileNOTfound, fnevbe);
          halt(1);
         End;

  blockread(fin,Header,128);
  {$i+}

  { ======================= ARTNER ============== }
  dec(header.lorighty,15);

  if header.id <> 10 then
    Begin
      writeln(fnevbe, nemPCXfile);
      close(fin);
      halt(1);
    End;

  if header.nplanes <> 1 then
      writeln(notBWpicture);

  ennyi_mehet_ki := header.bytespline;

  assign(fout,fnevki);
  {$i-}
  rewrite(fout,1);
  {$i+}
  if ioresult <> 0 then
         Begin
          writeln(canNOTopen, fnevki);
          halt(1);
         End;


  ysor    := header.lorighty - header.uplefty + 1;
  Xpont   := Header.LoRightX - Header.UpLeftX + 1;
  Xbyte   := (Xpont+7) Div 8;

  line[0] := lo(Xpont);
  line[1] := hi(Xpont);
  line[2] := lo(ysor);
  line[3] := hi(ysor);

  {$i-}
  blockwrite(fout,line[0],4);
  {$i+}
  if ioresult <> 0 then
         Begin
          writeln(errorWriting, fnevki);
          close(fin);
          halt(1);
         End;

  writeln;
  writeln(converting, fnevbe, ' -> ', fnevki);

  for lefele := 0 to (header.lorighty - header.uplefty) do
   begin
     readline;
     writeline;
     if lefele mod 10 = 0 then
      begin
        gotoxy(1,wherey);
        write(processed, lefele);
      end;
   end;

  gotoxy(1,wherey);  write(processed, lefele+1);
  close(fin);
  close(fout);


End.

(*

Procedure Displin;

var t: word;

Begin
 for t:= 0 to 79 do
  begin
   mem[$a000:memofs] := line[t];
   inc(memofs);
  end;
End;



Procedure ReadLin;

var pufpoint, len, i, bejott: word;

Begin

  pufpoint := 0;
         i := 0;

  while i < header.bytespline * header.nplanes do
    Begin
       blockread(fin,by,1);
       if (by and $c0) = $c0  then
         begin
           len := by and $3f;
           blockread(fin,by,1);
           fillchar(line[pufpoint],len,by);
           inc(pufpoint,len);
           inc(i,len)
         end
       else
         Begin
           line[pufpoint] := by;
           inc(pufpoint);
           inc(i);
         End;
    End;
End;


Begin  {                               MAIN  test                         }

  assign(fin, '\tp5\cdw\pcx4.pcx');
  reset(fin,1);
  blockread(fin,Header,128);

 with Header do
 begin
   writeln('id ',id);
   writeln('ver ',ver);
   writeln('bit pr pkt ',bitppix);
   writeln('Ant. lag ',nplanes);
   writeln('ù.v-x ',upleftx);
   writeln('ù.v-y ',uplefty);
   writeln('N.h-x ',lorightx);
   writeln('N.h-y ',lorighty);
   writeln('bytes p.linje ',bytespline);
   writeln('Pakking ',coding);
 end;

 c := readkey;

 memofs := 0;
 regs.ax:= $10;
 intr($10,regs);

 for lefele := 0 to (header.lorighty - header.uplefty -15)  do
   begin
    if memofs < $c000 then
     begin
       readlin;
       displin;
     end;
   end;

  close(fin);

 c := readkey;

 regs.ax:= $3;
 intr($10,regs);

End.
*)
