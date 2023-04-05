<#
Name: .ps1

This script is for Testing Connectivity to Domain Controllers.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-04-05 - Initial Release

#>

# Start Function(s)
function Test-AllDomainController {
    $dcs=(Get-ADDomainController -Filter *).Name
    foreach ($items in $dcs) {
    Test-Connection $items -Count 1}
    }

# End Function(s)

# Clear Screen
Clear-Host

<#
# Self-elevate the script if required
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
#>

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Test Connection to Domain Controllers
Test-AllDomainController

