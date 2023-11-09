<#
Name: Installed Module Count.ps1

This script to get a count of All Installd PowerShell Modules

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-10-24 - Initial Release

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
#Clear-Host

<#
# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0
#>

<#
# PowerShell Version Requirements - v7.2 (LTS) Min
#Requires -Version 7.2
#>

# Get All Versions of PowerShell Modules Installed
Write-Host "Getting Count of PowerShell Module(s) Installed - $(Get-Date)"
$Script:ModulesAR = Get-InstalledModule | Select-Object * | Sort-Object Name
if (-not $Script:ModulesAR) {
    Write-Host ("`tModules found: 0") -ForegroundColor Yellow
    return
}
else {
    $ModulesCount = $Script:ModulesAR.Count
    Write-Host ("`tModules Found: {0}" -f $ModulesCount) -ForegroundColor Yellow
}

# Clear Variables
Write-Host "`nScript Cleanup"
Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

# End

