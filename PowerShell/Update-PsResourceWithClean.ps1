# Copied from https://github.com/JamesKehr/Update-PsResourceWithClean
# update a module, then cleanup old versions of a module installed from PSGallery

# disable progress bar
$startProg = $global:ProgressPreference
$global:ProgressPreference = 'SilentlyContinue'

# all modules from the PSGallery
$allMods = Get-InstalledPSResource | Where-Object Repository -eq 'PSGallery'

# group the modules by name and filter out modules with more than one entry
[array]$modGroups = $allMods | Group-Object -Property Name

# perform the cleanup
foreach ($m in $modGroups) {
    # get the mod name
    $modName = $m.Name

    # update the module
    Write-Host "Updating $modName."
    Update-PSResource -Name $modName -Force -Confirm:$false

    # get an update of all versions of the module
    $allVersions = Get-PSResource -Name $modName

    if ($allVersions.Count -gt 1) {
        Write-Host "Cleaning up old versions of $modName."

        # get the newest version of the module
        $newestVersion = $allVersions | Sort-Object -Property Version -Descending -Top 1 | ForEach-Object Version

        # older versions
        [array]$oldVersions = $allMods | Where-Object { $_.Name -eq $modName -and $_.Version -ne $newestVersion }

        # remove old versions
        $oldVersions | ForEach-Object { Uninstall-PSResource -Name $modName -Version $_.Version -Confirm:$false }

        # there should only be one version of the module left
        if ( (Get-InstalledPSResource $modName).Count -gt 1 ) {
            Write-Host -ForegroundColor Red "Failed to cleanup $modName."
        }
        else {
            Write-Host -ForegroundColor Green "$modName was successfully cleaned up."
            # Resource Path
            $resourcePath = "$($oldVersions.InstalledLocation)\$($oldVersions.Name)\$($oldVersions.Version)"
            # Check for Folder for Resource Path
            if (Test-Path $resourcePath) {
                #Write-Output 'The folder exists.'
                # Check for Empty Folder for Resource Path
                if (Get-ChildItem -Path $resourcePath -File) {
                    #Write-Output 'The folder contains files.'
                    Remove-Item -Path $resourcePath -Recurse -Force
                }
                else { 
                    #Write-Output 'The folder does not contain any files.'
                }
            }
            else {
                #Write-Output 'The folder does not exist.'
            }
        }
    }

    Remove-Variable modName, allVersions, newestVersion, oldVersions -EA SilentlyContinue
}

# reset progress
$global:ProgressPreference = $startProg