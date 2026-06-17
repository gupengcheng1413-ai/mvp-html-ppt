# 阿里云 OSS 部署说明

## ⚠️ 重要提示

阿里云 OSS 对直接访问 HTML 文件有安全限制，会强制浏览器下载而不是打开。

**解决方案：**

### 方案 A：绑定备案域名 + CDN（推荐，适合生产环境）

**要求：**
- 已备案的域名（如 `ppt.yourdomain.com`）
- 备案入口：https://beian.aliyun.com/

**步骤：**
1. 准备已备案域名
2. 在 OSS 控制台绑定域名
3. 开启 CDN 加速
4. 配置 HTTPS（可选）

详细步骤见 `DEPLOY.md`

**优点：**
- ✓ 可以直接在浏览器打开
- ✓ 访问速度快
- ✓ 流量费用低
- ✓ 支持 HTTPS

### 方案 B：本地服务器演示（适合演示、开发）

**无需备案，立即可用。**

**步骤：**
```bash
# 下载项目
git clone https://github.com/gupengcheng1413-ai/mvp-html-ppt.git
cd mvp-html-ppt

# 启动本地服务器
./serve.sh

# 浏览器打开
# http://localhost:8080/index-standalone.html
```

**优点：**
- ✓ 无需备案
- ✓ 立即可用
- ✓ 完全离线

**缺点：**
- ✗ 仅限本地访问
- ✗ 关闭电脑后无法访问

### 方案 C：使用 GitHub Pages（免费，无需备案）

**步骤：**
1. Fork 或 clone 本仓库
2. 在 GitHub 仓库设置中开启 GitHub Pages
3. 选择 `main` 分支
4. 访问：`https://你的用户名.github.io/mvp-html-ppt/index-standalone.html`

**优点：**
- ✓ 免费
- ✓ 无需备案
- ✓ 全球访问
- ✓ 自动 HTTPS

**缺点：**
- ✗ 国内访问可能较慢
- ✗ GitHub 在国内偶尔不稳定

## 当前部署状态

已部署到阿里云 OSS：
- Bucket: `mvp-html-ppt`
- 区域: `oss-cn-hangzhou`
- 地址: http://mvp-html-ppt.oss-cn-hangzhou.aliyuncs.com/

⚠️ 由于安全限制，直接访问会下载文件，需要绑定备案域名才能正常打开。

## 推荐方案选择

| 场景 | 推荐方案 | 说明 |
|------|---------|------|
| 正式生产环境 | 方案 A（OSS + 备案域名 + CDN） | 需要备案，但体验最好 |
| 内部演示/开发 | 方案 B（本地服务器） | 立即可用，无需备案 |
| 快速分享/测试 | 方案 C（GitHub Pages） | 免费，无需备案，国内稍慢 |

## 需要帮助？

- OSS 详细部署文档：`DEPLOY.md`
- GitHub 仓库：https://github.com/gupengcheng1413-ai/mvp-html-ppt
