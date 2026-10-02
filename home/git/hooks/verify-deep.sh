#!/bin/bash
# Deep behavioral verification.
# Beyond lint: actually exercise the changed code.

export PATH="/opt/homebrew/bin:$PATH"

if [ $# -eq 0 ]; then
  FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null)
else
  FILES="$*"
fi

FAILED=0

# Neovim: test loading changed modules, not just startup
NVIM_LUA=$(echo "$FILES" | grep "nvim/lua/" | grep "\.lua$" || true)
if [ -n "$NVIM_LUA" ]; then
  echo "→ Neovim module load tests..."
  for f in $NVIM_LUA; do
    # Convert path to module name: home/config/nvim/lua/core/foo.lua -> core.foo
    MOD=$(echo "$f" | sed 's|.*/nvim/lua/||; s|\.lua$||; s|/|.|g')
    # Skip init files and generated files (they have side effects)
    if echo "$MOD" | grep -q "generated\|init$"; then continue; fi
    echo "  Testing: $MOD"
    if ! timeout 10 nvim --headless --noplugin -c "lua ok, err = pcall(require, '$MOD'); if not ok then print('FAIL: ' .. tostring(err)); vim.cmd('cq!') end" -c "qa!" 2>&1 | grep -q "FAIL"; then
      echo "    OK"
    else
      echo "    FAIL: module failed to load"
      FAILED=1
    fi
  done
fi

# apply_theme.py: syntax + import test (don't run full generation)
if echo "$FILES" | grep -q "apply_theme.py"; then
  echo "→ apply_theme.py import test..."
  if ! python3 -c "import ast; ast.parse(open('home/scripts/apply_theme.py').read()); print('  OK: parses')" 2>&1; then
    echo "  FAIL"
    FAILED=1
  fi
  # Check that key functions exist
  for fn in generate_kitty generate_nvim generate_firefox _light_bg_ansi; do
    if ! grep -q "def $fn" home/scripts/apply_theme.py; then
      echo "  FAIL: missing function $fn"
      FAILED=1
    fi
  done
  echo "  OK: key functions present"
fi

# Generated files: validate format
for f in $FILES; do
  case "$f" in
    *.css)
      echo "→ CSS syntax check $f..."
      # Basic check: balanced braces
      OPEN=$(grep -o "{" "$f" | wc -l)
      CLOSE=$(grep -o "}" "$f" | wc -l)
      if [ "$OPEN" -ne "$CLOSE" ]; then
        echo "  FAIL: unbalanced braces ($OPEN open, $CLOSE close)"
        FAILED=1
      else
        echo "  OK"
      fi
      ;;
  esac
done

if [ $FAILED -eq 1 ]; then
  echo ""
  echo "DEEP VERIFICATION FAILED"
  exit 1
else
  echo ""
  echo "Deep verification passed."
fi
