UNIT region;
{
  By Adrian Pilkington
  For 3rd year project
  UMIST Dept. Of Computation

  Uses the notion of nested hierarchical regions as a means of
  organising the structure of 2 dimensional non-persistent data
  i.e for output to a display screen.
}

INTERFACE

   USES crt;

   CONST file_path = 'd:\3rdyea\sodl\';
         y_max_lines = 25;

   TYPE
       image       = string;

       node_type   = (a_region,a_subregion);

       layout_type = (vert, horiz);

       region_type = (abs,prim);

       tree_ptr    = ^tree;

       tree        = RECORD
                        first_child    : tree_ptr;
                        next_child     : tree_ptr;
                        contents       : image;
                        region_num     : integer;
                        layout         : layout_type;
                        type_of_region : region_type;
                        seen           : boolean;
                        editable       : boolean
                     END;
   TYPE
      list_ptr = ^list;

      list     = RECORD
                    element : tree_ptr;
                    next,
                    prev    : list_ptr
                 END;


   PROCEDURE new_region( new_contents : image;
                         new_layout   : layout_type;
                         where        : integer;
                         type_of_reg  : region_type;
                         is_seen      : boolean;
                         is_editable  : boolean
                       );
   PROCEDURE new_subregion( new_contents : image;
                            new_layout   : layout_type;
                            where        : integer;
                            type_of_reg  : region_type;
                            is_seen      : boolean;
                            is_editable  : boolean
                          );
   PROCEDURE find_contents( region_to_find : integer;
                            VAR contents : image;
                            VAR layout : layout_type;
                            VAR is_primitive : boolean
                          );
   PROCEDURE refresh_screen;

   PROCEDURE edit_contents(new_contents : string);

   PROCEDURE current_abs_region_contents(VAR current_contents : string);

   PROCEDURE select_topmost;

   PROCEDURE new_tree;

   PROCEDURE next_in_list;

   PROCEDURE prev_in_list;

   PROCEDURE create_list;

   PROCEDURE dispose_list;

   PROCEDURE dispose_tree;

   PROCEDURE output_to_file;

VAR
   region_count                : integer;
   reg_num_of_current_editable : integer;

IMPLEMENTATION

VAR my_region    : tree_ptr;
    pos          : tree_ptr;
    my_list      : list_ptr;
    current      : list_ptr;

   PROCEDURE empty_list;
   BEGIN
      my_list := nil
   END;

   FUNCTION is_list_empty : boolean;
   BEGIN
      is_list_empty :=  my_list = nil
   END;

   PROCEDURE select_topmost;
   BEGIN
      current := my_list
   END;

   PROCEDURE create_list;

      PROCEDURE new_list_node(root : tree_ptr);
      VAR temp_node,
          another_ptr : list_ptr;

          PROCEDURE find_end_of_list(VAR end_of_list : list_ptr);
          VAR search_ptr : list_ptr;
          BEGIN
             search_ptr := my_list;
             WHILE search_ptr^.next <> nil DO
             BEGIN
                search_ptr := search_ptr^.next
             END;
             end_of_list := search_ptr
          END;

      BEGIN
         new(temp_node);
         temp_node^.element := root;
         temp_node^.next := nil;
         IF is_list_empty THEN
         BEGIN
            my_list := temp_node;
            temp_node^.prev := my_list
         END
         ELSE
         BEGIN
            find_end_of_list(another_ptr);
            another_ptr^.next := temp_node;
            temp_node^.prev := another_ptr
         END
      END;

      PROCEDURE pre_order(root : tree_ptr);
      BEGIN
         IF root <> nil THEN
         BEGIN
            IF root^.editable = true THEN new_list_node(root);
            pre_order(root^.first_child);
            pre_order(root^.next_child)
         END
      END;

   BEGIN
      empty_list;
      pre_order(my_region)
   END;

   PROCEDURE dispose_list;
   VAR this_item,
       next_item : list_ptr;
   BEGIN
      next_item := my_list;
      WHILE next_item <> nil DO
      BEGIN
         this_item := next_item;
         next_item := this_item^.next;
         dispose(this_item);
      END;
      empty_list
   END;

   PROCEDURE prev_in_list;
   BEGIN
      IF current^.prev <> my_list THEN current := current^.prev
      ELSE current := my_list
   END;

   PROCEDURE next_in_list;
   BEGIN
      IF current^.next <> nil THEN current := current^.next
   END;

FUNCTION is_tree_empty : boolean;
BEGIN
   is_tree_empty := my_region = nil
END;

PROCEDURE tree_search( root : tree_ptr;
                       target : integer
                     );

BEGIN
   IF root <> nil  THEN
   BEGIN
      IF root^.region_num = target THEN pos := root;
      tree_search(root^.first_child,target);
      tree_search(root^.next_child,target)
   END
END;

PROCEDURE edit_contents(new_contents : string);
BEGIN
   IF (current^.element^.editable) AND
      (current^.element^.type_of_region <> abs)
   THEN
      current^.element^.contents := new_contents
END;

PROCEDURE goto_region( region_to_find : integer;
                       VAR position : tree_ptr
                     );

BEGIN
   position := nil;
   pos:= nil;
   tree_search(my_region,region_to_find);
   position := pos
END;

PROCEDURE insert_tree(root : tree_ptr;
                      new_node : tree_ptr;
                      node:node_type
                     );
BEGIN
   IF node = a_subregion THEN
      root^.first_child := new_node;
   IF node = a_region THEN
      root^.next_child  := new_node
END;

PROCEDURE new_region( new_contents : image;
                      new_layout   : layout_type;
                      where        : integer;
                      type_of_reg  : region_type;
                      is_seen      : boolean;
                      is_editable  : boolean
                    );

VAR new_one   : tree_ptr;
    temp_ptr  : tree_ptr;

BEGIN
   new(new_one);
   inc(region_count);
   goto_region(where,temp_ptr);
   WITH new_one^ DO
   BEGIN
      contents    := new_contents;
      region_num  := region_count;
      layout      := new_layout;
      type_of_region := type_of_reg;
      seen := is_seen;
      editable := is_editable;
      next_child  := nil;
      first_child := nil
   END;
   IF temp_ptr = nil THEN
   BEGIN
      my_region := new_one;
      new_one^.first_child := nil;
      new_one^.next_child  := nil;
   END
   ELSE insert_tree(temp_ptr,new_one,a_region)
END;

PROCEDURE new_subregion( new_contents : image;
                         new_layout   : layout_type;
                         where        : integer;
                         type_of_reg  : region_type;
                         is_seen      : boolean;
                         is_editable  : boolean
                    );

VAR new_one   : tree_ptr;
    temp_ptr  : tree_ptr;

BEGIN
   new(new_one);
   inc(region_count);
   goto_region(where,temp_ptr);
   WITH new_one^ DO
   BEGIN
      contents    := new_contents;
      region_num  := region_count;
      layout      := new_layout;
      type_of_region := type_of_reg;
      seen := is_seen;
      editable := is_editable;
      next_child  := nil;
      first_child := nil
   END;
   insert_tree(temp_ptr,new_one,a_subregion)
END;

PROCEDURE find_contents( region_to_find : integer;
                         VAR contents : image;
                         VAR layout : layout_type;
                         VAR is_primitive : boolean
                       );

VAR temp_ptr : tree_ptr;

BEGIN
   goto_region(region_to_find, temp_ptr);
   contents := temp_ptr^.contents;
   layout := temp_ptr^.layout;
   is_primitive := temp_ptr^.type_of_region = prim
END;

PROCEDURE header;
BEGIN
   writeln(' Syntax directed editor for SODL');
   writeln(' use keys: up/down = ''a/z'', quit=''q'', edit/insert= ''tab,\'',unparse= ''u''');
   writeln
END;

PROCEDURE refresh_screen;
VAR
   loop_count : integer;
   line_count : integer;
   current_editable_found : boolean;

   PROCEDURE pre_order(root : tree_ptr);
   BEGIN
      IF root <> nil THEN
      BEGIN
         IF current_editable_found THEN
         BEGIN
            IF line_count <= y_max_lines-5 THEN
            BEGIN
               IF (root^.type_of_region = abs) AND
                  (loop_count > 2) THEN
               BEGIN
                  writeln;
                  line_count := line_count + 1
               END;
               loop_count := loop_count + 1;
               IF root^.seen THEN write(root^.contents)
            END
         END
         ELSE
         BEGIN
            IF (root^.type_of_region = abs) AND
               (loop_count > 2) THEN
            BEGIN
               writeln;
               line_count := line_count + 1
            END;
            loop_count := loop_count + 1;
            IF root = current^.element THEN
            BEGIN
               IF (root^.type_of_region = abs)
                  THEN
                     write('<syntax:',root^.contents,'>')
                  ELSE
                  BEGIN
                     TextColor(black);
                     TextBackground(lightgray);
                     write(root^.contents);
                     TextColor(white);
                     TextBackground(black)
                  END;
               reg_num_of_current_editable := root^.region_num;
               current_editable_found := true
            END
            ELSE
               IF root^.seen THEN write(root^.contents)
         END;
         pre_order(root^.first_child);
         pre_order(root^.next_child)
      END
   END;

BEGIN
   clrscr;
   loop_count := 0;
   line_count := 0;
   current_editable_found := false;
   header;
   pre_order(my_region)
END;

PROCEDURE new_tree;
BEGIN
   my_region := nil;
   region_count := 0
END;

PROCEDURE current_abs_region_contents(VAR current_contents : string);

VAR temp_contents : string;
    editable_found: boolean;

   PROCEDURE pre_order(root : tree_ptr);
   BEGIN
      IF root <> nil THEN
      BEGIN
         IF (root^.type_of_region = abs) AND
            (editable_found = false) THEN
            temp_contents := root^.contents;
         IF (root = current^.element) AND
            NOT(editable_found) THEN
               editable_found := true;
         pre_order(root^.first_child);
         pre_order(root^.next_child)
      END
   END;

BEGIN
   editable_found := false;
   pre_order(my_region);
   current_contents := temp_contents
END;

PROCEDURE output_to_file;

VAR temp_file : text;
    file_name : string;
    loop_count: integer;

   PROCEDURE pre_order(root : tree_ptr);
   BEGIN
      IF root <> nil THEN
      BEGIN
         IF (root^.type_of_region = abs) AND
            (loop_count > 2) THEN writeln(temp_file);
         loop_count := loop_count + 1;
         IF root^.seen THEN write(temp_file,root^.contents);
         pre_order(root^.first_child);
         pre_order(root^.next_child)
      END
   END;

BEGIN
   writeln;
   writeln('enter a filename: ');
   readln(file_name);
   assign(temp_file,file_path + file_name);
   rewrite(temp_file);
   loop_count := 0;
   pre_order(my_region);
   close(temp_file)
END;

PROCEDURE dispose_tree;

   PROCEDURE post_order(root : tree_ptr);
   BEGIN
      IF root <> nil THEN
      BEGIN
         post_order(root^.first_child);
         post_order(root^.next_child);
         dispose(root)
      END
   END;

BEGIN
   post_order(my_region)
END;

BEGIN
   TextColor(white);
   TextBackground(black)
END.