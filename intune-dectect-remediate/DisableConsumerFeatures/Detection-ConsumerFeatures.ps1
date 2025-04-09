<#
.SYNOPSIS
    Detects whether Windows Consumer Features are disabled via policy.

.DESCRIPTION
    Checks for the presence and value of the DisableConsumerFeatures registry key
    under CloudContent. A value of 1 is considered compliant.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$keyName = "DisableConsumerFeatures"

try {
    $value = Get-ItemProperty -Path $regPath -Name $keyName -ErrorAction Stop
    if ($value.$keyName -eq 1) {
        Write-Output "Consumer features are disabled (compliant)."
        exit 0
    } else {
        Write-Output "Consumer features are enabled or misconfigured (non-compliant)."
        exit 1
    }
} catch {
    Write-Output "Registry key or value not found. Assuming non-compliant."
    exit 1
}
