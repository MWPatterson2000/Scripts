<#
    Allows the User to Cleanup Old Versions of PowerShell Module(s) on the Client
#>

# Copy Modules Folder
Write-Host "Copy All Versions of PowerShell Module(s) Installed"
$moduleSource = 'C:\Program Files\WindowsPowerShell\Modules'
$moduleDestination = 'D:\PowerShell\Modules'
#robocopy 'C:\Program Files\WindowsPowerShell\Modules' 'D:\PowerShell\Modules'  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH #/NJS 
robocopy $moduleSource $moduleDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH #/NJS 

# Get All Versions of PowerShell Modules Installed
Write-Host "Getting All Versions of PowerShell Module(s) Installed"
$Script:ModulesAR = Get-InstalledModule | Sort-Object Name
if (-not $Script:ModulesAR) {
    Write-Host ("`tModules found: 0") -ForegroundColor Yellow
    return
}
else {
    $ModulesCount = $Script:ModulesAR.Count
    $DigitsLength = $ModulesCount.ToString().Length
    Write-Host ("`tModules Found: {0}" -f $ModulesCount) -ForegroundColor Yellow
}

# Cleanup old versions of PowerShell Modules
$i = 0
Write-Host "Checking for Old Version(s) of Module(s)"
foreach ($module in $Script:ModulesAR) {
    $i++
    $Counter = ("[{0,$DigitsLength}/{1,$DigitsLength}]" -f $i, $ModulesCount)
    $CounterLength = $Counter.Length
    #Write-Host $module.Name
    $ModuleName = $module.Name
    #$count = (Get-Module $ModuleName -ListAvailable).Count # Faster Option
    $count = (Get-InstalledModule $ModuleName -AllVersions).Count # Slower Option
    if ($ModuleName -ne "Pester") {
        if ($count -gt 1) {
            $count--
            Write-Host "`tCleaning Up $count Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow
            Write-Host ("{0} Uninstalling {1} Previous Version of Module: {2}" -f $Counter, $count, $ModuleName) -ForegroundColor Yellow
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
