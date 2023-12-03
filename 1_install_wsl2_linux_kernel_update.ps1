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

# 检查虚拟机平台功能是否已经开启
$VMPlatformFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
if ($VMPlatformFeature.State -eq "Enabled") {
    Write-Host "虚拟机平台功能已经开启。"
} else {
    Write-Host "请先运行前置脚本，启用虚拟机平台功能！"
    Pause
    Exit
}

# 获取脚本所在的目录路径
$DependenciesPath = Join-Path $PSScriptRoot 'dependencies'

# 检查WSL2安装包是否已在依赖文件夹中
$WSL2Path = Join-Path $DependenciesPath "Microsoft.WSL_2.0.9.0_x64.msix"
if (Test-Path -Path $WSL2Path) {
    Write-Host "正在安装WSL2..."
    Add-AppxPackage -Path $WSL2Path
} else {
    Write-Host "WSL2安装包未找到，请将其放到 `"$DependenciesPath`" 目录下，并命名为：Microsoft.WSL_2.0.9.0_x64.msix"
    Pause
    Exit
}

# 设置WSL2为默认版本
Write-Host "设置WSL2为默认版本..."
wsl --set-default-version 2

. (Join-Path $PSScriptRoot 'functions\Get-PendingRebootStatus.ps1')

# 根据重启标志判断是否需要提示用户重启计算机
$rebootStatus = Get-PendingRebootStatus
if ($rebootStatus.PendingReboot) {
    Write-Host "检测到重启需要，请重新启动计算机，以完成WSL2的安装。"
} else {
    Write-Host "WSL2安装完成，无需重新启动计算机。"
}

Pause