; CDW-hez ALT_HELP kiiratasa
; TP5-hoz TASM formаtumban

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

DB    "Поиск",00                ;{  1 }
DB    "Поиск и смена",00      ;{  2 }
DB    "Искать дальше",00         ;{  3 }
DB    "Удалить слово",00           ;{  4 }
DB    "Удалить строку",00           ;{  5 }
DB    "Подгонить направо",00         ;{  6 }
DB    "Начало стр. блока",00      ;{  7 }
DB    "Столбцовый блок",00         ;{  8 }
DB    "Резольтат кальк.",00       ;{  9 }
DB    "Сегодняшняя дата",00            ;{ 10 }
DB    "Записать и конец",00        ;{ 11 }
DB    "Вкопировать блок",00      ;{ 12 }
; **************** Innen BlockHelp is ********************
DB    "Удалить блок",00        ;{ 13 }
DB    "Строчные буквы",00       ;{ 14 } { Ide jФn a helyesбrаsellenУrzВs }
DB    "Прописные буквы",00      ;{ 15 }
DB    "Строчные <-> Прописные",00     ;{ 16 }
DB    "Мягкий   <-> Твердый",00      ;{ 17 }
DB    "Вырезать блок",00        ;{ 18 }
DB    "Удалить блок",00       ;{ 19 }
DB    "Расстояние строк 1",00         ;{ 20 }
DB    "Расстояние строк 1",00         ;{ 20 }
DB    "Расстояние строк 2",00         ;{ 20 }
DB    "Расстояние строк 3",00         ;{ 20 }
DB    "Расстояние строк 4",00         ;{ 20 }
DB    "Расстояние строк 5",00         ;{ 20 }
DB    "Расстояние строк 6",00         ;{ 20 }
DB    "Расстояние строк 7",00         ;{ 20 }
DB    "Расстояние строк 8",00         ;{ 20 }
DB    "Расстояние строк 9",00         ;{ 20 }
DB    "Расстояние строк 10",00         ;{ 20 }
; **************** Eddig BlockHelp is ********************
DB    "Поиск страницы",00    ;{ 30 }
DB    "Результат буквами",00   ;{ 31 }
DB    "Мягкий пробел",00           ;{ 32 Mindig ez legyen a legutolsв }

VEGE:

END
