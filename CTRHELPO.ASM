; CDW-hez CTRL_HELP kiiratasa
; TP5-hoz TASM form�tumban

.MODEL TPASCAL
.CODE

CTRL_HELP PROC FAR NUM: WORD, STRIN: DWORD

PUBLIC CTRL_HELP

      PUSH   AX
      PUSH   BX
      PUSH   CX
      PUSH   DX
      PUSH   DI
      PUSH   SI
      PUSH   DS
      PUSH   ES

      PUSH   CS
      POP    ES

      MOV    DI,OFFSET STRINGS

      MOV    AL,00
      MOV    BX,NUM
      DEC    BX

      CLD
      MOV    CX,OFFSET VEGE - OFFSET STRINGS

CIK:  OR     BX,BX
      JZ     KESZ

      REPNZ  SCASB
      JNZ    NINCS

      DEC    BX
      JMP    SHORT CIK

NINCS:LES    DI,STRIN
      XOR    AL,AL
      STOSB
      JMP    SHORT VEG

KESZ: MOV    CX,30
      MOV    SI,DI
      REPNZ  SCASB
      SUB    DI,SI
      MOV    CX,DI

      LES    DI,STRIN
      DEC    CL
      MOV    AL,CL
      STOSB
      PUSH   CS
      POP    DS
      REPZ   MOVSB

VEG:  POP    ES
      POP    DS
      POP    SI
      POP    DI
      POP    DX
      POP    CX
      POP    BX
      POP    AX

      RET

CTRL_HELP ENDP

STRINGS:

DB      "�������� ���⨭��",00           ; { 01 }
DB      "�ࠢ� �஡��",00               ; { 02 }
DB      "���� �஡��",00                ; { 03 }
DB      "���/�몫 ⠡����",00          ; { 04 }
DB      "�������� ���. ��ப�",00              ; { 05 }
DB      "������� ���. ��ப�",00          ; { 06 }
DB      "���/�몫 ᨭ�஭.",00           ; { 07 }
DB      "���/�몫 ���ࠢ.",00           ; { 08 }
DB      "���/�몫 ��७��",00        ; { 09 }
DB      "��䨭��� ����",00          ; { 10 }
DB      "�믮����� ����",00          ; { 11 }
DB      "��ଠ�. �����",00        ; { 12 }
DB      "��ப� �� �।���",00        ; { 13 }
DB      "��ப� ������",00         ; { 14 }
DB      "��ப� ���ࠢ���",00               ; { 15 }
DB      "����� ��࠭���",00            ; { 16 }
DB      "��砫� ⥪��",00             ; { 17 }
DB      "����� ⥪��",00              ; { 18 }
DB      "���. ��ப� �����",00          ; { 19 }
DB      "���. ��ப� ����",00           ; { 20 }
DB      "��砫� ᫮��",00             ; { 21 }
DB      "����� ᫮��",00            ; { 22 }
DB      "���/�몫 ࠬ��",00          ; { 23 }
DB      "����� �������",00      ; { 24 }
DB      "����� ���⨭��",00            ; { 25 }
DB      "�����-�᪫�祭��",00            ; { 26 }
DB      "���/�몫 �窨",00           ; { 30  Mindig ez az utols� }

VEGE:

END
