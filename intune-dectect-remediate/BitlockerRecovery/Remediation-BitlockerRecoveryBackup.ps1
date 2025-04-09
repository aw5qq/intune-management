<#
.SYNOPSIS
    Attempts to back up the BitLocker recovery key to Azure AD.

.DESCRIPTION
    Dynamically detects the OS drive letter and attempts to back up the recovery
    password protector to Azure AD using BackupToAAD-BitLockerKeyProtector.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell

    This script only applies to EIDJ devices. It does not verify cloud backup status.
#>

$osDriveLetter = (Get-CimInstance -Class Win32_OperatingSystem).SystemDrive
$osVolume = Get-BitLockerVolume -MountPoint $osDriveLetter

try {
    if ($osVolume.VolumeStatus -ne "FullyEncrypted") {
        Write-Output "BitLocker is not fully enabled on $osDriveLetter. Skipping backup."
        exit 0
    }

    $recoveryProtector = $osVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }

    if (-not $recoveryProtector) {
        Write-Output "No recovery protector found. Skipping backup."
        exit 0
    }

    BackupToAAD-BitLockerKeyProtector -MountPoint $osDriveLetter -KeyProtectorId $recoveryProtector.KeyProtectorId
    Write-Output "Successfully initiated BitLocker recovery key backup to Azure AD."
    exit 0
} catch {
    Write-Error "Failed to back up BitLocker recovery key: $_"
    exit 1
}
