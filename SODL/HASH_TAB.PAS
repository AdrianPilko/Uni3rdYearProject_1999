UNIT hash_tab;

{
  By Adrian Pilkington
  For 3rd year project
  UMIST Dept. Of Computation

  This module comprises a chained hash table used by other SODL modules
}

INTERFACE

CONST hash_size   = 1;
      max_id_size = 20;
      mask        = '                    ';
      debug       = false;

TYPE
   id_name_type = STRING[max_id_size];
   hash_range   = 1..hash_size;
   list_ptr     = ^list;
   linkage_list_ptr = ^linkage_type_list;
   list         = RECORD
                     id_name            : id_name_type;
                     type_of_id         : integer;
                     is_local           : boolean;
                     argument_type_list : linkage_list_ptr;
                     super_type         : list_ptr;
                     result_type        : list_ptr;
                     next               : list_ptr
                  END;
   linkage_type_list= RECORD
                         ptr_to_id : list_ptr;
                         next : linkage_list_ptr
                      END;
   hashtable    = ARRAY[1..hash_size] OF list_ptr;

   PROCEDURE insert_table( id_name_to_add    : id_name_type;
                           type_of_id_to_add : integer;
                           this_id_local     : boolean
                         );
   PROCEDURE retrieve_table( id_name : id_name_type;
                             VAR type_of_id : integer
                           );
   PROCEDURE update_table_with_super_type( type_id_to_update : id_name_type;
                                           supertype         : id_name_type
                                         );
   PROCEDURE update_table_with_arg_type( func_id_to_update : id_name_type;
                                         type_id_to_link    : id_name_type
                                       );
   PROCEDURE update_table_with_result_type( func_id_to_update : id_name_type;
                                            type_id_to_link    : id_name_type
                                          );
   PROCEDURE find_argument_type( function_to_query : id_name_type;
                                 argument_number   : integer;
                                 VAR argument_type : string
                               );
   PROCEDURE find_result_type( id_to_query : id_name_type;
                               VAR result_type : string
                               );
   FUNCTION type1_subtype_of_type2(type_1, type_2 : id_name_type) : boolean;
   PROCEDURE input_table_from_file(filename: string);
   PROCEDURE output_table_to_file(filename: string);

   PROCEDURE find_type_id_pos( id_name    : id_name_type;
                                VAR type_id_ptr: list_ptr
                              );
   PROCEDURE dispose_sym_table;

IMPLEMENTATION

VAR
   my_hash_table : hashtable;
   first_insertion : boolean;

PROCEDURE symbol_tab_error(error_message : string);
BEGIN
   writeln('symbol table warning: ',error_message)
END;

FUNCTION hash(x : id_name_type) : integer;
VAR i : 1..max_id_size;
    h : 1..maxlongint;
    id : id_name_type;
    temp_index : integer;
BEGIN
   h := 1;
   id := mask;
   id := x + id;
   FOR i := 1 TO max_id_size DO
      h := h + ord(id[i]);
   temp_index := h MOD hash_size;
   IF temp_index = 0 THEN hash := 1
   ELSE hash := temp_index
END;

PROCEDURE traverse_to_end(current : list_ptr;VAR pos_to_add : list_ptr);
VAR temp_pos : list_ptr;

BEGIN
   temp_pos := current;
   WHILE temp_pos^.next <> NIL DO
      temp_pos := temp_pos^.next;
   pos_to_add := temp_pos
END;

    PROCEDURE find_type_id_pos( id_name    : id_name_type;
                                VAR type_id_ptr: list_ptr
                              );
    VAR index    : hash_range;

        PROCEDURE search_list( target : id_name_type;
                               current : list_ptr;
                               VAR pos : list_ptr
                             );
        VAR temp_pos : list_ptr;

        BEGIN
           temp_pos := current;
           WHILE (temp_pos^.next <> NIL) AND
                 (temp_pos^.id_name <> target) DO
                 temp_pos := temp_pos^.next;
           pos := temp_pos
        END;

    BEGIN
       index := hash(id_name);
       search_list(id_name, my_hash_table[index], type_id_ptr);
       IF type_id_ptr^.id_name <> id_name THEN type_id_ptr := nil
    END;

    PROCEDURE search_table( id_name : id_name_type;
                            VAR type_of_id : integer;
                            VAR pos : list_ptr
                          );
    VAR index    : hash_range;
        position : list_ptr;


        PROCEDURE search_list( target : id_name_type;
                              current : list_ptr;
                              VAR pos : list_ptr
                           );
        VAR temp_pos : list_ptr;

        BEGIN
           temp_pos := current;
           WHILE (temp_pos^.next <> NIL) AND
           (temp_pos^.id_name <> target) DO
             temp_pos := temp_pos^.next;
           pos := temp_pos
        END;

    BEGIN
      index := hash(id_name);
      search_list(id_name, my_hash_table[index], position);
      IF position^.id_name <> id_name THEN type_of_id := 0
      ELSE
      BEGIN
         type_of_id := position^.type_of_id;
         pos := position
      END
   END;

PROCEDURE update_table_with_super_type( type_id_to_update : id_name_type;
                                        supertype         : id_name_type
                                      );
VAR position : list_ptr;
    temp_id_type : integer;
    temp_typeid_ptr : list_ptr;
    temp_error_message : string;

BEGIN
   search_table(type_id_to_update , temp_id_type, temp_typeid_ptr);
   IF (temp_id_type IN [6]) THEN
   BEGIN
      find_type_id_pos(supertype, position);
      IF (position <> nil) AND (position^.type_of_id = 6) {6 = type_id}
      THEN
         temp_typeid_ptr^.super_type := position
      ELSE
      BEGIN   
         temp_error_message := 'supertype <type_id> ' + supertype + ' does not exist';
         symbol_tab_error(temp_error_message)       
      END
   END
   ELSE {ie not a type id, or does not exist }
   BEGIN
      temp_error_message := '<type id> ' + type_id_to_update +
                            ' does not exist or the id is not of type id';
      symbol_tab_error(temp_error_message)
   END
END;

PROCEDURE update_table_with_result_type( func_id_to_update : id_name_type;
                                         type_id_to_link    : id_name_type
                                       );
VAR position          : list_ptr;
    temp_id_type      : integer;
    temp_function_ptr : list_ptr;
    error_string      : string;

BEGIN
   search_table(func_id_to_update , temp_id_type, temp_function_ptr);
   IF (temp_id_type IN [0,1]) THEN {ie not function id, or does not exist }
   BEGIN
      error_string := 'function id ' + func_id_to_update +
                       ' does not exist, or the id is not of function type';
      symbol_tab_error(error_string)
   END
   ELSE
   BEGIN
      find_type_id_pos(type_id_to_link, position);
      IF (position <> nil) AND (position^.type_of_id = 6) {6 = type_id}
      THEN
         temp_function_ptr^.result_type := position
      ELSE
      BEGIN
         error_string := 'type_id ' + type_id_to_link + ' does not exist';
         symbol_tab_error(error_string)
      END
   END
END;


PROCEDURE update_table_with_arg_type( func_id_to_update : id_name_type;
                                      type_id_to_link    : id_name_type
                                    );
VAR position : list_ptr;
    argument_list_node : linkage_list_ptr;
    temp_id_type : integer;
    temp_function_ptr : list_ptr;
    temp_list_ptr :linkage_list_ptr;
    error_string      : string;

       PROCEDURE find_end_of_list(VAR end_of_list : linkage_list_ptr);
       VAR search_ptr : linkage_list_ptr;
       BEGIN
          search_ptr := temp_function_ptr^.argument_type_list;
          WHILE search_ptr^.next <> nil DO
          BEGIN
             search_ptr := search_ptr^.next
          END;
          end_of_list := search_ptr
       END;

BEGIN
   search_table(func_id_to_update , temp_id_type, temp_function_ptr);
   IF (temp_id_type IN [0,1,5]) THEN {ie not function id, or does not exist }
   BEGIN
         error_string := 'function id ' + func_id_to_update +
                       ' does not exist, or the id is not of function type';
      symbol_tab_error(error_string)
   END
   ELSE
   BEGIN
      find_type_id_pos(type_id_to_link, position);
      IF (position <> nil) AND (position^.type_of_id = 6) THEN {6 = type_id}
      BEGIN
         new(argument_list_node);
         IF temp_function_ptr^.argument_type_list = nil THEN
            temp_function_ptr^.argument_type_list := argument_list_node
         ELSE
         BEGIN
            find_end_of_list(temp_list_ptr);
            temp_list_ptr^.next := argument_list_node
         END;
         argument_list_node^.next := nil;
         argument_list_node^.ptr_to_id := position
      END
      ELSE
      BEGIN
         error_string := 'type_id ' + type_id_to_link + ' does not exist';
         symbol_tab_error(error_string)
      END
   END
END;

PROCEDURE insert_table( id_name_to_add    : id_name_type;
                        type_of_id_to_add : integer;
                        this_id_local     : boolean
                      );
VAR index        : hash_range;
    position     : list_ptr;
    new_one      : list_ptr;
    temp_id_type : integer;
    error_string : string;

BEGIN
   retrieve_table(id_name_to_add, temp_id_type);
   IF temp_id_type = 0 THEN {ie void type, and id does not exist }
   BEGIN
      new(new_one);
      index := hash(id_name_to_add);
      IF my_hash_table[index] = nil THEN
      BEGIN
         my_hash_table[index] := new_one;
         WITH new_one^ DO
         BEGIN
            next := nil;
            argument_type_list := nil;
            result_type := nil;
            super_type := nil;
            id_name := id_name_to_add;
            is_local := this_id_local;
            type_of_id := type_of_id_to_add
         END
      END
      ELSE
      BEGIN
         traverse_to_end(my_hash_table[index],position);
         position^.next := new_one;
         WITH new_one^ DO
         BEGIN
            next := nil;
            argument_type_list := nil;
            result_type := nil;
            super_type := nil;
            id_name := id_name_to_add;
            is_local := this_id_local;
            type_of_id := type_of_id_to_add
         END
      END
   END
   ELSE
   BEGIN
      error_string := 'identifier ' + id_name_to_add +
                       ' already exists';
      symbol_tab_error(error_string)
   END
END;

PROCEDURE retrieve_table( id_name : id_name_type;
                          VAR type_of_id : integer
                        );
VAR index    : hash_range;
    position : list_ptr;
    target   : id_name_type;

   PROCEDURE search_list( target : id_name_type;
                          current : list_ptr;
                          VAR pos : list_ptr
                        );
   VAR temp_pos : list_ptr;

   BEGIN
      temp_pos := current;
      WHILE (temp_pos^.next <> NIL) AND (temp_pos^.id_name <> target) DO
         temp_pos := temp_pos^.next;
      pos := temp_pos
   END;

BEGIN
   index := hash(id_name);
   target := id_name;
   IF first_insertion THEN
   BEGIN
      first_insertion := false;
      position := my_hash_table[index]
   END
   ELSE
      search_list(target, my_hash_table[index], position);
   IF position^.id_name <> target THEN type_of_id := 0
   ELSE type_of_id := position^.type_of_id
END;

PROCEDURE empty_table;

VAR i : integer;

   PROCEDURE empty_list(i : integer);
   BEGIN
      my_hash_table[i] := nil
   END;

BEGIN
   FOR i := 1 TO hash_size DO empty_list(i);
END;

PROCEDURE find_argument_type( function_to_query : id_name_type;
                              argument_number   : integer;
                              VAR argument_type : string
                            );
VAR temp_type_of_id : integer;
    position        : list_ptr;
    count           : integer;
    current_arg_ptr : linkage_list_ptr;

BEGIN
   search_table( function_to_query, temp_type_of_id, position);
   current_arg_ptr := position^.argument_type_list;
   IF argument_number = 1 THEN
      argument_type := current_arg_ptr^.ptr_to_id^.id_name
   ELSE
   BEGIN
      FOR count := 1 TO argument_number DO
      BEGIN
         IF current_arg_ptr^.next <> nil THEN
            current_arg_ptr := current_arg_ptr^.next;
      END;
      IF current_arg_ptr <> nil THEN
         argument_type := current_arg_ptr^.ptr_to_id^.id_name
   END
END;

PROCEDURE find_result_type( id_to_query : id_name_type;
                            VAR result_type : string
                          );
VAR temp_type_of_id : integer;
    position        : list_ptr;

BEGIN
   search_table( id_to_query, temp_type_of_id, position);
   result_type := position^.result_type^.id_name
END;

PROCEDURE input_table_from_file(filename: string);
VAR
   symbol_input_file : text;
   temp_type_of_id  : integer;
   supertype_id_name: string;
   temp_id_name     : id_name_type;
   temp_char        : char;
   temp_int         : integer;
   function_name    : id_name_type;
   temp_string      : string;
       { file format::= <id> <space> <id_type> <space> <linkage_info>+ ;
        <linkage_info> ::= <arguemnt_types> <space> <-> <space> <result_type>
        }

BEGIN
   assign(symbol_input_file,filename);
   {$I-}
      reset(symbol_input_file);
   {$I+}
   IF IOResult = 0 THEN
      (* ok *)
   ELSE
   BEGIN
      writeln('cannot find file error : ',filename);
      halt
   END;
   temp_type_of_id := 0;
   temp_id_name    := '';
   WHILE NOT(EOF(symbol_input_file)) DO
   BEGIN
      temp_id_name    := '';
      read(symbol_input_file, temp_char);
      WHILE temp_char <> ' ' DO
      BEGIN
         temp_id_name := temp_id_name + temp_char;
         read(symbol_input_file, temp_char)
      END;
      read(symbol_input_file, temp_int);
      temp_type_of_id := temp_int;
      insert_table(temp_id_name, temp_type_of_id, false);
      function_name := temp_id_name;
      IF temp_type_of_id = 6 THEN           {i.e a type id}
      BEGIN
         read(symbol_input_file,temp_char);
         read(symbol_input_file,temp_char);
         IF temp_char = ';' THEN read(symbol_input_file,temp_char)
         ELSE
         BEGIN
            supertype_id_name := '';
            WHILE temp_char <> ' ' DO
            BEGIN
               supertype_id_name := supertype_id_name + temp_char;
               read(symbol_input_file, temp_char)
            END;
            update_table_with_super_type(temp_id_name, supertype_id_name);
            read(symbol_input_file, temp_char);
            IF temp_char = ';' THEN read(symbol_input_file,temp_char)
         END
      END
      ELSE
      BEGIN
         read(symbol_input_file,temp_char);
         temp_id_name    := '';
         IF temp_char = ';' THEN read(symbol_input_file,temp_char)
         ELSE
         BEGIN
            IF temp_char = ' ' THEN
            BEGIN
               IF temp_char = ' ' THEN read(symbol_input_file,temp_char);
               IF temp_char = ';' THEN read(symbol_input_file,temp_char)
            END;
            IF temp_char <> #13 THEN
            BEGIN
               WHILE temp_char <> '-' DO
               BEGIN
                  WHILE temp_char <> ' ' DO
                  BEGIN
                     temp_id_name := temp_id_name + temp_char;
                     read(symbol_input_file, temp_char);
                  END;
                  update_table_with_arg_type(function_name,temp_id_name);
                  read(symbol_input_file,temp_char);
                  temp_id_name    := '';
               END;
               temp_id_name    := '';
               read(symbol_input_file,temp_char);
               read(symbol_input_file,temp_char);
               WHILE temp_char <> ';' DO
               BEGIN
                  temp_id_name := temp_id_name + temp_char;
                  read(symbol_input_file, temp_char);
               END;
               update_table_with_result_type(function_name, temp_id_name);
               temp_id_name    := '';
               read(symbol_input_file, temp_char)
            END
         END
      END;
      readln(symbol_input_file)
   END;
   close(symbol_input_file)
END;

PROCEDURE output_table_to_file(filename: string);
VAR
   symbol_text_file : text;
   index            : hash_range;
   temp_list_ptr    : list_ptr;
   type_of_id  : integer;
   temp_ptr    : linkage_list_ptr;
      { file format::= <id> <space> <id_type> <space> <linkage_info>+ ;
        <linkage_info> ::= <arguemnt_types> <space> <-> <space> <result_type>
        }
BEGIN
   assign(symbol_text_file,filename);
   rewrite(symbol_text_file);
   FOR index := 1 TO hash_size DO
   BEGIN
      temp_list_ptr := my_hash_table[index];
      WHILE temp_list_ptr <> NIL DO
      BEGIN
         IF temp_list_ptr^.is_local THEN temp_list_ptr := temp_list_ptr^.next
         ELSE
         BEGIN
            write(symbol_text_file,temp_list_ptr^.id_name,' ');
            write(symbol_text_file,temp_list_ptr^.type_of_id);
            IF temp_list_ptr^.type_of_id IN [2,3,4] THEN { i.e is a function type }
            BEGIN
               write(symbol_text_file,' ');
               temp_ptr := temp_list_ptr^.argument_type_list;
               WHILE temp_ptr <> nil DO
               BEGIN
                  write(symbol_text_file, temp_ptr^.ptr_to_id^.id_name,' ');
                  temp_ptr := temp_ptr^.next
               END;
               write(symbol_text_file,'- ');
               write(symbol_text_file,temp_list_ptr^.result_type^.id_name)
            END
            ELSE
            IF temp_list_ptr^.type_of_id IN [6] THEN { i.e is a type id }
            BEGIN
               IF temp_list_ptr^.super_type <> nil THEN
               BEGIN
                  write(symbol_text_file,' ');
                  write(symbol_text_file,temp_list_ptr^.super_type^.id_name)
               END;
               write(symbol_text_file,' ');
            END;
            write(symbol_text_file,';');
            writeln(symbol_text_file);
            writeln(symbol_text_file);
            temp_list_ptr := temp_list_ptr^.next
         END
      END
   END;
   close(symbol_text_file)
END;

FUNCTION type1_subtype_of_type2(type_1, type_2 : id_name_type) : boolean;
VAR type_of_id : integer;
    position   : list_ptr;
    temp_ptr   : list_ptr;
BEGIN
   search_table( type_1, type_of_id, position);
   IF position^.super_type^.id_name = type_2 THEN
      type1_subtype_of_type2 := true
   ELSE
   BEGIN
      WHILE (position^.super_type <> nil) AND
            (position^.super_type^.id_name <> type_2) DO
      BEGIN
         position := position^.super_type
      END;
      IF position^.super_type^.id_name = type_2 THEN
         type1_subtype_of_type2 := true
      ELSE
         type1_subtype_of_type2 := false
   END
END;

PROCEDURE dispose_sym_table;
VAR
   count : integer;
   chain_ptr : list_ptr;

   PROCEDURE dispose_chain(current : list_ptr);

      PROCEDURE dispose_linkage_list(current_linkage_ptr : linkage_list_ptr);
      BEGIN
         IF current_linkage_ptr^.next <> nil THEN
            dispose_linkage_list(current_linkage_ptr^.next);
         dispose(current_linkage_ptr)
      END;

   BEGIN
      IF current^.argument_type_list = nil THEN
      ELSE dispose_linkage_list(current^.argument_type_list);
      IF current^.next <> nil THEN dispose_chain(current^.next);
      dispose(current)
   END;
BEGIN
   FOR count := 1 TO hash_size DO
   BEGIN
      chain_ptr := my_hash_table[count];
      dispose_chain(chain_ptr)
   END
END;

BEGIN
   empty_table;
   first_insertion := true
END.
