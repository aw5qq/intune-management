<#
.SYNOPSIS
    Enables the EnableCertPaddingCheck registry value for WinTrust.

.DESCRIPTION
    This remediation script enforces that 'EnableCertPaddingCheck' is set to 1 (REG_DWORD)
    in both 64-bit and 32-bit registry paths under WinTrust.

    While this script does check for the presence of registry paths and forcibly sets
    values, it does not evaluate compliance. It assumes a detection script has already 
    determined the device is non-compliant and simply enforces the expected configuration.

    The script is idempotent — running it multiple times will not cause issues and will
    ensure the correct setting is always applied.

    If $triggerReboot is set to $true and the remediation is successful, the script will
    initiate a reboot with a 60-second delay to allow logging and cleanup.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

.REQUIREMENTS
    Must be run with administrative privileges or in SYSTEM context (e.g., Intune).
#>

# ===== CONFIGURATION =====
$triggerReboot = $true
# =========================

$registryEntries = @(
    @{
        Path  = "HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust\Config"
        Name  = "EnableCertPaddingCheck"
        Value = 1
    },
    @{
        Path  = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Cryptography\Wintrust\Config"
        Name  = "EnableCertPaddingCheck"
        Value = 1
    }
)

$success = $true

foreach ($entry in $registryEntries) {
    try {
        # Ensure registry path exists
        if (-not (Test-Path -Path $entry.Path)) {
            New-Item -Path $entry.Path -Force | Out-Null
            Write-Output "Created registry path: $($entry.Path)"
        }

        # Enforce the expected value (REG_DWORD)
        New-ItemProperty -Path $entry.Path `
                         -Name $entry.Name `
                         -Value $entry.Value `
                         -PropertyType DWord `
                         -Force | Out-Null

        Write-Output "Set '$($entry.Name)' to $($entry.Value) in $($entry.Path)"
    }
    catch {
        Write-Output "Failed to configure $($entry.Path): $_"
        $success = $false
    }
}

if ($success) {
    Write-Output "Remediation completed successfully."

    if ($triggerReboot) {
        Write-Output "triggerReboot is enabled. Initiating system reboot in 60 seconds..."
        shutdown.exe /r /t 60 /c "Reboot triggered by remediation script"
    }

    Exit 0
} else {
    Write-Output "Remediation encountered errors."
    Exit 1
}