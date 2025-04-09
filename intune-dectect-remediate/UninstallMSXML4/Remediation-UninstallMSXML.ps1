<#
.SYNOPSIS
    Removes Microsoft XML Core Services (MSXML) 4.0 if installed.

.DESCRIPTION
    This script:
    - Uses WMI to silently uninstall products referencing MSXML 4.0.
    - Renames any leftover msxml4.dll file in %windir%\SysWOW64 to msxml4.dll.bak
      to prevent usage while preserving it in case of rollback.

    It assumes detection has confirmed the presence of MSXML 4.0.

.NOTES
    Author: Andrew Welch (aw5qq@virginia.edu)

    Run Context : SYSTEM (default)
    Architecture: 64-bit PowerShell
#>

$searchPatterns = @(
    "MSXML 4.0",
    "Microsoft XML Core Services 4.0"
)

try {
    $products = Get-WmiObject -Class Win32_Product | Where-Object {
        $productName = $_.Name
        $searchPatterns | ForEach-Object { $productName -like "*$_*" }
    }

    if ($products.Count -eq 0) {
        Write-Output "No MSXML 4.0 installations found."
    }
    else {
        foreach ($product in $products) {
            try {
                Write-Output "Attempting to uninstall: $(${product.Name})"
                $result = $product.Uninstall()
                if ($result.ReturnValue -eq 0) {
                    Write-Output "Successfully uninstalled: $(${product.Name})"
                } else {
                    Write-Output "Uninstall returned code $(${result.ReturnValue}) for $(${product.Name})"
                }
            }
            catch {
                Write-Output "Failed to uninstall $(${product.Name}): $_"
            }
        }
    }

    # Rename leftover msxml4.dll if it exists
    $msxmlDllPath = "$env:windir\SysWOW64\msxml4.dll"
    if (Test-Path -Path $msxmlDllPath) {
        try {
            $backupPath = "${msxmlDllPath}.bak"
            Rename-Item -Path $msxmlDllPath -NewName $backupPath -Force
            Write-Output "Renamed leftover file to: ${backupPath}"
        }
        catch {
            Write-Output "Failed to rename ${msxmlDllPath}: $_"
        }
    } else {
        Write-Output "No leftover msxml4.dll file found."
    }

    Exit 0
}
catch {
    Write-Output "An error occurred during MSXML 4.0 remediation: $_"
    Exit 1
}