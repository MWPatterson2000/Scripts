<#
    Allows the User to Update & Cleanup Old Versions of PowerShell Module(s) on the Client
#>

# Update Modules
Write-Host "Updating All Versions of PowerShell Module(s) Installed"
Update-Module

# Get All Versions of PowerShell Modules Installed
Write-Host "Getting All Versions of PowerShell Module(s) Installed"
$Script:ModulesAR = Get-InstalledModule

# Cleanup old versions of PowerShell Modules
Write-Host "Checking for Old Version(s) of Modules"
foreach ($module in $Script:ModulesAR) {
    #Write-Host $module.Name
    $ModuleName = $module.Name
    #$count = (Get-Module $ModuleName -ListAvailable).Count
    $count = (Get-InstalledModule $ModuleName -AllVersions).Count
    if ($ModuleName -ne "Pester") {
        if ($count -gt 1) {
            $count--
            Write-Host "`tCleaning Up $count Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow
            $Latest = Get-InstalledModule $ModuleName
            #Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module #-WhatIf
            Get-InstalledModule $ModuleName -AllVersions | Where-Object {$_.Version -ne $Latest.Version} | Uninstall-Module -Force -ErrorAction Stop
        }
    }
    else {Write-Host "`tSkipping Cleaning Up  Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow}
}

# End
Write-Host "Finished Checking for Old Version(s) of Modules"
