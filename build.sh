#!/bin/bash

# 王者荣耀快速充值助手 - 快速编译脚本
# 使用方法: ./build.sh [device_ip]

echo "======================================"
echo "  王者荣耀快速充值助手 - 编译脚本"
echo "======================================"
echo ""

# 检查 Theos
if [ -z "$THEOS" ]; then
    echo "⚠️  警告: THEOS 环境变量未设置"
    echo "正在尝试使用默认路径: ~/theos"
    export THEOS=~/theos
fi

if [ ! -d "$THEOS" ]; then
    echo "❌ 错误: Theos 未安装在 $THEOS"
    echo "请先安装 Theos: https://theos.dev/docs/installation"
    exit 1
fi

echo "✓ Theos 路径: $THEOS"
echo ""

# 清理
echo "🧹 清理旧的编译文件..."
make clean

# 编译
echo ""
echo "🔨 开始编译..."
if make; then
    echo "✓ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

# 打包
echo ""
echo "📦 打包 deb..."
if make package; then
    echo "✓ 打包成功"
else
    echo "❌ 打包失败"
    exit 1
fi

# 显示生成的文件
echo ""
echo "📁 生成的文件:"
ls -lh packages/*.deb

# 安装到设备（如果提供了 IP）
if [ -n "$1" ]; then
    echo ""
    echo "📱 正在安装到设备 $1..."
    if make install THEOS_DEVICE_IP=$1 THEOS_DEVICE_PORT=22; then
        echo "✓ 安装成功！请重启 SpringBoard"
    else
        echo "❌ 安装失败，请检查设备连接"
        echo ""
        echo "💡 提示："
        echo "1. 确保设备已安装 OpenSSH"
        echo "2. 确认 IP 地址正确: $1"
        echo "3. 尝试手动 SSH 连接: ssh root@$1"
    fi
else
    echo ""
    echo "💡 提示: 运行 ./build.sh <设备IP> 可以自动安装到设备"
    echo ""
    echo "手动安装方法:"
    echo "1. 将 deb 文件复制到设备"
    echo "2. ssh root@设备IP"
    echo "3. dpkg -i /path/to/deb"
    echo "4. killall -9 SpringBoard"
fi

echo ""
echo "======================================"
echo "  编译完成！"
echo "======================================"

