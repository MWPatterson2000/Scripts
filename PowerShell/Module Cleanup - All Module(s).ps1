<#
Name: Module Cleanup - All Module(s).ps1

Allows the User to Cleanup Old Versions of PowerShell Module(s) on the Client

Michael Patterson
scripts@mwpatterson.com

Revision History
    2021-10-21 - Initial Release
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
}

Process {
    # Copy Modules Folder
    Write-Host 'Copy All Versions of PowerShell Module(s) Installed'
    $moduleSource = 'C:\Program Files\WindowsPowerShell\Modules'
    $moduleDestination = 'D:\PowerShell\Modules'
    #robocopy 'C:\Program Files\WindowsPowerShell\Modules' 'D:\PowerShell\Modules'  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH #/NJS 
    robocopy $moduleSource $moduleDestination  /S /R:1 /W:1 /XO /XC /MT:24 /ZB /XF /NC /NS /NFL /NDL /NP /NJH #/NJS 

    # Get All Versions of PowerShell Modules Installed
    #Write-Host "Getting All Versions of PowerShell Module(s) Installed"
    Write-Host "Getting Count of PowerShell Module(s) Installed - $(Get-Date)"
    $Script:ModulesAR = Get-InstalledModule | Select-Object * | Sort-Object Name

    # Build Variables
    #$Script:ModulesAR
    #Write-Host "`tModule(s) Found:" ($Script:ModulesAR).Count
    #$Script:ModulesCount = $Script:ModulesAR.Count
    #Write-Host "`tModule(s) Found:" $Script:ModulesCount
    $Script:counter1 = 0

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
        $Script:ModulesCount = $Script:ModulesAR.Count
        Write-Host ("`tModules Found: {0}" -f $Script:ModulesCount) -ForegroundColor Yellow
    }

    # Cleanup old versions of PowerShell Modules
    #$i = 0
    Write-Host 'Checking for Old Version(s) of Module(s)'
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

        #$i++
        #$Counter = ("[{0,$DigitsLength}/{1,$DigitsLength}]" -f $i, $Script:ModulesCount)
        #$CounterLength = $Counter.Length
        #Write-Host $module.Name
        $ModuleName = $module.Name
        #$count = (Get-Module $ModuleName -ListAvailable).Count # Faster Option
        $count = (Get-InstalledModule $ModuleName -AllVersions).Count # Slower Option
        if ($ModuleName -ne 'Pester') {
            if ($count -gt 1) {
                $count--
                #Write-Host "`tCleaning Up $count Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow
                Write-Host ('{0} Uninstalling {1} Previous Version of Module: {2}' -f $Counter, $count, $ModuleName) -ForegroundColor Yellow
                $Latest = Get-InstalledModule $ModuleName
                #Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module #-WhatIf
                #Get-InstalledModule $ModuleName -AllVersions | Where-Object {$_.Version -ne $Latest.Version} | Uninstall-Module -Force -ErrorAction Stop
                Get-InstalledModule $ModuleName -AllVersions | Where-Object { $_.Version -ne $Latest.Version } | Uninstall-Module -Force -ErrorAction Continue
            }
        }
        else { Write-Host "`tSkipping Cleaning Up Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow }
    }

    Write-Progress -Id 1 -Activity 'Checking Module' -Status "Module # $Script:counter1 of $Script:ModulesCount" -Completed
}

End {
    # End Cleanup
    Write-Host 'Finished Checking for Old Version(s) of Modules'

    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    Exit
}
