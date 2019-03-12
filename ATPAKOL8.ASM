; CDW kep nyomtatashoz 8-tus atpakolo
; TP5-hoz TASM formatumban
;
.MODEL TPASCAL
.CODE

public atpakol8
public buffnegal
public buffnegalw


ATPAKOL8 proc near tombcim: dword, fontcim: dword, xnovel: word,  xmennyit: word, ymagas: word, ymennyit: word
;                    mutato         mutato     tomb max. szelessege               10/20          5/10
;                                                                 byte-okban

      push ds
      push es

      cld

      lds  si,tombcim
      les  di,fontcim
      add  di,158h      ; '!'  elso sora

nagyhur:
      push di
      push si
      mov cx,xmennyit   ; hany byte-ot atrakni vizszintesen
 kishur:
      mov ax,ds:[si]  ; AX := elso es masodik byte balra igazitva
      inc SI          ;
      mov es:[di],ax  ; ES:DI = elso ket byte
      add DI,ymagas

      dec cx
      jz kishur_vege
      lodsw           ; AX := masodik es harmadik byte, jobbra igazitva

      shl ah,1
      rcl al,1
      shl ah,1
      rcl al,1
      shl ah,1
      rcl al,1
      shl ah,1
      rcl al,1
      mov es:[di],ax
      add DI,ymagas
      dec cx
      jz kishur_vege
      dec cx            ; !!!!!!! 3-byte-bol 2 karakter sor
      jnz kishur

  kishur_vege:
      pop si
      pop di
      add di,2        ; next char line
      add si,xnovel
      dec ymennyit
      jnz nagyhur

      pop es
      pop ds
      ret

atpakol8 endp
;---------------------------------------
buffnegal proc near  puffercim: dword,  hossza: word

         les di,puffercim
         mov cx,hossza

     bnhur:  not byte ptr es:[di]
             inc di
             loop bnhur
             ret

buffnegal endp

buffnegalw proc near  puffercim: dword,  hossza: word

         les di,puffercim
         mov cx,hossza
         shr cx,1

     bnhurw:  not word ptr es:[di]
              inc di
              inc di
              loop bnhurw
              ret

buffnegalw endp

       END