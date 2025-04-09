<#
.SYNOPSIS
    Detects the presence of weak TLS cipher suites.

.DESCRIPTION
    This detection script searches for known weak TLS cipher suites (e.g., 3DES, RC, IDEA, DES).
    If any weak ciphers are found, the script exits with code 1 (non-compliant).
    Otherwise, it exits with code 0 (compliant).

    Reference: https://nvd.nist.gov/vuln/detail/CVE-2016-2183

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

$weakPatterns = @("3DES", "IDEA", "RC", "DES")
$detected = $false

foreach ($pattern in $weakPatterns) {
    try {
        $weakCiphersFound = Get-TlsCipherSuite | Where-Object { $_.Name -match $pattern }

        if ($weakCiphersFound) {
            foreach ($cipher in $weakCiphersFound) {
                Write-Output "Detected weak cipher: $($cipher.Name)"
            }
            $detected = $true
            break
        }
    }
    catch {
        Write-Output "Error checking cipher suites: $_"
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