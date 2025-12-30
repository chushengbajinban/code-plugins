#!/bin/bash

# 设置插件列表（手动指定你要安装的文件）
PLUGINS=(
    "ms-python.debugpy-2025.18.0@linux-arm64.vsix"
    "ms-python.python-2025.14.0@linux-x64.vsix"
    "ms-python.black-formatter-2024.6.0.vsix"
)

# GitHub Raw 基础路径
BASE_URL="https://github.com/chushengbajinban/code-plugins/raw/main/cursor"

# 临时目录
TMP="/tmp/vscode-plugins"
mkdir -p "$TMP"

# 检查 code 命令
command -v code >/dev/null || { echo "❌ 未安装 VS Code 或未配置 'code' 命令"; exit 1; }

echo "🚀 开始安装插件..."

for p in "${PLUGINS[@]}"; do
    url="$BASE_URL/$p"
    file="$TMP/$p"
    echo "📥 下载: $p"
    curl -L -o "$file" "$url" && \
    echo "📦 安装: $p" && \
    code --install-extension "$file" && \
    echo "✅ 成功: $p" || \
    echo "❌ 失败: $p"
done

# 可选：清理
read -p "清理临时文件？(y/N): " -n 1
[[ $REPLY =~ ^[Yy]$ ]] && rm -rf "$TMP" && echo "🗑️ 已清理"

echo "✅ 完成！"
