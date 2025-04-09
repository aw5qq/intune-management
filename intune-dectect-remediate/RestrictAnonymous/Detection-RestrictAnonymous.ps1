<#
.SYNOPSIS
    Detects if RestrictAnonymous is enabled in the LSA registry key.

.DESCRIPTION
    Checks the value of HKLM\SYSTEM\CurrentControlSet\Control\LSA\RestrictAnonymous.
    If the value is missing or set to 0 (allow anonymous access), the device is marked non-compliant.
    If the value is set to 1 (restrict anonymous access), it is marked compliant.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
    
    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\LSA"
$regName = "RestrictAnonymous"

try {
    $value = Get-ItemPropertyValue -Path $regPath -Name $regName -ErrorAction Stop

    if ($value -eq 1) {
        Write-Output "RestrictAnonymous is set to 1. Compliant."
        Exit 0
    } else {
        Write-Output "RestrictAnonymous is set to $value. Non-compliant."
        Exit 1
    }
}
catch {
    Write-Output "Registry value $regName not found at $regPath. Non-compliant."
    Exit 1
}
