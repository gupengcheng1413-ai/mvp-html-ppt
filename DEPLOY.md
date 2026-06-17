# 阿里云 OSS + CDN 自动化部署指南

## 前置准备

### 1. 获取阿里云 AccessKey

1. 登录 [RAM 访问控制](https://ram.console.aliyun.com/manage/ak)
2. 创建 AccessKey（建议创建子账号，授予 OSS 权限）
3. 保存 `AccessKey ID` 和 `AccessKey Secret`

### 2. 配置部署脚本

编辑 `deploy.sh`，填写以下信息：

```bash
BUCKET_NAME="mvp-html-ppt"           # Bucket 名称（全局唯一）
REGION="oss-cn-hangzhou"             # 区域（华东1-杭州）
ACCESS_KEY_ID="LTAI5t..."            # 你的 AccessKey ID
ACCESS_KEY_SECRET="your_secret..."   # 你的 AccessKey Secret
```

**可选区域：**
- `oss-cn-hangzhou`   华东1（杭州）
- `oss-cn-shanghai`   华东2（上海）
- `oss-cn-beijing`    华北2（北京）
- `oss-cn-shenzhen`   华南1（深圳）

## 快速部署

### 一键部署

```bash
chmod +x deploy.sh
./deploy.sh
```

脚本会自动：
1. 检查并安装 ossutil（如未安装）
2. 创建 OSS Bucket（如不存在）
3. 配置静态网站托管
4. 上传所有文件
5. 显示访问地址

### 部署成功后

访问地址示例（实际以脚本输出为准）：
```
http://mvp-html-ppt.oss-cn-hangzhou.aliyuncs.com/
http://mvp-html-ppt.oss-cn-hangzhou.aliyuncs.com/index-standalone.html
```

## 进阶配置

### 1. 绑定自定义域名

1. 准备已备案的域名（如 `ppt.yourdomain.com`）
2. 进入 [OSS 控制台](https://oss.console.aliyun.com/) → 你的 Bucket → 域名管理
3. 点击「绑定域名」，输入 `ppt.yourdomain.com`
4. 到你的域名 DNS 服务商添加 CNAME 记录：
   - **主机记录**：`ppt`
   - **记录类型**：`CNAME`
   - **记录值**：`mvp-html-ppt.oss-cn-hangzhou.aliyuncs.com`
5. 等待 DNS 生效（10 分钟内）

### 2. 开启 CDN 加速

#### 方式一：在 OSS 控制台开启

1. 进入你的 Bucket → 域名管理
2. 点击自定义域名后的「未开启」→「添加域名」
3. 选择「阿里云 CDN」
4. 配置完成后自动开启加速

#### 方式二：使用脚本（可选）

创建 `deploy-cdn.sh`：

```bash
#!/bin/bash
# 需要先运行 deploy.sh 完成基础部署

DOMAIN="ppt.yourdomain.com"  # 你的自定义域名
BUCKET_ENDPOINT="${BUCKET_NAME}.${REGION}.aliyuncs.com"

echo "开启 CDN 加速..."
aliyun cdn AddCdnDomain \
    --DomainName ${DOMAIN} \
    --CdnType web \
    --SourceType oss \
    --Sources '[{"content":"'${BUCKET_ENDPOINT}'","type":"oss","priority":"20","port":80}]'

echo "配置缓存规则..."
aliyun cdn BatchSetCdnDomainConfig \
    --DomainNames ${DOMAIN} \
    --Functions '[
        {"functionArgs":[{"argName":"cache_ttl","argValue":"31536000"},{"argName":"file_type","argValue":"jpg,jpeg,png,gif,webp,svg,woff,woff2,ttf"}],"functionName":"set_cache_ttl"},
        {"functionArgs":[{"argName":"cache_ttl","argValue":"600"},{"argName":"file_type","argValue":"html,htm"}],"functionName":"set_cache_ttl"}
    ]'

echo "✓ CDN 配置完成"
```

### 3. 配置 HTTPS（推荐）

1. 进入 [CDN 控制台](https://cdn.console.aliyun.com/)
2. 找到你的加速域名 → HTTPS 配置
3. 上传 SSL 证书或申请免费证书
4. 开启「强制 HTTPS 跳转」

## 费用说明

### OSS 存储费用
- **标准存储**：约 ¥0.12/GB/月
- **外网流出流量**：约 ¥0.50/GB
- **请求次数**：GET 请求 ¥0.01/万次

### CDN 流量费用（按阶梯计费）
- 0-10TB：¥0.24/GB
- 10TB-50TB：¥0.23/GB
- 50TB-100TB：¥0.21/GB

**示例**：一个 3MB 的页面，1000 次访问
- 仅 OSS：1000 × 3MB × ¥0.50/GB ≈ ¥1.5
- OSS + CDN：1000 × 3MB × ¥0.24/GB ≈ ¥0.72

## 更新部署

修改代码后，再次运行：

```bash
./deploy.sh
```

会自动覆盖上传最新文件。

## 故障排查

### 1. 访问 403 Forbidden

**原因**：Bucket 权限不是「公共读」

**解决**：
```bash
ossutil set-acl oss://${BUCKET_NAME} public-read -r -f
```

### 2. 中文乱码

**原因**：Content-Type 没有设置 charset

**解决**：重新运行 `deploy.sh`（脚本已设置正确的 Content-Type）

### 3. CDN 缓存未更新

**解决**：在 CDN 控制台刷新缓存
```bash
aliyun cdn RefreshObjectCaches --ObjectPath https://ppt.yourdomain.com/index-standalone.html --ObjectType File
```

## 安全建议

1. **不要在脚本中硬编码 AccessKey**，使用环境变量：
   ```bash
   export ACCESS_KEY_ID="your_key"
   export ACCESS_KEY_SECRET="your_secret"
   ```

2. **使用 RAM 子账号**，仅授予 OSS 权限：
   - AliyunOSSFullAccess（开发）
   - AliyunOSSReadOnlyAccess（只读）

3. **定期轮换 AccessKey**

## 参考链接

- [OSS 控制台](https://oss.console.aliyun.com/)
- [CDN 控制台](https://cdn.console.aliyun.com/)
- [ossutil 文档](https://help.aliyun.com/document_detail/120075.html)
- [OSS 定价](https://www.aliyun.com/price/product#/oss/detail)
