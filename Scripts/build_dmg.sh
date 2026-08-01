#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

./Scripts/build_app.sh release

VERSION="1.0.0"
DMG_DIR="$ROOT/dist/dmg"
APP="$ROOT/dist/build-new/AgentsBin.app"
DMG="$ROOT/dist/AgentsBin-$VERSION.dmg"

rm -rf "$DMG_DIR" "$DMG"
mkdir -p "$DMG_DIR"
cp -R "$APP" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

hdiutil create -volname "AgentsBin" -srcfolder "$DMG_DIR" -ov -format UDZO "$DMG" >/dev/null
rm -rf "$DMG_DIR"

echo "Built: $DMG"
