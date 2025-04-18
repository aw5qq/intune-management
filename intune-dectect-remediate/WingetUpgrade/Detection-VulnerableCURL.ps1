<#
.SYNOPSIS
    Detects vulnerable curl.exe versions affected by CVE-2025-0665.

.DESCRIPTION
    Checks if curl.exe in System32 or SysWOW64 is version 8.11.1.0 or within the vulnerable range 
    [8.11.1.0, 8.12.0.0]. This script does not check for loaded DLLs or recommend reboot — that logic
    is reserved for the remediation script.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
    Run Context: SYSTEM
    Architecture: 64-bit PowerShell
#>

# Define vulnerability range
$vulnerableVersion = [Version]"8.11.1.0"
$safeVersion       = [Version]"8.12.0.0"

# Paths to check for curl.exe
$curlPaths = @(
    "$env:windir\System32\curl.exe",
    "$env:windir\SysWOW64\curl.exe"
)

$vulnerableFound = $false

foreach ($path in $curlPaths) {
    if (Test-Path $path) {
        try {
            $rawVersion = (Get-Item $path).VersionInfo.ProductVersion
            $norm = ($rawVersion.Split('.').Count -lt 4) ? "$rawVersion.0" : $rawVersion
            $ver = [Version]$norm

            if ($ver -ge $vulnerableVersion -and $ver -lt $safeVersion) {
                Write-Output "VULNERABLE: $path ($ver)"
                $vulnerableFound = $true
            } else {
                Write-Output "OK: $path ($ver)"
            }
        } catch {
            Write-Output "ERROR: $path ($_)"
        }
    }
}

if ($vulnerableFound) {
    Exit 1
} else {
    Exit 0
}