<#
Name: Set Networks to Private.ps1

This script to Set Networks to Private on Client

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-X-X - Initial Release

#>

# Start Function(s)

# End Function(s)

# Clear Screen
Clear-Host

#<#
# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0
#>

<#
# PowerShell Version Requirements - v7.2 (LTS) Min
#$PSVersionTable
#$PSVersionTable.PSVersion
#Requires -Version 7.2
#>

#<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Change NetWorkConnection Category to Private
# Set Each Network Profile to Private
Get-NetConnectionProfile |
Where-Object { $_.NetWorkCategory -ne 'Private' } |
ForEach-Object {
    $_
    $_ | Set-NetConnectionProfile -NetWorkCategory Private -Confirm
}