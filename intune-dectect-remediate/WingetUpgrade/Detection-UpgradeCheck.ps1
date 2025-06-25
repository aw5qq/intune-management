<#
.SYNOPSIS
    Detects whether a specified application is outdated using winget.

.DESCRIPTION
    Checks if an update is available for a specific winget package ID.
    Exits 1 if an update is available (non-compliant), 0 if up to date.
    Designed for use under SYSTEM context (e.g., Intune).
#>

# ========== CONFIGURATION ==========
$packageId = "Google.Chrome"
$logPath = "C:\ProgramData\WingetDetect_$packageId.log"
Start-Transcript -Path $logPath -Append
# ===================================

# Check for winget in system path
$wingetPath = Get-Command "winget.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue

if (-not $wingetPath) {
    $wingetPath = "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*\winget.exe"
    $wingetPath = Get-ChildItem -Path $wingetPath -ErrorAction SilentlyContinue | Select-Object -First 1 | Select-Object -ExpandProperty FullName
}

if (-not (Test-Path $wingetPath)) {
    Write-Warning "winget.exe not found. Assuming compliant."
    Stop-Transcript
    exit 0
}

Write-Output "winget located at $wingetPath. Checking for updates to $packageId..."

try {
    $params = @("upgrade", "--id", $packageId, "--source", "winget")
    $result = & $wingetPath @params 2>&1
    $exitCode = $LASTEXITCODE

    Write-Output "winget exit code: $exitCode"
    Write-Output "winget output:`n$result"

    switch ($exitCode) {
        0 {
            Write-Output "Update available for $packageId."
            Stop-Transcript
            exit 1
        }
        -1978335189 {
            Write-Output "$packageId is up to date."
            Stop-Transcript
            exit 0
        }
        default {
            Write-Warning "Unknown status for $packageId. winget exit code: $exitCode"
            Stop-Transcript
            exit 0
        }
    }
} catch {
    Write-Error "Error occurred: $_"
    Stop-Transcript
    exit 0
}
