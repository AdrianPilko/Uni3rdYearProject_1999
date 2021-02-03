CLASS person_d;


   TYPE person;
   ATTRIBUTE FUNCTIONS

      name( person) -> string;
      address( person) -> string;
      phone_no( person) -> number;
   METHOD FUNCTIONS

      edit_name( person X string) -> person;
      edit_address( person X string) -> person;
      edit_phone_no( person X number) -> person;
      display (person) -> person;
   AXIOMS

END.