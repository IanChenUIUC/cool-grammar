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

(method_definition
  name: (identifier) @function.method)

(call_expression
  name: (identifier) @function.method)

(dispatch_expression
  name: (identifier) @function.method)

(static_dispatch_expression
  name: (identifier) @function.method)

(formal
  name: (identifier) @variable.parameter)

(attribute
  name: (identifier) @variable.other.member)

((type_identifier) @type.builtin
  (#any-of? @type.builtin "Int" "String" "Bool" "Object" "IO" "SELF_TYPE"))

(type_identifier) @type

((identifier) @variable.builtin
  (#eq? @variable.builtin "self"))

(identifier) @variable

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
