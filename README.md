# 离线WSL2、Docker、K8s安装工具（Offline WSL2/Docker/K8s Installer）

作者正被Windows下如:shit:一般的自动化运维能力，以及各大企业如:shit:一般的开发者体验所折磨，没有心思认真写README。

**注意：本安装工具仅会安装Docker所依赖的组件，不会安装Linux发行版（例如Ubuntu），如有需要请自行研究安装。**

## 必要条件（Requirements）

- Windows 11 21H2 (build 22000) 或更高版本
- ~~Windows 10 22H2 (build 19045) 或更高版本~~（理论上支持，但未在此环境做过测试）
- PowerShell（pwsh） 7.3.9 或更高版本（**非Windows PowerShell**，本安装工具已附带，或自行前往Github下载[最新的64位MSI安装包](https://github.com/PowerShell/PowerShell/releases/)）
- Docker for Desktop 4.25.2 或更高版本（由于安装包体积太大，[需自行前往官方网站下载Windows版本的安装程序](https://www.docker.com/products/docker-desktop/)并放置在本安装工具的`dependencies`文件夹下，并确保命名为`Docker Desktop Installer.exe`）

## 使用方法（Usage）

1. 手动安装本安装工具所附带的（或自行下载的）PowerShell。（**需要注意，请不要安装并使用Microsoft Store版本的PowerShell，截止本安装工具测试时间为止，该商城版本的PowerShell存在无法正常点击并执行`*.ps1`脚本文件的问题**）
2. 选择使用`C:\Program Files\PowerShell\7\pwsh.exe`（默认路径）作为`*.ps1`脚本文件的默认运行程序。
3. 使用PowerShell，通过手动点击或在命令行中按下方所述顺序运行相应的`*.ps1`脚本文件。

### 脚本运行顺序

#### 安装（Install）

1. `0_enable_wsl_vmplatform_features.ps1` - 开启Windows自带的WSL和虚拟机平台功能。
2. `1_install_wsl2_linux_kernel_update.ps1` - 安装WSL2 Linux内核更新程序（如果当前的WSL2 Linux内核版本更高则会跳过安装）。
3. `2_install_docker_for_desktop.ps1` - 安装并配置Docker for Desktop。

#### 卸载（Uninstall）

1. `r0_uninstall_docker_for_desktop.ps1` - 卸载Docker for Desktop。
2. `r1_uninstall_wsl_linux_kernel_update.ps1` - 卸载WSL2 Linux内核更新程序。
3. `r2_disable_wsl_vmplatform_features.ps1` - 关闭Windows自带的WSL和虚拟机平台功能。