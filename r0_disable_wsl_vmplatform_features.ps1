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

Write-Host "正在回滚操作系统变更..."

# 禁用WSL功能
$WSLFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($WSLFeature.State -eq "Enabled") {
    Write-Host "正在禁用WSL功能..."
    Disable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
} else {
    Write-Host "WSL功能未启用，无需禁用。"
}

# 禁用虚拟机平台功能
$VMPlatformFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
if ($VMPlatformFeature.State -eq "Enabled") {
    Write-Host "正在禁用虚拟机平台功能..."
    Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
} else {
    Write-Host "虚拟机平台功能未启用，无需禁用。"
}

. (Join-Path $PSScriptRoot 'functions\Get-PendingRebootStatus.ps1')

# 根据重启标志判断是否需要提示用户重启计算机
$rebootStatus = Get-PendingRebootStatus
if ($rebootStatus.PendingReboot) {
    Write-Host "检测到重启需要，请重新启动计算机，以完成对WSL和虚拟机平台功能的禁用。"
} else {
    Write-Host "WSL和虚拟机平台功能已禁用，无需重新启动计算机。"
}

Pause