<#
.SYNOPSIS
    Disables weak TLS cipher suites.

.DESCRIPTION
    This remediation script searches for and disables known weak TLS cipher suites
    such as 3DES, RC4, IDEA, and DES using Disable-TlsCipherSuite.

    It dynamically queries installed cipher suites to avoid hardcoding exact names,
    which may differ across OS versions. Only detected weak ciphers are targeted.

    Reference: https://nvd.nist.gov/vuln/detail/CVE-2016-2183

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

.REQUIREMENTS
    PowerShell 5.1+
    Windows 10 20H1+ or Windows Server 2022+
    Script must run as Administrator (System context in Intune is sufficient)
#>

# List of known weak cipher patterns (partial name matches)
$weakPatterns = @("3DES", "IDEA", "RC", "DES")
$disabledList = @()

try {
    foreach ($pattern in $weakPatterns) {
        # We check against the currently installed cipher suites using a pattern match.
        # This avoids hardcoding and prevents errors when trying to disable non-existent ciphers.
        $matches = Get-TlsCipherSuite | Where-Object { $_.Name -match $pattern }

        foreach ($cipher in $matches) {
            try {
                Disable-TlsCipherSuite -Name $cipher.Name -ErrorAction Stop
                $disabledList += $cipher.Name
            }
            catch {
                Write-Output "Failed to disable cipher: $($cipher.Name). Error: $_"
            }
        }
    }

    if ($disabledList.Count -gt 0) {
        Write-Output "Disabled the following weak cipher suites:"
        $disabledList | ForEach-Object { Write-Output "- $_" }
    } else {
        Write-Output "No weak cipher suites found to disable."
    }

    Exit 0
}
catch {
    Write-Output "An error occurred while processing cipher suites: $_"
    Exit 1
}