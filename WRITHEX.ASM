      (*
      Push Cs
      Pop  Ds

      Mov  Ah,$48
      Mov  Bx,$FFFF
      Int  $21

      Mov  Si,Offset LargestBlock
      Lodsw

      Push Es
      Push Ax
      Push Bx
      Push Di

      Push Ax
      Push Bx
      Mov  Ax,$B800
      Mov  Es,Ax
      Mov  Di,0
      Pop  Bx

      Mov  Ax,Bx
      Mov  Cx,12
      Shr  Ax,Cl
      And  Al,15
      Cmp  Al,9
      Jle  K1
      Add  Al,7
      K1:
      Add  Al,48
      Stosb
      Inc  Di
      Mov  Ax,Bx
      Mov  Cx,8
      Shr  Ax,Cl
      And  Al,15
      Cmp  Al,9
      Jle  K2
      Add  Al,7
      K2:
      Add  Al,48
      Stosb
      Inc  Di
      Mov  Ax,Bx
      Mov  Cx,4
      Shr  Ax,Cl
      And  Al,15
      Cmp  Al,9
      Jle  K3
      Add  Al,7
      K3:
      Add  Al,48
      Stosb
      Inc  Di
      Mov  Ax,Bx
      And  Al,15
      Cmp  Al,9
      Jle  K4
      Add  Al,7
      K4:
      Add  Al,48
      Stosb
      Inc  Di

      Pop  Bx
      Inc  Di
      Inc  Di

      Mov  Ax,Bx
      Mov  Cx,12
      Shr  Ax,Cl
      And  Al,15
      Cmp  Al,9
      Jle  K5
      Add  Al,7
      K5:
      Add  Al,48
      Stosb
      Inc  Di
      Mov  Ax,Bx
      Mov  Cx,8
      Shr  Ax,Cl
      And  Al,15
      Cmp  Al,9
      Jle  K6
      Add  Al,7
      K6:
      Add  Al,48
      Stosb
      Inc  Di
      Mov  Ax,Bx
      Mov  Cx,4
      Shr  Ax,Cl
      And  Al,15
      Cmp  Al,9
      Jle  K7
      Add  Al,7
      K7:
      Add  Al,48
      Stosb
      Inc  Di
      Mov  Ax,Bx
      And  Al,15
      Cmp  Al,9
      Jle  K8
      Add  Al,7
      K8:
      Add  Al,48
      Stosb
      Inc  Di

      Pop  Di
      Pop  Bx
      Pop  Ax
      Pop  Es

      Cmp  Ax,Bx

      Jz   Dosbol
      Jmp  Ok

      Dosbol:

      *)
