#!/bin/bash
# 本地演示服务器

PORT=8080

echo "启动本地演示服务器..."
echo "访问地址: http://localhost:${PORT}/index-standalone.html"
echo "按 Ctrl+C 停止服务"
echo ""

if command -v python3 &> /dev/null; then
    python3 -m http.server $PORT
elif command -v python &> /dev/null; then
    python -m SimpleHTTPServer $PORT
else
    echo "错误: 未找到 python，请安装 python 后再试"
    exit 1
fi
