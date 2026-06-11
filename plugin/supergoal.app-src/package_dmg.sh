#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP="$ROOT/build/supergoal.app"
VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$ROOT/Info.plist")"
ARTIFACT_DIR="$ROOT/release"
STAGE_DIR="$ROOT/build/dmg-stage"
DMG="$ARTIFACT_DIR/SuperGoal-v${VERSION}.dmg"

"$ROOT/build.sh"
codesign --force --sign - --requirements '=designated => identifier "com.guowei.supergoal"' "$APP"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR" "$ARTIFACT_DIR"
ditto "$APP" "$STAGE_DIR/supergoal.app"
ln -s /Applications "$STAGE_DIR/Applications"

rm -f "$DMG"
hdiutil create \
  -volname "SuperGoal" \
  -srcfolder "$STAGE_DIR" \
  -ov \
  -format UDZO \
  "$DMG"

codesign --verify --deep --strict "$STAGE_DIR/supergoal.app"
echo "Packaged: $DMG"
