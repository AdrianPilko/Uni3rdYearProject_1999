UNIT abs_syn;

{
  By Adrian Pilkington
  For 3rd year project
  UMIST Dept. Of Computation

  abstract syntax for SODL, and term rewrite routine to generate
  a embryo imlplementaion in the Feynman Language (AKA The Model Language)
  from the abstract syntax

}

INTERFACE

USES hash_tab;

TYPE
   att_func_list_ptr = ^att_func_list;

   att_func_list = RECORD
                      link_to_sym_table : list_ptr;
                      next              : att_func_list_ptr;
                   END;

   met_func_list_ptr = ^met_func_list;

   met_func_list = RECORD
                      link_to_sym_table : list_ptr;
                      next              : met_func_list_ptr
                   END;

   spec_body_type= RECORD
                      inherits    : list_ptr;
                      {uses_clause : uses_clause_list}
                      type_decl   : list_ptr;
                      att_func    : att_func_list_ptr;
                      met_func    : met_func_list_ptr
                   END;

   specification = RECORD
                      class_id : string;
                      spec_body: spec_body_type
                   END;

PROCEDURE abs_new_met_func(function_name : string);

PROCEDURE abs_new_att_func(function_name : string);

PROCEDURE abs_new_type(type_name : string);

PROCEDURE abs_new_inherits(type_name : string);

PROCEDURE abs_new_spec(class_name : string);

PROCEDURE create_model_language_implementation(file_path : string);

IMPLEMENTATION

VAR this_spec : specification;

PROCEDURE abs_new_met_func(function_name : string);

VAR temp_met_func_ptr : met_func_list_ptr;
    insert_ptr        : met_func_list_ptr;
    linkage_ptr       : list_ptr;

   PROCEDURE traverse_end( start : met_func_list_ptr;
                           VAR pos_to_insert : met_func_list_ptr
                         );
   VAR temp_pos : met_func_list_ptr;
   BEGIN
      temp_pos := start;
      WHILE temp_pos^.next <> NIL DO
            temp_pos := temp_pos^.next;
      pos_to_insert := temp_pos
   END;

BEGIN
   new(temp_met_func_ptr);
   IF this_spec.spec_body.met_func = nil THEN
      this_spec.spec_body.met_func := temp_met_func_ptr
   ELSE
   BEGIN
      traverse_end(this_spec.spec_body.met_func, insert_ptr);
      IF insert_ptr <> nil THEN
         insert_ptr^.next := temp_met_func_ptr
   END;
   find_type_id_pos(function_name, linkage_ptr);
   temp_met_func_ptr^.link_to_sym_table := linkage_ptr;
   temp_met_func_ptr^.next := nil
END;

PROCEDURE abs_new_att_func(function_name : string);

VAR temp_att_func_ptr : att_func_list_ptr;
    insert_ptr        : att_func_list_ptr;
    linkage_ptr       : list_ptr;

   PROCEDURE traverse_end( start : att_func_list_ptr;
                           VAR pos_to_insert : att_func_list_ptr
                         );
   VAR temp_pos : att_func_list_ptr;
   BEGIN
      temp_pos := start;
      WHILE temp_pos^.next <> NIL DO
            temp_pos := temp_pos^.next;
      pos_to_insert := temp_pos
   END;

BEGIN
   new(temp_att_func_ptr);
   IF this_spec.spec_body.att_func = nil THEN
      this_spec.spec_body.att_func := temp_att_func_ptr
   ELSE
   BEGIN
      traverse_end(this_spec.spec_body.att_func, insert_ptr);
      IF insert_ptr <> nil THEN
         insert_ptr^.next := temp_att_func_ptr
   END;
   find_type_id_pos(function_name, linkage_ptr);
   temp_att_func_ptr^.link_to_sym_table := linkage_ptr;
   temp_att_func_ptr^.next := nil
END;

PROCEDURE abs_new_type(type_name : string);
VAR temp_type_ptr : list_ptr;
BEGIN
   find_type_id_pos(type_name, temp_type_ptr);
   this_spec.spec_body.type_decl := temp_type_ptr;
END;

PROCEDURE abs_new_inherits(type_name : string);
VAR temp_type_ptr : list_ptr;
BEGIN
   find_type_id_pos(type_name, temp_type_ptr);
   this_spec.spec_body.inherits := temp_type_ptr;
END;

PROCEDURE abs_new_spec(class_name : string);
BEGIN
   this_spec.class_id := class_name;
   this_spec.spec_body.inherits := nil;
   this_spec.spec_body.type_decl := nil;
   this_spec.spec_body.att_func := nil;
   this_spec.spec_body.met_func := nil
END;

PROCEDURE create_model_language_implementation(file_path : string);

VAR object_text : text;
    file_name   : string;

   PROCEDURE gen_type;
   BEGIN
      write(object_text,'TYPE ');
      write(object_text,this_spec.spec_body.type_decl^.id_name);
      write(object_text,';');
      writeln(object_text)
   END;

   PROCEDURE gen_super_type;
   BEGIN
      IF this_spec.spec_body.inherits <> nil THEN
      BEGIN
         writeln(object_text);
         write(object_text,'SUPERTYPES ');
         write(object_text,this_spec.spec_body.inherits^.id_name);
         write(object_text,';');
         writeln(object_text);
         writeln(object_text)
      END
   END;

   PROCEDURE gen_attributes;

   VAR temp_att_func_ptr : att_func_list_ptr;

   BEGIN
      temp_att_func_ptr := this_spec.spec_body.att_func;
      IF temp_att_func_ptr <> NIL THEN writeln(object_text,'   VAR');
      WHILE temp_att_func_ptr <> nil DO
      BEGIN
         write(object_text,'      ');
         write(object_text,temp_att_func_ptr^.link_to_sym_table^.id_name);
         write(object_text,' : ');
         write(object_text,temp_att_func_ptr^.link_to_sym_table^.result_type^.id_name);
         write(object_text,';');
         writeln(object_text);
         temp_att_func_ptr := temp_att_func_ptr^.next
      END;
      writeln(object_text)
   END;

   PROCEDURE gen_methods;

   VAR temp_met_func_ptr : met_func_list_ptr;
       temp_linkage_ptr  : linkage_list_ptr;
       temp_func_name    : string;
       temp_arg_name     : string;
       arg_count         : integer;

      PROCEDURE gen_method_body;
      BEGIN
         writeln(object_text);
         writeln(object_text,'   BEGIN');
         writeln(object_text,'      "insert code here"');
         writeln(object_text,'   END;');
         temp_met_func_ptr := temp_met_func_ptr^.next;
         writeln(object_text)
      END;

   BEGIN
      temp_met_func_ptr := this_spec.spec_body.met_func;
      WHILE temp_met_func_ptr <> nil DO
      BEGIN
         temp_linkage_ptr := temp_met_func_ptr^.link_to_sym_table^.argument_type_list;
         IF temp_met_func_ptr^.link_to_sym_table^.result_type^.id_name
            = 'nil' THEN
         BEGIN
            write(object_text,'   PROCEDURE ');
            write(object_text,temp_met_func_ptr^.link_to_sym_table^.id_name);
            temp_func_name := temp_met_func_ptr^.link_to_sym_table^.id_name;
            write(object_text,'(');
            arg_count := 1;
            WHILE temp_linkage_ptr <> NIL DO
            BEGIN
               IF temp_linkage_ptr^.ptr_to_id^.id_name <> 'nil' THEN
               BEGIN
                  str(arg_count, temp_arg_name);
                  temp_arg_name := temp_linkage_ptr^.ptr_to_id^.id_name[1] +
                                   temp_arg_name;
                  write(object_text, temp_arg_name);
                  write(object_text,' : ');
                  write(object_text,temp_linkage_ptr^.ptr_to_id^.id_name)
               END;
               temp_linkage_ptr := temp_linkage_ptr^.next;
               arg_count := arg_count + 1;
               IF temp_linkage_ptr <> NIL THEN write(object_text,';')
            END;
            write(object_text,')');
            write(object_text,';');
            gen_method_body
         END
         ELSE
         BEGIN
            write(object_text,'   FUNCTION ');
            write(object_text,temp_met_func_ptr^.link_to_sym_table^.id_name);
            temp_func_name := temp_met_func_ptr^.link_to_sym_table^.id_name;
            write(object_text,'(');
            arg_count := 1;
            WHILE temp_linkage_ptr <> NIL DO
            BEGIN
               IF temp_linkage_ptr^.ptr_to_id^.id_name <> 'nil' THEN
               BEGIN
                  str(arg_count, temp_arg_name);
                  temp_arg_name := temp_linkage_ptr^.ptr_to_id^.id_name[1] +
                                   temp_arg_name;
                  write(object_text, temp_arg_name);
                  write(object_text,' : ');
                  write(object_text,temp_linkage_ptr^.ptr_to_id^.id_name)
               END;
               temp_linkage_ptr := temp_linkage_ptr^.next;
               arg_count := arg_count + 1;
              IF temp_linkage_ptr <> NIL THEN write(object_text,';')
            END;
            write(object_text,')');
            write(object_text,' : ');
            write(object_text,temp_met_func_ptr^.link_to_sym_table^.result_type^.id_name);
            write(object_text,';');
            gen_method_body
         END
      END
   END;

BEGIN
   file_name := file_path + this_spec.spec_body.type_decl^.id_name;
   assign(object_text,file_name+'.mod');
   rewrite(object_text);
   writeln('   Generating code for ''',file_name + '.mod''');
   gen_type;
   gen_super_type;
   gen_attributes;
   gen_methods;
   writeln(object_text,'END.');
   close(object_text)
END;

BEGIN

END.