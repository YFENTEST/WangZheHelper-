@echo off
chcp 65001 >nul

echo ══════════════════════════════════════════════════════
echo   王者荣耀快速充值助手
echo   WSL + Theos 一键安装脚本
echo ══════════════════════════════════════════════════════
echo.
echo ⚠️  注意：
echo   1. 此脚本需要管理员权限
echo   2. 安装过程需要网络连接
echo   3. 首次安装需要重启电脑
echo   4. 安装时间约 10-20 分钟
echo.
echo 按任意键开始安装，或关闭窗口取消...
pause >nul

echo.
echo ══════════════════════════════════════════════════════
echo   第 1 步：检查管理员权限
echo ══════════════════════════════════════════════════════

net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo ❌ 需要管理员权限！
    echo.
    echo 请右键点击此脚本，选择"以管理员身份运行"
    echo.
    pause
    exit /b 1
)

echo ✓ 已获取管理员权限
echo.

echo ══════════════════════════════════════════════════════
echo   第 2 步：检查 WSL 状态
echo ══════════════════════════════════════════════════════

where wsl >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ WSL 已安装
    goto :install_ubuntu
) else (
    echo ⚠️ WSL 未安装，开始安装...
)

echo.
echo 正在安装 WSL...
wsl --install --no-distribution

if %ERRORLEVEL% NEQ 0 (
    echo ❌ WSL 安装失败
    echo.
    echo 请手动运行以下命令（PowerShell 管理员）：
    echo   wsl --install
    echo.
    pause
    exit /b 1
)

echo.
echo ✓ WSL 安装完成
echo.
echo ⚠️ 需要重启电脑才能继续
echo.
echo 重启后，请再次运行此脚本继续安装 Ubuntu 和 Theos
echo.
set /p REBOOT="是否现在重启？(Y/N): "
if /i "%REBOOT%"=="Y" (
    shutdown /r /t 10 /c "重启后继续安装 WSL 和 Theos"
    echo 10 秒后将重启...
    pause
) else (
    echo 请手动重启后继续
    pause
)
exit /b 0

:install_ubuntu
echo.
echo ══════════════════════════════════════════════════════
echo   第 3 步：安装 Ubuntu
echo ══════════════════════════════════════════════════════

wsl -l | findstr "Ubuntu" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo ✓ Ubuntu 已安装
    goto :install_theos
)

echo 正在安装 Ubuntu 22.04...
echo （这可能需要几分钟，请耐心等待）
echo.

wsl --install -d Ubuntu-22.04

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Ubuntu 安装失败
    echo.
    echo 请手动安装：
    echo   1. 打开 Microsoft Store
    echo   2. 搜索 "Ubuntu 22.04"
    echo   3. 点击安装
    echo.
    pause
    exit /b 1
)

echo.
echo ✓ Ubuntu 安装完成
echo.
echo ⚠️ 首次启动 Ubuntu 需要设置用户名和密码
echo.
echo 按任意键启动 Ubuntu 进行初始设置...
pause >nul

start wsl -d Ubuntu-22.04

echo.
echo 请在弹出的 Ubuntu 窗口中完成设置后，关闭窗口
echo 然后按任意键继续安装 Theos...
pause >nul

:install_theos
echo.
echo ══════════════════════════════════════════════════════
echo   第 4 步：安装 Theos 及依赖
echo ══════════════════════════════════════════════════════
echo.

echo 检查 Theos 是否已安装...
wsl test -d /opt/theos
if %ERRORLEVEL% EQU 0 (
    echo ✓ Theos 已安装
    echo.
    set /p REINSTALL="是否重新安装 Theos？(Y/N): "
    if /i not "%REINSTALL%"=="Y" goto :finish
    echo 正在删除旧版本...
    wsl sudo rm -rf /opt/theos
)

echo.
echo 正在安装必要的工具...
echo （这可能需要几分钟）
echo.

wsl sudo apt update
wsl sudo apt install -y git curl build-essential fakeroot perl clang

if %ERRORLEVEL% NEQ 0 (
    echo ❌ 工具安装失败
    pause
    exit /b 1
)

echo.
echo ✓ 工具安装完成
echo.

echo 正在克隆 Theos...
wsl sudo mkdir -p /opt
wsl sudo chown $USER:$USER /opt
wsl git clone --recursive https://github.com/theos/theos.git /opt/theos

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Theos 克隆失败
    pause
    exit /b 1
)

echo.
echo ✓ Theos 克隆完成
echo.

echo 配置环境变量...
wsl bash -c "grep -q 'export THEOS=/opt/theos' ~/.bashrc || echo 'export THEOS=/opt/theos' >> ~/.bashrc"
wsl bash -c "grep -q 'export PATH=\$THEOS/bin:\$PATH' ~/.bashrc || echo 'export PATH=\$THEOS/bin:\$PATH' >> ~/.bashrc"

echo.
echo ✓ 环境变量配置完成
echo.

echo ══════════════════════════════════════════════════════
echo   第 5 步：安装 iOS SDK
echo ══════════════════════════════════════════════════════
echo.

echo 正在下载 iOS SDK...
wsl bash -c "cd /opt/theos/sdks && curl -LO https://github.com/theos/sdks/archive/master.zip"

if %ERRORLEVEL% NEQ 0 (
    echo ❌ SDK 下载失败
    pause
    exit /b 1
)

echo 正在解压 SDK...
wsl bash -c "cd /opt/theos/sdks && unzip -q master.zip && mv sdks-master/* . && rm -rf sdks-master master.zip"

echo.
echo ✓ iOS SDK 安装完成
echo.

:finish
echo ══════════════════════════════════════════════════════
echo   ✓ 安装完成！
echo ══════════════════════════════════════════════════════
echo.
echo 已安装组件：
echo   ✓ WSL 2
echo   ✓ Ubuntu 22.04
echo   ✓ Theos 框架
echo   ✓ iOS SDK
echo   ✓ 编译工具链
echo.
echo ══════════════════════════════════════════════════════
echo   下一步：
echo ══════════════════════════════════════════════════════
echo.
echo 1. 双击运行 build-wsl.bat 编译项目
echo 2. 编译完成后，在 packages 目录找到 .deb 文件
echo 3. 将 .deb 文件传输到 iOS 设备安装
echo.
echo 💡 提示：
echo   - 如需进入 WSL：在开始菜单搜索 "Ubuntu"
echo   - 如需手动编译：参考 Windows编译指南.md
echo   - WSL 中访问项目：cd /mnt/d/project/1023001
echo.
echo 按任意键退出...
pause >nul

