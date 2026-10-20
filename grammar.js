const PREC = {
  let: 1,
  assign: 2,
  not: 3,
  compare: 4,
  add: 5,
  mul: 6,
  isvoid: 7,
  neg: 8,
  static_dispatch: 9,
  dispatch: 10,
};

function ci(word) {
  return new RegExp(
    word
      .split('')
      .map((c) => `[${c.toLowerCase()}${c.toUpperCase()}]`)
      .join(''),
  );
}

function kw(word) {
  return alias(ci(word), word);
}

function commaSep1(rule) {
  return seq(rule, repeat(seq(',', rule)));
}

function commaSep(rule) {
  return optional(commaSep1(rule));
}

module.exports = grammar({
  name: 'cool',

  extras: ($) => [/\s/, $.line_comment, $.block_comment],

  externals: ($) => [$.block_comment, $.string],

  supertypes: ($) => [$._expression],

  rules: {
    source_file: ($) => repeat($.class_definition),

    class_definition: ($) =>
      seq(
        kw('class'),
        field('name', $.type_identifier),
        optional(seq(kw('inherits'), field('superclass', $.type_identifier))),
        '{',
        repeat(seq($._feature, ';')),
        '}',
        ';',
      ),

    _feature: ($) => choice($.method_definition, $.attribute),

    method_definition: ($) =>
      seq(
        field('name', $.identifier),
        '(',
        commaSep($.formal),
        ')',
        ':',
        field('type', $.type_identifier),
        '{',
        field('body', $._expression),
        '}',
      ),

    formal: ($) =>
      seq(field('name', $.identifier), ':', field('type', $.type_identifier)),

    attribute: ($) =>
      seq(
        field('name', $.identifier),
        ':',
        field('type', $.type_identifier),
        optional(seq('<-', field('value', $._expression))),
      ),

    binding: ($) =>
      seq(
        field('name', $.identifier),
        ':',
        field('type', $.type_identifier),
        optional(seq('<-', field('value', $._expression))),
      ),

    _expression: ($) =>
      choice(
        $.assignment_expression,
        $.static_dispatch_expression,
        $.dispatch_expression,
        $.call_expression,
        $.conditional_expression,
        $.while_expression,
        $.for_expression,
        $.block,
        $.let_expression,
        $.case_expression,
        $.new_expression,
        $.isvoid_expression,
        $.binary_expression,
        $.unary_expression,
        $.parenthesized_expression,
        $.identifier,
        $.integer,
        $.string,
        $.boolean,
      ),

    assignment_expression: ($) =>
      prec.right(
        PREC.assign,
        seq(field('left', $.identifier), '<-', field('right', $._expression)),
      ),

    static_dispatch_expression: ($) =>
      prec.left(
        PREC.static_dispatch,
        seq(
          field('object', $._expression),
          '@',
          field('type', $.type_identifier),
          '.',
          field('name', $.identifier),
          field('arguments', $.argument_list),
        ),
      ),

    dispatch_expression: ($) =>
      prec.left(
        PREC.dispatch,
        seq(
          field('object', $._expression),
          '.',
          field('name', $.identifier),
          field('arguments', $.argument_list),
        ),
      ),

    call_expression: ($) =>
      seq(field('name', $.identifier), field('arguments', $.argument_list)),

    argument_list: ($) => seq('(', commaSep($._expression), ')'),

    conditional_expression: ($) =>
      seq(
        kw('if'),
        field('condition', $._expression),
        kw('then'),
        field('consequence', $._expression),
        kw('else'),
        field('alternative', $._expression),
        kw('fi'),
      ),

    while_expression: ($) =>
      seq(
        kw('while'),
        field('condition', $._expression),
        kw('loop'),
        field('body', $._expression),
        kw('pool'),
      ),

    for_expression: ($) =>
      seq(
        kw('for'),
        '(',
        commaSep1($.binding),
        ';',
        field('condition', $._expression),
        ';',
        field('update', $._expression),
        ')',
        '{',
        field('body', $._expression),
        '}',
      ),

    block: ($) => seq('{', repeat1(seq($._expression, ';')), '}'),

    let_expression: ($) =>
      prec.right(
        PREC.let,
        seq(
          kw('let'),
          commaSep1($.binding),
          kw('in'),
          field('body', $._expression),
        ),
      ),

    case_expression: ($) =>
      seq(
        kw('case'),
        field('value', $._expression),
        kw('of'),
        repeat1($.case_branch),
        kw('esac'),
      ),

    case_branch: ($) =>
      seq(
        field('name', $.identifier),
        ':',
        field('type', $.type_identifier),
        '=>',
        field('body', $._expression),
        ';',
      ),

    new_expression: ($) => seq(kw('new'), field('type', $.type_identifier)),

    isvoid_expression: ($) =>
      prec.right(
        PREC.isvoid,
        seq(field('operator', kw('isvoid')), field('operand', $._expression)),
      ),

    binary_expression: ($) => {
      const table = [
        [PREC.compare, choice('<=', '<', '=')],
        [PREC.add, choice('+', '-')],
        [PREC.mul, choice('*', '/')],
      ];
      return choice(
        ...table.map(([precedence, operator]) =>
          prec.left(
            precedence,
            seq(
              field('left', $._expression),
              field('operator', operator),
              field('right', $._expression),
            ),
          ),
        ),
      );
    },

    unary_expression: ($) =>
      choice(
        prec.right(
          PREC.neg,
          seq(field('operator', '~'), field('operand', $._expression)),
        ),
        prec.right(
          PREC.not,
          seq(field('operator', kw('not')), field('operand', $._expression)),
        ),
      ),

    parenthesized_expression: ($) => seq('(', $._expression, ')'),

    boolean: (_) => token(choice(/t[rR][uU][eE]/, /f[aA][lL][sS][eE]/)),

    // Must stay below every keyword and literal rule: equal-length lexer ties break by rule order.
    type_identifier: (_) => /[A-Z][A-Za-z0-9_]*/,

    identifier: (_) => /[a-z][A-Za-z0-9_]*/,

    integer: (_) => token(choice(/0x[0-9a-f]+/, /[0-9]+/)),

    line_comment: (_) => /--[^\n]*/,
  },
});
