CLASS tricky_def;

   INHERITS a_class FOR poly_type;

   USES oth_spc FOR some_type;
   TYPE tricky;
   ATTRIBUTE FUNCTIONS

      some_att_function (tricky) -> boolean;
   METHOD FUNCTIONS

      some_method_function (some_type X tricky) -> tricky;
      another_method_function (poly_type X tricky) -> number;
   AXIOMS
      VAR

         t : tricky;
         p : poly_type;
         s : some_type;
         g : number;


      some_att_function (some_method_function (s, self)) = true;
      some_method_function (s, t) = self;
      another_method_function (p, self) = g;
      another_method_function (self, self) = g;
      do_it (self) = 10;
      do_it (p) = 1;
END.
