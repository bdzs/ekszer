
;ÚÄÄÄÄÄÄÄÄÄÄÄ¿
;³ BITFORGAT ³ nyomtat¢ fggoleges tminta el” ll¡t sa v¡zszintes mint b¢l
;ÀÄÄÄÄÄÄÄÄÄÄÄÙ

; BITSOR = ARRAY[0..7] of BYTE
; minden input byte els” bitje az els” output byte-ba kerl
; fentr”l lefel‚, ha irany  = true
; lentrol felfele, ha irany = false
;
; procedure BITFORGAT(var EZT:BITSOR, ERRE:BITSOR, IRANY:boolean); external;

public BITFORGAT

.model tpascal
.code

BITFORGAT proc near  EZT:dword, ERRE:dword, IRANY:byte

        cld   ; felfele novelni stosb utan!

        push ds
        lds  si,EZT   ; 1. tomb cime
        les  di,ERRE  ; 2. tomb cime

        mov cx,8  ; kulso hurok

   kulsohur:
        push cx
        xor bx,bx     ; cimzes eltolas: 0
        cmp IRANY,1   ; merre kell tolni?
        je belsohur2

   belsohur1:
        shl byte ptr ds:[si+bx],1  ; eggyel balra
        rcr al,1
        inc bx
        cmp bl,7          ; ez az utso
        jbe belsohur1     ; belso hurok
        stosb             ; elrak al-t es:[di]-be, INC DI
        jmp nextkulso

   belsohur2:
        shl byte ptr ds:[si+bx],1  ; eggyel balra
        rcl al,1
        inc bx
        cmp bl,7          ; ez az utso
        jbe belsohur2     ; belso hurok
        stosb             ; elrak al-t es:[di]-be, INC DI

  nextkulso:
        pop cx
        loop kulsohur

        pop ds
        ret

BITFORGAT endp
          end