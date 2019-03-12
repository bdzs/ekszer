unit bgi;

interface

procedure SetPaletta(ik, erre: word);  {ik-edik szint erre-valtja}
Procedure Set256Pal(Color,R,G,B:Byte);
procedure SetGraphMod(gr_card: word);  {gr_card-ot a max. grafikus felbontasra allitja}
Procedure SetPlane(X:Byte);
procedure ega_hatter(i:byte);
procedure set_ega_color(i: byte);  {grafikusra atallas utan hivando}

implementation

uses dos,Graph;


procedure ch_to_text; external;
procedure ch_to_graf; external;
{$L herc-gr.obj}

procedure SetPaletta(ik, erre: word);

Var regs: registers;

begin
  regs.ax := $1000;
  regs.bl := ik;
  regs.bh := erre;
  intr($10,regs)
end;

Procedure Set256Pal(Color,R,G,B:Byte);Assembler;
Asm
  MOV AL,10H
  MOV AH,10H
  MOV BL,[Color]
  MOV DH,[R]
  MOV CL,[B]
  MOV CH,[G]
  XOR BH,BH
  INT 10H
End;


Procedure SetGraphMod(gr_card: word);

Var regs: registers;
    hscr: array[1..$8000] of byte absolute $b000:0;

    CMM : boolean;
    int99ofs : word absolute $0000:$99*4;
    int99seg : word absolute $0000:$99*4 + 2;

Begin

  case gr_card of
    cga: Begin
           regs.ax := 6;
           intr($10, regs);
         End;
    ega, ega64:
         Begin
            regs.ax := $10;
            intr($10,regs);
          End;
    VGA: Begin
            regs.ax := $12;
            intr($10,regs);
          End;
    egamono:
          Begin
            regs.ax := $0f;
            intr($10,regs);
          End;
    hercmono:
          Begin
            CMM := ((mem[int99seg:int99ofs-2] = byte('I')) and
                     (mem[int99seg:int99ofs-1] = byte('F')));
            ch_to_graf;

            if CMM then mem[int99seg:int99ofs+5] := 1;   {CMM-nek jelolni,hogy graf}
            mem[$b000:0]:=0;
            fillchar(hscr,$8000,0);
          End;
  end;

End;

Procedure SetPlane(X:Byte);Assembler;
Var B : Byte;
Label Next1,Next2;
Asm
  Mov Dx,3c4H
  Mov Al,2
  Out Dx,Al
  Jmp Next1
Next1:
  Mov Dx,3c5H
  Mov Al,[X]
  Out Dx,Al
  Jmp Next2
Next2:
End;

procedure ega_hatter(i:byte);

begin
  SetPaletta(0,i);         {FI}
end;

procedure set_ega_color(i: byte);  {grafikusra atallas utan hivando}

begin
  SetPaletta(15,i);       {FI}
end;



End.