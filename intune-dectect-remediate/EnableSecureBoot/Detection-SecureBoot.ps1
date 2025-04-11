<#
.SYNOPSIS
    Detects whether Secure Boot is enabled on a UEFI system.

.DESCRIPTION
    Uses Confirm-SecureBootUEFI to check Secure Boot state.
    If Secure Boot is not enabled or the device is not UEFI-based, it exits non-compliant.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

# Confirm-SecureBootUEFI throws if system is not UEFI
try {
    if (Confirm-SecureBootUEFI) {
        Write-Output "Secure Boot is enabled."
        exit 0
    } else {
        Write-Output "Secure Boot is supported but not enabled."
        exit 1
    }
} catch {
    Write-Output "System does not support UEFI Secure Boot or it is in Legacy BIOS mode."
    exit 1
}
