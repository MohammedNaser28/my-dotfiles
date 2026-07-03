#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
SRC_DIR="$HOME/.config/scripts"
NIRI_CONFIG="$HOME/.config/niri/config.kdl"
CC="${CC:-gcc}"
CFLAGS="${CFLAGS:--O2}"

# ANSI codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }

echo "=== Build Dependencies ==="
if ! command -v "$CC" &>/dev/null; then
    fail "$CC not found. Install gcc or clang, or set \$CC."
fi
ok "Compiler: $CC ($($CC --version | head -1))"

# linux/input.h is provided by linux-api-headers on Arch
# Try compiling a minimal check
cat >/tmp/_cs_test.c <<'EOF'
#include <linux/input.h>
#include <linux/input-event-codes.h>
int main(void) { return 0; }
EOF
if ! $CC $CFLAGS -o /dev/null /tmp/_cs_test.c 2>/dev/null; then
    fail "Missing linux-api-headers. Install with: sudo pacman -S linux-api-headers"
fi
rm -f /tmp/_cs_test.c
ok "linux-api-headers found"

mkdir -p "$BIN_DIR"

echo ""
echo "=== Compiling Daemons ==="
compiled=0
skipped=0
failed=0
for src in "$SRC_DIR"/*.c; do
    [ -f "$src" ] || continue
    name=$(basename "$src" .c)
    bin="$BIN_DIR/$name"

    if [ "$src" -nt "$bin" ] || [ ! -f "$bin" ]; then
        if $CC $CFLAGS -o "$bin" "$src" 2>/tmp/_cs_err.log; then
            ok "$name → $bin"
            ((++compiled))
        else
            warn "Failed to compile $name:"
            cat /tmp/_cs_err.log >&2
            ((++failed))
        fi
    else
        ok "$name up-to-date"
        ((++skipped))
    fi
done
rm -f /tmp/_cs_err.log

echo ""
echo "=== Summary ==="
echo "  Compiled: $compiled   Skipped: $skipped   Failed: $failed"

echo ""
echo "=== Niri Config ==="
if [ -f "$NIRI_CONFIG" ]; then
    if grep -q 'spawn.*cursor-speeder' "$NIRI_CONFIG"; then
        ok "cursor-speeder spawn entry found"
    else
        warn "cursor-speeder spawn entry MISSING — add:"
        echo '  spawn-at-startup "sh" "-c" "sleep 2 && cursor-speeder"'
    fi
    if grep -q 'include optional=true.*cursor-override.kdl' "$NIRI_CONFIG"; then
        ok "cursor-override include found"
    else
        warn "cursor-override include MISSING — add at end of config:"
        echo '  include optional=true "cursor-override.kdl"'
    fi
else
    warn "Niri config not found at $NIRI_CONFIG"
fi

echo ""
echo "=== Done ==="
exit "$failed"
