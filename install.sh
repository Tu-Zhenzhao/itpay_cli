#!/usr/bin/env sh
set -eu

SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ITP_BIN="$SOURCE_DIR/bin/itp"
PREFIX="${ITP_PREFIX:-$HOME/.local}"
TARGET_DIR="$PREFIX/bin"
TARGET="$TARGET_DIR/itp"

if [ ! -f "$ITP_BIN" ]; then
  echo "itp binary not found at $ITP_BIN" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
chmod +x "$ITP_BIN"
cp "$ITP_BIN" "$TARGET"
chmod +x "$TARGET"

case ":$PATH:" in
  *":$TARGET_DIR:"*) ;;
  *)
    echo "Installed itp to $TARGET"
    echo "Add $TARGET_DIR to PATH before running itp."
    exit 0
    ;;
esac

"$TARGET" --version
