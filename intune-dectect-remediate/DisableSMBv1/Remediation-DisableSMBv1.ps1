<#
.SYNOPSIS
    Disables the SMBv1 protocol.

.DESCRIPTION
    This remediation script disables the SMBv1 Windows optional feature.
    It assumes a detection script has already verified that SMBv1 is currently enabled.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
    
    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell

    This script is intended for Windows 10 version 1709 (build 16299) and newer.
#>

try {
    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart -ErrorAction Stop
    Write-Output "SMBv1 protocol has been disabled."
    Exit 0
}
catch {
    Write-Output "Failed to disable SMBv1 protocol: $_"
    Exit 1
}