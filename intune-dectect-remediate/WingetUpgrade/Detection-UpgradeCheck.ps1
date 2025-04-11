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
    
    Run Context : Logged-in user
    Architecture: 64-bit PowerShell
#>

# ========== CONFIGURATION ==========
# Winget package ID as recognized by `winget upgrade`
$packageId = "Google.Chrome"  # Example: "Google.Chrome"
# You can change this to any other package ID you want to check.
# ===================================

# Check if winget is installed
$wingetPath = (Get-Command "winget.exe" -ErrorAction SilentlyContinue)?.Source
if (-not $wingetPath) {
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (-not (Test-Path $wingetPath)) {
        Write-Warning "winget not found. Skipping detection for $packageId."
        exit 0
    }
}

Write-Output "winget found at: $wingetPath. Checking for updates to $packageId..."

try {
    $params = @(
        "upgrade",
        "--id", $packageId,
        "--source", "winget"
    )

    $result = & $wingetPath @params 2>&1
    $exitCode = $LASTEXITCODE

    Write-Output "winget exit code: $exitCode"
    Write-Output "winget output:`n$result"

    switch ($exitCode) {
        0 {
            Write-Output "Update available for $packageId."
            exit 1
        }
        -1978335189 {
            Write-Output "$packageId is up to date."
            exit 0
        }
        default {
            Write-Output "$packageId not found or no update info available. Assuming compliant."
            exit 0
        }
    }
} catch {
    Write-Error "An error occurred while checking for updates to ${packageId}: $_"
    exit 0
}
