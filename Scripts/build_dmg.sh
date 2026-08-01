#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

./Scripts/build_app.sh release

VERSION="$(cat "$ROOT/version.txt")"
DMG_DIR="$ROOT/dist/dmg"
APP="$ROOT/dist/build-new/AgentsBin.app"
DMG="$ROOT/dist/AgentsBin-$VERSION.dmg"

rm -rf "$DMG_DIR" "$DMG"
mkdir -p "$DMG_DIR"
cp -R "$APP" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

RW="$ROOT/dist/AgentsBin-rw.dmg"
MOUNT="/tmp/agentsbin-dmg-mount"
rm -rf "$MOUNT"
hdiutil create -volname "AgentsBin" -srcfolder "$DMG_DIR" -ov -format UDRW "$RW" >/dev/null
hdiutil attach "$RW" -nobrowse -mountpoint "$MOUNT" >/dev/null
cp "$ROOT/Assets/AppIcon.icns" "$MOUNT/.VolumeIcon.icns"
SetFile -a C "$MOUNT"
hdiutil detach -force "$MOUNT" >/dev/null
rm -f "$DMG"
hdiutil convert "$RW" -format UDZO -o "$DMG" >/dev/null
rm -f "$RW"
rm -rf "$DMG_DIR" "$MOUNT"

echo "Built: $DMG"
