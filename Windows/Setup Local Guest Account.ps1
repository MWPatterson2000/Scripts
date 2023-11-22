<#
Name: Setup Local Guest Account.ps1

This script to Setup Local Guest Account on Client

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-06-17 - Initial Release
    2023-11-22 - Converting to Advanced

Ref URL https://www.howtogeek.com/280527/how-to-create-a-guest-account-in-Windows-10/

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
    # St
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
}

Process {
    # Add Uuser
    Net User Visitor /Add /Active:yes

    # Set Password
    Net User Visitor *

    # Remove user from User Group
    Net LocalGroup Users Visitor /Delete

    # Add user to Guests Group
    Net LocalGroup Guests Visitor /Add
}

End {
    # End
    Exit
}