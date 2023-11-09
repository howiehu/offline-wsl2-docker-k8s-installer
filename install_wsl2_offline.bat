@echo off
setlocal EnableDelayedExpansion

REM ���ű��Ƿ��Թ���ԱȨ������
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo �����Թ���ԱȨ�����������ű���
    powershell -Command "Start-Process cmd.exe -ArgumentList '/c %~f0' -Verb RunAs"
    exit /b
) 

REM �ű������岿�֣������Թ���ԱȨ��ִ��...

REM ��ȡ����ϵͳ�汾������
for /f "tokens=2 delims==" %%a in ('wmic os get Caption /value') do set "OSName=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get Version /value') do set "OSVersion=%%a"
for /f "tokens=2 delims==" %%a in ('wmic os get OSArchitecture /value') do set "OSArch=%%a"

REM ������ϵͳ�Ƿ�Ϊ64λ
if "%OSArch%" neq "64-bit" (
    echo ���ű���Ҫ64λ����ϵͳ����ִ�С�
    exit /b
)

REM ���Windows 11�������汾������Ϊ21H2 (build 22000)
set "Win11Detected=false"
echo !OSName! | findstr /C:"Microsoft Windows 11" >nul
for /f "tokens=3 delims=." %%i in ("!OSVersion!") do (
    set /a "build=%%i"
    if !build! GEQ 22000 (
        set "Win11Detected=true"
    )
)

REM ���Windows 10�������汾������Ϊ22H2 (build 19045)
set "Win10Detected=false"
echo !OSName! | findstr /C:"Microsoft Windows 10" >nul
for /f "tokens=3 delims=." %%i in ("!OSVersion!") do (
    set /a "build=%%i"
    if !build! GEQ 19045 (
        set "Win10Detected=true"
    )
)

REM �ж��Ƿ������͵Ĳ���ϵͳҪ��
if !Win11Detected! equ true (
    echo ��⵽ Windows 11 version 21H2 ����߰汾��
) else if !Win10Detected! equ true (
    echo ��⵽ Windows 10 version 22H2 ����߰汾��
) else (
    echo ��ǰWindows����ϵͳ�汾�޷�������Ͱ�װ������
    pause
    exit /b
)

REM ���ϵͳ�汾����Ҫ��ִ�к�������
echo ��ǰWindows����ϵͳ�汾������Ͱ�װ��������ʼִ�а�װ���򡭡�

REM ��ȡ�ű����ڵ�Ŀ¼·��
set "scriptPath=%~dp0"
set "dependenciesPath=%scriptPath%dependencies"

echo ��������WSL����...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
echo �������������ƽ̨����...
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

REM ���WSL2 Linux�ں˸��°��Ƿ����������ļ�����
set "wslUpdatePath=%dependenciesPath%\wsl_update_x64.msi"
if exist "%wslUpdatePath%" (
    echo ���ڰ�װWSL2 Linux�ں˸��°�...
    msiexec.exe /i "%wslUpdatePath%" /quiet /norestart
) else (
    echo WSL2 Linux�ں˸��°�δ�ҵ����뽫��ŵ� "%dependenciesPath%" Ŀ¼�¡�
    pause
    exit
)

REM ����WSL2ΪĬ�ϰ汾
echo ��������WSL2ΪĬ�ϰ汾...
wsl --set-default-version 2

REM ��ɰ�װ�����Ϣ
echo WSL2��װ��ɡ���������������ʹ��WSL2��

pause

endlocal