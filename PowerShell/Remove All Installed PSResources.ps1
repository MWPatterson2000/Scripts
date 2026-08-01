<#
.SYNOPSIS
    Removes all installed PowerShell resources from the current machine.

.NOTES
    Revision History
    2026-07-31 - Added a header and made the removal flow handle empty results more safely.
#>

$resources = @(Get-InstalledPSResource -ErrorAction SilentlyContinue)
if (-not $resources) {
    Write-Host 'No installed PowerShell resources were found.'
    return
}

$resources | ForEach-Object {
    Uninstall-PSResource -Name $_.Name -Force -ErrorAction SilentlyContinue
}

