#!/bin/bash

set -u

GRAMMAR_DIR="$(cd "$(dirname "$0")" && pwd)"

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
EXAMPLES="${EXAMPLES:-$MP1/examples}"

query=$(mktemp); trap 'rm -f "$query"' EXIT
cat > "$query" <<'Q'
(type_identifier) @type_identifier
(identifier) @identifier
(integer) @integer
(boolean) @boolean
(string) @string
Q

fail=0 pass=0 skip=0
for f in "$EXAMPLES"/*.cl; do
    if ! "$BIN/lexer" "$f" | "$BIN/parser" >/dev/null 2>&1; then
        skip=$((skip + 1)); skipped+=" $(basename "$f")"; continue
    fi

    ref=$("$BIN/lexer" "$f" | awk '
        $2 == "TYPEID"     { print "type_identifier " $3; next }
        $2 == "OBJECTID"   { print "identifier "      $3; next }
        $2 == "INT_CONST"  { print "integer";              next }
        $2 == "BOOL_CONST" { print "boolean "        $3;   next }
        $2 == "STR_CONST"  { print "string";               next }')

    ts=$(cd "$GRAMMAR_DIR" && tree-sitter query "$query" "$f" 2>/dev/null | awk '
        match($0, /capture: ([0-9]+ - )?([a-z_]+),/, m) {
            type = m[2]
            if (type == "integer" || type == "string") { print type; next }
            if (match($0, /text: `(.*)`$/, t)) print type " " t[1]; else print type
        }')

    if [ "$ref" = "$ts" ]; then
        pass=$((pass + 1))
    else
        fail=$((fail + 1))
        echo "MISMATCH  $(basename "$f")"
        diff <(printf '%s\n' "$ref") <(printf '%s\n' "$ts") | sed 's/^/    /'
    fi
done

echo "difftest: $pass agree, $fail disagree, $skip skipped (reference parser rejects)"
[ "$fail" -eq 0 ]
