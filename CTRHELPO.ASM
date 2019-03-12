; CDW-hez CTRL_HELP kiiratasa
; TP5-hoz TASM formаtumban

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

DB      "Показать картинку",00           ; { 01 }
DB      "Правый пробел",00               ; { 02 }
DB      "Левый пробел",00                ; { 03 }
DB      "Вкл/выкл табулятор",00          ; { 04 }
DB      "Добавить инд. строку",00              ; { 05 }
DB      "Удалить инд. строку",00          ; { 06 }
DB      "Вкл/Выкл синхрон.",00           ; { 07 }
DB      "Вкл/Выкл поправ.",00           ; { 08 }
DB      "Вкл/Выкл перенос",00        ; { 09 }
DB      "Дефиниция макро",00          ; { 10 }
DB      "Выполнить макро",00          ; { 11 }
DB      "Формат. абзац",00        ; { 12 }
DB      "Строку на середину",00        ; { 13 }
DB      "Строку налево",00         ; { 14 }
DB      "Строку поправить",00               ; { 15 }
DB      "Номер страницы",00            ; { 16 }
DB      "Начало текста",00             ; { 17 }
DB      "Конец текста",00              ; { 18 }
DB      "Инд. строку вверх",00          ; { 19 }
DB      "Инд. строку вниз",00           ; { 20 }
DB      "Начало слова",00             ; { 21 }
DB      "Конец слова",00            ; { 22 }
DB      "Вкл/Выкл рамки",00          ; { 23 }
DB      "Выбрать издание",00      ; { 24 }
DB      "Выбрать картинку",00            ; { 25 }
DB      "Слово-исключение",00            ; { 26 }
DB      "Вкл/выкл точки",00           ; { 30  Mindig ez az utolsв }

VEGE:

END
