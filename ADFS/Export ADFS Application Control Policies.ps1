<#
Name: Export ADFS Application Control Policies.ps1

This script to Export all the Application Control Policies in ADFS.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-06-14 - Initial Release

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

# End Function(s)

# Clear Screen
Clear-Host

# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0

# Write Output
Write-Host "Export ADFA Access Control Policy" -ForegroundColor Green

# Get Date & Backup Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$backupRoot = "C" #Can use another drive if available
$backupFolder = "Temp"
$backupFolderPath = $backupRoot + ":\" + $backupFolder + "\"
$backupPath = $backupFolderPath + $date

# Verify ADFS BackupFolder
Write-Host "`tPlease Wait - Checking for Backup Directory" -ForegroundColor Yellow
if ((Test-Path $backupFolderPath) -eq $false) {
    New-Item -Path $backupFolderPath -ItemType directory
}

# Enterprise Read-only Domain Controllers
#$adfsAccessControlPolicyName = Get-AdfsAccessControlPolicy | Select-Object Name
$adfsAccessControlPolicyAll = Get-AdfsAccessControlPolicy #| Select-Object *
Write-Host "`tExporting All ADFS Access Control Policy Information" -ForegroundColor Yellow
$exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Access Control Policies.txt"
Get-AdfsAccessControlPolicy >> $exportFile
$exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Access Control Policies.json"
#Get-AdfsAccessControlPolicy | ConvertTo-Json | Out-File $exportFile
$adfsAccessControlPolicyAll | ConvertTo-Json | Out-File $exportFile
#$exportFile = $backupPath + " - $env:COMPUTERNAME - " + "All Access Control Policies.csv"
#Get-AdfsAccessControlPolicy | Export-CSV $exportFile
#Pause


# Export Data

# Clear Variables
Get-UserVariable | Remove-Variable

# End
