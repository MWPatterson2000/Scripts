<#
.SYNOPSIS
    Maintains installed PowerShell modules and scripts by reporting updates, backing up local content, and optionally updating or cleaning duplicate versions.

.DESCRIPTION
    This script will:
        Inventory installed PowerShell modules and scripts
        Check for available updates and preview updates
        Back up installed modules and scripts to configurable backup locations
        Update installed modules and scripts when requested
        Remove old duplicate versions of installed modules when requested
        Reduce memory usage by processing results with a shared in-memory record model

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
    2026-07-31      1.26.0731       Mike Patterson      Optimized memory usage by reducing duplicate in-memory object tracking
    2026-08-04      1.26.0804       Mike Patterson      Fixed version comparison to use [version] cast to prevent string/lexicographic ordering for Updating
    2026-08-28      1.26.0828       Mike Patterson      Fixed version comparison to use [version] cast to prevent string/lexicographic ordering for Cleanup
    
    VERSION 1.26.0828
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

    function New-ChangeRecord {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$State,

            [Parameter(Mandatory)]
            [string]$Name,

            [string]$Repository,
            [object]$Installed,
            [object]$Local,
            [object]$LocalPublished,
            [object]$Online,
            [object]$OnlinePublished
        )

        [pscustomobject]@{
            State              = $State
            Name               = $Name
            Repository         = $Repository
            Installed          = $Installed
            Local              = $Local
            'Local Published'  = $LocalPublished
            Online             = $Online
            'Online Published' = $OnlinePublished
        }
    }

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
    # Modules
    $Script:ModulesList = [System.Collections.Generic.List[object]]::new()
    $Script:ModulesNoChangesCount = 0
    $Script:ModulesLocalOnlyCount = 0
    $Script:ModulesLocalNewerCount = 0
    $Script:ModulesUpdatedCount = 0
    $Script:ModulesUpdatedPreviewCount = 0
    # Scripts
    $Script:ScriptsList = [System.Collections.Generic.List[object]]::new()
    $Script:ScriptsNoChangesCount = 0
    $Script:ScriptsLocalOnlyCount = 0
    $Script:ScriptsLocalNewerCount = 0
    $Script:ScriptsUpdatedCount = 0
    $Script:ScriptsUpdatedPreviewCount = 0
    <# WIP
    # PSResources
    $Script:PSResourcesList = [System.Collections.Generic.List[object]]::new()
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
    if ($Backup -eq $true) {
        Write-Host 'This Script will Copy All Installed Modules to Backup Location:'
        Write-Host "`tModule(s) from: $moduleSource" -ForegroundColor Yellow
        Write-Host "`tModule(s) to: $moduleDestination" -ForegroundColor Yellow
        Write-Host 'This Script will Copy All Installed PowerShell 7 Modules to Backup Location:'
        Write-Host "`tModule(s) from: $moduleSource7" -ForegroundColor Yellow
        Write-Host "`tModule(s) to: $moduleDestination7" -ForegroundColor Yellow
        Write-Host 'This Script will Copy All Installed Scripts to Backup Location:'
        Write-Host "`tScript(s) from: $scriptSource" -ForegroundColor Yellow
        Write-Host "`tScript(s) to: $scriptDestination" -ForegroundColor Yellow
    }
    Write-Host 'This Script will Check for Updates of Installed Module(s) & Script(s)'
    if ($Update -eq $true) {
        Write-Host 'This Script will Update the Installed Module(s) & Script(s)'
    }
    if ($Cleanup -eq $true) {
        Write-Host 'This Script will Remove Old Versions of Installed Module(s) & Script(s)'
    }

    # Get All Versions of PowerShell Module(s) & Script(s) Installed
    Write-Host 'Getting List & Count of PowerShell Installed: Module(s) & Script(s)'

    # Get All Versions of PowerShell Modules Installed
    #Write-Host 'Getting List & Count of PowerShell Module(s) Installed'
    $Script:ModulesAR = @(Get-InstalledModule -ErrorAction SilentlyContinue | Sort-Object Name)

    # Get All Versions of PowerShell Scripts Installed
    #Write-Host 'Getting List & Count of PowerShell Script(s) Installed'
    $Script:ScriptsAR = @(Get-InstalledScript -ErrorAction SilentlyContinue | Sort-Object Name)

    # WIP
    # Get All Versions of PowerShell Resources Installed
    #Write-Host 'Getting List & Count of PowerShell Module(s) Installed'
    #$Script:PSResourcesAR = Get-InstalledPSResource | Select-Object * | Sort-Object Name

    # Build Variables
    $Script:counter1 = 0 # Modules
    $Script:counter2 = 0 # Scripts
    #$Script:counter3 = 0 # PSResources

    # Check to see if Modules & Scripts Found
    if ((-not $Script:ModulesAR) -and (-not $Script:ScriptsAR)) {
        Write-Host ("`tModule(s) found: 0") -ForegroundColor Yellow
        Write-Host ("`tScript(s) found: 0") -ForegroundColor Yellow

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
        $Script:ModulesCount = @($Script:ModulesAR).Count
        Write-Host ("`tModule(s) Found: {0}" -f $Script:ModulesCount) -ForegroundColor Yellow
        $Script:ScriptsCount = @($Script:ScriptsAR).Count
        Write-Host ("`tScript(s) Found: {0}" -f $Script:ScriptsCount) -ForegroundColor Yellow
    }

    # Copy Modules Folder
    if ($Backup -eq $true) {
        Write-Host 'Copy All Versions of Installed Module(s) & Scripts'
        #Write-Host 'Copy All Versions of PowerShell Module(s) Installed'
        Write-Host "`tPowerShell Module(s)" -ForegroundColor Yellow
        #robocopy $moduleSource $moduleDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS
        $temp = robocopy $moduleSource $moduleDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS
        #Write-Host 'Copy All Versions of PowerShell 7 Module(s) Installed'
        Write-Host "`tPowerShell 7 Module(s)" -ForegroundColor Yellow
        #robocopy $moduleSource7 $moduleDestination7  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS
        $temp = robocopy $moduleSource7 $moduleDestination7  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS
        #Write-Host 'Copy All Versions of PowerShell Script(s) Installed'
        Write-Host "`tPowerShell Script(s)" -ForegroundColor Yellow
        #robocopy $scriptSource $scriptDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS
        $temp = robocopy $scriptSource $scriptDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH /NJS
    }

    # Check for Changes
    Write-Host 'Checking for Changes'
    # Find Updated Modules
    if ($Script:ModulesCount -gt 0) {
        # Find Updated Module(s)
        #Write-Host 'or Module Changes'
        Write-Host "`tModule(s)" -ForegroundColor Yellow
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
                $moduleT = New-ChangeRecord -State 'Local Only' -Name $module.Name -Repository $module.Repository -Installed $module.InstalledDate -Local $module.Version -LocalPublished $module.PublishedDate -Online 'N/A' -OnlinePublished 'N/A'
                [void]$Script:ModulesList.Add($moduleT)
                $Script:ModulesLocalOnlyCount++
            }
            elseif ([version]$module.Version -lt [version]$moduleUpdate.Version) {
                $moduleT = New-ChangeRecord -State 'Updated' -Name $module.Name -Repository $module.Repository -Installed $module.InstalledDate -Local $module.Version -LocalPublished $module.PublishedDate -Online $moduleUpdate.Version -OnlinePublished $moduleUpdate.PublishedDate
                [void]$Script:ModulesList.Add($moduleT)
                $Script:ModulesUpdatedCount++
            }
            elseif ([version]$module.Version -gt [version]$moduleUpdate.Version) {
                $moduleT = New-ChangeRecord -State 'Local Newer' -Name $module.Name -Repository $module.Repository -Installed $module.InstalledDate -Local $module.Version -LocalPublished $module.PublishedDate -Online $moduleUpdate.Version -OnlinePublished $moduleUpdate.PublishedDate
                [void]$Script:ModulesList.Add($moduleT)
                $Script:ModulesLocalNewerCount++
            }
            else {
                $Script:ModulesNoChangesCount++
            }

            # Check Pre-Release Modules
            if ($module.Version -like '*preview*') {
                $moduleUpdatePreRelease = Find-Module -Name $module.Name -AllowPrerelease -ErrorAction SilentlyContinue
                if ($null -ne $moduleUpdatePreRelease) {
                    if ([version]$module.Version -lt [version]$moduleUpdatePreRelease.Version) {
                        $moduleT = New-ChangeRecord -State 'Updated' -Name $module.Name -Repository $module.Repository -Installed $module.InstalledDate -Local $module.Version -LocalPublished $module.PublishedDate -Online $moduleUpdatePreRelease.Version -OnlinePublished $moduleUpdatePreRelease.PublishedDate
                        [void]$Script:ModulesList.Add($moduleT)
                        $Script:ModulesUpdatedPreviewCount++
                    }
                    elseif ([version]$module.Version -gt [version]$moduleUpdatePreRelease.Version) {
                        $moduleT = New-ChangeRecord -State 'Local Newer' -Name $module.Name -Repository $module.Repository -Installed $module.InstalledDate -Local $module.Version -LocalPublished $module.PublishedDate -Online $moduleUpdatePreRelease.Version -OnlinePublished $moduleUpdatePreRelease.PublishedDate
                        [void]$Script:ModulesList.Add($moduleT)
                        $Script:ModulesLocalNewerCount++
                    }
                    else {
                        $Script:ModulesNoChangesCount++
                    }
                }
            }
        }
        # Close Progress Bar
        Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed

        # Build Variables - Modules
        $Script:counter1 = 0
        # Counts are maintained during the scan to avoid extra list passes and reduce memory churn.

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
                $scriptT = New-ChangeRecord -State 'Local Only' -Name $script.Name -Repository $script.Repository -Installed $script.InstalledDate -Local $script.Version -LocalPublished $script.PublishedDate -Online 'N/A' -OnlinePublished 'N/A'
                [void]$Script:ScriptsList.Add($scriptT)
                $Script:ScriptsLocalOnlyCount++
            }
            elseif ([version]$script.Version -lt [version]$scriptUpdate.Version) {
                $scriptT = New-ChangeRecord -State 'Updated' -Name $script.Name -Repository $script.Repository -Installed $script.InstalledDate -Local $script.Version -LocalPublished $script.PublishedDate -Online $scriptUpdate.Version -OnlinePublished $scriptUpdate.PublishedDate
                [void]$Script:ScriptsList.Add($scriptT)
                $Script:ScriptsUpdatedCount++
            }
            elseif ([version]$script.Version -gt [version]$scriptUpdate.Version) {
                $scriptT = New-ChangeRecord -State 'Local Newer' -Name $script.Name -Repository $script.Repository -Installed $script.InstalledDate -Local $script.Version -LocalPublished $script.PublishedDate -Online $scriptUpdate.Version -OnlinePublished $scriptUpdate.PublishedDate
                [void]$Script:ScriptsList.Add($scriptT)
                $Script:ScriptsLocalNewerCount++
            }
            else {
                $Script:ScriptsNoChangesCount++
            }
        }
        # Close Progress Bar
        Write-Progress -Id 1 -Activity 'Checking Script' -Status "Script # $Script:counter2 of $Script:ScriptsCount" -Completed

        # Build Variables - Scripts
        $Script:counter2 = 0
        # Counts are maintained during the scan to avoid extra list passes and reduce memory churn.

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
                $modulesToUpdate = @($Script:ModulesList | Where-Object { $_.State -eq 'Updated' -and $_.Local -notlike '*preview*' -and $_.Online -notlike '*preview*' })
                foreach ($module in $modulesToUpdate) {
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
                $modulesToCleanup = @($Script:ModulesList | Where-Object { $_.State -eq 'Updated' -and $_.Local -notlike '*preview*' -and $_.Online -notlike '*preview*' })
                foreach ($module in $modulesToCleanup) {
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
                    if ($ModuleName -ne 'Pester') {
                        <#
                        $allVersions = @(Get-InstalledModule -Name $ModuleName -AllVersions -ErrorAction SilentlyContinue)
                        if ($allVersions.Count -gt 1) {
                            $latest = $allVersions | Sort-Object Version -Descending | Select-Object -First 1
                            $oldVersions = @($allVersions | Where-Object { $_.Version -ne $latest.Version })
                            if ($oldVersions.Count -gt 0) {
                                $count = $oldVersions.Count
                                Write-Host ("`tUninstalling {0} Previous Version(s) of Module: {1}" -f $count, $ModuleName) -ForegroundColor Yellow
                                $oldVersions | Uninstall-Module -Force -ErrorAction Continue
                            }
                        }
                        #>
                        $allVersions = @(Get-InstalledModule -Name $ModuleName -AllVersions -ErrorAction SilentlyContinue)

                        if ($allVersions.Count -gt 1) {

                            # Sort versions numerically, not as strings
                            $latest = $allVersions |
                            Sort-Object { [version]$_.Version } -Descending |
                            Select-Object -First 1

                            $oldVersions = @(
                                $allVersions |
                                Where-Object { [version]$_.Version -lt [version]$latest.Version }
                            )

                            if ($oldVersions.Count -gt 0) {
                                $count = $oldVersions.Count

                                Write-Host ("`tLatest Version: {0}" -f $latest.Version) -ForegroundColor Green
                                Write-Host ("`tUninstalling {0} Previous Version(s) of Module: {1}" -f $count, $ModuleName) -ForegroundColor Yellow

                                foreach ($oldVersion in $oldVersions) {
                                    Write-Host ("`t`tRemoving Version: {0}" -f $oldVersion.Version) -ForegroundColor Yellow

                                    Uninstall-Module -Name $ModuleName `
                                        -RequiredVersion $oldVersion.Version `
                                        -Force `
                                        -ErrorAction Continue
                                }
                            }
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
                $modulesToUpdatePreview = @($Script:ModulesList | Where-Object { $_.State -eq 'Updated' -and $_.Local -like '*preview*' -and $_.Online -like '*preview*' })
                foreach ($module in $modulesToUpdatePreview) {
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
                $modulesToCleanupPreview = @($Script:ModulesList | Where-Object { $_.State -eq 'Updated' -and $_.Local -like '*preview*' -and $_.Online -like '*preview*' })
                foreach ($module in $modulesToCleanupPreview) {
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
                    if ($ModuleName -ne 'Pester') {
                        <#
                        $allVersions = @(Get-InstalledModule -Name $ModuleName -AllVersions -ErrorAction SilentlyContinue)
                        if ($allVersions.Count -gt 1) {
                            $latest = $allVersions | Sort-Object Version -Descending | Select-Object -First 1
                            $oldVersions = @($allVersions | Where-Object { $_.Version -ne $latest.Version })
                            if ($oldVersions.Count -gt 0) {
                                $count = $oldVersions.Count
                                Write-Host ("`tUninstalling {0} Previous Version(s) of Module: {1}" -f $count, $ModuleName) -ForegroundColor Yellow
                                $oldVersions | Uninstall-Module -Force -ErrorAction Continue
                            }
                        }
                        #>
                        $allVersions = @(Get-InstalledModule -Name $ModuleName -AllVersions -ErrorAction SilentlyContinue)

                        if ($allVersions.Count -gt 1) {

                            # Sort versions numerically, not as strings
                            $latest = $allVersions |
                            Sort-Object { [version]$_.Version } -Descending |
                            Select-Object -First 1

                            $oldVersions = @(
                                $allVersions |
                                Where-Object { [version]$_.Version -lt [version]$latest.Version }
                            )

                            if ($oldVersions.Count -gt 0) {
                                $count = $oldVersions.Count

                                Write-Host ("`tLatest Version: {0}" -f $latest.Version) -ForegroundColor Green
                                Write-Host ("`tUninstalling {0} Previous Version(s) of Module: {1}" -f $count, $ModuleName) -ForegroundColor Yellow

                                foreach ($oldVersion in $oldVersions) {
                                    Write-Host ("`t`tRemoving Version: {0}" -f $oldVersion.Version) -ForegroundColor Yellow

                                    Uninstall-Module -Name $ModuleName `
                                        -RequiredVersion $oldVersion.Version `
                                        -Force `
                                        -ErrorAction Continue
                                }
                            }
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
                $scriptsToUpdate = @($Script:ScriptsList | Where-Object { $_.State -eq 'Updated' })
                foreach ($script in $scriptsToUpdate) {
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
                $scriptsToCleanup = @($Script:ScriptsList | Where-Object { $_.State -eq 'Updated' })
                foreach ($script in $scriptsToCleanup) {
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
