#!/bin/sh
# Сборка run_luajit (хост: LuaJIT из Pascal) на Linux/Unix.
# Требуется: FPC, libluajit-5.1.so.2 (или совместимый SONAME) в LD_LIBRARY_PATH при запуске.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$SCRIPT_DIR/src"
EXAMPLE_DIR="$SCRIPT_DIR/example"

if [ -z "$FPCDIR" ]; then
  FPC_BIN="$(command -v fpc 2>/dev/null)"
  if [ -n "$FPC_BIN" ]; then
    FPC_ROOT="$(cd "$(dirname "$FPC_BIN")/../.." 2>/dev/null && pwd)"
    if [ -d "$FPC_ROOT/units" ]; then
      export FPCDIR="$FPC_ROOT"
    fi
  fi
fi

echo "Building run_luajit (LuaJIT host)..."
fpc -MObjFPC -Scghi -O2 -Tlinux -Px86_64 -Fu"$SRC_DIR" -Fi"$SRC_DIR" -FE"$EXAMPLE_DIR" "$EXAMPLE_DIR/run_luajit.lpr"
if [ $? -ne 0 ]; then exit 1; fi

echo ""
echo "Output: $EXAMPLE_DIR/run_luajit"
echo "Run: cd example && ./run_luajit [script.lua]"
echo "Ensure libluajit-5.1.so.2 (or your distro SONAME) is found by the dynamic linker."
