; hercules grafika megallapito rutin
.model tpascal
.code
public hercgraf
public xplot

hercgraf proc near

         mov dx,3bbh
         out dx,al  ; cleat light pen latch
         dec dx
  l01:   in al,dx
         test al,80h
         jnz l01    ; wait for start of vert retrace
  l02:   in al,dx
         test al,80h
         jz l02     ; wait for end of vert retrace

         cli
  l03:   in al,dx   ; wait for start
         test al,80h
         jnz  l03

         dec dx
         out dx,al  ; load latch
         sti

         mov dl,0b4h
         mov al,10h
         out dx,al
         inc dx
         in al,dx
         dec dx
         mov ah,al
         mov al,11h
         out dx,al
         inc dx
         in al,dx

         ; ax = current light pen latch value
         ret

hercgraf  endp


xplot proc near x,y, scrseg: word

      mov ax,y
      mov bx,x
      mov es,scrseg

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

      mov al,1   ; set pix
      shl ax,cl

      test al,al
      jz ll02
      xor es:[bx],al

ll02:  ret

xplot endp

          end