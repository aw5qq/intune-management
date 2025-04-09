<#
.SYNOPSIS
    Ensures the Windows Update service (wuauserv) is enabled and running.

.DESCRIPTION
    Sets the wuauserv service to Manual start if it is disabled and attempts to
    start the service if it is not running.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

try {
    $service = Get-Service -Name 'wuauserv' -ErrorAction Stop

    if ($service.StartType -eq 'Disabled') {
        Set-Service -Name 'wuauserv' -StartupType Manual
        Write-Output "Changed wuauserv start type to Manual."
    }

    if ($service.Status -ne 'Running') {
        Start-Service -Name 'wuauserv' -ErrorAction Stop
        Write-Output "Started wuauserv service."
    }

    Write-Output "Windows Update service is enabled and running."
    exit 0
} catch {
    Write-Error "Failed to configure Windows Update service: $_"
    exit 1
}