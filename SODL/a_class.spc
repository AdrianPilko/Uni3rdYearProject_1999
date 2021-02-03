CLASS a_class;
INHERITS oth_spc FOR some_type;

   TYPE poly_type;
   ATTRIBUTE FUNCTIONS

   METHOD FUNCTIONS

      do_it (poly_type) -> number;
   AXIOMS
      VAR

         p : poly_type;
      INITIAL         
         do_it (p) = 0 
      END;

END.
