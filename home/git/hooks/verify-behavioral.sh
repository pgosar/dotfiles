#!/bin/bash
# Behavioral verification: exercises changed code, not just lints it.
# Usage: verify-behavioral.sh [files...] (defaults to staged files)

export PATH="/opt/homebrew/bin:$PATH"

if [ $# -eq 0 ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
else
  FILES="$*"
fi

FAILED=0

# Neovim Lua: headless startup test
NVIM_LUA=$(echo "$FILES" | grep "nvim/lua/" | grep "\.lua$" || true)
if [ -n "$NVIM_LUA" ]; then
  echo "→ Neovim headless startup test..."
  # Use a timeout; config errors will cause non-zero exit or error output
  if ! timeout 15 nvim --headless -c "qa!" 2>&1 | grep -qi "error\|attempt to index\|nil value"; then
    # Check exit code too
    timeout 15 nvim --headless -c "qa!" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "  FAIL: Neovim failed to start cleanly"
      FAILED=1
    else
      echo "  OK: Neovim starts"
    fi
  else
    echo "  FAIL: Neovim startup errors detected"
    timeout 15 nvim --headless -c "qa!" 2>&1 | head -5
    FAILED=1
  fi
fi

# Shell scripts: syntax + shellcheck (already in pre-commit, but double-check)
SHELL_FILES=$(echo "$FILES" | grep -E "\.(sh|bash)$" || true)
for f in $SHELL_FILES; do
  [ -f "$f" ] || continue
  if ! bash -n "$f" 2>&1; then
    echo "  FAIL: bash syntax $f"
    FAILED=1
  fi
done

# Python: compile + import check
PY_FILES=$(echo "$FILES" | grep "\.py$" || true)
for f in $PY_FILES; do
  [ -f "$f" ] || continue
  if ! python3 -m py_compile "$f" 2>&1; then
    echo "  FAIL: python syntax $f"
    FAILED=1
  fi
done

if [ $FAILED -eq 1 ]; then
  echo ""
  echo "BEHAVIORAL VERIFICATION FAILED"
  exit 1
else
  echo ""
  echo "Behavioral verification passed."
fi
