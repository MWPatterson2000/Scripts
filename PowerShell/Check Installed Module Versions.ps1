<#
Name: Check Installed Module Versions.ps1

This script to List All Installd PowerShell Modules that have a different version Online or no matching Online version

Michael Patterson
scripts@mwpatterson.com

Revision History
    2021-10-21 - Initial Release
    2023-09-22 - Added Additional Information to Report
    2023-10-10 - Added Local Module Published Date
    2023-11-19 - Converted to Advanced Script
    2023-12-02 - Added Progress Bar

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
    # Get All Versions of PowerShell Modules Installed
    #Write-Host "Getting All Versions of PowerShell Module(s) Installed"
    Write-Host "Getting List & Count of PowerShell Module(s) Installed - $(Get-Date)"
    $Script:ModulesAR = Get-InstalledModule | Select-Object * | Sort-Object Name

    # Build Variables
    #$Script:ModulesAR
    #Write-Host "`tModule(s) Found:" ($Script:ModulesAR).Count
    #$Script:ModulesCount = $Script:ModulesAR.Count
    #Write-Host "`tModule(s) Found:" $Script:ModulesCount
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
        #$Script:percentComplete1d = '{0:N2}' -f $Script:percentComplete1
        #Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -PercentComplete $Script:percentComplete1
        #Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module: $($module.Name) - $Script:counter1 of $Script:ModulesCount" -PercentComplete $Script:percentComplete1
        #Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module: $($module.Name) - $Script:counter1 of $Script:ModulesCount - $Script:percentComplete1d%" -PercentComplete $Script:percentComplete1
        Write-Progress -Id 1 -Activity 'Checking Module' -Status "$Script:percentComplete1d% - $Script:counter1 of $Script:ModulesCount - Module: $($module.Name)" -PercentComplete $Script:percentComplete1
        #Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1" -PercentComplete $Script:percentComplete1 -CurrentOperation "Module $($module.Name)"
        
        $moduleUpdate = Find-Module -Name $module.Name -ErrorAction SilentlyContinue
        if ($module.Version -lt $moduleUpdate.Version) {
            $moduleT = New-Object System.Object
            $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
            $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
            $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
            #$moduleT | Add-Member -type noteproperty -Name "Local Version" -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
            #$moduleT | Add-Member -type noteproperty -Name "Online Version" -Value $moduleUpdate.Version
            $moduleT | Add-Member -type noteproperty -Name 'Online' -Value $moduleUpdate.Version
            $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value $moduleUpdate.PublishedDate
            [void]$Script:UpdatedModules.Add($moduleT)
        }
        elseif ($module.Version -gt $moduleUpdate.Version) {
            $moduleT = New-Object System.Object
            $moduleT | Add-Member -type noteproperty -Name 'Name' -value $module.Name
            $moduleT | Add-Member -type noteproperty -Name 'Repository' -Value $module.Repository
            $moduleT | Add-Member -type noteproperty -Name 'Installed' -Value $module.InstalledDate
            #$moduleT | Add-Member -type noteproperty -Name "Local Version" -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
            #$moduleT | Add-Member -type noteproperty -Name "Online Version" -Value $moduleUpdate.Version
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
            #$moduleT | Add-Member -type noteproperty -Name "Local Version" -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local' -Value $module.Version
            $moduleT | Add-Member -type noteproperty -Name 'Local Published' -Value $module.PublishedDate
            #$moduleT | Add-Member -type noteproperty -Name "Online Version" -Value "N/A"
            $moduleT | Add-Member -type noteproperty -Name 'Online' -Value 'N/A'
            $moduleT | Add-Member -type noteproperty -Name 'Online Published' -Value 'N/A'
            [void]$Script:UpdatedModules.Add($moduleT)
        }
    }
    # Close Progress Bar
    Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed

    # Write Data
    $Script:UpdatedModules | Format-Table -AutoSize

}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # Memory Cleanup
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    # End
    #Exit
    return
}
