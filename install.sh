#!/bin/bash

# =============================
# 配置区：插件列表与版本 + 平台控制
# =============================

# 插件定义格式：
#   "publisher/extension-name/version[/platform]"
# 示例：
#   ms-python/python/2025.9.2025062001/linux-x64
#   ms-python/vscode-pylance/2025.10.100          # 无平台参数
#   ms-python/debugpy/2025.19.2025121701/linux-arm64

PLUGINS=(
    "ms-python/python/2025.20.1/linux-x64"
    # "ms-python/black-formatter/2024.6.0"
    "ms-python/vscode-pylance/2025.4.1"
    "ms-python/debugpy/2025.18.0/linux-x64"
)

# 临时目录
TMP="/tmp/vscode-plugins"
mkdir -p "$TMP"

# 检查 code 命令是否可用
command -v code >/dev/null || { echo "❌ 未安装 VS Code 或未配置 'code' 命令"; exit 1; }

echo "🚀 开始安装插件..."

for plugin in "${PLUGINS[@]}"; do
    IFS='/' read -r publisher extension version platform <<< "$plugin"

    # 构造基础 URL
    url="https://marketplace.visualstudio.com/_apis/public/gallery/publishers/$publisher/vsextensions/$extension/$version/vspackage"

    # 如果指定了平台，则添加 ?targetPlatform= 参数
    if [ -n "$platform" ]; then
        url="$url?targetPlatform=$platform"
    fi

    # 文件名格式：publisher.extension.version[.platform].vsix
    filename="$publisher.$extension.$version"
    if [ -n "$platform" ]; then
        filename="$filename.$platform"
    fi
    filename="$filename.vsix"
    filepath="$TMP/$filename"

    echo "📥 下载: $filename"
    curl -L --compressed "$url" -o "$filepath" -J && \
    echo "📦 安装: $filename" && \
    code --install-extension "$filepath" && \
    echo "✅ 成功: $filename" || \
    echo "❌ 失败: $filename"
done

rm -rf "$TMP" && echo "🗑️ 已清理"

echo "✅ 所有插件安装完成！"
