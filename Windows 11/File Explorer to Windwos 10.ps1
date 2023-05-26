#Requires -RunAsAdministrator
#Requires -Version 5.1
<#
    .SYNOPSIS
        Reverts to Windows 10 file explorer with a registry key. Reboot required.

    .NOTES
        # Script info
        Author:   Olav Rønnestad Birkeland
        Created:  211201
        Modified: 211201

        # Notes
        * https://www.tomshardware.com/how-to/restore-windows-10-explorer-windows-11

    .EXAMPLE
        & $psISE.CurrentFile.FullPath
        & $psISE.CurrentFile.FullPath -Revert
#>


# Input parameters
[OutputType($null)]
Param(
    [Parameter()]
    [switch] $Revert
)


# PowerShell preferences
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'


# Assets
$Path = [string] 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'
$Name = [string] '{e2bf9676-5f8f-435c-97eb-11607a5bedf7}'
$Type = [string] 'String'


# Set
if ($Revert) {    
    if (Test-Path -Path $Path -PathType 'Container') {
        Write-Information -MessageData 'Reverting changes.'
        $null = Remove-Item -Path $Path -Recurse -Force
    }
    else {
        Write-Information -MessageData 'Already reverted.'
    }
}
else {
    if (Test-Path -Path $Path -PathType 'Container') {
        Write-Information -MessageData 'Path already exists.'
    }
    else {
        Write-Information -MessageData 'Path does not already exist, creating it.'
        $null = New-Item -Path $Path -ItemType 'Directory' -Force
    }
    Write-Information -MessageData 'Setting registry key.'
    $null = Set-ItemProperty -Path $Path -Name $Name -Value '' -Type $Type -Force
}


# Done
Write-Information -MessageData 'Done.'