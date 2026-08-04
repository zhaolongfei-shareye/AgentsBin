# AgentsBin 项目文档

文档更新：2026-08-04
当前版本：V1.1.4（免费内测版）
仓库：https://github.com/zhaolongfei-shareye/AgentsBin
官网：https://www.agentsbin.com
作者：Jacky Zhao（zhaolongfei@gmail.com）

---

## 1. 项目简介

AgentsBin 是一款 macOS 菜单栏 AI 智能体快速入口应用：

- 点击菜单栏 `[AB]` 图标瞬间拉起置顶弹窗
- 左侧浮层选择智能体，右侧嵌入官方网页对话，或使用 API 模式直连调用
- 支持智能体管理、API Key 本地加密备份、10 语言
- 提供官网、下载分发、真实使用统计后台（含国家来源）

项目包含三部分：macOS 应用（SwiftUI）、官网（Cloudflare Pages）、统计后台（Pages Functions + D1 + Google 登录）。

---

## 2. 当前功能清单（V1.1.4）

### 2.1 macOS 应用

- 菜单栏常驻 `[AB]` 图标：下方箭头缓慢闪动提醒点击，展开时箭头向上提示收起
- 首次安装打开首页：官网式文字胶囊选择默认智能体，前 7 个默认选中（系统 accent 蓝），Open / Launch at login；版本变化自动重置首页
- 单一视图主界面：无左右分栏、色块分区、少线条
- 顶部栏：箭头按钮 + 当前智能体（16px 图标 + 名称）+ 最近 9 个切换 Logo（悬停全名、点击切换）+ Web/API 自定义分段 tab（带状态圆点）
- 智能体浮层：鼠标移到顶部箭头自动展开（从上往下渐变），移开 1 秒延迟收起；紧贴箭头下方；默认容纳 10 行，下方滚动；背景固定系统窗口色；设置界面不显示
- 智能体双状态点：蓝 = Web 可用，绿 = API 可用，灰 = 不可用
- 客户端模式：OpenAI 兼容 / Anthropic API 直连；验证结果按配置哈希缓存，配置未变不重复验证；友好错误提示 + 复制详情
- API 配置：按供应商预填默认参数（DeepSeek 等）、参数组激活（绿播放/灰暂停）、10 组上限、供应商与参数组拖拽排序
- API Key：本地 AES-GCM 加密存储（无钥匙串弹窗），不依赖网络
- 智能体管理：37 个内置智能体、自定义添加、拖拽排序、导入导出
- 多语言：10 种语言手动切换，默认英文
- 窗口：默认 960×560、最小 720×420；位置与尺寸记忆，收起再展开恢复
- 原生一致性：系统 accent 色、系统字体/间距/圆角、深浅模式自动适配；样式集中在 Theme.swift 便于扩展多风格
- 其他：开机自动启动、深浅模式、右上角浏览器按钮、底部地球图标（悬停显示官网、点击打开）

### 2.2 官网

- 深色科技感设计，动态渐变背景；默认英文、10 语言手动切换
- 顶部 AgentsBin.com 品牌 + Products 产品弹窗（深灰风格，三卡片 + 搜索/筛选）
- 首页右侧 App 预览为模拟操作动画：智能体高亮自动切换 + 对话淡入循环
- 功能详解、操作说明（网页或 API 模式、桌面自由摆放）、FAQ（AI 关键词问答）
- SEO：AI 热门关键词、FAQPage/WebSite/Organization 结构化数据、sitemap、Google Search Console 已验证
- 下载区：AgentsBin 1.1.4 DMG（约 913 KB），SHA-256 校验
- 作者联系方式：邮箱、微信、Facebook、X

### 2.3 统计后台

- 隐蔽路径：https://www.agentsbin.com/agentsbin-jz-admin（Google 登录，仅管理员邮箱）
- 数据范围：7 / 30 / 90 / 365 天
- KPI：总下载、应用打开、智能体访问、活跃天数
- 每日明细、智能体访问排行、来源（Web/App）、国家来源（Cloudflare CF-IPCountry 自动记录）
- 真实数据写入 Cloudflare D1，永久保留

---

## 3. 目录结构

```text
AgentsBin/
├── Sources/AIHub/            macOS 应用源码（SwiftUI + AppKit）
│   ├── main.swift            入口（纯 AppKit，避免 Settings 空窗口）
│   ├── AppDelegate.swift     菜单栏、窗口、动态 [AB] 图标、启动杀旧实例
│   ├── MainView.swift        首页、主界面、浮层、双模式、设置
│   ├── Theme.swift           集中主题配置（系统风格，可扩展多风格）
│   ├── Stores.swift          智能体存储、最近 9 个历史
│   ├── SecurityStore.swift   API 配置、本地 AES 加密、验证缓存
│   ├── ClientChatView.swift  API 客户端对话
│   ├── Localization.swift    10 语言
│   ├── WebViewPool.swift     网页嵌入
│   └── Analytics.swift       统计埋点
├── Assets/AgentIcons/        37 个官方书签图标（按智能体名称命名）
├── Scripts/                  构建脚本
├── site/                     官网静态文件与 downloads
├── functions/                Pages Functions（track/stats/auth/后台）
├── wrangler.toml             Pages + D1 配置
└── docs/                     项目文档与工作流指南
```

---

## 4. 技术栈与依赖清单

| 项 | 技术 / 依赖 | 平台 | 路径 |
| --- | --- | --- | --- |
| 应用语言 | Swift 5.9 + SwiftUI/AppKit | macOS 13+ | Package.swift |
| 构建工具链 | Swift 6.3.2（本机安装，系统 6.3.3 不匹配） | macOS | ~/Library/Developer/Toolchains/swift-6.3.2-RELEASE.xctoolchain |
| 本地加密 | CryptoKit AES-GCM | macOS | SecurityStore.swift |
| 官网 | HTML/CSS/JS 原生 | Cloudflare Pages | site/ |
| 后端 | Pages Functions（JS ESM） | Cloudflare | functions/ |
| 数据库 | D1（SQLite） | Cloudflare | wrangler.toml |
| 登录 | Google OAuth 2.0 | Google Cloud | functions/api/auth/ |
| 部署 | Wrangler CLI + Cloudflare API Token | Cloudflare | 命令见第 7 章 |
| 版本控制 | GitHub | 远程 | zhaolongfei-shareye/AgentsBin |
| 域名 | agentsbin.com（Porkbun 注册） | Web | Cloudflare Pages 绑定 |

---

## 5. 统计系统架构

```text
官网下载按钮 / macOS App
   │  POST /api/track（含 CF-IPCountry）
   ▼
Pages Functions → D1（events 表，含 country 字段）
   ▲
   │  GET /api/stats（管理员 Cookie）
后台 /agentsbin-jz-admin
```

- 事件类型：download / app_open / agent_open
- 防刷：同一 IP 每天每类最多 40 次，IP 只存哈希
- 国家来源：Cloudflare CF-IPCountry 自动注入；旧数据无国家，新事件开始积累

---

## 6. Google 登录配置

- OAuth 客户端：Web 应用，重定向 https://www.agentsbin.com/api/auth/callback
- Cloudflare secrets：GOOGLE_CLIENT_ID、GOOGLE_CLIENT_SECRET
- 管理员邮箱：zhaolongfei@gmail.com（可用 ADMIN_EMAIL 覆盖）
- 登录会话：HMAC 签名 Cookie（7 天），仅允许管理员邮箱
- 注意：邮箱含点号时 Cookie 解析需从右侧拆分

---

## 7. 部署

```bash
export CLOUDFLARE_API_TOKEN='<token>'
npx wrangler pages deploy site --project-name agentsbin --branch main
npx wrangler d1 execute agentsbin-stats --remote --command "..."
```

- 部署后刷新 CDN：资源引用带版本参数（如 ?v=1.1.7），并用 no-cache 请求验证
- 下载文件必须验证 SHA-256、hdiutil verify、挂载、启动
- Wrangler 登录失效时使用 Cloudflare API Token（权限：Workers Scripts / Pages / D1 Edit）

---

## 8. macOS 应用构建与分发

```bash
export PATH="$HOME/Library/Developer/Toolchains/swift-6.3.2-RELEASE.xctoolchain/usr/bin:$PATH"
./Scripts/build_dmg.sh
open dist/AgentsBin-1.1.4.dmg
```

- build_dmg.sh 自动递增 PATCH；发布指定版本时临时将递增改为 +0，构建后恢复脚本
- 本地验证：shasum、hdiutil verify、挂载检查 Info.plist、open 启动 + pgrep
- 上架 Mac App Store：需安装 Xcode、开发者证书、沙盒与隐私说明

---

## 9. 版本历史

| 提交 | 说明 |
| --- | --- |
| 5e2d219 | 修复首页误删，移除 Demo 残留，首页动画预览 v1.1.7 |
| ca758b0 | 移除官网 Demo 弹窗，新增首页预览动画 |
| c48c491 | 官网新增交互式 macOS Demo（后撤销） |
| 1526594 | SEO：AI 关键词、FAQ、结构化数据、sitemap |
| 037d964 | 统计后台新增国家来源分析 |
| d80b9e1 | 1.1.4：浮层固定背景色并部署 |
| eaabebf | 1.1.3：集中主题配置、原生字体/间距/圆角、弹窗尺寸 |
| 139c072 | 1.1.2：真正应用原生风格（accent 蓝、毛玻璃、圆角） |
| 47e4ece | 1.1.1：界面统一 macOS 原生风格 |
| 735f9ac | 文档：工作流与排坑指南 |

---

## 10. 已上线地址

| 资源 | 地址 |
| --- | --- |
| 官网 | https://www.agentsbin.com |
| 下载 | https://www.agentsbin.com/downloads/AgentsBin-1.1.4.dmg |
| 统计后台 | https://www.agentsbin.com/agentsbin-jz-admin |
| 统计 API | https://www.agentsbin.com/api/track |
| Sitemap | https://www.agentsbin.com/sitemap.xml |
| GitHub | https://github.com/zhaolongfei-shareye/AgentsBin |

---

## 11. 下一步计划

- 确认新版 App 后更新官网下载与版本文案
- 上架 Mac App Store 准备（Xcode、证书、沙盒、隐私说明）
- 官网继续沉淀 AI 关键词 SEO 与内容
- AgentsBin Audio / Watermark 产品规划
- 统计后台丰富：留存、会话时长、地区地图

---

## 12. 维护提示

- 详细工作流与踩坑清单见 docs/AgentsBin-Workflow.md
- Codex 专属技能 agentsbin-dev 已沉淀开发流程
- 改动 UI 先出英文效果图 → 确认 → 开发 → 本地验证 → 等部署指令
- 编辑脚本注意：多条件替换脚本不要因部分未匹配而不写入，避免出现“看似改了实际没改”
