Title CDW -hez 16 pixel soros megjelenito (OBJ modul verzio FAR hivasokkal)
;                        E G A *******************
;
;
CODE segment WORD PUBLIC
   assume cs:CODE

Mconst    EQU 48H
FontSize  EQU (128-31)*16 + Mconst
W39       EQU 39     ; EGA=39  VGA=59


; innen jonnek a belepesi pontok


Public     Page_End
Public     Ablak
Public     Sys_WriteO
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
public     felsor_ideoda
public     felsor_ideodaW
public     scrollR
public     scrollL

Public     Image_seg
Public     Image_Offs
Public     Sortab_Offs
Public     Font_Offs
Public     EzAVege

belep proc FAR

Page_End: Jmp     XPage_End
Ablak:    Jmp     XAblak
Sys_WriteO:Jmp     XSys_Write
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
Felsor_IdeOda:  Jmp     Xfelsor_ideoda
Felsor_IdeOdaW: Jmp     Xfelsor_ideodaW
scrollR:        Jmp EScrRight
scrollL:        Jmp EScrLeft


Image_seg   DW 0
Image_Offs  DW 0
Sortab_Offs DW 0
Font_Offs   DW 0


; ----------------------------------- szeles sor parameterek --

WBetuk       EQU 00H ; 80        ; sor akt. szelessege karakterekben
WBetukXketto EQU 02H ;160       ; 2-szeres max. sorszelesseg  160 vagy 320
WKezdoPos    EQU 04H ;000       ; kiiras kezdopozicioja (kepernyon ennyivel balra
                          ; X-tol)
W75          EQU 06H ;75        ; konstansok helyett
W76          EQU 08H ;76        ;
W77          EQU 0AH ;77        ;
W78          EQU 0CH ;78        ;
W79          EQU 0EH ;79        ;
W80          EQU 10H ;80        ;
Disp78       EQU 12H ;78 Ez lesz a Disp_Page szelesseg parametere

Xfelsor_ideoda proc near  ; DB. szamu y. felsort (8 pix) pufferba rakja
                          ;  vagy pufferbol eloveszi es kirakja
; hivasa: felsor_ideoda (Db,  y,puff_ofs,puff_segm,sortaboff,irany)
;                        16, 14  12       10         8       6
;         irany : 0 = pufferba rak
;                 1 = pufferbol screen-re rak



        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

        push es
        mov ax,0a000h    ; EGA screen
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

        shl bx,1
        shl bx,1
        shl bx,1         ; * 8 (pixel sorok szama)
                         ; honnan hova? igy pufferbol screenre rakashoz jo
        cmp byte ptr [bp+6],0
        jz  fio_oda     ; screenrol pufferba

     fiohuri:  push di   ; pufferbol screenre  es:di screen
               mov cx,80 ; teljes sor
               rep movsb
               pop di
               add di,80 ; next pix.line
      fio1i:   dec Bx
               jnz fiohuri
               jmp short fio_end

      fio_oda: push es
               push ds
               pop  es
               pop  ds
               xchg di,si    ; es:di <-> ds:si

     fiohuro:  push si
               mov cx,80 ; teljes sor
               rep movsb
               pop si
               add si,80
      fio1o:   dec Bx
               jnz fiohuro

    fio_end: pop ds
             jmp kilep
Xfelsor_ideoda endp
;----------------------------------------------------------------------

Xfelsor_ideodaW proc near  ; DB. szamu y. felsort (8 pix) pufferba rakja
                           ;  vagy pufferbol eloveszi es kirakja
; hivasa: felsor_ideoda (Xpos, width, Db,  y,puff_ofs,puff_segm,sortaboff,irany)
;                        20,    18,   16, 14  12       10         8       6
;         irany : 0 = pufferba rak
;                 1 = pufferbol screen-re rak


        
        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

        push es
        mov ax,0a000h    ; EGA screen
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

        shl bx,1
        shl bx,1
        shl bx,1         ; * 8 (pixel sorok szama)
                         ; honnan hova? igy pufferbol screenre rakashoz jo
        cmp byte ptr [bp+6],0
        jz  fio_odaw     ; screenrol pufferba

     fiohuriw: push di         ; pufferbol screenre  es:di screen
               add di,[bp+20]  ; Xpos = 0..79
               mov cx,[bp+18]  ; szelesseg
               rep movsb
               pop di
               add di,80 ; next pix.line
      fio1iw:  dec Bx
               jnz fiohuriw
               jmp short fio_endw

      fio_odaw: push es
                push ds
                pop  es
                pop  ds
                xchg di,si    ; es:di <-> ds:si

     fiohurow:  push si
                add  si,[bp+20]  ; Xpos = 0..79
                mov  cx,[bp+18]  ; szelesseg
                rep movsb
                pop si
                add si,80
      fio1ow:   dec Bx
                jnz fiohurow

    fio_endw: pop ds

		jmp kilep2

Xfelsor_ideodaW endp
;----------------------------------------------------------------------

Xpage_end proc near       ; y. sor 8. pixel sorat CCh/FFh-val XOR-olja
                        ; elso meghivas lapveget kiteszi
                        ; masodik meghivas lapveget elveszi

 ; hivasa:  page_end  (0, y, 0, 0, sortaboff, mit)
 ;                     ^ ez nulla legyen !!!   ^ ha nem 0, akkor hard ___



        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

        push es
        mov ax,0a000h
        mov es,ax

        cmp byte ptr [bp+14],2 ; ketto nem lehet
        jz page_end_end
        call get_line_beg ;      sor 1. pixel soran all

                          ; het sorral kell lemenni
        add di,80 * 7

           cmp byte ptr [bp+6], 0  ; ha 0, akkor soft.....
           jz spe
           mov ax,0ffffh  ; kulonben hard ___
           jmp short pe_2
 spe:      mov ax,0cccch ; xor-olo minta
 pe_2:     mov cx,39    ; 78 byte
 pe_h2:    xor word ptr es:[di],ax
           inc di
           inc di
           loop pe_h2

page_end_end: jmp kilep
Xpage_end endp
;===============================================================

Xablak proc near        ; x,y-tol m+2 sor (10 pix) magas ablakot rajzol ki
                        ; s+2 szelesseggel
                        ; s,m minimum 1 legyen!

; hivasa: ablak(x,y,magasag,fontoff,sortaboff,szelesseg)

        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

        push es
        mov ax,0a000h
        mov es,ax
        Cld            ; Istvan !   Ne hagyd el a CLD -ket !!!

            call get_line_beg ; es:di bal felso sarokra all

felso_sor:        mov  ax,107
                  call get_sys_kar_mat
                  push di
                  add di,ds:[Wkezdopos]  ; WWWW
                  call kar_ki_over
                  pop di
                  inc  di
                  mov ax,114          ;  -
                  call get_sys_kar_mat
                  mov cx,[bp+6]       ; szelesseg
      fe_hur:     push cx
                  push si
                  push di
                  add di,ds:[Wkezdopos]  ; WWWW
                  call kar_ki_over
                  pop di
                  inc di
                  pop si
                  pop cx
                  loop fe_hur
                  mov ax,108
                  call get_sys_kar_mat
                  push di
                  add di,ds:[Wkezdopos] ; WWWW
                  call kar_ki_over
                  pop di

 kozepso_sor:     inc byte ptr [bp+14]
                  inc byte ptr [bp+14]  ; next 10. pix line
                  call get_line_beg     ; es:di rajta all
                  mov ax,111            ; fuggoleges vonal
                  call get_sys_kar_mat
                  push si               ; ^
                  push di
                  add di,ds:[Wkezdopos]  ; WWWW
                  call kar_ki_over
                  pop di
                  inc di
                  mov cx,[bp+6] ; szelesseg
    kozep_hur:    push cx
                  push di
                  add di,ds:[Wkezdopos] ; WWWW
                  call space_ki_over
                  pop di
                  inc di
                  pop cx
                  loop kozep_hur
                  pop si               ;  |
                  push di
                  add di,ds:[Wkezdopos] ; WWWW
                  call kar_ki_over
                  pop di
    ;
         dec byte ptr [bp+12] ; hany kozepso sor kell?
         jnz  kozepso_sor     ; meg kell
    ;
         inc byte ptr [bp+14]
         inc byte ptr [bp+14]

         call get_line_beg ; es:di bal also sarokra all

also_sor:         mov  ax,110
                  call get_sys_kar_mat
                  push di
                  add di,ds:[Wkezdopos]  ; WWWW
                  call kar_ki_over
                  pop di
                  inc  di
                  mov ax,114           ;  -
                  call get_sys_kar_mat
                  mov cx,[bp+6]        ; szelesseg
      al_hur:     push cx
                  push si
                  push di
                  add di,ds:[Wkezdopos] ; WWWW
                  call kar_ki_over
                  pop di
                  inc di
                  pop si
                  pop cx
                  loop al_hur
                  mov ax,109
                  call get_sys_kar_mat
                  push di
                  add di,ds:[Wkezdopos] ; WWWW
                  call kar_ki_over
                  pop di

  ablak_end:   jmp kilep

Xablak endp
;-------------------------------------------------------------
get_line_beg proc near       ;  in:  [bp+14] y koordinata
                             ;       [bp+16] x koordinata
                             ;  out: di   raallitva

	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,[bx+si]	        ; di = sor absolute kezdocime !!
        add di,[bp+16]          ; x-szel korrigalva
        ret

get_line_beg endp
;------------------------------------------------------------


get_sys_kar_mat  proc near   ;  in:  ax-ban karakter num
                             ;  out:  ds:si  raallitva

        xor ah,ah
        sub al,32
        shl ax,1            ; * 2
        shl ax,1            ; * 4
        shl ax,1            ; * 8
        shl ax,1            ; * 16
        mov bx,ax           ; bx = karakter matrix offset kezdethez kepest

        mov si,[bp+10]      ; fontoff
        add bx,Mconst       ; space kezdocime fontkezdethez kepest
        add si,bx           ; si = kivant karakter matrix kezdocime

        ret

get_sys_kar_mat endp
;==============================================================
Xsor_hossz	proc near

; hivasa: sh = sor_hossz(0,y,0,fontoff,sortaboff,imageoff)
; megadja az IMAGE y. sorban talalhato kiirando karakterek szamat



        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX


       mov di,[bp+14]   ; y
       call di160       ; y*160
       add di,[bp+6]    ; di = sor eleje  (attrib)

       add di,ds:[Wbetuk]
       add di,ds:[W77]  ; di = sor vege   (karakterek)

       mov ax,ds:[W78]  ; ennyit lehet max visszamenni

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
        dw 12     ; ret 12  ; Istvan ! Ez nem 14 hanem 12 !

Xsor_hossz endp
;=============================================================

Xscroll_left	proc near       ; y1 ... y2 sorokban
				; x-re huzza x+1  pos-t,
				; 76.-ra 77.-et,
				; 77.be 0-t rak

; hivasa: scroll_left(x,y1,y2,mit,sortaboff,imageoff)
; ha mit = 0, akkor screen
;    mit <>0, akkor IMAGE



        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
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

;-------------------------------------------------------------
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
	mov di,[bp+8]		; sor_kezd_tabla offsetje
	shl bx,1		; y * 2
	mov di,Ds:[bx+di]	; di = ide sor absolute kezdocime
        add di,ax               ; di = ide pos.

        mov dx,0a000h ; ega  segm
        mov es,dx
        mov ds,dx

            mov cx,8      ; nyolc pix.sor
 bal_5:     push cx
            push ax
            push di       ; pos. bal felso

            mov cx,77
            sub cx,ax     ; cx = ennyi kell atrakni

			mov si,di
			inc si			; innen
     egy_pix_sor_bal:   repz movsb              ; egy byte-ot atrak
                        xor al,al
                        stosb                   ;  77.-be 0-t
     next_pix_line_bal:
                        pop di

                        add di,80
 ba_1:
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
       add di,[bp+6]    ; di = image sor eleje  (attrib)
       mov ax,[bp+16]   ; x
       add di,ax        ; di = sor x.pos

; 0.-ra rakunk ra valamit? Akkor meg kell jegyezni az sor attributumot
     or al,al      ;
     jnz bai9      ; nem

     mov cl,ds:[di]  ; 0.byte attrib
     and cl,0f0h     ; csak a felso 4. bit kell
     or ds:[di+1],cl ; bele OR-olni a kovetkezobe

bai9:     mov cx,ds:[W77]
          sub cx,ax   ; cx= ennyi kell atrakni

     push cx
     push di
			mov si,di
			inc si			; innen
     attr_bal:          repz movsb              ; egy byte-ot atrak
                        xor al,al
                        stosb                   ;  77.-be 0-t

                        pop di
                        add di,ds:[W80]   ;
                        pop cx
                        mov si,di
			inc si			; innen
     kar_bal:           repz movsb              ; egy byte-ot atrak
                        xor al,al
                        stosb                   ;  77.-be 0-t
                    ret

egy_sor_balra endp

;==============================================================

Xscroll_right  proc near        ; y1 .... y2 sorokban
				; 77-re huzza 76-ot,
				; x+1-re x-et
				; x.-be 0-t rak

; hivasa: scroll_right ( x, y1, y2, mit,sortaboff,imageoff)
; ha mit = 0, akkor screen
;    mit <>0, akkor IMAGE



        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
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

;-------------------------------------------------------------
egy_sor_jobbra proc near        ; [bp+14] = y koord
				; [bp+16] = x koord
                                ; 77-re az elozot   stb. x.-ig
				; x-re nullat
; visszafele fogunk pakolni !
			std	; !!!!!!!!!!!!!!!!!!!!!!!!!!!!1

       cmp byte ptr [bp+10],0   ; mi kell: screen / Image?
       jnz sri9                 ; az IMAGE kell!
       push ds

   jobbra_scr:

        mov ax,[bp+16]          ; x
        mov bx,[bp+14]          ; y
	mov di,[bp+8]		; sor_kezd_tabla offsetje
	shl bx,1		; y * 2

	mov di,Ds:[bx+di]	; di = ide sor absolute kezdocime
        add di,77               ; di = ide pos.,

        mov dx,0a000h ; ega segm
        mov es,dx
        mov ds,dx

                mov cx,8    ; nyolc pix.sor
 jobb_5:        push cx
		push ax
                push di     ; pos. jobb felso

            mov cx,77
            sub cx,ax       ; cx= ennyi kell atrakni

			mov si,di
			dec si			; innen

     egy_pix_sor_jobb:   repz movsb             ; egy byte-ot atrak
                         xor al,al
			 stosb			; x.-be 0-t
	next_pix_line_jobb:
                        pop di

                        add di,80
 jo_1:
		pop ax
                pop cx
                loop jobb_5

              cld       ; visszaallitja felfelehez
              pop ds
              ret

; most jon az IMAGE -----------------------
sri9:   push ds
	pop es

       mov di,[bp+14]   ; y
       call di160       ; y*160
       add di,[bp+6]    ; di = sor eleje  (attrib)
       mov ax,[bp+16]   ; x
       add di,ds:[W77]  ; di = sor vege (ameddig lehet)



          mov cx,ds:[W77]
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
			add di,ds:[W80]	;
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
        Call SET_DS
        Mov  DS,AX

        push es

        mov ax,0a000h ; ega  segm
        mov es,ax

	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	add di,79		; di = bal felso pont offsetje
        Add Di,ds:[WkezdoPos]   ; Azert,mert ezt ki fogja vonni L.A. WWWW
;
	cmp byte ptr [bp+16],0	; kirak vagy elvesz?
        jnz lptr_kirak          ; elvesz = space-val felulir

        call space_ki_over      ; csak a screen pozicio kell
        jmp kilep

lptr_kirak:
        mov si,[bp+10]           ; fontoff
        add si,Mconst + (105-32)*16  ; mutato matrix kezdet

        call kar_ki_over        ; egy karaktert kiir, overwrite
        jmp kilep

Xline_ptr endp

;===============================================================

Xline_stat proc near    ; y.dik sor 78.oszlopaba az image-nek megfelelo
                        ; status-jelzot kirakja
                        ; status jelzok matrixa a system fontban:
                        ; 97 = hard CR
                        ; 98 = soft CR
			; 99 = felso index
			; 100 = also index
                        ; magassaguk 6 pix. sor igy a kivant sor
			; 5. pixel soraban kell elkezdeni kirakni oket,
			; hogy kozepre keruljenek



        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

        push es

        mov ax,0a000h ; ega segm
        mov es,ax


	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata

        cmp bl,02  ; 2. sorban torolni
        jz  l_s_2
        cmp bl,W39  ; 39. sorban torolni
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

        mov bx,[bp+6]     ; image offset
        call si160        ; si = si * 160
        mov al,[bx + si]  ; al = 0. attr byte

;        Push Bx
;        Add  Bx,DS:[W77]
;        MOV AH,BYTE PTR [BX+SI]  ; a 77. attrib (protected)
;        POP  BX

        mov si,[bp+10]    ; fontoff
        add si,Mconst + (97-32) * 16 ; hard cr kezdete

;        TEST  AH,80h            ; 3. bit protected sor
;        jnz   protected

        test al,10h            ; 4. bit fosor/index sor
        jz  index_sor

  fosor: test al,80h           ; 7. bit soft/hard cr
         jnz  get_st_kesz      ; hard cr: SI beallitva
         add si,16             ; soft cr a kovetkezo

     get_st_kesz:   ret

protected:  add si,27*16       ; | karakter
            jmp short get_st_kesz

 index_sor: add si,32          ; masodik ketto lehet
            jmp fosor          ; ugyanazt kell csinalni

    gstsp:    mov si,[bp+10]         ; fontoff
              add si,Mconst       ; space kezdete
              ret

get_status endp
;================================================================

disp_status proc near           ; ds:si matrixra allitva
				; es:di screenre mutat
				; 5 pix sort torolni
				; majd 6-ot kirajzolni (over)

           CLD                  ; Istvan ! Remelem ez az utolso. L.A.
           mov cx,5             ; 5 sorral lemenni
dsh1:
           add  di,80
 ds_1:     loop dsh1

           mov cx,6             ; 6 -ot kirajzolni
dsh2:
           movsb                ; si,di novekedett
           add di,79            ;
 dsh2end:  loop dsh2

           ret

disp_status endp
;------------------------------------------------------------------
 torol_st2 proc near   ; 2. sorban status jelzot torol

 mov byte ptr es:[780h+78], 00
 mov byte ptr es:[780h+78+80], 00
 mov byte ptr es:[780h+78+160], 00
 ret

 torol_st2  endp

;------------------------------------------------------------------
 torol_st39 proc near   ; 39. sorban status jelzot torol

 otsor equ 5 * 80
 mov byte ptr es:[W39*80*8+otsor+78], 00
 mov byte ptr es:[W39*80*8+otsor+78+80], 00
 mov byte ptr es:[W39*80*8+otsor+78+160], 00
 ret

 torol_st39  endp
;-----------------------------------------------------------------
Xpage_stat proc near    ; image alapjan y.sorig (azt is beleertve)
                        ; a statusz jelzoket kiirja
                        ; 39.-ket nem irja ki !!!


        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

        push es

        mov ax,0a000h   ; ega segm
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

        cmp si,W39
        jz ps39 ; torolni!
        cmp [bp+14],si ; y.-ig kell menni, azt is!
        jnc psh        ; meg nem nagyobb

        jmp kilep
  ps39: call torol_st39
        jmp kilep

 Xpage_stat endp

;================================================================

Xdisp_page  proc near   ; kepernyo torlese a 3. sortol
                        ; a leheto leggyorsabb modon
                        ; majd a teljes image megjelenitese

                     ; !!!!!!!!!!!! Istvan !  L.A.-D.A.

        push bp
        mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

        push es

        mov ax,0a000h ; ega segm
        mov es,ax

        xor ax,ax

        Cmp Word ptr DS:[Disp78],78   ; WWWWWW
        jnz NemKellTorles    ; WWWWWW  L.A.

        mov di,1920   ; 3. 8-pix sor
        mov cx, (W39+1)*8*40  - 1920/2  ;    ??????
        rep stosw
	;     ---------     kepernyo torolve
	;                   most minden olyan sort, amiben van valami
	;                   OR-olva megjeleniteni


NemKellTorles:
        Mov AX,[Bp+16]               ; Az x pozicioval korrigalom a hosszt
        Add DS:[disp78],AX           ;   mert kesobb levonja azt is

        Mov Ax,DS:[Wkezdopos]        ; WWWW L.A.
        ADD [bp+16],AX               ; x -koordinata WWWW L.A (0 volt)
        mov byte ptr [bp+14],2       ; y -koordinata

        mov si,[bp+6]       ; image offset
        add si,ds:[WbetukXketto]
        add si,ds:[WbetukXketto] ; 2. sor

        test byte ptr [si],20h    ; 5. bit = van benne valami?
        jz  page_t_sorok          ; nincs
        mov ax,0100h              ; OR-olva 2. sor
            push si
        call line_5_pix           ; kiirni
            pop si

page_t_sorok:  inc byte ptr [bp+14]      ; next line (teljes sorok: 3..38)
               add si,ds:[WbetukXketto]  ; image cime
               test byte ptr [si],20h    ; van benne valami?
               jz page_next_line         ; nincs
               push si
               mov ax,0100H              ; OR ; WWWW L.A. Mov Ah,01 volt
               call line_out             ; kiir
               pop si

 page_next_line:  cmp byte ptr [bp+14],(W39-1) ; 38. volt?
                  jnz page_t_sorok        ; meg nem

               add si,ds:[WbetukXketto]   ; 39. sor
               test byte ptr [si],20h     ; van benne valami?
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
        Call SET_DS
        Mov  DS,AX

        push es

	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add di,bx		; di = bal felso pont offsetje
        mov ax,0a000h           ; ega screen segmens
        mov es,ax               ; ES:DI beallitva kirakohelyre
;
	mov ax,[bp+12]	; karakter num
        or al,al        ; 0 is space lesz
        jz sys_space
        sub al,32       ; szokoztol megyunk
        jz  sys_space   ; space-ra kulon rutin van

        shl ax,1                ; * 2
	shl ax,1		; * 4
	shl ax,1		; * 8
	shl ax,1		; * 16
        mov bx,ax               ; bx = karakter matrix offset kezdethez kepest
;
        mov cx,[bp+6]           ;  font szam
        inc cx                  ; + 1
        mov si,[bp+10]      ; fontoff
        mov dx,FontSize      ; kulonbseg

pkf_ker:  add si,dx
          loop pkf_ker     ; si = font offset  akt karakternek
          sub si,dx        ; igy a jo
;
        add bx,Mconst   ; space kezdocime fontkezdethez kepest !!!!!!!
        add si,bx          ; si = kivant karakter matrix kezdocime
;
          push di
          add di,ds:[Wkezdopos]  ; azert mert ki fogja vonni WWWW L.A.
          call kar_ki_over
          pop di

        jmp kilep

   sys_space:
        push di
        add di,ds:[Wkezdopos] ; mert ki fogja vonni WWWW L.A.
        call space_ki_over
        pop di
        jmp kilep

   XSys_Write endp
; ======================================================================
; felfele scrollozo rutin: 8 pixelsoros;
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
        Call SET_DS
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
; lefele scrollozo rutin: 8  pixelsoros;
; hivasa  sc_dn (y-tol,y-ig,darab,0,sortaboff,imageoff)
;                16     14    12  10     8       6

Xsc_dn proc near


        
        push bp
        mov bp,sp

        Push DS
        Call SET_DS
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

;----------------------------------------------------------------------
clear_line_ax proc near   ; ax.-dik 8 pix. sort torli

        cld
	mov di,[bp+8]		; sor_kezd_tabla offssetje
	mov bx,ax		; y koordinata
	shl bx,1		; * 2
	mov di,ds:[bx+di]	; di = sor absolute kezdocime

        mov ax,0a000h           ; EGA screen segm
        mov es,ax

        mov ax,0000    ; ezzel feltolteni

clrax_hur:
                 mov cx,40 * 8 ;     40 word egy sor
                 rep stosw ;     0-kat [di]-be !

                 ret

clear_line_ax endp
;----------------------------------------------------------------------------
egy_sor_le proc near    ; [bp+14]-ik sorra rakja [bp+10]-et
        cld
        cmp byte ptr [bp+10],2  ; tabulatort nem rakjuk a 2.-bol!
        jz  sdi9                ; de az IMAGE-t at kell rakni!
	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
	shl bx,1		; * 2
	mov di,[bx+si]	; di = ide sor
        mov bx,[bp+10]
        shl bx,1
        mov si,[bx+si];  si = innen

        push ds                 ; DS,ES screen!!!
        mov ax,0a000h           ; EGA screen segm
        mov es,ax
        mov ds,ax

shd_hur:
                 mov cx,40 * 8 ;     40 word egy sor
                 rep movsw     ;     atpakolni
                               ; si/di jo helyre all be!!!

;--------------------------    most jon az IMAGE ------
        pop ds
sdi9:   push ds
        pop es

   mov di,[bp+14]  ; erre pakol
   call di160      ; cime
   add di,[bp+6]   ; image offs

   mov si,[bp+10]  ; ezt pakol
   call si160      ; cime
   add si,[bp+6]   ; image offs

   mov cx,ds:[W80] ; sor szelesseg
   rep movsw       ; atpakol

 ;--------------------------------
            ret

egy_sor_le endp

;=======================================================================

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

        mov ax,0a000h            ; EGA screen segm
        mov es,ax
        mov ds,ax

shu_hur:
                 mov cx,40 * 8 ;     40 word egy sor
                 rep movsw     ;     atpakolni

;--------------------------    most jon az IMAGE ------
        pop  ds
sui9:   push ds
	pop es

   mov di,[bp+14]  ; erre
   call di160      ; cime
   add di,[bp+6]   ; image offs

   mov si,[bp+10]  ; ezt
   call si160      ; cime
   add si,[bp+6]   ; image offs

   mov cx,ds:[W80] ; sor szelesseg
   rep movsw       ; atpakol

            ret

egy_sor_fel endp
;=======================================================================
; egy karakter megjelenites az image alapjan
; hivasa: disp_kar (x,y,0,fontoff,sortaboff,imageoff)
;         kezeli az atfedeseket es fontokat is !!!!

Xdisp_kar proc near

         
         push bp
         mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

         push es

         mov ax,0a000h ; ega screen segm
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
;======================================================================

; fejlec es tabulator megjelenito rutin
; fejlecet   az image 0.sorabol veszi
; tabulatort az image 1.sorabol veszi
; hivasa:  fej_tab (0,0,0,fontoff,sortaboff,imageoff) ... fejlecet frissit
;          fej_tab (1,0,0,fontoff,sortaboff,imageoff) ... tabulatort frissit

Xfej_tab proc near

         
        push bp
         mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

         push es

         cld
         mov ax,0a000h ; ega screen segm
         mov es,ax

         mov si,[bp+10] ; fontoff
         xor ah,ah      ; 0 = fejlec

         mov di,0       ; default: fejlec
         mov bx,[bp+6]  ; 0. image sor (image offset)
         Sub Bx,ds:[WkezdoPos] ; Mivel a Tab-ok miatt hozzaadja L.A. WWWW
         cmp byte ptr [bp+16],0 ; fejlec kell?
         mov CX,80           ; 0..79 x-pos
         jz  ft_kar

         inc ah              ; 1= tabulator
         mov di,1280         ; tabulator sor screen-en
         add bx,ds:[WbetukXketto] ; 1. image sor   { tabulatorok }
         Add Bx,Ds:[WkezdoPos] ; visszacsinaljuk az elobbi kivonast WWWW L.A.
         Mov CX,78             ; WWWWW L.A.

ft_kar:          push si ; font off
                 push bx ; image sor offset
                 push cx ; karakter szamlalo

        push ax                ; ah = fel/tab  jelzo

        push bx                ; WWWWWWWWWWWWWWW miatt
        add bx,ds:[W80]
        add bx,ds:[WkezdoPos]    ; honnan kell?
        mov al, byte ptr [bx]  ; karakter

        ; pop BX                  ; orosz miatt kiszedve
; oooooooooooooooooooooooooooooooooooooooooooooooooooo
        PUSH CX
        PUSH DX

        Sub bx,DS:[W80]
        mov cl,byte ptr [bx]        ; attributum = font szam
        and cl,0fh                  ; csak az also 4 bit kell
        inc cl                      ; + 1
        xor ch,ch                   ; cx = fontszam

        mov dx,FontSize     ; kulonbseg

f_kero: add si,dx
        loop f_kero          ; si = font offset  akt karakternek
        sub  si,dx
        POP  DX
        POP  CX


        POP BX

; ooooooooooooooooooooooooooooooooooo vege



        sub al,32    ; nem lehet benne kisebb   !!!!!!!!!!!!
        xor ah,ah              ; al = kar - 32, ah = 0

        shl ax,1                ; * 2
	shl ax,1		; * 4
	shl ax,1		; * 8
	shl ax,1		; * 16
        mov bx,ax               ; bx = 16 * kar num
;
        add bx,Mconst        ; space kezdocime fontkezdethez kepest

        add si,bx               ; si = kivant karakter matrix kezdocime
;
        pop ax                  ; | ah fej/tab jelzo
        or ah,ah                ; ha nem 0, akkor OR-olni
        jnz tab1

        push di
        add di,ds:[Wkezdopos]   ; Mert ki fogja vonni WWWW L.A.
        call kar_ki_over
        pop di
        jmp short fejtab_kar_end ;----------------------

tab1:   add si,8                 ; also 8 sor
        call tab_out             ; tabulatort also 8 pixellel kirajzolni

fejtab_kar_end:         pop cx
                        pop bx
			pop si
                        inc bx          ; next kar
                        inc di          ; next screen pos

		 loop ft_kar	; ha van meg ...

                      jmp kilep

 Xfej_tab endp

;-----------------------------------------------------------------------
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
        Call SET_DS
        Mov  DS,AX

         push es

         mov ax,0a000h ; ega screen segm
         mov es,ax

         call kornyezet ; [bp+12] -ben a felette es alatta levo sorok allapota
                        ;
      xor ax,ax                  ; al = 0, ah =0 aktualis image sor , overwrite

      cmp byte ptr [bp+14],2     ; 2.  sor: kulon teszta
      jz  kivetel_2
      cmp byte ptr [bp+14],W39   ; 39. sor: kulon teszta
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


     cmp byte ptr [bp+14],(W39-1)  ; 38.sor alattit kell kiirni?
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

;----------------------------------------------------------------------
kornyezet proc near     ; a kerdeses sor feletti es alatti sorok allapota
			; [bp+12] = felette levo sor (0 = ures)
			; [bp+13] = alatta  levo sor (0 = ures)

	mov di,[bp+14] ; kerdeses sor Y koordinataja
        mov bx,[bp+6]  ; image offset

        dec  di            ; elozo sor
        call di160         ; di = di * 160

        mov cl,byte ptr ds:[bx+di]     ; elozo sor attributuma
        add di,ds:[WbetukXketto]       ; ez a sor
        add di,ds:[WbetukXketto]       ; alatta levo sor
        mov ch,byte ptr ds:[bx+di]     ; kovetkezo sor attributuma
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

        CLD                     ; WWWWWWWW  L.A.
        push ax                 ; ^ ax , ah = over/or jelzo
	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+14]		; y koordinata
        add bl,al               ; al-lel korrigalni

        push bx                 ;  ^ bx, bl = y koord
        shl bx,1                ; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add di,bx		; di = bal felso pont offsetje
;                                 ----------------------------

        mov bx,[bp+6]           ; image offset
        pop si                  ; | SI = y koord
        push si                 ; ^    = y koord

; 160-nal megszorozni

        call si160
        add si, [bp+16]              ; + x koordinata

        add si,ds:[Wbetuk]
        mov al, byte ptr [bx+si]    ; karakter
        sub si,ds:[Wbetuk]          ; attribra mutat

; fel kell keszulni a 0-ra es a space-ra !!!!!!!!!!!!!!!

        or al,al     ; 0 ????
        jz s_d2      ; szokoz lesz
        sub al,32    ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        or al,al     ; space ???
        jnz s_d2     ; nem, hol a matrixa

; space kezelest ide !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
; ha valodi space volt (asc 32), akkor .-ot kell kiirni
; system font, 103-as karakter
        mov si,[bp+10]                   ; fontoff
        add si,Mconst + 16 * (103-32) ; itt kezdodik
        jmp short sd_sp

s_d2:   mov cl,byte ptr [bx+si]     ; attributum = font szam
        and cl,0fh                  ; csak az also 4 bit kell
        inc cl                      ; + 1
        xor ch,ch                   ; cx = fontszam

        mov si,[bp+10]      ; fontoff
        mov dx,FontSize     ; kulonbseg

f_ker:  add si,dx
        loop f_ker          ; si = font offset  akt karakternek
        sub si,dx

        xor ah,ah               ; al = kar -32
        shl ax,1                ; * 2
	shl ax,1		; * 4
	shl ax,1		; * 8
	shl ax,1		; * 16
        mov bx,ax               ; bx = 16 * kar num
;
        add bx,Mconst  ; space kezdocime fontkezdethez kepest !!!!!!!
        add si,bx         ; si = kivant karakter matrix kezdocime
;
sd_sp:  pop bx                  ; | bl = akt y-koordinata
        pop ax                  ; | ah over/or jelzo

        or ah,ah                ; ha nem 0, akkor OR-olni
        jnz s_d_or

        jmp kar_ki_over         ; kirajzolni, onnan megy vissza
                                ;---------------------------------------------

; OR  ... de 2. es  39. sorban levot egyedileg kezelni

s_d_or: cmp bl,2                ; 2. sor?
        jnz sdo1                ; nem
        mov al,0                ; 2. sor jelzo
        mov di,1920             ; 3. sor kezdet
        add di,[bp+16]          ; x. koord
        jmp kar5_ki_or

sdo1:   cmp bl,W39              ; 39. sor?
        jnz sdo2                ; nem teljes karaktert kell kirajzolni
        mov al,1                ; 39. sor jelzo
        jmp kar5_ki_or

sdo2: jmp kar_ki_or             ; kirajzolni ..... onnan vissza megy

si_di_out endp
;======================================================================
;
line_out  proc near    ; egy sor kiirasat elvegzi
		       ; elozoleg y-koordinatat AL-lel korrigalja
                       ; space kezelesre ugyel
                       ; ha AH = 0, a sort felulirja
                       ; kulonben minden karaktert OR-olva kirajzoltat

        push ax                 ; ^ ah = over/or jelzo

	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
        add bl,al               ; al-lel korrigalni
        push bx                 ; ^ BX (y koord)

        shl bx,1                ; * 2
	mov di,Ds:[bx+si]	; di = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add di,bx		; di = bal felso pont offsetje
;                                 ----------------------------
        mov bx,[bp+6]           ; image offset DS:
        pop si                  ; | SI = y koord
                                ; 160-nal megszorozni
        call si160
        add si, [bp+16]         ; + x koordinata

        pop ax                  ; | ah = or/over jelzo
; ..................................................

        mov cx,DS:[disp78]         ; Itt 78 volt
        sub cx,[bp+16]          ; ennyi karaktert kell kiirni
        add cx,Ds:[Wkezdopos]   ; az x nagyobb lehet mint 80 WWWWW L.A.

line_out_kar:    push si ; x image offsetten belul
                 push bx ; image offset
                 push cx ; karakter szamlalo

        push ax         ; ah = or/over jelzo

        Push Si
        Add  Si,Ds:[Wbetuk]
        mov al, byte ptr ds:[bx+si]  ; karakter
        Pop  Si

; fel kell keszulni a 0-ra es a space-ra !!!
        or al,al     ; 0 ????
        jz l_o2      ; szokoz lesz
        sub al,32    ;
        or al,al     ; space ???
        jnz l_o2     ; nem, hol a matrixa

; ha asc space, akkor system font 103-as karaktere kell

  mov si,[bp+10]                      ; fontoff
  add si,Mconst + 16 * (103-32)    ; itt kezdodik
  jmp short lo_sp

l_o2:   mov cl,byte ptr ds:[bx+si]     ; attributum = font szam
        and cl,0fh                     ; csak az also 4 bit kell
        inc cl                         ; + 1
        xor ch,ch                      ; cx = fontszam

        mov si,[bp+10]      ; fontoff
        mov dx,FontSize     ; kulonbseg

lo_f_ker:  add si,dx
           loop lo_f_ker         ; si = font offset  akt karakternek
           sub si,dx

        xor ah,ah               ; al = kar - 32, ah = 0
        shl ax,1                ; * 2
	shl ax,1		; * 4
	shl ax,1		; * 8
	shl ax,1		; * 16
        mov bx,ax               ; bx = 16 * kar num
;
        add bx,Mconst       ; space kezdocime fontkezdethez kepest !!!!!!!
        add si,bx              ; si = kivant karakter matrix kezdocime
;
lo_sp:  pop ax                  ; | ah over/or jelzo
        or ah,ah                ; ha nem 0, akkor OR-olni
        jnz l_o_or

        call kar_ki_over           ; kirajzolni
        jmp short line_out_kar_end ;----------------------

l_o_or: call kar_ki_or             ; kirajzolni

line_out_kar_end:       pop cx
                        pop bx          ; image offset
                        pop si          ; pozicio imagen belul

                        inc si          ; next kar
                        inc di          ; next screen pos

		 loop line_out_kar	; ha van meg ...

			ret
line_out endp
;======================================================================
;
line_5_pix  proc near    ; 2. es 39. image sor kiirasat elvegzi
			 ; csak az also/felso 8 pixel sort jeleniti meg
                         ; ah = 0, akkor overwrite, kulonben OR
                         ; al = 0, akkor 2. sor, kulonben 39. sor
                         ; space kezelesre ugyel

        mov di,1920            ; 3.sor kezdo cime (also 8.pix)
        cmp al,0               ; vagy a 39. kell?
        jz l51
        mov di,W39*8*80        ; 39. sor kezdo cime

l51:    mov bx,[bp+16]          ; x koordinata
	add di,bx		; di = bal felso pont offsetje
;                                 ----------------------------
        mov si,[bp+6]           ; image offset
        add si,ds:[WbetukXketto] ;
        add si,ds:[WbetukXketto] ; masodik sor attr. kezdet
        cmp al,0                ; a 39. kell?
        jz l52

        push ax               ; WWWWWWWWWWWWWWWWWWWWWWW
        mov ax,(W39-2)
        mov cx,ds:[WbetukXketto]
        imul cx
        add si,ax             ; akkor meg 37-tel lejjebb
        pop ax


 l52:   ;       ???????   add si,[bp+16]          ; + x koordinata

        mov cx,Ds:[disp78]     ; 78 volt L.A.
        sub cx,[bp+16]         ; ennyi karaktert kell kiirni
        Add cx,ds:[Wkezdopos]  ; WWWW L.A.

line_5_kar:      push si ; sor kezd   image offsetten belul
                 push bx ; x attr
                 push cx ; karakter szamlalo
                 push ax ; ah = or/over jelzo , al = 2./39. jelzo

        push si                   ; WWWWWWWWWWWWWWWWW
        add si,ds:[Wbetuk]
        mov al, byte ptr [bx+si]  ; karakter
        pop si

; fel kell keszulni a 0-ra es a space-ra !!!!!!!!!!!!!!!

        or al,al          ; 0 ?
        jz l5_o2          ; akkor nem vonunk le 32-ot
        sub al,32

l5_o2:  mov cl,byte ptr [bx+si]        ; attributum = font szam
        and cl,0fh                     ; csak az also 4 bit kell
        inc cl                         ; + 1
        xor ch,ch                      ; cx = fontszam

        mov si,[bp+10]      ; fontoff
        mov dx,FontSize     ; kulonbseg

lo5font_ker:  add si,dx
              loop lo5font_ker         ; si = font offset  akt karakternek
              sub si,dx

        xor ah,ah               ; al = kar - 32, ah = 0
        shl ax,1                ; * 2
	shl ax,1		; * 4
	shl ax,1		; * 8
	shl ax,1		; * 16
        mov bx,ax               ; bx = 16 * kar num
;
        add bx,Mconst    ; space kezdocime fontkezdethez kepest !!!!!!!
        add si,bx           ; si = kivant karakter matrix kezdocime
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

;-----------------------------------------------------------------------
kar5_ki_over proc near  ; egy karakter 8 sorat ES:DI-tol kirajzolja
                        ;                      DS:SI matrix 0.pix.sora

           CLD     ; WWWW Istvan! L.A.
           push di
           sub di,ds:[Wkezdopos]  ; WWWWWWWWWWWW

           push ax

            cmp al,0          ; 2. / 39.?
            jnz k5_39         ; 39.sor: elso ot pixel sor kell

            add si,8          ; karakter 8.soratol kezdve

   k5_39:   mov cx,8
   k5_ki_ov_hur:
                movsb         ; ds:[si] -> es:[di] ; inc si/di
                add di,79

   k5_qq:    loop k5_ki_ov_hur

                pop ax
		pop di
                ret

 kar5_ki_over  endp

; ----------------------------------------------------------------------
tab_out proc near       ; tabulator egy karakteret kirajzolja

             push di
             mov cx,8

  tab_out_hur:    movsb
                  add di,79
  tab_qq:   loop tab_out_hur

        pop di
        ret

tab_out endp

; ======================================================================

kar5_ki_or proc near  ; egy karakter 8 sorat ES:DI-tol kirajzolja
                      ; OR-olva!!!!!         DS:SI matrix 0.pix.sora
        push di
        sub di,ds:[Wkezdopos]  ; WWWWWWWWWWWW

        push ax
        mov cx,8

            cmp al,0          ; 2. / 39.?
            jnz kar5_or_hur   ; 39.sor: elso ot pixel sor kell
            add si,8          ; karakter 8. soratol kezdve

  kar5_or_hur:  mov al,ds:[si]
                or es:[di],al   ; ott van
                inc si
                add di,80
        kar5_or_qq: loop kar5_or_hur

        pop ax
        pop di
        ret

 kar5_ki_or  endp

;----------------------------------------------------------------------
; kurzor ki es bekapcsolasa stb. szolgalo rutin
; egy teljes vagy also fel karakter pozicio negalasa (invert)
; hivasa:   inv_kar (x,y,merete,0,sortaboff,0)
;           merete: ha 0, akkor teljes, ha mas, akkor csak also 8 soros
;
Xinv_kar  proc near



         
        push bp
         mov bp,sp

        Push DS
        Call SET_DS
        Mov  DS,AX

         push es

        push ds

	mov si,[bp+8]		; sor_kezd_tabla offsetje
	mov bx,[bp+14]		; y koordinata
        cmp byte ptr [bp+12],0  ; teljes vagy fel?
        jz  cu_y                ; teljes
        inc bx                  ; ha fel, akkor a kov soron kell kezdeni
cu_y:   shl bx,1                ; * 2
	mov ax,Ds:[bx+si]	; ax = sor absolute kezdocime
	mov bx,[bp+16]		; x koordinata
	add bx,ax		; bx = bal felso pont offsetje

        sub bx,ds:[Wkezdopos]   ; WWWWWWWWW

        mov ax,0a000h           ; ega screen segmens
        mov ds,ax               ; DS:BX beallitva kezdo pos-ra


; 8 vagy 16 sor?

        mov cx,16                ; default 16
        cmp byte ptr [bp+12],0   ; teljes = 0
        jz cu_hur
        mov cl,8                 ; csak fel cursor lesz

 cu_hur:   not byte ptr [bx]     ; negalja
           add bx,80
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
        Call SET_DS
        Mov  DS,AX

         push es

        push ds

	mov si,[bp+8]		; sor_kezd_tabla offsetje a CS-en !!!!!!!
	mov bx,[bp+16]		; y koordinata
        shl bx,1                ; * 2
	mov ax,Ds:[bx+si]	; ax = sor absolute kezdocime
	mov bx,[bp+14]		; x1 koordinata
	add bx,ax		; bx = bal felso pont offsetje

        ; sub bx,ds:[Wkezdopos]   ; WWWWWWWWWWWWWWWW

        mov ax,0a000h           ; ega screen segmens
        mov ds,ax               ; DS:BX beallitva kezdo pos-ra
;
        mov cx,[bp+12]  ; x2
        sub cx,[bp+14]  ; x1
        inc cx          ; CX = hossz

;
        mov di,16                ; 16 pixel sor
        cmp byte ptr [bp+6],0    ; ha nulla, akkor 10
        jz egy_pix_sor_inv
        mov di,8                 ; kulonben csak 8 sor kell

; egy soron vegigmegy:

   egy_pix_sor_inv:
                push cx               ; sor hossza
                push bx               ; sor eleje
   inv1_line:   not byte ptr [bx]     ; negalja
                inc bx                ; next byte
                loop inv1_line


		pop bx		; sor eleje
		pop cx		; sor hossza

                add bx,80
 inv2_h_end:    dec di
                jnz egy_pix_sor_inv
         pop ds
         jmp kilep

 Xinv_line endp
;-----------------------------------------------------------------------
kar_ki_over proc near   ; egy karaktert ES:DI-tol kirajzol
                        ;               DS:SI raallitva a matrixra
        push di
        sub di,ds:[Wkezdopos]  ; WWWWWWWWWWWW

        push ax

                   movsb      ; 1
                   add di,79
                   movsb      ; 2
                   add di,79
                   movsb      ; 3
                   add di,79
                   movsb      ; 4
                   add di,79
                   movsb      ; 5
                   add di,79
                   movsb      ; 6
                   add di,79
                   movsb      ; 7
                   add di,79
                   movsb      ; 8
                   add di,79
                   movsb      ; 9
                   add di,79
                   movsb      ; 10
                   add di,79
                   movsb      ; 11
                   add di,79
                   movsb      ; 12
                   add di,79
                   movsb      ; 13
                   add di,79
                   movsb      ; 14
                   add di,79
                   movsb      ; 15
                   add di,79
                   movsb      ; 16
                   add di,79

 k_ki_ov_end:
                pop ax
		pop di
                ret

 kar_ki_over  endp

; ======================================================================

space_ki_over proc near ; space-t  ES:DI-re kirajzol

        push di
        sub di,ds:[Wkezdopos]  ; WWWWWWWWWWWW

        push ax
              xor al,al     ; bit minta

                   stosb      ;1
                   add di,79
                   stosb      ;2
                   add di,79
                   stosb      ;3
                   add di,79
                   stosb      ;4
                   add di,79
                   stosb      ;5
                   add di,79
                   stosb      ;6
                   add di,79
                   stosb      ;7
                   add di,79
                   stosb      ;8
                   add di,79
                   stosb      ;9
                   add di,79
                   stosb      ;10
                   add di,79
                   stosb       ;11
                   add di,79
                   stosb        ;12
                   add di,79
                   stosb         ;13
                   add di,79
                   stosb          ;14
                   add di,79
                   stosb           ;15
                   add di,79
                   stosb            ;16
                   add di,79

 sp_ki_ov_end:
                pop ax
                pop di
                ret

 space_ki_over  endp

;======================================================================

kar_ki_or proc near     ; egy karaktert ES:DI-tol kirajzol
                        ;               DS:SI raallitva a matrixra
              push di
              sub di,ds:[Wkezdopos]  ; WWWWWWWWWWWW

              push ax

              lodsb
              or es:[di],al      ;1
              add di,80
              lodsb
              or es:[di],al      ;2
              add di,80
              lodsb
              or es:[di],al      ;3
              add di,80
              lodsb
              or es:[di],al      ;4
              add di,80
              lodsb
              or es:[di],al      ;5
              add di,80
              lodsb
              or es:[di],al      ;6
              add di,80
              lodsb
              or es:[di],al      ;7
              add di,80
              lodsb
              or es:[di],al      ;8
              add di,80
              lodsb
              or es:[di],al      ;9
              add di,80
              lodsb
              or es:[di],al      ;10
              add di,80
              lodsb
              or es:[di],al      ;11
              add di,80
              lodsb
              or es:[di],al      ;12
              add di,80
              lodsb
              or es:[di],al      ;13
              add di,80
              lodsb
              or es:[di],al      ;14
              add di,80
              lodsb
              or es:[di],al      ;15
              add di,80
              lodsb
              or es:[di],al      ;16
              add di,80

 k_ki_or_end:
                pop ax
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
        Call SET_DS
        Mov  DS,AX

	mov si,[bp+14]	; kerdeses sor Y koordinataja
        mov bx,[bp+6]   ; image offset

        call si160      ; di = di * 160

        add si,ds:[Wbetuk]      ; akt. sor karakterek eleje
        mov ax,[bp+16]          ; x koordinata
        add si,ax               ; kurzor pos: ide jon a karakter

van_valami_hur:
        cmp byte ptr ds:[bx+si], 0 ; nulla van ott?
        jnz van_valami_vege           ; NOT ZERO:  van valami
        cmp al,byte ptr ds:[W77]      ; utso-t is megneztuk?
        jz van_valami_vege            ; ZERO: nincs semmi
	inc ax
	inc si
        jmp short van_valami_hur

van_valami_vege:                   ;
                pop ds
                pop bp
                db 0cah ;  ret far 13   ; 12 + 1
                dw 13   ;
Xures_e endp

;============================================================

di160 proc near         ; DI := DI * WbetukXketto

push ax
        mov ax,ds:[WbetukXketto]  ; get line width * 2
        imul di
        mov di,ax

   comment #
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
   #
pop ax
         ret

di160 endp
;==============================================================

si160 proc near         ; SI := SI * WbetukXketto
push ax
        mov ax,ds:[WbetukXketto]
        imul si
        mov si,ax

   comment #
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
   #
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

kilep3:         ret 2

belep           endp

Set_Ds          Proc Near
                  Mov  Bx,Offset $  ; 3 byte
                  Call Next  ; 3 byte
           Next:  Pop  Ax    ; 1 byte
                  Sub  Ax,6
                  Sub  Ax,Bx
                  Mov  Bx,Offset Image_Seg
                  Add  Bx,Ax
                  Mov  Ax,CS:[Bx]
                  CLD
                  Ret
Set_Ds          Endp
;------------------------------------------------- EGA -------
EScrLeft proc NEAR

  Push Bp
  Mov Bp, Sp

  Push Ds

  CLD

  Mov  Ax,0A000H
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,3*80*8  ;{ Az elso szerkesztoterulet sor elso byte  }
  Mov  Si,Di
  Add  Si,[BP+6]  ;{ Innen move-olja                 }

  Mov  Cx,(W39-2)*8 ;{ Ennyi pixelsor                  }
  Mov  Bx,78        ;{ Mivel a ket bal szelso nem kell }
  Sub  Bx,[BP+6]    ;{ Ennyi byte-ot mozgat            }
  Xor  Ax,Ax        ;{ Ezzel fogja feltolteni          }

SorCik:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,[BP+6]      ;{ Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

  Add  Si,80
  Add  Di,80

  Loop SorCik

  Pop  Ds

  Pop  Bp
  Jmp Kilep3

EScrLeft EndP


EScrRight Proc NEAR

  Push Bp
  Mov  Bp,Sp

  Push Ds

  STD

  Mov  Ax,0A000H
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,3*8*80+77 ;{ Az elso szerkesztoterulet sor utolso byte  }
  Mov  Si,Di
  Sub  Si,[BP+6]    ;{ Innen move-olja                 }

  Mov  Cx,(W39-2)*8 ;{ Ennyi pixelsor                  }
  Mov  Bx,78        ;{ Mivel a ket bal szelso nem kell }
  Sub  Bx,[BP+6]    ;{ Ennyi byte-ot mozgat            }
  Xor  Ax,Ax        ;{ Ezzel fogja feltolteni          }

SorCik2:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,[BP+6]    ;{ Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

  Add  Si,80
  Add  Di,80

  Loop SorCik2       ;{ Kovetkezo pixelsor }

  Pop  Ds
  Pop  Bp

  Jmp Kilep3

EScrRight ENDP

EzAVege:

Puffer Db 500 Dup(65)

CODE            ends

end

