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

Write-Host "正在检查操作系统版本..."

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
Write-Host "当前Windows操作系统版本满足最低安装条件，开始执行安装程序..."

# 检查WSL功能是否已经开启
$WSLFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($WSLFeature.State -eq "Enabled") {
    Write-Host "WSL功能已经开启。"
} else {
    Write-Host "正在启用WSL功能..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -All -NoRestart
}

# 检查虚拟机平台功能是否已经开启
$VMPlatformFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
if ($VMPlatformFeature.State -eq "Enabled") {
    Write-Host "虚拟机平台功能已经开启。"
} else {
    Write-Host "正在启用虚拟机平台功能..."
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -All -NoRestart
}

. (Join-Path $PSScriptRoot 'functions\Get-PendingRebootStatus.ps1')

# 根据重启标志判断是否需要提示用户重启计算机
$rebootStatus = Get-PendingRebootStatus
if ($rebootStatus) {
    Write-Host "检测到重启需要，请重新启动计算机，以完成对WSL和虚拟机平台功能的启用。"
} else {
    Write-Host "WSL和虚拟机平台功能已启用，无需重新启动计算机。"
}

Pause