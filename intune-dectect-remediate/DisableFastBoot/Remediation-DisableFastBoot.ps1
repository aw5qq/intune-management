<#
.SYNOPSIS
    Disables Fast Boot (Hiberboot) by updating the registry.

.DESCRIPTION
    This script sets the "HiberbootEnabled" registry value to 0, which disables Fast Boot.
    Intended to be run as a remediation script in Microsoft Intune.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
    
    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

# Registry path and value
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$regName = "HiberbootEnabled"
$desiredValue = 0  # 0 = Disabled

try {
    if (Test-Path -Path $regPath) {
        Set-ItemProperty -Path $regPath -Name $regName -Value $desiredValue -ErrorAction Stop
        Write-Output "Fast Boot has been successfully disabled."
        Exit 0
    } else {
        Write-Output "Registry path not found: $regPath"
        Exit 1
    }
}
catch {
    Write-Output "Failed to disable Fast Boot: $_"
    Exit 1
}