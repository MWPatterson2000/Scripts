<#
Name: Check Installed Module Versions.ps1

This script to List All Installd PowerShell Modules that have a different version Online or no matching Online version

Michael Patterson
scripts@mwpatterson.com

Revision History
    2021-10-21 - Initial Release
    2023-09-22 - Added Additional Information to Report

#>

# Start Function(s)
# Clear Varables
function Get-UserVariable ($Name = '*') {
    # these variables may exist in certain environments (like ISE, or after use of foreach)
    $special = 'ps', 'psise', 'psunsupportedconsoleapplications', 'foreach', 'profile'

    $ps = [PowerShell]::Create()
    $null = $ps.AddScript('$null=$host;Get-Variable') 
    $reserved = $ps.Invoke() | 
    Select-Object -ExpandProperty Name
    $ps.Runspace.Close()
    $ps.Dispose()
    Get-Variable -Scope Global | 
    Where-Object Name -like $Name |
    Where-Object { $reserved -notcontains $_.Name } |
    Where-Object { $special -notcontains $_.Name } |
    Where-Object Name 
}

# End Function(s)

# Clear Screen
Clear-Host

<#
# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0
#>

<#
# PowerShell Version Requirements - v7.2 (LTS) Min
#Requires -Version 7.2
#>

# Build Array for Output
$Script:modulesUpdated = [System.Collections.ArrayList]::new()

# Get All Versions of PowerShell Modules Installed
Write-Host "Getting All Versions of PowerShell Module(s) Installed"
$Script:ModulesAR = Get-InstalledModule | Select-Object * | Sort-Object Name
if (-not $Script:ModulesAR) {
    Write-Host ("`tModules found: 0") -ForegroundColor Yellow
    return
}
else {
    $ModulesCount = $Script:ModulesAR.Count
    Write-Host ("`tModules Found: {0}" -f $ModulesCount) -ForegroundColor Yellow
}

# Find Updated Module(s)
Write-Host "Checking for Updated Versions of Modules"
#$i = 0
$count = @($Script:ModulesAR).Count
$count = $count - 1
foreach ($module in $Script:ModulesAR) {
    $moduleUpdate = Find-Module -Name $module.Name -ErrorAction SilentlyContinue
    if ($module.Version -lt $moduleUpdate.Version) {
        $moduleT = New-Object System.Object
        $moduleT | Add-Member -type noteproperty -Name "Name" -value $module.Name
        $moduleT | Add-Member -type noteproperty -Name "Repository" -Value $module.Repository
        $moduleT | Add-Member -type noteproperty -Name "Local" -Value $module.Version
        $moduleT | Add-Member -type noteproperty -Name "Online" -Value $moduleUpdate.Version
        $moduleT | Add-Member -type noteproperty -Name "Installed" -Value $module.InstalledDate
        $moduleT | Add-Member -type noteproperty -Name "Published" -Value $moduleUpdate.PublishedDate
        [void]$Script:modulesUpdated.Add($moduleT)
    }
    elseif ($module.Version -gt $moduleUpdate.Version) {
        $moduleT = New-Object System.Object
        $moduleT | Add-Member -type noteproperty -Name "Name" -value $module.Name
        $moduleT | Add-Member -type noteproperty -Name "Repository" -Value $module.Repository
        $moduleT | Add-Member -type noteproperty -Name "Local" -Value $module.Version
        $moduleT | Add-Member -type noteproperty -Name "Online" -Value $moduleUpdate.Version
        $moduleT | Add-Member -type noteproperty -Name "Installed" -Value $module.InstalledDate
        $moduleT | Add-Member -type noteproperty -Name "Published" -Value $moduleUpdate.PublishedDate
        [void]$Script:modulesUpdated.Add($moduleT)
    }
    elseif (($module.Version -eq $moduleUpdate.Version)) {
        # No Ouput Needed
    }
    else {
        $moduleT = New-Object System.Object
        $moduleT | Add-Member -type noteproperty -Name "Name" -value $module.Name
        $moduleT | Add-Member -type noteproperty -Name "Repository" -Value $module.Repository
        $moduleT | Add-Member -type noteproperty -Name "Local" -Value $module.Version
        $moduleT | Add-Member -type noteproperty -Name "Online" -Value "N/A"
        $moduleT | Add-Member -type noteproperty -Name "Installed" -Value $module.InstalledDate
        $moduleT | Add-Member -type noteproperty -Name "Published" -Value $module.PublishedDate
        [void]$Script:modulesUpdated.Add($moduleT)
    }
}

# Write Data
$Script:modulesUpdated | Format-Table -AutoSize

# Clear Variables
Write-Host "`nScript Cleanup"
Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

# End

