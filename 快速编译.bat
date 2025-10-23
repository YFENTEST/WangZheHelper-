@echo off
:: 使用 UTF-8 编码
chcp 65001 >nul 2>&1

cls
echo.
echo ========================================================
echo    Wang Zhe Helper - Quick Build Script
echo ========================================================
echo.

REM 检查 WSL
where wsl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] WSL not found
    echo.
    echo Please install WSL first:
    echo   Run "install-environment.bat" as Administrator
    echo.
    pause
    exit /b 1
)

echo [OK] WSL detected
echo.

REM 获取当前目录的 WSL 路径
set CURRENT_DIR=%CD%
set DRIVE=%CURRENT_DIR:~0,1%
set PATH_NO_DRIVE=%CURRENT_DIR:~2%
call :toLowerCase DRIVE
set WSL_PATH=/mnt/%DRIVE%%PATH_NO_DRIVE:\=/%

echo Project: %CURRENT_DIR%
echo WSL Path: %WSL_PATH%
echo.

REM 检查 Theos
echo Checking Theos...
wsl test -d /opt/theos 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [X] Theos not found
    echo.
    echo Please install Theos first:
    echo   Run "install-environment.bat" as Administrator
    echo.
    pause
    exit /b 1
)

echo [OK] Theos found
echo.

REM 编译
echo ========================================================
echo    Building...
echo ========================================================
echo.

echo [1/3] Cleaning...
wsl cd "%WSL_PATH%" ^&^& export THEOS=/opt/theos ^&^& make clean

if %ERRORLEVEL% NEQ 0 (
    echo [X] Clean failed
    pause
    exit /b 1
)

echo.
echo [2/3] Compiling...
wsl cd "%WSL_PATH%" ^&^& export THEOS=/opt/theos ^&^& make

if %ERRORLEVEL% NEQ 0 (
    echo [X] Compile failed
    echo.
    echo Possible reasons:
    echo   1. Theos not properly installed
    echo   2. Missing iOS SDK
    echo   3. Code syntax error
    echo.
    echo Check the error messages above
    pause
    exit /b 1
)

echo.
echo [3/3] Packaging...
wsl cd "%WSL_PATH%" ^&^& export THEOS=/opt/theos ^&^& make package

if %ERRORLEVEL% NEQ 0 (
    echo [X] Package failed
    pause
    exit /b 1
)

echo.
echo ========================================================
echo    Build Complete!
echo ========================================================
echo.

echo Generated files:
echo.
if exist "packages\*.deb" (
    dir /b packages\*.deb
    echo.
    echo Location: %CURRENT_DIR%\packages\
) else (
    echo [!] No .deb file found
)

echo.
echo ========================================================
echo    Next Steps:
echo ========================================================
echo.
echo 1. Transfer the .deb file to your iOS device
echo 2. Install using Filza or dpkg
echo 3. Respring (restart SpringBoard)
echo.

pause
goto :eof

:toLowerCase
set %1=!%1!
for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do call set %1=%%%1:%%i=%%i%%
goto :eof

