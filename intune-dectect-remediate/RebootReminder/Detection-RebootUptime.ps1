<#
.SYNOPSIS
    Detects if a system has been up for too long without a reboot.

.DESCRIPTION
    This detection script checks if the OS uptime exceeds a defined threshold (default: 14 days).
    If the threshold is exceeded, the script returns exit code 1 (non-compliant).
    Otherwise, it returns exit code 0 (compliant).

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
    Intended for use with Intune Proactive Remediations
#>

# Define uptime threshold in days
$UptimeThreshold = 14

# Get the system uptime
$uptime = Get-ComputerInfo | Select-Object -ExpandProperty OSUptime

# Optional: Output for logging or troubleshooting
Write-Output "System uptime: $($uptime.Days) days"
Write-Output "Uptime threshold: $UptimeThreshold days"

# Evaluate against threshold
if ($uptime.Days -ge $UptimeThreshold) {
    Write-Output "Device exceeds uptime threshold. Flagged as non-compliant."
    Exit 1
} else {
    Write-Output "Device is within acceptable uptime. Marked as compliant."
    Exit 0
}
