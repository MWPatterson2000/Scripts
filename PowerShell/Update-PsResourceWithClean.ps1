<#
.SYNOPSIS
    Updates installed PowerShell resources from PSGallery and removes older versions.

.NOTES
    Revision History
    2026-07-31 - Added a header and streamlined the update/cleanup flow to avoid repeated resource lookups.
#>

$startProg = $global:ProgressPreference
$global:ProgressPreference = 'SilentlyContinue'

$allMods = @(Get-InstalledPSResource -ErrorAction SilentlyContinue | Where-Object Repository -eq 'PSGallery')
if (-not $allMods) {
    Write-Host 'No PSGallery resources were found.'
    $global:ProgressPreference = $startProg
    return
}

[array]$modGroups = @($allMods | Group-Object -Property Name)

foreach ($group in $modGroups) {
    $modName = $group.Name

    Write-Host "Updating $modName."
    Update-PSResource -Name $modName -Force -Confirm:$false -ErrorAction SilentlyContinue

    $allVersions = @(Get-InstalledPSResource -Name $modName -ErrorAction SilentlyContinue | Where-Object Repository -eq 'PSGallery')
    if ($allVersions.Count -gt 1) {
        Write-Host "Cleaning up old versions of $modName."

        $newestVersion = ($allVersions | Sort-Object -Property Version -Descending | Select-Object -First 1).Version
        [array]$oldVersions = @($allVersions | Where-Object { $_.Version -ne $newestVersion })

        foreach ($oldVersion in $oldVersions) {
            Uninstall-PSResource -Name $modName -Version $oldVersion.Version -Confirm:$false -ErrorAction SilentlyContinue
        }

        if (@(Get-InstalledPSResource -Name $modName -ErrorAction SilentlyContinue).Count -gt 1) {
            Write-Host -ForegroundColor Red "Failed to cleanup $modName."
        }
        else {
            Write-Host -ForegroundColor Green "$modName was successfully cleaned up."
            $resourcePath = "$($oldVersions[0].InstalledLocation)\$($oldVersions[0].Name)\$($oldVersions[0].Version)"
            if (Test-Path $resourcePath) {
                if (Get-ChildItem -Path $resourcePath -File -ErrorAction SilentlyContinue) {
                    Remove-Item -Path $resourcePath -Recurse -Force
                }
            }
        }
    }
}

$global:ProgressPreference = $startProg