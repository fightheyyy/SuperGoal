#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/build/supergoal.app"

swift "$ROOT/Scripts/make_icons.swift" "$ROOT"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

swiftc \
  -O \
  -framework AppKit \
  -framework Carbon \
  -framework Security \
  "$ROOT/Sources/main.swift" \
  -o "$APP/Contents/MacOS/supergoal"

cp "$ROOT/Info.plist" "$APP/Contents/Info.plist"
if [ -d "$ROOT/Assets" ]; then
  cp "$ROOT"/Assets/* "$APP/Contents/Resources/"
fi

echo "Built: $APP"
