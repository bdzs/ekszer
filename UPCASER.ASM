; roman rutinok SZOTAGOL-hoz

.model tpascal
.code

public r_upcase,r_locase

extrn R_upctable1

r_upcase proc Far  cime : dword, hossza : word

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

         cmp al,'-'   ; roman kisbetus maganhangzok
         jz  mup3
         cmp al,'='
         jz  mup3
         cmp al,'['
         jz  mup3

         cmp al,'_'   ; roman nagybetus maganhangzok
         jz  mup4
         cmp al,'+'
         jz  mup4
         cmp al,'{'
         jz  mup4

	 cmp al,'A'     ; csak betu lehet !!!!
	 jae betu

         cmp al,'<'
         jz  egyeb_roman
         cmp al,':'
         jz  egyeb_roman
         cmp al,';'
         jz  egyeb_roman
         cmp al,"'"
         jz  egyeb_roman
         cmp al,'"'
         jz  egyeb_roman

   nembetu:
	 mov al,'*'
	 jmp short mup4
   betu:
         cmp al,'a'
         jb nembetu
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

   egyeb_roman:

         mov  al,'K' ; kamu massalhangzo
         jmp  short mup4


   mup3: push ax
         mov  ax,seg R_upctable1
         mov  ds,ax
         pop  ax

         mov si,offset R_upctable1
         mov di,si
         add di,3

         push cx
         mov cx,3
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

r_upcase endp

r_locase proc Far  cime : dword, hossza : word

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
         mov  ax,seg R_upctable1
         mov  ds,ax
         pop  ax

         mov si,offset R_upctable1
         mov di,si
         add si,3

         push cx
         mov cx,3
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

r_locase endp

end








