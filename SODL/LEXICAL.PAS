UNIT lexical;

{
  By Adrian Pilkington
  For 3rd year project
  UMIST Dept. Of Computation

  This module comprises a lexical analyser used by SODL.exe
  The compilation process is syntax directed
}


INTERFACE

USES hash_tab;

CONST debug = false;

TYPE
   natural     = 0..maxint;
   lexeme_kind = (semi_colon_sym,    type_sym,             end_sym,
                  uses_sym,          for_sym,              inherits_sym,
                  attribute_sym,     function_sym,         method_sym,
                  initial_sym,       equality_sym,         class_sym,
                  id_sym, const_sym, comma_sym,            full_stop_sym,
                  axiom_sym,         open_bracket_sym,     close_bracket_sym,
                  var_sym,           function_result_sym,  parameter_sep_sym,
                  sed_sym,           colon_sym,            equal_sym);
   id_type       = (void,           class_id,  attribute_func_id,
                    method_func_id, decorated, var_id,
                    type_id);
VAR
   current 	       : lexeme_kind;
   source_text         : text;
   prog_param          : word;
   full_file_name      : string;
   global_id_name      : string;
   last_line_processed : string;

PROCEDURE read_sym;

PROCEDURE insert_in_sym_table(id_name : id_name_type;
                              type_of_id : id_type;
                              is_local : boolean
                             );
PROCEDURE retrieve_from_sym_table(id_name : id_name_type;
                                  VAR type_of_id : id_type
                                 );
PROCEDURE new_super_type( type_id_to_update : id_name_type;
                          supertype         : id_name_type
                        );
PROCEDURE new_function_result_type( function_id : id_name_type;
                                    type_id_name: id_name_type
                                  );

PROCEDURE new_function_argument_type(function_id : id_name_type;
                                     type_id_name: id_name_type
                                    );
PROCEDURE output_sym_table(filename : string);

PROCEDURE input_symbol_table(filename : string);

PROCEDURE shut_doun_parser;

IMPLEMENTATION
VAR
   count           : natural;
   last_sym_was_id : boolean;
   buffer          : string[2];
   local_sym       : string;
   id_char_set     : SET OF char;

PROCEDURE lexical_error(error_message : string);
BEGIN
   writeln('Lexical error: ',error_message);
   IF NOT(debug) THEN writeln(last_line_processed);
   shut_doun_parser;
   halt
END;

PROCEDURE input_symbol_table(filename : string);
BEGIN
    input_table_from_file(filename);
END;

PROCEDURE output_sym_table(filename : string);
BEGIN
   output_table_to_file(filename);
END;

PROCEDURE new_super_type( type_id_to_update : id_name_type;
                          supertype         : id_name_type
                        );
BEGIN
   update_table_with_super_type(type_id_to_update, supertype)
END;
PROCEDURE new_function_result_type( function_id : id_name_type;
                                    type_id_name: id_name_type
                                  );
BEGIN
   update_table_with_result_type(function_id, type_id_name)
END;

PROCEDURE new_function_argument_type(function_id : id_name_type;
                                     type_id_name: id_name_type
                                    );
BEGIN
   update_table_with_arg_type(function_id, type_id_name);
END;

PROCEDURE insert_in_sym_table(id_name : id_name_type;
                              type_of_id : id_type;
                              is_local : boolean
                             );
VAR code : integer;

BEGIN
   CASE type_of_id OF
      void              : code := 0;
      class_id          : code := 1;
      attribute_func_id : code := 2;
      method_func_id    : code := 3;
      decorated         : code := 4;
      var_id            : code := 5;
      type_id           : code := 6
   END;
   insert_table(id_name, code, is_local)
END;

PROCEDURE retrieve_from_sym_table(id_name : id_name_type;
                                  VAR type_of_id : id_type
                                 );
VAR code : integer;
BEGIN
   retrieve_table(id_name, code);
   CASE code OF
      0 : type_of_id := void;
      1 : type_of_id := class_id;
      2 : type_of_id := attribute_func_id;
      3 : type_of_id := method_func_id;
      4 : type_of_id := decorated;
      5 : type_of_id := var_id;
      6 : type_of_id := type_id
   END;
END;

PROCEDURE read_sym;
VAR
   found	   : boolean;
   current_char    : char;

   PROCEDURE read_next_char(VAR current_char   : char);

      PROCEDURE add_current_to_buffer;
      BEGIN
         buffer[2]:= buffer[1];
         buffer[1]:= current_char
      END;
   BEGIN
      read(source_text, current_char);
      IF debug THEN write(current_char);
      add_current_to_buffer;
      IF (last_sym_was_id) AND (buffer[2] = ' ') THEN
         current_char := buffer[1]
      ELSE
      IF (last_sym_was_id) AND NOT(current_char IN id_char_set) THEN
         current_char := buffer[2]
      ELSE
      IF buffer = #13';' THEN current_char := buffer[2]
      ELSE
         current_char := buffer[1];
      last_sym_was_id := false;
      IF current_char <> ' ' THEN
         last_line_processed := last_line_processed + current_char;
      IF (current_char = #13) OR (current_char = #10)
         THEN count := count + 1;
      IF count = 1 THEN
      BEGIN
         last_line_processed := '';
         count := 0
      END
   END;

   PROCEDURE do_const_or_id;
   BEGIN
      IF local_sym[1] IN id_char_set THEN
      BEGIN
         current:=id_sym;
         WHILE current_char IN id_char_set DO
         BEGIN
            read_next_char(current_char);
            IF current_char IN id_char_set THEN
               local_sym := local_sym + current_char
         END;
         found:= true;
         last_sym_was_id := true;
         global_id_name := local_sym
      END
      ELSE
      IF local_sym[1] IN ['0'..'9'] THEN
      BEGIN
         current:=const_sym;
         WHILE current_char IN ['0'..'9'] DO
         BEGIN
            read_next_char(current_char);
            local_sym := local_sym + current_char
         END;
         found:= true
      END
   END;

	PROCEDURE deal_with_white_space;
	BEGIN
	    WHILE (current_char = #14) OR (current_char = #13) OR
                  (current_char = #10) OR (current_char = ' ') DO
            read_next_char(current_char)
	END;



BEGIN
   local_sym := '';
   current_char:= ' ';
   found := false;
   read_next_char(current_char);
   deal_with_white_space;
   WHILE found = FALSE DO
   BEGIN
      local_sym := local_sym + current_char;
      IF current_char = #26 THEN lexical_error('full stop expected at end of spec.')
      ELSE
      IF local_sym = 'CLASS' THEN BEGIN current := class_sym; found:=true END
      ELSE
      IF local_sym = 'INHERITS' THEN BEGIN current := inherits_sym; found:=true END
      ELSE
      IF local_sym = 'USES' THEN BEGIN current := uses_sym; found:=true END
      ELSE
      IF local_sym = 'TYPE' THEN BEGIN current := type_sym; found:=true END
      ELSE
      IF local_sym = 'ATTRIBUTE' THEN BEGIN current := attribute_sym; found:=true END
      ELSE
      IF local_sym = 'FUNCTIONS' THEN BEGIN current := function_sym; found:=true END
      ELSE
      IF local_sym = 'METHOD' THEN BEGIN current := method_sym; found:=true END
      ELSE
      IF local_sym = 'FOR' THEN BEGIN current := for_sym; found:=true END
      ELSE
      IF local_sym = 'INITIAL' THEN BEGIN current := initial_sym; found:=true END
      ELSE
      IF local_sym = 'END' THEN BEGIN current := end_sym; found:=true END
      ELSE
      IF local_sym = 'AXIOMS' THEN BEGIN current := axiom_sym; found:=true END
      ELSE
      IF local_sym = 'VAR' THEN BEGIN current := var_sym; found:=true END
      ELSE
      IF local_sym = 'X' THEN BEGIN current := parameter_sep_sym; found:=true END
      ELSE
         CASE current_char OF
            '.' : BEGIN current := full_stop_sym;  found:=true END;
            ',' : BEGIN current := comma_sym;      found:=true END;
            '=' : BEGIN current := equal_sym;      found:=true END;
            '-' : BEGIN
                      found:=true;
                      read_next_char(current_char);
                      IF current_char = '>'
                         THEN current := function_result_sym
                      ELSE lexical_error('''>'' expected after ''-''')
                  END;
            ';' : BEGIN
                     current := semi_colon_sym;
                     found:=true
                  END;
            ':' : BEGIN current := colon_sym; found:=true END;
            '(' : BEGIN current := open_bracket_sym; found:=true END;
            ')' : BEGIN current := close_bracket_sym; found:=true END;
            '~' : BEGIN current := sed_sym; found:=true END
            ELSE
               do_const_or_id
         END;
      IF NOT found THEN read_next_char(current_char);
   END;
END;

PROCEDURE shut_doun_parser;
BEGIN
   dispose_sym_table;
   close(source_text)
END;

BEGIN
   last_sym_was_id := false;
   last_line_processed := '';
   count := 0;
   id_char_set := ['a'..'z','_'];
   buffer := '  ';
   IF ParamCount = 0 THEN
   BEGIN
      Writeln('Simple Object Description Language Compiler');
      write('Enter file name : ');
      readln(full_file_name);
      writeln
   END
   ELSE
   BEGIN
     Prog_param := 1;
     full_file_name := ParamStr(prog_param)
   END;
   assign(source_text,full_file_name);
{$I-}
   reset(source_text);
{$I+}
   IF IOResult = 0 THEN
      (* ok *)
   ELSE
   BEGIN
      writeln('cannot find file error : ',full_file_name);
      halt
   END
END.