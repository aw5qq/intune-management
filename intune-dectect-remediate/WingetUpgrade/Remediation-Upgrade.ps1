<#
.SYNOPSIS
    Updates a specified application using winget.

.DESCRIPTION
    This script checks if winget is installed, detects whether the target application is running,
    and uses the $forceUpdate flag to determine whether to proceed with the upgrade.
    It supports any winget-compatible package and can be reused across applications.
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
$packageId = "Google.Chrome"

# Name of the process to check if app is running (no .exe)
$appProcessName = "chrome"

# Set to $true to allow upgrade even if app is running
$forceUpdate = $false
# ===================================

# Validate winget is installed
$wingetCommand = Get-Command "winget.exe" -ErrorAction SilentlyContinue
$wingetPath = if ($wingetCommand) { $wingetCommand.Source } else { $null }

if (-not $wingetPath) {
    $wingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (-not (Test-Path $wingetPath)) {
        Write-Warning "winget not found. Cannot remediate ${packageId}."
        exit 1
    }
}

Write-Output "winget found at: $wingetPath. Target package: $packageId"

# Detect if app is running
$isAppRunning = $false
if (Get-Process $appProcessName -ErrorAction SilentlyContinue) {
    $isAppRunning = $true
    Write-Warning "$appProcessName is currently running."
}

# Decision logic
if ($isAppRunning -and -not $forceUpdate) {
    Write-Output "Remediation skipped: ${appProcessName} is running and forceUpdate is disabled."
    exit 0
}

Write-Output "Proceeding with winget upgrade (forceUpdate = $forceUpdate)..."

try {
    $params = @(
        "upgrade",
        "--id", $packageId,
        "--source", "winget",
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )

    # Run winget and capture all output
    $wingetOutput = & $wingetPath @params 2>&1
    $exitCode = $LASTEXITCODE

    Write-Output "winget exited with code: $exitCode"
    Write-Output "winget output:`n$wingetOutput"

    switch ($exitCode) {
        0 {
            Write-Output "$packageId upgraded successfully."
            exit 0
        }
        -1978335189 {
            Write-Output "No update available for ${packageId}. Already up to date."
            exit 0
        }
        default {
            Write-Warning "Upgrade for ${packageId} failed. winget exit code: $exitCode"
            exit 1
        }
    }
} catch {
    Write-Error "An error occurred while upgrading ${packageId}: $_"
    exit 1
}