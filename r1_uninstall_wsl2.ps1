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

Write-Host "正在回滚WSL2安装..."

# 检查WSL2安装包是否已在依赖文件夹中
Write-Host "正在卸载WSL2的APPX安装..."
Get-AppxPackage MicrosoftCorporationII.WindowsSubsystemForLinux | Remove-AppxPackage
Write-Host "正在卸载WSL2的MSI安装..."
Start-Process "msiexec.exe" -ArgumentList '/uninstall "{408A5C50-34F2-4025-968E-A21D6A515D48}" /quiet /norestart' -Wait

. (Join-Path $PSScriptRoot 'functions\Get-PendingRebootStatus.ps1')

# 根据重启标志判断是否需要提示用户重启计算机
$rebootStatus = Get-PendingRebootStatus
if ($rebootStatus.PendingReboot) {
    Write-Host "检测到重启需要，请重新启动计算机，以完成WSL2的卸载。"
} else {
    Write-Host "WSL2已卸载，无需重新启动计算机。"
}

Pause