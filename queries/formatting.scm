; Leaves, comments, keyword case

[(string) (line_comment) (block_comment)] @leaf

[(line_comment) (block_comment)] @prepend_input_softline
(line_comment) @append_hardline
(block_comment) @append_input_softline

[(class_definition) (method_definition) (attribute)
 (line_comment) (block_comment)] @allow_blank_line_before
(block (_) @allow_blank_line_before)

["class" "inherits" "if" "then" "else" "fi" "while" "loop" "pool" "for"
 "let" "in" "case" "of" "esac" "new" "isvoid" "not"] @lower_case
(boolean) @lower_case

; Spacing

"," @append_space
(binary_expression operator: _ @prepend_space @append_space)
["<-" "=>"] @prepend_space @append_space
(formal ":" @append_space)
(attribute ":" @append_space)
(binding ":" @append_space)
(case_branch ":" @append_space)
(method_definition ":" @append_space)
["not" "isvoid" "new"] @append_space

; Class: always broken, one feature per line

(class_definition "class" @append_space)
(class_definition "inherits" @prepend_space @append_space)
(class_definition "{" @prepend_hardline @append_indent_start)
(class_definition
  "{" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(class_definition "}" @prepend_indent_end @prepend_hardline)
(class_definition
  ";" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)

; Method: body always on its own indented lines

(method_definition "{" @prepend_hardline @append_indent_start)
(method_definition
  "{" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(method_definition "}" @prepend_indent_end @prepend_hardline)

; Block: always broken, one expression per line

(block "{" @prepend_hardline @append_indent_start)
(block
  "{" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(block
  ";" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(block "}" @prepend_indent_end @prepend_hardline)

; while / for: always broken

(while_expression "while" @append_space)
(while_expression "loop" @prepend_space @append_indent_start)
(while_expression
  "loop" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(while_expression "pool" @prepend_indent_end @prepend_hardline)

(for_expression "for" @append_space)
(for_expression ";" @append_space)
(for_expression "{" @prepend_hardline @append_indent_start)
(for_expression
  "{" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(for_expression "}" @prepend_indent_end @prepend_hardline)

; case: always broken, one branch per line

(case_expression "case" @append_space)
(case_expression "of" @prepend_space @append_indent_start)
(case_expression
  "of" @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(case_expression
  (case_branch) @append_hardline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(case_expression "esac" @prepend_indent_end)

; if / let / arguments: broken only if broken in the input

(conditional_expression "if" @append_space)
(conditional_expression "then" @prepend_space)
(conditional_expression
  "then" @append_spaced_softline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(conditional_expression "then" @append_indent_start)
(conditional_expression "else" @prepend_spaced_softline)
(conditional_expression
  "else" @append_spaced_softline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(conditional_expression "else" @prepend_indent_end @append_indent_start)
(conditional_expression "fi" @prepend_spaced_softline)
(conditional_expression "fi" @prepend_indent_end)

(let_expression "let" @append_space)
(let_expression "in" @prepend_space)
(let_expression
  "in" @append_spaced_softline
  .
  [(line_comment) (block_comment)]? @do_nothing)

(argument_list "(" @append_indent_start)
(argument_list
  "(" @append_empty_softline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(argument_list
  "," @append_spaced_softline
  .
  [(line_comment) (block_comment)]? @do_nothing)
(argument_list ")" @prepend_indent_end @prepend_empty_softline)
