<#
.SYNOPSIS
    Test-Connection to DC OU

.DESCRIPTION
    Run Test-Connectin to All Computers in the DC OU

.PARAMETER


.EXAMPLE


.LINK
    https://github.com/MWPatterson2000/Scripts/

.NOTES
    Change Log:
    Date            Version         By                  Notes
    ----------------------------------------------------------
    2024-02-09      2024.02.09      Mike Patterson      Initial release

    
    VERSION 1.2024.02.09
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

    <#
    # Hide PowerShell Console
    $Script:showWindowAsync = Add-Type -MemberDefinition @'
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
'@ -Name 'Win32ShowWindowAsync' -Namespace Win32Functions -PassThru

    Hide-PowerShell
    #>


    # Funtions
    # Start Functions
    # Show PowerShell
    Function Show-Powershell() {
        [CmdletBinding()]
        param ()
        $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
    }

    # Hide Show PowerShell
    Function Hide-Powershell() {
        [CmdletBinding()]
        param ()
        $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
    }

    # End Functions

}

Process {
    Test-Connection -ComputerName (Get-ADDomainController -filter * | Select-Object HostName) -Count 1
}

End {
    # End
    Exit
}
    
# End
