CODE segment WORD PUBLIC
   assume cs:CODE

public tuk_mat

;==============================================================
tuk_mat  proc far       ; garfikus nyomtatashoz kar.num es font.num
			; alapjan 'tuk' matrixot feltolti
                        ; ha [bp+18] = 0, akkor
                        ; elso 12 byte: karakter felso 5 pixelje
                        ; masodik 12 byte: karakter also 5 pixelje
                        ;  ha [bp+18] = 1, akkor
			;  0..11 byte teteje elso nekifutasnal
			;  12..23 byte alja elso nekifutasnal
			; ha [bp+18] = 2, akkor
			;  0..11 byte teteje masodik nekifutasnal
			;  12..23 byte alja masodik nekifutasnal

; hivasa: tuk_mat (nekifut,kar, font, fontok.ofs, fontok.segm, tuk.ofs, tuk.segm)

        push bp
        mov bp,sp
        push es

        push ds ; nem a pascal data segmensben matatunk!

        mov es,[bp+6] ; tuk matrix segm
        mov di,[bp+8] ; tuk matrix offset

; ha a karakter space, akkor nem kell semmi!!!!!

     cmp byte ptr [bp+16],32
     jnz tdft_k1

tdft_sp: jmp tdft_space

tdft_k1:
        mov ds,[bp+10] ; fontok segmens
        mov si,[bp+12]; fontok offset

  mov cx,[bp+14] ; hanyadik font kell? 1..10
  mov dx,18*128  ; egy font keszlet hossza, DFT

  cmp byte ptr [bp+18],0 ; draft kell?
  jz tdft_h1             ; igen
  mov dx,33*128          ; font keszlet hossza, PFT

 tdft_h1:  add si,dx
           loop tdft_h1  ; eggyel tul megy!

           sub si,dx     ; igy jo: si = fontkezdet!

     add si,158h      ; '!'  kezdocime fontkezdethez kepest
     mov ax,20        ;  DFT egy karakter hossza
     cmp byte ptr [bp+18],0
     jz dft0
     add ax,ax        ; PFT egy karakter hossza
  dft0: sub si,ax     ; SI = space kezdocime

     mov ax,[bp+16]   ; melyik karakter kell?
     sub al,32        ; csak 32 .. 127 lehet

tdft_keres:

   shl ax,1   ; *2
   shl ax,1   ; *4
   push ax
   shl ax,1   ; *8
   shl ax,1   ; *16
   pop bx
   add bx,ax  ; bx = 20 * ax, karakter kezdet space-hoz kepest

cmp byte ptr [bp+18],0   ; DFT kell?
       jz dft1     ; igen
       add bx,bx   ; bx = 40 * ax
dft1:  add si,bx   ; si = kar.matrix kezdet

; ha masodik nekifutas, akkor 2-byte-tal tovabb kezdodik
cmp byte ptr [bp+18],2
jnz dft2

add si,2

dft2:
        mov cx,8   ; elso byte: mind a nyolc bit
tdft_forg1:
   push cx
   mov bx,0    ; 0. byte
   mov cx,5    ; elso 5 byte par

tdft_forg2:

            rol byte ptr [si+bx],1   ; balra: carry-be es jobbrol visszajon
            rcl al,1                 ; carry jobbrol bejon
            inc bx
            inc bx
       cmp byte ptr [bp+18],0 ; DFT-nel csak 2-vel megyunk tovabb
       jz dft3
                inc bx
		inc bx

       dft3:    loop tdft_forg2        ; elso 5 bit bejott al-be
                shl al,1
		shl al,1
		shl al,1		; felkerult a felso 5 bitbe
            stosb                  ; el van rakva

            pop cx
            loop tdft_forg1

  mov cx,4   ; masodik byte: csak 4 bit
tdft_forg1a:
   push cx
   mov bx,0    ; 0. byte
   mov cx,5    ; elso 5 byte par

tdft_forg2a:

            rol byte ptr [si+bx+1],1 ; balra: carry-be es jobbrol visszajon
            rcl al,1                 ; carry jobbrol bejon
            inc bx
            inc bx
            cmp byte ptr [bp+18],0
            jz dft4
                inc bx
		inc bx

        dft4:  loop tdft_forg2a        ; elso 5 bit bejott al-be
                shl al,1
		shl al,1
		shl al,1		; felkerult a felso 5 bitbe
            stosb                  ; el van rakva

            pop cx
            loop tdft_forg1a

     tdft_memo:
                or bx,bx  ; ha visszaert nullara, akkor kesz!
                jz tdft_memo_end
		dec bx	; elozo byte par
		dec bx
           cmp byte ptr [bp+18],0  ; DFT?
           jz dft5
                dec bx
                dec bx
         dft5:
                mov cl,4   ; memoriat tovabb forgatni, hogy a helyre alljon
                rol byte ptr [si+bx+1],cl ;  balra: carry-be es jobbrol visszajon
		jmp tdft_memo
     tdft_memo_end:

; most jon az also 5 pixelsor --------------------------------------
; raallunk
;
dft_also:    mov bx,10    ; 10. byte
             cmp byte ptr [bp+18],0   ; DFT-nel eleg
             jz dft99
             add bx,bx    ; PFT-nel 20.-nal kezdodik
      dft99: add si,bx    ; SI kar matrix also 5 sor elso sora
                          ; ---
             xor ax,ax
             mov cx,8
tdft_forg3:
             push cx
             mov bx,0     ; 0. relativ byte
   dft6:     mov cx,5     ; masodik 5 byte par

tdft_forg4:
            rol byte ptr [si+bx],1 ;  balra: carry-be es jobbrol visszajon
            rcl al,1               ; carry jobbrol bejon
            inc bx
            inc bx
            cmp byte ptr [bp+18],0
            jz dft7
                inc bx
		inc bx
     dft7:  loop tdft_forg4        ; elso 5 bit bejott al-be
                shl al,1
		shl al,1
		shl al,1		; felkerult a felso 5 bitbe
            stosb                  ; el van rakva

            pop cx
            loop tdft_forg3

   mov cx,4     ; masodik byte: csak 4 bit kell

tdft_forg3a:
       push cx
       mov bx,0
dft8:  mov cx,5     ; masodik 5 byte par

tdft_forg4a:
            rol byte ptr [si+bx+1],1 ;  balra: carry-be es jobbrol visszajon
            rcl al,1                 ; carry jobbrol bejon
            inc bx
            inc bx
               cmp byte ptr [bp+18],0
               jz dft9
               inc bx
               inc bx

dft9:  loop tdft_forg4a        ; elso 5 bit bejott al-be
                shl al,1
		shl al,1
		shl al,1		; felkerult a felso 5 bitbe
            stosb                       ; el van rakva

            pop cx
            loop tdft_forg3a


     tdft_memo1:
            or bx,bx              ; ujra nulla?
            jz tdft_memo1_end     ; akkor vege
            dec bx
		dec bx
            cmp byte ptr [bp+18],0
            jz dft10
            dec bx
		dec bx
   dft10:
            mov cl,4         ; memoriat tovabb forgatni, hogy a helyre alljon
            rol byte ptr [si+bx+1],cl ;  balra: carry-be es jobbrol visszajon
            jmp tdft_memo1

tdft_memo1_end:  jmp short tdft_kilep

tdft_space:   xor ax,ax

                           mov cx,12
          tdft_sp_h:       stosw     ; es:di-tol 24 nullat!
                           loop tdft_sp_h

tdft_kilep:	pop ds

                pop es
                pop bp
                ret 14

tuk_mat endp

CODE            ends

end









