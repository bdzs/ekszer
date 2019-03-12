{****************** Az EkSzer magyar vonatkozasu reszei ***************}


{ ********** Menu system types, constans and variables *********** }

Type  MnRec = Record
                Start  : Byte; { Kde sa zacina v mnozine textov.
                                 Netreba zadat, InitMenu vyplni          }
                MemNum : Byte; { Pocet bodov menu                        }
                Xp     : Byte; {\                                        }
                Yp     : Byte; {-- Suradnice                             }
                Xp2    : Byte; {--                                       }
                Yp2    : Byte; {/                                        }
                Co     : Byte; { Atributy okna                           }
                Co2    : Byte; { Atributy ramecku                        }
                Co3    : Byte; { Atribut prveho znaku                    }
                Typ    : (hor,ver); { Vodorovne alebo zvisle menu        }
                P      : Byte; { Z ktorej menu bolo meno aktivovane      }
              End;

Const
       CurColor : Array[DispType] Of Byte = (63,112); { Farba kurzora menu  }

{$IFDEF CHEM}

       MpNum         = 120;  {  Celkovy pocet menu                     }

{$ELSE}

       MpNum         = 119;  {  Celkovy pocet textov menu              }

{$ENDIF}

       MenuNum       =  15;  {  Celkom menu     (aj hlavne           ) }

       MenuStr : Array[1..MpNum] of string[20] =    { Texty menu     }

                        {1. Main Menu }
('Edit cia','Mazanie','Nac¡tanie','Ulozenie','Zmena','Tlac','S£bor,'Koniec',

       'Dokument',      {2. Edit}
       'Buffer',
       'H.z hlavie',
       'D.z hlavie ',

       'Dokument  ',      {3. Delete}
       'Buffer',
       'H.z hlavie',
       'D.z hlavie',

       'Dokument',       {4. Load}
       'Blok buffer',
       'Parameter',
       'ASCII s£bor',
       'WordStar s£bor',
       'H.z hl-D.z hl',
       'Makro s£bor',

       'Dokument',       {5. Save}
       'Blok buffer',
       'Konfigur cia',
       'Parameter',
       'ASCII s£bor',
       'Ventura s£bor',
       'H.z hl-D.z hl ',
       'Makr ',

       'Prac. adres r',    {6. Change}
       'Znakov  sada',
       'Parametre',
       'ProTex adres r',
       'Rozs¡renie:     ',
       'Editor:         ',
       'Typ:            ',
       'Display:   Color',

       'Rychl',          {7. Print}
       'Norm l',
       'Dopisov ',
       'P¡sacy stroj',
       'Opcie',
       'Obezn¡ky',

       'Directory',        {8. File}
       'Erase',
       'Rename',
       'Copy',

       'Dlzka str n      170',   {9. Change Parameters}
       'Riadkovanie       50',
       'Doba ulozenia   9999',
       'Pocet impulzov  1000',
       'P¡saci stroj        ',
       'Tlaciaren           ',

       'Prv  strana        1',  {10. Print Options}
       'Posledn  strana 9999',
       'Cislovat od        1',
       'Pausa              1',
       'Lavy okraj         6',
       'Kopie              1',
       'Eject            Zap',
       'Vzdial.st¡tkov  1.00',

       'Seriov  linka   COM1',
       'Paraleln  linka LPT1',
       'Casovanie         10',

                        {11. Edit headers   }
'Vsetky','P rne','Nep rne',' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9',
                        {12. Edit footers   }
'Vsetky','P rne','Nep rne',' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9',
                        {13. Delete headers }
'Vsetky','P rne','Nep rne',' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9',
                        {14. Delete footers }
'Vsetky','P rne','Nep rne',' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9',


       'Databanka:    Nie je',         {15. Obezniky    }
       'Z znam              ',
       'Podmienky vyberu    ',
       'Naplnenie podmienok ',
       'Ulozenie            '

 );

       NewMenu  : Array[1..MpNum] of Byte =
          {  Z ktoreho menu do ktoreho vstupime           .
             Ak je to     0,   menu nema dalsie submenu            }

                     {Edit}
  (2,3,4,5,6,7,8,0,  0,0,11,12, 


  {Delete}       {Load}            {Save}
  0,0,13,14,   0,0,0,0,0,0,0,   0,0,0,0,0,0,0,0,

     {Change}          {Print}       {File}    {chg par}  {pr. opt}
    0,0,9,0,0,0,0,0,  0,0,0,0,10,15, 0,0,0,0,  0,0,0,0,0,0, 0,0,0,0,0,0,0,0,0,0,0,

                     0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,

                     0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,

                     0,0,0, 0,0 );

       ShowLine : Array[1..MpNum] of Byte =
          { Fuggoleges menu eseten ez tartalmazza azt, hogy a menupontok
            hanyadik sorban jelenjenek meg. Az ablak legelso sora = 1.
            Vizszintes menu eseten a menupont x pozicioja az ablakban,
            Ezt az InitMenu rutin automatikusan beallitja }

                     {Edit}
 (0,0,0,0,0,0,0,0,  2,3,4,5, 

   {Delete}      {Load}             {Save}
   2,3,4,5,    2,3,4,5,6,7,8,     2,3,4,5,6,7,8,9,

       {Change}     {Print}     {File}    {chg par}       {pr. opt}
 2,3,4,5,6,7,8,9,  2,3,4,5,6,8, 2,3,4,5, 2,3,4,5,7,8,   2,3,4,5,6,7,8,9,
                                                           11,12,13,

                     0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,

                     0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,

                     { K”rlevelez‚s }

                     2,3,4, 6,7 );

       MenuRec : Array[1..MenuNum] Of MnRec =(
       { Ezek a rekordok a menuk adatait tartalmazzak. Ld. az MnRec leirast }

    (Start  :  1;    { Fomenu  1 }
     MemNum :  8;
     Xp     :  1;
     Yp     :  1;
     Xp2    : 80;
     Yp2    :  3;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :hor;
     P      :  0),

    (Start  :  0;    { Edit    2 }

     MemNum :  4;
     Xp     :  1;
     Yp     :  3;
     Xp2    : 16;
     Yp2    : 10;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    : ver;
     P      :  1),

    (Start  :  0;    { Delete  3 }
     MemNum :  4;
     Xp     : 10;
     Yp     :  3;
     Xp2    : 25;
     Yp2    : 10;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :ver;
     P      :  1),

    (Start  :  0;    { Load   4 }
     MemNum :  7;
     Xp     : 30;
     Yp     :  3;
     Xp2    : 51;
     Yp2    : 13;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :ver;
     P      :  1),

    (Start  :  0;    { Save  5 }
     MemNum :  8;
     Xp     :  1;
     Yp     :  3;
     Xp2    : 22;
     Yp2    : 14;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :ver;
     P      :  1),

    (Start  :  0;    { Change 6 }
     MemNum :  8;
     Xp     : 10;
     Yp     :  3;
     Xp2    : 30;
     Yp2    : 14;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :ver;
     P      :  1),

   (Start   :  0;    { Print  7 }
    MemNum  :  6;
    Xp      : 30;
    Yp      :  3;
    Xp2     : 48;
    Yp2     : 13;
    Co      : 31;
    Co2     : 15;
    Co3     : 23;
    Typ     :ver;
    P       :  1),

   (Start   :  0;    { File   8 }
    MemNum  :  4;
    Xp      : 50;
    Yp      :  3;
    Xp2     : 65;
    Yp2     : 10;
    Co      : 31;
    Co2     : 15;
    Co3     : 23;
    Typ     :ver;
    P       :  1),

    (Start  :  0;    { Change parameters   9 }
     MemNum :  6;
     Xp     : 35;
     Yp     :  6;
     Xp2    : 59;
     Yp2    : 16;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :ver;
     P      :  6),

    (Start  :  0;    { Printer options    10 }
     MemNum : 11;
     Xp     : 52;
     Yp     :  4;
     Xp2    : 76;
     Yp2    : 19;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :ver;
     P      :  7),


    (Start  :  0;    { Edit headers       11 }
     MemNum : 12;
     Xp     : 07;
     Yp     :  4;
     Xp2    : 73;
     Yp2    : 06;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :hor;
     P      :  2),

    (Start  :  0;    { Edit footers       12 }
     MemNum : 12;
     Xp     : 07;
     Yp     :  6;
     Xp2    : 73;
     Yp2    : 08;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :hor;
     P      :  2),

    (Start  :  0;    { Delete headers     13 }
     MemNum : 12;
     Xp     : 07;
     Yp     :  4;
     Xp2    : 73;
     Yp2    : 06;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :hor;
     P      :  3),

    (Start  :  0;    { Delete footers     14}
     MemNum : 12;
     Xp     : 07;
     Yp     :  6;
     Xp2    : 73;
     Yp2    : 08;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :hor;
     P      :  3),

     (Start  :  0;    { K”rlevelez‚s    15 }
     MemNum :  5;
     Xp     : 54;
     Yp     :  5;
     Xp2    : 78;
     Yp2    : 14;
     Co     : 31;
     Co2    : 15;
     Co3    : 23;
     Typ    :ver;
     P      :  7)

);

{********************** Menu system end ************************}
