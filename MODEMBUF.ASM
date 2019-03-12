; serial port: interrupt controlled input

pic_mask equ 21h  ; 8259 mask register
pic_eoi  equ 20h  ; 8259 end of interrupt instr

code segment byte public
     assume cs:code, ds: code, es:code, ss:code

     public INT_0FFH
     public comm_data

;-------------------------------------------------
com_stat proc near  ; check status
                    ; ax <> 0, if char ready
                    ; ax  = 0, if nothing waiting

   mov ax,[asc_in]  ; compare ring buffer pointers
   sub ax,[asc_out]

   ret

com_stat endp
;--------------------------------------------------

com_in proc near    ; get a char from asynch buffer
                    ; if no char waiting: loop until one arrives

    push bx

com_in1:
    mov bx,[asc_out]
    cmp bx,[asc_in]
    je com_in1      ; if equal: nothing in

    mov al,[bx+asc_buf]
    inc bx
    cmp bx,asc_buf_len
    jne com_in2
    xor bx,bx       ; az elejere mutat ujra

com_in2:
    mov [asc_out],bx
    pop bx
    ret

com_in endp
;--------------------------------------------

com_out proc near   ; write char in AL to COM1 port

   push dx
   push ax
   mov dx,CS:[comm_stat]  ; lehet irni?

com_out1:
   in al,dx
   and al,20h
   jz com_out1   ; meg nem
   pop ax
   mov dx,CS:[comm_data]
   out dx,al
   pop dx
   ret

com_out endp
;--------------------------------------------------

asc_enb proc near   ; set up COMM1 interrupt vector

   mov ah,35h   ; get address
   mov al,cs:[com_int]  ; = 0ch
   int 21h
   mov intc_seg,es
   mov intc_offs,bx

   mov dx,offset asc_int  ; uj cim
   mov ah,25h
   mov al,cs:[com_int]  ; = 0ch
   int 21h

   mov dx,CS:[comm_mcr] ; modem controller DTR, RTS, OUT2
   mov al,0bh
   out dx,al

   mov dx,CS:[comm_ier]   ; interrupt enable register
   mov al,1
   out dx,al

   in al,pic_mask ; read current 8259a int mask
   Mov  Ah,Cs:[Int_mask]
   xor  Ah,0FFH
   and al,Ah ; reset for this comm port
   out pic_mask,al

   ret

asc_enb  endp
;--------------------------------------------------------

asc_dsb proc near   ; disable int and release vektor

     in al,pic_mask
     or al,cs:[int_mask]
     out pic_mask,al

     push ds
     mov dx,intc_offs
     mov ds,intc_seg
     mov ah,25h
     mov al,cs:[com_int]
     int 21h
     pop ds
     ret

asc_dsb endp
;----------------------------------------------------------

asc_int proc far   ; interrupt service rutin

  push ax
  push bx
  push dx
  push ds
  mov ax,cs
  mov ds,ax
  mov dx,CS:[comm_data]
  in al,dx         ; beolvassa
  mov bx,asc_in    ; pointer
  mov [asc_buf+bx],al ; elrak
  inc bx
  cmp bx,asc_buf_len  ; vege?
  jne asc_int1
  xor bx,bx           ; akkor ujra az eleje

asc_int1:
  mov asc_in,bx
  sti
  mov al,20h
  out pic_eoi,al
  pop ds
  pop dx
  pop bx
  pop ax
  iret

asc_int endp
;-------------------------------------------------

;--------------------------------------------------
int_0ffh proc near    ; ez a kezelo interrupt

    sti     ; ha kozben bejon valami!

    push ds
    push dx

    mov dx,cs
    mov ds,dx

stat:
    cmp ah,0
    jnz read
    call com_stat
    jmp short ki

read: cmp ah,1
      jnz write
      call com_in
      jmp short ki

write:  cmp ah,2
        jnz open
        call com_out
        jmp short ki

open: cmp ah,3
      jnz close
      mov word ptr [asc_in],0    ; tiszta lappal indulni
      mov word ptr [asc_out],0
      call asc_enb
      jmp short ki

close: cmp ah,4
       jnz ki
       call asc_dsb

ki:
    pop dx
    pop ds

    iret

int_0ffh endp
;---------------------------------------------------

intc_offs dw 0
intc_seg  dw 0

asc_in    dw 0
asc_out   dw 0

comm_data  dw 03f8h   ; COM1

comm_ier   dw 03f9h
comm_mcr   dw 03fch
comm_stat  dw 03fdh
Com_Int    DB 0cH
int_mask   DB 10h      ; mask for 8259, IRQ4


asc_buf_len equ 100h          ; 256 Byte-os puffer!

asc_buf db 100h+1 dup (0)

;----------------------------------------------------

   code ends
        end