<#
.SYNOPSIS
    Disable IPv6 on all Network Adaptors

.DESCRIPTION
    Will look through all Network Adaptors on the system and Disable IPv6 Binding

.PARAMETER


.EXAMPLE


.LINK
    https://github.com/MWPatterson2000/Scripts/

.NOTES
    Change Log:
    Date            Version         By                  Notes
    ----------------------------------------------------------
    2024-02-15      2024.02.15      Mike Patterson      Initial release

    
    VERSION 1.2024.0215
    GUID 
    AUTHOR Michael Patterson
    CONTACT scripts@mwpatterson.com
    COMPANYNAME 
    COPYRIGHT 
    APPLICATION 
    FEATURE 
    TAGS 
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
)

Begin {
    # Clear Screen
    Clear-Host

    <#
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
    # Self-elevate the script if required
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { 
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        Exit
    }
    #>

    #<#
    # Check For Admin Mode
    #Requires -RunAsAdministrator
    #>

    # Funtions
    # Start Functions

    # Email Function

}

Process {
    $adapter = '*'
    # you can specify what type of adapter you want to make changes to like Wireless or Wired
    # depending on adapter name or use * for all
    $adapters = Get-NetAdapter -name $adapter
    Write-Host "Found $($adapters.Length) adapters"
    foreach ($adapter in $adapters) {
        $adName = $adapter.Name
        Write-Host "Working on: $adName"
        $adBindings = Get-NetAdapterBinding -name $adName
        foreach ($adbind in $adBindings) {
            Write-Host $adbind.ComponentID
            if ($adbind.ComponentID -eq 'ms_tcpip6' -and $adbind.Enabled -eq $true) {
                Write-Host "Disabling IPv6 on $adName"
                Set-NetAdapterBinding -Name $adName -ComponentID ms_tcpip6 -Enabled $false
            }
        }
    }
}

End {
    # End
    Exit
}
    
# End
