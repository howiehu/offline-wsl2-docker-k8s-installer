# 检查脚本是否以管理员权限运行
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # 获取当前的PowerShell脚本的路径
    $script = $MyInvocation.MyCommand.Definition
    
    # 以管理员权限重新启动当前脚本
    Start-Process pwsh -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$script`"" -Verb RunAs
    
    # 退出当前的脚本执行
    Exit
}

# 脚本的主体部分，它会以管理员权限执行...

# 检测操作系统是否为64位
if (![Environment]::Is64BitOperatingSystem) {
    Write-Host "本脚本需要64位操作系统方可执行。"
    Exit
}

# 检测Windows 11条件：版本号至少为21H2 (build 22000)
$Win11Detected = $false
if ([Environment]::OSVersion.Version.Build -ge 22000) {
    $Win11Detected = $true
}

# 检测Windows 10条件：版本号至少为22H2 (build 19045)
$Win10Detected = $false
if ([Environment]::OSVersion.Version.Build -ge 19045) {
    $Win10Detected = $true
}

# 判断是否符合最低的操作系统要求
if ($Win11Detected) {
    Write-Host "检测到 Windows 11 version 21H2 或更高版本。"
} elseif ($Win10Detected) {
    Write-Host "检测到 Windows 10 version 22H2 或更高版本。"
} else {
    Write-Host "当前Windows操作系统版本无法满足最低安装条件。"
    Pause
    Exit
}

# 如果系统版本符合要求，执行后续命令
Write-Host "当前Windows操作系统版本满足最低安装条件，开始执行安装程序……"

# 获取脚本所在的目录路径
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$DependenciesPath = Join-Path -Path $ScriptPath -ChildPath "dependencies"

# 检查WSL功能是否已经开启或需要重启
$WSLFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($WSLFeature.State -eq "Enabled") {
    Write-Host "WSL功能已经开启。"
} else {
    Write-Host "正在启用WSL功能..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
}

# 检查虚拟机平台功能是否已经开启或需要重启
$VMPlatformFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
if ($VMPlatformFeature.State -eq "Enabled") {
    Write-Host "虚拟机平台功能已经开启。"
} else {
    Write-Host "正在启用虚拟机平台功能..."
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
}

# 检查WSL2 Linux内核更新包是否已在依赖文件夹中
$WslUpdatePath = Join-Path -Path $DependenciesPath -ChildPath "wsl_update_x64.msi"
if (Test-Path -Path $WslUpdatePath) {
    Write-Host "正在安装WSL2 Linux内核更新包..."
    Start-Process "msiexec.exe" -ArgumentList "/i `"C:\Users\huhao\myprojects\offline-wsl2-docker-k8s-installer\dependencies\wsl_update_x64.msi`" /quiet /norestart" -Wait
} else {
    Write-Host "WSL2 Linux内核更新包未找到，请将其放到 `"$DependenciesPath`" 目录下。"
    Pause
    Exit
}

# 设置WSL2为默认版本
Write-Host "正在设置WSL2为默认版本..."
wsl --set-default-version 2

# 完成安装后的消息
Write-Host "WSL2安装完成。请在重新启动后使用WSL2。"

Pause