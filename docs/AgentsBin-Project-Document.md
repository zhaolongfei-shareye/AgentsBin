# AgentsBin 项目文档

文档日期：2026-08-02  
当前版本：V1.0.17（免费内测版）  
仓库：https://github.com/zhaolongfei-shareye/AgentsBin  
官网：https://www.agentsbin.com  
作者：Jacky Zhao（zhaolongfei@gmail.com）

---

## 1. 项目简介

AgentsBin 是一款 macOS 菜单栏 AI 智能体快速入口应用，目标是用一个常驻菜单栏图标聚合主流 AI 智能体：

- 点击菜单栏图标瞬间拉起置顶弹窗
- 左侧选择智能体，右侧嵌入官方网页直接对话
- 支持智能体管理、API Key 加密备份、多语言
- 提供官网、下载分发和真实使用统计后台

项目同时包含三部分：

| 部分 | 说明 |
| --- | --- |
| macOS 应用 | SwiftUI 菜单栏 App，核心产品 |
| 官网 | Cloudflare Pages 静态站，用于介绍和下载分发 |
| 统计后台 | Cloudflare Pages Functions + D1，真实下载与应用使用统计，Google 登录保护 |

---

## 2. 当前功能清单（V1.0.17）

### 2.1 macOS 应用

- 菜单栏常驻图标，左键打开/收起主窗口，右键显示打开与退出菜单
- 主窗口置顶浮动，可拖拽调整大小，可折叠左侧边栏缩小整体宽度
- 单智能体对话模式：一次只在一个智能体网页内对话，右侧嵌入真实官网
- 左侧智能体列表：反白显示当前项、未读红点、拖拽排序、自定义添加、文本导入导出
- 内置 37 个智能体，按字母排序，含 ChatGPT、Claude、DeepSeek、Kimi、Qwen、Grok 等
- 智能体管理：显示/隐藏、自定义智能体（LOGO 自动取域名首字母）、置顶与排序
- API Key 保险箱：管理员账号密码保护，本地加密保存，支持多组参数、备份
- 通用设置：修改密码、修改邮箱、自动启动、语言、深浅色切换
- 多语言：10 种语言手动切换，包含中英日韩西法德俄葡繁中
- 浏览器跳转：右上角打开系统默认浏览器进入当前智能体页面
- 应用埋点：启动上报 app_open，切换智能体上报 agent_open（统计用）

### 2.2 官网

- 深色科技感设计，动态渐变背景，默认英文、手动 10 语言切换
- 顶部 AB Logo + “Products” 产品入口（Adobe 风格多列卡片弹窗）
- 产品卡片：AgentsBin（已发布）、AgentsBin Audio（Coming Soon）、AgentsBin Watermark（Coming Soon）
- 功能详解、操作说明、内置智能体跑马灯、下载区
- 模拟统计展示区（Top 5 智能体访问量柱状图），后续可接真实数据
- 作者联系方式区：邮箱、微信、Facebook、X

### 2.3 统计后台

- 隐蔽路径：https://www.agentsbin.com/agentsbin-jz-admin
- Google OAuth 登录，仅允许管理员邮箱（默认 zhaolongfei@gmail.com）
- 数据范围切换：7 / 30 / 90 / 365 天
- KPI：总下载、应用打开、智能体访问、活跃天数
- 每日明细表：日期、下载、应用打开、智能体访问
- 智能体访问量排行：Top 12 柱状图
- 实时写入 Cloudflare D1，数据永久保留

---

## 3. 项目目录结构

```text
AgentsBin/
├── Sources/AIHub/            macOS 应用源码（SwiftUI）
│   ├── AIHubApp.swift        应用入口
│   ├── AppDelegate.swift     菜单栏、主面板、埋点
│   ├── MainView.swift        主界面、智能体列表
│   ├── Models.swift          智能体数据模型
│   ├── Stores.swift          智能体存储与状态
│   ├── WebViewPool.swift     嵌入网页池
│   ├── SecurityStore.swift   API Key 加密存储
│   ├── Localization.swift    多语言
│   ├── FaviconStore.swift    官网图标缓存
│   └── Analytics.swift       统计埋点上报
├── Assets/                   App 图标、菜单栏图标、智能体图标
├── Scripts/                  构建脚本（build_app.sh / build_dmg.sh / build_pkg.sh）
├── site/                     官网静态文件
│   ├── index.html
│   ├── styles.css
│   ├── app.js
│   ├── assets/
│   └── downloads/            DMG 安装包
├── functions/                Cloudflare Pages Functions
│   ├── _lib.js               公共工具（D1、Cookie 签名）
│   ├── agentsbin-jz-admin.js 统计后台页面
│   └── api/
│       ├── track.js          事件写入 API
│       ├── stats.js          统计查询 API
│       └── auth/             Google OAuth（google / callback / logout）
├── wrangler.toml             Cloudflare Pages + D1 配置
├── Package.swift             Swift Package 配置
├── version.txt               版本号
└── docs/                     项目文档
```

---

## 4. 技术栈与依赖清单

### 4.1 macOS 应用

| 项 | 技术 / 依赖 | 版本 | 平台 | 路径 |
| --- | --- | --- | --- | --- |
| 语言 | Swift | 5.9（swift-tools-version） | macOS 13+ | `Package.swift` |
| UI 框架 | SwiftUI + AppKit | 系统框架 | macOS | `Sources/AIHub/` |
| 本地存储 | SQLite3（系统库） | 系统库 | macOS | `Package.swift`（linkerSettings） |
| 数据库文件 | SQLite | - | 用户目录 | 由 `SecurityStore.swift` 管理 |
| 图标资源 | PNG / ICNS | - | macOS | `Assets/` |
| 第三方 Swift 包 | 无 | - | - | 仅系统框架 |
| 构建脚本 | Shell | - | macOS | `Scripts/build_app.sh`、`Scripts/build_dmg.sh`、`Scripts/build_pkg.sh` |
| 图标生成 | Python 3 | - | macOS | `Scripts/generate_icon.py`、`Scripts/convert_agent_icons.py` |

### 4.2 官网前端

| 项 | 技术 / 依赖 | 版本 | 平台 | 路径 |
| --- | --- | --- | --- | --- |
| 页面结构 | HTML5 | - | 浏览器 | `site/index.html` |
| 样式 | CSS3（原生） | - | 浏览器 | `site/styles.css` |
| 逻辑 | JavaScript（原生，无框架） | - | 浏览器 | `site/app.js` |
| 静态托管 | Cloudflare Pages | - | Cloudflare | `site/` |
| 下载安装包 | DMG | 1.0.17 | macOS | `site/downloads/` |
| 爬虫/SEO | robots.txt / sitemap.xml | - | 搜索引擎 | `site/robots.txt`、`site/sitemap.xml` |

### 4.3 后端统计

| 项 | 技术 / 依赖 | 版本 | 平台 | 路径 |
| --- | --- | --- | --- | --- |
| 函数运行时 | Cloudflare Pages Functions（JavaScript ESM） | - | Cloudflare | `functions/` |
| 数据库 | Cloudflare D1（SQLite） | - | Cloudflare | `wrangler.toml`（binding: DB） |
| 登录 | Google OAuth 2.0 | - | Google Cloud | `functions/api/auth/` |
| 埋点 API | Pages Function | - | Cloudflare | `functions/api/track.js` |
| 查询 API | Pages Function | - | Cloudflare | `functions/api/stats.js` |
| 后台页面 | 服务端渲染 HTML + 原生 JS | - | Cloudflare | `functions/agentsbin-jz-admin.js` |

### 4.4 部署与代码托管

| 项 | 平台 | 说明 | 位置/命令 |
| --- | --- | --- | --- |
| 代码仓库 | GitHub | `zhaolongfei-shareye/AgentsBin` | `git push origin master` |
| 官网部署 | Cloudflare Pages | 项目名 `agentsbin` | `npx wrangler pages deploy site --project-name agentsbin --branch main` |
| 域名 | agentsbin.com | Porkbun 注册，DNS 指向 Cloudflare | Cloudflare 控制台 |
| D1 管理 | Cloudflare | `agentsbin-stats` | `npx wrangler d1 execute agentsbin-stats --remote --command "..."` |
| 安全变量 | Cloudflare Pages secrets | Google OAuth 凭据 | `npx wrangler pages secret put ...` |
| 本地开发服务器 | Python 3 | 官网预览 | `python3 -m http.server 8137 --directory site` |

### 4.5 本机环境

| 项 | 值 |
| --- | --- |
| 项目根目录 | `/Users/zlfmac/Documents/AgentsBin` |
| 系统 | macOS（Apple Silicon，arm64） |
| 工具链 | Xcode CommandLineTools（当前 Swift 6.3.3） |
| macOS SDK | `MacOSX26.5.sdk`（当前与 Swift 6.3.3 不匹配，打包受阻） |
| Node / npm | 通过 npx 使用 wrangler |
| 数据 | 统计数据在 Cloudflare D1，本机不落库 |

### 4.6 配置与环境变量

| 变量 | 平台 | 用途 | 配置位置 |
| --- | --- | --- | --- |
| `GOOGLE_CLIENT_ID` | Cloudflare Pages | Google 登录客户端 ID | Production secret |
| `GOOGLE_CLIENT_SECRET` | Cloudflare Pages | Google 登录密钥 | Production secret |
| `ADMIN_EMAIL` | Cloudflare Pages（可选） | 后台管理员邮箱，默认 `zhaolongfei@gmail.com` | Environment variables |
| `ADMIN_COOKIE_SECRET` | Cloudflare Pages（可选） | 会话签名密钥，默认用 Client Secret | Environment variables |
| `database_id` | wrangler.toml | D1 数据库绑定 | `wrangler.toml` |

---

## 5. 统计系统架构

### 5.1 数据链路

```text
官网下载按钮 / macOS App
        │  POST /api/track
        ▼
Cloudflare Pages Functions
        │  D1（agentsbin-stats）
        ▼
Cloudflare D1 数据库（真实数据，永久保留）
        ▲
        │  GET /api/stats（管理员 Cookie）
统计后台 /agentsbin-jz-admin
```

### 5.2 事件类型

| kind | 触发点 | source |
| --- | --- | --- |
| download | 官网点击 Download DMG | web |
| app_open | macOS 应用每次启动 | app |
| agent_open | 每次切换智能体 | app |

### 5.3 数据表

```sql
CREATE TABLE events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL,        -- YYYY-MM-DD（UTC）
  ts TEXT NOT NULL,          -- ISO 时间
  kind TEXT NOT NULL,        -- download / app_open / agent_open
  name TEXT NOT NULL,        -- dmg / 智能体 ID
  version TEXT,              -- 应用版本
  source TEXT,               -- web / app
  ip_hash TEXT,              -- IP 哈希（防刷，不存原始 IP）
  ua TEXT                    -- User-Agent
);
```

### 5.4 防刷

- 同一 IP 同一天同类型事件最多 40 次
- IP 只保存哈希，不保存原始地址
- 请求体大小限制 4KB

---

## 6. Google 登录配置

### 6.1 已配置项

- Google Cloud OAuth 客户端：Web 应用类型
- 授权重定向 URI：`https://www.agentsbin.com/api/auth/callback`
- Cloudflare Production secrets：
  - `GOOGLE_CLIENT_ID`
  - `GOOGLE_CLIENT_SECRET`
- 管理员邮箱：`zhaolongfei@gmail.com`（可用环境变量 `ADMIN_EMAIL` 覆盖）

### 6.2 登录流程

1. 用户访问 `/agentsbin-jz-admin`
2. 点击 Sign in with Google
3. `/api/auth/google` 生成 state 并跳转 Google 授权
4. Google 回调 `/api/auth/callback`，交换 token、校验邮箱
5. 校验通过后写入签名 Cookie（HttpOnly / Secure / SameSite=Lax，7 天）
6. `/agentsbin-jz-admin` 通过 Cookie 鉴权，未登录或非管理员一律拒绝

### 6.3 安全提示

- 客户端密钥不要写入代码、文档或公开仓库
- 如需更换密钥，在 Google Cloud 重新生成并更新 Cloudflare secret
- 后台路径默认不对外公布，仍由 Google 登录做最终鉴权

---

## 7. 部署

### 7.1 官网与 Functions

```bash
npx wrangler pages deploy site --project-name agentsbin --branch main
```

注意：`functions/` 必须放在项目根目录（与 `site/` 同级），wrangler 才会自动打包 Functions。

### 7.2 D1 数据库

```bash
npx wrangler d1 create agentsbin-stats
npx wrangler d1 execute agentsbin-stats --remote --file schema.sql
```

数据库 ID 已写入 `wrangler.toml` 的 `d1_databases` 绑定。

### 7.3 安全变量

```bash
npx wrangler pages secret put GOOGLE_CLIENT_ID --project-name agentsbin
npx wrangler pages secret put GOOGLE_CLIENT_SECRET --project-name agentsbin
```

### 7.4 GitHub 推送

```bash
git add -A
git commit -m "..."
git push origin master
```

---

## 8. macOS 应用构建与分发

### 8.1 构建命令

```bash
./Scripts/build_dmg.sh
open dist/AgentsBin-1.0.17.dmg
```

### 8.2 分发流程

1. `build_dmg.sh` 生成 DMG
2. 拷贝到 `site/downloads/AgentsBin-<版本>.dmg`
3. 更新官网版本号、下载链接、SHA-256
4. 部署官网

### 8.3 当前障碍

本机 Swift 工具链为 6.3.3，macOS SDK 为 6.3.2 编译，`swift build` 报工具链/SDK 版本不匹配，暂时无法在本机重新打包新版 DMG。应用统计埋点代码已合入仓库，待工具链修复后重新打包。

建议：

- 更新 Xcode 或 CommandLineTools 至与 SDK 匹配的版本
- 或安装与 SDK 6.3.2 匹配的 Swift 工具链
- 正式分发前还需 Developer ID 签名与公证

---

## 9. 版本历史

| 提交 | 说明 |
| --- | --- |
| dd133e6 | 修复邮箱含点导致的管理员会话 Cookie 解析失败 |
| a0b272b | Google 登录失败时显示详细原因 |
| 50be030 | 统计 API 错误响应加固 |
| 89785a0 | Pages Functions 移到项目根，修复 D1 建表 |
| a60ceda | 新增真实统计系统：D1、Google 登录后台、官网/应用埋点 |
| 59f63b7 | 官网移除 GitHub 入口，作者与平台同一行 |
| ab0c0ec | 产品弹窗删除空卡片 |
| 49be4cb | Products 按钮紧靠 Logo |
| 1a5faad | 官网新增 Adobe 风格产品菜单 |
| ee771b3 | 官网统计 Top 5 柱状图（模拟数据） |

---

## 10. 已上线地址

| 资源 | 地址 |
| --- | --- |
| 官网 | https://www.agentsbin.com |
| 统计后台 | https://www.agentsbin.com/agentsbin-jz-admin |
| 统计写入 API | https://www.agentsbin.com/api/track |
| 统计查询 API | https://www.agentsbin.com/api/stats |
| Google 登录 | https://www.agentsbin.com/api/auth/google |
| GitHub | https://github.com/zhaolongfei-shareye/AgentsBin |

---

## 11. 下一步计划

- 修复 Swift 工具链后重新打包 DMG，更新官网下载
- 新版应用上线后开始积累真实统计
- 官网统计展示区接入真实数据
- AgentsBin Audio、AgentsBin Watermark 产品开发
- 正式签名与公证，开放正式版下载
