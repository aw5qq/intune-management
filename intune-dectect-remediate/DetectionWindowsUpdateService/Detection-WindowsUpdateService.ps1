<#
.SYNOPSIS
    Detects whether the Windows Update service (wuauserv) is properly configured.

.DESCRIPTION
    Checks if the wuauserv service is present, not disabled, and either set to
    Manual or Automatic. If the service is missing or disabled, the system is
    considered non-compliant.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

$service = Get-Service -Name 'wuauserv' -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Output "Windows Update service (wuauserv) not found. Non-compliant."
    exit 1
}

if ($service.StartType -eq 'Disabled') {
    Write-Output "Windows Update service is disabled. Non-compliant."
    exit 1
}

Write-Output "Windows Update service is present and not disabled. Compliant."
exit 0
