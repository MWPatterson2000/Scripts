<#
    Allows the User to Cleanup Old Versions of PowerShell Module(s) on the Client
#>

# Copy Modules Folder
Write-Host "Copy All Versions of PowerShell Module(s) Installed"
robocopy 'C:\Program Files\WindowsPowerShell\Modules' 'D:\PowerShell\Modules'  /S /R:1 /W:1 /NP /XO /XC /MT:24 /ZB /XF

# Get All Versions of PowerShell Modules Installed
Write-Host "Getting All Versions of PowerShell Module(s) Installed"
$Script:ModulesAR = Get-InstalledModule

# Cleanup old versions of PowerShell Modules
Write-Host "Checking for Old Version(s) of Module(s)"
foreach ($module in $Script:ModulesAR) {
    #Write-Host $module.Name
    $ModuleName = $module.Name
    #$count = (Get-Module $ModuleName -ListAvailable).Count # Faster Option
    $count = (Get-InstalledModule $ModuleName -AllVersions).Count # Slower Option
    if ($ModuleName -ne "Pester") {
        if ($count -gt 1) {
            $count--
            Write-Host "`tCleaning Up $count Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow
            $Latest = Get-InstalledModule $ModuleName
            #Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module #-WhatIf
            #Get-InstalledModule $ModuleName -AllVersions | Where-Object {$_.Version -ne $Latest.Version} | Uninstall-Module -Force -ErrorAction Stop
            Get-InstalledModule $ModuleName -AllVersions | Where-Object {$_.Version -ne $Latest.Version} | Uninstall-Module -Force -ErrorAction Continue
        }
    }
    else {Write-Host "`tSkipping Cleaning Up Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow}
}

# End Cleanup
Write-Host "Finished Checking for Old Version(s) of Modules"
