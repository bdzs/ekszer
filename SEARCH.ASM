; SEARCH rutin CDW-hez
; FONTOK rutin CDW-hez

CODE segment WORD PUBLIC
   assume cs:CODE

public search
public bsearch   ; visszafele keres; javitani !!!!!
public fontok
public sort
Extrn  Heap_posX : Near
Extrn  FreeEms1X : Near
Extrn  Hptr      : Dword
Extrn  C78       : Word
Extrn  C80       : Word
Extrn  UPPER     : Near
Extrn  UpperChar

Extrn  OszlopMode  : Byte
Extrn  BlokkSearch : Byte
Extrn  Veg         : Word;

CC78   DW 0078
CC80   DW 0080

; SEARCH rutin CDW-hez
;----------------------
; hivasa:
; doubleword =
;  search(ptomb_seg,xpos, str_offs, pointertomb_offs, tol, ig, heap_segmens, upc, attr)
;         22         20    18        16                14   12   10            8     6
;
; upc  = 0, ha nem kell upper case atvaltas, ha <>0 , akkor kell
; attr = 0, ha karaktereket kell keresni, ha <>0, akkor attrib
;
; visszaad  DX = ahanyadikban van meg (0 = nincs meg)
;           AX = Xpos

SEARCH proc far

       push bp
       mov  bp,sp
       push es

       MOV  AX,DS:[C78]
       MOV  CS:[CC78],AX

       MOV  AX,DS:[C80]
       MOV  CS:[CC80],AX

       CMP  BYTE PTR DS:BLOKKSEARCH,1
       JNZ  NEMBLOKKSEARCH_0

       PUSH BX

       MOV  BX,[BP+14]
       CMP  BX,[BP+12]
       JNZ  ELOTTE_UTANA_0

       MOV  BX,DS:[VEG]
       INC  BX
       MOV  CS:[CC78],BX

ELOTTE_UTANA_0:
       POP  BX

NEMBLOKKSEARCH_0:

       dec word ptr [bp+14]  ; 1-es szamu tombelem a 0.
                             ; igy [bp+12]-ik mar nem kell !!

       mov si,[bp+18]        ; string hossza cim
       xor ch,ch
       mov cl,[si]           ; CX = string hossza    ; megorizni!
       inc si                ; DS:SI string kezdete  ; megorizni!

       mov dl,byte ptr [bp+8] ; kell  upcase?        ; megorizni!

       xor di,di             ; di = 0
       add di,[bp+20]        ; DI = Xpos

search_hur:
       call get_heap_segm    ;bp+14. sor alapjan ES:BX-raall a heap_sorra

       call keres           ; z= nincs,   nz= megvan

    Pushf
    Push ax
    push cx
    push dx
    push di
    push si
    push bp

    Call FreeEms1X

    pop  bp
    Pop  si
    pop  di
    pop  dx
    pop  cx
    pop  ax
    Popf

       jnz megvan_kilep

       mov  ax,[bp+14]        ; tol
       inc  ax                ; next pointer
       cmp  ax,[bp+12]        ; ez mar nem kell
       jz   nincs_kilep       ; nem talalta meg
       mov  [bp+14],ax        ; ebben keress tovabb!
       xor  di,di             ; xpos = 0

       CMP  BYTE PTR DS:BLOKKSEARCH,1
       JNZ  NEMBLOKKSEARCH
       CMP  BYTE PTR DS:OSZLOPMODE,1
       JNZ  NEMOSZLOPMODE

       add  di,[bp+20]        ; DI = Xpos

NEMOSZLOPMODE:

       PUSH BX

       MOV  BX,[BP+14]
       INC  BX
       CMP  BX,[BP+12]
       JNZ  ELOTTE_UTANA

       MOV  BX,DS:[VEG]
       INC  BX
       MOV  CS:[CC78],BX

ELOTTE_UTANA:
       POP  BX

NEMBLOKKSEARCH:
       jmp search_hur

 nincs_kilep:    XOR AX,AX    ; nincs meg
                 XOR DX,DX
                 jmp short search_kilep

 megvan_kilep:   mov ax,di        ; Xpos
                 mov dx,[bp+14]   ; ennyiedik
                 inc dx

 search_kilep:  pop es
                pop bp
                ret 18

SEARCH endp

;========================================================================

get_heap_segm proc near  ; [bp+14] a pointer tomb elemenek sorszama
                         ; [bp+16] pointer tomb offsetje
                         ; [bp+10] heap segmens (offsett = 0 !!!)
                         ; [bp+6]  attr vagy karakter kell
                         ; out:    ES-t raallitja a keresett sorra


    Push ax
    push cx
    push dx
    push si
    push bp
    Push di

    Mov  Bx,[bp+14]
    Mov  Word ptr Ds:[Hptr],Bx
    Call Heap_posX
    Mov  Bx,word ptr Ds:[Hptr+2]

    pop  di
    pop  bp
    Pop  si
    pop  dx
    pop  cx
    pop  ax


    cmp  byte ptr [bp+6],0    ; ha nulla, akkor karakter
    jnz  heap_segm_kesz      ; attrib kell: rajta all

    Push Ax
    Mov  Ax,CS:[CC80]
    Shr  Ax,1
    Shr  Ax,1
    Shr  Ax,1
    Shr  Ax,1               ; C80/16

    add  bx,Ax
    Pop  Ax

  heap_segm_kesz:   mov es,bx
                    mov bx,word ptr Ds:[Hptr]
                    ret

get_heap_segm endp

;------------------------------------------------------------------------
; keres:  DS:SI  amit keres string eleje
;         ES:DI  amiben keres eleje     (DI = 0..77)
;         BX     Amiben keres offset
;         CX keresendo string hossza
;         DL = 0, ha nem kell upcase
;                 kulonben kell upcase
;         keresendo stringben 0 = joker
;
; out:     zflag beallitva = nincs meg
;          not zero        = megvan
;          DI  : megtalalt Xpos vagy 78 ha nincs meg

keres proc near

      jmp short ujra_probal

bent_nem_jo: pop si   ; ujra a string elejere            |
             pop di   ; ez az elso pos ami jo volt       |
             pop cx   ; hossz                            |
             inc di   ; nezzuk a kovetkezotol
             cmp di,CS:[CC78]     ; mar a vegen vagyunk?
             jz  nincs_meg ; tovabb nem kell keresni
ujra_probal:
      push si         ; keresendo eleje                  ^

probalkozik:
      mov ah,ds:[si]  ; elso byte-ja a keresendonek
      or  ah,ah       ; joker?
      jz  eddig_azonos; akkor jo
      mov al,es:[di+bx]  ; ebben keresunk
      or al,al        ; ha nulla, akkor spacet csinalni belole!
      jnz kell_up
      mov al,32       ; biztos nem kell upcase
      jmp short egyforma_e

kell_up:      or dl,dl        ; kell upcase?
              jz egyforma_e   ; nem
              call upcase

egyforma_e:  cmp ah,al
             jz  eddig_azonos

nem_egyforma:  inc di ; ebben keres novekszik
               pop si ; keresendo elejeo              |

               cmp di,CS:[CC78] ; mar a vegen vagyunk?
               jnz ujra_probal

nincs_meg:     ret ; zero = nincs meg

eddig_azonos:
                pop si  ;                              |
                push cx ; hossz                         ^
                push di ; X-pos ha tenyleg megvan       ^
                push si ; string eleje                  ^

bent_probalkozik:
                inc si              ; ezt next byte
                inc di              ; ebben next byte
                dec cl              ; hossza csokk
                jnz meg_van

megvan:         pop si    ;                              |
                pop di    ;                              |
                pop cx    ;                              |
                or al,al   ;      nem zero = megvan
                ret

meg_van:      cmp di,CS:[CC78]       ; sor vegen vagyunk mar?
              jnz meggg_van
              pop si
              pop di
              pop cx
              jmp nincs_meg

meggg_van:    mov ah,ds:[si]  ; next byte-ja a keresendonek
              or  ah,ah       ; joker?
              jz  meg_jo      ; akkor jo
              mov al,es:[di+BX]  ; ha 0, akkor 32 kell!
;              or al,al
;              jnz bent_up
;              mov al,32       ; biztosan nem kell up
;              jmp short azonos_e

bent_up:      or dl,dl        ; kell upcase?
              jz azonos_e     ; nem
              call upcase

azonos_e:   cmp al,ah
            jnz bent_nem_jo

meg_jo:     jmp bent_probalkozik


keres endp
;--------------------------------------------------------------
upcase proc near  ; al -bol nagybetut csinal, ha lehet

; cmp al,"a"
; jl upcase_end  ; al kisebb mint  "a"
; cmp al,"z"
; jg upcase_end  ; al nagyobb mint "z"
; sub al,32


MOV byte ptr DS:[UpperChar],AL

pushf
Push AX
push bx
push cx
push dx
push si
push di
push bp
push es

call UPPER

pop es
pop bp
pop di
pop si
pop dx
pop cx
pop bx
pop AX
popf

MOV  AL, byte ptr DS:[UpperChar]

upcase_end: ret

upcase endp
;-------------------------------------------------------------
; BSEARCH rutin CDW-hez     visszafele keres
;----------------------
; hivasa:
; doubleword =
;  search(ptomb_seg, xpos, str_offs, pointertomb_offs, tol, ig, heap_segmens, upc, attr)
;         22          20    18        16                14   12   10            8     6
;
; upc  = 0, ha nem kell upper case atvaltas, ha <>0 , akkor kell
; attr = 0, ha karaktereket kell keresni, ha <>0, akkor attrib
;
; visszaad  DX = ahanyadikban van meg (0 = nincs meg)
;           AX = Xpos

bSEARCH proc far

       push bp
       mov  bp,sp
       push es

       MOV  AX,DS:[C78]
       MOV  CS:[CC78],AX

       MOV  AX,DS:[C80]
       MOV  CS:[CC80],AX

       dec word ptr [bp+12]  ; 1-es szamu tombelem a 0.
       dec word ptr [bp+12]  ; ez mar nem kell!!!!
       dec word ptr [bp+14]  ; indexeles 0-tol

       mov si,[bp+18]        ; string hossza cim
       xor ch,ch
       mov cl,[si]           ; CX = string hossza    ; megorizni!
       inc si                ; DS:SI string kezdete  ; megorizni!

       mov dl,byte ptr [bp+8] ; kell  upcase?        ; megorizni!

       xor di,di             ; di = 0
       add di,[bp+20]        ; DI = Xpos

bsearch_hur:
       call get_heap_segm    ;bp+14. sor alapjan ES:BX-raall a heap_sorra

       call keres           ; z= nincs,   nz= megvan

    Pushf
    Push ax
    push cx
    push dx
    push di
    push si
    push bp

    Call FreeEms1X

    pop  bp
    Pop  si
    pop  di
    pop  dx
    pop  cx
    pop  ax
    Popf

       jnz bmegvan_kilep

       mov ax,[bp+14]        ; tol
       dec ax                ; next pointer
       cmp ax,[bp+12]        ; ez mar nem kell
       jz bnincs_kilep       ; nem talalta meg
       mov [bp+14],ax        ; ebben keress tovabb!
       xor di,di             ; xpos = 0
       jmp bsearch_hur

bnincs_kilep:    XOR AX,AX    ; nincs meg
                 XOR DX,DX
                 jmp short bsearch_kilep

bmegvan_kilep:   mov ax,di        ; Xpos
                 mov dx,[bp+14]   ; ennyiedik
                 inc dx

bsearch_kilep:  pop es
                pop bp
                ret 18

bSEARCH endp

; FONTOK (van-e beloluk) rutin CDW-hez
;-----------------------
; kell hozza egy (false-ra allitott) boolean tomb: vanfont[0..maxfontnum]
; hivasa:
;  fontok(Pointer_seg,0, vanfont_offs, pointertomb_offs, tol, ig, heap_segmens, 0, 0)
;            22       20     18        16                14   12   10           8  6
;

Fontok proc far

       push bp
       mov  bp,sp
       push es

       MOV  AX,DS:[C78]
       MOV  CS:[CC78],AX

       MOV  AX,DS:[C80]
       MOV  CS:[CC80],AX


       dec word ptr [bp+14]  ; 1-es szamu tombelem a 0.
                             ; igy [bp+12]-ik mar nem kell !!

       mov si,[bp+18]        ; ds:si vanfont[] cime
       mov dl,0fh            ; mask-hoz
       mov dh,1              ; or-hoz

Fontok_hur:
       xor  di,di            ; DI lenullazas
       Push BP
       call get_heap_segm1   ;bp+14. sor alapjan ES-raall a heap_sorra
       call bejelol          ;egy sor attributumain vegig
       POP  BP

    Pushf
    Push ax
    push cx
    push dx
    push di
    push si
    push bp

    Call FreeEms1X

    pop  bp
    Pop  si
    pop  di
    pop  dx
    pop  cx
    pop  ax
    Popf

       mov ax,[bp+14]        ; tol
       inc ax                ; next pointer
       cmp ax,[bp+12]        ; ez mar nem kell
       jz Fontok_vege        ; itt a vege
       mov [bp+14],ax        ; ezt nezd tovabb
       jmp Fontok_hur

 Fontok_vege:   pop es
                pop bp
                ret 18 ;9 parameter

Fontok endp

;========================================================================

get_heap_segm1 proc near ; [bp+14] a pointer tomb elemenek sorszama
                         ; [bp+16] pointer tomb offsetje
                         ; [bp+10] heap segmens (offsett = 0 !!!)
                         ; [bp+6]  attr vagy karakter kell
                         ; out:    ES-t raallitja a keresett sorra


    Push ax
    push cx
    push dx
    push si
    push bp
    push di

    Mov  Bx,[bp+14]
    Mov  Word ptr Ds:[Hptr],Bx
    Call Heap_posX
    Mov  Bx,word ptr Ds:[Hptr+2]

    pop  di
    add  di,word ptr Ds:[Hptr] ; megis jo

    pop  bp
    Pop  si
    pop  dx
    pop  cx
    pop  ax


    mov es,bx
    mov bp,word ptr Ds:[Hptr]
    Ret

get_heap_segm1 endp

;------------------------------
bejelol proc near

       mov cx,CS:[CC78]    ; ennyi karakter van egy sorban
       mov bh,ch    ; bh = 0,   bx mutat a tomb elemre
       ; DI -t beallitja a GetHeapSeg
       xor di,di    ; di = 0, elso attributum

bejelol_hur:

       mov bl,es:[di+Bp]   ; elso attrib
       and bl,dl        ; dl = 0F, jobb szelso negy bit kell
       or ds:[si+bx],dh ; dh =  1, adott font megvan
       inc di
       loop bejelol_hur

       ret

bejelol endp
;------------------------------

; sort: pascal string tombot rendez, bubble sort fizikai atpakolas
;
; hivasa:  sort (tomb_ofs, tomb_segm,  darab, egyseg_hossz)
;                   12         10         8       6
;                 elso     masodik

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
