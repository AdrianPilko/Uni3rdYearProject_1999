CLASS stck_def;

   USES item_spc FOR item;

   TYPE stack;

   ATTRIBUTE FUNCTIONS

      top  (stack) -> item;
      rest (stack) -> stack;

   METHOD FUNCTIONS
      is_empty (stack)           -> boolean;
      empty    (nil)             -> stack;
      push     (stack X item)   -> stack;
      pop      (stack)           -> stack;
      
   AXIOMS

      VAR i : item;
          s : stack;
          n : nil;

      INITIAL is_empty( self) = true END;

      is_empty (empty (n))   = true;
      is_empty (push (s, i)) = false;
      pop (push (s, i))      = s;
      top (push (s, i))      = i;

END.
