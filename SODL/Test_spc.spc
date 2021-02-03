CLASS test_spc;

   INHERITS num_spec FOR number;

   TYPE test;

   ATTRIBUTE FUNCTIONS
       value (test) -> test;

   METHOD FUNCTIONS
       ~ add ~ (test X test) -> test;

   AXIOMS
       VAR a : test;
           b : test;
           c : number;

     INITIAL value (self) = 0 END;
     c add c = c;   
     a add b = c;
END.
