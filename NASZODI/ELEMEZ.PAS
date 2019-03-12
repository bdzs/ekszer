(*$B-*)
(*$D-*)
(*$E-*)
(*$I-*)
(*$L-*)
(*$N+*)
(*$R-*)
(*$S-*)
(*$V-*)
UNIT ELEMEZ;
(*$DEFINE EKSZER *)
(*    $UNDEF EKSZER *)
INTERFACE
(*$IFDEF EKSZER*) (*$UNDEF SAJSZO*) USES PLUSMEM;
       (*$ELSE*) (*$DEFINE SAJSZO*)
(*$ENDIF *)
FUNCTION HELYESE(VAR SZO; VAR L:WORD):BOOLEAN;
FUNCTION INITAB(LCOD:WORD):WORD;
PROCEDURE SETOPTION(OPT:WORD);
PROCEDURE JAVASOL(VAR SZO);
(*$IFDEF SAJSZO*)
 FUNCTION UJSZO(VAR SZO; L:WORD):BOOLEAN;
 PROCEDURE UJSZOS(VAR InFTT:File);
(*$ENDIF *)

IMPLEMENTATION
USES ELEMTAB;
CONST MAXHOSSZ=80;
      TELE=[Nul..Del];
      ALTX=30;
TYPE SOC=SET OF CHAR;
     SZOT=ARRAY[0..MAXHOSSZ] OF CHAR;
     ALTStr=ARRAY[0..MAXHOSSZ] OF SOC;
     ALTSX=ARRAY [0..ALTX,0..3] OF CHAR;
(*$IFDEF SAJSZO*) MAGANSZ=ARRAY[0..65000] OF CHAR; (*$ENDIF*)
VAR InFT:file; (* Input Files *)
    WIMAX,HL,I,VSTAX,APOSI,LANG,SG1P:WORD;
(*$IFDEF SAJSZO*) MAXIW:WORD; (*$ENDIF*)
    voncod,apos,pontcod:CHAR;
    HONN:STRING[50];
    CHTAB:ARRAY [CHAR] OF ARRAY [0..4] OF CHAR;
    CCSET,KKSET,TRACS,JHLY:BOOLEAN;
    ALTStringS,ALTString:ALTStr;
    SZOSAVE,ALTSszo:SZOT;
    PREFIX,AltL,AltLM,JAVPassz,JAV1,JAV2,JAV3,JAV4,JF,JA,SSX:WORD;
    MIT,MIRE:ALTSX;
(*$IFDEF SAJSZO*) AMAGANSZ:^MAGANSZ; (*$ENDIF*)
(*$IFDEF EKSZER*)
STOWNH,STATETH,STATETHEX,VSTATNEH,SSTATESH0,SSTATESH10,SSTATESH1,SSTATESH2,
SSTATESD2,SSTATESH33,SSTATESH3,STATESH,Fiction:INTEGER; (* Ezek a nyelek *)
(*$ENDIF *)

(*$IFDEF SAJSZO*)
PROCEDURE UJSZOS(VAR InFTT:File);
VAR C:CHAR;
    I,J,K:WORD;
BEGIN
(*  Assign(InFTT,'FINN'+'DIC'); Reset(InFTT,1);
  IF IOResult<>0 THEN Assign(InFTT,HONN+'FINN'+'DIC')
                 ELSE Assign(InFTT,'SAVE.'+'DIC');
  ReWrite(InFTT,1);*)
WriteLn('Sz¢t†rmentÇs');
  I:=0; J:=ORD(AMAGANSZ^[I]);
  WHILE J>0 DO BEGIN
    I:=SUCC(I);
    WHILE J>0 DO BEGIN
      C:=STOWNA^[ORD(AMAGANSZ^[I])];
Write(C);
      BlockWrite(InFTT,C,1); I:=SUCC(I); J:=PRED(J);
    END;
WriteLn;
    C:=CHR(13); BlockWrite(InFTT,C,1); C:=CHR(10); BlockWrite(InFTT,C,1);
    J:=ORD(AMAGANSZ^[I])
  END;
  Close(InFTT)
END;

FUNCTION UJSZO(VAR SZO; L:WORD):BOOLEAN;
VAR BB:BOOLEAN;
    I,J,K:WORD;
    C:CHAR;
BEGIN
  BB:=(L<>0) AND (WIMAX+L<MAXIW);
  IF BB THEN BEGIN
    I:=0;
    REPEAT
      C:=AtCodol[SZOT(SZO)[I]]; SZOSAVE[I]:=C; I:=SUCC(I); SZOSAVE[I]:=Nul
    UNTIL (I>L) OR (C=Nul);
    L:=PRED(I);
    IF L>0 THEN BEGIN
      I:=0; K:=0; J:=ORD(AMAGANSZ^[0]); 
      WHILE (K=0) AND (J<>0) DO BEGIN
        I:=SUCC(I);
        WHILE (K<J) AND (K<L) AND (SZOSAVE[K]=AMAGANSZ^[I+K]) DO K:=SUCC(K);
        IF ((K<J) AND (K<L) AND (SZOSAVE[K]>AMAGANSZ^[I+K])) OR (K=J)
          THEN BEGIN K:=0; I:=I+J END
          ELSE BEGIN K:=1; I:=PRED(I) END;
        J:=ORD(AMAGANSZ^[I]);
      END;
      L:=SUCC(L);
      FOR K:=WIMAX DOWNTO I DO BEGIN AMAGANSZ^[K+L]:=AMAGANSZ^[K] END;
      WIMAX:=WIMAX+L; L:=PRED(L);
      AMAGANSZ^[I]:=CHR(L); I:=SUCC(I);
      FOR K:=0 TO L-1 DO AMAGANSZ^[I+K]:=SZOSAVE[K]
    END
  END;
  UJSZO:=BB
END; (* UJSZO *)
(*$ENDIF*)

FUNCTION HELYESE(VAR SZO; VAR L:WORD):BOOLEAN;
CONST DEPTH=5; (* 2 FOR THE ENGLISH - 5 for Hungarian *)
VAR
  MUNKASZO:SZOT;
  MUNKA:ARRAY [0..MAXHOSSZ] OF ARRAY [0..DEPTH] OF WORD;
  VONX,BACKX:ARRAY [0..MAXHOSSZ] OF BOOLEAN;
  NUMX,NOMX,NOMY,VERBX:ARRAY [0..MAXHOSSZ] OF WORD;
  NOM,NUMY,Passz,JA:WORD;
  bb,cc:BOOLEAN;
  SSM:^STRINGT                 (* ARRAY [0..MAXSTRING] OF CHAR   *);
  STM:^SSTATEST                (* ARRAY [0..STATEMA] OF WORD *);
  NUM,MAXSZO,I,J,K,AK,e,f,ff,PSTART,TALDOM:WORD;
  CBA,Pointc,d:CHAR;
  alfa:BOOLEAN;

 PROCEDURE ALTBE(CCSS:SOC); VAR f:WORD;
  BEGIN f:=e+PREFIX; ALTString[f]:=ALTString[f]+CCSS END;

 PROCEDURE ELOJAT(MELY:WORD);
   VAR NM:WORD;
   BEGIN
     FOR NM:=0 TO MAXHOSSZ DO
       BEGIN MUNKA[NM,0]:=0; MUNKASZO[NM]:=NUL; BACKX[NM]:=FALSE END;
     VONX:=BACKX;
     MAXSZO:=0; I:=0; J:=0; NOM:=0; bb:=FALSE; Pointc:=NUL;
     REPEAT CBA:=AtCodol[SZOT(SZO)[J]]; J:=SUCC(J)
     UNTIL (J>L) OR
       ((CBA<>NUL)AND(CBA<>pontcod)AND(CBA<>apos)AND(CBA<>voncod)); (* -'. *)
     PREFIX:=PRED(J);
     WHILE (J<=L) AND (CBA<>NUL) AND (I<2) DO BEGIN
       MUNKASZO[MAXSZO]:=CBA;
       IF (MELY=0) AND (CBA<voncod) AND (CBA<>apos) THEN
         BEGIN alfa:=TRUE; IF (CBA<apos) THEN cc:=CCSET END;
       IF Pointc<>CBA THEN I:=0
       ELSE IF (LANG=1038) AND (CBA>=CHR(14)) AND (CBA<apos) THEN (* H *)
        BEGIN I:=SUCC(I); BACKX[MAXSZO]:=TRUE;IF CBA=CHR(26) THEN bb:=TRUE END;
       Pointc:=CBA;
       MAXSZO:=SUCC(MAXSZO);
       CBA:=AtCodol[SZOT(SZO)[J]]; J:=SUCC(J);
       IF (MELY<>0)AND(CBA<voncod)AND(CBA>apos) THEN CBA:=CHR(ORD(CBA)-APOSI)
     END; (* WHILE *)
     MUNKASZO[MAXSZO]:=NUL; CBA:=apos;
     IF alfa AND (MAXSZO<>0) THEN BEGIN             (* A .-' lev†g†sa *)
       REPEAT MAXSZO:=PRED(MAXSZO); CBA:=MUNKASZO[MAXSZO]
       UNTIL (MAXSZO=0) OR ((CBA<>apos)AND(CBA<>pontcod)AND(CBA<>voncod));
       MAXSZO:=SUCC(MAXSZO)
     END;
     IF (LANG=2057) AND (MAXSZO>3)
        AND (MUNKASZO[Pred(MAXSZO)]=CHR(11)) AND (MUNKASZO[MAXSZO-2]=apos)
        AND (MUNKASZO[(MAXSZO-3)]<>CHR(11)) THEN MAXSZO:=MAXSZO-2
   END; (* ELOJAT *)
BEGIN
e:=0; TALDOM:=1;
IF LANG<>0 THEN BEGIN
  IF L>MAXHOSSZ THEN L:=MAXHOSSZ;
  IF TRACS THEN BEGIN
(* memset(ALTString,Nul,SizeOf(ALTStr)); *)
    FillChar(ALTString,SizeOf(ALTStr),Nul); ALTBE(TELE)
  END;
  alfa:=FALSE;
  cc:=FALSE;
  ELOJAT(0);
  IF I<2 THEN BEGIN
   e:=1;
   IF alfa AND (MAXSZO>1) THEN
    REPEAT (* CAPITALIZE *)
      cc:=NOT(cc);
      IF (LANG=1038) AND (MAXSZO>3) THEN BEGIN (* H *) (* -e, leg, legesleg *)
        IF (MUNKASZO[PRED(PRED(MAXSZO))]=voncod) AND (CBA=CHR(3))
          THEN BEGIN MAXSZO:=PRED(PRED(MAXSZO)); MUNKASZO[MAXSZO]:=NUL END;
        e:=2;
        IF bb AND (MAXSZO>5) AND (MUNKASZO[3]<apos)
              AND ((MUNKASZO[0]=CHR(16)) OR (MUNKASZO[0]=CHR(52)))
              AND (MUNKASZO[1]=CHR(3)) AND (MUNKASZO[2]=CHR(22)) THEN BEGIN
           REPEAT VONX[e]:=TRUE; e:=e+5
           UNTIL (MAXSZO<e+4)            OR (MUNKASZO[e-4]<>CHR(3))
             OR (MUNKASZO[e-3]<>CHR(17)) OR (MUNKASZO[e-2]<>CHR(16))
             OR (MUNKASZO[e-1]<>CHR( 3)) OR (MUNKASZO[e]<>CHR(22))
             OR (MUNKASZO[e+1]>=apos);
           IF TALDOM<e-4 THEN TALDOM:=e-4
        END
      END;
      e:=1; Passz:=0;
      Pointc:=MUNKASZO[MAXSZO]; MUNKASZO[MAXSZO]:=NUL;
      d:=MUNKASZO[0]; I:=BASE[d];
      IF KKSET AND (d<voncod) AND (d>apos) THEN
        BEGIN MUNKA[1,0]:=1; MUNKA[1,1]:=I; I:=BASE[CHR(ORD(d)-APOSI)] END;
(* memset(NOMX,DEL,SizeOf(NOMX)); *)
      FillChar(NOMX,SizeOf(NOMX),DEL);
      NOMY:=NOMX; VERBX:=NOMX; NUMX:=NOMX;
      REPEAT (* Passz + AUTOMATA *)
        d:=MUNKASZO[e];
        IF I<>0 THEN BEGIN
          REPEAT (* J a nagy oszt†ly, K az aloszt†ly - az alternat°v†k *)
            IF (LANG=1038) AND (I<VSTAX) THEN BEGIN (* H *)
              IF (e>1) AND BACKX[PRED(e)] THEN BEGIN
                MUNKA[PRED(e),0]:=SUCC(MUNKA[PRED(e),0]);
                MUNKA[PRED(e),MUNKA[PRED(e),0]]:=I
              END;
              f:=SUCC(e);
              CASE Passz OF
                0: IF (I<96) AND (I>2) THEN BEGIN
                     IF TRACS THEN ALTBE(TELE);
                     NOMX[f]:=BASE[d]
                   END
                   ELSE IF (I>140) AND (I<158) THEN BEGIN
                     IF TRACS THEN ALTBE(TELE);
                     NUMX[f]:=BASE[d]
                   END
                   ELSE IF I=216 THEN BEGIN
                     IF TRACS THEN ALTBE(TELE);
                     VERBX[f]:=BASE[d]
                   END;
                1:;
              2,3: BEGIN
                     IF I<11 THEN BEGIN
                       IF (Passz=2) OR (I<7) THEN BEGIN
                         IF (NOM>e) OR (NOM=0) THEN NOM:=e;
                         IF NOMY[f]<>NIHIL THEN BEGIN
                           MUNKA[f,0]:=SUCC(MUNKA[f,0]);
                           MUNKA[f,MUNKA[f,0]]:=NOMY[f]
                         END
                       END
                     END
                     ELSE IF (I=122) OR (I=123) THEN NOMY[f]:=I
                     ELSE IF (Passz=2) AND (I=216) THEN BEGIN
                       IF TRACS THEN ALTBE(TELE);
                       NOMX[f]:=BASE[d]
                     END;
                     IF (d=voncod)AND(Passz=2)AND(I<96)AND(I>2) THEN BEGIN
                       f:=SUCC(f);
                       MUNKA[f,0]:=SUCC(MUNKA[f,0]);
                       IF TRACS THEN ALTBE(TELE);
                       MUNKA[f,MUNKA[f,0]]:=BASE[MUNKASZO[PRED(f)]]
                     END
                   END;
                4: IF ((I>216) OR ((I>89) AND (I<96))) AND
                      ((NOM>e)OR(NOM=0)) THEN NOM:=e;
                5: IF (((I>11)AND(I<17)) OR ((I>154)AND(I<158))) AND
                      ((NOM>e) OR (NOM=0)) THEN NOM:=e;
                6: IF (((I>2) AND (I<5)) OR ((I>11) AND (I<23)) OR (I>216)) AND
                      ((NOM>e) OR (NOM=0)) THEN NOM:=e;
              END (* CASE *)
            END; (* For Hungarian *)
(*    (           ((1<<(I%8)) & (NAGYBIT[I/8]))  ) *);
            IF BITS(I MOD 8) IN NAGYBIT[I DIV 8] THEN BEGIN
              IF d=NUL THEN BEGIN
(* a $IFDEF EKSZER Fiction:=Ext_Address(VSTATNEH,Pointer(VSTATNEA)); $ENDIF
                MUNKA[e,0]:=SUCC(MUNKA[e,0]);
                MUNKA[e,MUNKA[e,0]]:=VSTATNEA^[I] *)
                I:=0
              END
              ELSE IF (d=voncod) AND ((Passz<2) OR (NOM>0)) THEN VONX[e]:=TRUE
            END
            ELSE IF ((LANG=1036) OR (LANG=3084))  (* F *) (* d' l'.. *)
             AND (I=6) AND ((d<CHR(20)) OR (d=CHR(25))) THEN BEGIN
              IF TRACS THEN ALTBE(TELE);
              I:=BASE[d]; e:=SUCC(e); d:=MUNKASZO[e]
            END;
            J:=0; K:=0;
            IF I=NIHIL THEN J:=GLOBX
            ELSE IF I<>0 THEN BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STATETH,Pointer(STATETA)); (*$ENDIF *)
              REPEAT J:=SUCC(J) UNTIL GLOBATAB[J].MIN>I; J:=PRED(J);
              AK:=I-GLOBATAB[J].MIN; 
              IF J=0 THEN BEGIN
                K:=STATETA^[I];
(*$IFDEF EKSZER*) Fiction:=Ext_Address(VSTATNEH,Pointer(VSTATNEA)); (*$ENDIF *)
                IF (I>=VSTAX) AND (VSTATNEA^[I]<>NIHIL) THEN BEGIN
                  IF K=NIHIL THEN K:=VSTATNEA^[I]
                             ELSE BEGIN
                               MUNKA[e,0]:=SUCC(MUNKA[e,0]);
                               MUNKA[e,MUNKA[e,0]]:=VSTATNEA^[I]
                             END
                END;
                I:=K
              END (* IF J=0 *)
              ELSE IF J=1 THEN BEGIN
                IF STATETA^[SG1P]<=I THEN BEGIN
                  K:=ORD(d);
                  IF (d=NUL) OR (d>apos) OR
                     (STATETA^[K+SG1P]<=I) OR
                     (STATETA^[K+PRED(SG1P)]>I) THEN
                    BEGIN
                      IF TRACS THEN BEGIN
                        K:=0; WHILE STATETA^[K+SG1P]<=I DO K:=SUCC(K);
                        ALTBE([CHR(K)])
                      END;
                      J:=GLOBX
                    END
                END
                ELSE IF TOMOR THEN BEGIN
                  IF d=NUL THEN d:=Pointc;
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH10,Pointer(SSTATESA10));(*$ENDIF*)
                  IF SSTATESA10^[AK]<>d THEN BEGIN
                    IF TRACS THEN
                      ALTBE([SSTATESA10^[AK]]);
                    J:=GLOBX
                  END
                  ELSE K:=1
                END
              END
              ELSE IF J=4 THEN BEGIN
                REPEAT K:=SUCC(K)
                UNTIL (K>GLOBATAB[4].PART)OR(STATETA^[K+GLOBATAB[4].PSTART]>I);
                K:=PRED(K)
              END
            END (* IF I<>0 *)
          UNTIL (J<>0) OR (I=0) OR (I=NIHIL) (* ALTERNATIVE *)
        END; (* I<>0 *)
        IF (I=0) AND (d=voncod) AND ((Passz<2) OR (NOM>0)) THEN VONX[e]:=TRUE;
        IF ((I=0) AND (((Passz>=2)AND(NOM=0)) OR (d<>NUL))) OR (J>=GLOBX) THEN
          I:=NIHIL
        ELSE IF I<>0 THEN BEGIN
          PSTART:=GLOBATAB[J].PSTART;
          I:=NIHIL; NUM:=J+K;
          IF J=5 THEN BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STATESH,Pointer(STATESA)); (*$ENDIF*)
                     NUM:=STATESA^[AK].L
          END;
          f:=0;
          IF (d=NUL) AND (Pointc<>NUL) THEN BEGIN d:=Pointc; e:=PRED(e) END;
          IF J=1 THEN BEGIN
            IF K=0 THEN BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH1,Pointer(SSTATESA1));(*$ENDIF*)
              JA:=SSTATESA1^[AK];
              IF JA<256 THEN BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH0,Pointer(SSTATESA0));(*$ENDIF*)
                IF JA=ORD(d) THEN I:=SSTATESA0^[AK]
                             ELSE IF TRACS THEN ALTBE([CHR(JA)])
              END
              ELSE BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STOWNH,Pointer(STOWNA)); (*$ENDIF*)
                WHILE (STOWNA^[JA]<>NUL) AND (STOWNA^[JA]=d) DO BEGIN
                  JA:=SUCC(JA); e:=SUCC(e); d:=MUNKASZO[e];
                  IF (d=NUL) AND (Pointc<>NUL)AND(STOWNA^[JA]=Pointc) THEN
                    BEGIN e:=PRED(e); d:=Pointc END
                END;
                IF STOWNA^[JA]=NUL THEN BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH0,Pointer(SSTATESA0));(*$ENDIF*)
                  I:=SSTATESA0^[AK]
                END
                ELSE IF TRACS THEN ALTBE([STOWNA^[JA]]);
                e:=PRED(e)
              END
            END
          ELSE BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH0,Pointer(SSTATESA0));(*$ENDIF*)
             I:=SSTATESA0^[AK] (* 1 *)
          END
        END
        ELSE IF J>5 THEN BEGIN
          JA:=J-SUPMIN; CBA:=SUPERMIN[JA];
          IF (d>=CBA) THEN BEGIN
            K:=ORD(d)-ORD(CBA); JA:=ORD(SUPERLEN[JA]);
            IF K<JA THEN BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STATETH,Pointer(STATETA)); (*$ENDIF*)
              I:=STATETA^[JA*AK+PSTART+K]
            END
          END;
          IF TRACS THEN ALTBE([CBA..CHR(ORD(CBA)+PRED(JA))])
        END;
          IF J IN [2..5] THEN BEGIN
            CASE J OF
              2: BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESD2,Pointer(SSTATESC2));(*$ENDIF*)
                   SSM:=@SSTATESC2^[AK];     (* a c°mkÇpzÇst tîrîlni *)
                 END;
              3: BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH33,Pointer(SSTATESA33));(*$ENDIF*)
                   SSX:=SSTATESA33^[AK].SC2
                  END;
               4: BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH3,Pointer(SSTATESA3));(*$ENDIF*)
                   SSX:=SSTATESA3^[AK].SC2;
                   JA:=SSTATESA3^[AK].STA
                 END (* >3 *);
              5: BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STATESH,Pointer(STATESA)); (*$ENDIF*)
                   SSX:=STATESA^[AK].SCA;
                   JA:=STATESA^[AK].STA;
                 END (* 5 *);
            END; (* CASE *)
            IF J>2 THEN BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STOWNH,Pointer(STOWNA)); (*$ENDIF*)
              SSM:=@STOWNA^[SSX]
            END;
            WHILE (f<NUM) AND (SSM^[f]<d) DO f:=SUCC(f);
            IF TRACS THEN FOR ff:=0 TO PRED(NUM) DO ALTBE([SSM^[ff]]);
            IF (f<NUM) AND (SSM^[f]=d) THEN BEGIN
              CASE J OF
                2: BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH2,Pointer(SSTATESA2));(*$ENDIF*)
                     STM:=@SSTATESA2^[AK]      (* a c°mkÇpzÇst tîrîlni *)
                   END;
                3: BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(SSTATESH33,Pointer(SSTATESA33));(*$ENDIF*)
                     STM:=@SSTATESA33^[AK].STA  (* a c°mkÇpzÇst tîrîlni *)
                   END;
              4,5: IF JA>STATEMA THEN BEGIN
(*$IFDEF EKSZER*)Fiction:=Ext_Address(STATETHEX,Pointer(STATETAEX));(*$ENDIF*)
                     STM:=@STATETAEX^[JA-SUCC(STATEMA)]
                   END
                   ELSE BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STATETH,Pointer(STATETA)); (*$ENDIF *)
                    STM:=@STATETA^[JA]
                   END;
              END; (* CASE *)
              I:=STM^[f]; f:=SUCC(f);
            END;
          END (* 2..5 *);
          e:=SUCC(e)
        END; (* I<>0 *)
        IF I=NIHIL THEN BEGIN
          IF e+PREFIX>TALDOM THEN TALDOM:=e+PREFIX;
          e:=MAXSZO;
          WHILE (e<>0) AND (MUNKA[e,0]=0) DO e:=PRED(e);
          I:=MUNKA[e,MUNKA[e,0]];
          IF MUNKA[e,0]<>0 THEN MUNKA[e,0]:=PRED(MUNKA[e,0]);
          IF NOM>=e THEN NOM:=0
        END;
        IF (LANG=1038) AND (e=0) THEN BEGIN (* H *)
          d:=MUNKASZO[0];
          NOM:=0; 
          I:=NIHIL;
          CASE Passz OF
            0:BEGIN
                e:=1;
                I:=BASESEC[d];
                IF KKSET AND (d>apos) AND (d<voncod) THEN BEGIN
                  MUNKA[1,0]:=1; MUNKA[1,1]:=I; I:=BASESEC[CHR(ORD(d)-APOSI)]
                END
              END;
          1,2:FOR e:=1 TO PRED(MAXSZO) DO IF NOMX[e]<>NIHIL THEN
                BEGIN MUNKA[e,0]:=1; MUNKA[e,1]:=NOMX[e]; NOMX[e]:=NIHIL END;
            3:FOR e:=1 TO PRED(MAXSZO) DO IF VERBX[e]<>NIHIL THEN
                BEGIN MUNKA[e,0]:=1; MUNKA[e,1]:=VERBX[e] END;
            4:FOR e:=1 TO PRED(MAXSZO) DO IF NUMX[e]<>NIHIL THEN
                BEGIN MUNKA[e,0]:=1; MUNKA[e,1]:=NUMX[e] END;
            5:IF d<apos THEN BEGIN
                e:=1; I:=BASESEC[CHR(ORD(MUNKASZO[0])+APOSI)]
              END;
          ELSE;
          END;
          Passz:=SUCC(Passz)
        END; (* For Hungarian *)
        d:=MUNKASZO[e];
(*      (            ((1<<(I%8))&(NAGYBIT[I/8]))  ) *);
        IF ((I=0) OR (BITS(I MOD 8) IN NAGYBIT[I DIV 8])) AND
          (d=voncod) AND ((Passz<2) OR (NOM>0)) THEN VONX[e]:=TRUE;
        IF (e=0) AND (((LANG=1038) AND (Passz>=6)) OR            (* H *)
                       (LANG=2057)) THEN BEGIN        (* E *)
          REPEAT e:=SUCC(e) UNTIL ((e+2)>=MAXSZO) OR VONX[e];
          IF VONX[e] THEN BEGIN
            CBA:=MUNKASZO[e]; VONX[e]:=FALSE; e:=SUCC(e);
            IF (SUCC(e)>=MAXSZO) OR (MUNKASZO[e]=voncod) THEN e:=0
            ELSE BEGIN
              PREFIX:=PREFIX+e;
              FOR NOM:=0 TO MAXHOSSZ DO MUNKA[I,0]:=0;
              f:=0; NOM:=0;
              REPEAT
                VONX[f]:=VONX[e]; BACKX[f]:=BACKX[e]; MUNKASZO[f]:=MUNKASZO[e];
                e:=SUCC(e); f:=SUCC(f)
              UNTIL e>=MAXSZO;
              MUNKASZO[f]:=NUL; MAXSZO:=f;
              REPEAT VONX[f]:=FALSE; BACKX[f]:=FALSE; f:=SUCC(f) UNTIL f>=e;
              d:=MUNKASZO[0]; I:=BASE[d];
              IF (CBA=voncod) AND (d<voncod) AND (d>apos) THEN BEGIN
                MUNKA[1,0]:=1; MUNKA[1,1]:=I; I:=BASE[CHR(ORD(d)-APOSI)]
              END;
              e:=1; Passz:=0
            END;
(*          memset(NOMX,DEL,SizeOf(NOMX)); *)
            FillChar(NOMX,SizeOf(NOMX),DEL);
            NOMY:=NOMX; VERBX:=NOMX; NUMX:=NOMX; Passz:=0
          END
          ELSE e:=0;
          d:=MUNKASZO[e]
        END (* For Hungarian *)
      UNTIL (e=0) OR
(*       (             ((1<<(I%8))&(NAGYBIT[I/8]))  ) *)
             (((I=0) OR (BITS(I MOD 8) IN NAGYBIT[I DIV 8])) AND (* Passz + A *)
              (d=NUL) AND ((Passz<2) OR (NOM>0)));
      IF (e=0) AND cc THEN ELOJAT(1) ELSE cc:=FALSE
    UNTIL NOT(cc) (* CAPITALIZE *)
   END (* Ha nincs 3 m†ssalhangz¢ *)
   ELSE BEGIN
     TALDOM:=SUCC(MAXSZO);
     IF TRACS THEN
(* memset(ALTString,Nul,SizeOf(ALTStr)); *)
     FillChar(ALTString,SizeOf(ALTStr),Del)
   END
  END; (* Inicializ†l†s ut†n *)
(*$IFDEF SAJSZO*)
  IF e=0 THEN BEGIN
    I:=0;
    REPEAT
      CBA:=AtCodol[SZOT(SZO)[I]]; MUNKASZO[I]:=CBA; I:=SUCC(I)
    UNTIL (CBA=Nul) OR (I>L);
    I:=PRED(I);
    K:=0; J:=0; e:=0; CBA:=MUNKASZO[0];
    REPEAT J:=J+K; K:=ORD(AMAGANSZ^[J]); J:=SUCC(J)
    UNTIL (K=0) OR (AMAGANSZ^[J]>CBA) OR ((AMAGANSZ^[J]=CBA) AND (I=K));
    WHILE (K>0) AND (e=0) DO BEGIN
      WHILE (e<I) AND (AMAGANSZ^[J+e]=MUNKASZO[e]) DO e:=SUCC(e);
      IF e<I THEN BEGIN
        REPEAT J:=J+K; K:=ORD(AMAGANSZ^[J]); J:=SUCC(J)
        UNTIL (K=0) OR (AMAGANSZ^[J]>CBA) OR (I=K);
        e:=0
      END
    END
  END;
(*$ENDIF*)
  IF NOT JHLY THEN BEGIN
    AltL:=L;
    FOR I:=0 TO L DO ALTSszo[I]:=SZOT(SZO)[I]; ALTSszo[L]:=Nul;
    JAVPassz:=0
  END;
  IF L>TALDOM THEN L:=TALDOM;
  HELYESE:=e<>0
 END; (* HELYESE *)

PROCEDURE SETOPTION(OPT:WORD);
BEGIN CCSET:=(OPT MOD 2)=1; KKSET:=(OPT MOD 4)>1 END;

PROCEDURE JAVASOL(VAR SZO);
VAR HEE:BOOLEAN;
    I,J:WORD;
    SOCK:SOC;
    C,CK:CHAR;
FUNCTION JAVASOL1(VAR J1,J2:WORD; VAR ALTS:ALTStr; A,F:WORD):BOOLEAN;
VAR TRCS:BOOLEAN;
BEGIN
  TRCS:=FALSE;
  REPEAT
    C:=Nul; CK:=AtCodol[SZOSAVE[J1]];
    IF (CK<>Nul) AND ((J1>F) OR (J1<A)) THEN BEGIN
      SOCK:=ALTS[J1];
      REPEAT C:=CHTAB[CK,J2]; J2:=SUCC(J2); IF C=Nul THEN J2:=6
      UNTIL (J2>=5) OR (C IN SOCK);
      IF NOT (C IN SOCK) THEN J2:=6
    END
    ELSE J2:=6;
    IF J2>=5 THEN BEGIN
      J2:=0;
      IF J1>0 THEN BEGIN
        REPEAT J1:=PRED(J1) UNTIL (J1=0) OR (J1>F) OR (J1<A);
        IF (J1<=F) AND (J1>=A) THEN TRCS:=TRUE
      END
      ELSE TRCS:=TRUE
    END
  UNTIL TRCS OR (J2<>0);
  JAVASOL1:=TRCS;
END; (* JAVASOL1 *)
BEGIN
  C:=Nul; JHLY:=TRUE;
  REPEAT
    TRACS:=(JAVPassz=0) OR ((JAVPassz=5) AND (JAV2=0)) OR
           JAVASOL1(JAV3,JAV4,ALTString,JA,JF);
    IF TRACS THEN BEGIN
      HL:=AltL;
      SZOSAVE:=ALTSszo;
(*0*) IF JAVPassz=0 THEN BEGIN
        AltLM:=AltL;
        IF HELYESE(SZO,AltLM) THEN BEGIN
(* memset(ALTString,Nul,SizeOf(ALTStr)); *)
          FillChar(ALTString,SizeOf(ALTStr),Del);
          ALTString[0]:=[Nul..apos]
        END;
        ALTStringS:=ALTString;
        JAV1:=AltLM; JAVPassz:=1; JAV2:=0
      END; (* 0 *)
(*1*) IF JAVPassz=1 THEN BEGIN
        IF JAVASOL1(JAV1,JAV2,ALTStringS,MAXHOSSZ,0) THEN BEGIN
          JAV1:=AltL; JAVPassz:=2
        END
        ELSE BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STOWNH,Pointer(STOWNA)); (*$ENDIF*)
          SZOSAVE[JAV1]:=STOWNA^[ORD(C)]
        END
      END; (* 1 *)
(*2*) IF JAVPassz=2 THEN BEGIN
        IF JAV1>0 THEN BEGIN
          C:=AtCodol[SZOSAVE[JAV1]];
          REPEAT CK:=C; JAV1:=PRED(JAV1); C:=AtCodol[SZOSAVE[JAV1]]
          UNTIL (JAV1=0) OR ((C<>CK) AND (C<voncod) AND (C<>apos));
          IF (C=CK) THEN JAVPassz:=3
        END
        ELSE JAVPassz:=3;
        IF JAVPassz=3 THEN JAV1:=AltL
        ELSE BEGIN
          HL:=SUCC(HL); FOR I:=AltL DOWNTO JAV1 DO SZOSAVE[SUCC(I)]:=SZOSAVE[I]
        END
      END; (* 2 *)
(*3*) IF JAVPassz=3 THEN BEGIN
        IF (JAV1>0) AND (AltL>3) THEN BEGIN
          CK:=AtCodol[SZOSAVE[JAV1]];
          REPEAT C:=CK; JAV1:=PRED(JAV1); CK:=AtCodol[SZOSAVE[JAV1]]
          UNTIL (JAV1=0) OR ((C<>CK) AND ((C<=voncod) OR (C>=pontcod)));
          IF C=CK THEN JAVPassz:=4
        END
        ELSE JAVPassz:=4;
        IF JAVPassz=4 THEN BEGIN IF AltL>1 THEN JAV1:=PRED(AltL) END
        ELSE BEGIN
          SZOSAVE[JAV1]:=SZOSAVE[SUCC(JAV1)];
          SZOSAVE[SUCC(JAV1)]:=ALTSszo[JAV1]
        END
      END; (* 3 *)
(*4*) IF JAVPassz=4 THEN BEGIN
        CK:=AtCodol[SZOSAVE[JAV1]];
        IF (JAV1>0) AND (AltL>1) THEN BEGIN
          REPEAT
            C:=CK;
            JAV1:=PRED(JAV1);
            CK:=AtCodol[SZOSAVE[JAV1]];
          UNTIL (JAV1=0) OR ((C<>CK) AND ((C<=voncod) OR (C>pontcod)));
          IF (CK=Nul) OR (C=CK) THEN JAVPassz:=5
        END
        ELSE JAVPassz:=5;
        IF JAVPassz=5 THEN JAV1:=AltL
        ELSE BEGIN
          HL:=PRED(HL); FOR I:=JAV1 TO AltL DO SZOSAVE[I]:=SZOSAVE[SUCC(I)]
        END
      END; (* 4 *)
(*5*) IF JAVPassz=5 THEN BEGIN
        REPEAT
          I:=0; CK:=MIT[JAV2,0];
          REPEAT
            IF NOT (MIRE[JAV2,0] IN ALTStringS[JAV1]) THEN CK:=Del
            ELSE WHILE (CK<>Nul) AND (CK=AtCodol[SZOSAVE[JAV1+I]]) DO BEGIN
              I:=SUCC(I); CK:=MIT[JAV2,I]
            END;
            IF CK<>Nul THEN BEGIN JAV2:=SUCC(JAV2); I:=0; CK:=MIT[JAV2,0] END
          UNTIL CK=Nul;
          IF I=0 THEN BEGIN
            JAV2:=0;
            IF JAV1>0 THEN JAV1:=PRED(JAV1) ELSE JAVPassz:=6
          END
          ELSE JAV2:=SUCC(JAV2)
        UNTIL (JAV2<>0) OR (JAVPassz>5);
        IF JAVPassz=5 THEN BEGIN
          J:=0;
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STOWNH,Pointer(STOWNA)); (*$ENDIF*)
          WHILE (J<4) AND (MIRE[PRED(JAV2),J]<>Nul) DO BEGIN
            SZOSAVE[JAV1+J]:=STOWNA^[ORD(MIRE[PRED(JAV2),J])]; J:=SUCC(J)
          END;
          HL:=JAV1;
          REPEAT SZOSAVE[HL+J]:=ALTSszo[HL+I]; HL:=SUCC(HL)
          UNTIL (HL+I)>AltL;
          HL:=AltL+J-I
        END
      END; (* 5 *)
      FOR I:=0 TO HL(* +1 *) DO SZOT(SZO)[I]:=SZOSAVE[I];
      AltLM:=HL
    END
    ELSE BEGIN
      HL:=AltLM;
      FOR I:=0 TO SUCC(AltLM) DO SZOT(SZO)[I]:=SZOSAVE[I];
      IF C<>Nul THEN BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STOWNH,Pointer(STOWNA)); (*$ENDIF*)
        SZOT(SZO)[JAV3]:=STOWNA^[ORD(C)]
      END
    END;
    IF JAVPassz<6 THEN BEGIN
      IF (JAV2<>0) OR (JAVPassz<5) THEN HEE:=HELYESE(SZO,HL)
                                   ELSE HEE:=FALSE;
      IF TRACS THEN BEGIN
        TRACS:=FALSE; JAV3:=HL; JAV4:=0;
        IF HEE THEN BEGIN
          JAV3:=AltLM;
          ALTString:=ALTStringS;
          ALTString[0]:=[Nul..apos]
        END;
        CASE JAVPassz OF
          1: BEGIN JF:=JAV1;         JA:=0        END;
        2,3: BEGIN JF:=SUCC(JAV1);   JA:=JAV1     END;
          4: BEGIN JF:=0;            JA:=MAXHOSSZ END;
          5: BEGIN JF:=JAV1+PRED(J); JA:=JAV1     END;
          6: (* A vÇge *);
        END
      END
    END
  UNTIL HEE OR (JAVPassz>5);
  JHLY:=FALSE;
  IF JAVPassz>5 THEN SZOT(SZO)[0]:=NUL
END; (* JAVASOL *)

FUNCTION INITAB(LCOD:WORD):WORD;
 VAR RESUL:WORD;
     ABC,CBA:CHAR;
     FINN:STRING[10];
 PROCEDURE BRead(P:Pointer; L:WORD);
           BEGIN BlockRead(InFT,P^,L) END;
(*$IFDEF EKSZER*)
 FUNCTION GetRead(VAR P:Pointer;L:WORD):INTEGER;
 VAR Handle:INTEGER;
 BEGIN
   RESUL:=Ext_Alloc(Handle,L);
   IF RESUL=0 THEN BEGIN
     Fiction:=Ext_Address(Handle,P);
     BRead(P,L);
     RESUL:=IOResult;
     Ext_Save
   END;
   GetRead:=Handle
 END;
(*$ELSE*)
 PROCEDURE GetRead(VAR P:Pointer;L:WORD);
   BEGIN
     GetMem(P,L);
     IF P=NIL THEN RESUL:=99 ELSE BEGIN BRead(P,L); RESUL:=IOResult END
   END;
(*$ENDIF*)
BEGIN
IF LANG=0 THEN BEGIN
FileMode:=0;                         (* C-ben kihuzand¢ *)
  FILLChar(CHTAB,SizeOf(CHTAB),NUL);       (* az egÇszet ki kell null†zni *)
  I:=LCOD; FINN:='';
  WHILE I>0 DO BEGIN FINN:=CHR(I MOD 10+ORD('0'))+FINN; I:=I DIV 10 END;
  FOR I:=LENGTH(FINN) TO 4 DO FINN:='0'+FINN+'.';
  FINN:='NAS'+FINN;
  Assign(InFT,HONN+FINN+'HKE'); ReSet(InFT,1); RESUL:=IOResult;
(* Az elìzì sor helyett   ? ? ? ? ?
  strcat(HONN,FINN+...); RESUL = open(HONN,O_RDONLY+O_BINARY);
*)
(*$IFDEF EKSZER*)
  IF RESUL=0 THEN RESUL:=Ext_Init(FileSize(InFT),65520);
  Ext_Enter;
(*$ENDIF*)
  IF RESUL=0 THEN BEGIN
(* Minden skal†rnak a c°mÇt kell venni, Çs minden allok†lt tîmbnÇl
eggyel csîkkenteni kell az indirekci¢t a BlockRead fÅggvÇnyben,
vagyis (ahol ,* van). Viszont a GetMem-ben az elsì argumentumnak a
c°mÇt kell venni (point &). *)
    BRead(Pointer(@NUX),SizeOf(NUX));                        (* & *)
    BRead(Pointer(@AtCodol),SizeOf(AtCodol));
    BRead(Pointer(@TOMOR),SizeOf(TOMOR));
    BRead(Pointer(@I),SizeOf(WORD));                     (* & *)
(*$IFDEF EKSZER*) STOWNH:= (*$ENDIF*)
    GetRead(Pointer(STOWNA),I);  (* CharacterArray *)             (* *)
    IF RESUL=0 THEN BEGIN
    BRead(Pointer(@I),SizeOf(WORD));                     (* & *)
(*$IFDEF EKSZER*) STATETH:= (*$ENDIF*)
    GetRead(Pointer(STATETA),I*SizeOf(WORD));
    IF RESUL=0 THEN BEGIN
    BRead(Pointer(@I),SizeOf(WORD));                     (* & *)
(*$IFDEF EKSZER*) STATETHEX:= (*$ENDIF*)
    GetRead(Pointer(STATETAEX),I*SizeOf(WORD));
    IF RESUL=0 THEN BEGIN
    FillChar(GLOBATAB,SizeOf(GLOBATAB),NUL);
    BRead(Pointer(@GLOBX),SizeOf(WORD));                 (* & *)
    BRead(Pointer(@GLOBATAB),SUCC(GLOBX)*SizeOf(GLOBA));
(*$IFDEF EKSZER*) VSTATNEH:= (*$ENDIF*)
    GetRead(Pointer(VSTATNEA),GLOBATAB[0].ACT*SizeOf(WORD));
    IF RESUL=0 THEN BEGIN
    APOSI:=SUCC(GLOBATAB[1].PART);
    SG1P:=SUCC(GLOBATAB[1].PSTART);
    apos:=CHR(APOSI); voncod:=CHR(2*APOSI); pontcod:=CHR(2*APOSI+11);
(*$IFDEF EKSZER*) SSTATESH0:= (*$ENDIF*)
    GetRead(Pointer(SSTATESA0),
        (GLOBATAB[1].ACT-GLOBATAB[1].MIN)*SizeOf(WORD));(* Egyes †llpt *)
    IF RESUL=0 THEN BEGIN
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STATETH,Pointer(STATETA)); (*$ENDIF*)
    WIMAX:=STATETA^[SG1P]-GLOBATAB[1].MIN;
    IF TOMOR THEN
(*$IFDEF EKSZER*) SSTATESH10:= (*$ENDIF*)
      GetRead(Pointer(SSTATESA10),WIMAX*SizeOf(CHAR))
    ELSE
(*$IFDEF EKSZER*) SSTATESH1:= (*$ENDIF*)
      GetRead(Pointer(SSTATESA1),WIMAX*SizeOf(WORD));
    IF RESUL=0 THEN BEGIN
(*$IFDEF EKSZER*) SSTATESH2:= (*$ENDIF*)
GetRead(Pointer(SSTATESA2),(GLOBATAB[2].ACT-GLOBATAB[2].MIN)*SizeOf(D2));
    IF RESUL=0 THEN BEGIN
(*$IFDEF EKSZER*) SSTATESD2:= (*$ENDIF*)
GetRead(Pointer(SSTATESC2),(GLOBATAB[2].ACT-GLOBATAB[2].MIN)*SizeOf(T2));
    IF RESUL=0 THEN BEGIN
(*$IFDEF EKSZER*) SSTATESH33:= (*$ENDIF*)
GetRead(Pointer(SSTATESA33),(GLOBATAB[3].ACT-GLOBATAB[3].MIN)*SizeOf(STATE33));
    IF RESUL=0 THEN BEGIN
(*$IFDEF EKSZER*) SSTATESH3:= (*$ENDIF*)
GetRead(Pointer(SSTATESA3),(GLOBATAB[4].ACT-GLOBATAB[4].MIN)*SizeOf(STATE3));
    IF RESUL=0 THEN BEGIN
(*$IFDEF EKSZER*) STATESH:= (*$ENDIF*)
    GetRead(Pointer(STATESA),(GLOBATAB[5].ACT-GLOBATAB[5].MIN)*SizeOf(STATE));
    IF RESUL=0 THEN BEGIN
    BRead(Pointer(@SUPERMIN),SizeOf(SUPERMIN));
    BRead(Pointer(@SUPERLEN),SizeOf(SUPERLEN));
    BRead(Pointer(@NAGYBIT),SizeOf(NAGYBIT));
    BRead(Pointer(@BASE),SizeOf(STARRAY));
    BRead(Pointer(@VSTAX),SizeOf(VSTAX));                          (* ? *)
    BRead(Pointer(@BASESEC),SizeOf(STARRAY));   (* For Hungarian ? *)
    RESUL:=IOResult; close(InfT);
    IF RESUL=0 THEN LANG:=LCOD;
(*$IFDEF EKSZER*)(*$ELSE*)
    Assign(InFT,FINN+'ABC'); Reset(InFT,1);
    IF IOResult<>0 THEN
(*$ENDIF*)
      BEGIN Assign(InFT,HONN+FINN+'ABC'); Reset(InFT,1) END;
    IF IOResult=0 THEN BEGIN
(* Az elìzì h†rom sor helyett
    InFT = open("ABC.COD",O_RDONLY+O_BINARY);
    if(InFT == -1) {InFT = open("ABC.COD",O_RDONLY+O_BINARY);}
    if(InFT!=-1)
*)     
      FILLChar(MIT,SizeOf(ALTSX),NUL);      (* az egÇszet ki kell null†zni *)
      FILLChar(MIRE,SizeOf(ALTSX),NUL);     (* az egÇszet ki kell null†zni *)
      FILLChar(CHTAB,SizeOf(CHTAB),NUL);    (* az egÇszet ki kell null†zni *)
(*$IFDEF EKSZER*) Fiction:=Ext_Address(STOWNH,Pointer(STOWNA)); (*$ENDIF*)
      FOR ABC:=NUL TO CHR(255) DO
        BEGIN AtCodol[ABC]:=NUL; STOWNA^[ORD(ABC)]:='#' END;
      ABC:=NUL; BRead(Pointer(@CBA),1);
(* IOResult ==> eof(InFT) *)
      WHILE (ABC<NUX) AND (CBA>' ') AND (IOResult=0) DO BEGIN
        ABC:=SUCC(ABC);
        IF STOWNA^[ORD(ABC)]='#' THEN STOWNA^[ORD(ABC)]:=CBA;
        AtCodol[CBA]:=ABC;
        BRead(Pointer(@CBA),1)
      END (* WHILE *);
(*$IFDEF EKSZER*) Ext_Save; (*$ENDIF*)
      I:=0;
      WHILE (IOResult=0) AND (I<4) DO BEGIN
        WHILE (CBA>=' ') AND (IOResult=0) DO BRead(Pointer(@CBA),1);
        WHILE (CBA<' ') AND (IOResult=0) DO BRead(Pointer(@CBA),1);
        ABC:=NUL;
        WHILE (ABC<NUX) AND (CBA>=' ') AND (IOResult=0) DO BEGIN
          ABC:=SUCC(ABC); CHTAB[ABC,I]:=AtCodol[CBA]; BRead(Pointer(@CBA),1)
        END; (* WHILE *)
        I:=SUCC(I)
      END; (* WHILE *)
      I:=0;
      WHILE (IOResult=0) AND (I<ALTX) DO BEGIN
        WHILE (AtCodol[CBA]=Nul) AND (IOResult=0) DO BRead(Pointer(@CBA),1);
        IF IOResult=0 THEN BEGIN
          HL:=0;
          WHILE (AtCodol[CBA]<>Nul) AND (HL<3) AND (IOResult=0) DO BEGIN
            MIT[I,HL]:=AtCodol[CBA]; HL:=SUCC(HL); BRead(Pointer(@CBA),1) END;
          WHILE (AtCodol[CBA]=Nul) AND (IOResult=0) DO BRead(Pointer(@CBA),1);
          HL:=0;
          WHILE (AtCodol[CBA]<>Nul) AND (HL<3) AND (IOResult=0) DO BEGIN
            MIRE[I,HL]:=AtCodol[CBA]; HL:=SUCC(HL); BRead(Pointer(@CBA),1) END;
          IF IOResult=0 THEN I:=SUCC(I)
        END
      END;
      close(InFT)
    END;
    JHLY:=FALSE;
(*$IFDEF SAJSZO*)
    MAXIW:=0;
    IF MemAvail>105000 THEN MAXIW:=65000
    ELSE IF MemAvail>6000 THEN MAXIW:=((MemAvail DIV 1000) -6)*650+2;
    GetMem(Pointer(AMAGANSZ),MAXIW);
    MAXIW:=PRED(MAXIW);
    AMAGANSZ^[0]:=Nul;
    WIMAX:=0;
    Assign(InFT,FINN+'DIC'); Reset(InFT,1);
    IF IOResult<>0 THEN BEGIN Assign(InFT,HONN+FINN+'DIC'); Reset(InFT,1) END;
    IF IOResult=0 THEN BEGIN
      REPEAT
        CBA:=Nul;
        WHILE (CBA=Nul) AND (IOResult=0) DO
          BEGIN BRead(Pointer(@CBA),1); ALTSszo[0]:=CBA; CBA:=AtCodol[CBA] END;
        JA:=0;
        WHILE (CBA>Nul) AND (IOResult=0) DO BEGIN
          JA:=SUCC(JA); BRead(Pointer(@CBA),1);
          ALTSszo[JA]:=CBA; CBA:=AtCodol[CBA];
        END;
        ALTSszo[JA]:=Nul;
        JF:=JA;
        TRACS:=FALSE;
        IF (JA>=0) AND NOT HELYESE(ALTSszo,JA) THEN TRACS:=UJSZO(ALTSszo,JF);
        TRACS:=FALSE
      UNTIL (IOResult<>0) OR (JA=0);
      close(InFT)
    END
(*$ENDIF*)
  END END END END END END END END END END END
  END;
FileMode:=2                          (* C-ben kihuzand¢ *)
END
ELSE RESUL:=99;
  INITAB:=RESUL;

(*$IFDEF EKSZER *)
  Ext_Leave
(*$ENDIF *)

END; (* INITAB *)
BEGIN
  HONN:=ParamStr(0); CCSET:=TRUE; KKSET:=TRUE; TRACS:=FALSE;
  I:=Length(HONN);
  WHILE (I>0) AND (HONN[I]<>'\') AND (HONN[I]<>':') DO
    BEGIN Delete(HONN,I,1); I:=PRED(I) END;
  LANG:=0
END.
