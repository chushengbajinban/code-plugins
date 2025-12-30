#!/bin/bash

# ========================
# 脚本说明
# ========================
# 一键在指定容器中安装 VS Code 插件（.vsix 文件）
# 插件文件需提前放在宿主机的 /path/to/vscode-extensions/ 目录下
# 安装完成后自动清理容器内临时目录

# ========================
# 参数校验
# ========================

if [ $# -ne 1 ]; then
    echo "❌ 用法: $0 <容器名称或ID>"
    echo "示例: $0 my-vscode-container"
    exit 1
fi

CONTAINER_NAME="$1"

# ========================
# 配置参数（请根据实际情况修改）
# ========================

# 宿主机上的插件目录（必须包含 .vsix 文件）
HOST_EXTENSIONS_DIR="/mnt/data/cursor-plugins"

# 容器内 VS Code 的安装路径（通常为 /usr/share/code 或 /usr/bin/code）
CODE_PATH="/root/.cursor-server/bin/20adc1003928b0f1b99305dbaf845656ff81f5d0/bin/remote-cli/cursor"

# 容器内挂载插件的临时路径
CONTAINER_EXTENSIONS_DIR="/tmp/vscode-extensions"

# ========================
# 脚本逻辑
# ========================

echo "🚀 开始在容器 [$CONTAINER_NAME] 中安装 VS Code 插件..."

# 检查宿主机插件目录是否存在
if [ ! -d "$HOST_EXTENSIONS_DIR" ]; then
    echo "❌ 宿主机插件目录不存在: $HOST_EXTENSIONS_DIR"
    exit 1
fi

# 检查容器是否存在并运行
if ! docker ps -q -f name="$CONTAINER_NAME" > /dev/null; then
    echo "❌ 容器 $CONTAINER_NAME 未运行或不存在。"
    exit 1
fi

检查容器内是否安装了 code 命令
if ! docker exec "$CONTAINER_NAME" which "$CODE_PATH" > /dev/null; then
    echo "❌ 容器内未找到 VS Code 可执行文件: $CODE_PATH"
    exit 1
fi

# 创建并挂载插件目录到容器内
echo "📁 创建容器内临时目录: $CONTAINER_EXTENSIONS_DIR"
docker exec "$CONTAINER_NAME" mkdir -p "$CONTAINER_EXTENSIONS_DIR"

echo "📦 复制插件文件到容器内..."
docker cp "$HOST_EXTENSIONS_DIR/." "$CONTAINER_NAME:$CONTAINER_EXTENSIONS_DIR/"

echo "🔧 开始安装插件..."
docker exec "$CONTAINER_NAME" bash -c "
    for vsix in $CONTAINER_EXTENSIONS_DIR/*.vsix; do
        if [ -f \"\$vsix\" ]; then
            echo \"Installing: \$vsix\"
            $CODE_PATH --install-extension \"\$vsix\"
            if [ \$? -eq 0 ]; then
                echo \"✅ 安装成功: \$vsix\"
            else
                echo \"❌ 安装失败: \$vsix\"
            fi
        fi
    done
"

# 清理容器内临时目录
echo "🗑️ 正在清理容器内临时目录: $CONTAINER_EXTENSIONS_DIR"
docker exec "$CONTAINER_NAME" rm -rf "$CONTAINER_EXTENSIONS_DIR"

echo "🎉 所有插件安装完成，临时文件已清理！"
