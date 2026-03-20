#!/usr/bin/env bash
# Generate a structural code index for a project.
# Extracts exported/public symbols (functions, types, classes) from source files.
# Skips test files by default. Pass --include-tests to include them.
# Output: markdown suitable for .claude/code-index.md

set -euo pipefail

INCLUDE_TESTS=false
PROJECT_DIR=""

for arg in "$@"; do
    case "$arg" in
        --include-tests) INCLUDE_TESTS=true ;;
        *) PROJECT_DIR="$arg" ;;
    esac
done

PROJECT_DIR="${PROJECT_DIR:-.}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "Error: directory '$PROJECT_DIR' does not exist" >&2
    exit 1
fi

PROJECT_NAME=$(basename "$(cd "$PROJECT_DIR" && pwd)")

echo "# Code Index: $PROJECT_NAME"
echo "Generated: $(date +%Y-%m-%d)"
echo ""

# Get all source files, respecting .gitignore
get_files() {
    local files
    if command -v rg &>/dev/null; then
        files=$(rg --files --follow "$PROJECT_DIR" --type-add 'src:*.{go,rs,py,swift,ts,tsx,js,jsx}' -t src 2>/dev/null)
    elif [ -d "$PROJECT_DIR/.git" ]; then
        files=$(git -C "$PROJECT_DIR" ls-files -- '*.go' '*.rs' '*.py' '*.swift' '*.ts' '*.tsx' '*.js' '*.jsx' 2>/dev/null | while read -r f; do
            echo "$PROJECT_DIR/$f"
        done)
    else
        files=$(find "$PROJECT_DIR" \( -name '*.go' -o -name '*.rs' -o -name '*.py' -o -name '*.swift' -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' \) \
            -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' -not -path '*/target/*' -not -path '*/__pycache__/*' -not -path '*/.build/*')
    fi

    if [ "$INCLUDE_TESTS" = false ]; then
        files=$(echo "$files" | grep -v -E '(_test\.go|_test\.rs|test_.*\.py|.*_test\.py|\.test\.(ts|tsx|js|jsx)|\.spec\.(ts|tsx|js|jsx)|Tests?\.swift)$')
    fi

    echo "$files" | sort
}

# Extract exported/public symbols from a file based on its extension
extract_symbols() {
    local file="$1"
    local ext="${file##*.}"
    local symbols=""

    case "$ext" in
        go)
            # Only exported symbols (uppercase first letter) + types
            symbols=$(grep -E '^(func [A-Z]|func \(.*\) [A-Z]|type [A-Z].+ (struct|interface))' "$file" 2>/dev/null | \
                sed 's/func ([^)]*) /func /' | \
                sed -E 's/func ([A-Z][A-Za-z0-9_]*).*/func \1/' | \
                sed -E 's/type ([A-Z][A-Za-z0-9_]*) (struct|interface).*/type \1 \2/' | \
                head -12)
            ;;
        rs)
            symbols=$(grep -E '^pub (fn |struct |enum |trait |type |mod )' "$file" 2>/dev/null | \
                sed -E 's/pub fn ([A-Za-z_][A-Za-z0-9_]*).*/pub fn \1/' | \
                sed -E 's/pub (struct|enum|trait|type|mod) ([A-Za-z_][A-Za-z0-9_]*).*/pub \1 \2/' | \
                head -12)
            ;;
        py)
            symbols=$(grep -E '^(def [a-zA-Z]|class [A-Z])' "$file" 2>/dev/null | \
                sed -E 's/def ([A-Za-z_][A-Za-z0-9_]*).*/def \1/' | \
                sed -E 's/class ([A-Za-z_][A-Za-z0-9_]*).*/class \1/' | \
                grep -v '^def _' | \
                head -12)
            ;;
        swift)
            symbols=$(grep -E '^[[:space:]]*(public |open )?(func |class |struct |protocol |enum )' "$file" 2>/dev/null | \
                sed -E 's/.*func ([A-Za-z_][A-Za-z0-9_]*).*/func \1/' | \
                sed -E 's/.*(class|struct|protocol|enum) ([A-Za-z_][A-Za-z0-9_]*).*/\1 \2/' | \
                head -12)
            ;;
        ts|tsx|js|jsx)
            symbols=$(grep -E '^export (function |class |const |type |interface |enum )' "$file" 2>/dev/null | \
                sed -E 's/export function ([A-Za-z_][A-Za-z0-9_]*).*/export function \1/' | \
                sed -E 's/export (class|const|type|interface|enum) ([A-Za-z_][A-Za-z0-9_]*).*/export \1 \2/' | \
                head -12)
            ;;
    esac

    echo "$symbols"
}

# Group files by directory and output
file_count=0
current_dir=""
while IFS= read -r file; do
    [ -z "$file" ] && continue
    file_count=$((file_count + 1))

    # Get relative path
    rel_path="${file#$PROJECT_DIR/}"
    dir=$(dirname "$rel_path")
    base=$(basename "$rel_path")

    # Print directory header when it changes
    if [ "$dir" != "$current_dir" ]; then
        [ -n "$current_dir" ] && echo ""
        current_dir="$dir"
        echo "## $dir/"
        echo ""
    fi

    # Extract symbols
    symbols=$(extract_symbols "$file")

    if [ -n "$symbols" ]; then
        symbol_list=$(echo "$symbols" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g')
        echo "- \`$base\` — $symbol_list"
    else
        echo "- \`$base\`"
    fi

done < <(get_files)

echo ""
echo "---"
echo "*${file_count} files indexed*"
