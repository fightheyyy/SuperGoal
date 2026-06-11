#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/build/supergoal.app"
DEST="/Applications/supergoal.app"

"$ROOT/build.sh"
codesign --force --sign - --requirements '=designated => identifier "com.guowei.supergoal"' "$APP"
rm -rf "$DEST"
ditto "$APP" "$DEST"
touch "$DEST"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DEST" >/dev/null 2>&1 || true

echo "Installed: $DEST"
