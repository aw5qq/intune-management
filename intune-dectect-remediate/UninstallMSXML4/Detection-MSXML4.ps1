<#
.SYNOPSIS
    Detects if Microsoft XML Core Services (MSXML) 4.0 is installed.

.DESCRIPTION
    Searches uninstall registry keys for any entries referencing MSXML 4.0.
    Also checks for the presence of msxml4.dll in %windir%\SysWOW64.
    If either is found, exits with code 1 (non-compliant). Otherwise, exits 0 (compliant).

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
#>

$paths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$msxml4Found = $false

# Check uninstall registry keys
foreach ($path in $paths) {
    try {
        $subkeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

        foreach ($subkey in $subkeys) {
            $displayName = (Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -match "MSXML 4\.0|Microsoft XML Core Services 4\.0") {
                Write-Output "Found MSXML 4.0 installation: $displayName"
                $msxml4Found = $true
                break
            }
        }
    }
    catch {
        Write-Output "Error reading registry path: $path. $_"
    }

    if ($msxml4Found) { break }
}

# Check for leftover DLL file
$msxmlDllPath = "$env:windir\SysWOW64\msxml4.dll"
if (Test-Path -Path $msxmlDllPath) {
    Write-Output "Found leftover file: $msxmlDllPath"
    $msxml4Found = $true
}

# Final evaluation
if ($msxml4Found) {
    Exit 1  # Non-compliant
} else {
    Write-Output "MSXML 4.0 is not installed and no leftover DLL found."
    Exit 0  # Compliant
}
<#
.SYNOPSIS
    Detects if Microsoft XML Core Services (MSXML) 4.0 is installed.

.DESCRIPTION
    Searches uninstall registry keys for any entries referencing MSXML 4.0.
    Also checks for the presence of msxml4.dll in %windir%\SysWOW64.
    If either is found, exits with code 1 (non-compliant). Otherwise, exits 0 (compliant).

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
#>

$paths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$msxml4Found = $false

# Check uninstall registry keys
foreach ($path in $paths) {
    try {
        $subkeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

        foreach ($subkey in $subkeys) {
            $displayName = (Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue).DisplayName
            if ($displayName -match "MSXML 4\.0|Microsoft XML Core Services 4\.0") {
                Write-Output "Found MSXML 4.0 installation: $displayName"
                $msxml4Found = $true
                break
            }
        }
    }
    catch {
        Write-Output "Error reading registry path: $path. $_"
    }

    if ($msxml4Found) { break }
}

# Check for leftover DLL file
$msxmlDllPath = "$env:windir\SysWOW64\msxml4.dll"
if (Test-Path -Path $msxmlDllPath) {
    Write-Output "Found leftover file: $msxmlDllPath"
    $msxml4Found = $true
}

# Final evaluation
if ($msxml4Found) {
    Exit 1  # Non-compliant
} else {
    Write-Output "MSXML 4.0 is not installed and no leftover DLL found."
    Exit 0  # Compliant
}