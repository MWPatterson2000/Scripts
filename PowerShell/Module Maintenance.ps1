<#
.SYNOPSIS
    This script allows for easy PowerShell Module Maintenance for Installed Module(s).

.DESCRIPTION
    This Script will do the following:
        Get a List All Installed PowerShell Module(s)
        Check for Updates to Installed PowerShell Module(s)
        Copy the Installed PowerShell Module(s) to a Backup Location
        Copy the Installed PowerShell Script(s) to a Backup Location
        Update the Installed PowerShell Module(s)
        Remove Old Duplicate Version(s) of PowerShell Module(s)

.PARAMETER Time
    Used to Show the Time when the Process Starts and Stops
    $true / $false

.PARAMETER Backup
    Used to Copy the PowerShell Module(s) out to an Alternate Location
    $true / $false

.PARAMETER Update
    Used to Update the PowerShell Module(s)
    $true / $false

.PARAMETER Cleanup
    Used to Cleanup Duplicate Module(s) to Reduce Disk Space as well as get rid of Depreciated Commands
    $true / $false

    .PARAMETER moduleSource
    Source folder for copying the PowerShell Modules out from
    Default All Users: 'C:\Program Files\WindowsPowerShell\Modules'
    Default All Users: "$env:ProgramFiles\PowerShell\Modules"
    Default All Users: "$env:ProgramFiles\WindowsPowerShell\Modules"
    Current User: "$home\Documents\PowerShell\Modules"

.PARAMETER moduleDestination
    Destination folder for copying the PowerShell Module(s) out to

.PARAMETER scriptSource
    Default All Users: "$env:ProgramFiles\PowerShell\Scripts"
    Default All Users: "$env:ProgramFiles\WindowsPowerShell\Scripts"
    Current User: "$home\Documents\PowerShell\Scripts"

.PARAMETER scriptDestination
    Destination folder for copying the PowerShell Scripts(s) out to

.EXAMPLE
    & '.\Module Maintenance.ps1' -Time $false
    Do Not Display Start & End Time

.EXAMPLE
    & '.\Module Maintenance.ps1' -Backup $false
    Do Not Backup Modules & Scripts

.EXAMPLE
    & '.\Module Maintenance.ps1' -Update $false
    Do Not Update Installed Modules

.EXAMPLE
    & '.\Module Maintenance.ps1' -Cleanup $false
    Do Not Cleanup Duplicate Modules

.EXAMPLE
    & '.\Module Maintenance.ps1' -Time $false -Backup $false -Update $false -Cleanup $false
    Do Not do the following:
        Display Start & End Time
        Backup Modules & Scripts
        Update Installed Modules
        Cleanup Duplicate Modules

.LINK
    https://github.com/MWPatterson2000/Scripts/blob/main/PowerShell/Module%20Maintenance.ps1

.NOTES
    VERSION 2023.12.11
    GUID 965d056a-eb41-4fb8-a9e3-8811b910e656
    AUTHOR Michael Patterson
    CONTACT scripts@mwpatterson.com
    COMPANYNAME 
    COPYRIGHT 
    APPLICATION Module Maintenance.ps1
    FEATURE 
    TAGS PowerShell, Modules
    LICENSEURI 
    PROJECTURI 
    RELEASENOTES
        2021-09-21 - Initial Release
        2023-09-22 - Added Additional Information to Report
        2023-10-10 - Added Local Module Published Date
        2023-11-19 - Converted to Advanced Script
        2023-12-02 - Added Progress Bar
        2023-12-06 - Combined other scripts into a Single Script
        2023-12-11 - Added Parameters

    Change Log:
    Date            Version         By                  Notes
    ----------------------------------------------------------
    2023-09-21      2023.09.21      Mike Patterson      Initial release
    2023-09-22      2023.09.22      Mike Patterson      Added Additional Information to Report
    2023-10-10      2023.10.10      Mike Patterson      Added Local Module Published Date
    2023-11-19      2023.11.19      Mike Patterson      Converted to Advanced Script
    2023-12-02      2023.12.02      Mike Patterson      Added Progress Bar
    2023-12-06      2023.12.06      Mike Patterson      Combined other scripts into a Single Script
    2023-12-11      2023.12.11      Mike Patterson      Added Parameters
    2023-12-13      2023.12.13      Mike Patterson      Fixed Cleanup Variable Name
    


#>

[CmdletBinding()]
[Alias()]
[OutputType([int])]
Param(
    # Parameter help description
    #[Parameter(AttributeValues)]
    #[ParameterType]
    #$ParameterName
    <#
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0)]
    [ValidateNotNullOrEmpty()]
    #>

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateSet($true, $false)]
    [bool]$Time = $false,

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateSet($true, $false)]
    [bool]$Backup = $true,

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateSet($true, $false)]
    [bool]$Update = $true,

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [ValidateSet($true, $false)]
    [bool]$Cleanup = $true,

    #[string]$moduleSource = 'C:\Program Files\WindowsPowerShell\Modules', # Default Location for All Users
    [string]$moduleSource = "$env:ProgramFiles\WindowsPowerShell\Modules", # Default Location for All Users
    #[string]$moduleSource = "$env:ProgramFiles\PowerShell\Modules", # Default Location for All Users ?
    #[string]$moduleSource = "$env:ProgramFiles\PowerShell\7\Modules", # Default Location for All Users ?
    #[string]$moduleSource = "$home\Documents\PowerShell\Modules", # Default Locaion for Current User
    [string]$moduleDestination = 'D:\PowerShell\Modules', # Destination Location for Backup
    [string]$scriptSource = "$env:ProgramFiles\WindowsPowerShell\Scripts", # Default Location for All Users
    #[string]$scriptSource = "$env:ProgramFiles\PowerShell\Scripts", # Default Location for All Users ?
    [string]$scriptDestination = 'D:\PowerShell\Scripts' # Destination Location for Backup

)

Begin {
    # Clear Screen
    #Clear-Host

    # Build Variables
    #$moduleSource = 'C:\Program Files\WindowsPowerShell\Modules' # Default Location for All Users
    #$moduleDestination = 'D:\PowerShell\Modules' # Destination Location for Backup

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
    if ($Time -eq $true) {
        Write-Host "`tStart Time - $(Get-Date)" -ForegroundColor Yellow
    }
    #Write-Host ''
    Write-Host 'PowerShell Module Maintenance Script'
    Write-Host ''
    if ($Backup -eq $true) {
        Write-Host 'This Script will Copy All Installed Modules to Backup Location:'
        Write-Host "`tModule(s) from: $moduleSource" -ForegroundColor Yellow
        Write-Host "`tModule(s) to: $moduleDestination" -ForegroundColor Yellow
        Write-Host 'This Script will Copy All Installed Scripts to Backup Location:'
        Write-Host "`tScript(s) from: $scriptSource" -ForegroundColor Yellow
        Write-Host "`tScript(s) to: $scriptDestination" -ForegroundColor Yellow
    }
    Write-Host 'This Script will Check for Updates of Installed Module(s)'
    if ($Update -eq $true) {
        Write-Host 'This Script will Update the Installed Module(s)'
    }
    if ($Clean -eq $true) {
        Write-Host 'This Script will Remove Old Versions of Installed Module(s)'
    }
    Write-Host ''


    # Get All Versions of PowerShell Modules Installed
    Write-Host 'Getting List & Count of PowerShell Module(s) Installed'
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
    if ($Backup -eq $true) {
        Write-Host 'Copy All Versions of PowerShell Module(s) Installed'
        robocopy $moduleSource $moduleDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS 
        Write-Host 'Copy All Versions of PowerShell Script(s) Installed'
        robocopy $scriptSource $scriptDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS 

    }

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
    # Close Progress Bar
    Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed


    # Build Variables
    $Script:counter1 = 0
    $Script:UpdatedModulesCount = @($Script:UpdatedModules).Count

    # Display Updates Found
    Write-Host ("`tUpdates Found: {0}" -f $Script:UpdatedModulesCount) -ForegroundColor Yellow
    #Write-Host ''
    # Write Data
    $Script:UpdatedModules | Format-Table -AutoSize


    # Update Modules
    if ($Update -eq $true) {
        Write-Host 'Updating Newer Versions of PowerShell Module(s) Installed'
        #Update-Module
        foreach ($module in $Script:UpdatedModules) {
            # Build Progress Bar
            $Script:counter1++
            $Script:percentComplete1 = ($Script:counter1 / $Script:ModulesCount) * 100
            $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
            If ($Script:percentComplete1 -lt 1) {
                $Script:percentComplete1 = 1
            }
            #Write-Progress -Id 1 -Activity 'Updating Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1

            if ($null -ne $module.Online) {
                #Write-Host "`tUpdating Module: $($module.Name)" -ForegroundColor Yellow
                Write-Progress -Id 1 -Activity 'Updating Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1
                Update-Module -Name $module.Name
            }
        }
        # Close Progress Bar
        Write-Progress -Id 1 -Activity 'Updating Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed
    }


    # Cleanup old versions of PowerShell Modules
    if ($Cleanup -eq $true) {
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
                        #Write-Host ('{0} Uninstalling {1} Previous Version of Module: {2}' -f $Counter1, $count, $ModuleName) -ForegroundColor Yellow
                        Write-Host ("`tUninstalling {0} Previous Version of Module: {1}" -f $count, $ModuleName) -ForegroundColor Yellow
                        #Write-Host "`nUninstalling $count Previous Version of Module: $ModuleName" -ForegroundColor Yellow
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
}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    if ($Time -eq $true) {
        Write-Host ''
        Write-Host "`tEnd Time - $(Get-Date)" -ForegroundColor Yellow
    }
    # Memory Cleanup
    [System.GC]::Collect()
    Exit
}
