# Windows 编译指南 - 王者荣耀快速充值助手

## 🪟 在 Windows 上编译 iOS 越狱插件

由于 Theos 主要支持 macOS/Linux，Windows 用户需要使用 **WSL (Windows Subsystem for Linux)** 来编译。

---

## 方法一：使用 WSL（推荐）⭐

### 第一步：安装 WSL

#### 1. 启用 WSL 功能（Windows 10/11）

打开 PowerShell（管理员），运行：

```powershell
# 安装 WSL2（推荐）
wsl --install

# 如果上面的命令不工作，使用这个：
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 重启电脑
```

#### 2. 安装 Ubuntu

```powershell
# 列出可用的 Linux 发行版
wsl --list --online

# 安装 Ubuntu（推荐 Ubuntu-22.04）
wsl --install -d Ubuntu-22.04
```

#### 3. 设置 Ubuntu

首次启动会要求创建用户名和密码：
```
Enter new UNIX username: yourname
New password: ********
Retype new password: ********
```

### 第二步：在 WSL 中安装 Theos

打开 Ubuntu（从开始菜单搜索 "Ubuntu"），然后执行：

```bash
# 1. 更新系统
sudo apt update
sudo apt upgrade -y

# 2. 安装必要的工具
sudo apt install -y git curl build-essential fakeroot perl clang

# 3. 设置 Theos 路径
echo 'export THEOS=/opt/theos' >> ~/.bashrc
echo 'export PATH=$THEOS/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 4. 安装 Theos
sudo mkdir -p /opt
sudo chown $USER:$USER /opt
git clone --recursive https://github.com/theos/theos.git /opt/theos

# 5. 安装 iOS SDK
cd $THEOS/sdks
curl -LO https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/* .
rm -rf sdks-master master.zip
```

### 第三步：访问 Windows 文件

WSL 可以访问 Windows 文件系统，你的项目在：

```bash
# Windows 的 D:\project\1023001 对应 WSL 的：
cd /mnt/d/project/1023001

# 查看文件
ls -la
```

### 第四步：编译项目

```bash
# 1. 进入项目目录
cd /mnt/d/project/1023001

# 2. 清理并编译
make clean
make

# 3. 打包 deb
make package

# 4. 查看生成的文件
ls -lh packages/
```

### 第五步：获取 deb 文件

编译完成后，deb 文件在：
```
Windows 路径: D:\project\1023001\packages\*.deb
WSL 路径:    /mnt/d/project/1023001/packages/*.deb
```

直接在 Windows 资源管理器中打开 `D:\project\1023001\packages\` 即可看到编译好的 deb 文件！

---

## 方法二：使用 Docker（稍复杂）

### 1. 安装 Docker Desktop

从官网下载：https://www.docker.com/products/docker-desktop

### 2. 创建 Dockerfile

在项目目录创建 `Dockerfile`：

```dockerfile
FROM ubuntu:22.04

# 安装依赖
RUN apt-get update && apt-get install -y \
    git curl build-essential fakeroot perl clang \
    && rm -rf /var/lib/apt/lists/*

# 安装 Theos
ENV THEOS=/opt/theos
RUN git clone --recursive https://github.com/theos/theos.git $THEOS

# 安装 SDK
WORKDIR $THEOS/sdks
RUN curl -LO https://github.com/theos/sdks/archive/master.zip \
    && unzip master.zip \
    && mv sdks-master/* . \
    && rm -rf sdks-master master.zip

WORKDIR /project
```

### 3. 编译

```powershell
# 构建 Docker 镜像
docker build -t theos-builder .

# 编译项目
docker run --rm -v ${PWD}:/project theos-builder make clean package
```

---

## 方法三：使用虚拟机

### 1. 安装 VirtualBox

下载：https://www.virtualbox.org/

### 2. 安装 Ubuntu 虚拟机

- 下载 Ubuntu ISO：https://ubuntu.com/download/desktop
- 在 VirtualBox 中创建虚拟机
- 安装 Ubuntu

### 3. 在虚拟机中按照 Linux 步骤编译

---

## 方法四：在线编译服务（不推荐）

可以使用 GitHub Actions 自动编译：

### 1. 创建 `.github/workflows/build.yml`

```yaml
name: Build Tweak

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Install Theos
      run: |
        sudo apt-get update
        sudo apt-get install -y git curl build-essential fakeroot perl
        export THEOS=/opt/theos
        sudo git clone --recursive https://github.com/theos/theos.git $THEOS
        cd $THEOS/sdks
        sudo curl -LO https://github.com/theos/sdks/archive/master.zip
        sudo unzip master.zip
        sudo mv sdks-master/* .
    
    - name: Build
      run: |
        export THEOS=/opt/theos
        make clean
        make package
    
    - name: Upload artifact
      uses: actions/upload-artifact@v2
      with:
        name: deb-package
        path: packages/*.deb
```

推送到 GitHub 后，会自动编译并生成 deb 文件。

---

## 🎯 推荐方案对比

| 方案 | 难度 | 速度 | 推荐度 | 说明 |
|------|------|------|--------|------|
| **WSL** | ⭐⭐ | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | 最推荐，原生集成 |
| Docker | ⭐⭐⭐ | ⚡⚡ | ⭐⭐⭐ | 适合熟悉 Docker 的用户 |
| 虚拟机 | ⭐⭐ | ⚡ | ⭐⭐ | 占用资源多，较慢 |
| GitHub Actions | ⭐ | ⚡⚡⚡ | ⭐⭐⭐ | 简单但需要网络 |

---

## 🔧 常见问题

### Q1: WSL 安装失败？

**方案 A：使用 Microsoft Store**
1. 打开 Microsoft Store
2. 搜索 "Ubuntu"
3. 点击安装

**方案 B：手动下载**
```powershell
# 下载 Ubuntu
Invoke-WebRequest -Uri https://aka.ms/wslubuntu2204 -OutFile Ubuntu.appx -UseBasicParsing

# 安装
Add-AppxPackage .\Ubuntu.appx
```

### Q2: make 命令找不到？

```bash
# 在 WSL 中安装
sudo apt install build-essential
```

### Q3: 权限问题？

```bash
# 给予执行权限
chmod +x build.sh log.sh

# 或使用 sudo
sudo make package
```

### Q4: 编译错误：找不到 SDK？

```bash
# 检查 SDK
ls $THEOS/sdks/

# 重新下载
cd $THEOS/sdks
curl -LO https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/* .
```

### Q5: 如何在 WSL 和 Windows 之间传输文件？

```bash
# WSL 访问 Windows 文件
cd /mnt/c/Users/你的用户名/Downloads

# Windows 访问 WSL 文件
# 在资源管理器输入：\\wsl$\Ubuntu\home\yourname
```

---

## 📝 完整编译流程示例

### 使用 WSL（从零开始）

```powershell
# 1. 在 PowerShell（管理员）中安装 WSL
wsl --install -d Ubuntu-22.04

# 重启电脑后，打开 Ubuntu
```

```bash
# 2. 在 Ubuntu 中设置环境
sudo apt update
sudo apt install -y git curl build-essential fakeroot perl clang

# 3. 安装 Theos
sudo mkdir -p /opt
sudo chown $USER:$USER /opt
git clone --recursive https://github.com/theos/theos.git /opt/theos
echo 'export THEOS=/opt/theos' >> ~/.bashrc
source ~/.bashrc

# 4. 安装 SDK
cd /opt/theos/sdks
curl -LO https://github.com/theos/sdks/archive/master.zip
unzip master.zip
mv sdks-master/* .
rm -rf sdks-master master.zip

# 5. 编译项目
cd /mnt/d/project/1023001
make clean
make package

# 6. 查看结果
ls -lh packages/
```

完成后，在 Windows 的 `D:\project\1023001\packages\` 目录就能看到编译好的 deb 文件了！

---

## 🎯 快捷编译脚本（WSL 专用）

创建 `build-wsl.bat`：

```batch
@echo off
echo ====================================
echo   开始编译 iOS 越狱插件
echo ====================================
echo.

wsl cd /mnt/d/project/1023001 ^&^& make clean ^&^& make package

echo.
echo ====================================
echo   编译完成！
echo ====================================
echo.
echo deb 文件位置：
dir /b packages\*.deb

pause
```

双击 `build-wsl.bat` 即可一键编译！

---

## 💡 小贴士

1. **第一次安装 WSL 后需要重启电脑**
2. **WSL 可以访问所有 Windows 盘符**：`/mnt/c`、`/mnt/d` 等
3. **在 WSL 中编译速度很快**，和原生 Linux 几乎一样
4. **可以使用 VSCode 的 WSL 插件**直接在 Windows 上编辑，在 WSL 中编译
5. **编译一次后，下次只需要几秒钟**

---

## 📚 相关资源

- [WSL 官方文档](https://docs.microsoft.com/zh-cn/windows/wsl/)
- [Theos 官方文档](https://theos.dev/docs/)
- [WSL 安装教程](https://docs.microsoft.com/zh-cn/windows/wsl/install)

---

如有问题，欢迎反馈！

