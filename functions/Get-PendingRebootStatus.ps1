# 系统重新启动状态检测函数，由chatGPT引用自 https://thesysadminchannel.com/remotely-check-pending-reboot-status-powershell/
Function Get-PendingRebootStatus {
    [CmdletBinding()]
    Param (
        [string[]] $ComputerName = $env:COMPUTERNAME
    )

    PROCESS {
        Foreach ($Computer in $ComputerName) {
            Try {
                $PendingReboot = $false

                $HKLM = [UInt32] "0x80000002"
                $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv"

                if ($WMI_Reg) {
                    if (($WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\")).sNames -contains 'RebootPending') {$PendingReboot = $true}
                    if (($WMI_Reg.EnumKey($HKLM,"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\")).sNames -contains 'RebootRequired') {$PendingReboot = $true}

                    #检查SCCM命名空间
                    $SCCM_Namespace = Get-WmiObject -Namespace ROOT\CCM\ClientSDK -List -ComputerName $Computer -ErrorAction Ignore
                    if ($SCCM_Namespace) {
                        if (([WmiClass]"\$Computer\ROOT\CCM\ClientSDK:CCM_ClientUtilities").DetermineIfRebootPending().RebootPending -eq $true) {$PendingReboot = $true}
                    }

                    [PSCustomObject]@{
                        ComputerName  = $Computer.ToUpper()
                        PendingReboot = $PendingReboot
                    }
                }
            } catch {
                Write-Error $_.Exception.Message
            } finally {
                #清除变量
                $null = $WMI_Reg
                $null = $SCCM_Namespace
            }
        }
    }
}