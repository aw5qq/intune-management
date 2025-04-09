<#
.SYNOPSIS
    Checks whether WinTrust's EnableCertPaddingCheck is enabled.

.DESCRIPTION
    Verifies that the registry value 'EnableCertPaddingCheck' is set to 1 
    in both 64-bit and 32-bit registry paths. Reports non-compliance if the 
    value is missing, incorrect, or unreadable.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
    
    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

$expectedValue = 1
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Cryptography\Wintrust\Config",
    "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Cryptography\Wintrust\Config"
)

$compliant = $true

foreach ($path in $regPaths) {
    try {
        $currentValue = Get-ItemPropertyValue -Path $path -Name "EnableCertPaddingCheck" -ErrorAction Stop

        if ($currentValue -ne $expectedValue) {
            Write-Output "Non-compliant: '$path\EnableCertPaddingCheck' is set to $currentValue"
            $compliant = $false
        } else {
            Write-Output "Compliant: '$path\EnableCertPaddingCheck' is correctly set to $expectedValue"
        }
    }
    catch {
        Write-Output "Non-compliant: '$path\EnableCertPaddingCheck' is missing or inaccessible"
        $compliant = $false
    }
}

if ($compliant) {
    Exit 0
} else {
    Exit 1
}