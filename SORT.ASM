; sort: pascal string tombot rendez, bubble sort fizikai atpakolas
;
; hivasa:  sort (tomb_ofs, tomb_segm,  darab, egyseg_hossz)
;                   12         10         8       6
;                 elso     masodik

CODE segment WORD PUBLIC
   assume cs:CODE

public sort

sort proc  FAR

        push bp
        mov bp,sp
        push ds
;----------------------
        mov ax,[bp+10]
        mov ds,ax            ; ds = elso elem segm
        mov es,ax

        mov di,[bp+12]
        add di,[bp+6]        ; di = masodik elem
        inc di               ;
        mov [bp+10],di       ; elrakni

        mov bx,[bp+6]        ; bx = hossz

; hosszakat max-ra allit

       mov cx,[bp+8]        ; darab
       mov si,[bp+12]       ; cim
max:   mov [si],bl
       add si,bx
       inc si
       loop max

;  jmp ki  ;@@@@@@@@@@@@@@@@@@@@@@@
hur:    dec word ptr [bp+8]  ; eggyel kevesebb nekifutas
        jz  ki               ; kesz
        mov cx, [bp+8]       ; ennyi nekifutas lesz
        mov si,[bp+12]       ; elso     elem
        mov di,[bp+10]       ; masodik  elem

;----------------------------
; ds:si = elso hossz, es:di = masodik hossz, bx = hossz
; cserelni, ha kell
; si := si + bx + 1,  di := di + bx + 1
;

belso:    push bx

          inc di            ; elso elso kar
          inc si            ; masodik elso kar

csere_ha_kell:

          mov al,[si]    ; elso egy kar
          mov ah,[di]    ; masodik egy kar
          cmp ah,al         ; ha carry, akkor kell csere
          jz tovabb_nez     ; eddig egyformak
          jc csere          ; elso nagyobb

          ; masodik nagyobb: nem kell csere
          add di,bx
          add si,bx
          jmp di_si_ok

tovabb_nez:      inc di
                 inc si
                 dec bx
                 jnz csere_ha_kell

di_si_ok:        pop bx
                 loop belso
                 jmp hur

 ; [di] <-> [si], bx hosszan, mindkettot novelni!
 ; elso cserehez ah,al elokeszitve

 csere:   mov [si],ah
          inc si
          stosb             ; mov es:[di],al + inc di
          dec bx            ; van meg?
          jz  di_si_ok
          mov al,[si]       ; elso egy kar
          mov ah,[di]       ; masodik egy kar
          jmp short csere
;----------------------------------------------------

ki:     pop ds
        pop bp
        ret 8

sort    endp

CODE            ends

end

