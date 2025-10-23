#!/bin/bash

# 王者荣耀快速充值助手 - 日志查看脚本
# 使用方法: ./log.sh <设备IP>

if [ -z "$1" ]; then
    echo "使用方法: ./log.sh <设备IP>"
    echo "示例: ./log.sh 192.168.1.100"
    exit 1
fi

DEVICE_IP=$1

echo "======================================"
echo "  王者荣耀快速充值助手 - 日志查看"
echo "======================================"
echo ""
echo "设备 IP: $DEVICE_IP"
echo "按 Ctrl+C 退出"
echo ""
echo "--------------------------------------"

# 连接到设备并查看日志
ssh root@$DEVICE_IP "tail -f /var/log/syslog" | grep --line-buffered "WZHelper"

