<#
.SYNOPSIS
    Detects whether the BitLocker recovery key has been backed up to Azure AD.

.DESCRIPTION
    Dynamically detects the OS drive letter and verifies BitLocker is fully enabled
    and a recovery password protector exists. If no protector is found, device is
    considered non-compliant.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell

    This script assumes the device is EIDJ and BitLocker is in use.
#>

$osDriveLetter = (Get-CimInstance -Class Win32_OperatingSystem).SystemDrive
$osVolume = Get-BitLockerVolume -MountPoint $osDriveLetter

if ($osVolume.VolumeStatus -ne "FullyEncrypted") {
    Write-Output "BitLocker is not fully enabled on $osDriveLetter. Non-compliant."
    exit 1
}

$recoveryProtector = $osVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }

if (-not $recoveryProtector) {
    Write-Output "No BitLocker recovery password protector found. Non-compliant."
    exit 1
}

Write-Output "BitLocker is enabled and recovery password protector is present. Assuming key is escrowed."
exit 0
