<#
.SYNOPSIS
    Displays a toast notification prompting the user to reboot.

.DESCRIPTION
    This remediation script shows a customized toast notification if the system has not rebooted recently.
    It assumes a detection script has already determined that the system is non-compliant (e.g., uptime exceeds threshold).
    This script must run in the context of the logged-on user to function correctly.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)
    Intended for use with Intune Proactive Remediations.
    Must run in **user context** to display toast notification.
#>

# Get uptime (used only to personalize the toast message)
$uptime = Get-ComputerInfo | Select-Object -ExpandProperty OSUptime

# App registration info for Toast support in Action Center
$appId = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\$appId"

# Ensure the app is registered to show notifications
if (-not (Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
Set-ItemProperty -Path $regPath -Name 'ShowInActionCenter' -Value 1 -Type DWord -Force

# Toast content settings
$scenario        = 'reminder'
$attributionText = "MSEndpointMgr"
$headerText      = "Computer Restart is Needed!"
$titleText       = "Your device has not rebooted in $($uptime.Days) days"
$bodyText1       = "For performance and stability, we recommend rebooting weekly."
$bodyText2       = "Please save your work and restart your device today. Thank you!"
$dismissContent  = "Dismiss"

# Create toast XML
[xml]$toastXml = @"
<toast scenario="$scenario">
  <visual>
    <binding template="ToastGeneric">
      <text placement="attribution">$attributionText</text>
      <text>$headerText</text>
      <group>
        <subgroup>
          <text hint-style="title" hint-wrap="true">$titleText</text>
        </subgroup>
      </group>
      <group>
        <subgroup>
          <text hint-style="body" hint-wrap="true">$bodyText1</text>
        </subgroup>
      </group>
      <group>
        <subgroup>
          <text hint-style="body" hint-wrap="true">$bodyText2</text>
        </subgroup>
      </group>
    </binding>
  </visual>
  <actions>
    <action activationType="system" arguments="dismiss" content="$dismissContent"/>
  </actions>
</toast>
"@

# Function to display the toast
function Show-ToastNotification {
    try {
        Add-Type -AssemblyName 'System.Runtime.WindowsRuntime'
        $xmlDoc = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xmlDoc.LoadXml($toastXml.OuterXml)

        $toast    = [Windows.UI.Notifications.ToastNotification]::new($xmlDoc)
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($appId)
        $notifier.Show($toast)
    }
    catch {
        Write-Warning "Failed to display toast notification. Ensure the script runs in the logged-on user context."
    }
}

# Display the toast
Show-ToastNotification
Exit 0
