; CDW kep nyomtatashoz sortagito
; TP5-hoz TASM formatumban
;
.MODEL TPASCAL
.CODE
TAGIT proc near ebbol: dword, ebbe: dword, ennyi: word,  mennyit: dword
;               tomb            tomb       ebbol tomb    tomb: minden eleme
;              bitjeit        bitjeibe     byteszama     azt mutatja, hogy
;  hanyszor kell 'ebbol' soronkovetkezo bitjet 'ebbe' irni

public tagit

      cld

      push ds
      push es

      mov cx,ennyi  ; cx byte szamlalo
      lds si,mennyit; ds:si 'mennyit' elso elem cime
      les di,ebbe   ; es:di 'ebbe'  elso elem cime
      mov dl,80h    ; dl = ebbe bitszamlalo es bitmutato (jobbra tolodik!)
      mov al,0      ; AL = letrehozando byte

nagyhur:
           push cx

;     next tagitando byte AH-ba

           push ds
           lds bx,ebbol       ; elso elem
           mov AH,[bx]        ; get it
           inc word ptr ebbol ; next
           pop ds

           mov cx,8  ; nyolc bitje a tagitandonak

  bitek:
           mov DH,[si]    ; DH = mennyit
           inc si         ; next mennyit
           shl AH,1       ; balszelso minta bit
           jc kitolt      ; beallitani

    torol:
           shr DL,1       ; van-meg bitmutato jobbra tolodik
           jnc torol1     ; 80->40->20->10->08->04->02->01-> carry
           stosb          ; letrehozott AL betelt, berakni, nextre allni
           mov AL,0       ; next erre egyenlore ures
           mov DL,80h
     torol1:
           dec DH         ; amennyit kell
           jnz torol      ; meg van
           jmp short bitek_next ; next minta byte

    kitolt:               ; AL-kovetkezo szabad bitje(i)t beallitja
           or AL,DL       ; bitet beallit
           shr DL,1       ; van-meg bitmutato jobbra tolodik
           jnc kitolt1    ; 80->40->20->10->08->04->02->01-> carry
           stosb          ; letrehozott AL betelt, berakni, nextre allni
           mov AL,0       ; next erre egyenlore ures
           mov DL,80h
     kitolt1:
           dec DH         ; amennyit kell
           jnz kitolt     ; van meg, lehet

bitek_next:  loop bitek

      pop cx
      loop nagyhur

      stosb          ; hatha maradt valami elraknivalo

      pop es
      pop ds
      ret


      endp
      END