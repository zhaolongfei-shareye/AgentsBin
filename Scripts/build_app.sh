#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CONFIG="${1:-release}"
swift build -c "$CONFIG"

VERSION_FILE="$ROOT/version.txt"
if [ ! -f "$VERSION_FILE" ]; then
  echo "1.0.0" > "$VERSION_FILE"
fi
CURRENT_VERSION="$(cat "$VERSION_FILE")"
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
PATCH=$((PATCH + 1))
VERSION="$MAJOR.$MINOR.$PATCH"
echo "$VERSION" > "$VERSION_FILE"

APP="$ROOT/dist/build-new/AgentsBin.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

BIN="$(swift build -c "$CONFIG" --show-bin-path)/AIHub"
cp "$BIN" "$APP/Contents/MacOS/AIHub"
if [ -f "$ROOT/Assets/AppIcon.icns" ]; then
  cp "$ROOT/Assets/AppIcon.icns" "$APP/Contents/Resources/AppIcon.icns"
fi
if [ -f "$ROOT/Assets/MenuBarIcon.png" ]; then
  cp "$ROOT/Assets/MenuBarIcon.png" "$APP/Contents/Resources/MenuBarIcon.png"
fi
if [ -d "$ROOT/Assets/AgentIcons" ]; then
  mkdir -p "$APP/Contents/Resources/BuiltinFavicons"
  cp "$ROOT"/Assets/AgentIcons/*.png "$APP/Contents/Resources/BuiltinFavicons/"
fi

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>AIHub</string>
  <key>CFBundleIdentifier</key>
  <string>com.agentsbin.app</string>
  <key>CFBundleName</key>
  <string>AgentsBin</string>
  <key>CFBundleDisplayName</key>
  <string>AgentsBin</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$PATCH</string>
  <key>CFBundleGetInfoString</key>
  <string>$VERSION (免费内测版)</string>
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
  </dict>
</dict>
</plist>
PLIST

if command -v codesign >/dev/null 2>&1; then
  codesign --force --deep --sign - "$APP" >/dev/null 2>&1 || true
fi

echo "Built: $APP"
