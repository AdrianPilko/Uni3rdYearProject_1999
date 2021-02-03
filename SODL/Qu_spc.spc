CLASS qu_spc;

   USES item_spc FOR item;
   TYPE queue;

   ATTRIBUTE FUNCTIONS

      first     (queue)        -> item;
      rest_of_q (queue)        -> queue;

   METHOD FUNCTIONS

      is_empty (queue)        -> boolean;      
      en_queue (item X queue) -> queue;
      de_queue (queue)        -> queue;
      empty    (nil)          -> queue;

   AXIOMS
      VAR i : item;
          j : item;
          q : queue;
          n : nil;

      is_empty (empty (n)) = true;
      is_empty (en_queue (i, q)) = false;
      first (en_queue (i, en_queue (j, q))) = first (en_queue (i, q));
      de_queue (en_queue (i, empty (n))) = empty (n);
      de_queue (en_queue (i, en_queue (j, q))) = 
                en_queue (i, de_queue (en_queue (j, q)));
END.
