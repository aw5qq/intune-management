<#
.SYNOPSIS
    Detects whether Fast Boot (Hiberboot) is enabled.

.DESCRIPTION
    This script checks the registry setting for Fast Boot (HiberbootEnabled). 
    If Fast Boot is enabled (value = 1), it exits with code 1 (non-compliant).
    If disabled (value = 0), it exits with code 0 (compliant).

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
#>

# Registry path and value
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
$regName = "HiberbootEnabled"
$expectedValue = 0  # 0 = Fast Boot disabled, 1 = enabled

try {
    if (Test-Path -Path $regPath) {
        $actualValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction Stop | Select-Object -ExpandProperty $regName

        if ($actualValue -eq $expectedValue) {
            Write-Output "Fast Boot is disabled (compliant)."
            Exit 0
        } else {
            Write-Output "Fast Boot is enabled (non-compliant)."
            Exit 1
        }
    } else {
        Write-Output "Registry path not found: $regPath"
        Exit 1
    }
}
catch {
    Write-Output "Error checking Fast Boot status: $_"
    Exit 1
}