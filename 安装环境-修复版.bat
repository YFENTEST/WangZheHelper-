@echo off
:: 使用 UTF-8 编码
chcp 65001 >nul 2>&1

cls
echo.
echo ========================================================
echo    Wang Zhe Helper - WSL + Theos Installation
echo ========================================================
echo.
echo WARNING:
echo   1. Administrator privileges required
echo   2. Internet connection required
echo   3. May need to restart once
echo   4. Takes about 10-20 minutes
echo.
echo Press any key to start, or close window to cancel...
pause >nul

echo.
echo ========================================================
echo    Step 1: Check Administrator Privileges
echo ========================================================

net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo [X] Administrator privileges required!
    echo.
    echo Please right-click this script and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [OK] Administrator privileges granted
echo.

echo ========================================================
echo    Step 2: Check WSL Status
echo ========================================================

where wsl >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] WSL is installed
    goto :install_ubuntu
) else (
    echo [!] WSL not installed, installing...
)

echo.
echo Installing WSL...
wsl --install --no-distribution

if %ERRORLEVEL% NEQ 0 (
    echo [X] WSL installation failed
    echo.
    echo Please run this command manually in PowerShell (as Admin):
    echo   wsl --install
    echo.
    pause
    exit /b 1
)

echo.
echo [OK] WSL installed
echo.
echo [!] Computer restart required
echo.
echo After restart, run this script again to continue
echo.
set /p REBOOT="Restart now? (Y/N): "
if /i "%REBOOT%"=="Y" (
    shutdown /r /t 10 /c "Restarting to complete WSL installation"
    echo Restarting in 10 seconds...
    pause
) else (
    echo Please restart manually and run this script again
    pause
)
exit /b 0

:install_ubuntu
echo.
echo ========================================================
echo    Step 3: Install Ubuntu
echo ========================================================

wsl -l 2>nul | findstr "Ubuntu" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Ubuntu is already installed
    goto :install_theos
)

echo Installing Ubuntu...
echo (This may take a few minutes, please wait)
echo.

:: Try Ubuntu (latest version)
wsl --install -d Ubuntu

if %ERRORLEVEL% NEQ 0 (
    echo [!] Failed with "Ubuntu", trying "Ubuntu-20.04"...
    wsl --install -d Ubuntu-20.04
    
    if %ERRORLEVEL% NEQ 0 (
        echo [X] Ubuntu installation failed
        echo.
        echo Please install manually:
        echo   1. Open Microsoft Store
        echo   2. Search for "Ubuntu"
        echo   3. Click Install
        echo.
        pause
        exit /b 1
    )
)

echo.
echo [OK] Ubuntu installed
echo.
echo [!] First time setup required
echo.
echo Press any key to launch Ubuntu for initial setup...
pause >nul

start wsl

echo.
echo Complete the setup in the Ubuntu window, then close it
echo Press any key here to continue installing Theos...
pause >nul

:install_theos
echo.
echo ========================================================
echo    Step 4: Install Theos and Dependencies
echo ========================================================
echo.

echo Checking if Theos is already installed...
wsl test -d /opt/theos 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Theos is already installed
    echo.
    set /p REINSTALL="Reinstall Theos? (Y/N): "
    if /i not "%REINSTALL%"=="Y" goto :finish
    echo Removing old version...
    wsl sudo rm -rf /opt/theos
)

echo.
echo Installing required tools...
echo (This may take a few minutes)
echo.

wsl sudo apt update
wsl sudo apt install -y git curl build-essential fakeroot perl clang

if %ERRORLEVEL% NEQ 0 (
    echo [X] Tool installation failed
    pause
    exit /b 1
)

echo.
echo [OK] Tools installed
echo.

echo Cloning Theos repository...
wsl sudo mkdir -p /opt
wsl sudo chown $USER:$USER /opt
wsl git clone --recursive https://github.com/theos/theos.git /opt/theos

if %ERRORLEVEL% NEQ 0 (
    echo [X] Theos clone failed
    pause
    exit /b 1
)

echo.
echo [OK] Theos cloned
echo.

echo Configuring environment variables...
wsl bash -c "grep -q 'export THEOS=/opt/theos' ~/.bashrc || echo 'export THEOS=/opt/theos' >> ~/.bashrc"
wsl bash -c "grep -q 'export PATH=$THEOS/bin:$PATH' ~/.bashrc || echo 'export PATH=$THEOS/bin:$PATH' >> ~/.bashrc"

echo.
echo [OK] Environment configured
echo.

echo ========================================================
echo    Step 5: Install iOS SDK
echo ========================================================
echo.

echo Downloading iOS SDK...
wsl bash -c "cd /opt/theos/sdks && curl -LO https://github.com/theos/sdks/archive/master.zip"

if %ERRORLEVEL% NEQ 0 (
    echo [X] SDK download failed
    pause
    exit /b 1
)

echo Extracting SDK...
wsl bash -c "cd /opt/theos/sdks && unzip -q master.zip && mv sdks-master/* . && rm -rf sdks-master master.zip"

echo.
echo [OK] iOS SDK installed
echo.

:finish
echo ========================================================
echo    Installation Complete!
echo ========================================================
echo.
echo Installed components:
echo   [OK] WSL 2
echo   [OK] Ubuntu
echo   [OK] Theos Framework
echo   [OK] iOS SDK
echo   [OK] Build Tools
echo.
echo ========================================================
echo    Next Steps:
echo ========================================================
echo.
echo 1. Double-click "build-wsl.bat" to compile the project
echo 2. Find the .deb file in the "packages" folder
echo 3. Transfer the .deb file to your iOS device
echo.
echo Press any key to exit...
pause >nul

