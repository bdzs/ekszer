CODE segment WORD PUBLIC
   assume cs:CODE

Mconst   Equ 4EH
FontSize Equ 16*(128-31) + 48H


Public     Page_End
Public     Ablak
Public     Sys_Write
Public     sc_up,sc_dn
Public     disp_kar
Public     inv_kar,inv_line
Public     disp_line
Public     fej_tab
Public     disp_page
Public     page_stat,line_stat
Public     line_ptr
Public     ures_e
Public     scroll_left,scroll_right
Public     sor_hossz
Public     felsor_ideoda
Public     felsor_ideodaW

Public     Image_seg
Public     Image_Offs
Public     Sortab_Offs
Public     Font_Offs

belep proc FAR


Page_End: Jmp     XPage_End
Ablak:    Jmp     XAblak
Sys_Write:Jmp     XSys_Write
Sc_Up:    Jmp     Xsc_up
Sc_Dn:    Jmp     Xsc_dn
Disp_Kar: Jmp     Xdisp_kar
Inv_Kar:  Jmp     Xinv_kar
Inv_Line: Jmp     Xinv_line
Disp_Line:Jmp     Xdisp_line
Fej_Tab:  Jmp     Xfej_tab
Disp_Page:Jmp     Xdisp_page
Page_Stat:Jmp     Xpage_stat
Line_Stat:Jmp     Xline_stat
Line_Ptr: Jmp     Xline_ptr
Ures_E:   Jmp     Xures_e

Scroll_Left:   Jmp     Xscroll_left
Scroll_Right:  Jmp     Xscroll_right
Sor_Hossz:     Jmp     Xsor_hossz
Felsor_IdeOda: Jmp     Xfelsor_ideoda
Felsor_IdeOdaW: Jmp     Xfelsor_ideodaW


  Image_seg    DW 0
  Image_Offs   DW 0
  Sortab_Offs  DW 0
  Font_Offs    DW 0

;------
Xfelsor_ideoda proc near  ; DB. szamu y. felsort (5 pix) pufferba rakja
                        ;  vagy pufferbol eloveszi es kirakja
; hivasa: felsor_ideoda (Db,  y,puff_ofs,puff_segm,sortaboff,irany)
;                        16, 14  12       10         8       6
;         irany : 0 = pufferba rak
;                 1 = pufferbol screen-re rak


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX


        push es
        mov ax,0b800h    ; cga screen
        mov es,ax
        push ds

        cld
        mov bx,[bp+14]   ; y
        shl bx,1         ; *2
        mov di,[bp+8]    ; sortaboffs
        mov di,[di+bx]   ; es:di = line beg.

        mov ds,[bp+10]   ; puff segm
        mov si,[bp+12]   ; puff ofs     ds:si = puffer beg.

        Mov Bx,[Bp + 16] ; Hany felsor

        Add Bx,Bx        ;   Bx = Bx * 5
        Add Bx,Bx        ;
        Add Bx,[Bp+16]   ;

                         ; honnan hova? igy pufferbol screenre rakashoz jo
        cmp byte ptr [bp+6],0
        jz  fio_oda     ; screenrol pufferba

     fiohuri:  push di   ; pufferbol screenre  es:di screen
               mov cx,40 ; kettesevel gyorsabb
               rep movsw
               pop di
               add di,2000h  ; next pix.line
               test di,4000h ; >= 4000h
               jz fio1i
               sub di,(4000h - 80)
      fio1i:   dec Bx
               jnz fiohuri
               jmp short fio_end

      fio_oda: push es
               push ds
               pop  es
               pop  ds
               xchg di,si    ; es:di <-> ds:si

     fiohuro:  push si
               mov cx,40 ; kettesevel gyorsabb
               rep movsw
               pop si
               add si,2000h  ; next pix.line
               test si,4000h ; >= 4000h
               jz fio1o
               sub si,(4000h - 80)
      fio1o:   dec Bx
               jnz fiohuro

    fio_end: pop ds
             jmp kilep
Xfelsor_ideoda endp
;-----------
Xfelsor_ideodaW proc near  ; DB. szamu y. felsort (5 pix) pufferba rakja
                           ;  vagy pufferbol eloveszi es kirakja
; hivasa: felsor_ideoda (Xpos, Wide, Db,  y,puff_ofs,puff_segm,sortaboff,irany)
;                        20,    18,  16, 14  12       10         8       6
;         irany : 0 = pufferba rak
;                 1 = pufferbol screen-re rak


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es
        mov ax,0b800h    ; cga screen
        mov es,ax
        push ds

        cld
        mov bx,[bp+14]   ; y
        shl bx,1         ; *2
        mov di,[bp+8]    ; sortaboffs
        mov di,[di+bx]   ; es:di = line beg.

        mov ds,[bp+10]   ; puff segm
        mov si,[bp+12]   ; puff ofs     ds:si = puffer beg.

        Mov Bx,[Bp + 16] ; Hany felsor

        Add Bx,Bx        ;   Bx = Bx * 5
        Add Bx,Bx        ;
        Add Bx,[Bp+16]   ;

                         ; honnan hova? igy pufferbol screenre rakashoz jo
        cmp byte ptr [bp+6],0
        jz  fio_odaW     ; screenrol pufferba

     fiohuriW:  push di   ; pufferbol screenre  es:di screen
                add di,[bp+20] ; xpos
                mov cx,[bp+18] ; szelesseg
                rep movsb
                pop di
                add di,2000h  ; next pix.line
                test di,4000h ; >= 4000h
                jz fio1iW
                sub di,(4000h - 80)
      fio1iW:   dec Bx
                jnz fiohuriW
               jmp short fio_endW

      fio_odaW: push es
                push ds
                pop  es
                pop  ds
               xchg di,si    ; es:di <-> ds:si

     fiohuroW:  push si
                add  si,[bp+20] ; xpos
                mov  cx,[bp+18] ; szelesseg
                rep movsb
                pop si
                add si,2000h  ; next pix.line
                test si,4000h ; >= 4000h
                jz fio1oW
                sub si,(4000h - 80)
      fio1oW:   dec Bx
                jnz fiohuroW

    fio_endW:   pop ds


		jmp kilep2


Xfelsor_ideodaW endp
;-----------

Xpage_end proc near       ; y. sor 5. pixel sorat CCh/FFh-val XOR-olja
                        ; elso meghivas lapveget kiteszi
                        ; masodik meghivas lapveget elveszi

 ; hivasa:  page_end  (0, y, 0, 0, sortaboff, mit)
 ;                     ^ ez nulla legyen !!!   ^ ha nem 0, akkor hard ___


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es
        mov ax,0b800h
        mov es,ax

        cmp byte ptr [bp+14],2 ; 2. nem lehet
        jz page_end_end
        call get_line_beg      ; sor 1. pixel soran all

        mov cx,4 ; negy sorral le
	mov ax,2000h	       ; egybeveteshez
	mov dx,(4000h - 80)    ;  novekmeny

pe_h1:     cmp  di,ax            ; nagyobb  2000h-nal?
           jc pe_1               ; kisebbb: hozza adni 2000h  -t
           sub di,dx             ; nagyobb: levonni 2000h - 80 - 2000
 pe_1:     add di,ax
           loop pe_h1

           cmp byte ptr [bp+6], 0  ; ha 0, akkor soft.....
           jz spe
           mov ax,0ffffh  ; kulonben hard ___
           jmp short pe_2
 spe:      mov ax,0cccch ; xor-olo minta
 pe_2:     mov cx,39     ; 78 byte
 pe_h2:    xor word ptr es:[di],ax
           inc di
           inc di
           loop pe_h2

page_end_end: jmp kilep
Xpage_end endp
;-----------
Xablak proc near        ; x,y-tol m+2 sor (10 pix) magas ablakot rajzol ki
                        ; s+2 szelesseggel
                        ; s,m minimum 1 legyen!
; hivasa: ablak(x,y,magasag,fontoff,sortaboff,szelesseg)


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es
        mov ax,0b800h
        mov es,ax
        Cld            ; Istvan !   Ne hagyd el a CLD -ket !!!

            call get_line_beg ; es:di bal felso sarokra all

felso_sor:        mov  ax,107
                  call get_sys_kar_mat
                  call kar_ki_over
                  inc  di
                  mov ax,114          ;  -
                  call get_sys_kar_mat
                  mov cx,[bp+6]       ; szelesseg
      fe_hur:     push cx
                  push si
                  call kar_ki_over
                  inc di
                  pop si
			pop cx
                  loop fe_hur
                  mov ax,108
                  call get_sys_kar_mat
                  call kar_ki_over    ; felso jobb szelso

 kozepso_sor:     inc byte ptr [bp+14]
                  inc byte ptr [bp+14]  ; next 10. pix line
                  call get_line_beg     ; es:di rajta all
                  mov ax,111            ; fuggoleges vonal
                  call get_sys_kar_mat
                  push si               ; ^
                  call kar_ki_over
                  inc di
                  mov cx,[bp+6] ; szelesseg
    kozep_hur:    push cx
                  call space_ki_over
                  inc di
                  pop cx
                  loop kozep_hur
                  pop si               ;  |
                  call kar_ki_over
    ;
         dec byte ptr [bp+12] ; hany kozepso sor kell?
         jnz  kozepso_sor     ; meg kell
    ;
         inc byte ptr [bp+14]
         inc byte ptr [bp+14]

         call get_line_beg ; es:di bal also sarokra all

also_sor:         mov  ax,110
                  call get_sys_kar_mat
                  call kar_ki_over
                  inc  di
                  mov ax,114           ;  -
                  call get_sys_kar_mat
                  mov cx,[bp+6]        ; szelesseg
      al_hur:     push cx
                  push si
                  call kar_ki_over
                  inc di
                  pop si
			pop cx
                  loop al_hur
                  mov ax,109
                  call get_sys_kar_mat
                  call kar_ki_over    ; also jobb szelso

  ablak_end:   jmp kilep

Xablak endp
;-----------
get_line_beg proc near       ;  in:  [bp+14] y koordinata
                             ;       [bp+16] x koordinata
                             ;  out: di   raallitva

	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,[bx+si]	; di = sor absolute kezdocime !!!!!!!!!
        add di,[bp+16]          ; x-szel korrigalva
        ret

get_line_beg endp

get_sys_kar_mat  proc near   ;  in:  ax-ban karakter num
                             ;  out:  ds:si  raallitva

        sub al,32
        shl ax,1                ; * 2
	push ax ;                 ^ ax
	shl ax,1		; * 4
	shl ax,1		; * 8
        pop bx                  ; |  bx
        add bx,ax               ; bx = karakter matrix offset kezdethez kepest
;

        mov si,[bp+10]          ; fontoff
        add bx,Mconst        ; space kezdocime fontkezdethez kepest !!!!!!!
        add si,bx               ; si = kivant karakter matrix kezdocime

        ret

get_sys_kar_mat endp

Xsor_hossz	proc near

; hivasa: sh = sor_hossz(0,y,0,fontoff,sortaboff,imageoff)
; megadja az IMAGE y. sorban talalhato kiirando karakterek szamat



        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

       mov di,[bp+14]   ; y
       call di160       ; y*160
       add di,[bp+6]    ; di = sor eleje  (attrib)
       add di,80+77     ; di = sor vege   (karakterek)

mov ax,78  ; ennyit lehet max visszamenni

sor_h_h:  mov cl,ds:[di]  ; van ott valami?  IMAGE  DS-en !!!!!!!!!!!!!
          or cl,cl        ; 0 = semmi
          jz nincs_semmi
          cmp cl,32       ; space sem erdekes
          jnz sor_h_vege

 ; itt a sor vege:      AX-ben a hossza


nincs_semmi: dec di       ; elozo kar.pos
             dec al       ; szamlalo csokk.
             jnz  sor_h_h ; nem : vissza lep eggyel
                          ; hossza = 0
sor_h_vege:

        pop ds
        pop bp
        db 0cah   ; ret far
        dw 12     ;
                  ;   ret 12   ; Istvan ! Ez nem 14 hanem 12 !

Xsor_hossz endp
;-----------
Xscroll_left	proc near        ; y1 ... y2 sorokban
				; x-re huzza x+1  pos-t,
				; 76.-ra 77.-et,
				; 77.be 0-t rak

; hivasa: scroll_left(x,y1,y2,mit,sortaboff,imageoff)
; ha mit = 0, akkor screen
;    mit <>0, akkor IMAGE



        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

                inc byte ptr [bp+12]    ; y2 = y2 + 1

bal_hur:
		call egy_sor_balra	; [bp+14].sort balra tolja
		mov ax,[bp+14]  	; y1
                inc ax                  ; y1 = y1 + 1
		mov [bp+14],ax
                cmp ax,[bp+12]          ; elerte?
                jnz bal_hur

        jmp kilep

Xscroll_left endp
;------------
egy_sor_balra proc near         ; [bp+14] = y koord
				; ax = x koord
                                ; x-re a kovetkezot stb. 76.ig
          cld    ; jobbra atpakolni!

          cmp byte ptr [bp+10],0 ; mi kell: screen vagy IMAGE?
          jnz  sli9              ; IMAGE kell!
          push ds

   balra_scr:

        mov ax,[bp+16]          ; x
        mov bx,[bp+14]          ; y
	mov di,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	shl bx,1		; y * 2
	mov di,Ds:[bx+di]	; di = ide sor absolute kezdocime
        add di,ax               ; di = ide pos.

        mov dx,0b800h ; cga segm
        mov es,dx
        mov ds,dx

            mov cx,5      ; ot pix.sor
 bal_5:     push cx
            push ax
            push di       ; pos. bal felso

            mov cx,77
            sub cx,ax   ; cx= ennyi kell atrakni

			mov si,di
			inc si			; innen
     egy_pix_sor_bal:   repz movsb              ; egy byte-ot atrak
                        xor al,al
                        stosb                   ;  77.-be 0-t
     next_pix_line_bal:
                        pop di

		mov cx,2000h		;  egybeveteshez
		mov dx,(4000h - 80)	;  novekmeny

           cmp  di,cx            ; nagyobb  2000h-nal?
           jc ba_1               ; kisebbb: hozza adni 2000h  -t
           sub di,dx             ; nagyobb: levonni 2000h - 80 - 2000
 ba_1:     add di,cx

		pop ax
                pop cx
                loop bal_5

        pop ds
        ret


; most jon az IMAGE -----------------------
sli9:   push ds
	pop es

       mov di,[bp+14]   ; y
       call di160       ; y*160
       add di,[bp+6]    ; di = sor eleje  (attrib)
       mov ax,[bp+16]   ; x
       add di,ax        ; di = sor x.pos

; 0.-ra rakunk ra valamit? Akkor meg kell jegyezni az sor attributumot
     or al,al      ;
     jnz bai9      ; nem

     mov cl,ds:[di]  ; 0.byte attrib
     and cl,0f0h     ; csak a felso 4. bit kell
     or ds:[di+1],cl ; bele ORolni a kovetkezobe


bai9:     mov cx,77
          sub cx,ax   ; cx= ennyi kell atrakni

     push cx
     push di
			mov si,di
			inc si			; innen
     attr_bal:          repz movsb              ; egy byte-ot atrak
                        xor al,al
                        stosb                   ;  77.-be 0-t

                        pop di
                        add di,80   ;
                        pop cx
                        mov si,di
			inc si			; innen
     kar_bal:           repz movsb              ; egy byte-ot atrak
                        xor al,al
                        stosb                   ;  77.-be 0-t


           ret

egy_sor_balra endp

;-----------
Xscroll_right  proc near          ; y1 .... y2 sorokban
				; 77-re huzza 76-ot,
				; x+1-re x-et
				; x.-be 0-t rak

; hivasa: scroll_right(  x, y1, y2, mit,sortaboff,imageoff)
; ha mit = 0, akkor screen
;    mit <>0, akkor IMAGE


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es
                inc byte ptr [bp+12]    ; y2 = y2 + 1

jobb_hur:
		call egy_sor_jobbra     ;  [bp+14].sort jobbra tolja
		mov ax,[bp+14]		;  y1
                inc ax                  ;  y1 = y1 + 1
		mov [bp+14],ax
                cmp ax,[bp+12]          ;  elerte?
                jnz jobb_hur

        jmp kilep

Xscroll_right endp
;-----------
egy_sor_jobbra proc near        ; [bp+14] = y koord
				; [bp+16] = x koord
                                ; 77-re az elozot   stb. x.-ig
				; x-re nullat
; visszafele fogunk pakolni !
			std	; !!!!!!!!!!!!!!!!!!!!!!!!!!!!1

       cmp byte ptr [bp+10],0   ; mi kell: screen / Image?
       jnz sri9                  ; az IMAGE kell!
       push ds

   jobbra_scr:

        mov ax,[bp+16]          ; x
        mov bx,[bp+14]          ; y
	mov di,[bp+8]		; sor_kezd_tabla offsetje
	shl bx,1		; y * 2

	mov di,Ds:[bx+di]	; di = ide sor absolute kezdocime
        add di,77               ; di = ide pos.,

        mov dx,0b800h ; cga segm
        mov es,dx
        mov ds,dx

                mov cx,5      ; ot pix.sor
 jobb_5:        push cx
		push ax
                push di     ; pos. jobb felso

            mov cx,77
            sub cx,ax   ; cx= ennyi kell atrakni

			mov si,di
			dec si			; innen

     egy_pix_sor_jobb:   repz movsb             ; egy byte-ot atrak
                         xor al,al
			 stosb			; x.-be 0-t
	next_pix_line_jobb:
                        pop di

		mov cx,2000h		;  egybeveteshez
		mov dx,(4000h - 80)	;  novekmeny

           cmp  di,cx            ; nagyobb  2000h-nal?
           jc jo_1               ; kisebbb: hozza adni 2000h  -t
           sub di,dx             ; nagyobb: levonni 2000h - 80 - 2000
 jo_1:     add di,cx

		pop ax
                pop cx
                loop jobb_5

              cld       ; visszaallitja felfelehez
              pop ds
              ret

; most jon az IMAGE -
sri9:   push ds
	pop es

       mov di,[bp+14]   ; y
       call di160       ; y*160
       add di,[bp+6]    ; di = sor eleje  (attrib)
       mov ax,[bp+16]   ; x
       add di,77        ; di = sor vege (ameddig lehet)



          mov cx,77
          sub cx,ax   ; cx= ennyi kell atrakni

     push cx
     push di
			mov si,di
			dec si			; innen
     attr_jobb:         repz movsb              ; egy byte-ot atrak

                    mov al,0f0h     ; felso 4 bit marad
                    and es:[di],al  ; tobbit nullazni
                                    ;  x.-be 0-t

			pop di
			add di,80	;
			pop cx
                        mov si,di
			dec si			; innen
     kar_jobb:          repz movsb              ; egy byte-ot atrak
                        xor al,al
                        stosb                   ;  x.-be 0-t

                        cld       ; visszaallitja felfelehez

           ret

egy_sor_jobbra endp

;==============================================================
Xline_ptr   proc near   ; sormutatot 79. oszlopban kirakja vagy
                        ; eltunteti

; hivasa: line_ptr (mit,y,0,fontoff,sortaboff,imageoff)
;                   mit = 0, akkor elveszi
;                   mit = 1, akkor kirakja


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

        mov ax,0b800h ; cga segm
        mov es,ax

	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	add di,79		; di = bal felso pont offsetje
;
	cmp byte ptr [bp+16],0	; kirak vagy elvesz?
        jnz lptr_kirak          ; elvesz = space-val felulir

        call space_ki_over      ; csak a screen pozicio kell
        jmp kilep

lptr_kirak:
        mov si,[bp+10]               ; fontoff
        add si,Mconst + 10*(105-32)  ; mutato matrix kezdet

        call kar_ki_over        ; egy karaktert kiir, overwrite
        jmp kilep

Xline_ptr endp

;===============================================================

Xline_stat proc near  ; y.dik sor 78.oszlopaba az image-nek megfelelo
                      ; status-jelzot kirakja
                      ; status jelzok matrixa a system fontban:
                        ; 97 = hard CR
                        ; 98 = soft CR
			; 99 = felso index
			; 100 = also index
                        ; magassaguk 4 pix. sor igy a kivant sor
			; 3. pixel soraban kell elkezdeni kirakni oket,
			; hogy kozepre keruljenek



        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

        mov ax,0b800h ; cga segm
        mov es,ax

	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata

        cmp bl,02  ; 2. sorban torolni
        jz  l_s_2
        cmp bl,39  ; 39. sorban torolni
        jz  l_s_39

	shl bx,1		; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	add di,78		; DI = bal felso pont offsetje
;
        mov si,[bp+14]     ; y. koord
        call get_status    ; get status:     SI = offs matrix
        call disp_status   ; display status

l_s_end:   jmp kilep

l_s_2:  call torol_st2
        jmp kilep

l_s_39: call torol_st39
        jmp kilep

Xline_stat endp

;================================================================
get_status proc near            ; si-ban y.koord-t kapja
				; si-t a megfelelo jelzo matrixara
				; allitja
        cmp byte ptr [bp+16],0  ; ha 0, akkor kirakni
        jnz gstsp               ; csak torolni

        mov bx,[bp+6]  ; image offset

        shl si,1       ; *2
        shl si,1       ; *4
	shl si,1	; *8
	shl si,1	; *16
        push si
        shl si,1       ; *32
	shl si,1	; *64
        pop ax
        add si,ax      ; *80
        shl si,1       ; *160

        mov al,byte ptr [bx+si]     ; a sor attributuma

        ;;; MOV AH,BYTE PTR [BX+SI+77]  ; a 77. attrib (protected)

        mov si,[bp+10] ; fontoff
        add si,Mconst + (97-32) * 10 ; hard cr kezdete

        ;;; TEST  AH,80h            ; 3. bit protected sor
        ;;; jnz   protected

        test al,10h            ; 4. bit fosor/index sor
        jz  index_sor

  fosor: test al,80h           ; 7. bit soft/hard cr
         jnz  get_st_kesz      ; hard cr: SI beallitva
         add si,10             ; soft cr a kovetkezo

     get_st_kesz:   ret

protected:  add si,27*10       ; | karakter
            jmp short get_st_kesz

 index_sor: add si,20          ; masodik ketto lehet
            jmp fosor          ; ugyanazt kell csinalni

    gstsp:    mov si,[bp+10]   ; fontoff
              add si,Mconst    ; space kezdete
              ret


get_status endp
;================================================================

disp_status proc near           ; ds:si matrixra allitva
				; es:di screenre mutat
				; 3 pix sort torolni
				; majd 4-et kirajzolni (over)

	mov ax,2000h		;  egybeveteshez
        mov dx,(4000h - 80)                    ; novekmeny1

        mov cx,3                 ; 3 sorral lemenni
dsh1:
           cmp  di,ax            ; nagyobb  2000h-nal?
           jc ds_1               ; kisebbb: hozza adni 2000h  -t
           sub di,dx             ; nagyobb: levonni 2000h - 80
                                 ;                  - 2000h -t
 ds_1:     add di,ax

 dsh1end: loop dsh1

        mov cx,4                 ; 4 -et kirajzolni
dsh2:
           movsb                 ; si,di novekedett
           dec di
           cmp di,ax             ; nagyobb 2000h-nal?
           jc ds_2               ;
           sub di,dx             ;

 ds_2:     add di,ax

 dsh2end: loop dsh2

           ret

disp_status endp

;-----------
 torol_st2 proc near   ; 2. sorban status jelzot torol

 mov byte ptr es:[2230h+78], 00
 mov byte ptr es:[0280h+78], 00
             ret

 torol_st2  endp

;-------------
 torol_st39 proc near   ; 39. sorban status jelzot torol

 mov byte ptr es:[1ef0h+78], 00
 mov byte ptr es:[3ef0h+78], 00
             ret

 torol_st39  endp
;------------

Xpage_stat proc near    ; image alapjan y.sorig (azt is beleertve)
                        ; a statusz jelzoket kiirja
                        ; 39.-ket torli


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

        mov ax,0b800h ; cga segm
        mov es,ax

ps1: mov di,[bp+8] ; sorkezd tabla offs
     add di,6      ; 3. sor kezdo cime
     mov si,3      ; 3. sor mint y koord.
psh:
        push di
        push si
        mov di,Ds:[di]      ; sor kezdo cime
        add di,78           ; DI = bal felso pont offsetje
;
        call get_status    ; get status:     SI = offs matrix
        call disp_status   ; display status

        pop si
        inc si   ; next line

        pop di
        inc di
        inc di   ; cime

        cmp si,39          ;  azt csak torolni!
        jz  ps39

        cmp [bp+14],si ; y.-ig kell menni, azt is!
        jnc psh        ; meg nem nagyobb

        jmp kilep

 ps39:  call torol_st39
        jmp kilep

 Xpage_stat endp

;================================================================

Xdisp_page  proc near   ; kepernyo torlese a 3.sortol
                        ; a leheto leggyorsabb modon
                        ; majd a teljes image megjelenitese


        CLD             ; !!!!!!!!!!!!!!! Istvan !  L.A.-D.A.
        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

        mov ax,0b800h ; cga segm
        mov es,ax

        xor ax,ax

        mov di,8752           ; 3. sor 0. pix sor
        mov cx,04000h - 8752
        shr cx,1              ; ket byte-onkent
        rep stosw

        mov di,8752-02000h+80 ; 3. sor 1. pix sor
        mov cx,02000h - (8752 - 02000h + 80)
        shr cx,1
        rep stosw
	;     ---------     kepernyo torolve
	;                   most minden olyan sort, amiben van valami
	;                   OR-olva megjeleniteni

        mov byte ptr [bp+16],0       ; x -koordinata
        mov byte ptr [bp+14],2       ; y -koordinata

        mov si,[bp+6]       ; image offset
        add si,2*160        ; 2. sor

        test byte ptr [si],20h ; 5. bit = van benne valami?
        jz  page_t_sorok          ; nincs
        mov ax,0100h              ; OR-olva 2. sor
            push si
        call line_5_pix        ; kiirni
            pop si

page_t_sorok:  inc byte ptr [bp+14]      ; next line (teljes sorok: 3..38)
               add si,160                ; image cime
               test byte ptr [si],20h ; van benne valami?
               jz page_next_line         ; nincs
                  push si
                    mov ah,1             ; OR
                    call line_out        ; kiir
                  pop si

 page_next_line:  cmp byte ptr [bp+14],38 ; 38. volt?
                  jnz page_t_sorok        ; meg nem

               add si,160                 ; 39. sor
               test byte ptr [si],20h  ; van benne valami?
               jz  page_vege              ; nincs
               mov ax,0101h               ; OR-olva 39. sor
               call line_5_pix            ; kiirni

 page_vege:

               jmp kilep

Xdisp_page endp

; =============================================================
; Sys_Write:    kivant fonttal x,y koordinatara 1 karaktert kiir
;             32 - 127 asc kodu karaktereket kezel
;             felulirja az x,y pozicion talalhato barmit
; hivasa:     Sys_Write (x,y,kar,fontoff,sortaboff,fontszam)

XSys_Write proc near


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add di,bx		; di = bal felso pont offsetje
        mov ax,0b800h           ; cga  screen segmens
        mov es,ax               ; ES:DI beallitva kirakohelyre
;
	mov ax,[bp+12]	; karakter num
        or al,al        ; 0 is space lesz
        jz sys_space
        sub al,32       ; szokoztol megyunk
        jz  sys_space   ; space-ra kulon rutin van

        shl ax,1                ; * 2
	push ax ;                 ^ ax
	shl ax,1		; * 4
	shl ax,1		; * 8
        pop bx                  ; |  bx
        add bx,ax               ; bx = karakter matrix offset kezdethez kepest
;

        mov cx,[bp+6]           ;  font szam
        inc cx                  ; + 1

        mov si,[bp+10]          ; fontoff
        mov dx,FontSize         ; kulonbseg

pkf_ker:  add si,dx
          loop pkf_ker     ; si = font offset  akt karakternek

          sub si,dx        ; igy a jo
;
        add bx,Mconst       ; space kezdocime fontkezdethez kepest !!!!!!!
        add si,bx               ; si = kivant karakter matrix kezdocime
;
   call kar_ki_over             ; egy karaktert kiir, overwrite

        jmp kilep

   sys_space:

        call space_ki_over      ; csak a screen pozicio kell

        jmp kilep

  XSys_Write endp
; ======================================================================
; felfele scrollozo rutin: 5 pixelsoros;
; hivasa  sc_up (y-ig,y-tol,darab,0,sortaboff,imageoff)
;                16   14     12   10    8         6
;              y-ig. sorra rakja az y-ig + darab-ot  ...
;              y-tol. sor az y-tol-darab. sorra kerul
;              y-tol-darab +1 tol y-tol. ig torli a sorokat
;              az image-t is scrollozza!

Xsc_up proc near




        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

              cmp byte ptr [bp+12],0    ; 0-bol egyet csinalni!!!
              jnz sc_up1
              inc byte ptr [bp+12]

 sc_up1:      mov ax, [bp+16]
              add ax, [bp+12]
              mov [bp+10],ax      ; [bp+10]. sort masolni [bp+14-re]

              mov ax, [bp+14]     ; utolso sor AL-ben
              mov bx, [bp+16]     ; elso sor
              mov [bp+14],bx      ;
 sc_up_hur:   push ax
              call egy_sor_fel    ; [bp+14]. ik sorra rarakja [bp+10]-et
              inc byte ptr [bp+14]      ; next line  : erre
              inc byte ptr [bp+10]      ; next line  : ezt
              pop ax
              cmp  byte ptr [bp+10],al  ; atraktuk az utolsot is?
              jbe  sc_up_hur

              mov cx,word ptr [bp+12]
                 ;                               al ; %%%%
   sc_up_cls:    push cx
                 push ax
                 cmp al,2
                 jnz sc_up_cl ; helyette a 3.
                 mov al,3
    sc_up_cl:    call clear_line_ax
                 pop ax
                 pop cx
                 dec ax ; &&& inc ax
                 loop sc_up_cls

  scroll_up_end: jmp kilep

Xsc_up endp
; ======================================================================
; lefele scrollozo rutin: 5  pixelsoros;
; hivasa  sc_dn (y-tol,y-ig,darab,0,sortaboff,imageoff)
;                16     14    12  10     8       6

Xsc_dn proc near


        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

        push es

              cmp byte ptr [bp+12],0    ; 0-bol egyet csinalni!!!
              jnz sc_dn1
              inc byte ptr [bp+12]
 sc_dn1:      mov ax, [bp+16]
              sub ax, [bp+12]
              mov [bp+10],ax      ; [bp+10]. sort masolni [bp+14-re]

                mov ax,[bp+14] ; y-ig
                mov bx,[bp+16] ; y-tol

              mov [bp+14], bx ; erre rakni eloszor
 sc_down_hur: push ax
              call egy_sor_le           ; [bp+14]. ik sorra rakja [bp+10]-et
              dec  byte ptr [bp+14]     ; elertuk y.-at?
              dec  byte ptr [bp+10]     ; ha ez < al, akkor meg vege
              pop ax
              cmp  byte ptr [bp+10],al
              jae  sc_down_hur

              mov cx,word ptr [bp+12]
  scd_hur:    push ax
              push cx
              cmp al,2 ; helyette 3.
              jnz scd_cls_m
              mov al,3
  scd_cls_m:  call clear_line_ax
              pop cx
              pop ax
              inc ax
              loop scd_hur

  scroll_down_end: jmp kilep

Xsc_dn endp

;---------
clear_line_ax proc near   ; ax.-dik 5 pix. sort torli
        cld
	mov di,[bp+8]		; sor_kezd_tabla offssetje
	mov bx,ax		; y koordinata
	shl bx,1		; * 2
	mov di,ds:[bx+di]	; di = sor absolute kezdocime

        mov ax,0b800h           ; screen segm
        mov es,ax

        mov ax,0000    ; ezzel feltolteni
        mov cx,5       ;      5 pixel sor
        mov bx,2000h   ;        novekmeny 1
        mov dx,80      ;        novekmeny 2

clrax_hur:       push cx
                 push di
                 mov cx,40 ;     40 word egy sor
                 rep stosw ;     0-kat oda !

                 pop di    ;     next pix. line
                 sub di,bx ; nagyobb 2000h-nal?
                 jc clr1   ; nem ..
                 add di,dx ; akkor + 80
                 jmp short clr2
         clr1:   add di,bx ; 4000h novelni
                 add di,bx

         clr2:  pop cx
                loop clrax_hur

                 ret

clear_line_ax endp
;=======================================================================
        egy_sor_le proc near    ; [bp+14]-ik sorra rakja [bp+10]-et
        cld
        cmp byte ptr [bp+10],2  ; tabulatort nem rakjuk a 2.-bol!
        jz  sdi9                ; de az IMAGE-t at kell rakni!
	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,[bx+si] ; di = ide sor
        mov bx,[bp+10]
        shl bx,1
        mov si,[bx+si] ; si = innen

        push ds                 ; DS,ES screen!!!
        mov ax,0b800h           ; screen segm
        mov es,ax
        mov ds,ax

        mov al,5       ;      5 pixel sor
        mov bx,2000h   ;        novekmeny 1
        mov dx,80      ;        novekmeny 2

shd_hur:         push di
		 push si
                 mov cx,40 ;     40 word egy sor
                 rep movsw     ;     atpakolni

                 pop si       ;     next pix. line
                 sub si,bx    ; ha carry, akkor kisebb volt 2000h-nal!
                 jc shd_1     ; kisebb volt ..
                 add si,dx    ; nem volt kisebb
                 jmp short shd_2
         shd_1:  add si,bx
                 add si,bx ; vissza es meg 2000
         shd_2:  pop di    ;     next pix. line
                 sub di,bx ; nagyobb 2000h-nal?
                 jc shd_3  ; nem ..
                 add di,dx ; akkor + 80
                 jmp short shd_4
         shd_3:  add di,bx ; 4000h novelni
                 add di,bx


         shd_4:  dec al
		 jnz shd_hur

;   most jon az IMAGE ------
        pop ds
sdi9:   push ds
        pop es

   mov di,[bp+14]  ; erre pakol
   call di160      ; cime
   add di,[bp+6]   ; image offs

   mov si,[bp+10]  ; ezt pakol
   call si160      ; cime
   add si,[bp+6]   ; image offs

   mov cx,80
   rep movsw       ; atpakol


 ;
            ret

egy_sor_le endp

;========

egy_sor_fel proc near    ; [bp+14]-ik sorra rarakja [bp+10]-et
        cld
        cmp byte ptr [bp+14],2  ; tabulatorra nem rakjuk!
        jz sui9                 ; de az IMAGE-t atrakni!
	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,[bx+si]	; di = ide
        mov bx,[bp+10]
        shl bx,1
        mov si,[bx+si] ; si = innen

        push ds                 ; DS,ES screen!!!

        mov ax,0b800h            ; screen segm
        mov es,ax
        mov ds,ax

        mov al,5       ;      5 pixel sor
        mov bx,2000h   ;        novekmeny 1
        mov dx,80      ;        novekmeny 2

shu_hur:         push di
		 push si
                 mov cx,40 ;     40 word egy sor
                 rep movsw     ;     atpakolni

                 pop si       ;     next pix. line
                 sub si,bx    ; ha carry, akkor kisebb volt 2000h-nal!
                 jc shu_1     ; kisebb volt ..
                 add si,dx    ; nem volt kisebb
                 jmp short shu_2
         shu_1:  add si,bx
                 add si,bx ; vissza es meg 2000
         shu_2:  pop di    ;     next pix. line
                 sub di,bx ; nagyobb 2000h-nal?
                 jc shu_3  ; nem ..
                 add di,dx ; akkor + 80
                 jmp short shu_4
         shu_3:  add di,bx ; 4000h novelni
                 add di,bx


         shu_4:  dec al
		 jnz shu_hur

;  most jon az IMAGE ------
        pop  ds
sui9:   push ds
	pop es

   mov di,[bp+14]  ; erre
   call di160      ; cime
   add di,[bp+6]   ; image offs

   mov si,[bp+10]  ; ezt
   call si160      ; cime
   add si,[bp+6]   ; image offs

   mov cx,80
   rep movsw       ; atpakol

            ret

egy_sor_fel endp

;-
; egy karakter megjelenites az image alapjan
; hivasa: disp_kar (x,y,0,fontoff,sortaboff,imageoff)
;         kezeli az atfedeseket es fontokat is !!!!

Xdisp_kar proc near


         push bp
         mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

         push es

         mov ax,0b800h ; cga screen segm
         mov es,ax

         call kornyezet ; [bp+12] -ben a felette es alatta levo sorok allapota
                        ;

  xor ax,ax                     ; al = 0, ah =0 aktualis image sor , overwrite
  call si_di_out

  cmp byte ptr [bp+12],0        ; felette levo sorban van valami?
  jz  dk_alatta

dk_felette:
  mov ax,01ffh ; al = -1, ah =1 ; felette levo sor , OR
  call si_di_out

dk_alatta:
  cmp byte ptr [bp+13],0        ; alatta levo sorban van valami?
  jz  dk_vege

  mov ax,0101h ; al = +1, ah =1 ; alatta levo sor , OR
  call si_di_out

 dk_vege: jmp kilep

Xdisp_kar endp
;
;=============

; fejlec es tabulator megjelenito rutin
; fejlecet   az image 0.sorabol veszi
; tabulatort az image 1.sorabol veszi
; hivasa:  fej_tab (0,0,0,fontoff,sortaboff,imageoff) ... fejlecet frissit
;          fej_tab (1,0,0,fontoff,sortaboff,imageoff) ... tabulatort frissit

Xfej_tab proc near


         push bp
         mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

         push es

         CLD        ; !!!!!!!!!!!!!!!!!!!!!! Istvan ! L.A.-D.A.

         mov ax,0b800h ; cga screen segm
         mov es,ax

         mov si,[bp+10] ; fontoff
         xor ah,ah     ; 0 = fejlec
         xor di,di     ; default: fejlec
         mov bx,[bp+6] ; 0. image sor (image offset)
         cmp byte ptr [bp+16],0 ; fejlec kell?
         jz  ft1

         inc ah              ; 1= tabulator
         mov di,400          ; tabulator sor screen-en
         add bx,160          ; 1. image sor
ft1:
        mov cx,80            ; 0..79 x-pos

ft_kar:          push si ; font off
                 push bx ; image sor offset
                 push cx ; karakter szamlalo

        push ax                ; ah = fel/tab  jelzo

        mov al, byte ptr [bx+80]  ; karakter

        sub al,32    ; nem lehet benne kisebb   !!!!!!!!!!!!
        xor ah,ah              ; al = kar - 32, ah = 0

        shl ax,1                ; * 2
	push ax ;                 ^ ax
	shl ax,1		; * 4
	shl ax,1		; * 8
        pop bx                  ; |  bx
        add bx,ax               ; bx = 10 * kar num
;
        add bx,Mconst          ; space kezdocime fontkezdethez kepest !!!!!!!

        add si,bx               ; si = kivant karakter matrix kezdocime
;
        pop ax                  ; | ah fej/tab jelzo
        or ah,ah                ; ha nem 0, akkor OR-olni
        jnz tab1

        call kar_ki_over           ; fejlecet kirak
        jmp short fejtab_kar_end ;----------------------

tab1:   add si,5                 ; also ot sor
        call tab_out             ; tabulatort also 5 pixellel kirajzolni

fejtab_kar_end:         pop cx
                        pop bx
			pop si
                        inc bx          ; next kar
                        inc di          ; next screen pos

		 loop ft_kar	; ha van meg ...

                      jmp kilep

 Xfej_tab endp

;
; sormegjelenito rutin
; megadott x,y poziciotol x..79 kozott minden karaktert kiir
;                                      az image alapjan
; atfedeseket, fontokat stb figyelembe vesz
; hasznalhato a 2. es 39 sorok frissitesere is
; hivasa:  disp_line (x,y,0,fontoff,sortaboff,imageoff)
;
Xdisp_line proc near


         push bp
         mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

         push es

         mov ax,0b800h ; cga screen segm
         mov es,ax

         call kornyezet ; [bp+12] -ben a felette es alatta levo sorok allapota
                        ;

      xor ax,ax                  ; al = 0, ah =0 aktualis image sor , overwrite

      cmp byte ptr [bp+14],2     ; 2.  sor: kulon teszta
      jz  kivetel_2
      cmp byte ptr [bp+14],39    ; 39. sor: kulon teszta
      jz  kivetel_39

line_overwrite:
      call line_out

      cmp byte ptr [bp+12],0        ; felette levo sorban van valami?
      jz  line_alatta

line_felette:

      cmp byte ptr [bp+14],3        ; 2.sor a felette levo?
      jnz l_felette                 ; nem, OR-olva kiirhato

      mov ax,0100h                  ; ah = 1, or; al = 0, 2. sor
      call line_5_pix               ; kulonleges banasmod
      jmp short line_alatta

l_felette:
      mov ax,01ffh ; al = -1, ah =1 ; felette levo sor , OR
      call line_out

line_alatta:
     cmp byte ptr [bp+13],0        ; alatta levo sorban van valami?
     jz  line_vege


     cmp byte ptr [bp+14],38       ; 38.sor alattit kell kiirni?
     jnz l_alatta                  ; nem

     mov ax,0101h                  ; ah = 1, or; al = 1, 39. sor
     call line_5_pix
     jmp short line_vege

l_alatta:

     mov ax,0101h            ; al = +1, ah =1 ; alatta levo sor , OR
     call line_out

 line_vege: jmp kilep


 kivetel_2:
                             ; masodik sor a "kozepso"
       mov ax, 0000h         ; al = 0, 2. sor; ah = 0, over
       call line_5_pix
       jmp short line_alatta

 kivetel_39:
                               ; 39. sor a "kozepso"
       mov ax, 0001h           ; al = 1, 39.sor; ah = 0, over
       call line_5_pix
       cmp byte ptr [bp+12],0 ; van felette valami?
       jz line_vege           ; nincs
       mov ax,01ffh ; ah = 1, or; al = -1, elozo sor
       call line_out
       jmp line_vege

Xdisp_line endp

;----
kornyezet proc near     ; a kerdeses sor feletti es alatti sorok allapota
			; [bp+12] = felette levo sor (0 = ures)
			; [bp+13] = alatta  levo sor (0 = ures)

	mov di,[bp+14] ; kerdeses sor Y koordinataja
        mov bx,[bp+6]  ; image offset

        dec  di            ; elozo sor

        call di160         ; di = di * 160

        mov cl,byte ptr ds:[bx+di]     ; elozo sor attributuma
        mov ch,byte ptr ds:[bx+di+320] ; kovetkezo sor attributuma

                              ; 5. bit = van benne valami?
        and cx, 2020h         ;

        mov [bp+12],cx        ; kornyezetet elrakni

          ret
kornyezet endp

;=======================================================================
;
si_di_out  proc near    ; egy karakter kiirasat elokesziti:
			; atadott parameterek alapjan
			; SI-t karakter matrixra
			; DI-t kepernyo poziciora allitja
			; elozoleg y-koordinatat AL-lel korrigalja
                        ; space kezelesre ugyel
                        ; ha AH = 0, karakter poziciot felulirja
                        ; kulonben karaktert OR-olva kirajzoltatja
                        ; 2. es 39. sorokban levo fel betuket is kezeli

        push ax                 ; ^ ax , ah = over/or jelzo

	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+14]		; y koordinata
        add bl,al               ; al-lel korrigalni

        push bx                 ;  ^ bx, bl = y koord

        shl bx,1                ; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add di,bx		; di = bal felso pont offsetje
;

        mov bx,[bp+6]           ; image offset CS:
        pop si                  ; | SI = y koord
        push si                 ; ^    = y koord

; 160-nal megszorozni

        call si160
        add si, [bp+16]     ; + x koordinata

        mov al, byte ptr [bx+si+80]  ; karakter

; fel kell keszulni a 0-ra es a space-ra
        or al,al     ; 0 ????
        jz s_d2      ; szokoz lesz
        sub al,32    ;
        or al,al     ; space ???
        jnz s_d2     ; nem, hol a matrixa

; space kezelest ide !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; ha valodi space volt (asc 32), akkor .-ot kell kiirni
; system font, 103-as karakter
        mov si,[bp+10]    ; fontoff
        add si,Mconst + 10 * (103-32) ; itt kezdodik
        jmp short sd_sp

s_d2:   mov cl,byte ptr [bx+si]     ; attributum = font szam
        and cl,0fh                     ; csak az also 4 bit kell
        inc cl                         ; + 1
        xor ch,ch                      ; cx = fontszam

        mov si,[bp+10]         ; fontoff
        mov dx,FontSize        ; kulonbseg

f_ker:  add si,dx
        loop f_ker         ; si = font offset  akt karakternek

        sub si,dx

        xor ah,ah ;   al = kar -32

        shl ax,1                ; * 2
	push ax ;                 ^ ax
	shl ax,1		; * 4
	shl ax,1		; * 8
        pop bx                  ; |  bx
        add bx,ax               ; bx = 10 * kar num
;
        add bx,Mconst          ; space kezdocime fontkezdethez kepest !!!!!!!

        add si,bx               ; si = kivant karakter matrix kezdocime
;
sd_sp:  pop bx                  ; | bl = akt y-koordinata
        pop ax                  ; | ah over/or jelzo

        or ah,ah                ; ha nem 0, akkor OR-olni
        jnz s_d_or

        jmp kar_ki_over         ; kirajzolni, onnan megy vissza


; OR  ... de 2. es  39. sorban levot egyedileg kezelni


s_d_or: cmp bl,2                ; 2. sor?
        jnz sdo1                ; nem
        mov al,0                ; 2. sor jelzo
        mov di,8752     ; 3. sor kezdet
        add di,[bp+16]  ; x. koord
        jmp kar5_ki_or

sdo1:   cmp bl,39               ; 39. sor?
        jnz sdo2                ; nem teljes karaktert kell kirajzolni
        mov al,1                ; 39. sor jelzo
        jmp kar5_ki_or

sdo2: jmp kar_ki_or           ; kirajzolni ..... onnan vissza megy

si_di_out endp

;
line_out  proc near    ; egy sor kiirasat elvegzi
			; elozoleg y-koordinatat AL-lel korrigalja
                       ; space kezelesre ugyel
                       ; ha AH = 0, a sort felulirja
                       ; kulonben minden karaktert OR-olva kirajzoltat

        push ax                 ; ^ ah = over/or jelzo

	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+14]		; y koordinata
        add bl,al               ; al-lel korrigalni
        push bx                 ; ^ BX (y koord)

        shl bx,1                ; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add di,bx		; di = bal felso pont offsetje
;

        mov bx,[bp+6]           ; image offset DS:
        pop si                  ; | SI = y koord
; 160-nal megszorozni

        call si160
        add si, [bp+16]     ; + x koordinata

        pop ax         ; | ah = or/over jelzo
;
        mov cx,78
        sub cx,[bp+16] ; ennyi karaktert kell kiirni

line_out_kar:    push si ; x image offsetten belul
                 push bx ; image offset
                 push cx ; karakter szamlalo

        push ax         ; ah = or/over jelzo

        mov al, byte ptr ds:[bx+si+80]  ; karakter

; fel kell keszulni a 0-ra es a space-ra

        or al,al     ; 0 ????
        jz l_o2      ; szokoz lesz
        sub al,32    ;
        or al,al     ; space ???
        jnz l_o2     ; nem, hol a matrixa

; ha asc space, akkor system font 103-as karaktere kell

  mov si,[bp+10]  ; fontoff
  add si,Mconst + 10 * (103-32)    ; itt kezdodik
  jmp short lo_sp

l_o2:   mov cl,byte ptr ds:[bx+si]     ; attributum = font szam
        and cl,0fh                     ; csak az also 4 bit kell
        inc cl                         ; + 1
        xor ch,ch                      ; cx = fontszam

        mov si,[bp+10]         ; fontoff
        mov dx,FontSize        ; kulonbseg

lo_f_ker:  add si,dx
           loop lo_f_ker         ; si = font offset  akt karakternek

        sub si,dx

        xor ah,ah              ; al = kar - 32, ah = 0

        shl ax,1                ; * 2
	push ax ;                 ^ ax
	shl ax,1		; * 4
	shl ax,1		; * 8
        pop bx                  ; |  bx
        add bx,ax               ; bx = 10 * kar num
;
        add bx,Mconst           ; space kezdocime fontkezdethez kepest !!!!!!!

        add si,bx               ; si = kivant karakter matrix kezdocime
;
lo_sp:  pop ax                  ; | ah over/or jelzo
        or ah,ah                ; ha nem 0, akkor OR-olni
        jnz l_o_or

        call kar_ki_over           ; kirajzolni
        jmp short line_out_kar_end ;

l_o_or: call kar_ki_or             ; kirajzolni

line_out_kar_end:       pop cx
                        pop bx          ; image offset
                        pop si          ; pozicio imagen belul

                        inc si          ; next kar
                        inc di          ; next screen pos

		 loop line_out_kar	; ha van meg ...

			ret
line_out endp

;
line_5_pix  proc near    ; 2. es 39.sor kiirasat elvegzi
			 ; csak az also/felso 5 pixel sort jeleniti meg
                         ; ah = 0, akkor overwrite, kulonben OR
                         ; al = 0, akkor 2. sor, kulonben 39. sor
                 ; space kezelesre ugyel

        mov di,8752             ; 3.sor kezdo cime (also 5.pix)
        cmp al,0                ; vagy a 39. kell?
        jz l51
        mov di,15952            ; 39. sor kezdo cime

l51:    mov bx,[bp+16]          ; x koordinata
	add di,bx		; di = bal felso pont offsetje
;

        mov si,[bp+6]           ; image offset
        add si,2*160            ; masodik sor attr. kezdet
        cmp al,0                ; a 39. kell?
        jz l52
        add si,37*160           ; akkor meg 37-tel lejjebb

 l52:   ;       ???????   add si,[bp+16]          ; + x koordinata

        mov cx,78
        sub cx,[bp+16] ; ennyi karaktert kell kiirni

line_5_kar:      push si ; sor kezd   image offsetten belul
                 push bx ; x attr
                 push cx ; karakter szamlalo

                 push ax ; ah = or/over jelzo , al = 2./39. jelzo

        mov al, byte ptr [bx+si+80]  ; karakter

; fel kell keszulni a 0-ra es a space-ra !!!!!!!!!!!!!!!

        or al,al          ; 0 ?
        jz l5_o2          ; akkor nem vonunk le 32-ot
        sub al,32

l5_o2:  mov cl,byte ptr [bx+si]        ; attributum = font szam
        and cl,0fh                     ; csak az also 4 bit kell
        inc cl                         ; + 1
        xor ch,ch                      ; cx = fontszam

        mov si,[bp+10]                 ; fontoff
        mov dx,FontSize                ; kulonbseg

lo5font_ker:  add si,dx
           loop lo5font_ker         ; si = font offset  akt karakternek

        sub si,dx

        xor ah,ah              ; al = kar - 32, ah = 0

        shl ax,1                ; * 2
	push ax ;                 ^ ax
	shl ax,1		; * 4
	shl ax,1		; * 8
        pop bx                  ; |  bx
        add bx,ax               ; bx = 10 * kar num
;
        add bx,Mconst          ; space kezdocime fontkezdethez kepest !!!!!!!

        add si,bx               ; si = kivant karakter matrix kezdocime
;
        pop ax                  ; ah = or/over jelzo
        or ah,ah                ; al = 2. / 39. jelzo
        jnz l5_or               ; OR-olni

        call kar5_ki_over       ; kirajzolni
        jmp short  line_5_kar_end

l5_or:  call kar5_ki_or         ; kirajzolni

line_5_kar_end:
                      pop cx
                      pop bx          ; x pos. att.
                      pop si          ; sor kezdet imagen belul

                      inc si          ; next kar
                      inc di          ; next screen pos

		 loop line_5_kar	; ha van meg ...

			ret
line_5_pix endp

;------------
kar5_ki_over proc near  ; egy karakter also 5 sorat ES:DI-tol kirajzolja
                        ;                           DS:SI matrix 0.pix.sora
			;       minden registert  megoriz!
        push di

              mov bx,80-1     ; ennyivel kell novelni
              mov dx,2000h    ; sorok kozotti tavolsag

            push di
               sub di,dx      ; minden masodik sor
               mov dx,di      ; 2000h val kisebb
               add dx,80      ;
            pop di

            cmp al,0          ; 2. / 39.?
            jnz k5_39         ; 39.sor: elso ot pixel sor kell

            add si,5             ; 5.sortol kezdve

   k5_39:             movsb            ; 5.
;
                xchg di,dx ; di = 2000-el ala
                movsb            ; 6.
;

                mov cx,3         ; meg harom sor van

     k5_ki_ov_hur:

		xchg di,dx
		add	di,bx	; egy pixel sor
                movsb ;

     loop k5_ki_ov_hur

		pop di
                ret

 kar5_ki_over  endp

; -----------
tab_out proc near       ; tabulator egy karakteret kirajzolja

        push di

              mov bx,80-1     ; ennyivel kell novelni
              mov dx,2000h    ; sorok kozotti tavolsag
              add dx,di       ; minden masodik sorhoz ez kell

		movsb	;      1. kirak
                xchg di,dx ; di = 2000-el ala
                movsb         ; 2.

 mov cx,3  ; meg nyolc sor van

 tab_out_hur:

        xchg di,dx
        add di,bx    ; egy pixel sor
        movsb
   loop tab_out_hur

        pop di
        ret

tab_out endp

; ======================================================================

kar5_ki_or proc near  ; egy karakter also 5sorat ES:DI-tol kirajzolja
                      ; OR-olva!!!!!             DS:SI matrix 0.pix.sora
			;       minden registert  megoriz!
        push di
        push ax

              mov bx,80       ; ennyivel kell novelni
              mov dx,2000h    ; sorok kozotti tavolsag

            push di
               sub di,dx      ; minden masodik sor
               mov dx,di      ; 2000h val kisebb
               add dx,80      ;
            pop di

            cmp al,0          ; 0 = 2.sor,   1= 39.sor
            jnz kkk39

            add si,5             ; 5.sortol kezdve
kkk39:
                lodsb
                or es:[di],al    ; 5.
;
                lodsb
                xchg di,dx ; di = 2000-el ala
                or es:[di],al    ; 6.
;

                mov cx,3         ; meg harom sor van

     k5_ki_or_hur:
                lodsb
		xchg di,dx
		add	di,bx	; egy pixel sor
                or es:[di],al
     loop k5_ki_or_hur

                pop ax
		pop di
                ret

 kar5_ki_or  endp

;-----------
; kurzor ki es bekapcsolasa stb. szolgalo rutin
; egy teljes vagy also fel karakter pozicio negalasa (invert)
; hivasa:   inv_kar (x,y,merete,0,sortaboff,0)
;           merete: ha 0, akkor teljes, ha mas, akkor csak also 5 soros
;
Xinv_kar  proc near


         push bp
         mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

         push es

        push ds

	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+14]		; y koordinata
        cmp byte ptr [bp+12],0  ; teljes vagy fel?
        jz  cu_y                ; teljes
        inc bx                  ; ha fel, akkor a kov soron kell kezdeni
cu_y:   shl bx,1                ; * 2
	mov ax,Ds:[bx+si]	; ax = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add bx,ax		; bx = bal felso pont offsetje
        mov ax,0b800h           ; cga  screen segmens
        mov ds,ax               ; DS:BX beallitva kezdo pos-ra

        mov ax,2000h   ;        novekmeny 1
        mov dx,80      ;        novekmeny 2
;
; ot vagy tiz sor?

        mov cx,10                ;    default tiz
        cmp byte ptr [bp+12],0   ; teljes = 0
        jz cu_hur
        mov cl,5                 ; csak fel cursor lesz

 cu_hur:   not byte ptr [bx]     ; negalja
           sub bx,ax             ; nagyobb volt 2000h-nal?
           jc cu_1               ; kisebb volt: hozzaadni 4000h-t
           add bx,dx             ; nagyobb volt: hozzaadni 80-at
           jmp short cu_hur_end
 cu_1:     add bx,ax
           add bx,ax

 cu_hur_end: loop cu_hur

         pop ds
         jmp kilep

 Xinv_kar endp

;======================================================================

; blokk-kijelolesre stb. szolgalo rutin
; egy 10/5 pix magassagu sort x1-tol x-2 ig (beleertve) invertal
; hivasa:   inv_line (y,x1,x2, 0,sortaboff,hany_soros)
;                                          ha 0, akkor 10
;                                          kulonben 5
Xinv_line  proc near


         push bp
         mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

         push es

        push ds

	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+16]		; y koordinata
        shl bx,1                ; * 2
	mov ax,Ds:[bx+si]	; ax = sor absolute kezdocime
	mov bx,[bp+14]		; x1 koordinata
	add bx,ax		; bx = bal felso pont offsetje
        mov ax,0b800h           ; cga  screen segmens
        mov ds,ax               ; DS:BX beallitva kezdo pos-ra
;
        mov cx,[bp+12]  ; x2
        sub cx,[bp+14]  ; x1
        inc cx          ; CX = hossz


        mov ax,2000h   ;        novekmeny 1
        mov dx,80      ;        novekmeny 2
;

        mov di,10                ; tiz pixel sor
        cmp byte ptr [bp+6],0    ; ha nulla, akkor 10
        jz egy_pix_sor_inv
        mov di,5                 ; kulonben csak 5 sor kell

; egy soron vegigmegy:

   egy_pix_sor_inv:
                push cx               ; sor hossza
                push bx               ; sor eleje
   inv1_line:   not byte ptr [bx]     ; negalja
                inc bx                ; next byte
                loop inv1_line


		pop bx		; sor eleje
		pop cx		; sor hossza
                sub bx,ax             ; nagyobb volt 2000h-nal?
                jc  inv_1             ; kisebb volt: hozzaadni 4000h-t
                add bx,dx             ; nagyobb volt: hozzaadni 80-at
                jmp short inv2_h_end
      inv_1:    add bx,ax
                add bx,ax

 inv2_h_end:    dec di
                jnz egy_pix_sor_inv
         pop ds
         jmp kilep

 Xinv_line endp

;------------
kar_ki_over proc near   ; egy karaktert ES:DI-tol kirajzol
                        ;               DS:SI raallitva a matrixra
        push di

              mov bx,80-1     ; ennyivel kell novelni
              mov dx,2000h    ; sorok kozotti tavolsag

              cmp di,2000h    ; paros az elso sor?
              jnc paratlan

              add dx,di       ; minden masodik sorhoz ez kell

	ki1:	movsb	;      1. kirak
;
                xchg di,dx ; di = 2000-el ala
        ki2:    movsb         ; 2.
;

 mov cx,8 ; meg nyolc sor van

 k_ki_ov_hur1:

        xchg di,dx
        add di,bx    ; egy pixel sor
        movsb
;
       loop k_ki_ov_hur1

       jmp short k_ki_ov_end


paratlan:      push di
               sub di,dx      ; minden masodik sor
               mov dx,di      ; 2000h val kisebb
               add dx,80      ;
               pop di

                movsb    ; 1.
;
                xchg di,dx ; di = 2000-el ala
      k_ki_ov3: movsb     ; 2.
;

                mov cx,8 ; meg nyolc sor van

     k_ki_ov_hur2:

		xchg di,dx
		add	di,bx	; egy pixel sor
  k_ki_ov4:     movsb ;

     loop k_ki_ov_hur2


 k_ki_ov_end:
		pop di
                ret

 kar_ki_over  endp

; ======================================================================

space_ki_over proc near ; space-t  ES:DI-re kirajzol
			;       minden regisztert megoriz!
        push di
	push ax

              mov bx,80-1     ; ennyivel kell novelni
              mov dx,2000h    ; sorok kozotti tavolsag

                xor al,al     ; bit minta

  sp_ki_ov1:  cmp di,2000h    ; paros az elso sor?
              jnc paratlan_sp_ki_ov

              add dx,di       ; minden masodik sorhoz ez kell


                   stosb         ; 1, kirak
;
                   xchg di,dx    ; di = 2000-el ala
                   stosb         ; 2. kirak
;

 mov cx,8 ; meg nyolc sor van

 sp_ki_ov_hur1:

        xchg di,dx
        add di,bx    ; egy pixel sor
        stosb  ;
;
       loop sp_ki_ov_hur1

       jmp short sp_ki_ov_end


paratlan_sp_ki_ov:              push di
				sub di,dx	; minden masodik sor
				mov dx,di	; 2000h val kisebb
				add dx,80	;
				pop di

		stosb ;         1. kirak
;
                xchg di,dx    ; di = 2000-el ala
                stosb         ; 2.
;

                mov cx,8 ; meg nyolc sor van

     sp_ki_ov_hur2:

		xchg di,dx
		add	di,bx	; egy pixel sor
                stosb  ;

     loop sp_ki_ov_hur2


 sp_ki_ov_end:  pop ax
                pop di
                ret

 space_ki_over  endp

;======================================================================

kar_ki_or proc near     ; egy karaktert ES:DI-tol kirajzol
                        ;               DS:SI raallitva a matrixra
			; minden registert megoriz!
                        ; mind a 10 sort OR-olja a kepen levovel!!!!!!
        push di
        push ax

              mov bx,80       ; ennyivel kell novelni
              mov dx,2000h    ; sorok kozotti tavolsag

              cmp di,2000h    ; paros az elso sor?
              jnc paratlan_ki_or

              add dx,di       ; minden masodik sorhoz ez kell

                lodsb         ; al: bitminta
	ki_or1: or es:[di],al	;      1. kirak
;
                xchg di,dx ; di = 2000-el ala
                lodsb
       ki_or2:  or es:[di],al      ;       2.

 mov cx,8 ; meg nyolc sor van

 k_ki_or_hur1:
        xchg di,dx
        add  di,bx    ; egy pixel sor
        lodsb
  k_ki_or1:  or es:[di],al

       loop k_ki_or_hur1

       jmp short k_ki_or_end


paratlan_ki_or:
               push di
               sub di,dx      ; minden masodik sor
               mov dx,di      ; 2000h val kisebb
               add dx,80      ;
               pop di

                lodsb         ; al: bitminta
	k_ki_or11: or es:[di],al ;      1. kirak
;
                xchg di,dx ; di = 2000-el ala
                lodsb
     k_ki_or12: or es:[di],al        ; 2.
;
                mov cx,8     ; meg nyolc sor van

     k_ki_or_hur2:

		xchg di,dx
		add	di,bx	; egy pixel sor
		lodsb
  k_ki_or24:    or es:[di],al

     loop k_ki_or_hur2


 k_ki_or_end:   pop ax
		pop di
                ret

 kar_ki_or   endp

; ======================================================================

Xures_e  proc near; y. sort x-tol 77-ig vegignez, hogy van-e benne
                  ; valami
	          ; ha nincs: Z-flag beallitva
	          ; ha van:   Z-flag torolve



        push bp
        mov bp,sp

        Push DS
        Mov  AX,CS:[Image_Seg]
        Mov  DS,AX

	mov si,[bp+14]	; kerdeses sor Y koordinataja
        mov bx,[bp+6]   ; image offset

        call si160      ; di = di * 160

        add si,80               ; akt. sor karakterek eleje
        mov ax,[bp+16]          ; x koordinata
        add si,ax               ; kurzor pos: ide jon a karakter

van_valami_hur:
        cmp byte ptr ds:[bx+si], 0 ; nulla van ott?
        jnz van_valami_vege           ; NOT ZERO:  van valami
        cmp al,77                     ; utso-t is megneztuk?
        jz van_valami_vege            ; ZERO: nincs semmi
	inc ax
	inc si
        jmp short van_valami_hur

van_valami_vege:             ;

                pop ds
                pop bp
                db 0cah   ; ret far
                dw 13     ; ret 13   ; 12 + 1

Xures_e endp

;============================================================

di160 proc near         ; DI := DI * 160

push ax

        shl di,1        ; *2
        shl di,1        ; *4
	shl di,1	; *8
	shl di,1	; *16
        push di
        shl di,1        ; *32
	shl di,1	; *64
        pop ax
        add di,ax       ; *80
        shl di,1        ; *160

pop ax
         ret

di160 endp
;==============================================================

si160 proc near         ; SI := SI * 160

push ax

        shl si,1        ; *2
        shl si,1        ; *4
	shl si,1	; *8
	shl si,1	; *16
        push si
        shl si,1        ; *32
	shl si,1	; *64
        pop ax
        add si,ax       ; *80
        shl si,1        ; *160

pop ax
         ret

si160 endp
;==============================================================

kilep:
                pop es
                pop ds
                pop bp
                ret 12

kilep2:         pop es
                pop ds
		pop bp
		ret 16

belep           endp

CODE            ends

end

