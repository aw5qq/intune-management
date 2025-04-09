<#
.SYNOPSIS
    Disables Windows Consumer Features (e.g., suggested apps, bloatware) via policy.

.DESCRIPTION
    Sets the DisableConsumerFeatures registry value under
    HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent to prevent Windows
    from installing consumer-focused apps and suggestions for new user profiles.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell

    This script prevents future installation of consumer apps (e.g., Candy Crush, TikTok).
    It does not remove any consumer apps that are already installed on the system.
#>

$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$keyName = "DisableConsumerFeatures"

try {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
        Write-Output "Created registry path: $regPath"
    }

    New-ItemProperty -Path $regPath -Name $keyName -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Output "Set $keyName to 1 at $regPath"
    exit 0
} catch {
    Write-Error "Failed to set consumer features policy: $_"
    exit 1
}