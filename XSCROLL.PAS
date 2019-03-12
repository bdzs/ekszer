;------------------------------------------------- EGA -------
Procedure EScrLeft(X:Word);Assembler;
Label SorCik;
ASM
  Push Ds

  CLD

  Mov  Ax,$A000
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,3*8*80  { Az elso szerkesztoterulet sor elso byte  }
  Mov  Si,Di
  Add  Si,X       { Innen move-olja                 }

  Mov  Cx,37*8    { Ennyi pixelsor                  }
  Mov  Bx,78      { Mivel a ket bal szelso nem kell }
  Sub  Bx,X       { Ennyi byte-ot mozgat            }
  Xor  Ax,Ax      { Ezzel fogja feltolteni          }

SorCik:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,X       { Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

  Add  Si,80
  Add  Di,80
  Loop SorCik

  Pop  Ds
End;

Procedure EScrRight(X:Word);Assembler;
Label SorCik;
Asm
  Push Ds

  STD

  Mov  Ax,$A000
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,3*8*80+77 { Az elso szerkesztoterulet sor utolso byte  }
  Mov  Si,Di
  Sub  Si,X         { Innen move-olja                 }

  Mov  Cx,37*8      { Ennyi pixelsor                  }
  Mov  Bx,78        { Mivel a ket bal szelso nem kell }
  Sub  Bx,X         { Ennyi byte-ot mozgat            }
  Xor  Ax,Ax        { Ezzel fogja feltolteni          }

SorCik:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,X         { Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

  Add  Si,80
  Add  Di,80
  Loop SorCik       { Kovetkezo pixelsor }

  Pop  Ds
End;

;------------------------------------------------- CGA -------
Procedure EScrLeft(X:Word);Assembler;
Label SorCik;
ASM
  Push Ds

  CLD

  Mov  Ax,$B800
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,8752 { Az elso szerkesztoterulet sor elso byte  }
  Mov  Si,Di
  Add  Si,X       { Innen move-olja                 }

  Mov  Cx,37*5    { Ennyi pixelsor                  }
  Mov  Bx,78      { Mivel a ket bal szelso nem kell }
  Sub  Bx,X       { Ennyi byte-ot mozgat            }
  Xor  Ax,Ax      { Ezzel fogja feltolteni          }

SorCik:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,X       { Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

;  Add  Si,80
;  Add  Di,80
  
  Sub Si,2000h
  Jc Sc196
  Add Si,80h
  Jmp Short Sc197
Sc196:
  Add Si,2000h
  Add Si,2000h
Sc197:
  Sub Di,2000h
  Jc Sc198
  Add Di,80h
  Jmp Short Sc199
Sc198:
  Add Di,2000h
  Add Di,2000h
Sc199:

  Loop SorCik

  Pop  Ds
End;

Procedure EScrRight(X:Word);Assembler;
Label SorCik;
Asm
  Push Ds

  STD

  Mov  Ax,$B800
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,8752 { Az elso szerkesztoterulet sor utolso byte  }
  Mov  Si,Di
  Sub  Si,X         { Innen move-olja                 }

  Mov  Cx,37*5      { Ennyi pixelsor                  }
  Mov  Bx,78        { Mivel a ket bal szelso nem kell }
  Sub  Bx,X         { Ennyi byte-ot mozgat            }
  Xor  Ax,Ax        { Ezzel fogja feltolteni          }

SorCik:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,X         { Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

;  Add  Si,80
;  Add  Di,80
   
  Sub Si,2000h
  Jc Sc196
  Add Si,80h
  Jmp Short Sc197
Sc196:
  Add Si,2000h
  Add Si,2000h
Sc197:
  Sub Di,2000h
  Jc Sc198
  Add Di,80h
  Jmp Short Sc199
Sc198:
  Add Di,2000h
  Add Di,2000h
Sc199:

  Loop SorCik       { Kovetkezo pixelsor }

  Pop  Ds
End;

;------------------------------------------------- HERC -------
Procedure EScrLeft(X:Word);Assembler;
Label SorCik;
ASM
  Push Ds

  CLD

  Mov  Ax,$B000
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,545  { Az elso szerkesztoterulet sor elso byte  }
  Mov  Si,Di
  Add  Si,X       { Innen move-olja                 }

  Mov  Cx,37*8    { Ennyi pixelsor                  }
  Mov  Bx,78      { Mivel a ket bal szelso nem kell }
  Sub  Bx,X       { Ennyi byte-ot mozgat            }
  Xor  Ax,Ax      { Ezzel fogja feltolteni          }

SorCik:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,X       { Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

;  Add  Si,80
;  Add  Di,80

  Add  Si,2000h 
  Test Si,8000h
  Jz Sc198
  Sub Si,8000h-90
Sc198:  

  Add  Di,2000h 
  Test Di,8000h
  Jz Sc199
  Sub Di,8000h-90
Sc199:  
  
  Loop SorCik

  Pop  Ds
End;

Procedure EScrRight(X:Word);Assembler;
Label SorCik;
Asm
  Push Ds

  STD

  Mov  Ax,$B000
  Mov  Ds,Ax
  Mov  Es,Ax

  Mov  Di,545 { Az elso szerkesztoterulet sor utolso byte  }
  Mov  Si,Di
  Sub  Si,X         { Innen move-olja                 }

  Mov  Cx,37*8      { Ennyi pixelsor                  }
  Mov  Bx,78        { Mivel a ket bal szelso nem kell }
  Sub  Bx,X         { Ennyi byte-ot mozgat            }
  Xor  Ax,Ax        { Ezzel fogja feltolteni          }

SorCik:
  Push Cx
  Push Di
  Push Si

  Mov  Cx,Bx
  Repz MovsB

  Mov  Cx,X         { Ennyit kell feltolteni }
  Repz StosB

  Pop  Si
  Pop  Di
  Pop  Cx

;  Add  Si,80
;  Add  Di,80
 
  Add  Si,2000h 
  Test Si,8000h
  Jz Sc198
  Sub Si,8000h-90
Sc198:  

  Add  Di,2000h 
  Test Di,8000h
  Jz Sc199
  Sub Di,8000h-90
Sc199:  
  
  Loop SorCik       { Kovetkezo pixelsor }

  Pop  Ds
End;

