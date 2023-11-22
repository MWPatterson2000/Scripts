<#
Name: Export ADFS Replay Party Trusts.ps1

This script to Export all the ADFS Relay Party Trusts.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-04-04 - Initial Release
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
    Clear-Host

    # PowerShell 5.x required. The version of PowerShell included with Windows 10
    #Requires -Version 5.0

    # Write Output
    Write-Host 'Export Trust(s)' -ForegroundColor Green

    # Get Date & Backup Locations
    $date = get-date -Format 'yyyy-MM-dd-HH-mm'
    $backupRoot = 'C' #Can use another drive if available
    $backupFolder = 'Temp'
    $backupFolderPath = $backupRoot + ':\' + $backupFolder + '\'
    $backupPath = $backupFolderPath + $date
}

Process {
    # Export ADFS Access Control Policy
    Write-Host "`tExporting All ADFS Access Control Policy Information" -ForegroundColor Yellow
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Access Control Policy.txt'
    Write-Host $exportFile
    Get-AdfsAccessControlPolicy >> $exportFile
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Access Control Policy.json'
    Write-Host $exportFile
    Get-AdfsAccessControlPolicy | ConvertTo-Json | Out-File $exportFile
    <#
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Access Control Policy.csv"
    Write-Host $exportFile
    Get-AdfsAccessControlPolicy | Export-CSV $exportFile
    #>

    # Export ADFS Application Group
    Write-Host "`tExporting All ADFS Application Group Information" -ForegroundColor Yellow
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Application Group.txt'
    Write-Host $exportFile
    Get-AdfsApplicationGroup >> $exportFile
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Application Group.json'
    Write-Host $exportFile
    Get-AdfsApplicationGroup | ConvertTo-Json | Out-File $exportFile
    <#
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Application Group.csv"
    Write-Host $exportFile
    Get-AdfsApplicationGroup | Export-CSV $exportFile
    #>

    # Export ADFS Application Permissions
    Write-Host "`tExporting All ADFS Application Information" -ForegroundColor Yellow
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Application Permissions.txt'
    Write-Host $exportFile
    Get-AdfsApplicationPermission >> $exportFile
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Application Permissions.json'
    Write-Host $exportFile
    Get-AdfsApplicationPermission | ConvertTo-Json | Out-File $exportFile
    <#
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Application Permissions.csv"
    Write-Host $exportFile
    Get-AdfsApplicationPermission | Export-CSV $exportFile
    #>

    # Export ADFS Native Client Application
    Write-Host "`tExporting All ADFS Native Client Application" -ForegroundColor Yellow
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Native Client Application.txt'
    Write-Host $exportFile
    Get-AdfsNativeClientApplication  >> $exportFile
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Native Client Application.json'
    Write-Host $exportFile
    Get-AdfsNativeClientApplication  | ConvertTo-Json | Out-File $exportFile
    <#
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Native Client Application.csv"
    Write-Host $exportFile
    Get-AdfsNativeClientApplication  | Export-CSV $exportFile
    #>

    # Export ADFS Server Application
    Write-Host "`tExporting All ADFS Server Application Information" -ForegroundColor Yellow
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Server Application.txt'
    Write-Host $exportFile
    Get-AdfsServerApplication >> $exportFile
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Server Application.json'
    Write-Host $exportFile
    Get-AdfsServerApplication | ConvertTo-Json | Out-File $exportFile
    <#
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Server Application.csv"
    Write-Host $exportFile
    Get-AdfsServerApplication | Export-CSV $exportFile
    #>

    # Export ADFS Web API Application
    Write-Host "`tExporting All ADFS Web API Application Information" -ForegroundColor Yellow
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Web API Application.txt'
    Write-Host $exportFile
    Get-AdfsWebApiApplication >> $exportFile
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Web API Application.json'
    Write-Host $exportFile
    Get-AdfsWebApiApplication | ConvertTo-Json | Out-File $exportFile
    <#
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Web API Application.csv"
    Write-Host $exportFile
    Get-AdfsWebApiApplication | Export-CSV $exportFile
    #>

    # Export ADFS Relay Party Trusts
    Write-Host "`tExporting All ADFS Relay Party Trust Information" -ForegroundColor Yellow
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Relay Party Trusts.txt'
    Write-Host $exportFile
    Get-AdfsRelyingPartyTrust >> $exportFile
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + 'All Relay Party Trusts.json'
    Write-Host $exportFile
    Get-AdfsRelyingPartyTrust | ConvertTo-Json | Out-File $exportFile
    <#
    $exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Relay Party Trusts.csv"
    Write-Host $exportFile
    Get-AdfsRelyingPartyTrust | Export-CSV $exportFile
    #>

}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    Exit
}
