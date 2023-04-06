<#
Name: Export ADFS Replay Party Trusts.ps1

This script to Export all the ADFS Relay Party Trusts.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-04-04 - Initial Release

#>

# Start Function(s)
# Clear Varables
function Get-UserVariable ($Name = '*')
{
    # these variables may exist in certain environments (like ISE, or after use of foreach)
    $special = 'ps','psise','psunsupportedconsoleapplications', 'foreach', 'profile'

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

function ExportADFSRelayTrust {

}

# End Function(s)

# Clear Screen
Clear-Host

# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0

# Write Output
Write-Host "Export ADFA Relay Party Trust" -ForegroundColor Green

# Get Date & Backup Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$backupRoot = "C" #Can use another drive if available
$backupFolder = "ADFSBackup"
$backupFolderPath = $backupRoot + ":\" + $backupFolder + "\"
$backupPath = $backupFolderPath + $date

# Verify ADFS BackupFolder
Write-Host "`tPlease Wait - Checking for Backup Directory" -ForegroundColor Yellow
if ((Test-Path $backupFolderPath) -eq $false) {
    New-Item -Path $backupFolderPath -ItemType directory
}

# Verify ADFS Date BackupPath
Write-Host "`tPlease Wait - Creating Backup Directory" -ForegroundColor Yellow
if ((Test-Path $backupPath) -eq $false) {
    New-Item -Path $backupPath -ItemType directory
}

# Enterprise Read-only Domain Controllers
$adfsRelayPartyTrusts = Get-AdfsRelyingPartyTrust | Select-Object Name
Write-Host "`tExporting All ADFS Relay Party Trust Information" -ForegroundColor Yellow
$exportFile = $backupPath + "All Relay Party Trusts.csv"
Get-AdfsRelyingPartyTrust | Export-CSV $exportFile

# Loop each Domain in the list
<#
$adfsRelayPartyTrusts | ForEach-Object {
    $trustName = $_
    Write-Host "`tExporting ADFS Relay Party Trust Information for $($trustName)" -ForegroundColor Yellow
    $exportFile = $backupPath + $trustName + ".txt"
    Get-AdfsRelyingPartyTrust -Name $trustName >> $exportFile
    $exportFile = $backupPath + $trustName + ".csv"
    Get-AdfsRelyingPartyTrust -Name $trustName | Export-CSV $exportFile
}
#>
Foreach ($trust in $adfsRelayPartyTrusts) {
    # Get Trust Details
    Write-Host "`tExporting ADFS Relay Party Trust Information for $($trust.Name)" -ForegroundColor Yellow
    $exportFile = $backupPath + $trust.Name + ".txt"
    Get-AdfsRelyingPartyTrust -Name $trust.Name >> $exportFile
    $exportFile = $backupPath + $trust.Name + ".csv"
    Get-AdfsRelyingPartyTrust -Name $trust.Name | Export-CSV $exportFile
}

# Export Data

# Clear Variables
Get-UserVariable | Remove-Variable

# End
