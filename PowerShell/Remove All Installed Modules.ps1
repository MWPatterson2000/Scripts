<#
.SYNOPSIS
    Removes all installed PowerShell modules from the current machine.

.NOTES
    Revision History
    2026-07-31 - Added a header and made the cleanup flow handle empty results and repeated removals more safely.
#>

$modules = @(Get-InstalledModule -ErrorAction SilentlyContinue)
if (-not $modules) {
    Write-Host 'No installed modules were found.'
    return
}

$modules | ForEach-Object {
    Uninstall-Module -Name $_.Name -AllVersions -Force -ErrorAction SilentlyContinue
}

$availableModules = @(Get-Module -ListAvailable -ErrorAction SilentlyContinue)
if ($availableModules) {
    $availableModules | ForEach-Object {
        Uninstall-Module -Name $_.Name -Force -ErrorAction SilentlyContinue
    }
}

