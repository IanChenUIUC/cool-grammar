#include "tree_sitter/parser.h"

// Order must match `externals` in grammar.js.
enum TokenType {
  BLOCK_COMMENT,
  STRING,
};

static void advance(TSLexer *lexer) { lexer->advance(lexer, false); }

static bool scan_block_comment(TSLexer *lexer) {
  if (lexer->lookahead != '(') return false;
  advance(lexer);
  if (lexer->lookahead != '*') return false;
  advance(lexer);

  unsigned depth = 1;
  while (depth > 0 && !lexer->eof(lexer)) {
    if (lexer->lookahead == '(') {
      advance(lexer);
      if (lexer->lookahead == '*') {
        advance(lexer);
        depth++;
      }
    } else if (lexer->lookahead == '*') {
      advance(lexer);
      if (lexer->lookahead == ')') {
        advance(lexer);
        depth--;
      }
    } else {
      advance(lexer);
    }
  }

  lexer->result_symbol = BLOCK_COMMENT;
  return true;
}

static bool scan_triple_quoted(TSLexer *lexer) {
  unsigned quotes = 0;
  while (quotes < 3 && !lexer->eof(lexer)) {
    if (lexer->lookahead == '\\') {
      advance(lexer);
      if (lexer->eof(lexer)) break;
      advance(lexer);
      quotes = 0;
    } else if (lexer->lookahead == '"') {
      advance(lexer);
      quotes++;
    } else {
      advance(lexer);
      quotes = 0;
    }
  }
  return true;
}

static bool scan_string(TSLexer *lexer) {
  if (lexer->lookahead != '"') return false;
  advance(lexer);

  if (lexer->lookahead == '"') {
    advance(lexer);
    if (lexer->lookahead == '"') {
      advance(lexer);
      scan_triple_quoted(lexer);
    }
    lexer->result_symbol = STRING;
    return true;
  }

  while (!lexer->eof(lexer) && lexer->lookahead != '\n') {
    if (lexer->lookahead == '\\') {
      advance(lexer);
      if (lexer->eof(lexer)) break;
      advance(lexer);
    } else if (lexer->lookahead == '"') {
      advance(lexer);
      break;
    } else {
      advance(lexer);
    }
  }

  lexer->result_symbol = STRING;
  return true;
}

void *tree_sitter_cool_external_scanner_create(void) { return NULL; }

void tree_sitter_cool_external_scanner_destroy(void *payload) { (void)payload; }

unsigned tree_sitter_cool_external_scanner_serialize(void *payload, char *buffer) {
  (void)payload;
  (void)buffer;
  return 0;
}

void tree_sitter_cool_external_scanner_deserialize(void *payload, const char *buffer,
                                                   unsigned length) {
  (void)payload;
  (void)buffer;
  (void)length;
}

bool tree_sitter_cool_external_scanner_scan(void *payload, TSLexer *lexer,
                                            const bool *valid_symbols) {
  (void)payload;

  while (!lexer->eof(lexer) &&
         (lexer->lookahead == ' ' || lexer->lookahead == '\t' ||
          lexer->lookahead == '\n' || lexer->lookahead == '\r')) {
    lexer->advance(lexer, true);
  }

  if (valid_symbols[BLOCK_COMMENT] && lexer->lookahead == '(') {
    return scan_block_comment(lexer);
  }
  if (valid_symbols[STRING] && lexer->lookahead == '"') {
    return scan_string(lexer);
  }
  return false;
}
