.model tpascal
.code
 public makelong



makelong proc far elso: word, masodik: word, harmadik: word

        xor dx,dx
        xor ax,ax
        mov cl,4

        mov bx,elso
        call HL100
        mov bx,masodik
        call HL100
        mov bx,harmadik
        call HL100

        ret
makelong endp

HL100 proc near

      mov cl,4
      xor bh,bh
      push  bx

      and bl,0F0h   ; elso 4 bit
      shr bl,cl     ;
      call DXAX10   ; megszorozza tizzel DX-AX-et
      add ax,bx     ; vegere beteszi

      pop bx
      and bl,00Fh   ; masodik 4 bit
      call DXAX10   ; megszorozza tizzel DX-AX-et
      add ax,bx     ; vegere beteszi

      ret
HL100 endp


DXAX10 proc near


       shl AX,1
       rcl DX,1  ; * 2

       push dx
       push ax

       shl AX,1
       rcl DX,1  ; * 4
       shl AX,1
       rcl DX,1  ; * 8

       pop cx  ; AX*2
       add ax,cx
       pop cx
       adc dx,cx

       ret

DXAX10 endp

         end