CLASS true_def;

   INHERITS bool_spc FOR boolean;

   TYPE true;

   ATTRIBUTE FUNCTIONS

   METHOD FUNCTIONS
      ~ and ~ (boolean X boolean) -> boolean;
      ~ or ~ (boolean X boolean) -> boolean;
      ~ implies ~ ( boolean X boolean) -> boolean;

   AXIOMS
      VAR x : boolean;

      true and x = x;
      false and x = false;
      true or x = true;
      false or x = x;
      false implies true = true;
      false implies false =true;
      true implies false = false;
      true implies true = true;
      true and false = true;
      true or false = true;
END.