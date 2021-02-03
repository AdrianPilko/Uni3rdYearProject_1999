UNIT semantic;

{
  By Adrian Pilkington
  For 3rd year project
  UMIST Dept. Of Computation

  This unit interfaces with symbol table (hash_tab.tpu) and allows
  the checking of result and argument types for functions match the
  previous declaration
}

INTERFACE

FUNCTION argument_of_current(function_name : string;
                             argument_number : integer) : string;

FUNCTION result_of_current(identifier_name : string) : string;

FUNCTION is_type_conformant( type_1 : string;
                             type_2 : string ) : boolean;

IMPLEMENTATION

USES hash_tab;

FUNCTION argument_of_current(function_name : string;
                             argument_number : integer) : string;
VAR temp_argument_type : string;

BEGIN
   find_argument_type(function_name,argument_number, temp_argument_type);
   argument_of_current := temp_argument_type
END;

FUNCTION result_of_current(identifier_name : string) : string;

VAR temp_result_type : string;

BEGIN
   find_result_type(identifier_name, temp_result_type);
   result_of_current := temp_result_type
END;

FUNCTION is_type_conformant( type_1 : string;
                             type_2 : string ) : boolean;
BEGIN
   IF type_1 = type_2 THEN is_type_conformant := true
   ELSE
   IF type1_subtype_of_type2(type_1, type_2) THEN is_type_conformant := true
   ELSE
      is_type_conformant := false
END;

BEGIN

END.
