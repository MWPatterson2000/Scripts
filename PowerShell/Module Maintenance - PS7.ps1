<#
.SYNOPSIS
    This script allows for easy PowerShell Module Maintenance for Installed Module(s).

.DESCRIPTION
    This Script will do the following:
        Get a List All Installed PowerShell Module(s)
        Check for Updates to Installed PowerShell Module(s)
        Copy the Installed PowerShell Module(s) to a Backup Location
        Copy the Installed PowerShell 7 Module(s) to a Backup Location
        Copy the Installed PowerShell Script(s) to a Backup Location
        Update the Installed PowerShell Module(s)
        Remove Old Duplicate Version(s) of PowerShell Module(s)
        Remove Old Duplicate Version(s) of PowerShell Script(s)

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
    Change Log:
    Date            Version         By                  Notes
    ----------------------------------------------------------
    2023-09-21      1.23.0921       Mike Patterson      Initial release
    2023-09-22      1.23.0922       Mike Patterson      Added Additional Information to Report
    2023-10-10      1.23.1010       Mike Patterson      Added Local Module Published Date
    2023-11-19      1.23.1119       Mike Patterson      Converted to Advanced Script
    2023-12-02      1.23.1202       Mike Patterson      Added Progress Bar
    2023-12-06      1.23.1206       Mike Patterson      Combined other scripts into a Single Script
    2023-12-11      1.23.1211       Mike Patterson      Added Parameters
    2023-12-13      1.23.1213       Mike Patterson      Fixed Cleanup Variable Name
    2024-01-03      1.24.0103       Mike Patterson      Script Cleanup & Version Changes
    2024-03-14      1.24.0314       Mike Patterson      Added Reporting for Local Only and Local Newer, renamed variables
    2024-03-15      1.24.0315       Mike Patterson      Changes to Single Table Output of changes
    2024-04-05      1.24.0405       Mike Patterson      Copied Module processing to Script processing
    2024-04-06      1.24.0406       Mike Patterson      Copy PowerShell 7 Modules out, Notes Added, Cleanup
    2024-04-16      1.24.0416       Mike Patterson      Reorganized to Show all changes together, Output
    2024-10-17      1.24.1017       Mike Patterson      Added Checks for Preview Updates & Update Logic
    
    VERSION 1.24.1017
    GUID 965d056a-eb41-4fb8-a9e3-8811b910e656
    AUTHOR Michael Patterson
    CONTACT scripts@mwpatterson.com
    COMPANYNAME 
    COPYRIGHT 
    APPLICATION Module Maintenance.ps1
    FEATURE 
    TAGS PowerShell, Modules, Update
    LICENSEURI 
    PROJECTURI 
    RELEASENOTES
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
    #[ValidateSet($true, $false)]
    [bool]$Time = $false,

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    #[ValidateSet($true, $false)]
    [bool]$Backup = $true,

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    #[ValidateSet($true, $false)]
    [bool]$Update = $true,

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    #[ValidateSet($true, $false)]
    [bool]$Cleanup = $true,

    [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
    #[ValidateSet($true, $false)]
    [bool]$PreviewUpdate = $false,

    #[string]$moduleSource = 'C:\Program Files\WindowsPowerShell\Modules', # Default Location for All Users
    [string]$moduleSource = "$env:ProgramFiles\WindowsPowerShell\Modules", # Default Location for All Users
    #[string]$moduleSource = "$env:ProgramFiles\PowerShell\Modules", # Default Location for All Users ?
    #[string]$moduleSource = "$home\Documents\PowerShell\Modules", # Default Locaion for Current User
    [string]$moduleDestination = 'D:\PowerShell\Modules', # Destination Location for Backup
    [string]$moduleSource7 = "$env:ProgramFiles\PowerShell\7\Modules", # Default Location for All Users ?
    [string]$moduleDestination7 = 'D:\PowerShell\Modules7', # Destination Location for Backup
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

    #<#
    # PowerShell Version Requirements - v7.2 (LTS) Min
    #Requires -Version 7.2
    #>

    # Build Array for Output
    # PSResources
    $Script:PSResourcesList = [System.Collections.ArrayList]::new()
    $Script:PSResourcesUpdated = [System.Collections.ArrayList]::new()
    $Script:PSResourcesLocalNewer = [System.Collections.ArrayList]::new()
    $Script:PSResourcesLocalOnly = [System.Collections.ArrayList]::new()
    $Script:PSResourcesNoChanges = [System.Collections.ArrayList]::new()
    #>
}

Process {
    # Build Header
    #Write-Host "PowerShell Module Maintenance Script - $(Get-Date)"
    if ($Time -eq $true) {
        Write-Host "`tStart Time - $(Get-Date)" -ForegroundColor Yellow
    }
    Write-Host 'PowerShell Module Maintenance Script'
    Write-Host ''
    Write-Host 'This Script will Check for Updates of Installed Resource(s)'
    if ($Update -eq $true) {
        Write-Host 'This Script will Update the Installed Resource(s)'
    }
    if ($Clean -eq $true) {
        Write-Host 'This Script will Remove Old Versions of Installed Resource(s)'
    }

    # Get All Versions of PowerShell Module(s) & Script(s) Installed
    Write-Host 'Getting List & Count of PowerShell Installed: Resource(s)'

    # Get All Versions of PowerShell Resources Installed
    Write-Host 'Getting List & Count of PowerShell Resource(s) Installed'
    $Script:PSResourcesAR = Get-InstalledPSResource | Select-Object * | Sort-Object Name

    # Build Variables
    $Script:counter3 = 0 # PSResources

    # Check to see if Modules & Scripts Found
    if (-not $Script:PSResourcesAR) {
        Write-Host ("`tResource(s)) found: 0") -ForegroundColor Yellow

        # Clear Variables
        Write-Host "`nScript Cleanup"
        Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

        # Memory Cleanup
        [System.GC]::Collect()

        # End
        #Exit
        return
    }
    else {
        $Script:ResourcesCount = @($Script:PSResourcesAR).Count
        Write-Host ("`tResource(s) Found: {0}" -f $Script:ModulesCount) -ForegroundColor Yellow
    }

    # Check for Changes
    Write-Host 'Checking for Changes'
    # Find Updated Modules
    if ($Script:ModulesCount -gt 0) {
        # Find Updated Module(s)
        #Write-Host 'or Module Changes'
        Write-Host "`tResource(s)" -ForegroundColor Yellow
        foreach ($module in $Script:ModulesAR) {
            # Build Progress Bar
            $Script:counter1++
            $Script:percentComplete1 = ($Script:counter1 / $Script:ModulesCount) * 100
            $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
            If ($Script:percentComplete1 -lt 1) {
                $Script:percentComplete1 = 1
            }
            # Write Progress Bar
            Write-Progress -Id 1 -Activity 'Checking Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1

            # Check Release Modules
            $moduleUpdate = Find-Module -Name $module.Name -ErrorAction SilentlyContinue
            if ($null -eq $moduleUpdate) {
                $moduleT = New-Object System.Object
                $moduleT | Add-Member -type noteproperty -Name 'State' -value 'Local Only'
                $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
                $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
                $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
                $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
                $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
                $moduleT | Add-Member -type noteproperty -Name 'Online' -Value 'N/A'
                $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value 'N/A'
                [void]$Script:ModulesLocalOnly.Add($moduleT)
                [void]$Script:ModulesList.Add($moduleT)
            }
            if ($null -ne $moduleUpdate) {
                if ($module.Version -lt $moduleUpdate.Version) {
                    $moduleT = New-Object System.Object
                    $moduleT | Add-Member -type noteproperty -Name 'State' -value 'Updated'
                    $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
                    $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
                    $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
                    $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
                    $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
                    $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdate.Version
                    $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdate.PublishedDate
                    [void]$Script:ModulesUpdated.Add($moduleT)
                    [void]$Script:ModulesList.Add($moduleT)
                }
                elseif ($module.Version -gt $moduleUpdate.Version) {
                    $moduleT = New-Object System.Object
                    $moduleT | Add-Member -type noteproperty -Name 'State' -value 'Local Newer'
                    $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
                    $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
                    $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
                    $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
                    $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
                    $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdate.Version
                    $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdate.PublishedDate
                    [void]$Script:ModulesLocalNewer.Add($moduleT)
                    [void]$Script:ModulesList.Add($moduleT)
                }
                elseif (($module.Version -eq $moduleUpdate.Version)) {
                    $moduleT = New-Object System.Object
                    $moduleT | Add-Member -type noteproperty -Name 'State' -value 'Same'
                    $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
                    $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
                    $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
                    $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
                    $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
                    $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdate.Version
                    $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdate.PublishedDate
                    [void]$Script:ModulesNoChanges.Add($moduleT)
                    #[void]$Script:ModulesList.Add($moduleT)
                }
                else {
                    # No Ouput Needed
                }
            }

            # Check Pre-Release Modules
            if ($module.Version -like '*preview*') {
                $moduleUpdatePreRelease = Find-Module -Name $module.Name -AllowPrerelease -ErrorAction SilentlyContinue
                #Write-Host 'Preview Module'
                if ($null -ne $moduleUpdatePreRelease) {
                    if ($module.Version -lt $moduleUpdatePreRelease.Version) {
                        $moduleT = New-Object System.Object
                        $moduleT | Add-Member -type noteproperty -Name 'State' -value 'Updated'
                        $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
                        $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
                        $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
                        $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
                        $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
                        $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdatePreRelease.Version
                        $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdatePreRelease.PublishedDate
                        [void]$Script:ModulesUpdatedPreview.Add($moduleT)
                        [void]$Script:ModulesList.Add($moduleT)
                    }
                    elseif ($module.Version -gt $moduleUpdatePreRelease.Version) {
                        $moduleT = New-Object System.Object
                        $moduleT | Add-Member -type noteproperty -Name 'State' -value 'Local Newer'
                        $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
                        $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
                        $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
                        $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
                        $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
                        $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdatePreRelease.Version
                        $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdatePreRelease.PublishedDate
                        [void]$Script:ModulesLocalNewer.Add($moduleT)
                        [void]$Script:ModulesList.Add($moduleT)
                    }
                    elseif (($module.Version -eq $moduleUpdatePreRelease.Version)) {
                        $moduleT = New-Object System.Object
                        $moduleT | Add-Member -type noteproperty -Name 'State' -value 'Same'
                        $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
                        $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
                        $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
                        $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
                        $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
                        $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdatePreRelease.Version
                        $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdatePreRelease.PublishedDate
                        [void]$Script:ModulesNoChanges.Add($moduleT)
                        #[void]$Script:ModulesList.Add($moduleT)
                    }
                    else {
                        # No Ouput Needed
                    }
                }
            }
        }
        # Close Progress Bar
        Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed

        # Build Variables - Modules
        $Script:counter1 = 0
        $Script:ModulesNoChangesCount = @($Script:ModulesNoChanges).Count
        $Script:ModulesLocalOnlyCount = @($Script:ModulesLocalOnly).Count
        $Script:ModulesLocalNewerCount = @($Script:ModulesLocalNewer).Count
        $Script:ModulesUpdatedCount = @($Script:ModulesUpdated).Count
        $Script:ModulesUpdatedPreviewCount = @($Script:ModulesUpdatedPreview).Count

        # Display No Changes
        #Write-Host ("`tNo Changes: {0}" -f $Script:ModulesNoChangesCount) -ForegroundColor Yellow
        #$Script:ModulesNoChanges | Format-Table -AutoSize

        # Display Local Only
        #Write-Host ("`tLocal Only: {0}" -f $Script:ModulesLocalOnlyCount) -ForegroundColor Yellow
        #$Script:ModulesLocalOnly | Format-Table -AutoSize

        # Display Local Modules Newer
        #Write-Host ("`tLocal Newer: {0}" -f $Script:ModulesLocalNewerCount) -ForegroundColor Yellow
        #$Script:ModulesLocalNewer | Format-Table -AutoSize

        # Display Updates Found
        #Write-Host ("`tUpdates Found: {0}" -f $Script:ModulesUpdatedCount) -ForegroundColor Yellow
        #$Script:ModulesUpdated | Format-Table -AutoSize 

        # Write Table
        #$Script:ModulesList | Sort-Object State, Name | Format-Table -AutoSize 
    }

    # Find Updated Scripts
    if ($Script:ScriptsCount -gt 0) {
        # Find Updated Script(s)
        #Write-Host 'Checking for Script Changes'
        Write-Host "`tScript(s)" -ForegroundColor Yellow
        foreach ($script in $Script:ScriptsAR) {
            # Build Progress Bar
            $Script:counter2++
            $Script:percentComplete1 = ($Script:counter2 / $Script:ScriptsCount) * 100
            $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
            If ($Script:percentComplete1 -lt 1) {
                $Script:percentComplete1 = 1
            }
            # Write Progress Bar
            Write-Progress -Id 1 -Activity 'Checking Module' -Status "$Script:percentComplete1d% - $Script:counter2 of $Script:ScriptsCount - Module: $($script.Name)" -PercentComplete $Script:percentComplete1

            $scriptUpdate = Find-Script -Name $script.Name -ErrorAction SilentlyContinue
            if ($null -eq $scriptUpdate) {
                $scriptT = New-Object System.Object
                $scriptT | Add-Member -type noteproperty -Name 'State' -value 'Local Only'
                $scriptT | Add-Member -type noteproperty -Name 'Name' -value $script.Name
                $scriptT | Add-Member -type noteproperty -Name 'Repository' -Value $script.Repository
                $scriptT | Add-Member -type noteproperty -Name 'Installed' -Value $script.InstalledDate
                $scriptT | Add-Member -type noteproperty -Name 'Local' -Value $script.Version
                $scriptT | Add-Member -type noteproperty -Name 'Local Published' -Value $script.PublishedDate
                $scriptT | Add-Member -type noteproperty -Name 'Online' -Value 'N/A'
                $scriptT | Add-Member -type noteproperty -Name 'Online Published' -Value 'N/A'
                [void]$Script:ScriptsLocalOnly.Add($scriptT)
                [void]$Script:ScriptsList.Add($scriptT)
            }
            if ($null -ne $scriptUpdate) {
                if ($script.Version -lt $scriptUpdate.Version) {
                    $scriptT = New-Object System.Object
                    $scriptT | Add-Member -type noteproperty -Name 'State' -value 'Updated'
                    $scriptT | Add-Member -type noteproperty -Name 'Name' -value $script.Name
                    $scriptT | Add-Member -type noteproperty -Name 'Repository' -Value $script.Repository
                    $scriptT | Add-Member -type noteproperty -Name 'Installed' -Value $script.InstalledDate
                    $scriptT | Add-Member -type noteproperty -Name 'Local' -Value $script.Version
                    $scriptT | Add-Member -type noteproperty -Name 'Local Published' -Value $script.PublishedDate
                    $scriptT | Add-Member -type noteproperty -Name 'Online' -Value $scriptUpdate.Version
                    $scriptT | Add-Member -type noteproperty -Name 'Online Published' -Value $scriptUpdate.PublishedDate
                    [void]$Script:ScriptsUpdated.Add($scriptT)
                    [void]$Script:ScriptsList.Add($scriptT)
                }
                elseif ($script.Version -gt $scriptUpdate.Version) {
                    $scriptT = New-Object System.Object
                    $scriptT | Add-Member -type noteproperty -Name 'State' -value 'Local Newer'
                    $scriptT | Add-Member -type noteproperty -Name 'Name' -value $script.Name
                    $scriptT | Add-Member -type noteproperty -Name 'Repository' -Value $script.Repository
                    $scriptT | Add-Member -type noteproperty -Name 'Installed' -Value $script.InstalledDate
                    $scriptT | Add-Member -type noteproperty -Name 'Local' -Value $script.Version
                    $scriptT | Add-Member -type noteproperty -Name 'Local Published' -Value $script.PublishedDate
                    $scriptT | Add-Member -type noteproperty -Name 'Online' -Value $scriptUpdate.Version
                    $scriptT | Add-Member -type noteproperty -Name 'Online Published' -Value $scriptUpdate.PublishedDate
                    [void]$Script:ScriptsLocalNewer.Add($scriptT)
                    [void]$Script:ScriptsList.Add($scriptT)
                }
                elseif (($script.Version -eq $scriptUpdate.Version)) {
                    $scriptT = New-Object System.Object
                    $scriptT | Add-Member -type noteproperty -Name 'State' -value 'Same'
                    $scriptT | Add-Member -type noteproperty -Name 'Name' -value $script.Name
                    $scriptT | Add-Member -type noteproperty -Name 'Repository' -Value $script.Repository
                    $scriptT | Add-Member -type noteproperty -Name 'Installed' -Value $script.InstalledDate
                    $scriptT | Add-Member -type noteproperty -Name 'Local' -Value $script.Version
                    $scriptT | Add-Member -type noteproperty -Name 'Local Published' -Value $script.PublishedDate
                    $scriptT | Add-Member -type noteproperty -Name 'Online' -Value $scriptUpdate.Version
                    $scriptT | Add-Member -type noteproperty -Name 'Online Published' -Value $scriptUpdate.PublishedDate
                    [void]$Script:ScriptsNoChanges.Add($scriptT)
                    #[void]$Script:ScriptsList.Add($scriptT)
                }
                else {
                    # No Ouput Needed
                }
            }
        }
        # Close Progress Bar
        Write-Progress -Id 1 -Activity 'Checking Script' -Status "Script # $Script:counter2 of $Script:ScriptsCount" -Completed

        # Build Variables - Scripts
        $Script:counter2 = 0
        $Script:ScriptsNoChangesCount = @($Script:ScriptsNoChanges).Count
        $Script:ScriptsLocalOnlyCount = @($Script:ScriptsLocalOnly).Count
        $Script:ScriptsLocalNewerCount = @($Script:ScriptsLocalNewer).Count
        $Script:ScriptsUpdatedCount = @($Script:ScriptsUpdated).Count
        $Script:ScriptsUpdatedPreviewCount = @($Script:ScriptsUpdatedPreview).Count

        # Display No Changes
        #Write-Host ("`tNo Changes: {0}" -f $Script:ScriptsNoChangesCount) -ForegroundColor Yellow
        #$Script:ScriptsNoChanges | Format-Table -AutoSize

        # Display Local Only
        #Write-Host ("`tLocal Only: {0}" -f $Script:ScriptsLocalOnlyCount) -ForegroundColor Yellow
        #$Script:ScriptsLocalOnly | Format-Table -AutoSize

        # Display Local Scripts Newer
        #Write-Host ("`tLocal Newer: {0}" -f $Script:ScriptsLocalNewerCount) -ForegroundColor Yellow
        #$Script:ScriptsLocalNewer | Format-Table -AutoSize

        # Display Updates Found
        #Write-Host ("`tUpdates Found: {0}" -f $Script:ScriptsUpdatedCount) -ForegroundColor Yellow
        #$Script:ScriptsUpdated | Format-Table -AutoSize 

        # Write Table
        #$Script:ScriptsList | Sort-Object State, Name | Format-Table -AutoSize
    }

    # Write Output
    Write-Host 'Change Information'
    # Display No Changes
    Write-Host ("`tNo Changes `t`tModules: {0} `tScripts: {1}" -f $Script:ModulesNoChangesCount, $Script:ScriptsNoChangesCount) -ForegroundColor Yellow
    #$Script:ModulesNoChanges | Format-Table -AutoSize

    # Display Local Newer
    Write-Host ("`tLocal Newer `t`tModules: {0} `tScripts: {1}" -f $Script:ModulesLocalNewerCount, $Script:ScriptsLocalNewerCount) -ForegroundColor Yellow
    #$Script:ModulesLocalNewer | Format-Table -AutoSize

    # Display Local Only
    Write-Host ("`tLocal Only `t`tModules: {0} `tScripts: {1}" -f $Script:ModulesLocalOnlyCount, $Script:ScriptsLocalOnlyCount) -ForegroundColor Yellow
    #$Script:ModulesLocalOnly | Format-Table -AutoSize

    # Display Updates Found
    Write-Host ("`tUpdates `t`tModules: {0} `tScripts: {1}" -f $Script:ModulesUpdatedCount, $Script:ScriptsUpdatedCount) -ForegroundColor Yellow
    #$Script:ModulesUpdated | Format-Table -AutoSize 

    # Display Preview Updates Found
    Write-Host ("`tUpdates - Preview `tModules: {0} `tScripts: {1}" -f $Script:ModulesUpdatedPreviewCount, $Script:ScriptsUpdatedPreviewCount) -ForegroundColor Yellow
    #$Script:ModulesUpdated | Format-Table -AutoSize 
    
    # Write Tables Out
    # Write Table - Modules
    if ($Script:ModulesCount -gt 0) {
        $Script:ModulesList | Sort-Object State, Name | Format-Table -AutoSize
    }
    
    # Write Table - Scripts
    if ($Script:ScriptsCount -gt 0) {
        $Script:ScriptsList | Sort-Object State, Name | Format-Table -AutoSize
    }

    # Update Modules
    if ($Script:ModulesCount -gt 0) {

        # Update Modules - Normal
        # Build Variables
        $Script:counter1 = 0
        if ($Script:ModulesUpdatedCount -gt 0) {
            if ($Update -eq $true) {
                Write-Host 'Updating Newer Versions of PowerShell Module(s) Installed'
                foreach ($module in $Script:ModulesUpdated) {
                    # Build Progress Bar
                    $Script:counter1++
                    $Script:percentComplete1 = ($Script:counter1 / $Script:ModulesUpdatedCount) * 100
                    $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
                    If ($Script:percentComplete1 -lt 1) {
                        $Script:percentComplete1 = 1
                    }
                    # Write Progress Bar
                    #Write-Progress -Id 1 -Activity 'Updating Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1

                    if ($null -ne $module.Online) {
                        #Write-Host "`tUpdating Module: $($module.Name)" -ForegroundColor Yellow
                        # Write Progress Bar
                        Write-Progress -Id 1 -Activity 'Updating Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesUpdatedCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1
                        Write-Host ("`tUpdating Module: {0}" -f $module.Name) -ForegroundColor Yellow
                        Update-Module -Name $module.Name
                    }
                }
                # Close Progress Bar
                Write-Progress -Id 1 -Activity 'Updating Module' -Status "Module # $Script:counter1 of $Script:ModulesUpdatedCount" -Completed
            }
        }

        # Cleanup old versions of PowerShell Modules
        # Build Variables
        $Script:counter1 = 0
        if ($Cleanup -eq $true) {
            if ($Script:ModulesUpdatedCount -gt 0) {
                Write-Host 'Checking for Old Version(s) of Module(s)'
                foreach ($module in $Script:ModulesUpdated) {
                    # Build Progress Bar
                    $Script:counter1++
                    $Script:percentComplete1 = ($Script:counter1 / $Script:ModulesUpdatedCount) * 100
                    $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
                    If ($Script:percentComplete1 -lt 1) {
                        $Script:percentComplete1 = 1
                    }
                    # Write Progress Bar
                    Write-Progress -Id 1 -Activity 'Cleanup Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesUpdatedCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1

                    $ModuleName = $module.Name
                    $count = @(Get-InstalledModule $ModuleName -AllVersions).Count # Slower Option
                    if ($ModuleName -ne 'Pester') {
                        if ($count -gt 1) {
                            $count--
                            #Write-Host ('{0} Uninstalling {1} Previous Version of Module: {2}' -f $Counter1, $count, $ModuleName) -ForegroundColor Yellow
                            Write-Host ("`tUninstalling {0} Previous Version(s) of Module: {1}" -f $count, $ModuleName) -ForegroundColor Yellow
                            #Write-Host "`nUninstalling $count Previous Version of Module: $ModuleName" -ForegroundColor Yellow
                            $Latest = Get-InstalledModule $ModuleName
                            Get-InstalledModule $ModuleName -AllVersions | Where-Object { $_.Version -ne $Latest.Version } | Uninstall-Module -Force -ErrorAction Continue
                        }
                    }
                    else { Write-Host "`tSkipping Cleaning Up Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow }
                }
                # Close Progress Bar
                Write-Progress -Id 1 -Activity 'Cleanup Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed
            }
        }

        # Update Modules - Preview
        # Build Variables
        $Script:counter1 = 0
        if ($Script:ModulesUpdatedPreviewCount -gt 0) {
            if ($Update -eq $true) {
                Write-Host 'Updating Newer Versions of PowerShell Module(s) Installed - Preview'
                foreach ($module in $Script:ModulesUpdatedPreview) {
                    # Build Progress Bar
                    $Script:counter1++
                    $Script:percentComplete1 = ($Script:counter1 / $Script:ModulesUpdatedPreviewCount) * 100
                    $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
                    If ($Script:percentComplete1 -lt 1) {
                        $Script:percentComplete1 = 1
                    }
                    # Write Progress Bar
                    #Write-Progress -Id 1 -Activity 'Updating Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1

                    if ($null -ne $module.Online -and $module.Local -like '*preview*' -and $module.Online -like '*preview*') {
                        #Write-Host "`tUpdating Module: $($module.Name)" -ForegroundColor Yellow
                        # Write Progress Bar
                        Write-Progress -Id 1 -Activity 'Updating Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesUpdatedPreviewCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1
                        Write-Host ("`tUpdating Module: {0}" -f $module.Name) -ForegroundColor Yellow
                        #Update-Module -Name $module.Name
                        Install-Module -Name $module.Name -AllowPrerelease -Force
                    }
                }
                # Close Progress Bar
                Write-Progress -Id 1 -Activity 'Updating Module' -Status "Module # $Script:counter1 of $Script:ModulesUpdatedPreviewCount" -Completed
            }
        }

        # Cleanup old versions of PowerShell Modules
        # Build Variables
        $Script:counter1 = 0
        if ($Cleanup -eq $true) {
            if ($Script:ModulesUpdatedPreviewCount -gt 0) {
                Write-Host 'Checking for Old Version(s) of Module(s) - Preview'
                foreach ($module in $Script:ModulesUpdatedPreview) {
                    # Build Progress Bar
                    $Script:counter1++
                    $Script:percentComplete1 = ($Script:counter1 / $Script:ModulesUpdatedPreviewCount) * 100
                    $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
                    If ($Script:percentComplete1 -lt 1) {
                        $Script:percentComplete1 = 1
                    }
                    # Write Progress Bar
                    Write-Progress -Id 1 -Activity 'Cleanup Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesUpdatedPreviewCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1

                    $ModuleName = $module.Name
                    $count = @(Get-InstalledModule $ModuleName -AllVersions).Count # Slower Option
                    if ($ModuleName -ne 'Pester') {
                        if ($count -gt 1) {
                            $count--
                            #Write-Host ('{0} Uninstalling {1} Previous Version of Module: {2}' -f $Counter1, $count, $ModuleName) -ForegroundColor Yellow
                            Write-Host ("`tUninstalling {0} Previous Version(s) of Module: {1}" -f $count, $ModuleName) -ForegroundColor Yellow
                            #Write-Host "`nUninstalling $count Previous Version of Module: $ModuleName" -ForegroundColor Yellow
                            $Latest = Get-InstalledModule $ModuleName
                            Get-InstalledModule $ModuleName -AllVersions | Where-Object { $_.Version -ne $Latest.Version } | Uninstall-Module -Force -ErrorAction Continue
                        }
                    }
                    else { Write-Host "`tSkipping Cleaning Up Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow }
                }
                # Close Progress Bar
                Write-Progress -Id 1 -Activity 'Cleanup Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed
            }
        }
    }

    #$Script:ScriptsUpdatedPreview

    # Update Scripts
    if ($Script:ScriptsCount -gt 0) {
        # Build Variables
        $Script:counter2 = 0
        if ($Script:ScriptsUpdatedCount -gt 0) {
            if ($Update -eq $true) {
                Write-Host 'Updating Newer Versions of PowerShell Script(s) Installed'
                foreach ($script in $Script:ScriptsUpdated) {
                    # Build Progress Bar
                    $Script:counter2++
                    $Script:percentComplete1 = ($Script:counter2 / $Script:ScriptsUpdatedCount) * 100
                    $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
                    If ($Script:percentComplete1 -lt 1) {
                        $Script:percentComplete1 = 1
                    }
                    # Write Progress Bar
                    #Write-Progress -Id 1 -Activity 'Updating Script' -Status "$Script:percentComplete1d% - $Script:counter2 of $Script:ScriptsCount - Script: $($script.Name)" -PercentComplete $Script:percentComplete1

                    if ($null -ne $script.Online) {
                        #Write-Host "`tUpdating Script: $($script.Name)" -ForegroundColor Yellow
                        # Write Progress Bar
                        Write-Progress -Id 1 -Activity 'Updating Script' -Status "$Script:percentComplete1d% - $Script:counter2 of $Script:ScriptsUpdatedCount - Script: $($script.Name)" -PercentComplete $Script:percentComplete1
                        Write-Host ("`tUpdating Script: {0}" -f $script.Name) -ForegroundColor Yellow
                        Update-Script -Name $script.Name
                    }
                }
                # Close Progress Bar
                Write-Progress -Id 1 -Activity 'Updating Script' -Status "Script # $Script:counter2 of $Script:ScriptsUpdatedCount" -Completed
            }
        }

        # Cleanup old versions of PowerShell Scripts
        # Build Variables
        $Script:counter2 = 0
        if ($Cleanup -eq $true) {
            if ($Script:ScriptsUpdatedCount -gt 0) {
                <#
                Write-Host 'Checking for Old Version(s) of Script(s)'
                foreach ($script in $Script:ScriptsUpdated) {
                    # Build Progress Bar
                    $Script:counter2++
                    $Script:percentComplete1 = ($Script:counter2 / $Script:ScriptsUpdatedCount) * 100
                    $Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
                    If ($Script:percentComplete1 -lt 1) {
                        $Script:percentComplete1 = 1
                    }
                    # Write Progress Bar
                    Write-Progress -Id 1 -Activity 'Cleanup Script' -Status "$Script:percentComplete1d% - $Script:counter2 of $Script:ScriptsUpdatedCount - Script: $($script.Name)" -PercentComplete $Script:percentComplete1

                    $scriptName = $script.Name
                    $count = @(Get-InstalledScript $scriptName -AllVersions).Count # Slower Option
                    if ($scriptName -ne 'Pester') {
                        if ($count -gt 1) {
                            $count--
                            #Write-Host ('{0} Uninstalling {1} Previous Version of Script: {2}' -f $Counter1, $count, $scriptName) -ForegroundColor Yellow
                            Write-Host ("`tUninstalling {0} Previous Version(s) of Script: {1}" -f $count, $scriptName) -ForegroundColor Yellow
                            #Write-Host "`nUninstalling $count Previous Version of Script: $scriptName" -ForegroundColor Yellow
                            $Latest = Get-InstalledScript $scriptName
                            Get-InstalledScript $scriptName -AllVersions | Where-Object { $_.Version -ne $Latest.Version } | Uninstall-Script -Force -ErrorAction Continue
                        }
                    }
                    else { Write-Host "`tSkipping Cleaning Up Old Version(s) of Script: $scriptName" -ForegroundColor Yellow }
                }
                # Close Progress Bar
                Write-Progress -Id 1 -Activity 'Cleanup Script' -Status "Script # $Script:counter2 of $Script:ScriptsCount" -Completed
                #>
            }
        }
    }
}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # Write Ent Time
    if ($Time -eq $true) {
        Write-Host "`tEnd Time - $(Get-Date)" -ForegroundColor Yellow
    }

    # Memory Cleanup
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    # End
    #Exit
    return
}
