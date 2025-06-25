<#
.SYNOPSIS
    Updates a specified application using winget.

.DESCRIPTION
    Detects if the app is running, and upgrades it using winget under SYSTEM context.
    Skips update if running unless $forceUpdate is set to $true.
#>

# ========== CONFIGURATION ==========
$packageId = "Google.Chrome"
$appProcessName = "chrome"
$forceUpdate = $false
$logDir = "C:\ProgramData\WingetRemediation"
$logFile = "$logDir\Remediate_$packageId.log"
# ===================================

# Ensure logging directory exists
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory -Force | Out-Null
}
Start-Transcript -Path $logFile -Append

# Discover winget
$wingetPath = Get-Command "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
if (-not $wingetPath) {
    $wingetPath = "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*\winget.exe"
    $wingetPath = Get-ChildItem -Path $wingetPath -ErrorAction SilentlyContinue | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if (-not (Test-Path $wingetPath)) {
    Write-Warning "winget.exe not found. Remediation aborted for $packageId."
    Stop-Transcript
    exit 1
}

Write-Output "winget located at: $wingetPath"

# Check if app is running
$isAppRunning = Get-Process -Name $appProcessName -ErrorAction SilentlyContinue
if ($isAppRunning -and -not $forceUpdate) {
    Write-Warning "$appProcessName is running. Skipping update (forceUpdate = $forceUpdate)."
    Stop-Transcript
    exit 0
}

Write-Output "Proceeding with winget upgrade..."

try {
    $params = @(
        "upgrade",
        "--id", $packageId,
        "--source", "winget",
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )

    $wingetOutput = & $wingetPath @params 2>&1
    $exitCode = $LASTEXITCODE

    Write-Output "winget exited with code: $exitCode"
    Write-Output "winget output:`n$wingetOutput"

    switch ($exitCode) {
        0 {
            Write-Output "$packageId upgraded successfully."
            Stop-Transcript
            exit 0
        }
        -1978335189 {
            Write-Output "$packageId is already up to date."
            Stop-Transcript
            exit 0
        }
        default {
            Write-Error "Upgrade failed for $packageId. Exit code: $exitCode"
            Stop-Transcript
            exit 1
        }
    }
} catch {
    Write-Error "Unhandled error during upgrade: $_"
    Stop-Transcript
    exit 1
}
