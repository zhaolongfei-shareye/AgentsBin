# AgentsBin 开发工作流与排坑指南

维护日期：2026-08-02 · 当前版本：1.1.0

---

## 1. 强制工作流

1. UI 改动：先出英文效果图（HTML + 无头浏览器截图），等用户确认后再写代码
2. 开发：只改 `Sources/AIHub`（应用）或 `site/`（官网），保持改动聚焦
3. 本地验证：构建 → 校验和 → 挂载 → 启动，全部通过才算完成
4. 部署：必须等用户明确指令；部署后主动刷新 CDN 缓存并验证下载
5. 多语言：任何新增文案都要同步 10 种语言（App 与官网一致）
6. 每轮发布：版本递增 → 打包 → 本地验证 → 更新官网 → 部署 → 线上验证 → 提交

---

## 2. 相关依赖清单

| 依赖 | 位置/版本 | 用途 |
| --- | --- | --- |
| Swift 工具链 | `~/Library/Developer/Toolchains/swift-6.3.2-RELEASE.xctoolchain` | 编译（系统 6.3.3 不可用） |
| macOS SDK | `/Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk` | 系统框架 |
| Xcode | 未安装（仅有 CommandLineTools） | App Store 上架仍需安装 |
| Python 3 + PIL | 系统 Python | 图标批量下载/转换、脚本 |
| Headless Chrome | `~/Library/Caches/ms-playwright/chromium_headless_shell-1234/.../chrome-headless-shell` | 效果图与图标渲染 |
| Cloudflare Wrangler | `npx wrangler@latest` | Pages 部署、D1、secrets |
| Cloudflare Pages | 项目 `agentsbin` | 官网托管 + Functions |
| Cloudflare D1 | `agentsbin-stats` | 统计真实数据 |
| Google OAuth | Client ID / Secret（Pages secrets） | 统计后台登录 |
| GitHub | `zhaolongfei-shareye/AgentsBin` | 代码仓库 |
| SwiftPM | `Package.swift` | 应用构建 |
| SQLite3 / Keychain | 系统库 | 数据存储（现已改为本地 AES） |

---

## 3. 构建与打包

```bash
export PATH="$HOME/Library/Developer/Toolchains/swift-6.3.2-RELEASE.xctoolchain/usr/bin:$PATH"
swift build -c release
./Scripts/build_dmg.sh
```

- 产物：`dist/AgentsBin-<版本>.dmg`
- `build_dmg.sh` 会把 `version.txt` 的 PATCH 自动 +1
- 要发布指定版本（如 1.1.0）：
  1. 先写 `version.txt` 为目标版本
  2. 临时把 `build_app.sh` 中 `PATCH=$((PATCH + 1))` 改为 `PATCH=$((PATCH + 0))`
  3. 构建后 `git checkout Scripts/build_app.sh` 恢复

---

## 4. 本地验证（部署前必做）

```bash
shasum -a 256 dist/AgentsBin-<v>.dmg
hdiutil verify dist/AgentsBin-<v>.dmg          # 必须 VALID
hdiutil attach ...                              # 检查 .app 与 Applications
plutil -p .../Contents/Info.plist              # 确认 CFBundleShortVersionString
open .../AgentsBin.app && sleep 4 && pgrep -fl AIHub
# 结束：pkill + hdiutil detach
```

---

## 5. 官网部署

```bash
cp dist/AgentsBin-<v>.dmg site/downloads/
git rm -q site/downloads/AgentsBin-<旧>.dmg
# 更新 site/index.html（版本、SHA-256、文案）、site/app.js（10 语言版本字符串）、docs/
npx wrangler pages deploy site --project-name agentsbin --branch main
```

部署后：

1. 循环下载并比对 SHA，直到与本地一致（CDN 可能要重试几次）
2. `hdiutil verify` 线上包 + 挂载 + 启动
3. 资源引用建议带版本参数：`styles.css?v=1.1.0`、`app.js?v=1.1.0`

---

## 6. 踩过的坑（按类别）

### 6.1 构建环境

- 系统 `swiftc` 6.3.3 与 SDK 6.3.2 模块不匹配，`swift build` 报 `SwiftShims` / `_errno` / `CoreFoundation` 错误。解决：安装 Swift 6.3.2 官方工具链到用户 Toolchains 目录，用绝对路径调用。
- 不要用旧 SDK（MacOSX15.sdk）硬编，SwiftUI 模块是 arm64e 新格式，老编译器读不了。
- 项目目录改名（AI导航 → AgentsBin）后，沙箱 writable root 仍指向旧路径，`apply_patch` 无法访问新路径；编辑需用带权限的 shell/python。

### 6.2 打包与发布

- 曾出现官网下载 17KB HTML：DMG 没复制进 `site/downloads/`，线上 404 走 SPA fallback。发布前必须 `ls site/downloads/` 确认文件存在。
- CDN 会缓存旧 fallback（`max-age=3600`），部署后立即下载可能拿到旧文件。用 no-cache 请求或循环重试刷新。
- 版本字符串曾在 `app.js` 遗留 1.0.22（多次替换没覆盖），导致官网显示旧版本。发布时用脚本全局替换并核对。
- 用户安装新版仍看到旧版：旧进程未退出 + 首页未重置。解决：`AppDelegate` 启动时杀掉同 Bundle 旧实例；版本号变化时重置 `setupDone` 重新显示首页。

### 6.3 界面与交互

- 浮层默认在 ZStack 中垂直居中 → 改为 `ZStack(alignment: .topLeading)` 才能钉在箭头下方。
- SwiftUI `onHover` 在透明视图/Button 上不可靠 → 用 `NSTrackingArea`（`HoverSensorView`）。
- 给整个浮层加 `NSTrackingArea` overlay 会拦截点击，智能体切换失效 → 只能给左缘感应条用原生跟踪，面板自身用 `onHover`。
- 系统 segmented Picker 不支持自定义圆点 → 改自绘分段按钮。
- 窗口左缘 resize 区域会抢占 hover，感应条不要太贴边。
- 浮层顶部与箭头之间有间隙会导致鼠标一移开就隐藏 → 紧贴箭头下方 + 1 秒延迟隐藏。
- 首页智能体曾用 LazyVGrid 变成“一格一个”，官网式排列要用自定义 FlowLayout（Layout 协议）。
- 滚动条“滑块”需要去掉时：限制区域高度 + `.scrollIndicators(.hidden)`。

### 6.4 API / 数据

- DeepSeek 401：Key 无效（平台创建、`sk-` 开头）。应用调用路径本身正确。
- 钥匙串每次弹授权提示 → 改为本地 AES-GCM 加密存储，完全移除 `SecItem` 调用；旧钥匙串数据不再自动迁移（避免弹窗）。
- 每次进入客户端模式都验证 API → 验证结果按智能体+配置哈希缓存，配置没变直接通过。
- 新增参数组默认参数为空 → 按供应商官方默认预填（DeepSeek 等），只留 API Key。
- 失败提示显示 `HTTP 401...` 不友好 → 映射成友好文案，细节放“复制详情”按钮。

### 6.5 官网 / Cloudflare

- Pages Functions 目录必须放在项目根 `functions/`；放 `site/functions/` 不会被部署，路由会变成 `/functions/...`。
- D1 `exec()` 传多条 SQL 报 `incomplete input` → 改用 `prepare().run()` 逐条执行。
- Pages secrets 设置后需要重新部署才生效。
- Google 登录邮箱带点号（`zhaolongfei@gmail.com`）导致 cookie 按 `.` 拆分失败 → 从右侧拆分 email/exp/sig。
- 后台/统计路径 `/agentsbin-jz-admin` 需 Google OAuth 凭据（Pages secrets：`GOOGLE_CLIENT_ID`、`GOOGLE_CLIENT_SECRET`）。
- 线上文案/截图更新后 CDN 可能仍返回旧资源：资源 URL 加版本参数，或 no-cache 请求回源刷新。

---

## 7. 常用命令速查

| 操作 | 命令 |
| --- | --- |
| 构建应用 | `swift build -c release` |
| 打包 DMG | `./Scripts/build_dmg.sh` |
| 部署官网 | `npx wrangler pages deploy site --project-name agentsbin --branch main` |
| 查部署 | `npx wrangler pages deployment list --project-name agentsbin` |
| D1 查询 | `npx wrangler d1 execute agentsbin-stats --remote --command "..."` |
| 设置 secret | `npx wrangler pages secret put <KEY> --project-name agentsbin` |
| 渲染效果图 | 无头 Chrome `--screenshot=... --window-size=...` |
| 校验安装包 | `hdiutil verify <dmg>` |

---

## 8. 协作约定

- 效果图只出英文版；改动先确认再开发
- 部署要等“部署”指令，不得擅自上线
- 验证后明确告知结果（校验、挂载、启动），不只说“一致”
- 每次更新按“版本递增 → 打包 → 本地验证 → 更新官网 → 部署 → 线上验证 → 提交”执行
