# AgentsBin 官网（Cloudflare Pages）

## 本地预览

```bash
cd site
python3 -m http.server 8000
```

打开 http://127.0.0.1:8000

## 部署到 Cloudflare Pages

1. 登录 Cloudflare Dashboard，进入 Workers & Pages。
2. 创建 Pages 项目，连接 GitHub 仓库。
3. 构建命令留空，输出目录填 `site`。
4. 部署后，把自定义域名 CNAME 指向生成的 `*.pages.dev` 地址。

下载文件位于 `site/downloads/AgentsBin-1.0.0.pkg`。
