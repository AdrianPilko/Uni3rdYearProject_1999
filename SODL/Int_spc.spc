CLASS int_spc;

INHERITS num_spec FOR number;

TYPE integer;

ATTRIBUTE FUNCTIONS
   display( integer) -> string;

METHOD FUNCTIONS
   pred ( integer) -> integer;
   succ ( integer) -> integer;
   ~ add ~ ( integer X integer) -> integer;
   ~ sub ~ ( integer X integer) -> integer;
   ~ multiply ~ ( integer X integer) -> integer;
   ~ square ~ ( integer X integer) -> integer;
   ~ cube ~ ( integer X integer) -> integer;

AXIOMS

END.

