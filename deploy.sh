#!/bin/bash
# 阿里云 OSS 自动化部署脚本

set -e

# 配置信息（首次运行时需要填写）
BUCKET_NAME=""           # 例如: mvp-html-ppt
REGION=""                # 例如: oss-cn-hangzhou
ACCESS_KEY_ID=""         # 阿里云 AccessKey ID
ACCESS_KEY_SECRET=""     # 阿里云 AccessKey Secret

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== 阿里云 OSS 自动化部署 ===${NC}\n"

# 检查配置
if [ -z "$BUCKET_NAME" ] || [ -z "$REGION" ] || [ -z "$ACCESS_KEY_ID" ] || [ -z "$ACCESS_KEY_SECRET" ]; then
    echo -e "${RED}错误: 请先编辑 deploy.sh 填写配置信息${NC}"
    echo -e "${YELLOW}需要配置:${NC}"
    echo "  BUCKET_NAME       - OSS Bucket 名称"
    echo "  REGION            - OSS 区域 (如 oss-cn-hangzhou)"
    echo "  ACCESS_KEY_ID     - 阿里云 AccessKey ID"
    echo "  ACCESS_KEY_SECRET - 阿里云 AccessKey Secret"
    echo ""
    echo -e "${YELLOW}获取 AccessKey:${NC}"
    echo "  https://ram.console.aliyun.com/manage/ak"
    exit 1
fi

# 检查 ossutil 是否安装
if ! command -v ossutil &> /dev/null; then
    echo -e "${YELLOW}ossutil 未安装，开始安装...${NC}"

    # 下载 ossutil
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        wget https://gosspublic.alicdn.com/ossutil/1.7.18/ossutil-v1.7.18-linux-amd64.zip
        unzip -o ossutil-v1.7.18-linux-amd64.zip
        chmod +x ossutil-v1.7.18-linux-amd64/ossutil64
        mkdir -p ~/bin
        mv ossutil-v1.7.18-linux-amd64/ossutil64 ~/bin/ossutil
        export PATH=~/bin:$PATH
        rm -rf ossutil-v1.7.18-linux-amd64*
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        wget https://gosspublic.alicdn.com/ossutil/1.7.18/ossutil-v1.7.18-mac-arm64.zip
        unzip -o ossutil-v1.7.18-mac-arm64.zip
        chmod +x ossutil-v1.7.18-mac-arm64/ossutil64
        mkdir -p ~/bin
        mv ossutil-v1.7.18-mac-arm64/ossutil64 ~/bin/ossutil
        export PATH=~/bin:$PATH
        rm -rf ossutil-v1.7.18-mac-arm64*
    fi

    echo -e "${GREEN}✓ ossutil 安装完成${NC}\n"
fi

# 配置 ossutil
echo -e "${YELLOW}配置 ossutil...${NC}"
ossutil config -e ${REGION}.aliyuncs.com -i ${ACCESS_KEY_ID} -k ${ACCESS_KEY_SECRET} -L CH

# 检查 Bucket 是否存在
echo -e "\n${YELLOW}检查 Bucket...${NC}"
if ! ossutil ls oss://${BUCKET_NAME}/ &> /dev/null; then
    echo -e "${YELLOW}Bucket 不存在，正在创建...${NC}"
    ossutil mb oss://${BUCKET_NAME} --acl public-read

    # 配置静态网站托管
    echo -e "${YELLOW}配置静态网站托管...${NC}"
    cat > /tmp/website.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<WebsiteConfiguration>
    <IndexDocument>
        <Suffix>index-standalone.html</Suffix>
    </IndexDocument>
    <ErrorDocument>
        <Key>index-standalone.html</Key>
    </ErrorDocument>
</WebsiteConfiguration>
EOF
    ossutil website --method put oss://${BUCKET_NAME} /tmp/website.xml
    rm /tmp/website.xml

    echo -e "${GREEN}✓ Bucket 创建成功${NC}"
else
    echo -e "${GREEN}✓ Bucket 已存在${NC}"
fi

# 上传文件
echo -e "\n${YELLOW}开始上传文件...${NC}"

# 上传 index-standalone.html
echo "上传 index-standalone.html..."
ossutil cp index-standalone.html oss://${BUCKET_NAME}/ -f \
    --meta "Content-Type:text/html;charset=utf-8" \
    --meta "Cache-Control:no-cache"

# 上传 index.html
if [ -f "index.html" ]; then
    echo "上传 index.html..."
    ossutil cp index.html oss://${BUCKET_NAME}/ -f \
        --meta "Content-Type:text/html;charset=utf-8" \
        --meta "Cache-Control:no-cache"
fi

# 上传 assets 目录
if [ -d "assets" ]; then
    echo "上传 assets/ 目录..."
    ossutil cp -r assets/ oss://${BUCKET_NAME}/assets/ -f \
        --meta "Cache-Control:max-age=31536000"
fi

echo -e "${GREEN}✓ 文件上传完成${NC}\n"

# 显示访问地址
echo -e "${GREEN}=== 部署成功！===${NC}\n"
echo -e "${YELLOW}访问地址:${NC}"
echo "  http://${BUCKET_NAME}.${REGION}.aliyuncs.com/index-standalone.html"
echo "  http://${BUCKET_NAME}.${REGION}.aliyuncs.com/"
echo ""
echo -e "${YELLOW}下一步（可选）:${NC}"
echo "  1. 绑定自定义域名: https://oss.console.aliyun.com/bucket/${REGION}/${BUCKET_NAME}/domain"
echo "  2. 开启 CDN 加速: https://cdn.console.aliyun.com/domain/add"
echo "  3. 配置 HTTPS: 在 CDN 控制台上传 SSL 证书"
echo ""
