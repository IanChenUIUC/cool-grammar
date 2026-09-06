(method_definition
  body: (_) @function.inside) @function.around

(class_definition
  [
    (method_definition)
    (attribute)
  ] @class.inside) @class.around

(formal) @parameter.inside

(argument_list
  (_) @parameter.inside)

[
  (line_comment)
  (block_comment)
] @comment.inside

[
  (line_comment)
  (block_comment)
]+ @comment.around
