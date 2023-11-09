@echo off
setlocal EnableDelayedExpansion

REM 检查脚本是否以管理员权限运行
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 尝试以管理员权限重新启动脚本。
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c %~f0' -Verb RunAs"
    exit /b
) 

REM 脚本的主体部分，它会以管理员权限执行...

REM 获取操作系统版本和名称
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value') do set "OSName=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get Version /value') do set "OSVersion=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get OSArchitecture /value') do set "OSArch=%%a"

REM 检测操作系统是否为64位
if "%OSArch%" neq "64-bit" (
    echo 本脚本需要64位操作系统方可执行。
    exit /b
)

REM 检测Windows 11条件：版本号至少为21H2 (build 22000)
set "Win11Detected=false"
echo !OSName! | findstr /C:"Microsoft Windows 11" >nul
for /f "tokens=3 delims=." %%i in ("!OSVersion!") do (
    set /a "build=%%i"
    if !build! GEQ 22000 (
        set "Win11Detected=true"
    )
)

REM 检测Windows 10条件：版本号至少为22H2 (build 19045)
set "Win10Detected=false"
echo !OSName! | findstr /C:"Microsoft Windows 10" >nul
for /f "tokens=3 delims=." %%i in ("!OSVersion!") do (
    set /a "build=%%i"
    if !build! GEQ 19045 (
        set "Win10Detected=true"
    )
)

REM 判断是否符合最低的操作系统要求
if !Win11Detected! equ true (
    echo 检测到 Windows 11 version 21H2 或更高版本。
) else if !Win10Detected! equ true (
    echo 检测到 Windows 10 version 22H2 或更高版本。
) else (
    echo 当前Windows操作系统版本无法满足最低安装条件。
    pause
    exit /b
)

REM 如果系统版本符合要求，执行后续命令
echo 当前Windows操作系统版本满足最低安装条件，开始执行安装程序……

REM 获取脚本所在的目录路径
set "scriptPath=%~dp0"
set "dependenciesPath=%scriptPath%dependencies"

echo 正在启用WSL功能...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
echo 正在启用虚拟机平台功能...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

REM 检查WSL2 Linux内核更新包是否已在依赖文件夹中
set "wslUpdatePath=%dependenciesPath%\wsl_update_x64.msi"
if exist "%wslUpdatePath%" (
    echo 正在安装WSL2 Linux内核更新包...
    msiexec.exe /i "%wslUpdatePath%" /quiet /norestart
) else (
    echo WSL2 Linux内核更新包未找到，请将其放到 "%dependenciesPath%" 目录下。
    pause
    exit
)

REM 设置WSL2为默认版本
echo 正在设置WSL2为默认版本...
wsl --set-default-version 2

REM 完成安装后的消息
echo WSL2安装完成。请在重新启动后使用WSL2。

pause

endlocal