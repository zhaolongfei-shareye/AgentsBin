# AgentsBin

菜单栏常驻的 AI 智能体快速入口：嵌入网页端、同问对比、本地知识库、智能体管理。

App 是纯菜单栏应用：双击启动后不会打开窗口，也不占 Dock，请看向屏幕右上角菜单栏的“A”图标，点击图标打开主界面。

App 图标是单色字母 A logo，源图在 `Assets/AppIcon.png`，菜单栏模板图在 `Assets/MenuBarIcon.png`，macOS 图标在 `Assets/AppIcon.icns`，重新生成可运行 `python3 Scripts/generate_icon.py`。

## 本地构建

```bash
./Scripts/build_dmg.sh
open dist/AgentsBin-1.0.4.dmg
```

打开 DMG 后把 `AgentsBin.app` 拖进 `Applications` 即可。

正式分发前还需要 Developer ID 签名和公证。

## 当前状态

- 单智能体对话：右侧直接嵌入网页，一次只聊一个智能体，左侧反白显示当前项
- 站点适配层：ChatGPT/Claude/Gemini/DeepSeek 等输入框、发送按钮、回答选择器，回答轮询检测
- 主窗口为置顶浮动面板，可拖拽调整大小，再次打开恢复默认尺寸
- 智能体管理：拖拽排序、药丸显示/隐藏切换、自定义添加、文本导入/导出，已去掉删除
- 内置 17 个智能体，界面支持多国语言切换（左下角下拉菜单）
- 后续：Developer ID 签名公证
