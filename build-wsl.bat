@echo off
chcp 65001 >nul
echo ══════════════════════════════════════════════════════
echo   王者荣耀快速充值助手 - Windows WSL 编译脚本
echo ══════════════════════════════════════════════════════
echo.

REM 检查 WSL 是否安装
where wsl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误：未检测到 WSL
    echo.
    echo 请先安装 WSL：
    echo   1. 以管理员身份打开 PowerShell
    echo   2. 运行: wsl --install -d Ubuntu-22.04
    echo   3. 重启电脑
    echo   4. 按照 Windows编译指南.md 设置 Theos
    echo.
    pause
    exit /b 1
)

echo ✓ 检测到 WSL
echo.

REM 获取当前目录路径
set CURRENT_DIR=%CD%
set DRIVE=%CURRENT_DIR:~0,1%
set PATH_NO_DRIVE=%CURRENT_DIR:~2%

REM 转换为 WSL 路径格式（将反斜杠转为正斜杠）
set WSL_PATH=/mnt/%DRIVE%%PATH_NO_DRIVE:\=/%

echo 📁 项目目录: %CURRENT_DIR%
echo 📁 WSL 路径: %WSL_PATH%
echo.

REM 检查 Theos 是否安装
echo 🔍 检查 Theos 环境...
wsl test -d /opt/theos
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误：未检测到 Theos
    echo.
    echo 请先安装 Theos，参考 Windows编译指南.md
    echo 快速安装：
    echo   wsl sudo apt update
    echo   wsl sudo apt install -y git curl build-essential fakeroot perl clang
    echo   wsl sudo git clone --recursive https://github.com/theos/theos.git /opt/theos
    echo.
    pause
    exit /b 1
)

echo ✓ Theos 已安装
echo.

REM 开始编译
echo ══════════════════════════════════════════════════════
echo   开始编译...
echo ══════════════════════════════════════════════════════
echo.

echo 🧹 清理旧文件...
wsl cd "%WSL_PATH%" ^&^& export THEOS=/opt/theos ^&^& make clean

if %ERRORLEVEL% NEQ 0 (
    echo ❌ 清理失败
    pause
    exit /b 1
)

echo.
echo 🔨 编译项目...
wsl cd "%WSL_PATH%" ^&^& export THEOS=/opt/theos ^&^& make

if %ERRORLEVEL% NEQ 0 (
    echo ❌ 编译失败
    echo.
    echo 💡 可能的原因：
    echo   1. Theos 未正确安装
    echo   2. 缺少 iOS SDK
    echo   3. 代码语法错误
    echo.
    echo 请查看上方的错误信息
    pause
    exit /b 1
)

echo.
echo 📦 打包 deb...
wsl cd "%WSL_PATH%" ^&^& export THEOS=/opt/theos ^&^& make package

if %ERRORLEVEL% NEQ 0 (
    echo ❌ 打包失败
    pause
    exit /b 1
)

echo.
echo ══════════════════════════════════════════════════════
echo   ✓ 编译成功！
echo ══════════════════════════════════════════════════════
echo.

echo 📁 生成的 deb 文件：
echo.
if exist "packages\*.deb" (
    dir /b packages\*.deb
    echo.
    echo 文件位置：%CURRENT_DIR%\packages\
) else (
    echo ⚠️ 未找到 deb 文件
)

echo.
echo ══════════════════════════════════════════════════════
echo   下一步：
echo ══════════════════════════════════════════════════════
echo.
echo 1. 将 packages 目录下的 .deb 文件传输到 iOS 设备
echo 2. 使用 Filza 或 dpkg 安装
echo 3. 重启 SpringBoard
echo.
echo 或者使用 make install 直接安装到设备（需要 SSH）
echo.

pause

