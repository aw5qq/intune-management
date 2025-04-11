<#
.SYNOPSIS
    Logs that Secure Boot is not enabled. Cannot be enabled via script.

.DESCRIPTION
    Secure Boot must be enabled manually in UEFI firmware.
    This script serves as a placeholder and audit flag only.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell

    Secure Boot cannot be enabled via PowerShell or Intune.
    This script flags non-compliant systems for review or manual remediation.
#>

Write-Output "Secure Boot is not enabled. This must be enabled manually in UEFI firmware."
exit 1
