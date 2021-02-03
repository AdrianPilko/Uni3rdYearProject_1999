CLASS acc_spc;

USES person_d FOR person;
USES mon_spec FOR money;

TYPE account;

ATTRIBUTE FUNCTIONS
   balance_of (account) -> money;
   holder_of (account) -> person;
   overdraft (account) -> money;
   acc_number (account) -> number;

METHOD FUNCTIONS
   open (person X money) -> account;
   close (account) -> nil;
   credit (account X money) -> account;
   debit (account X money) -> account;
   set_overdraft (account X money) -> account;

AXIOMS
   VAR m  : money;
       ov : money;
       p  : person;
 
   INITIAL open (p, ov) = self
   END;

   balance_of (credit (self, m)) = balance_of (self) add m;
   balance_of (debit (self, m)) = balance_of (self) sub m;
   overdraft (set_overdraft (self, ov)) = overdraft (self);
END.