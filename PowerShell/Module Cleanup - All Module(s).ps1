<#
    Allows the User to Cleanup Old Versions of PowerShell Module(s) on the Client
#>

# Get All Versions of PowerShell Modules Installed
Write-Host "Getting All Versions of PowerShell Modules Installed"
$Script:ModulesAR = Get-InstalledModule

# Cleanup old versions of PowerShell Modules
Write-Host "Checking for Old Versions of Modules"
foreach ($module in $Script:ModulesAR) {
    #Write-Host $module.Name
    $ModuleName = $module.Name
    $count = (Get-Module $ModuleName -ListAvailable).Count
    if ($count -gt 1) {
        $count--
        Write-Host "Cleaning Up $count Old Version(s) of Module: $ModuleName"
        $Latest = Get-InstalledModule $ModuleName
        #Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module #-WhatIf
        Get-InstalledModule $ModuleName -AllVersions | Where-Object {$_.Version -ne $Latest.Version} | Uninstall-Module -Force -ErrorAction Stop
    }
}

