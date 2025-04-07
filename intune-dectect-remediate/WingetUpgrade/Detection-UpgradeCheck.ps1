<#
.SYNOPSIS
    Detects whether a specified application is outdated using winget.

.DESCRIPTION
    This script checks if winget is installed and determines if an update is available
    for the specified package ID. If an update is available, it exits with code 1 (non-compliant).
    If no update is available, it exits with code 0 (compliant).
    Uses '2>&1' when capturing winget output to ensure both stdout and stderr are captured.
    This is necessary because winget sometimes writes status messages like
    "No available upgrade found" to stderr rather than stdout.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
#>

# ========== CONFIGURATION ==========
# Winget package ID as recognized by `winget upgrade`
$packageId = "Google.Chrome"  # Example: "Google.Chrome"
# You can change this to any other package ID you want to check.
# ===================================

# Check if winget is installed
if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    Write-Warning "winget not found. Skipping detection for $packageId."
    exit 0
}

Write-Output "winget found. Checking for updates to $packageId..."

try {
    $result = winget upgrade --id $packageId --source winget 2>&1
    #Write-Output "winget output:`n$result"

    if ($result -match "No available upgrade found") {
        Write-Output "$packageId is up to date."
        exit 0
    }

    $escapedId = [regex]::Escape($packageId)
    if ($result -match $escapedId) {
        Write-Output "Update available for $packageId."
        exit 1
    } else {
        Write-Output "$packageId not found in winget output. Assuming it is up to date or not installed."
        exit 0
    }
} catch {
    Write-Error "An error occurred while checking for updates to ${packageId}: ${_}"
    exit 0
}
