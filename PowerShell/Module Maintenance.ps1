<#
    Allows the User to Update & Cleanup Old Versions of PowerShell Module(s) on the Client
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
    robocopy 'C:\Program Files\WindowsPowerShell\Modules' 'C:\PowerShell\Modules'  /S /R:1 /W:1 /NP /XO /XC /MT:24 /ZB /XF

    # Update Modules
    Write-Host 'Updating All Versions of PowerShell Module(s) Installed'
    Update-Module

    # Get All Versions of PowerShell Modules Installed
    Write-Host 'Getting All Versions of PowerShell Module(s) Installed'
    $Script:ModulesAR = Get-InstalledModule

    # Cleanup old versions of PowerShell Modules
    Write-Host 'Checking for Old Version(s) of Modules'
    foreach ($module in $Script:ModulesAR) {
        #Write-Host $module.Name
        $ModuleName = $module.Name
        #$count = (Get-Module $ModuleName -ListAvailable).Count # Faster Option
        $count = (Get-InstalledModule $ModuleName -AllVersions).Count # Slower Option
        if ($ModuleName -ne 'Pester') {
            if ($count -gt 1) {
                $count--
                Write-Host "`tCleaning Up $count Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow
                $Latest = Get-InstalledModule $ModuleName
                #Get-InstalledModule $ModuleName -AllVersions | ? {$_.Version -ne $Latest.Version} | Uninstall-Module #-WhatIf
                Get-InstalledModule $ModuleName -AllVersions | Where-Object { $_.Version -ne $Latest.Version } | Uninstall-Module -Force -ErrorAction Stop
            }
        }
        else { Write-Host "`tSkipping Cleaning Up Old Version(s) of Module: $ModuleName" -ForegroundColor Yellow }
    }
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
