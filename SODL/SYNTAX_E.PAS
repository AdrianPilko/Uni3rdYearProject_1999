PROGRAM syntax_directed_editor;
{
  By Adrian Pilkington
  For 3rd year project
  UMIST Dept. Of Computation

  A syntax directed editor for the language SODL (Simple Object Description
  Language. Allows user to input a specification using the preset synatctic
  template, then unparse to a textual representation. Uses the notion of
  nested hierarchical regions as a means for representing the abstract
  syntax of the specification
}


USES region, crt;

CONST
      move_up_char   = 'a';
      move_down_char = 'z';
      return_to_top  = 'ª';
      jump_10_down    = 'x';
      jump_10_up      = 's';
      want_to_edit   = #09;
      want_to_insert = '\';
      exit_char      = 'q';
      un_parse       = 'u';
      reset_editor   = 'r';
TYPE
   method_func_type = (decorated, standard);

VAR
   inherits_index      : integer;
   uses_index          : integer;
   first_uses          : boolean;
   first_inherits      : boolean;
   first_var_list      : boolean;
   first_initial       : boolean;
   first_initial_axiom : boolean;
   attribute_index     : integer;
   method_index        : integer;
   var_list_index      : integer;
   initial_index       : integer;
   initial_axiom_index : integer;
   axiom_index         : integer;
   type_id             : string;


PROCEDURE init_editor;
VAR class_id,
    carrier_type_id :string;

BEGIN
   class_id := '<class_id>';
   carrier_type_id := '<type_id>';
   type_id := '<type_id>';
   first_uses := true;
   first_inherits  := true;
   first_var_list := true;
   first_initial := true;
   first_initial_axiom := true;
   inherits_index := 6;
   uses_index := 7;
   attribute_index:= 14;
   method_index := 17;
   var_list_index := 20;
   initial_index := 21;
   axiom_index := 22;
   new_tree;
   new_region('',vert,1,abs,false,false); {1}
   new_subregion('',horiz,1,abs,false,false); {2}
   new_subregion('CLASS ',horiz,2,prim,true,false); {3}
   new_region(class_id,horiz,3,prim,true,true); {4}
   new_region(';',horiz,4,prim,true,false); {5}

   new_region('inherits',horiz,2,abs,false,true);      {6}

   new_region('uses',vert,6,abs,false,true);      {7}

   new_region('',vert,7,abs,false,false);      {8}
   new_subregion('   TYPE ',horiz,8,prim,true,false); {9}
   new_region(carrier_type_id,horiz,9,prim,true,true);  {10}
   new_region(';',horiz,10,prim,true,false); {11}

   new_region('attribute',vert,8,abs,false,false);      {12}
   new_subregion('   ATTRIBUTE FUNCTIONS',horiz,12,prim,true,false); {13}
   new_region('attribute',vert,13,abs,false,true);      {14}

   new_region('method',vert,12,abs,false,false);      {15}
   new_subregion('   METHOD FUNCTIONS',horiz,15,prim,true,false); {16}
   new_region('method',vert,16,abs,false,true);  {17}

   new_region('axiom',vert,15,abs,false,false);      {18}
   new_subregion('   AXIOMS',horiz,18,prim,true,false); {19}
   new_region('var_list',vert,19,abs,false,true); {20}
   new_region('initial',vert,20,abs,false,true);      {21}
   new_region('axiom',vert,21,abs,false,true);  {22}

   new_region('',vert,18,abs,false,false);      {23}
   new_subregion('END',horiz,23,prim,true,false); {24}
   new_region('.',horiz,24,prim,true,false); {25}
   create_list
END;

PROCEDURE insert_inherits;
VAR temp_index : integer;
    inherited_class_id : string;
BEGIN
   inherited_class_id := '<class_id>';
   IF first_inherits THEN
   BEGIN
      new_subregion('inherits',horiz,inherits_index,abs,false,false);
      inherits_index := region_count;
      first_inherits := false;
      temp_index := inherits_index;
      new_subregion('   INHERITS ',horiz,temp_index,prim,true,false);
      new_region(inherited_class_id,horiz,temp_index+1,prim,true,true);
      new_region(' FOR ',horiz,temp_index+2,prim,true,false);
      new_region(type_id,horiz,temp_index+3,prim,true,true);
      new_region(';',horiz,temp_index+4,prim,true,false)
   END
   ELSE
      writeln('only single inheritance supported')
END;

PROCEDURE insert_uses;
VAR uses_class_id,
    used_type_id : string;
    temp_index : integer;
BEGIN
   uses_class_id := '<class_id>';
   used_type_id := '<type_id>';
   IF first_uses THEN
   BEGIN
      new_subregion('uses',horiz,uses_index,abs,false,false);
      uses_index := region_count;
      first_uses := false
   END
   ELSE
   BEGIN
      new_region('uses',horiz,uses_index,abs,false,false);
      uses_index := region_count;
   END;
   temp_index := uses_index;
   new_subregion('   USES ',horiz,temp_index,prim,true,false);
   new_region(uses_class_id,horiz,temp_index+1,prim,true,true);
   new_region(' FOR ',horiz,temp_index+2,prim,true,false);
   new_region(used_type_id,horiz,temp_index+3,prim,true,true);
   new_region(';',horiz,temp_index+4,prim,true,false)
END;

PROCEDURE insert_attribute_func_def;
VAR  temp_index : integer;
BEGIN
   new_region('attribute',horiz,attribute_index,abs,false,false);
   attribute_index := region_count;
   temp_index := attribute_index;
   new_subregion('      ',horiz,temp_index,prim,true,false);
   new_region('<function_id>',horiz,temp_index+1,prim,true,true);
   new_region(' (',horiz,temp_index+2,prim,true,false);
   new_region(type_id,horiz,temp_index+3,prim,true,true);
   new_region(')',horiz,temp_index+4,prim,true,false);
   new_region(' -> ',horiz,temp_index+5,prim,true,false);
   new_region('<result_type_id>',horiz,temp_index+6,prim,true,true);
   new_region(';',horiz,temp_index+7,prim,true,false)
END;

PROCEDURE insert_method_func_def(this_func_type : method_func_type);
VAR  temp_index : integer;
BEGIN
   IF this_func_type = standard THEN
   BEGIN
      new_region('method',horiz,method_index,abs,false,false);
      method_index := region_count;
      temp_index := method_index;
      new_subregion('      ',horiz,temp_index,prim,true,false);
      new_region('<function_id>',horiz,temp_index+1,prim,true,true);
      new_region(' (',horiz,temp_index+2,prim,true,false);
      new_region(type_id,horiz,temp_index+3,prim,true,true);
      new_region(')',horiz,temp_index+4,prim,true,false);
      new_region(' -> ',horiz,temp_index+5,prim,true,false);
      new_region('<result_type_id>',horiz,temp_index+6,prim,true,true);
      new_region(';',horiz,temp_index+7,prim,true,false)
   END
   ELSE
   BEGIN
      new_region('method',horiz,method_index,abs,false,false);
      method_index := region_count;
      temp_index := method_index;
      new_subregion('      ',horiz,temp_index,prim,true,false);
      new_region('~ ',horiz,temp_index+1,prim,true,false);
      new_region('<function_id>',horiz,temp_index+2,prim,true,true);
      new_region(' ~ ',horiz,temp_index+3,prim,true,false);
      new_region(' (',horiz,temp_index+4,prim,true,false);
      new_region('<type_id>',horiz,temp_index+5,prim,true,true);
      new_region(' X ',horiz,temp_index+6,prim,true,false);
      new_region('<type_id>',horiz,temp_index+7,prim,true,true);
      new_region(')',horiz,temp_index+8,prim,true,false);
      new_region(' -> ',horiz,temp_index+9,prim,true,false);
      new_region('<result_type_id>',horiz,temp_index+10,prim,true,true);
      new_region(';',horiz,temp_index+11,prim,true,false)
   END
END;

PROCEDURE insert_var_list;
VAR temp_index : integer;
    type_id,
    var_id : string;
BEGIN
   type_id := '<type_id>';
   var_id := '<var_id>';
   IF first_var_list THEN
   BEGIN
      new_subregion('      VAR',horiz,var_list_index,prim,true,false);
      var_list_index := region_count;
      new_region('var_list',horiz,var_list_index,abs,false,false);
      new_subregion('var_list',horiz,var_list_index+1,abs,false,false);
      var_list_index := region_count;
      temp_index := var_list_index;
      new_subregion('         ',horiz,temp_index,prim,true,false);
      new_region(var_id,horiz,temp_index+1,prim,true,true);
      new_region(' : ',horiz,temp_index+2,prim,true,false);
      new_region(type_id,horiz,temp_index+3,prim,true,true);
      new_region(';',horiz,temp_index+4,prim,true,false);
      first_var_list := false
   END
   ELSE
   BEGIN
      new_region('var_list',horiz,var_list_index,abs,false,false);
      var_list_index := region_count;
      temp_index := var_list_index;
      new_subregion('         ',horiz,temp_index,prim,true,false);
      new_region(var_id,horiz,temp_index+1,prim,true,true);
      new_region(' : ',horiz,temp_index+2,prim,true,false);
      new_region(type_id,horiz,temp_index+3,prim,true,true);
      new_region(';',horiz,temp_index+4,prim,true,false)
   END
END;

PROCEDURE insert_initial;
VAR temp_index : integer;
BEGIN
   IF first_initial THEN
   BEGIN
      new_subregion('      INITIAL',horiz,initial_index,prim,true,false);
      initial_index := region_count;
      temp_index := initial_index;
      new_subregion('         ',horiz,temp_index,prim,true,false);
      new_region('initial_axiom',horiz,temp_index+1,abs,false,true);
      initial_axiom_index := region_count;
      new_region(' END',horiz,temp_index+2,prim,true,false);
      new_region(';',horiz,temp_index+3,prim,true,false);
      first_initial := false
   END
   ELSE
      writeln('only one initial state allowable')
END;

PROCEDURE insert_initial_axiom;
VAR temp_index : integer;
BEGIN
   IF first_initial_axiom THEN
   BEGIN
      new_subregion('         ',horiz,initial_axiom_index,prim,true,false);
      initial_axiom_index := region_count;
      temp_index := region_count;
      new_region('<argument>',horiz,temp_index,prim,true,true);
      new_region(' = ',horiz,temp_index+1,prim,true,false);
      new_region('<argument>',horiz,temp_index+2,prim,true,true);
      initial_axiom_index := region_count;
      first_initial_axiom := false
   END
   ELSE
      writeln('only one initial state axiom allowable')
END;


PROCEDURE insert_axiom;
VAR  temp_index : integer;
BEGIN
   new_region('axiom',horiz,axiom_index,abs,false,false);
   axiom_index := region_count;
   temp_index := axiom_index;
   new_subregion('      ',horiz,temp_index,prim,true,false);
   new_region('<argument>',horiz,temp_index+1,prim,true,true);
   new_region(' = ',horiz,temp_index+2,prim,true,false);
   new_region('<argument>',horiz,temp_index+3,prim,true,true);
   new_region(';',horiz,temp_index+4,prim,true,false)
END;

PROCEDURE prompt_to_insert_inherits;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert inheritance clause (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN insert_inherits
END;

PROCEDURE prompt_to_insert_uses;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert uses clause (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN insert_uses
END;

PROCEDURE prompt_to_insert_attrib;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert attribute function (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN
      insert_attribute_func_def
END;

PROCEDURE prompt_to_insert_method;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert method function (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN
   BEGIN
      writeln('insert standard or decorated function (1, 2): ');
      char_pressed := readkey;
      IF char_pressed = '1' THEN
         insert_method_func_def(standard)
      ELSE
         insert_method_func_def(decorated)
   END
END;

PROCEDURE prompt_to_insert_var_list;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert variable list (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN insert_var_list
END;

PROCEDURE prompt_to_insert_initial;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert initial state specification (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN insert_initial
END;

PROCEDURE prompt_to_insert_initial_axiom;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert initial state axiom (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN insert_initial_axiom
END;

PROCEDURE prompt_to_insert_axiom;
VAR char_pressed : char;
BEGIN
   writeln;
   writeln('insert axiom (y/n): ');
   char_pressed := readkey;
   IF char_pressed = 'y' THEN
      insert_axiom
END;

PROCEDURE test_and_insert;
VAR region_contents: string;
BEGIN
   current_abs_region_contents(region_contents);
   IF region_contents = 'inherits' THEN
      prompt_to_insert_inherits
   ELSE
   IF region_contents = 'uses' THEN
      prompt_to_insert_uses
   ELSE
   IF region_contents = 'attribute' THEN
      prompt_to_insert_attrib
   ELSE
   IF region_contents = 'method' THEN
      prompt_to_insert_method
   ELSE
   IF region_contents = 'var_list' THEN
      prompt_to_insert_var_list
   ELSE
   IF region_contents = 'initial' THEN
      prompt_to_insert_initial
   ELSE
   IF region_contents = 'initial_axiom' THEN
      prompt_to_insert_initial_axiom
   ELSE
   IF region_contents = 'axiom' THEN
      prompt_to_insert_axiom;
   dispose_list;
   create_list; {create editable item list which points to regions }
   refresh_screen
END;

PROCEDURE edit_specification;

VAR char_pressed   : char;
    new_cont       : string;
    temp_count     : integer;

BEGIN
   char_pressed := readkey;
   select_topmost;
   refresh_screen;
   WHILE char_pressed <> exit_char DO
   BEGIN
      CASE char_pressed OF
         move_down_char : BEGIN
                             next_in_list;
                             refresh_screen
                          END;
         move_up_char   : BEGIN
                             prev_in_list;
                             refresh_screen
                          END;
         return_to_top  : BEGIN
                             select_topmost;
                             refresh_screen
                          END;
         jump_10_up     : BEGIN
                             FOR temp_count := 1 TO 10 DO
                                prev_in_list;
                             refresh_screen
                          END;
         jump_10_down   : BEGIN
                             FOR temp_count := 1 TO 10 DO
                                next_in_list;
                             refresh_screen
                          END;
         un_parse       : BEGIN
                             output_to_file;
                             select_topmost;
                             refresh_screen
                          END;
         want_to_edit   : BEGIN
                             writeln;
                             write('Enter new contents: ');
                             readln(new_cont);
                             edit_contents(new_cont);
                             refresh_screen
                          END;
         want_to_insert : test_and_insert;
         reset_editor   : BEGIN
                             dispose_list;
                             dispose_tree;
                             init_editor;
                             select_topmost;
                             refresh_screen
                          END
      END;
      char_pressed := readkey
   END
END;

BEGIN
   init_editor;
   select_topmost;
   refresh_screen;
   edit_specification;
   dispose_tree;
   dispose_list
END.
