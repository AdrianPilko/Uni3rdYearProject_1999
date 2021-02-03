CLASS mon_spec;

TYPE money;

ATTRIBUTE FUNCTIONS
   value( money) -> money;

METHOD FUNCTIONS
   ~ add ~ ( money X money) -> money;
   ~ sub ~ ( money X money) -> money;
   set_val( money) -> nil;

AXIOMS

END.
