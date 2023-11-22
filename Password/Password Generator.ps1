<#
Name: .ps1

This script is for Creating Ramdom Passwords.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-04-05 - Initial Release
    2023-11-22 - Converting to Advanced

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
    function New-RandomPassword {
        param(
            [Parameter()]
            [int]$MinimumPasswordLength = 5,
            [Parameter()]
            [int]$MaximumPasswordLength = 10,
            [Parameter()]
            [int]$NumberOfAlphaNumericCharacters = 5,
            [Parameter()]
            [switch]$ConvertToSecureString
        )
    
        Add-Type -AssemblyName 'System.Web'
        $length = Get-Random -Minimum $MinimumPasswordLength -Maximum $MaximumPasswordLength
        $password = [System.Web.Security.Membership]::GeneratePassword($length, $NumberOfAlphaNumericCharacters)
        if ($ConvertToSecureString.IsPresent) {
            ConvertTo-SecureString -String $password -AsPlainText -Force
        } 
        else {
            $password
        }
    }

    # End Function(s)

    # Clear Screen
    #Clear-Host

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
}

Process {
    # Generate Ramdom Password
    New-RandomPassword -MinimumPasswordLength 10 -MaximumPasswordLength 15 -NumberOfAlphaNumericCharacters 6 -ConvertToSecureString
}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    Exit
}
