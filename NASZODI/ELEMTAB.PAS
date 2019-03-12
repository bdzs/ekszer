UNIT ELEMTAB;
INTERFACE
CONST
  NUL=CHAR(0);           (* #define NUL 0 *)
  DEL=CHAR(255);         (* #define DEL 255 *)
  NIHIL=65535;
  STATEMA=32758;
  GLOBAMAX=12;
  SUPMIN=6;
  SUPEREK=(GLOBAMAX-SUPMIN);
  MAXSTRINGT=65514;
TYPE
(*  WORD=0..NIHIL;    typedef unsigned int CARDINAL *)
                      (* typedef unsigned char CHAR *)
  BITS=0..7;          (* C-ben ez elhagyhat¢, ha ... *)
                      (* typedef int BOOLEAN *)
  BITEK=SET OF BITS;  (* typedef unsigned char BITEK *)
  GLOBA =RECORD MIN,ACT,PART,PSTART:WORD END;
  T2=ARRAY[0..1] OF CHAR;
  D2=ARRAY[0..1] OF WORD;
  D3=ARRAY[0..2] OF WORD;
  STARRAY =ARRAY[CHAR] OF WORD;
  CHARCODE=ARRAY[CHAR] OF CHAR;
  STATE3=RECORD STA:WORD; (*  llapotsor indexe *)
                SC2:WORD  (* string index *)
         END;
  STATE33=RECORD STA:D3;     (* £j  llapoth rmas *)
                 SC2:WORD(* char index *)
         END;
  STATE =RECORD STA:WORD; (* £j  llapot/ llapotsor indexe *)
                SCA:WORD; (* string index *)
                  L:WORD
         END;
(* Ha minden igaz, ezek a dinamikus t”mb”k t¡pusai *)
  STRINGT=ARRAY [0..MAXSTRINGT] OF CHAR;
  SSTATEST =ARRAY[0..STATEMA] OF WORD;       (*  llapott”mb *)
  SSTATEST2=ARRAY[0..16374] OF T2;(* Kett“s  llapotok - Char *)
  SSTATESD2=ARRAY[0..16374] OF D2;(* Kett“s  llapotok - States *)
  SSTATEST3=ARRAY[0..16374] OF STATE3;(* > mint h rmas  llapotok *)
  SSTATEST33=ARRAY[0..8186] OF STATE33;(* H rmas  llapotok *)
  STATEST  =ARRAY[0..10921] OF STATE; (* ™sszetett  llapotok *)

VAR
  NAGYBIT: ARRAY [0..8191] OF BITEK;
  NUX:CHAR;                          (* Maximal Amount of the ABC *)
  GLOBATAB: ARRAY [0..GLOBAMAX] OF GLOBA;
  GLOBX:WORD;                                     (* Mentend“ *)
  BASE,BASESEC:STARRAY;                               (* Mentend“ *)
  AtCodol(*,VisszaCodol*):CHARCODE;
  SUPERLEN,SUPERMIN:ARRAY[0..SUPEREK] OF CHAR;        (* Mentend“ *)

  STOWNA,SSTATESA10:^STRINGT; (* STRINGT=ARRAY [0..MAXSTRINGT] OF CHAR; *)
  SSTATESC2:^SSTATEST2;       (* SSTATEST2=ARRAY[0..16374] OF T2;       *)
  SSTATESA2:^SSTATESD2;       (* SSTATESD2=ARRAY[0..16374] OF D2;       *)
  SSTATESA33:^SSTATEST33;     (* SSTATEST33=ARRAY[0..8186] OF STATE33;  *)
  SSTATESA3:^SSTATEST3;       (* SSTATEST3=ARRAY[0..16374] OF STATE3;   *)
  STATETA,STATETAEX:^SSTATEST;(* SSTATEST =ARRAY[0..STATEMA] OF WORD; *)
  STATESA:^STATEST;           (* STATEST  =ARRAY[0..10921] OF STATE;    *)
  SSTATESA1,SSTATESA0:^SSTATEST;(* SSTATEST =ARRAY[0..STATEMA] OF WORD; *)
  VSTATNEA:^SSTATEST;         (* SSTATEST =ARRAY[0..STATEMA] OF WORD; *)
  TOMOR:BOOLEAN;
IMPLEMENTATION
END.