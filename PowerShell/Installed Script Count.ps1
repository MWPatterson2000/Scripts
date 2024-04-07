<#
Name: Installed Script Count.ps1

This script to get a count of All Installd PowerShell Script(s)

Michael Patterson
scripts@mwpatterson.com

Revision History
    2024-04-07 - Initial Release

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

    # Clear Screen
    #Clear-Host
}

Process {
    <#
    # PowerShell 5.x required. The version of PowerShell included with Windows 10
    #Requires -Version 5.0
    #>

    <#
    # PowerShell Version Requirements - v7.2 (LTS) Min
    #Requires -Version 7.2
    #>

    # Get All Versions of PowerShell Modules Installed
    Write-Host "Getting List & Count of PowerShell Script(s) Installed - $(Get-Date)"
    $Script:ModulesAR = Get-InstalledScript | Select-Object * | Sort-Object Name
    if (-not $Script:ModulesAR) {
        Write-Host ("`tScripts found: 0") -ForegroundColor Yellow
        return
    }
    else {
        $ModulesCount = $Script:ModulesAR.Count
        Write-Host ("`tScripts Found: {0}" -f $ModulesCount) -ForegroundColor Yellow
    }

}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    Exit
}

