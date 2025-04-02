<#
.SYNOPSIS
    Disables weak TLS cipher suites.

.DESCRIPTION
    This remediation script disables known weak cipher suites such as 3DES, RC4, IDEA, and DES.
    It dynamically checks for installed cipher suites that match those patterns and disables them
    using the Disable-TlsCipherSuite cmdlet.

    This avoids hardcoding cipher names and ensures compatibility across OS versions.

    Reference: https://nvd.nist.gov/vuln/detail/CVE-2016-2183

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

.REQUIREMENTS
    PowerShell 5.1+
    Windows 10 20H1 or later / Windows Server 2022+
    Must run as Administrator (System context in Intune is sufficient)
#>

$weakPatterns = @("3DES", "IDEA", "RC", "DES")
$disabledCiphers = @()

try {
    foreach ($pattern in $weakPatterns) {
        # Get all installed cipher suites matching this weak pattern
        $ciphersToDisable = Get-TlsCipherSuite | Where-Object { $_.Name -match $pattern }

        foreach ($cipher in $ciphersToDisable) {
            try {
                Disable-TlsCipherSuite -Name $cipher.Name -ErrorAction Stop
                $disabledCiphers += $cipher.Name
            }
            catch {
                Write-Output "Failed to disable cipher: $($cipher.Name). Error: $_"
            }
        }
    }

    if ($disabledCiphers.Count -gt 0) {
        Write-Output "Disabled the following weak cipher suites:"
        $disabledCiphers | ForEach-Object { Write-Output "- $_" }
    } else {
        Write-Output "No weak cipher suites found to disable."
    }

    Exit 0
}
catch {
    Write-Output "An error occurred while processing cipher suites: $_"
    Exit 1
}