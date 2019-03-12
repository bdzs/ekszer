; rutinok SZOTAGOL-hoz

.model tpascal
.code

public m_upcase,m_locase

extrn upctable1

m_upcase proc Far  cime : dword, hossza : word

         cld
         push es
         push ds

         les bx,cime
         INC BX
         mov cx,hossza
         or cx,cx
         jz mup_ok
   mup2:
	 mov al,es:[bx]
	 cmp al,'A'     ; csak betu lehet !!!!
	 jae betu
         cmp al,'-'
         jz  mup4
	 mov al,'*'
	 jmp short mup4
   betu:
         cmp al,'a'
         jb mup1
         cmp al,'z'
         ja mup3     ; magyar lehet
         sub al,32   ; make upcase
   mup4: mov es:[bx],al

   mup1: inc bx
         loop mup2

   mup_ok:
         pop ds
         pop es
         ret

   mup3: push ax
         mov  ax,seg upctable1
         mov  ds,ax
         pop  ax

         mov si,offset upctable1
         mov di,si
         add di,9

         push cx
         mov cx,9
    mup5:
         cmp al,ds:[si]
         jne mup6
         mov al,ds:[di]
         pop cx
         jmp mup4

    mup6: inc si
          inc di
          loop mup5

         pop cx
         jmp mup1

m_upcase endp

m_locase proc Far  cime : dword, hossza : word

         cld
         push es
         push ds

         les bx,cime
         INC BX
         mov cx,hossza
         or cx,cx
         jz Mlo_ok
   Mlo2:
	 mov al,es:[bx]
	 cmp al,'A'     ; csak betu lehet !!!!
	 jae L_betu
         cmp al,'-'
         jz  mLo4
	 mov al,'*'
	 jmp short Mlo4
   L_betu:
         cmp al,'z'
         ja Mlo3     ; magyar lehet
         cmp al,'a'
         jae Mlo4
         add al,32   ; make Locase
   Mlo4: mov es:[bx],al

   Mlo1: inc bx
         loop Mlo2

   Mlo_ok:
         pop ds
         pop es
         ret

   Mlo3: push ax
         mov  ax,seg upctable1
         mov  ds,ax
         pop  ax

         mov si,offset upctable1
         mov di,si
         add si,9

         push cx
         mov cx,9
    Mlo5:
         cmp al,ds:[si]
         jne Mlo6
         mov al,ds:[di]
         pop cx
         jmp Mlo4

    Mlo6: inc si
          inc di
          loop Mlo5

         pop cx
         jmp Mlo1

m_locase endp

end








