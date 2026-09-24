#!/bin/bash
# Checks that formatting preserves meaning and comments, and is idempotent.
# Usage: test/fmtcheck.sh [files...]   (default: cs426-mp1 examples + test/format)

set -u

GRAMMAR_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$GRAMMAR_DIR/.." && pwd)"
QUERY="${QUERY:-$REPO/queries/formatting.scm}"

if [ -z "${MP1:-}" ]; then
    for candidate in "$GRAMMAR_DIR/cs426-mp1" "$GRAMMAR_DIR/../cs426-mp1"; do
        [ -d "$candidate/reference-binaries" ] && { MP1="$candidate"; break; }
    done
fi
if [ ! -d "${MP1:-}/reference-binaries" ]; then
    echo "$(basename "$0"): no reference-binaries under '${MP1:-<not found>}'." >&2
    echo "  run 'git submodule update --init', or set MP1 to a cs426-mp1 checkout" >&2
    exit 2
fi
BIN="$MP1/reference-binaries"

if [ $# -gt 0 ]; then files=("$@"); else files=("$MP1"/examples/*.cl "$GRAMMAR_DIR"/format/*.cl); fi

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
mkdir -p "$work/a" "$work/b"

fmt() {
    topiary format -C "$REPO/topiary/languages.ncl" -q "$QUERY" --language cool
}

ts_tree() {
    (cd "$REPO" && tree-sitter parse "$1" 2>/dev/null) | sed -E 's/ \[[0-9]+, [0-9]+\] - \[[0-9]+, [0-9]+\]//'
}

ref_tokens() {
    (cd "$1" && "$BIN/lexer" src.cl) | sed -E 's/^#[0-9]+ //'
}

ref_ast() {
    (cd "$1" && "$BIN/lexer" src.cl | "$BIN/parser") | grep -vE '^[[:space:]]*#[0-9]+$'
}

mismatch() {
    fail=$((fail + 1))
    echo "MISMATCH  $name ($1)"
    diff <(printf '%s\n' "$2") <(printf '%s\n' "$3") | head -20 | sed 's/^/    /'
}

fail=0 pass=0 skip=0 ref=0
for f in "${files[@]}"; do
    name=$(basename "$f")
    cp "$f" "$work/a/src.cl"

    if ! (cd "$REPO" && tree-sitter parse -q "$work/a/src.cl" >/dev/null 2>&1); then
        skip=$((skip + 1)); continue
    fi

    if ! fmt < "$f" > "$work/b/src.cl" 2>"$work/err"; then
        fail=$((fail + 1))
        echo "FAILED    $name (topiary)"; sed 's/^/    /' "$work/err"
        continue
    fi
    before=$fail

    again=$(fmt < "$work/b/src.cl" 2>&1)
    [ "$again" = "$(cat "$work/b/src.cl")" ] || mismatch "idempotence" "$(cat "$work/b/src.cl")" "$again"

    a=$(ts_tree "$work/a/src.cl"); b=$(ts_tree "$work/b/src.cl")
    [ "$a" = "$b" ] || mismatch "tree-sitter tree" "$a" "$b"

    if "$BIN/lexer" "$work/a/src.cl" | "$BIN/parser" >/dev/null 2>&1; then
        ref=$((ref + 1))
        a=$(ref_tokens "$work/a"); b=$(ref_tokens "$work/b")
        [ "$a" = "$b" ] || mismatch "reference tokens" "$a" "$b"
        a=$(ref_ast "$work/a"); b=$(ref_ast "$work/b")
        [ "$a" = "$b" ] || mismatch "reference AST" "$a" "$b"
    fi

    [ "$fail" -eq "$before" ] && pass=$((pass + 1))
done

broken='class A { f(): Int { if x then }; };'
out=$(printf '%s\n' "$broken" | fmt 2>/dev/null)
if [ $? -eq 0 ] || [ -n "$out" ]; then
    fail=$((fail + 1))
    echo "MISMATCH  broken input was formatted instead of rejected"
fi

if ! topiary coverage -C "$REPO/topiary/languages.ncl" -q "$QUERY" \
        --language cool < <(cat "$GRAMMAR_DIR"/format/*.cl) > "$work/coverage" 2>&1; then
    fail=$((fail + 1))
    echo "UNUSED    query patterns:"; sed 's/^/    /' "$work/coverage"
fi

echo "fmtcheck: $pass pass, $fail fail, $skip skipped (tree-sitter rejects), $ref checked against reference"
[ "$fail" -eq 0 ]
