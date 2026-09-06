; Helix resolves overlapping captures to the LAST matching pattern, so the
; generic rules come first and every specialisation below overrides them.

(identifier) @variable

(type_identifier) @type

"class" @keyword.storage.type
"inherits" @keyword.storage.modifier

[
  "if"
  "then"
  "else"
  "fi"
  "case"
  "of"
  "esac"
] @keyword.control.conditional

[
  "while"
  "loop"
  "pool"
  "for"
] @keyword.control.repeat

[
  "let"
  "in"
] @keyword

[
  "new"
  "isvoid"
  "not"
] @keyword.operator

(integer) @constant.numeric.integer
(boolean) @constant.builtin.boolean
(string) @string

(line_comment) @comment.line
(block_comment) @comment.block

[
  "+"
  "-"
  "*"
  "/"
  "~"
  "<"
  "<="
  "="
  "<-"
  "=>"
  "@"
] @operator

[
  "("
  ")"
  "{"
  "}"
] @punctuation.bracket

[
  ","
  ":"
  ";"
  "."
] @punctuation.delimiter

(formal
  name: (identifier) @variable.parameter)

(attribute
  name: (identifier) @variable.other.member)

(method_definition
  name: (identifier) @function.method)

(call_expression
  name: (identifier) @function.method)

(dispatch_expression
  name: (identifier) @function.method)

(static_dispatch_expression
  name: (identifier) @function.method)

((call_expression
  name: (identifier) @function.builtin)
  (#any-of? @function.builtin
    "abort" "type_name" "copy"
    "out_string" "out_int" "in_string" "in_int"
    "length" "concat" "substr"))

((dispatch_expression
  name: (identifier) @function.builtin)
  (#any-of? @function.builtin
    "abort" "type_name" "copy"
    "out_string" "out_int" "in_string" "in_int"
    "length" "concat" "substr"))

((static_dispatch_expression
  name: (identifier) @function.builtin)
  (#any-of? @function.builtin
    "abort" "type_name" "copy"
    "out_string" "out_int" "in_string" "in_int"
    "length" "concat" "substr"))

((type_identifier) @type.builtin
  (#any-of? @type.builtin "Int" "String" "Bool" "Object" "IO" "SELF_TYPE"))

(new_expression
  type: (type_identifier) @constructor)

((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))
