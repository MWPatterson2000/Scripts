<#
Name: Module Maintenance.ps1

This script to List All Installd PowerShell Modules that have a different version Online or no matching Online version
Allows the User to Update & Cleanup Old Versions of PowerShell Module(s) on the Client

Michael Patterson
scripts@mwpatterson.com

Revision History
    2021-10-21 - Initial Release
    2023-09-22 - Added Additional Information to Report
    2023-10-10 - Added Local Module Published Date
    2023-11-19 - Converted to Advanced Script
    2023-12-02 - Added Progress Bar
    2023-12-06 - Combined other scripts into a Single Script

#>

[CmdletBinding()]
[Alias()]
[OutputType([int])]
Param(
    # Parameter help description
    #[Parameter(AttributeValues)]
    #[ParameterType]
    #$ParameterName
)

Begin {
    # Clear Screen
    #Clear-Host

    # Build Variables
    $moduleSource = 'C:\Program Files\WindowsPowerShell\Modules' # Dwfault Location for All Users
    $moduleDestination = 'D:\PowerShell\Modules' # Destination Location for Backup

    # Start Function(s)
    # Clear Varables
    function Get-UserVariable ($Name = '*') {
        [CmdletBinding()]
        #param ()
        # these variables may exist in certain environments (like ISE, or after use of foreach)
        $special = 'ps', 'psise', 'psunsupportedconsoleModules', 'foreach', 'profile'

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
    #Clear-Host

    <#
    # PowerShell 5.x required. The version of PowerShell included with Windows 10
    #Requires -Version 5.0
    #>

    <#
    # PowerShell Version Requirements - v7.2 (LTS) Min
    #Requires -Version 7.2
    #>

    # Build Array for Output
    $Script:UpdatedModules = [System.Collections.ArrayList]::new()
}

Process {
    # Build Header
    #Write-Host "PowerShell Module Maintenance Script - $(Get-Date)"
    Write-Host 'PowerShell Module Maintenance Script'
    Write-Host ''
    Write-Host 'This Script will Copy All Installed Modules to Backup Location:'
    Write-Host "`tModules from: $moduleSource" -ForegroundColor Yellow
    Write-Host "`tModules to: $moduleDestination" -ForegroundColor Yellow
    Write-Host 'This Script will Check for Updates of Installed Module(s)'
    Write-Host 'This Script will Remove Old Versions of Installed Module(s)'
    #Write-Host ''
    Write-Host "Start Time - $(Get-Date)"
    Write-Host ''


    # Get All Versions of PowerShell Modules Installed
    Write-Host 'Getting Count of PowerShell Module(s) Installed'
    $Script:ModulesAR = Get-InstalledModule | Select-Object * | Sort-Object Name


    # Build Variables
    $Script:counter1 = 0

    # Check to see if Modules Found
    if (-not $Script:ModulesAR) {
        Write-Host ("`tModules found: 0") -ForegroundColor Yellow
        # Clear Variables
        Write-Host "`nScript Cleanup"
        Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue
        # End
        #Exit
        return
    }
    else {
        $Script:ModulesCount = @($Script:ModulesAR).Count
        Write-Host ("`tModules Found: {0}" -f $Script:ModulesCount) -ForegroundColor Yellow
    }


    # Copy Modules Folder
    Write-Host 'Copy All Versions of PowerShell Module(s) Installed'
    robocopy $moduleSource $moduleDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS 


    # Find Updated Module(s)
    Write-Host 'Checking for Updated Versions of Modules'
    foreach ($module in $Script:ModulesAR) {
        # Build Progress Bar
        $Script:counter1++
        $Script:percentComplete1 = ($Script:counter1 / $Script:ModulesCount) * 100
        $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
        If ($Script:percentComplete1 -lt 1) {
            $Script:percentComplete1 = 1
        }
        Write-Progress -Id 1 -Activity 'Checking Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1
        
        $moduleUpdate = Find-Module -Name $module.Name -ErrorAction SilentlyContinue
        if ($module.Version -lt $moduleUpdate.Version) {
            $moduleT = New-Object System.Object
            $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
            $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
            $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
            $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
            $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdate.Version
            $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdate.PublishedDate
            [void]$Script:UpdatedModules.Add($moduleT)
        }
        elseif ($module.Version -gt $moduleUpdate.Version) {
            $moduleT = New-Object System.Object
            $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
            $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
            $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
            $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
            $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdate.Version
            $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdate.PublishedDate
            [void]$Script:UpdatedModules.Add($moduleT)
        }
        elseif (($module.Version -eq $moduleUpdate.Version)) {
            # No Ouput Needed
        }
        else {
            $moduleT = New-Object System.Object
            $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
            $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
            $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
            $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
            $moduleT | Add-Member -type noteproperty -Name 'Online' -Value 'N/A'
            $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value 'N/A'
            [void]$Script:UpdatedModules.Add($moduleT)
        }
    }

    Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed


    # Write Data
    $Script:UpdatedModules | Format-Table -AutoSize


    # Update Modules
    Write-Host 'Updating Newer Versions of PowerShell Module(s) Installed'
    #Update-Module
    foreach ($module in $Script:UpdatedModules) {
        if ($null -ne $module.Online) {
            Write-Host "`tUpdating Module: $($module.Name)" -ForegroundColor Yellow
            Update-Module -Name $module.Name
        }
    }


    # Build Variables
    $Script:counter1 = 0
    $Script:UpdatedModulesCount = @($Script:UpdatedModules).Count

    # Cleanup old versions of PowerShell Modules
    if ($Script:UpdatedModulesCount -gt 0) {
        Write-Host 'Checking for Old Version(s) of Module(s)'
        #foreach ($module in $Script:ModulesAR) {
        foreach ($module in $Script:UpdatedModules) {
            # Build Progress Bar
            $Script:counter1++
            $Script:percentComplete1 = ($Script:counter1 / $Script:UpdatedModulesCount) * 100
            $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
            If ($Script:percentComplete1 -lt 1) {
                $Script:percentComplete1 = 1
            }
            Write-Progress -Id 1 -Activity 'Checking Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:UpdatedModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1
            
            $ModuleName = $module.Name
            $count = @(Get-InstalledModule $ModuleName -AllVersions).Count # Slower Option
            if ($ModuleName -ne 'Pester') {
                if ($count -gt 1) {
                    $count--
                    Write-Host ('{0} Uninstalling {1} Previous Version of Module: {2}' -f $Counter1, $count, $ModuleName) -ForegroundColor Yellow
                    $Latest = Get-InstalledModule $ModuleName
                    Get-InstalledModule $ModuleName -AllVersions | Where-Object { $_.Version -ne $Latest.Version } | Uninstall-Module -Force -ErrorAction Continue
                }
            }
            else { Write-Host "`tSkipping Cleaning Up Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow }
        }
        # Close Progress Bar
        Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed
    }
}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    Write-Host "End Time - $(Get-Date)"
    Exit
}
