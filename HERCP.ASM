hercplot proc near x,y: word, dot : byte
;
; dot = 0,1,

      mov ax,0B000h
      mov es,ax        ; scr segment
      mov ax,y
      mov bx,x

      mov cl,bl

      shr ax,1
      rcr bx,1
      shr ax,1
      rcr bx,1
      shr bx,1
      mov ah,90  ; bytes / line
      mul ah
      add bx,ax
      and cl,7
      xor cl,7
      mov ah,1

      mov al,dot   ; 0,1
      shl ax,cl

; itt kell elagazni: PUT, AND, OR, XOR

PUTPIX:      not ah
             and es:[bx],ah
             or  es:[bx],al

ANDPIX:      test al,al
             jnz vege
             not ah
             and es:[bx],ah

ORPIX:       test al,al
             jz vege
             or  es:[bx],al

XORPIX:      test al,al
             jz vege
             xor es:[bx],al

vege:
             ret

hercplot endp
