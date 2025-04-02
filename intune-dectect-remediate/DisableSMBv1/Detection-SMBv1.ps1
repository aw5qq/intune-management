<#
.SYNOPSIS
    Detects whether the SMBv1 protocol is enabled.

.DESCRIPTION
    This script checks if the SMBv1 Windows optional feature is present and enabled.
    If SMBv1 is enabled, the script exits with code 1 (non-compliant).
    If SMBv1 is not present or disabled, the script exits with code 0 (compliant).

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
#>

try {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction Stop

    if ($feature.State -eq 'Enabled') {
        Write-Output "SMBv1 is enabled (non-compliant)."
        Exit 1
    } else {
        Write-Output "SMBv1 is disabled (compliant)."
        Exit 0
    }
}
catch {
    Write-Output "SMBv1 feature not found or error occurred. Assuming compliant. Error: $_"
    Exit 0
}