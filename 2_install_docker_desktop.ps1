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

# 检查Docker Desktop安装包是否已在依赖文件夹中
$InstallerPath = Join-Path $DependenciesPath "Docker Desktop Installer.exe"
if (Test-Path -Path $InstallerPath) {
    Write-Host "正在安装Docker Desktop..."
    Start-Process `"$InstallerPath`" -ArgumentList 'install --quiet --accept-license' -Wait
} else {
    Write-Host "Docker Desktop安装包未找到，请将其放到 `"$DependenciesPath`" 目录下，并命名为：Docker Desktop Installer.exe"
    Pause
    Exit
}

. (Join-Path $PSScriptRoot 'functions\Get-PendingRebootStatus.ps1')

# 根据重启标志判断是否需要提示用户重启计算机
$rebootStatus = Get-PendingRebootStatus
if ($rebootStatus.PendingReboot) {
    Write-Host "检测到重启需要，请重新启动计算机，以完成Docker Desktop的安装。"
} else {
    Write-Host "Docker Desktop安装完成，请注销并重新登录当前用户后使用。"
}

Pause