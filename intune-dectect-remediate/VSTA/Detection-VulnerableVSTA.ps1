<#
.SYNOPSIS
    Detects vulnerable versions of VSTA 2019 and 2022 by checking DLL file versions.

.DESCRIPTION
    Checks specific DLLs associated with VSTA 2019 and 2022. If either DLL is present
    and below the secure version threshold, the device is considered non-compliant.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    CVE: CVE-2025-29803
    Run Context: Logged-in user
    Architecture: 64-bit PowerShell
#>

# ========== CONFIGURATION ==========
$vsta2022Dll = "Microsoft.VisualStudio.Tools.Applications.dll"
$vsta2022MinVersion = [version]"17.0.35906.1"

$vsta2019Dll = "VstaComObjectAggregator.dll"
$vsta2019MinVersion = [version]"16.0.35907.1"

$searchPaths = @(
    "$env:ProgramFiles\Microsoft Visual Studio",
    "$env:ProgramFiles(x86)\Microsoft Visual Studio"
)
# ====================================

function Test-DllVersion {
    param (
        [string]$dllName,
        [version]$minVersion
    )

    foreach ($path in $searchPaths) {
        $dlls = Get-ChildItem -Path $path -Recurse -Filter $dllName -ErrorAction SilentlyContinue
        foreach ($dll in $dlls) {
            $fileVersion = (Get-Item $dll.FullName).VersionInfo.FileVersion
            try {
                $parsedVersion = [version]$fileVersion
                Write-Output "[INFO] Found $dllName at $($dll.FullName) with version $parsedVersion"

                if ($parsedVersion -lt $minVersion) {
                    Write-Output "[WARNING] $dllName is vulnerable (version $parsedVersion < $minVersion)"
                    return $true
                }
            } catch {
                Write-Output "[ERROR] Failed to parse version for $dllName at $($dll.FullName)"
            }
        }
    }

    return $false
}

# Run checks
$vsta2022Vulnerable = Test-DllVersion -dllName $vsta2022Dll -minVersion $vsta2022MinVersion
$vsta2019Vulnerable = Test-DllVersion -dllName $vsta2019Dll -minVersion $vsta2019MinVersion

if ($vsta2022Vulnerable -or $vsta2019Vulnerable) {
    Write-Output "[WARNING] Vulnerable VSTA DLL(s) detected. Device is non-compliant."
    exit 1
} else {
    Write-Output "[INFO] No vulnerable VSTA components detected. Device is compliant."
    exit 0
}