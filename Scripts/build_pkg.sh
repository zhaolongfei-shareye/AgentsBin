#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

./Scripts/build_app.sh release

VERSION="1.0.0"
APP="$ROOT/dist/build/AgentBin.app"
COMPONENT="$ROOT/dist/AgentBin-component.pkg"
FINAL="$ROOT/dist/AgentBin-$VERSION.pkg"
RES="$(mktemp -d)"

cat > "$RES/welcome.html" <<'HTML'
<!DOCTYPE html>
<html lang="zh">
<head><meta charset="utf-8"><style>body{font-family:-apple-system,sans-serif;font-size:13px;line-height:1.6;color:#1d1d1f}</style></head>
<body>
<h2>欢迎安装 AgentBin</h2>
<p>AgentBin 是一个 macOS 菜单栏 AI 智能体聚合工具，安装后可从菜单栏的 “AB” 图标打开。</p>
<p>安装位置：/Applications</p>
</body>
</html>
HTML

cat > "$RES/readme.txt" <<'TXT'
AgentBin 1.0.0

安装后：
1. 点击菜单栏右上角 “AB” 图标打开主窗口。
2. 在左侧选择智能体开始对话。
3. 使用底部“收藏”按钮把回复存入知识库。

数据保存在 ~/Library/Application Support/AIHub/。
TXT

cat > "$RES/license.txt" <<'TXT'
AgentBin 使用许可

本软件按现状提供，仅限个人使用。不得用于商业再分发、逆向工程或恶意用途。
TXT

cat > "$RES/distribution.xml" <<'XML'
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="1">
  <pkg-ref id="com.agentbin.app"/>
  <title>AgentBin</title>
  <options customize="never" require-scripts="false" hostArchitectures="x86_64,arm64"/>
  <domains enable_anywhere="false" enable_currentUserHome="false" enable_localSystem="true"/>
  <welcome file="welcome.html"/>
  <readme file="readme.txt"/>
  <license file="license.txt"/>
  <choices-outline>
    <line choice="default">
      <line choice="com.agentbin.app"/>
    </line>
  </choices-outline>
  <choice id="default"/>
  <choice id="com.agentbin.app" visible="false">
    <pkg-ref id="com.agentbin.app"/>
  </choice>
  <pkg-ref id="com.agentbin.app" version="1.0.0" onConclusion="none">AgentBin-component.pkg</pkg-ref>
</installer-gui-script>
XML

pkgbuild \
  --component "$APP" \
  --identifier com.agentbin.app \
  --version "$VERSION" \
  --install-location /Applications \
  "$COMPONENT"

productbuild \
  --distribution "$RES/distribution.xml" \
  --resources "$RES" \
  --package-path "$ROOT/dist" \
  "$FINAL"

rm -f "$COMPONENT"
rm -rf "$RES"

echo "Built: $FINAL"
