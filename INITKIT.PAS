Unit INITKIT;

Interface

Uses Dos;

const
     on           = true;
     off          = false;
     dir_nagysag  = 400 ;

type

     st4 = String[4];
     ST       = STRING[30];
     ST8      = STRING[8];
     ST5      = STRING[5];
     st12     = STRING[12];
     ST20     = STRING[20];
     ST40     = STRING[40];
     st80     = string[80];
     st81     = string[81];
     st160    = string[160];
     st255    = string[255];


     nevtomb  = array[1..dir_nagysag] of st12;
     attrtomb = array[1..dir_nagysag] of byte;

var
     register : registers;
     press    : boolean;

Implementation

End.