; CDW-hez ALT_HELP kiiratasa
; TP5-hoz TASM form�tumban

.MODEL TPASCAL
.CODE

ALT_HELP PROC FAR NUM: WORD, STRIN: DWORD

PUBLIC ALT_HELP

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

ALT_HELP ENDP

STRINGS:

DB    "����",00                ;{  1 }
DB    "���� � ᬥ��",00      ;{  2 }
DB    "�᪠�� �����",00         ;{  3 }
DB    "������� ᫮��",00           ;{  4 }
DB    "������� ��ப�",00           ;{  5 }
DB    "��������� ���ࠢ�",00         ;{  6 }
DB    "��砫� ���. �����",00      ;{  7 }
DB    "�⮫�殢� ����",00         ;{  8 }
DB    "�������� ����.",00       ;{  9 }
DB    "���������� ���",00            ;{ 10 }
DB    "������� � �����",00        ;{ 11 }
DB    "�����஢��� ����",00      ;{ 12 }
; **************** Innen BlockHelp is ********************
DB    "������� ����",00        ;{ 13 }
DB    "����� �㪢�",00       ;{ 14 } { Ide j�n a helyes�r�sellen�rz�s }
DB    "�ய��� �㪢�",00      ;{ 15 }
DB    "����� <-> �ய���",00     ;{ 16 }
DB    "���   <-> �����",00      ;{ 17 }
DB    "��१��� ����",00        ;{ 18 }
DB    "������� ����",00       ;{ 19 }
DB    "�����ﭨ� ��ப 1",00         ;{ 20 }
DB    "�����ﭨ� ��ப 1",00         ;{ 20 }
DB    "�����ﭨ� ��ப 2",00         ;{ 20 }
DB    "�����ﭨ� ��ப 3",00         ;{ 20 }
DB    "�����ﭨ� ��ப 4",00         ;{ 20 }
DB    "�����ﭨ� ��ப 5",00         ;{ 20 }
DB    "�����ﭨ� ��ப 6",00         ;{ 20 }
DB    "�����ﭨ� ��ப 7",00         ;{ 20 }
DB    "�����ﭨ� ��ப 8",00         ;{ 20 }
DB    "�����ﭨ� ��ப 9",00         ;{ 20 }
DB    "�����ﭨ� ��ப 10",00         ;{ 20 }
; **************** Eddig BlockHelp is ********************
DB    "���� ��࠭���",00    ;{ 30 }
DB    "������� �㪢���",00   ;{ 31 }
DB    "��� �஡��",00           ;{ 32 Mindig ez legyen a legutols� }

VEGE:

END
