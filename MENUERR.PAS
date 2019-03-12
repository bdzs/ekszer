Unit MenuErr;

Interface

Type St80= String[80];

PROCEDURE ErrorStr(Cikl : word; VAR st : string);
PROCEDURE MenuStr(szam : word; VAR szoveg : string; Irja : boolean);
Procedure Error(Num:Byte; Fn : St80);
Function  StartCh(Var WS:String):Byte;

Implementation

Uses Crt,Windowm,video,SpeakCdw;

{$IFDEF OROSZ}
  {$L MNUTX_O3.OBJ}
{$ELSE}
  {$IFDEF ANGOL}
    {$IFDEF VER3}
      {$L MNUTX_A3.OBJ}
    {$ELSE}
      {$L MNUTX_AN.OBJ}
    {$ENDIF} {nem ver3}
  {$ELSE}
    {$IFDEF VER3}
      {$IFDEF NORVEG}
        {$L MNUTX_N3.OBJ}
      {$ELSE}
        {$IFDEF ROMAN}
          {$L MNUTX_R3.OBJ}
        {$ELSE}
          {$IFDEF SZLOVAK}
            {$L MNUTX_S3.OBJ}
          {$ELSE}
            {$L MNUTX_M3.OBJ}
          {$ENDIF}  {nem szlovak}
        {$ENDIF}  {nem roman}
      {$ENDIF}  {nem norveg}
    {$ELSE}
      {$IFDEF NORVEG}
        {$L MNUTX_NN.OBJ}
      {$ELSE}
        {$IFDEF ROMAN}
          {$L MNUTX_RN.OBJ}
        {$ELSE}
          {$IFDEF SZLOVAK}
            {$L MNUTX_SN.OBJ}
          {$ELSE}
            {$L MNUTX_MN.OBJ}

          {$ENDIF}  {nem szlovak}
        {$ENDIF}  {nem roman}
      {$ENDIF} {nem norveg}

    {$ENDIF} {nem ver3}

  {$ENDIF} {nem angol}
{$ENDIF} { Orosz}

{$IFDEF OROSZ}
  {$L ERRORSO.OBJ}
{$ELSE}
  {$IFDEF ANGOL}
    {$L ERRORSA.OBJ}
  {$ELSE}
    {$IFDEF NORVEG}
      {$L ERRORSN.OBJ}
    {$ELSE}
      {$IFDEF ROMAN}
        {$L ERRORSR.OBJ}
      {$ELSE}
        {$IFDEF SZLOVAK}
          {$L ERRORSSZ.OBJ}
        {$ELSE}
          {$L ERRORSM.OBJ}
        {$ENDIF}
      {$ENDIF}
    {$ENDIF}
  {$ENDIF}
{$ENDIF} { Orosz}

PROCEDURE ErrorStr(Cikl : word; VAR st : string);  External;
PROCEDURE MenuStr(szam : word; VAR szoveg : string; Irja : boolean); External;

Procedure Error; { (Num:Byte; Fn : St80);  Forward }
Var  Ws           : String[80];
     X,Count,Spoz : Integer;
     Graphic      : Boolean;
     ScBuf        : Array[1..4800] Of Byte;
     C            : char;

Begin

  Count   := 8000;
  Graphic := (CrtMode = 6);

  If Graphic Then
  Begin
    FelSor_IdeOdaW(2,74,8,32,Ofs(ScBuf),Seg(ScBuf),SortabOffs,0);
    GrWindow(2,34,76,37,ErrorSt[ErrorStNum]);
  End
  Else
    BOOL := CREATE_WINDOW(3,19,78,21,ErrorSt[ErrorStNum],CA[DispMode,1],CA[DispMode,4]);

  GlobalErrorNum := Num;
  GlobalErrorSt  := Fn;

  ws:='';
  ErrorStr(Num,Ws);
  Ws   := Ws + Fn;
  Spoz := 40-(Length(Ws)) DIV 2;

  If Graphic Then
  Begin
    {$IFNDEF OROSZ}
    Uppercase(Ws);
    ConvertString(Ws);
    {$ENDIF}
    For X:= 1 to Length(Ws) Do
       Sys_Write(Spoz+X-1,36,Word(Ws[X]),FontOffs,SortabOffs,0);
    Inv_Line(36,4,4+69,0,sortaboffs,0);
  End
  Else
    Display(Ws,20,Spoz);

  If EnabledSpeak Then
  Begin
    If NOT (Num In [20,35..39,44..49]) Then
      Case Num Of
        42:Speak2(42,44);
        52:Speak2(52,62);
        53:Speak2(53,63);
        Else Speak(Num);
        End; { Case }
    Case Num Of
      4: Begin
           If Fn = Pr_Mess20 Then Speak(104) Else
           If Fn = InpSt3   Then Speak(105) Else
           If Fn = EleSt7   Then Speak(110) Else
           If Fn = BlSt1    Then Speak(111) Else
           If Fn = CdwFst1  Then Speak(112) Else
           If Fn = FormSt1  Then Speak(114);
         End;
     29: Speak(CLV^.Hibakod+119);
    End { Case }
  End
  Else
  Begin
    Beepel(600);
    Beepel(400);
  End;

  Cik := 20;

  If ErrorDelay = 100 Then
    Repeat
      Delay(100);
      Dec(Cik)
    Until (Cik = 0) Or KeyPressed
  Else
    Repeat
      Delay(ErrorDelay);
      Dec(Cik)
    Until Cik = 0;

  While KeyPressed Do
    C := ReadKey;

  { Esc := (Num In [15,16]); !!!!!}

  If Not Graphic Then Bool := Remove_Window
                 Else FelSor_IdeOdaW(2,74,8,32,Ofs(ScBuf),Seg(ScBuf),SortabOffs,1);

End; {Error}

Function StartCh(Var WS:String):Byte;
Var X : Byte;
Begin
  X := Pos('^',Ws);
  If X = 0 Then
    Begin
      X := 1;
      While Ws[X] = ' ' Do
        Inc(X);
    End
  Else
    Delete(Ws,X,1);
  StartCh := X;
End;


End.