; rutin 30 sor magas 24 pont szeles nyomtatashoz 8 tus matrix nyomtaton
; kap : tomb cime, ahol 3 vagy 4 byte van egymas utan,
;       6 byte-os tomb cime, ahova a 6 nekifutashoz valo adatokat teszi
;       minden nekifutas 5 tut mukodtet (minden harmadikat)
;       oszlopok szama
;       vanLelogo: 3 vagy 4 elem egy oszlopban
.model tpascal
.code

public make6run

make6run proc near  ebbol : dword , ebbe : dword, oszlopok_szama: word, vanlelogo : byte

          push ds

          lds si,ebbol
          les di,ebbe

          mov cx,oszlopok_szama ; nagy hurok-hoz
     huri:
          ; al-t tologatjuk es ah, bl, bh - ban  gyujtjuk
          xor ax,ax
          xor bx,bx
          ;
          lodsb  ; get byte into AL ; SI := SI + 1
          shl al,1 ; 7.bit carry-be
          rcl ah,1 ;          AH 1.
          shl al,1 ; 6. bit
          rcl bl,1 ;                 BL 1.
          shl al,1 ; 5. bit
          rcl bh,1 ;                         BH 1.

          shl al,1 ; 4. bit
          rcl ah,1 ;          AH 2.
          shl al,1 ; 3. bit
          rcl bl,1 ;                 BL 2.
          shl al,1 ; 2. bit
          rcl bh,1 ;                         BH 2.

          shl al,1 ; 1. bit
          rcl ah,1 ;          AH 3.
          shl al,1 ; 0. bit   : elfogyott
          rcl bl,1 ;                 BL 3.

          lodsb    ; next byte into AL
          shl al,1 ; 7.bit carry-be
          rcl bh,1 ;                         BH 3.
          shl al,1 ; 6. bit
          rcl ah,1 ;          AH 4.
          shl al,1 ; 5. bit
          rcl bl,1 ;                 BL 4.
          shl al,1 ; 4. bit
          rcl bh,1 ;                         BH 4.
          shl al,1 ; 3. bit
          rcl ah,1 ;          AH 5.
          shl al,1 ; 2. bit
          rcl bl,1 ;                BL 5.

          shl al,1 ; 1. bit
          rcl bh,1 ;                         BH 5.

          ; a karakter felso 3 nekifutasa keszen van, elrakni !!!
          mov es:[di], ah
          inc di
          mov es:[di], bl
          inc di
          mov es:[di], bh
          inc di

          xor ah,ah    ; tarolokat nullazni
          xor bx,bx

          shl al,1 ; 0. bit   : elfogyott
          rcl ah,1 ;          AH 1.

          lodsb    ; 3. byte-ot atvesz, lehet, hogy az utso
          shl al,1 ; 7.bit carry-be
          rcl bl,1 ;                 BL 1.
          shl al,1 ; 6. bit
          rcl bh,1 ;                         BH 1.
          shl al,1 ; 5. bit
          rcl ah,1 ;          AH 2.
          shl al,1 ; 4. bit
          rcl bl,1 ;                 BL 2.
          shl al,1 ; 3. bit
          rcl bh,1 ;                         BH 2.
          shl al,1 ; 2. bit
          rcl ah,1 ;          AH 3.
          shl al,1 ; 1. bit
          rcl bl,1 ;                 BL 3.
          shl al,1 ; 0. bit   : elfogyott
          rcl bh,1 ;                         BH 3.

          cmp vanlelogo,0     ; ha nincs, akkor vege !
          jne tovabb_megy     ; van
          shl ah,1
          shl ah,1
          shl bl,1
          shl bl,1
          shl bh,1
          shl bh,1            ; kettovel arrabb tolni !!!
          jmp next_oszlop     ; nincs

   tovabb_megy:
          lodsb    ; 4. byte-ot atvesz, csak 6 bit kell !
          shl al,1 ; 7.bit carry-be
          rcl ah,1 ;          AH 4.
          shl al,1 ; 6. bit
          rcl bl,1 ;                 BL 4.
          shl al,1 ; 5. bit
          rcl bh,1 ;                         BH 4.
          shl al,1 ; 4. bit
          rcl ah,1 ;          AH 5.
          shl al,1 ; 3. bit
          rcl bl,1 ;                 BL 5.
          shl al,1 ; 2. bit
          rcl bh,1 ;                         BH 5.


      next_oszlop:

          ; a karakter also 3 nekifutasa keszen van, elrakni !!!
          mov es:[di], ah
          inc di
          mov es:[di], bl
          inc di
          mov es:[di], bh
          inc di

          dec cx
          jz kilep
          jmp huri

     kilep:
          pop ds
          ret

make6run endp

end


