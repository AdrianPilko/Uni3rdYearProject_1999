CLASS btr_spc;


   USES item_spc FOR item;

   TYPE btree;

   ATTRIBUTE FUNCTIONS
      left (btree) -> btree;
      right (btree) -> btree; 
      root (btree) -> item;
   METHOD FUNCTIONS

      empty_btree (nil) -> btree;
      empty (btree) -> boolean;
      push_btree (item X btree X btree) -> btree;

   AXIOMS
      VAR

         i : item;
         l : btree;
         r : btree;
         n : nil;

      empty (empty_btree (n))      = false;
      empty (push_btree (i, l, r)) = false;
      root (push_btree (i, l, r))  = i;
      left (push_btree (i, l, r))  = l;
      right (push_btree (i, l, r)) = r;
END.