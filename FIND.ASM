TITLE    STRING KERESO RUTIN TURBO PASCAL 4.0 PROGRAMOKHOZ

CODE    SEGMENT PARA PUBLIC

ASSUME CS:CODE

Public FIND

FIND PROC FAR

        PUSH  BP
        MOV   BP,SP
        PUSH  DS
        PUSH  ES

        PUSH  SS
        POP   DS
        LDS   SI,[BP+10]
        LES   DI,[SI]        ; ES:DI  KERESES ELEJE

        PUSH  DS             ; A KEZDOCIM PASCAL VALTOZO CIME  **1**
        PUSH  SI             ;                                 **2**

    PUSH  ES         ;  Elrakja vegen talalat lapra aljon      **3**

        PUSH  SS
        POP   DS
        LDS   SI,[BP+06]     ; DS:SI   KERESES VEGE
        LDS   SI,[SI]

        MOV   AX,DI
        CALL  NORMAL
        MOV   DI,AX
        MOV   AX,ES
        ADD   BX,AX
        MOV   ES,BX       ;  ES:DI  KERESES ELEJE (DI < 10H)

        MOV   AX,SI
        CALL  NORMAL

        ADD   AX,0FH
        MOV   SI,AX
        DEC   BX
        MOV   AX,DS
        ADD   BX,AX       ; DS:SI KERESES VEGE  (0FH < SI < 20H)
        MOV   DS,BX

        MOV   AX,ES       ; SZEGMENSKULONBSEG
        SUB   BX,AX
        MOV   AX,BX
        MOV   CX,4
        SHL   AX,CL
        SUB   SI,DI         ; OFFSETKULONBSEG
        ADD   SI,AX         ; TOREDEK KERESES

MARAD:  MOV   CL,0CH
        SHR   BX,CL

      PUSH  BX             ; ATNEZENDO EGESZ SZEGMENSEK SZAMA

        MOV   BX,SI
        LDS   SI,[BP+14]
        XOR   DX,DX
        MOV   DL,[SI]
        INC   SI
      POP   BP
        SUB   BX,DX      ;  NEHOGY SZEGMENSHATORON TULFUSSON
        ADD   BX,4       ;  KORREKCIO
        JNB   SIMA1
        INC   BX         ;  TULCSORDULAS VOLT
SIMA1:  XCHG  BP,BX
        MOV   BH,BL      ;  ATLAPOLAS MIATT

        CALL  KERES

  pop   dx        ;   kezdocim segmens          **3**
     PUSHF
        MOV   AX,DI
        CALL  NORMAL
        MOV   CX,ES
        ADD   CX,BX
        MOV   SI,CX    ; NORMALT SEGMENS ELMENTES
        AND   DX,0FFH  ; LAP MEGTARTAS
        AND   CX,0FFH  ;  TALALAT SEGMENS 'LAP'
        SUB   CX,DX    ; 'LAPOK' KULONBSEGE'
        MOV   DX,SI
      PUSHF              ;  CARRY   MENTES
        SUB   DX,CX    ;  VEGLEGES  SEGMENS
      POPF               ;  CARRY VISSZA
        JNC   NEM_NOVELT
        SUB   DX,100H  ;  SEGMENS ERTEK NOVEKEDETT
NEM_NOVELT:  SUB   SI,DX   ; ENNYIT CSOKKENT A SZEGMENS
        MOV   CX,4
        SHL   SI,CL
        ADD   AX,SI    ; ATADONDO OFFSET
        MOV   CX,DX    ; ATADANDO SZEGMENS
     POPF
        JNC   TOLT
        XOR   AX,AX
        XOR   CX,CX
TOLT:   POP   DI                               ;**2**  KEZDOCIM = 0000:0000
        POP   ES                               ;**1**

        STOSW
        MOV   AX,CX
        STOSW

        POP   ES
        POP   DS
        POP   BP
        RET   12

FIND ENDP


KERES   PROC  NEAR
        LODSB
        MOV   CX,BP
TOVABB: REPNZ SCASB
        OR    CX,CX
        JZ    NEM_TALALT
    PUSH   CX         ; HOSSZ MENTES       $$$$$$$$$$$
        MOV   CX,DX
        DEC   CX
        JZ    TALALT        ; BYTE-OS KERESES

        REPZ  CMPSB
        JZ    TALALT        ; HOSSZU KERESES
      PUSH  DX
        SUB   DX,CX
        DEC   DX
        SUB   SI,DX
        SUB   DI,DX        ; SI,DI VISSZALEPTETVE
      POP   DX
     POP    CX
        JMP   TOVABB

NEM_TALALT:
        OR     BX,BX
        JZ     KILEP
        ADD    BP,DX      ; ATNEZETT TERULET
     XCHG   BX,BP
        RCR    BX,1
        MOV    CX,3
        SHR    BX,CL

TOV2:   MOV    CX,ES
        ADD    BX,CX

        SUB    BX,03        ; ATLAPOLAS
        MOV    ES,BX        ; KOV ATNEZENDO ES:0-TOL
     XCHG   BX,BP
     INC    BH          ; ATLAPOLASOK SZAMOLASA
        XOR    DI,DI
        DEC    SI
        OR     BL,BL        ; TELJES SZEGMENS ?
        JZ    UTOLJA
        DEC    BL
        MOV    BP,0FFFFH        ;64 K-T ATNEZNI
        SUB    BP,DX
        INC    BP
        JMP    KERES       ; UJABB 64-K ATNEZES

UTOLJA:  INC   CH          ; MERET SZAMOLAS

         MOV   AX,03       ;  STRINGHOSSZ PARAGR +1
         MUL   BH
         MOV   CX,4
         SHL   AX,CL
         MOV   BX,AX       ;  k * 48 /BYTE-BAN
         ; SUB   BX,DX
         ; JB    KILEP       ; KERESENDO S. HOSSZABB TERULETNEL
         MOV   BP,BX
         INC   BP
         XOR   BX,BX
         JMP   KERES

KILEP:  STC
        RET

TALALT: POP    CX           ; STACK   VISSZA $$$$$$$$$$
        SUB    DI,DX
        SUB    SI,DX
        CLC
        RET


KERES   ENDP

NORMAL   PROC NEAR     ;  ELJARAS OFFSET MINIMALIZALASARA
        MOV   BX,AX    ;   AX-BON NORMALANDO OFFSET
        AND   AX,0FH   ;   VEGEN    AX-BEN UJ OFFSET
        MOV   CX,4
        SHR   BX,CL    ;            BX-BEN SEGMENS NOVEKMENY
        RET
NORMAL   ENDP

;
; ***************************************************************************

CODE   ENDS
end
