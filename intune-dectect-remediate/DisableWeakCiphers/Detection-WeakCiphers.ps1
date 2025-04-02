<#
.SYNOPSIS
    Detects the presence of known weak TLS cipher suites.

.DESCRIPTION
    This script checks for the presence of insecure or deprecated cipher suites 
    such as 3DES, RC4, and others. If any are found, the script exits with code 1 (non-compliant).
    If none are found, it exits with code 0 (compliant).

    Reference: https://nvd.nist.gov/vuln/detail/CVE-2016-2183

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
#>

# List of weak ciphers to check for (partial names)
$weakCiphers = @("3DES", "IDEA", "RC", "DES")

$detected = $false

foreach ($name in $weakCiphers) {
    try {
        $matches = Get-TlsCipherSuite | Where-Object { $_.Name -match $name }
        if ($matches) {
            Write-Output "Detected weak cipher(s) containing: $name"
            $detected = $true
            break
        }
    }
    catch {
        Write-Output "Failed to query TLS cipher suites. Ensure PowerShell 5.1 or later is installed. Error: $_"
        Exit 1
    }
}

if ($detected) {
    Write-Output "Weak cipher suites are enabled (non-compliant)."
    Exit 1
} else {
    Write-Output "No weak cipher suites detected (compliant)."
    Exit 0
}