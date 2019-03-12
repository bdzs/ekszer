; CDW k‚p nyomtat shoz sorsz–k¡t“
; TP5-hoz TASM form tumban
;
.MODEL TPASCAL
.CODE
SZUKIT proc near ebbol: dword, ebbe: dword, ennyi: word,  mennyit: dword
;               tomb            tomb        ebbe tomb     tomb: minden eleme
;              bitjeit        bitjeibe      byteszama     azt mutatja, hogy
;  hany 'ebbol' bitbol kell egy 'ebbe' bit-et irni

public szukit

      cld

      push ds
      push es

      mov cx,ennyi  ; cx byte szamlalo
      lds si,mennyit; ds:si 'mennyit' elso elem cime
      les di,ebbol  ; es:di 'ebbol'   elso elem cime

      mov DL,80h     ; DL = ebbe bitmutato (jobbra tolodik!)
      mov BL,8       ; szukitendo bitszamlalo
      mov AH,es:[di] ; elso szukitendo byte AH-ba
      inc di

nagyhur:   push CX
           mov CH,0
           mov AL,0       ; AL = letrehozando byte

  next_bit:
           mov CL,[si]    ; CL = mennyibol legyen egy bit
           inc si         ; next mennyibol
           or cl,cl       ; 0 = atugorni !!!!! nincs ra mar szukseg
           jz ittavege

   egyszerre:
           shl AH,1       ; balszelso minta bit
           jnc amennyi    ; amennyibol egyet csinalunk

   kitolt:                ; AL-kovetkezo szabad bitje(i)t beallitja
           or AL,DL       ; bitet beallit

  amennyi:
           dec BL         ; max. nyolc bit van egy byte-ban
           jnz van_meg

           mov BL,8       ; szukitendo bitszamlalo
           mov AH,es:[di] ; next szukitendo byte AH-ba
           inc di
   van_meg:
           loop egyszerre ;

           ror DL,1       ; kovetkezo bitpozicio
           jnc next_bit   ; meg byte-on belul van

      ittavege:
           push es
           push di
           les di,ebbe    ; elrakni a kesz byte-ot
           stosb
           inc word ptr [ebbe] ; next address
           pop di
           pop es

           pop CX
           loop nagyhur

      pop es
      pop ds
      ret


szukit  endp
      END