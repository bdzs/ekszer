UNIT Publicat;


INTERFACE

USES Crt,InputCdw,FileCdw,WindowM,Video;

PROCEDURE New_Publicat;

PROCEDURE Edit_Publicat(Belso_hivas : boolean);

PROCEDURE Subs_Publicat;

PROCEDURE Add_Publicat;

PROCEDURE Move_Doc_In_Publicat;

FUNCTION  Nev_ad(ut_file : FnTyp ) : FnTyp;

IMPLEMENTATION


CONST PubFileSize = (FnSize+1)*(FnSize+1);

VAR IORES   : integer;
    C_Fil   : file;
    Pb_file : file;

FUNCTION Nagybetu(szoveg : string) : string;

VAR cikl : byte;

BEGIN
  For cikl:=1 to Length(szoveg) do szoveg[cikl]:=UpCase(szoveg[cikl]);
  Nagybetu:=szoveg;
End;

FUNCTION  Nev_ad(ut_file : FnTyp ) : FnTyp;

VAR  reszut : fntyp;

BEGIN
  reszut:=copy(ut_file,BackFind(ut_file,'\')+1,12);
  Nev_ad:=reszut;
End;

FUNCTION FileEllenor(fileut : FnTyp): boolean ;

VAR eleje : string[4];

BEGIN
  Assign(C_fil,Fileut);
  {$I-}
  ReSet(C_fil,1);
  {$I+}
  If IOResult<>0 then FileEllenor:=False
  else
    BEGIN
      eleje[0]:=#4;
      {$I-}
      BlockRead(C_fil,eleje[1],4);
      {$I+}
      If IOResult<>0 then FileEllenor:=False
      else
        If eleje=#0+'CD'+#0 then FileEllenor:=True
        else FileEllenor:=False;
      {$I-}
      Close(C_fil);
      {$I+}
      IORES:=IOResult;
      IORES:=0;
    End;
End;

FUNCTION  FileNevValaszt(Abl_szov : string; Mask : string;
                         VAR Kiadv_tart : Doc_sor; Add_e : boolean) : FnTyp;

VAR  KiFileNev : FnTyp;
     valaszt   : nevtomb;
     val_db    : word;
     val_ut    : string;
     cikl      : word;
     index     : array [0..FnSize] of byte absolute Kiadv_tart;
     maradek   : string[4];
     sza1,sza2,
     sza3      : word;

FUNCTION Mar_van : boolean;

VAR c_m : byte;

BEGIN
  c_m:=2;
  If Index[0]>1 then
    While (c_m<=Index[0]) and
          (Kiadv_tart[c_m]<>NagyBetu(AddBack(val_ut)+valaszt[cikl])) do
            Inc(c_m)
  else
    BEGIN
      mar_van:=False;
      Exit;
    End;
  If c_m<=Index[0] then
    BEGIN
      Error(12,NagyBetu(AddBack(val_ut)+valaszt[cikl]));
      Mar_van:=True;
    End
  else Mar_van:=False;
End;

BEGIN
  val_ut:='';
  bool:=Create_Window(35,9,79,13,Abl_szov,CA[DispMode,1],CA[DispMode,3]);
  REPEAT
    ESC:=False;
    CurOn;
    MaxStringLen:=60;
    KiFileNev:='';
    GoToXY(2,2);
    Input_FileName(Fejcim,KiFileNev,20,False);
    CurOff;
    If ESC then
      BEGIN
        FileNevValaszt:='';
        bool:=Remove_window;
        Exit;
      End
    else If KiFileNev<>'' then CheckFileName(KiFileNev);
  UNTIL not ESC;
  bool:=Remove_window;

  If KiFileNev='' then KiFileNev:='*';

  If ((Pos('*',KiFileNev)>0) or (Pos('?',KiFileNev)>0)) then
    BEGIN
      If (BackFind(KiFileNev,'.') in [1..4]) and
         (Pos(Mask,KiFileNev)=BackFind(KiFileNev,'.')-1) then
          KiFileNev:=copy(KiFileNev,1,BackFind(KiFileNev,'.')-1)+'.'+Mask
      else
        If Pos('.',KiFileNev)=0 then KiFileNev:=KiFileNev+'.'+Mask;
      If Add_e then enged:=1;
      Dir(KiFileNev,valaszt,val_db,val_ut);
      enged:=0;
      If val_ut='' then val_ut:=NagyBetu(Path)
      else val_ut:=NagyBetu(val_ut);
      If ESC then
        BEGIN
          FileNevValaszt:='';
          Exit;
        End;
      If Add_e then
        BEGIN
          cikl:=1;
          While (cikl<=val_db) and (Index[0]<76) do
            BEGIN
              If not Mar_van then
                If FileEllenor(AddBack(val_ut)+valaszt[cikl]) then
                  BEGIN
                    Inc(Index[0]);
                    Index[Index[0]]:=Index[0];
                    Kiadv_tart[Index[0]]:=AddBack(val_ut)+NagyBetu(valaszt[cikl]);
                  End
                else Error(38,valaszt[cikl]);
              Inc(cikl);
            End;
          Str((Val_db-cikl):3,maradek);
          If cikl>76 then Error(37,maradek);
        End
      else
        BEGIN
          KiFileNev:=AddBack(val_ut)+valaszt[1];
          KiFileNev:=NagyBetu(KiFileNev);
          FileNevValaszt:=KiFileNev;
        End;
    End
  else
    BEGIN
      sza1:=BackFind(KiFileNev,'.');
      sza3:=BackFind(KiFileNev,'\');
      sza2:=Length(KiFileNev)-sza1;
      If (sza2 in [1..4]) and (Pos(Mask,KiFileNev)=sza1+1) then
          KiFileNev:=copy(KiFileNev,1,BackFind(KiFileNev,'.')-1)+'.'+Mask
      else KiFileNev:=KiFileNev+'.'+Mask;

      KiFileNev:=NagyBetu(KiFileNev);
      FileNevValaszt:=KiFileNev;
      If sza3>0 then
        BEGIN
          val_ut:=copy(KiFileNev,1,sza3);
          valaszt[1]:=copy(KiFileNev,sza3+1,255);
        End
      else valaszt[1]:=KiFileNev;
      If Add_e then
        If not Mar_van then
          If FileEllenor(AddBack(val_ut)+valaszt[1]) then
            BEGIN
              Inc(Index[0]);
              Index[Index[0]]:=Index[0];
              Kiadv_tart[Index[0]]:=AddBack(val_ut)+valaszt[1];
            End
          else Error(38,valaszt[1]);
    End;
End;


PROCEDURE PublFileRead(VAR tartalom : Doc_sor; VAR hibas : boolean);

BEGIN
  Assign(Pb_file,Pub_nev);
  {$I-}
  ReSet(Pb_file,1);
  {$I+}
  If IOResult<>0 then
    BEGIN
      hibas:=False;
      Error(3,'');
      Exit;
    End;
  {$I-}
  BlockRead(Pb_file,Tartalom,PubFileSize);
  {$I+}
  IORES:=IOResult;
  If IORES<>0 then
    BEGIN
      hibas:=False;
      Error(6,'');
      Exit;
    End;
  hibas:=True;
  {$I-}
  Close(Pb_file);
  {$I+}
  IORES:=IOResult;
End;

PROCEDURE PublFileWrite(tartalom : Doc_sor);

BEGIN
  Assign(Pb_file,Pub_nev);
  {$I-}
  ReSet(Pb_file,1);
  {$I+}
  IORES:=IOResult;
  If IORES<>0 then
    BEGIN
      Error(3,'');
      Exit;
    End;
  {$I-}
  BlockWrite(Pb_file,Tartalom,PubFileSize);
  {$I+}
  IORES:=IOResult;
  If IORES<>0 then
    BEGIN
      Error(26,'');
      Exit;
    End;
  {$I-}
  Close(Pb_file);
  {$I+}
  IORES:=IOResult;
End;


(****************************************************************************)

PROCEDURE New_Publicat;

VAR ch      : char;
    Kiadv_tart : Doc_sor;
    Kiadv_ind  : array [0..FnSize] of byte absolute Kiadv_tart;

BEGIN
  bool:=Create_Window(35,9,79,13,Menu_duma(6,1),CA[DispMode,1],CA[DispMode,3]);
  REPEAT
    ESC:=False;
    CurOn;
    MaxStringLen:=60;
    Pub_nev:='';
    GoToXY(2,2);
    mentes_e:=True;
    Input_FileName(Fejcim,Pub_nev,20,False);
    mentes_e:=False;
    CurOff;
    If ESC then
      BEGIN
        Bool:=Remove_Window;
        Exit;
      End;
    If (Pub_nev<>'') and (Pos('*',Pub_nev)=0) and (Pos('?',Pub_nev)=0) then CheckFileName(Pub_nev)
    else
      BEGIN
        Error(34,Pub_nev);
        ESC:=True;
      End;
  UNTIL not ESC;

  If BackFind(Pub_nev,'.') in [1..4] then
      Pub_nev:=copy(Pub_nev,1,BackFind(Pub_nev,'.')-1)+'.pub'
  else Pub_nev:=Pub_nev+'.pub';
  Assign(Pb_file,Pub_nev);
  {$I-}
  ReSet(Pb_file,1);
  {$I+}
  IORES:=IOResult;
  If IORES=2 then
    BEGIN
      {$I-}
      ReWrite(Pb_file,1);
      {$I+}
      If IOResult<>0 then
        BEGIN
          Error(3,'');
          Bool:=Remove_Window;
          Exit;
        End;
      FillChar(Kiadv_tart,PubFileSize,0);
      Kiadv_ind[0]:=1;
      Kiadv_ind[1]:=1;
      Kiadv_tart[1]:='KIADVANY';
      {$I-}
      Close(Pb_file);
      {$I+}
      IORES:=IOResult;
      PublFileWrite(Kiadv_tart);
      If IORES<>0 then Exit;
      Bool:=Remove_window;
    End
  else
    BEGIN
      If IORES=0 then
        BEGIN
          bool:=Create_Window(50,14,72,17,'',CA[DispMode,4],CA[DispMode,5]);
          Write(Felulir_e);
          REPEAT
            ch:=UpCase(ReadKey);
          UNTIL (ch in [YesChar,NoChar,#27]);
          Bool:=Remove_Window;
          bool:=Remove_window;
          If ch=YesChar then
            BEGIN
              {$I-}
              ReWrite(Pb_file,1);
              {$I+}
              If IOResult<>0 then
                BEGIN
                  Error(3,'');
                  Exit;
                End;
              FillChar(Kiadv_tart,PubFileSize,0);;
              Kiadv_ind[0]:=1;
              Kiadv_ind[1]:=1;
              Kiadv_tart[1]:='KIADVANY';
              {$I-}
              Close(Pb_file);
              {$I+}
              IORES:=IOResult;
              PublFileWrite(Kiadv_tart);
              If IORES<>0 then Exit;
            End;
        End;
    End;
  EditNum:=1;
  Edit_Publicat(True);
End;


(***************************************************************************)


{ Kiadv_tart-ot globalissa kell tenni es nem szabad torolni
  es megtartani vagy torolni }

PROCEDURE Edit_Publicat(Belso_hivas : boolean);

VAR cikl       : byte;
    c_fil      : file;
    Kiadv_tart : Doc_sor;
    Kiadv_ind  : array [0..FnSize] of byte absolute Kiadv_tart;
    Be_hiba    : boolean;
    ch         : char;

BEGIN
  If not Belso_hivas then
    BEGIN
      Pub_nev:=FileNevValaszt(Menu_duma(6,2),PublMask,Kiadv_tart,False);
      If ESC then Exit;
      PublFileRead(Kiadv_tart,Be_hiba);
      If not Be_hiba then Exit;
      Editnum:=GeditNum;
      ESC:=False;
      If (Valtozas[EditNum]) then
        If not (Are_You_Sure(EditNum,Single) and ESC) then
          BEGIN
            ESC:=False;
            Temp_BackUp(NormalMode);
            Valtozas[EditNum]:=False;
          End
        else Valtozas[EditNum]:=False;
      If Kiadv_tart[0]>#1 then
        BEGIN
          FileName[EditNum]:=Nev_Ad(Kiadv_tart[Kiadv_ind[2]]);
          Load(Kiadv_tart[Kiadv_ind[2]],Document,NoWriteMode);
          Fresh_Info;
          Akt_kiadv_szam:=2;
        End;
    End
  else
    BEGIN
      PublFileRead(Kiadv_tart,Be_hiba);
      If not Be_hiba then Exit;
    End;
  If Kiadv_ind[0]>1 then
    BEGIN
      cikl:=2;
      While (cikl<=Kiadv_ind[0]) and (Kiadv_ind[0]>1) do
        If Kiadv_ind[cikl]>0 then
          BEGIN
            If not FileEllenor(Kiadv_tart[cikl]) then
              BEGIN
                Error(35,Kiadv_tart[cikl]);
                Move(Kiadv_ind[cikl],Kiadv_ind[cikl+1],Kiadv_ind[0]-cikl);
                If Kiadv_ind[0]>1 then Dec(Kiadv_ind[0]);
                PublFileWrite(Kiadv_tart);
                If IORES<>0 then Exit;
              End
            else Inc(cikl);
          End;
      If Kiadv_ind[0]=0 then Error(36,Pub_nev);
    End
  else
    BEGIN
      If not Belso_hivas then Error(36,Pub_nev);
      Exit;
    End;
End;

(***************************************************************************)

PROCEDURE Subs_Publicat;

CONST Csik : String[18] = '컴컴컴컴컴컴컴컴컴';

VAR nevek      : nevtomb;
    valasz     : attrtomb;
    cikl       : byte;
    Kiadv_tart : Doc_sor;
    Kiadv_ind  : array [0..FnSize] of byte absolute Kiadv_tart;
    Be_hiba    : boolean;
    vonnal     : string;
    d_x        : byte;
    van        : boolean;

BEGIN
  ESC:=False;
  If Pub_nev='' then
    BEGIN
      Error(39,'');
      Exit;
    End;
  PublFileRead(Kiadv_tart,be_hiba);
  If not Be_hiba then Exit;
  If Kiadv_ind[0]<2 then
    BEGIN
      Error(36,Pub_nev);
      Exit;
    End;
  For cikl:=1 to Kiadv_ind[0] do
    nevek[cikl]:=Nev_ad(Kiadv_tart[Kiadv_ind[cikl]]);

  Set_Choose(5,7,76,18,12,0);  {Default}

  BOOL := CREATE_WINDOW(Wkx1-1,Wky1-1,Wkx2+1,Wky2+1,'*.DOC',CA[DispMode,1],CA[DispMode,20]);
  ClrScr;
  If (Wkx2-Wkx1)>18 then Csik[0]:=#18
  else Csik[0]:=Char(Wkx2-Wkx1);
  Display(Csik,Wky2+1,Wkx1+2);

  Csik[0]:=#18;
  Vonnal:=Csik+Csik;
  d_x:=Wkx2-Wkx1-5;
  d_x:=d_x div 2;
  Vonnal[0]:=Char(d_x);
  Vonnal[0]:=#36;

  enged:=1;
  nev_db:=Kiadv_ind[0];
  dir_db:=0;
  Set_Choose(5,7,76,18,12,0);  {Default}
  Choose(nevek,valasz,Kiadv_ind[0],0,cikl,cikl,cikl);
  enged:=0;
  Bool:=Remove_Window;
  cikl:=2;
  While (cikl<=Kiadv_ind[0]) do
    If valasz[cikl]>0 then
      BEGIN
        Move(Kiadv_ind[cikl+1],Kiadv_ind[cikl],Kiadv_ind[0]-cikl);
        Move(valasz[cikl+1],valasz[cikl],Kiadv_ind[0]-cikl);
        If Kiadv_ind[0]>1 then Dec(Kiadv_ind[0]);
        If IORES<>0 then Exit;
      End
    else Inc(cikl);
  PublFileWrite(Kiadv_tart);
End;

(***************************************************************************)

PROCEDURE Add_Publicat;

VAR adando     : FnTyp;
    Kiadv_tart : Doc_sor;
    Kiadv_ind  : array [0..FnSize] of byte absolute Kiadv_tart;
    Be_hiba    : boolean;
    Old_db     : byte;

BEGIN
  ESC:=False;
  If Pub_nev='' then
    BEGIN
      Error(39,'');
      Exit;
    End;
  PublFileRead(Kiadv_tart,be_hiba);
  If not Be_hiba then Exit;
  Old_db:=Kiadv_ind[0];
  adando:='';
  adando:=FileNevValaszt(Menu_Duma(6,4),'DOC',Kiadv_tart,True);
  If ESC then Exit;
  PublFileWrite(Kiadv_tart);
  If (Old_db=1) and (Kiadv_ind[0]>1) then
    BEGIN
      FileName[EditNum]:=Nev_Ad(Kiadv_tart[Kiadv_ind[2]]);
      Load(Kiadv_tart[Kiadv_ind[2]],Document,NoWriteMode);
      Fresh_Info;
      Akt_kiadv_szam:=2;
    End;
End;

(***************************************************************************)



PROCEDURE Move_Doc_In_Publicat;

CONST Csik : String[18] = '컴컴컴컴컴컴컴컴컴';

VAR cikl       : byte;
    Kiadv_tart : Doc_sor;
    Kiadv_ind  : array [0..FnSize] of byte absolute Kiadv_tart;
    Be_hiba    : boolean;
    hanyadik   : byte;
    hova       : byte;
    nevek      : nevtomb;
    valasz     : attrtomb;
    vonnal     : string;
    d_x        : byte;
    van        : boolean;

PROCEDURE Reff_ress;

BEGIN
  If Hova<=akt_kiadv_szam then
    BEGIN
      EditNum:=GeditNum;
      FileName[EditNum]:=Nev_Ad(Kiadv_tart[Kiadv_ind[Akt_kiadv_szam]]);
      Load(Kiadv_tart[Kiadv_ind[2]],Document,NoWriteMode);
      Fresh_Info;
    End;
End;

PROCEDURE Csere(Kezd : byte);

VAR By : byte;

BEGIN
  By                 :=Kiadv_ind[Kezd];
  Kiadv_ind[Kezd]    :=Kiadv_ind[Kezd+1];
  Kiadv_ind[Kezd+1]  :=By;
End;

BEGIN
  ESC:=False;
  If Pub_nev='' then
    BEGIN
      Error(39,'');
      Exit;
    End;
  PublFileRead(Kiadv_tart,be_hiba);
  If not Be_hiba then Exit;
  If Kiadv_ind[0]<2 then
    BEGIN
      Error(36,Pub_nev);
      Exit;
    End;
  For cikl:=1 to Kiadv_ind[0] do
    nevek[cikl]:=Nev_ad(Kiadv_tart[Kiadv_ind[cikl]]);

  Set_Choose(5,7,76,18,12,0);  {Default}

 BOOL := CREATE_WINDOW(Wkx1-1,Wky1-1,Wkx2+1,Wky2+1,'*.DOC',CA[DispMode,1],CA[DispMode,20]);
  ClrScr;
  If (Wkx2-Wkx1)>18 then Csik[0]:=#18
  else Csik[0]:=Char(Wkx2-Wkx1);
  Display(Csik,Wky2+1,Wkx1+2);

  Csik[0]:=#18;
  Vonnal:=Csik+Csik;
  d_x:=Wkx2-Wkx1-5;
  d_x:=d_x div 2;
  Vonnal[0]:=Char(d_x);
  Vonnal[0]:=#36;

  nev_db:=Kiadv_ind[0];
  dir_db:=0;

  Set_Choose(5,7,76,18,12,0);  {Default}
  Choose(nevek,valasz,Kiadv_ind[0],0,cikl,cikl,cikl);
  If ESC then
    BEGIN
      bool:=Remove_window;
      Exit;
    End;
  cikl:=2;
  hanyadik:=(cikl*valasz[cikl]);
  While (cikl<= kiadv_ind[0]) and (hanyadik=0) do
    BEGIN
      hanyadik:=(cikl*valasz[cikl]);
      Inc(cikl);
    End;
  If hanyadik=0 then
    BEGIN
      bool:=Remove_window;
      Exit;
    End;

  Set_Choose(5,7,76,18,12,0);  {Default}
  Choose(nevek,valasz,Kiadv_ind[0],0,cikl,cikl,cikl);
  If ESC then
    BEGIN
      bool:=Remove_window;
      Exit;
    End;
  cikl:=1;
  hova:=(cikl*valasz[cikl]);
  While (cikl<= kiadv_ind[0]) and (hova=0) do
    BEGIN
      hova:=(cikl*valasz[cikl]);
      Inc(cikl);
    End;
  If hova=0 then
    BEGIN
      bool:=Remove_window;
      Exit;
    End;
  Inc(hova);
  Bool:=Remove_Window;
  If (hanyadik+1=Hova) then Exit;

  If hanyadik=Hova then
    If hova>2 then
      BEGIN
        Dec(hanyadik);
        Csere(hanyadik);
        PublFileWrite(Kiadv_tart);
        Reff_ress;
        Exit;
      End
    else Exit;
  If hanyadik+2=Hova then
    BEGIN
      Csere(hanyadik);
      PublFileWrite(Kiadv_tart);
      Reff_ress;
      Exit;
    End;

  If hanyadik>Hova then
    BEGIN
      cikl  :=Kiadv_ind [Hanyadik];
      Move(Kiadv_ind[hova],Kiadv_ind[hova+1],hanyadik-hova);
      Kiadv_ind [Hova]:=cikl;
    End
  else
    BEGIN
      Dec(hova);
      cikl :=Kiadv_ind [Hanyadik];
      Move(Kiadv_ind [hanyadik+1],Kiadv_ind [Hanyadik],hova-hanyadik);
      Kiadv_ind [Hova]:=cikl;
    End;
  PublFileWrite(Kiadv_tart);
  Reff_ress;
End;

(***************************************************************************)

End.
