#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/build/supergoal.app"
DEST="/Applications/supergoal.app"

"$ROOT/build.sh"
codesign --force --sign - --requirements '=designated => identifier "com.guowei.supergoal"' "$APP"
rm -rf "$DEST"
ditto "$APP" "$DEST"

echo "Installed: $DEST"
