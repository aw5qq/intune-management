<#
.SYNOPSIS
    Enforces the RestrictAnonymous registry value.

.DESCRIPTION
    This remediation script sets the registry value:
    HKLM\SYSTEM\CurrentControlSet\Control\LSA\RestrictAnonymous to 1 (DWORD),
    which prevents anonymous access to certain system resources.

    It assumes detection has already confirmed non-compliance.

.NOTES
    QID: 90044
    Author: Andrew Welch (aw5qq@virginia.edu)
    Must run in SYSTEM context (Intune default)
#>

$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\LSA"
$regName = "RestrictAnonymous"
$desiredValue = 1

try {
    # Ensure registry key exists
    if (-not (Test-Path -Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Enforce expected value
    New-ItemProperty -Path $regPath `
                     -Name $regName `
                     -Value $desiredValue `
                     -PropertyType DWord `
                     -Force | Out-Null

    Write-Output "RestrictAnonymous has been set to $desiredValue."
    Exit 0
}
catch {
    Write-Output "Failed to set RestrictAnonymous: $_"
    Exit 1
}